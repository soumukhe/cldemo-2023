#  Define data sources

data "mso_site" "aws_site" {
  name = var.aws_site_name
}

data "mso_site" "azure_site" {
  name = var.azure_site_name
}


data "mso_site" "onprem_site" {
  name = var.onprem_site_name
}



# Define Tenant

resource "mso_tenant" "tenant" {
  name         = var.tenant.tenant_name
  display_name = var.tenant.display_name
  description  = var.tenant.description
  site_associations {
    site_id = data.mso_site.onprem_site.id
  }
  site_associations {
    site_id                = data.mso_site.aws_site.id
    vendor                 = "aws"
    aws_account_id         = var.awsstuff.aws_account_id
    is_aws_account_trusted = true
    #aws_access_key_id     = var.awsstuff.aws_access_key_id
    #aws_secret_key        = var.awsstuff.aws_secret_key
  }
  site_associations {
    site_id                 = data.mso_site.azure_site.id
    vendor                  = "azure"
    azure_access_type       = "shared"
    azure_subscription_id   = var.azurestuff.azure_subscription_id
    azure_shared_account_id = var.azurestuff.azure_subscription_id
  }

}

# Define schema and template


resource "mso_schema" "schema1" {
  name = var.schema_name
  template {
    name         = var.template1.name
    display_name = var.template1.name
    tenant_id    = mso_tenant.tenant.id
  }
  template {
    name         = var.template2.name
    display_name = var.template2.name
    tenant_id    = mso_tenant.tenant.id
  }

}

output "TN0" {
  value = tolist(mso_schema.schema1.template)[0]
}


output "TN1" {
  value = tolist(mso_schema.schema1.template)[1]
}


# Associate schema and template with cloud sites

resource "mso_schema_site" "azure_site" {
  schema_id           = mso_schema.schema1.id
  template_name       = tolist(mso_schema.schema1.template)[0].name
  site_id             = try(data.mso_site.azure_site.id)
  undeploy_on_destroy = true
}

resource "mso_schema_site" "aws_site" {
  schema_id           = mso_schema.schema1.id
  template_name       = tolist(mso_schema.schema1.template)[0].name
  site_id             = data.mso_site.aws_site.id
  undeploy_on_destroy = true
}

resource "mso_schema_site" "onprem_site" {
  schema_id           = mso_schema.schema1.id
  template_name       = tolist(mso_schema.schema1.template)[0].name
  site_id             = data.mso_site.onprem_site.id
  undeploy_on_destroy = true
}

resource "mso_schema_site" "aws_site-t2" {
  schema_id           = mso_schema.schema1.id
  template_name       = tolist(mso_schema.schema1.template)[1].name
  site_id             = mso_schema_site.aws_site.site_id
  undeploy_on_destroy = true
}

# Create Stretched VRF

resource "mso_schema_template_vrf" "vrf1" {
  schema_id    = mso_schema.schema1.id
  template     = mso_schema_site.onprem_site.template_name
  name         = try(var.vrf_name)
  display_name = try(var.vrf_name)
}


## Define Region, CIDR and Subnets in AWS

resource "mso_schema_site_vrf_region" "aws_region" {
  schema_id          = mso_schema.schema1.id
  template_name      = mso_schema_template_vrf.vrf1.template
  site_id            = data.mso_site.aws_site.id
  vrf_name           = mso_schema_template_vrf.vrf1.name
  region_name        = var.aws_region_name
  vpn_gateway        = false
  hub_network_enable = true # This enables attachment to Infra TGW
  hub_network = {
    name        = var.tgw_name
    tenant_name = "infra"
  }
  cidr {
    cidr_ip = var.aws_cidr_ip
    primary = true

    subnet {
      ip    = var.aws_subnet1
      zone  = var.aws_zone1
      usage = "user"
    }

    subnet {
      ip    = var.aws_subnet2
      zone  = var.aws_zone2
      usage = "gateway"
    }

    subnet {
      ip    = var.aws_subnet3
      zone  = var.aws_zone3
      usage = "gateway"
    }

  }
}




