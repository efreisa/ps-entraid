# ps-entraid

A curated collection of PowerShell scripts for managing and automating tasks in Microsoft Entra ID (formerly Azure Active Directory).

## Table of Contents

- #overview
- #features
- #prerequisites
- #installation
- #usage
- #script-index
- #contributing
- #license
- #author

## Overview

`ps-entraid` provides a set of PowerShell scripts designed to simplify and automate common administrative tasks in Microsoft Entra ID. These scripts are intended for IT administrators, DevOps engineers, and technical operations teams who manage identity and access in Microsoft cloud environments.

## Features

- Automate user and group management
- Query and export directory data
- Manage application registrations and service principals
- Support for secure authentication using MSAL or Azure CLI
- Modular and reusable script components

## Prerequisites

- PowerShell 7.x or later
- Microsoft Graph PowerShell SDK or AzureAD module
- Appropriate permissions to access Microsoft Entra ID resources
- Internet connectivity

## Installation

Clone the repository:

```bash
git clone https://github.com/efreisa/ps-entraid.git
cd ps-entraid
```

Install required modules (if not already installed):

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

## Usage

Each script is self-contained and includes usage instructions in the header comments. To run a script:

```powershell
.\Get-EntraUsers.ps1 -Filter "accountEnabled eq true"
```

Refer to the inline documentation for parameter details and examples.

## Script Index

| Script Name              | Description                                 |
|--------------------------|---------------------------------------------|
| `Get-EntraUsers.ps1`     | Retrieves a list of active Entra ID users   |
| `New-EntraGroup.ps1`     | Creates a new security group                |
| `Set-EntraUserLicense.ps1` | Assigns licenses to users                  |
| _...more coming soon..._ |                                             |

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request with your proposed changes. For major changes, open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Author

Eric FREISA  
https://github.com/efreisa