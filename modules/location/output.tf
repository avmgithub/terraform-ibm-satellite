
output "location_id" {
  value = try(data.ibm_satellite_location.location.id, "")
}

output "host_script" {
  value = try(data.ibm_satellite_attach_host_script.script.host_script, "")
}

output "script_path" {
  value = try(data.ibm_satellite_attach_host_script.script.script_path, "")
}