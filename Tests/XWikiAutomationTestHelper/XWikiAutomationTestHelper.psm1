
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
    $url = 'https://www.xwikiplayground.org/'
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
        $result = Invoke-WebRequest -Uri "${url}xwiki/bin/register/XWiki/XWikiRegister" -UseBasicParsing
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

        Invoke-WebRequest -Uri "${url}xwiki/bin/register/XWiki/XWikiRegister" `
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
$xwTestGeneratedPages = [System.Collections.ArrayList]::new()

function GenerateRandomString
{
    [CmdletBinding()]
    param(
        [String] $Prefix,
        [int] $Length = 4
    )

    Set-StrictMode -Version 'Latest'
    $alphabet = 'abcdefghijklmnopqrstuvwxyz'.ToCharArray()
    $random = $alphabet | Get-Random -Count $Length
    return $Prefix + ($random -join '')
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

    Set-StrictMode -Version 'Latest'
    $Name | ForEach-Object {
        [void] $xwTestGeneratedPages.Add([pscustomobject]@{
            Name = $_
            SpacePath = $SpacePath
        })
        if (-not $Title)
        {
            $Title = $_
        }
        $VerbosePreference = 'Continue'
        Write-Verbose "Creating page $_ in space $($SpacePath -join '/')."
        $VerbosePreference = 'SilentlyContinue'
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

function InitTests
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String] $TestName
    )
    Set-StrictMode -Version 'Latest'
    $xwTestGeneratedPages.Clear()
    $TestName = GenerateRandomString -Prefix $TestName
    GivenPage -Name $TestName -SpacePath $xwTestSpace | Out-Null
    $testSpace = $xwTestSpace + $TestName
    return $testSpace
}

function CleanTests
{
    foreach($page in $xwTestGeneratedPages)
    {
        $VerbosePreference = 'Continue'
        Write-Verbose "Removing page $($page.Name) from space $($page.SpacePath)."
        $VerbosePreference = 'SilentlyContinue'
        RemovePage -Name $page.Name -SpacePath $page.SpacePath
    }
}

Set-XWPage -Session $xwTestSession `
           -SpacePath 'Sandbox' `
           -Name 'WHSDevOpsTesting' `
           -Hidden $true `
           -Content 'This is a test page.'

Export-ModuleMember -Variable '*' -Function '*'