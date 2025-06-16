<#
    Script to ensure Administrative Units
#>

# Function to ensure an Administrative Unit
# Require   : Microsoft Graph Connected with scope "AdministrativeUnit.ReadWrite.All"
# Input     : Group name
# Output    : Group
function Ensure-AdministrativeUnit {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DisplayName,

        [Parameter(Mandatory = $false)]
        [string]$Description = ""
    )

    # Check if the AU exists
    $existingAU = Get-MgDirectoryAdministrativeUnit -Filter "displayName eq '$DisplayName'"

    if ($existingAU) {
        $needsUpdate = $false
        $updateParams = @{}

        if ($existingAU.Description -ne $Description) {
            $updateParams["Description"] = $Description
            $needsUpdate = $true
        }

        if ($needsUpdate) {
            Update-MgDirectoryAdministrativeUnit -AdministrativeUnitId $existingAU.Id -BodyParameter $updateParams
            Write-Output "Updated Administrative Unit: $DisplayName"
        } else {
            Write-Output "Administrative Unit '$DisplayName' already exists and is up to date."
        }
    } else {
        # Create the AU
        $newAU = @{
            DisplayName = $DisplayName
            Description = $Description
        }
        New-MgDirectoryAdministrativeUnit -BodyParameter $newAU
        Write-Output "Created Administrative Unit: $DisplayName"
    }
}

<# Main #>

# Connect to Microsoft Graph if not already connected
if (-not (Get-MgContext)) {
    Connect-MgGraph -Scopes "AdministrativeUnit.ReadWrite.All"
}

# Define template AUs
$adminUnits = @(
    @{ DisplayName = "Sales AU"; Description = "Administrative Unit for Sales team" },
    @{ DisplayName = "IT AU"; Description = "Administrative Unit for IT operations" },
    @{ DisplayName = "HR AU"; Description = "Administrative Unit for Human Resources" }
)

# Loop through and ensure each AU exists
foreach ($au in $adminUnits) {
    Ensure-AdministrativeUnit -DisplayName $au.DisplayName -Description $au.Description
}
