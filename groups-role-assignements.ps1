<#
    Script to ensure role assignment
#>

# Function to ensure role assignment is set
# Require   : Microsoft Graph Connected with scope "RoleManagement.ReadWrite.Directory"
# Input     : Group name, Role name, Scope
# Output    : 
function Ensure-EligibleRoleAssignment {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupDisplayName,

        [Parameter(Mandatory = $true)]
        [string]$RoleDefinitionName,

        [Parameter(Mandatory = $true)]
        [string]$ScopeId  # Use '/' for tenant-wide or administrative unit ID
    )

    # Get the group object
    $group = Get-MgGroup -Filter "displayName eq '$GroupDisplayName'"
    if (-not $group) {
        Write-Error "Group not found: $GroupDisplayName"
        return
    }

    # Get the role definition
    $roleDef = Get-MgRoleManagementDirectoryRoleDefinition -Filter "displayName eq '$RoleDefinitionName'"
    if (-not $roleDef) {
        Write-Error "Role definition not found: $RoleDefinitionName"
        return
    }

    # Check for existing eligibility assignment
    $existing = Get-MgRoleManagementDirectoryRoleEligibilityScheduleInstance `
        -Filter "principalId eq '$($group.Id)' and roleDefinitionId eq '$($roleDef.Id)' and scopeId eq '$ScopeId'"

    if ($existing) {
        Write-Output "Eligible role assignment already exists for group '$GroupDisplayName'."
    } else {
        # Create a new eligible assignment request
        $schedule = @{
            Type = "Once"
            StartDateTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
            EndDateTime = (Get-Date).AddYears(100).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        }

        $params = @{
            PrincipalId = $group.Id
            RoleDefinitionId = $roleDef.Id
            DirectoryScopeId = $ScopeId
            AssignmentState = "Eligible"
            Type = "AdminAdd"
            ScheduleInfo = $schedule
            Justification = "Automated group-based eligible role assignment"
        }

        New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $params
        Write-Output "Created new eligible role assignment for group '$GroupDisplayName'."
    }
}

<# Main #>

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "RoleManagement.ReadWrite.Directory", "Group.Read.All"

# Example usage
Ensure-EligibleRoleAssignment -GroupDisplayName "GRP-Assigment-Contributor" -RoleDefinitionName "Contributor" -AdministrativeUnitId "administrative-unit-id"
