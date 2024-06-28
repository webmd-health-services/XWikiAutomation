function New-TestXWSession
{
    [CmdletBinding()]
    param()

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    $InformationPreference = 'Continue'

    $credentialsPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\credentials.json' -Resolve
    Write-Information "Reading credentials from $credentialsPath."
    $credentials = Get-Content -Path $credentialsPath -Raw | ConvertFrom-Json
    $url = 'https://www.xwikiplayground.org/xwiki/'
    if ($credentials.PSObject.Properties.name -match 'url')
    {
        $url = $credentials.url

        if (-not $url.EndsWith('/'))
        {
            $url = "${url}/"
        }
    }

    try
    {
        $result = Invoke-WebRequest "${url}bin/register/XWiki/XWikiRegister"
        if (-not ($result.Content -match 'name="form_token" value="(?<formToken>.*)"'))
        {
            Write-Error 'Could not find form_token in the response.'
            return
        }

        $formData = @{
            parent = 'xwiki:Main.UserDirectory'
            register_first_name = ''
            register_last_name = ''
            xwikiname = $credentials.username
            register_password = $credentials.password
            register2_password = $credentials.password
            register_email = ''
            xredirect = ''
            form_token = $Matches.formToken
        }

        Invoke-WebRequest -Uri "${url}bin/register/XWiki/XWikiRegister" `
                        -Method Post `
                        -Body $formData `
                        -ContentType 'application/x-www-form-urlencoded' | Out-Null
    }
    finally
    {
        $password = $credentials.password | ConvertTo-SecureString -AsPlainText -Force
        $cred = [pscredential]::new($credentials.username, $password)
        New-XWSession -Url $url -Credential $cred | Write-Output
    }
}

function GivenPage
{
    [CmdletBinding()]
    param(
        [String[]] $Name,
        [String] $Title,
        [String] $Content = 'This is a test page.',
        [String[]] $SpacePath = $xwTestSpace
    )

    $Name | ForEach-Object {
        if (-not $Title)
        {
            $Title = $_
        }
        Set-XWPage -Session $xwTestSession -SpacePath $SpacePath -Name $_ -Title $Title -Content $Content
    }
}

function RemovePage
{
    [CmdletBinding()]
    param(
        [String[]] $Name,
        [String[]] $SpacePath = $xwTestSpace
    )

    $Name | ForEach-Object { Remove-XWPage -Session $xwTestSession -SpacePath $SpacePath -Name $_ }
}

if ($PSVersionTable.PSVersion.Major -lt 7)
{
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

$xwTestSession = New-TestXWSession
$xwTestPage = 'WHSDevOpsTesting'
$xwTestSpace = 'Sandbox', $xwTestPage

Set-XWPage -Session $xwTestSession -SpacePath 'Sandbox' -Name 'WHSDevOpsTesting' -Hidden $true -Content 'This is a test page.'

Export-ModuleMember -Variable '*' -Function '*'