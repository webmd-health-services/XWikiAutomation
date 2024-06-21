# Overview

The "XWikiAutomation" module is a PowerShell module for automating
[XWiki](https://www.xwiki.org/xwiki/bin/view/Main/WebHome), an open-source and self-hosted tool for storing wikis of information.

# System Requirements

* Windows PowerShell 5.1 and .NET 4.6.1+
* PowerShell Core 6+
* XWiki 15.10.10 (most functions should work on older/newer versions)

# Installing

To install globally:

```powershell
Install-Module -Name 'XWikiAutomation'
Import-Module -Name 'XWikiAutomation'
```

To install privately:

```powershell
Save-Module -Name 'XWikiAutomation' -Path '.'
Import-Module -Name '.\XWikiAutomation'
```

# Commands

## Create a New XWiki Session

* New-XWSession

## Functions That Call XWiki APIs

* Get-XWPage
* Invoke-XWRestMethod
