locals {
  zones      = ["${var.ibm_region}-1", "${var.ibm_region}-2", "${var.ibm_region}-3"]
  subnet_ids = [ibm_is_subnet.satellite_subnet[0].id, ibm_is_subnet.satellite_subnet[1].id, ibm_is_subnet.satellite_subnet[2].id]

  sg_rules = [
    for r in local.rules : {
      name       = r.name
      direction  = r.direction
      remote     = lookup(r, "remote", null)
      ip_version = lookup(r, "ip_version", null)
      icmp       = lookup(r, "icmp", null)
      tcp        = lookup(r, "tcp", null)
      udp        = lookup(r, "udp", null)
    }
  ]
  rules = [
    {
      name      = "${var.is_prefix}-ingress-1"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 22
        port_max = 22
      }
    },
    {
      name      = "${var.is_prefix}-ingress-2"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 80
        port_max = 80
      }
    },
    {
      name      = "${var.is_prefix}-ingress-3"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 443
        port_max = 443
      }
    },
    {
      name      = "${var.is_prefix}-ingress-4"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 30000
        port_max = 32767
      }
    },
    {
      name      = "${var.is_prefix}-ingress-5"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      udp = {
        port_min = 30000
        port_max = 32767
      }
    },
    {
      name      = "${var.is_prefix}-ingress-6"
      direction = "inbound"
      icmp = {
        type = 8
        code = null
      }
    },
    {
      name      = "${var.is_prefix}-egress-1"
      direction = "outbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 1
        port_max = 65535
      }
    }
  ]

  # hosts = merge({
  #     for i, host in var.cp_hosts :
  #     i => {
  #       instance_type     = host.instance_type
  #       count             = 1
  #       for_control_plane = true
  #       node_type         = host.node_type
  #       zone              = host.zone
  #       host_number       = host.host_number
  #       additional_labels = ["host:cp"]
  #     }
  #     }, {
  #     for i, host in var.worker_hosts :
  #     sum([i, length(var.cp_hosts)]) => {
  #       instance_type     = host.instance_type
  #       count             = 1
  #       for_control_plane = false
  #       node_type         = host.node_type
  #       zone              = host.zone
  #       host_number       = host.host_number
  #       additional_labels = ["type:worker"]
  #     }
  #     }, {
  #     for i, host in var.storage_hosts :
  #     sum([i, length(var.cp_hosts), length(var.worker_hosts)]) => {
  #       instance_type     = host.instance_type
  #       count             = 1
  #       for_control_plane = false
  #       node_type         = host.node_type
  #       zone              = host.zone
  #       host_number       = host.host_number
  #       additional_labels = [ "type:storage" ]
  #     } 
  # })

  hosts_cp = {
    for i, host in var.cp_hosts :
    i => {
      instance_type     = host.instance_type
      count             = 1
      for_control_plane = true
      node_type         = host.node_type
      zone              = host.zone
      host_number       = host.host_number
      additional_labels = ["host:cp"]
    }
  }

  hosts_wn = {
    for i, host in var.worker_hosts : i => {
      instance_type     = host.instance_type
      count             = 1
      for_control_plane = false
      node_type         = host.node_type
      zone              = host.zone
      host_number       = host.host_number
      additional_labels = ["type:worker"]
    }
  } 
      
  hosts_sn = {
    for i, host in var.storage_hosts : i => {
      instance_type     = host.instance_type
      count             = 1
      for_control_plane = false
      node_type         = host.node_type
      zone              = host.zone
      host_number       = host.host_number
      additional_labels = [ "type:storage" ]
    } 
  }


  // convert hosts to be a flat object with one key per desired host
  hosts_flattened = { for index, item in flatten([
    for host_index, host in local.hosts_cp : [
      for count_index in range(0, host.count) : {
        instance_type     = host.instance_type
        for_control_plane = host.for_control_plane
        node_type         = host.node_type
        zone              = host.zone
        host_number       = host.host_number
        additional_labels = host.additional_labels
      }
    ]
  ]) : index => item }

}