# Define Region, CIDR and Subnets in Azure

resource "mso_schema_site_vrf_region" "azure_region" {
  schema_id          = mso_schema.schema1.id
  template_name      = mso_schema_site_vrf_region.aws_region.template_name
  vrf_name           = mso_schema_template_vrf.vrf1.name
  site_id            = mso_schema_site.azure_site.site_id
  region_name        = var.azure_region_name
  vpn_gateway        = false
  hub_network_enable = true # This enables VNet Peering to Infra/Hub VNet
  hub_network = {
    name        = "default"
    tenant_name = "infra"
  }
  cidr {
    cidr_ip = var.azure_cidr_ip
    primary = true

    dynamic "subnet" {
      for_each = var.azure_user_subnets
      content {
        ip   = subnet.value.ip
        name = subnet.value.name
      }
    }
  }
}

## create ANP

resource "mso_schema_template_anp" "anp1" {
  schema_id    = mso_schema.schema1.id
  template     = mso_schema_site_vrf_region.azure_region.template_name
  name         = var.anp_name
  display_name = var.anp_name
}

# bd related for onPrem

resource "mso_schema_template_bd" "bridge_domain" {
  schema_id              = mso_schema.schema1.id
  template_name          = mso_schema_template_anp.anp1.template
  name                   = var.bd_name
  display_name           = var.bd_name
  vrf_name               = mso_schema_template_vrf.vrf1.name
  layer2_unknown_unicast = "proxy"
  layer2_stretch         = false
  unicast_routing        = true
}



#### trying with "mso_schema_site_bd_subnet"

resource "mso_schema_site_bd_subnet" "sub1" {
  schema_id     = mso_schema.schema1.id
  template_name = tolist(mso_schema.schema1.template)[0].name
  site_id       = mso_schema_site.onprem_site.site_id
  #bd_name            = mso_schema_site_bd.bd1.bd_name
  bd_name            = mso_schema_template_bd.bridge_domain.name
  ip                 = var.bd_subnet
  description        = var.bd_subnet
  shared             = false
  scope              = "public"
  querier            = true
  no_default_gateway = false
}



## create EPG

resource "mso_schema_template_anp_epg" "anp_epg" {
  schema_id                  = mso_schema.schema1.id
  template_name              = mso_schema_site_bd_subnet.sub1.template_name
  anp_name                   = mso_schema_template_anp.anp1.name
  name                       = var.epg_name
  bd_name                    = mso_schema_site_bd_subnet.sub1.bd_name
  vrf_name                   = mso_schema_template_bd.bridge_domain.vrf_name
  display_name               = var.epg_name
  useg_epg                   = false
  intra_epg                  = "unenforced"
  intersite_multicast_source = false
  preferred_group            = false
}

#### 

### Site Level - Policies
# epg selector for aws
resource "mso_schema_site_anp_epg_selector" "epgSel2" {
  schema_id     = mso_schema.schema1.id
  site_id       = data.mso_site.aws_site.id
  template_name = mso_schema_template_anp_epg.anp_epg.template_name
  anp_name      = mso_schema_template_anp.anp1.name
  epg_name      = mso_schema_template_anp_epg.anp_epg.name
  name          = "awssel"
  expressions {
    key      = "ipAddress"
    operator = "equals"
    value    = var.aws_subnet1
  }
}


resource "mso_schema_site_anp_epg_selector" "epgSel1" {
  schema_id     = mso_schema.schema1.id
  site_id       = data.mso_site.azure_site.id
  template_name = mso_schema_site_anp_epg_selector.epgSel2.template_name
  anp_name      = mso_schema_template_anp.anp1.name
  epg_name      = mso_schema_template_anp_epg.anp_epg.name
  name          = "azuresel"
  expressions {
    key      = "ipAddress"
    operator = "equals"
    value    = "10.70.1.0/24"
  }
}
# vmm binding

# troubleshooting for Aki -- TF_LOG env

