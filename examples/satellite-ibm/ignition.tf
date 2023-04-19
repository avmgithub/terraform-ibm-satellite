# Demo ignition file from satellite location attach.
# This file needs to be populated with the correct details to boot RHCOS properly
# data "local_file" "sat_attach_template" {
#     filename = "./templates/attachHost-satellite-location.ign.template"
# }

data "local_file" "sat_attach_template" {
  filename = "./templates/attachHost-satellite-location.ign.template"
}

data "local_file" "sat_user_template" {
    filename = "./templates/satelliteUser.ign.template"
}

data "local_file" "ssh_public_key" {
    filename = "./ssh/id_rsa.pub"
}

# file and content to add to the ignition template for login to nodes
data "local_file" "sat_user_file" {
    count    = local.create_ign_files
    filename = null_resource.add_sshkey_satuser[0].triggers.filename
}

# final ign attach scrpit
data "local_file" "attach_host_ign" {
    count    = local.create_ign_files
    filename = null_resource.create_ign_files[0].triggers.filename
}

resource "null_resource" "add_sshkey_satuser" {
    count = local.create_ign_files
    triggers = {
        filename = "./templates/satelliteUser.ign"
    }
    
    provisioner "local-exec" {
    command = <<EOT
./scripts/addsshkey.sh "${data.local_file.ssh_public_key.content}" "${data.local_file.sat_user_template.filename}" "./templates/satelliteUser.ign"
EOT
    }
}

# Creates ignition files that will be passed on during VM node creation
# ./scripts/create_ign_files.sh "${module.satellite-location.script_path}" "${data.local_file.ssh_public_key.content}" "${data.local_file.sat_user_file[0].filename}"  "./templates/host_attach_script.ign"
resource "null_resource" "create_ign_files" {
#  for_each = { for i, hd in var.host_details : i => hd }
    count = local.create_ign_files
    triggers = {
    filename = "./templates/host_attach_script.ign"
    }
    provisioner "local-exec" {
        command = <<EOT
./scripts/create_ign_files.sh "${data.local_file.sat_attach_template.filename}" "${data.local_file.ssh_public_key.content}" "${data.local_file.sat_user_file[0].filename}"  "./templates/host_attach_script.ign"
EOT
    }
}