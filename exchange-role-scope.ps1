function Ensure-ITStaffScopedRole {
    param (
        [string]$ScopeName = "ITStaffScope",
        [string]$RoleGroupName = "ITStaffRoleGroup",
        [string]$Role = "Mail Recipients"
    )

    $expectedFilter = "Department -eq 'IT Staff'"

    # Check if the management scope exists
    $scope = Get-ManagementScope -Identity $ScopeName -ErrorAction SilentlyContinue
    if ($scope) {
        if ($scope.RecipientFilter -ne $expectedFilter) {
            Write-Host "Updating existing scope '$ScopeName' with correct filter..."
            Set-ManagementScope -Identity $ScopeName -RecipientRestrictionFilter $expectedFilter
        } else {
            Write-Host "Scope '$ScopeName' already exists and is up to date."
        }
    } else {
        Write-Host "Creating new management scope '$ScopeName'..."
        New-ManagementScope -Name $ScopeName -RecipientRestrictionFilter $expectedFilter
    }

    # Check if the role group exists
    $roleGroup = Get-RoleGroup -Identity $RoleGroupName -ErrorAction SilentlyContinue
    if ($roleGroup) {
        $currentRoles = (Get-RoleGroup $RoleGroupName).Roles
        $currentScope = (Get-RoleGroup $RoleGroupName).CustomRecipientWriteScope
        if ($Role -notin $currentRoles -or $currentScope -ne $ScopeName) {
            Write-Host "Updating role group '$RoleGroupName'..."
            Remove-RoleGroup -Identity $RoleGroupName -Confirm:$false
            New-RoleGroup -Name $RoleGroupName -Roles $Role -CustomRecipientWriteScope $ScopeName
        } else {
            Write-Host "Role group '$RoleGroupName' already exists and is up to date."
        }
    } else {
        Write-Host "Creating new role group '$RoleGroupName'..."
        New-RoleGroup -Name $RoleGroupName -Roles $Role -CustomRecipientWriteScope $ScopeName
    }
}

# function that ensures a group is assigned to a role group, and only adds it if it’s not already a member
function Ensure-RoleGroupAssignment {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupName,  # The name of the mail-enabled security group

        [string]$RoleGroupName = "ITStaffRoleGroup"
    )

    # Check if the group exists
    $group = Get-DistributionGroup -Identity $GroupName -ErrorAction SilentlyContinue
    if (-not $group) {
        Write-Error "Group '$GroupName' not found. Please ensure it exists and is mail-enabled."
        return
    }

    # Check if the role group exists
    $roleGroup = Get-RoleGroup -Identity $RoleGroupName -ErrorAction SilentlyContinue
    if (-not $roleGroup) {
        Write-Error "Role group '$RoleGroupName' does not exist. Please create it first."
        return
    }

    # Check if the group is already a member of the role group
    $members = Get-RoleGroupMember -Identity $RoleGroupName
    $alreadyAssigned = $members | Where-Object { $_.Name -eq $GroupName }

    if ($alreadyAssigned) {
        Write-Host "Group '$GroupName' is already assigned to role group '$RoleGroupName'. No action needed."
    } else {
        Write-Host "Assigning group '$GroupName' to role group '$RoleGroupName'..."
        Add-RoleGroupMember -Identity $RoleGroupName -Member $GroupName
        Write-Host "Assignment completed."
    }
}

<# Main #>
#Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force
Connect-ExchangeOnline
# Enable-OrganizationCustomization - It takes some times


Ensure-ITStaffScopedRole
Ensure-RoleGroupAssignment -GroupName "IT Staff Admins"