resource "mso_schema_site_anp_epg_domain" "site_anp_epg_domain" {
  schema_id                = mso_schema.schema1.id
  template_name            = mso_schema_site_anp_epg_selector.epgSel1.template_name
  site_id                  = data.mso_site.onprem_site.id
  anp_name                 = mso_schema_template_anp.anp1.name
  epg_name                 = mso_schema_template_anp_epg.anp_epg.name
  domain_type              = "vmmDomain"
  vmm_domain_type          = "VMware"
  domain_name              = "VMM2"
  deploy_immediacy         = "lazy"
  resolution_immediacy     = "lazy"
  vlan_encap_mode          = "dynamic"
  allow_micro_segmentation = false
  switching_mode           = "native"
  switch_type              = "default"
  port_encap_vlan_type     = "vlan"
  enhanced_lag_policy_name = "elag1"
  enhanced_lag_policy_dn   = "uni/vmmp-VMware/dom-VMM2/vswitchpolcont/enlacplagp-elag1"
}


## create Filter
resource "mso_schema_template_filter_entry" "filter_entry" {
  schema_id = mso_schema.schema1.id
  # changing below temporarily for above log collection
  #template_name      = mso_schema_site_anp_epg_domain.site_anp_epg_domain.template_name
  template_name      = mso_schema_site_anp_epg_selector.epgSel1.template_name
  name               = var.filter_name
  display_name       = var.filter_name
  entry_name         = var.filter_entry_name
  entry_display_name = var.filter_entry_name
  destination_from   = "unspecified"
  destination_to     = "unspecified"
  source_from        = "unspecified"
  source_to          = "unspecified"
  arp_flag           = "unspecified"
}

## Create Contract
resource "mso_schema_template_contract" "template_contract" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema_template_filter_entry.filter_entry.template_name
  contract_name = var.contract_name
  display_name  = var.contract_name
  scope         = "context"
  directives    = ["none"]
  filter_relationship {
    filter_name = mso_schema_template_filter_entry.filter_entry.name
  }
}
#### add Contract Provider to EPg
resource "mso_schema_template_anp_epg_contract" "c1_epg_provider" {
  schema_id         = mso_schema.schema1.id
  template_name     = mso_schema_template_contract.template_contract.template_name
  anp_name          = mso_schema_template_anp.anp1.name
  epg_name          = mso_schema_template_anp_epg.anp_epg.name
  contract_name     = mso_schema_template_contract.template_contract.contract_name
  relationship_type = "provider"

}


#####  Template2 items

# create anp

resource "mso_schema_template_anp" "anp2" {
  schema_id    = mso_schema.schema1.id
  template     = tolist(mso_schema.schema1.template)[1].name
  name         = var.t2anp_name
  display_name = var.t2anp_name
}

data "mso_schema_site_vrf" "v1" {
  site_id   = data.mso_site.aws_site.id
  schema_id = mso_schema.schema1.id
  vrf_name  = mso_schema_template_vrf.vrf1.name
}

output "vrf_info" {
  value = data.mso_schema_site_vrf.v1
}


# Create contract and associate with filter in Template2
#  To make cross reference work you have to also include the VRF_schema_id and vrf_template_name from template1


#########################  Below   trying   based    on    Akini's     advise   ###################

# Create epg in template2, tied to VRF in template1
resource "mso_schema_template_anp_epg" "t2anp_epg" {
  schema_id         = mso_schema_template_anp.anp2.schema_id
  template_name     = tolist(mso_schema.schema1.template)[1].name
  anp_name          = mso_schema_template_anp.anp2.name
  name              = var.t2epg_name
  vrf_name          = mso_schema_template_vrf.vrf1.name
  vrf_schema_id     = mso_schema.schema1.id
  vrf_template_name = tolist(mso_schema.schema1.template)[0].name
  display_name      = var.t2epg_name
}


# epg selectors to be added


