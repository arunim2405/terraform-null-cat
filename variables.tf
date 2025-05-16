data "aws_availability_zones" "available" {
  state = "available"
}
variable "aws_account_id" {
  description = "ID of the AWS account."
  type        = string
}
variable "client_id" {
  description = "Client ID for authentication."
  type        = string
  sensitive   = true
}
variable "client_secret" {
  description = "Secret key for the client ID."
  type        = string
  sensitive   = true
}
variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
  sensitive   = true
}
variable "region" {
  description = "AWS region code. (e.g. us-east-1)"
  type        = string
  validation {
    condition     = contains(["ap-northeast-1", "ap-northeast-2", "ap-south-1", "ap-southeast-1", "ap-southeast-2", "ca-central-1", "eu-central-1", "eu-west-1", "eu-west-2", "eu-west-3", "sa-east-1", "us-east-1", "us-east-2", "us-west-2"], var.region)
    error_message = "Valid values for var: region are (ap-northeast-1, ap-northeast-2, ap-south-1, ap-southeast-1, ap-southeast-2, ca-central-1, eu-central-1, eu-west-1, eu-west-2, eu-west-3, sa-east-1, us-east-1, us-east-2, us-west-2)."
  }
}
variable "operation_mode" {
  type        = string
  description = "Operation mode (sandbox, custom, firewall, isolated), see README.md for more information."
  default     = "isolated" // Operation mode (sandbox, custom, firewall, isolated), see README.md for more information.
  validation {
    condition     = contains(["sandbox", "custom", "firewall", "isolated"], var.operation_mode)
    error_message = "Valid values for var: operation_mode are (sandbox, custom, firewall, isolated)."
  }
}
variable "region_name" {
  description = "Name of the AWS region. (e.g. nvirginia)"
  type        = map(string)
  default = {
    "ap-northeast-1" = "tokyo"
    "ap-northeast-2" = "seoul"
    "ap-south-1"     = "mumbai"
    "ap-southeast-1" = "singapore"
    "ap-southeast-2" = "sydney"
    "ca-central-1"   = "canada"
    "eu-central-1"   = "frankfurt"
    "eu-west-1"      = "ireland"
    "eu-west-2"      = "london"
    "eu-west-3"      = "paris"
    "sa-east-1"      = "saopaulo"
    "us-east-1"      = "nvirginia"
    "us-east-2"      = "ohio"
    "us-west-2"      = "oregon"
    #"us-west-1" = "oregon"
  }
}
variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}
variable "group_workspace_admin" {
  description = "Group to grant admin workspace access."
  type        = string
  nullable    = false
}
variable "group_workspace_user" {
  description = "Group to grant user workspace access."
  type        = string
  nullable    = false
}
variable "enable_admin_configs_boolean" {
  description = "Preset Admin Config Values"
  type        = bool
  default     = false
}
variable "enable_audit_log_alerting" {
  description = "Enable Audit Log Alerting"
  type        = bool
  default     = false
}
variable "enable_sat_boolean" {
  description = "Enable Security Analysis Tool"
  type        = bool
  default     = false
}
variable "uc_catalog_name" {
  description = "Name of the S3 bucket for the Unity Catalog."
  type        = string
}
variable "external_locations" {
  type = list(object({
    name        = string # Custom whole name of resource, the name of the underlying S3 bucket, used later to access exact external location in output map
    url         = string # Path URL in cloud storage
    kms_key_arn = string # KMS key ARN for encryption
    owner           = optional(string)      # Owner of resource
    skip_validation = optional(bool, true)  # Suppress validation errors if any & force save the external location
    read_only       = optional(bool, false) # Indicates whether the external location is read-only.
    force_destroy   = optional(bool, true)
    force_update    = optional(bool, true)
    comment         = optional(string, "External location provisioned by Terraform")
    permissions = optional(set(object({
      principal  = string
      privileges = list(string)
    })), [])
    storage_credential_permissions = optional(set(object({
      principal  = string
      privileges = list(string)
    })), [])
    isolation_mode = optional(string, "ISOLATION_MODE_ISOLATED")
  }))
  description = "List of object with external location configuration attributes"
  default     = []
}
variable "catalog_config" {
  type = list(object({
    # Catalog config
    catalog_name           = string
    catalog_owner          = optional(string)             # Username/groupname/sp application_id of the catalog owner.
    catalog_storage_root   = optional(string)             # Location in cloud storage where data for managed tables will be stored
    catalog_isolation_mode = optional(string, "ISOLATED") # Whether the catalog is accessible from all workspaces or a specific set of workspaces. Can be ISOLATED or OPEN.
    catalog_comment        = optional(string)             # User-supplied free-form text
    catalog_properties     = optional(map(string))        # Extensible Catalog Tags.
    catalog_grants = optional(list(object({               # List of objects to set catalog permissions
      principal  = string                                 # Account level group name, user or service principal app ID
      privileges = list(string)
    })), [])
    # Schemas
    schema_default_grants = optional(list(object({ # Sets default grants for each schema created by 'schema_configs' block w/o 'schema_custom_grants' parameter set
      principal  = string                          # Account level group name, user or service principal app ID
      privileges = list(string)
    })), [])
    schema_configs = optional(list(object({
      schema_name       = string
      schema_owner      = optional(string)
      schema_comment    = optional(string)
      schema_properties = optional(map(string))
      schema_custom_grants = optional(list(object({ # Overwrites 'schema_default_grants'
        principal  = string                         # Account level group name, user or service principal app ID
        privileges = list(string)
      })), [])
    })), [])
  }))
  description = <<DESCRIPTION
  DESCRIPTION
  default     = []
}
variable "isolated_unmanaged_catalog_bindings" {
  type = list(object({
    catalog_name         = string                                     # Name of ISOLATED catalog
    binding_workspace_id = string                                     # ID of the target workspace for catalog binding.
    binding_type         = optional(string, "BINDING_TYPE_READ_ONLY") # Binding mode. Possible values are BINDING_TYPE_READ_ONLY, BINDING_TYPE_READ_WRITE
  }))
  description = <<DESCRIPTION
  DESCRIPTION
  default     = []
}
variable "volumes" {
  type = list(object({
    name             = string
    catalog_name     = string
    schema_name      = string
    storage_location = string
    owner            = optional(string)
    volume_type      = optional(string, "EXTERNAL")
    comment          = optional(string, "External volume provisioned by Terraform")
    permissions = optional(set(object({
      principal  = string
      privileges = list(string)
    })), [])
  }))
  description = "List of object with volume configuration attributes"
  default     = []
}
