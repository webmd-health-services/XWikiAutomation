
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'New-XWSession' {
    It 'should return a session object' {
        $url = 'https://fubar.snafu'
        $username = 'xwikiautomation'
        $password = 'fubarsnafu' | ConvertTo-SecureString -AsPlainText -Force
        $cred = [pscredential]::new($username, $password)
        $session = New-XWSession -Url $url -Credential $cred
        $session | Should -Not -BeNullOrEmpty
        $session.Url | Should -Be ([uri]$url)
        $session.Credential.password | Should -Be $password
        $session.Credential.username | Should -Be $username
    }

    it 'should support creation using username and password' {
        $url = 'https://fubar.snafu'
        $username = 'xwikiautomation'
        $password = 'fubarsnafu' | ConvertTo-SecureString -AsPlainText -Force
        $session = New-XWSession -Url $url -Username $username -Password $password
        $session | Should -Not -BeNullOrEmpty
        $session.Url | Should -Be ([uri]$url)
        $session.Credential.password | Should -Be $password
        $session.Credential.username | Should -Be $username
    }
}