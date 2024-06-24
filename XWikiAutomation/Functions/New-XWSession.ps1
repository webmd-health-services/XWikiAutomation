
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
    [CmdletBinding(DefaultParameterSetName='ByCredential')]
    param(
        # The URL to the XWiki instance to use.
        [Parameter(Mandatory)]
        [Uri] $Url,

        # The API key to use when making requests to XWiki
        [Parameter(Mandatory, ParameterSetName='ByCredential')]
        [pscredential] $Credential,

        [Parameter(Mandatory, ParameterSetName='ByUsername')]
        [String] $Username,

        [Parameter(Mandatory, ParameterSetName='ByUsername')]
        [securestring] $Password
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    if ($PSCmdlet.ParameterSetName -eq 'ByUsername')
    {
        $Credential = [pscredential]::new($Username, $Password)
    }

    return [pscustomobject]@{
        Url = $Url;
        Credential = $Credential;
    }
}