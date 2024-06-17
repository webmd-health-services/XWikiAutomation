function New-TestXWSession
{
    $url = 'http://localhost:8080'
    $username = 'xwikiautomation'
    $password = 'password' | ConvertTo-SecureString -AsPlainText -Force
    $cred = [pscredential]::new($username, $password)
    return New-XWSession -Url $url -Credential $cred
}

Export-ModuleMember -Function '*'