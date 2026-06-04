output "portfolio_url" {
  value = azurerm_storage_account.site.primary_web_endpoint
}

output "site_url" {
  value = "https://${azurerm_cdn_frontdoor_endpoint.main.host_name}"
}
