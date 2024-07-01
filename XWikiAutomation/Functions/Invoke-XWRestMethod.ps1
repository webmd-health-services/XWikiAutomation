
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

        # The body of the request. This is used for POST and PUT requests.
        [Parameter(Mandatory, ParameterSetName='Body')]
        [Object] $Body,

        # The content type of the body. Defaults to `application/xml`.
        [Parameter(ParameterSetName='Body')]
        [String] $ContentType = 'application/xml',

        # The form data to send with the request. This is used for POST and PUT requests.
        [Parameter(ParameterSetName='Form')]
        [hashtable] $Form
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $url = [uri]::EscapeUriString("$($Session.Url)rest/${name}")
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

    if ($Form)
    {
        $requestParams['Body'] = $Form
        $requestParams['ContentType'] = 'application/x-www-form-urlencoded'
    }

    Write-Debug "${method} - ${url}"
    foreach ($key in $requestParams.Keys)
    {
        if ($key -ne 'Form')
        {
            Write-Debug "${key}: $($requestParams[$key])"
        }
        else
        {
            foreach ($formKey in $requestParams[$key].Keys)
            {
                Write-Debug "    ${formKey}: $($requestParams[$key][$formKey])"
            }
        }
    }

    $auth = "$($Session.Credential.UserName):$($Session.Credential.GetNetworkCredential().Password)"
    $bytes = [Text.Encoding]::ASCII.GetBytes($auth)
    $base64AuthInfo = [Convert]::ToBase64String($bytes)

    $headers = @{
        Authorization="Basic $base64AuthInfo"
    }

    if ($Session.Url.ToString().Contains('xwikiplayground'))
    {
        $requestParams['SkipCertificateCheck'] = $true
    }

    try
    {
        if ($Method -eq [Microsoft.PowerShell.Commands.WebRequestMethod]::Get -or $PSCmdlet.ShouldProcess($url, $method))
        {
            Invoke-RestMethod -Headers $headers -Method $Method -Uri $url @requestParams -UseBasicParsing |
                ForEach-Object { $_ } |
                Where-Object { $_ } |
                Write-Output
        }
    }
    catch
    {
        $Global:Error.RemoveAt(0)
    }
}