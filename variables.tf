# TEMPLATE: This file was automatically generated with `generate_addon_structure.sh`
# TEMPLATE: and should be modified as necessary
# TEMPLATE:
# TEMPLATE: All variables must have a description and should declare their type.
# TEMPLATE: Set defaults whenever possible but do not set defaults for required properties.
# TEMPLATE: Declare all variables in this file, sprawling declarations are difficult to identify.
# TEMPLATE:
# TEMPLATE: https://www.terraform.io/docs/language/values/variables.html
# TEMPLATE: https://www.terraform.io/docs/language/expressions/types.html
#
#variable "ssh_config" {
#  description = "Connection details to apply configuration"
#  type = object({
#    host        = string
#    user        = optional(string)
#    private_key = string
#  })
#}
#
#variable "addon_context" {
#  description = "Input context for the addon"
#  type = object({
#    equinix_project        = string
#    equinix_metro          = string
#    kubeconfig_remote_path = string
#  })
#}
#
#variable "portworx_config" {
#  description = "Add-on configuration for Portworx"
#  type        = any
#  default     = {}
#}

variable "project_id" {}

variable "ssh" {
  description = "SSH options for the storage provider including SSH details to access the control plane including the remote path to the kubeconfig file and a list of worker addresses"

  type = object({
    #host             = list("soln-demo-01", "soln-demo-02", "soln-demo-03", "soln-demo-04")
    host  	     = list(string)
    private_key      = string
    user             = string
    kubeconfig       = string
    worker_addresses = list(string)
    #worker_addresses = list("147.75.47.9", "147.75.35.95", "147.28.154.47", "145.40.99.5")
  })
  default = {
    host = ["soln-demo-01", "soln-demo-02", "soln-demo-03", "soln-demo-04"]
    worker_addresses = ["147.75.47.9", "147.75.35.95", "147.28.154.47", "145.40.99.5"]
    private_key      = "/root/.ssh/eqx_priv"
    user             = "root"
    kubeconfig       = "/root/demo/terraform-portworx-on-baremetal/modules/k8s_setup/kube-config-file"
  }
}

variable "account_id" {
  type = string
  default = "db4652ee-8937-47b2-952d-3b883fd2cb33"
  description = "Account id of PDS"
}

variable "tenant_id" {
  type = string
  default = "null"
  description = "Tenant id of PDS account"
}

variable "pds_token" {
  type = string
  default = "null"
  description = "Bearer token from PDS account page"
}

#variable "helm_version" {
#  type = string
#  default = "1.10.4"
#  description = "Helm version used during PDS install."
#}

variable "pds_name" {
  type = string
  default = "pds-demo-from-terraform"
  description = "Target Deployment name for cluster in PDS"
}

variable "px_security" {
  type        = string
  default     = "false"
  description = "Enable security for portworx or not"
}

variable "ssh_user" {
  type        = string
  default     = "root"
  description = "Username to connect baremetals"
}

variable "px_operator_version" {
  type        = string
  default     = "1.10.1"
  description = "Version for Portworx Operator"
}

variable "px_stg_version" {
  type        = string
  default     = "2.12.0"
  description = "Version for Portworx Storage Cluster"
}

variable "cluster_name" {
  type        = string
  default     = "px-cluster"
  description = "Name of the portworx cluster"
}

variable "metal_auth_token" {
  type        = string
  description = "Equinix Metal API Key"
}
