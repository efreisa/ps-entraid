<#
    Script to change the UserPrincipalName of a set of users

    When changing a user's UserPrincipalName (UPN), there are several potential impacts on access to various services such as Teams, SharePoint, and B2B resources via guest accounts. Here are the key points to consider:

    ### Potential Access Loss

    1. **Microsoft Teams**:
    - **Guest Access**: If the user is a guest in other tenants, changing the UPN might disrupt their access. They may need to be re-invited to the teams they were part of [1](https://answers.microsoft.com/en-us/msteams/forum/all/guest-access-problems/ae3ca0ec-acac-415c-95cb-3d7948fc1220) [2](https://learn.microsoft.com/en-us/microsoftteams/guest-access).
    - **Conditional Access Policies**: If there are conditional access policies tied to the old UPN, these policies may need to be updated to reflect the new UPN [1](https://answers.microsoft.com/en-us/msteams/forum/all/guest-access-problems/ae3ca0ec-acac-415c-95cb-3d7948fc1220).

    2. **SharePoint**:
    - **External Sharing**: If the user had access to SharePoint sites as a guest, changing the UPN might require re-inviting the user to those sites [3](https://techcommunity.microsoft.com/discussions/sharepoint_general/external-user-struggling-to-access-sharepoint/3609409).
    - **Permissions**: Any permissions granted to the old UPN will need to be reassigned to the new UPN [2](https://learn.microsoft.com/en-us/microsoftteams/guest-access).

    3. **B2B Resources**:
    - **Guest Accounts**: For B2B collaboration, the guest accounts associated with the old UPN might lose access. The user may need to be re-invited to the external resources they had access to [2](https://learn.microsoft.com/en-us/microsoftteams/guest-access).

    ### Mitigation Steps

    1. **Inform Users in Advance**:
    - Notify users about the upcoming change and provide clear instructions on what they need to do to regain access.

    2. **Update Conditional Access Policies**:
    - Ensure that any conditional access policies are updated to reflect the new UPN.

    3. **Re-invite to Teams and SharePoint**:
    - Re-invite the user to any Teams and SharePoint sites they had access to as a guest.

    4. **Verify Access**:
    - After the change, verify that the user can access all necessary resources and services.

    Comments on End User Actions
        Inform Users in Advance:

        Notify users about the upcoming change and provide clear instructions on what they need to do.
        Example: "Dear users, we will be updating your UserPrincipalName. Please follow the instructions to reconnect your Outlook and other applications."
        Reconnect Outlook:

        Users will need to restart Outlook and reconnect their accounts.
        Example: "After the UPN change, please restart Outlook. If prompted, enter your new email address and password."
        Update OneDrive and Teams:

        Users may need to sign out and sign back into OneDrive and Teams.
        Example: "Please sign out and sign back into OneDrive and Teams using your new email address to ensure seamless access."
        Verify Email Forwarding and Rules:

        Ensure that email forwarding rules and filters are updated to reflect the new UPN.
        Example: "Check your email forwarding rules and filters to ensure they are updated with your new email address."
        Test Email Functionality:

        Send test emails to verify that the new UPN is working correctly and that the old UPN is properly set as an alias.
        Example: "Send a test email to yourself and a colleague to confirm that your new email address is working and that emails sent to your old address are being received."
        Monitor for Issues:

        Monitor for any issues or errors and provide support as needed.
        Example: "If you encounter any issues, please contact the IT support team for assistance."

#>

# Function to change Entra ID user UserPrincipalName and set initial email as alias
#
# Require   : Microsoft Graph Connected with scope "User.ReadWrite.All"
# Input     : User UPN, New UPN
# Output    : 
function Update-UserPrincipalName {
    param (
        [string]$UserUPN,
        [string]$NewUPN
    )

    # Get the current UPN of the user
    $user = Get-MgUser -UserId $UserUPN

    # Check if the current UPN is already the new UPN
    if ($user.UserPrincipalName -eq $NewUPN) {
        #Write-Output "The user's UPN is already set to the new UPN: $NewUPN"
    } else {
        # Change the UserPrincipalName
        Update-MgUser -UserId $UserUPN -UserPrincipalName $NewUPN

        # Optionally, add the old UPN as an alias
        Update-MgUser -UserId $NewUPN -OtherMails @($UserUPN)

        # Verify the change
        $updatedUser = Get-MgUser -UserId $NewUPN
        Write-Output "UserPrincipalName: $($updatedUser.UserPrincipalName)"
        Write-Output "OtherMails: $($updatedUser.OtherMails)"
    }
}

<# Main #>

# Install the Microsoft.Graph module if not already installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

# Import the Microsoft.Graph module
Import-Module Microsoft.Graph

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Example usage
$UserId = "user@domain.com"
$NewUPN = "newuser@domain.com"
Update-UserPrincipalName -UserId $UserId -NewUPN $NewUPN

# Disconnect from Microsoft Graph
Disconnect-MgGraph