resource "mso_schema_site_anp_epg_selector" "t2-epgSel1" {
  schema_id     = mso_schema_template_anp.anp2.schema_id
  site_id       = data.mso_site.aws_site.id
  template_name = mso_schema_template_anp_epg.t2anp_epg.template_name
  anp_name      = mso_schema_template_anp_epg.t2anp_epg.anp_name
  epg_name      = mso_schema_template_anp_epg.t2anp_epg.name
  name          = var.t2epg_sel1
  expressions {
    key      = "ipAddress"
    operator = "equals"
    value    = var.aws_subnet2
  }
}

resource "mso_schema_site_anp_epg_selector" "t2-epgSel2" {
  schema_id     = mso_schema_site_anp_epg_selector.t2-epgSel1.schema_id
  site_id       = mso_schema_site_anp_epg_selector.t2-epgSel1.site_id
  template_name = mso_schema_site_anp_epg_selector.t2-epgSel1.template_name 
  anp_name      = mso_schema_site_anp_epg_selector.t2-epgSel1.anp_name
  epg_name      = mso_schema_site_anp_epg_selector.t2-epgSel1.epg_name
  name          = var.t2epg_sel2
  expressions {
    key      = "ipAddress"
    operator = "equals"
    value    = var.aws_subnet3
  }
}



# Create External EPG template2, tied to VRF in template1
resource "mso_schema_template_external_epg" "externalepg" {
  schema_id         = mso_schema_template_anp.anp2.schema_id
  template_name     = tolist(mso_schema.schema1.template)[1].name
  external_epg_name = var.t2ext_epg
  external_epg_type = "cloud"
  display_name      = var.t2ext_epg
  vrf_name          = mso_schema_template_vrf.vrf1.name
  vrf_schema_id     = mso_schema.schema1.id
  vrf_template_name = tolist(mso_schema.schema1.template)[0].name
  anp_name          = mso_schema_template_anp.anp2.name
  selector_name     = var.t2ext_epg_selector
  selector_ip       = var.t2ext_epg_selector_ip
}







# Create contract and associate with filter in Template2


## Create Contract for IGW
resource "mso_schema_template_contract" "template2-contract1" {
  schema_id     = mso_schema_template_anp.anp2.schema_id
  template_name = tolist(mso_schema.schema1.template)[1].name
  contract_name = var.t2contract_name
  display_name  = var.t2contract_name
  scope         = "context"
  directives    = ["none"]
  filter_relationship {
    filter_name          = mso_schema_template_filter_entry.filter_entry.name
    filter_schema_id     = mso_schema_template_anp.anp2.schema_id
    filter_template_name = tolist(mso_schema.schema1.template)[0].name
  }
}

#### add Contract Provider to EPg
resource "mso_schema_template_anp_epg_contract" "ap-alb-c1" {
  schema_id         = mso_schema.schema1.id
  template_name     = tolist(mso_schema.schema1.template)[1].name
  anp_name          = mso_schema_template_anp.anp2.name
  epg_name          = mso_schema_template_anp_epg.t2anp_epg.name
  contract_name     = mso_schema_template_contract.template2-contract1.contract_name
  relationship_type = "provider"

}

#add Contract Provider to EPg; contract is from template1, this is for the ALB target-grop
resource "mso_schema_template_anp_epg_contract" "ap-alb-c2" {
  schema_id              = mso_schema.schema1.id
  template_name          = tolist(mso_schema.schema1.template)[1].name
  anp_name               = mso_schema_template_anp.anp2.name
  epg_name               = mso_schema_template_anp_epg.t2anp_epg.name
  contract_name          = mso_schema_template_contract.template_contract.contract_name
  contract_schema_id     = mso_schema.schema1.id
  contract_template_name = tolist(mso_schema.schema1.template)[0].name
  relationship_type      = "consumer"

}



#### add Contract Provider to extEPg
resource "mso_schema_template_external_epg_contract" "extEPg-c1" {
  schema_id         = mso_schema.schema1.id
  template_name     = tolist(mso_schema.schema1.template)[1].name
  external_epg_name = mso_schema_template_external_epg.externalepg.external_epg_name
  contract_name     = mso_schema_template_contract.template2-contract1.contract_name
  relationship_type = "consumer"

}

