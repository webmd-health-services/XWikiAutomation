
function Invoke-XWRestMethod
{
    <#
    .SYNOPSIS
    Invokes an XWiki Rest endpoint.

    .DESCRIPTION
    The `Invoke-XWRestMethod` invokes a XWiki REST API method. You pass the path to the endpoint (everything after
    `/xwiki/rest`) via the `Name` parameter, the HTTP method to use via the `Method` parameter, and the parameters to
    pass in the body of the request via the `Parameter` parameter. XWiki allows for returning REST API requests in both
    JSON and XML formats. The default return format is XML, to change this to JSON use the `AsJson` switch.

    When trying to update or create data on the XWiki server, it is recommended to use PUT requests rather than POST
    requests. This is due to the way XWiki handles requests.

    When using the `WhatIf` parameter, only web requests that use the `Get` HTTP method are made.

    .EXAMPLE
    Invoke-XWRestMethod -Session $session -Name 'wikis'

    Demonstrates using the `xwiki/rest/wikis` endpoint with a GET request to find a list of all of the wikis available.
    .LINK
    https://www.xwiki.org/xwiki/bin/view/Documentation/UserGuide/Features/XWikiRESTfulAPI
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName='NoBody')]
    param(
        # The Session object for an XWiki session. Create a new Session using `New-XWSession`.
        [Parameter(Mandatory)]
        [pscustomobject] $Session,

        # The name of the API endpoint to make a request to. This should be everything after the `/xwiki/rest/` in the URL.
        [Parameter(Mandatory)]
        [String] $Name,

        # The REST method to use when making a request. Defaults to GET.
        [Microsoft.PowerShell.Commands.WebRequestMethod] $Method =
            [Microsoft.PowerShell.Commands.WebRequestMethod]::Get,

        # Sets the content to be returned as JSON rather than returned as XML.
        [switch] $AsJson,

        [Parameter(Mandatory, ParameterSetName='Body')]
        [Object] $Body,

        [Parameter(ParameterSetName='Body')]
        [String] $ContentType = 'application/xml',

        [switch] $PassThru
    )

    $url = [uri]::EscapeDataString("$($Session.Url)rest/${name}")

    if ($AsJson)
    {
        $url = "${url}?media=json"
    }

    $requestParams = @{}

    if ($Body)
    {
        $requestParams['Body'] = $Body
        $requestParams['ContentType'] = $ContentType
    }

    try
    {
        if ($Method -eq [Microsoft.PowerShell.Commands.WebRequestMethod]::Get -or $PSCmdlet.ShouldProcess($url, $method))
        {
            Invoke-RestMethod -Method $Method -Uri $url @requestParams |
                ForEach-Object { $_ } |
                Where-Object { $_ }
        }
    }
    catch
    {
        $Global:Error.RemoveAt(0)
        Write-Error -ErrorRecord $_ -ErrorAction $ErrorActionPreference
    }
}