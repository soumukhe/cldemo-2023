# Deploy Template

resource "mso_schema_template_deploy_ndo" "template1_deployer" {
  schema_id     = mso_schema.schema1.id
  template_name = var.template1.name
  depends_on = [

    mso_tenant.tenant,
    mso_schema.schema1,
    mso_schema_site.azure_site,
    mso_schema_site.aws_site,
    mso_schema_site.onprem_site,
    mso_schema_site.aws_site-t2,
    mso_schema_template_vrf.vrf1,
    mso_schema_site_vrf_region.aws_region,
    mso_schema_site_vrf_region.azure_region,
    mso_schema_template_anp.anp1,
    mso_schema_template_bd.bridge_domain,
    mso_schema_site_bd_subnet.sub1,
    mso_schema_template_anp_epg.anp_epg,
    mso_schema_site_anp_epg_selector.epgSel2,
    mso_schema_site_anp_epg_selector.epgSel1,
    mso_schema_site_anp_epg_domain.site_anp_epg_domain,
    mso_schema_template_filter_entry.filter_entry,
    mso_schema_template_contract.template_contract,
    mso_schema_template_anp_epg_contract.c1_epg_provider

  ]
  re_deploy = true
}



resource "mso_schema_template_deploy_ndo" "template2_deployer" {
  schema_id     = mso_schema.schema1.id
  template_name = var.template2.name
  depends_on = [

    mso_schema_template_deploy_ndo.template1_deployer,
    mso_schema_template_anp.anp2,
    mso_schema_template_anp_epg.t2anp_epg,
    mso_schema_site_anp_epg_selector.t2-epgSel1,
    mso_schema_site_anp_epg_selector.t2-epgSel2,
    mso_schema_template_external_epg.externalepg,
    mso_schema_template_contract.template2-contract1,
    mso_schema_template_anp_epg_contract.ap-alb-c1,
    mso_schema_template_anp_epg_contract.ap-alb-c2,
    mso_schema_template_external_epg_contract.extEPg-c1

  ]
  re_deploy = true
}

