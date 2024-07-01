Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    function GivenSpacePath
    {
        param(
            [String[]] $SpacePath
        )
        $script:spacePath = $SpacePath
    }

    function GivenWikiName
    {
        param(
            [String] $WikiName
        )
        $script:wikiName = $WikiName
    }

    function GivenPageName
    {
        param(
            [String] $Name
        )
        $script:pageName = $Name
    }

    function WhenInvokingRestMethod
    {
        $splat = @{}
        if ($script:spacePath)
        {
            $splat['SpacePath'] = $script:spacePath
        }
        if ($script:wikiName)
        {
            $splat['WikiName'] = $script:wikiName
        }
        if ($script:pageName)
        {
            $splat['Name'] = $script:pageName
        }

        $script:result = Get-XWPage -Session $script:session @splat
    }

    function ThenHasPages
    {
        param(
            [String] $Count
        )

        $script:result | Should -HaveCount $Count
    }
}

Describe 'Get-XWPage' {
    BeforeEach {
        $script:session = $xwTestSession
        $script:spacePath = $null
        $script:wikiName = $null
        $script:pageName = $null
        $script:result = $null
    }

    It 'should handle getting data by space path' {
        GivenPage -Name 'Get-XWPageTest', 'Get-XWPageTest2'
        GivenSpacePath -SpacePath $xwTestSpace
        WhenInvokingRestMethod
        ThenHasPages -Count 2
    }

    It 'should handle singular space paths' {
        GivenSpacePath -SpacePath 'Sandbox'
        GivenPageName -Name $xwTestPage
        WhenInvokingRestMethod
        ThenHasPages -Count 1
    }
}