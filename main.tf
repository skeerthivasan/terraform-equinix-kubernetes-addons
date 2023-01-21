#terraform {
#required_providers {
#    equinix = {
#      source = "equinix/equinix"
#    }
#  }
#}


provider "equinix" {
  auth_token = var.metal_auth_token
}

locals {
  mydata = zipmap(var.ssh.host, var.ssh.worker_addresses)
  ndata = join(" ", [for key, value in local.mydata : "${key},${value}"])
}

data "template_file" "config-vars" {
  template = file("${path.module}/templates/cluster-config-vars.template")
  vars = {
    XX_HOST_IPS_XX = local.ndata
    XX_SSH_USER_XX = var.ssh_user
    XX_PXOP_XX = var.px_operator_version
    XX_PXSTG_XX = var.px_stg_version
    XX_CLUSTER_NAME_XX = var.cluster_name
    XX_PX_SECURITY_XX = var.px_security
    }
}

resource "local_sensitive_file" "cluster-config-vars" {
  content  = "${data.template_file.config-vars.rendered}"
  filename = "${path.root}/cluster-config-vars"
}

resource "local_sensitive_file" "px-operator" {
  content  = templatefile("${path.module}/templates/px-operator.tftpl", {pxop_ver = var.px_operator_version})
  filename = "${path.root}/px-operator.yml"
}


resource "local_sensitive_file" "storage-cluster" {
  content  = templatefile("${path.module}/templates/storage-cluster.tftpl", {kvdb_device = "/dev/pwx_vg/pwxkvdb", px_stg_ver = var.px_stg_version, px_sec = var.px_security})
  filename = "${path.root}/storage-cluster.yml"
}


resource "null_resource" "worker_disks" {
  count = length(var.ssh.worker_addresses)

  connection {
    type        = "ssh"
    user        = var.ssh.user
    private_key = file(var.ssh.private_key)
    host        = var.ssh.worker_addresses[count.index]
  }

  provisioner "file" {
    source      = "${path.module}/scripts/portworx_disk_setup.sh"
    destination = "/tmp/portworx_disk_setup.sh"

  }
  provisioner "remote-exec" {
    inline = [
      "bash /tmp/portworx_disk_setup.sh create"
    ]
  }
}

resource "null_resource" "install_portworx" {
  depends_on = [
    null_resource.worker_disks
  ]

  provisioner "local-exec" {
    command = <<-EOT
      vMasters=`kubectl --kubeconfig=${var.ssh.kubeconfig} get node --selector='node-role.kubernetes.io/master' --no-headers=true -o custom-columns=":metadata.name"`
      kubectl --kubeconfig ${var.ssh.kubeconfig} cordon $vMasters
      kubectl --kubeconfig ${var.ssh.kubeconfig} apply -f px-operator.yml
      kubectl --kubeconfig ${var.ssh.kubeconfig} apply -f storage-cluster.yml
    EOT
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
  }
}
