
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    function GivenPage
    {
        [CmdletBinding()]
        param(
            [String] $Name,
            [String] $Title = $Name,
            [String] $Content = 'This is a test page.',
            [String[]] $SpacePath = $xwTestSpace
        )

        Set-XWPage -Session $xwTestSession -SpacePath $SpacePath -Name $Name -Title $Title -Content $Content
    }

    function ThenPageDeleted
    {
        param(
            [String] $Name
        )
        Get-XWPage -Session $xwTestSession -SpacePath $xwTestSpace -Name $Name | Should -BeNullOrEmpty
    }

    function ThenPageNotDeleted
    {
        param(
            [String] $Name,
            [String[]] $SpacePath = $xwTestSpace
        )
        Get-XWPage -Session $xwTestSession -SpacePath $SpacePath -Name $Name | Should -Not -BeNullOrEmpty
    }

    function WhenRemovingPage
    {
        param(
            [String] $Name
        )
        Remove-XWPage -Session $xwTestSession -SpacePath $xwTestSpace -Name $Name
    }
}

Describe 'Remove-XWPage' {
    It 'should delete the provided page' {
        GivenPage -Name 'Remove-XWPageTest'
        WhenRemovingPage -Name 'Remove-XWPageTest'
        ThenPageDeleted -Name 'Remove-XWPageTest'
    }

    It 'should not throw an error if the page does not exist' {
        GivenPage -Name 'Remove-XWPageTest'
        WhenRemovingPage -Name 'Remove-XWPageTest'
        WhenRemovingPage -Name 'Remove-XWPageTest'
    }

    It 'should not delete child pages' {
        GivenPage -Name 'Remove-XWPageTest'
        GivenPage -Name 'Remove-XWSubPage' -SpacePath ($xwTestSpace + 'Remove-XWPageTest')
        WhenRemovingPage -Name 'Remove-XWPageTest'
        ThenPageDeleted -Name 'Remove-XWPageTest'
        ThenPageNotDeleted -Name 'Remove-XWSubPage' -SpacePath ($xwTestSpace + 'Remove-XWPageTest')
    }
}