<#
    Script to ensure dynamic groups settings
#>

# Function to ensure dynamic group exists and update attributes if needed
# Require   : Microsoft Graph Connected with scope "Group.ReadWrite.All"
# Input     : Group name
# Output    : Group
function Ensure-DynamicGroup {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupName,
        
        [Parameter(Mandatory = $true)]
        [string]$Description,
        
        [Parameter(Mandatory = $true)]
        [string]$MembershipRule
    )

    # Check if the group exists
    $existingGroup = Get-MgGroup -Filter "displayName eq '$GroupName'"

    if ($existingGroup) {
        # Group exists, update attributes if needed
        $groupId = $existingGroup.Id
        $updateParams = @{
            Description = $Description
            MembershipRule = $MembershipRule
            MembershipRuleProcessingState = "On"
        }
        Update-MgGroup -GroupId $groupId -BodyParameter $updateParams
        Write-Output "Updated existing dynamic group: $GroupName."
    } else {
        # Group does not exist, create a new dynamic group
        $newGroupParams = @{
            DisplayName = $GroupName
            Description = $Description
            GroupTypes = @("DynamicMembership")
            MailEnabled = $false
            MailNickname = $GroupName.Replace(" ", "").ToLower()
            SecurityEnabled = $true
            MembershipRule = $MembershipRule
            MembershipRuleProcessingState = "On"
        }
        New-MgGroup -BodyParameter $newGroupParams
        Write-Output "Created new dynamic group: $GroupName."
    }
}

<# Main #>

# Install Microsoft Graph PowerShell module if not already installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Install-Module -Name Microsoft.Graph -Scope CurrentUser
}

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.ReadWrite.All"

# Example usage
$groupName = "Dynamic Group Example"
$description = "This is an example of a dynamic group."
$membershipRule = "(user.department -eq 'Sales')"

Ensure-DynamicGroup -GroupName $groupName -Description $description -MembershipRule $membershipRule
