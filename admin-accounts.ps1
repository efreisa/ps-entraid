<#
    Script to ensure admin accounts exists and are set with the right settings
#>

# Set a password with 16 char
function New-RandomPassword {
    param (
        [int]$Length = 16
    )

    Add-Type -AssemblyName System.Web
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%&*()-_=+[]{};:,.<>?'
    $password = -join ((1..$Length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    return $password
}

# Function to ensure Admin account is sets
function Ensure-AdminAccount {
    param (
        [Parameter(Mandatory)] [string]$UserPrincipalName,
        [Parameter(Mandatory)] [string]$DisplayName,
        [Parameter(Mandatory)] [string]$GivenName,
        [Parameter(Mandatory)] [string]$Surname,
        [Parameter(Mandatory)] [string]$CompanyName,
        [Parameter(Mandatory)] [string]$Email,
        [Parameter()] [bool]$Enabled = $true,
        [Parameter()] [string[]]$Groups = @()
    )

    # Check if user exists
    $user = Get-MgUser -Filter "userPrincipalName eq '$UserPrincipalName'" -ErrorAction SilentlyContinue

    if (-not $user) {
        Write-Host "Creating user: $DisplayName"
        $passwordProfile = @{
            ForceChangePasswordNextSignIn = $true
            Password = New-RandomPassword
        }

        $user = New-MgUser -AccountEnabled $Enabled `
                           -DisplayName $DisplayName `
                           -MailNickname ($UserPrincipalName.Split("@")[0]) `
                           -UserPrincipalName $UserPrincipalName `
                           -GivenName $GivenName `
                           -Surname $Surname `
                           -CompanyName $CompanyName `
                           -OtherMails @($Email) `
                           -PasswordProfile $passwordProfile
    } else {
        Write-Host "User exists. Updating properties for: $DisplayName"
        Update-MgUser -UserId $user.Id `
                      -DisplayName $DisplayName `
                      -GivenName $GivenName `
                      -Surname $Surname `
                      -CompanyName $CompanyName
    }

    # Ensure group membership
    foreach ($groupName in $Groups) {
        $group = Get-MgGroup -Filter "displayName eq '$groupName'" -ErrorAction SilentlyContinue
        if ($group) {
            $members = Get-MgGroupMember -GroupId $group.Id -All
            $isMember = $members | Where-Object { $_.Id -eq $user.Id }
            if (-not $isMember) {
                New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id
                Write-Host "Added $DisplayName to group $groupName"
            }
        }
    }
}
