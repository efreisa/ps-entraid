<#
    Script to Ensure assignment license groups exists
#>

# Function to ensure Entra ID group exist
# Require   : Microsoft Graph Connected with scope "Group.ReadWrite.All"
# Input     : Group name
# Output    : Group ID
function Ensure-EntraIDGroupExists {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupName
    )

    # Connect to Microsoft Graph
    # Connect-MgGraph -Scopes "Group.ReadWrite.All"

    # Check if group exists
    $existingGroup = Get-MgGroup -Filter "displayName eq '$GroupName'" -ConsistencyLevel eventual

    if ($existingGroup) {
        #Write-Output "Group '$GroupName' already exists. ID: $($existingGroup.Id)"
        return $existingGroup.Id
    } else {
        # Create the group
        $newGroup = New-MgGroup -DisplayName $GroupName `
                                -MailEnabled:$false `
                                -SecurityEnabled:$true `
                                -GroupTypes @()

        #Write-Output "Group '$GroupName' created. ID: $($newGroup.Id)"
        return $newGroup.Id
    }
}

# Function to ensure license is assigned to an Entra ID Group
# Require   : Microsoft Graph Connected with scope "Group.ReadWrite.All", "Directory.ReadWrite.All"
# Input     : Group ID, Sku name
# Output    :
function Ensure-LicenseAssignedToGroupBySkuName {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupId,

        [Parameter(Mandatory = $true)]
        [string]$SkuName
    )

    # Connect to Microsoft Graph
    #Connect-MgGraph -Scopes "Group.ReadWrite.All", "Directory.ReadWrite.All"

    # Get all available SKUs
    $skus = Get-MgSubscribedSku

    # Find the SKU ID by name
    $sku = $skus | Where-Object { $_.SkuPartNumber -eq $SkuName }

    if (-not $sku) {
        Write-Error "SKU name '$SkuName' not found. Please check the available SKUs using Get-MgSubscribedSku."
        return
    }

    $skuId = $sku.SkuId

    # Check if the license is already assigned
    $group = Get-MgGroup -GroupId $GroupId -Property AssignedLicenses

    $alreadyAssigned = $group.AssignedLicenses | Where-Object { $_.SkuId -eq $skuId }

    if ($alreadyAssigned) {
        #Write-Output "License '$SkuName' already assigned to group $GroupId."
    } else {
        $params = @{
            AddLicenses = @(@{ SkuId = $skuId })
            RemoveLicenses = @()
        }

        Set-MgGroupLicense -GroupId $GroupId -BodyParameter $params
        #Write-Output "License '$SkuName' assigned to group $GroupId."
    }
}

<#
    Main part of the script
#>

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.ReadWrite.All", "Directory.ReadWrite.All"

# Groups to create
$GroupLicenseMap = @(
    @{
        GroupName = "GP_M365_E3_Users"
        SkuNames  = @("ENTERPRISEPACK", "Microsoft_Teams_Enterprise_New")  # Microsoft 365 E3
    },
    @{
        GroupName = "GP_M365_Business_Premium"
        SkuNames  = @("M365_BUSINESS_PREMIUM")
    },
    @{
        GroupName = "GP_M365_E5_Users"
        SkuNames  = @("Microsoft_365_E5_(no_Teams)", "Microsoft_Teams_Enterprise_New")
    }
)

# Loop groups creation and licenses assigne
foreach ($entry in $GroupLicenseMap) {
    $group = Get-MgGroup -Filter "displayName eq '$($entry.GroupName)'" -ConsistencyLevel eventual

    if ($group) {
        foreach ($skuName in $entry.SkuNames) {
            Ensure-LicenseAssignedToGroupBySkuName -GroupId $group.Id -SkuName $skuName
        }
    } else {
        Write-Warning "Group '$($entry.GroupName)' not found."
    }
}

