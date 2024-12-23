
function Get-XWWiki
{
    <#
    .SYNOPSIS
    Lists the wikis on an XWiki instance.

    .DESCRIPTION
    The `Get-XWikis` function gets all of the parent wikis within an XWiki instance. On most XWikis, this should just
    return an XWiki named `xwiki`.

    .EXAMPLE
    Get-XWWikis -Session $Session

    Demonstrates listing all of the wikis on an XWiki instance.
    #>
    [CmdletBinding()]
    param(
        # The Session object for an XWiki session. Create a new Session using `New-XWSession`.
        [Parameter(Mandatory)]
        [pscustomobject] $Session
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    Invoke-XWRestMethod -Session $Session -Name 'wikis' -AsJson |
        Select-Object -ExpandProperty 'wikis' |
        Write-Output
}