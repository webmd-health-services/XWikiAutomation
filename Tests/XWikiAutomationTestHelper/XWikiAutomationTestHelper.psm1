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
    $password = $credentials.password | ConvertTo-SecureString -AsPlainText -Force
    $cred = [pscredential]::new($credentials.username, $password)
    return New-XWSession -Url $url -Credential $cred

    $result = Invoke-WebRequest 'https://www.xwikiplayground.org/xwiki/bin/register/XWiki/XWikiRegister'
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

    Invoke-WebRequest -Uri 'https://www.xwikiplayground.org/xwiki/bin/register/XWiki/XWikiRegister' `
                      -Method Post `
                      -Body $formData `
                      -ContentType 'application/x-www-form-urlencoded' | Out-Null
}

$xwTestSession = New-TestXWSession

Export-ModuleMember -Variable 'xwTestSession' -Function '*'