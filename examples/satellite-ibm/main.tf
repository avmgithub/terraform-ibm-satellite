#####################################################
# IBM Cloud Satellite -  IBM Example
# Copyright 2021 IBM
#####################################################

provider "ibm" {
  region = var.ibm_region
  ibmcloud_api_key   = var.ibmcloud_api_key
}

###################################################################
# Create satellite location
###################################################################
module "satellite-location" {
  //Uncomment following line to point the source to registry level module
  //source = "terraform-ibm-modules/satellite/ibm//modules/location"

  source            = "../../modules/location"
  is_location_exist = var.is_location_exist
  location          = var.location
  managed_from      = var.managed_from
  location_zones    = var.location_zones
  location_bucket   = ibm_cos_bucket.location_cos_bucket_standard.bucket_name
  host_labels       = var.host_labels
  ibm_region        = var.ibm_region
  resource_group    = var.resource_group
  host_provider     = "ibm"
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}
resource "ibm_resource_instance" "location_cos_instance" {
  name              = "${var.is_prefix}-location-cos-instance"
  resource_group_id = data.ibm_resource_group.group.id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
}

resource "ibm_cos_bucket" "location_cos_bucket_standard" {
  bucket_name           = "${var.is_prefix}-location-cos-bucket-standard-3"
  resource_instance_id  = ibm_resource_instance.location_cos_instance.id
#  cross_region_location = var.COS_REGION
  region_location 	    = var.ibm_region
  storage_class         = "standard"
}