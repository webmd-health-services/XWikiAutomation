
Set-StrictMode -Version 'Latest'
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
        $result = Invoke-WebRequest -Uri "${url}bin/register/XWiki/XWikiRegister" -UseBasicParsing
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
                          -UseBasicParsing `
                          -Method Post `
                          -Body $formData `
                          -ContentType 'application/x-www-form-urlencoded' | Out-Null
    }
    catch
    {
        Write-Error $_.Exception.Message
        return
    }
    finally
    {
        $password = $credentials.password | ConvertTo-SecureString -AsPlainText -Force
        $cred = [pscredential]::new($credentials.username, $password)
        New-XWSession -Url $url -Credential $cred | Write-Output
    }
}

$xwTestSession = New-TestXWSession
$xwTestPage = 'WHSDevOpsTesting'
$xwTestSpace = 'Sandbox', $xwTestPage

function GivenPage
{
    [CmdletBinding()]
    param(
        [String[]] $Name,
        [String] $Title,
        [String] $Content = 'This is a test page.',
        [String[]] $SpacePath = $xwTestSpace
    )

    Set-StrictMode -Version 'Latest'
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

    Set-StrictMode -Version 'Latest'
    $Name | ForEach-Object { Remove-XWPage -Session $xwTestSession -SpacePath $SpacePath -Name $_ }
}

Set-XWPage -Session $xwTestSession -SpacePath 'Sandbox' -Name 'WHSDevOpsTesting' -Hidden $true -Content 'This is a test page.'

Export-ModuleMember -Variable '*' -Function '*'