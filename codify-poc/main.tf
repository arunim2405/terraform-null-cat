module "bucket" {
  source   = "./modules/bucket"
  for_each = var.buckets

  bucket = each.value.bucket
  tags   = each.value.tags
}

module "security_group" {
  source   = "./modules/security_group"
  for_each = var.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = each.value.vpc_id
  tags        = each.value.tags
}
