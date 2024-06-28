
function New-XWSession
{
    <#
    .SYNOPSIS
    Creates a session object used to communicate with an XWiki instance.

    .DESCRIPTION
    The `New-BMSession` function creates and returns a session object that is required by any function in the
    XWikiAutomation module that communicates with XWiki. The session includes XWiki's URL and the
    credentials to use when making requests to XWiki's APIs.

    .EXAMPLE
    $session = New-XWSession -Url 'https://xwiki.com' -Credential $credential

    Demonstrates how to call `New-XWSession`. In this case, the returned session object can be passed to other
    BuildMasterAutomation module functions to communicate with XWiki at `https://xwiki.com` with the
    credential in `$credential`.
    #>
    [CmdletBinding()]
    param(
        # The URL to the XWiki instance to use.
        [Parameter(Mandatory)]
        [Uri] $Url,

        # The API key to use when making requests to XWiki
        [Parameter(Mandatory)]
        [pscredential] $Credential
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    if (-not $Url.AbsolutePath.EndsWith('/'))
    {
        $Url = [uri]::new($Url, '/')
    }

    return [pscustomobject]@{
        Url = $Url;
        Credential = $Credential;
    }
}