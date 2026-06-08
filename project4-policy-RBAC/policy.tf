#This file contains the policy definitions and assignments for the project. 
#It defines two custom policies: one that requires mandatory tags on resources, 
#and another that restricts resource deployment to specific Azure regions. 
#These policies are then grouped into a policy set definition and 
#assigned to a resource group.

##Policy definition to require mandatory tags on resources

resource "azurerm_policy_definition" "require_tags" {

  name        = "require-mandatory-tags"
  policy_type = "Custom"
  mode        = "Indexed"

  display_name = "Require Mandatory Tags"

  metadata = jsonencode({
    category = "Governance"
    version  = "1.0"
  })
  #Blocks resource creation if the required tags Environment or Owner are missing.

  policy_rule = jsonencode({

    if = {
      anyOf = [
        {
          field  = "tags['Environment']"
          exists = "false"
        },
        {
          field  = "tags['Owner']"
          exists = "false"
        }
      ]
    }

    then = {
      effect = "deny"
    }
  })
}

#Policy definition to restrict resource deployment to specific Azure regions

resource "azurerm_policy_definition" "allowed_locations" {

  name        = "allowed-locations"
  policy_type = "Custom"
  mode        = "Indexed"

  display_name = "Allowed Azure Regions"

  metadata = jsonencode({
    category = "Governance"
    version  = "1.0"
  })

  #blocks resource creation if the location is not in the allowed list of regions (eastus and centralindia in this case).

  policy_rule = jsonencode({

    if = {
      field = "location"

      notIn = [
        "eastus",
        "centralindia"
      ]
    }

    then = {
      effect = "deny"
    }
  })
}

#Policy initiative definition to group the above policies together

resource "azurerm_policy_set_definition" "governance" {

  name        = "governance-initiative" #must be globally unique 
  policy_type = "Custom"

  display_name = "Enterprise Governance Initiative" #friendly name for the initiative

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_tags.id
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_locations.id
  }
}

#policy assignment to apply the initiative to the resource group

resource "azurerm_resource_group_policy_assignment" "governance" {
  name                 = "governance-assignment"
  resource_group_id    = azurerm_resource_group.main.id
  policy_definition_id = azurerm_policy_set_definition.governance.id

  display_name = "Governance Initiative Assignment"
  description  = "Enforces mandatory tags and restricts resource deployment to specific regions."
}



