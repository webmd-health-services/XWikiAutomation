Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    function GivenSpaceResponse
    {
        $pageResponse = { @"
{
    "pageSummaries": [
        {
            "links": [
                {
                    "href": "http://localhost:8080/rest/wikis/xwiki/spaces/Sandbox",
                    "rel": "http://www.xwiki.org/rel/space",
                    "type": null,
                    "hrefLang": null
                },
            ],
            "id": "xwiki:Sandbox.newpage",
            "fullName": "Sandbox.newpage",
            "wiki": "xwiki",
            "space": "Sandbox",
            "name": "newpage",
            "title": "Hello world",
            "rawTitle": "Hello world",
            "parent": "",
            "parentId": "",
            "version": "1.1",
            "author": "XWiki.admin",
            "authorName": null,
            "xwikiRelativeUrl": "http://localhost:8080/bin/view/Sandbox/newpage",
            "xwikiAbsoluteUrl": "http://localhost:8080/bin/view/Sandbox/newpage",
            "translations": {
                "links": [],
                "translations": [],
                "default": ""
            },
            "syntax": "xwiki/2.0"
        }
    ]
}
"@ | ConvertFrom-Json }
        Mock -CommandName 'Invoke-XWRestMethod' -ModuleName 'XWikiAutomation' -MockWith $pageResponse
    }

    function ThenResponseCleaned
    {
        $script:result | Should -Not -BeNullOrEmpty
        $expectedResult = @"
{
    "id": "xwiki:Sandbox.newpage",
    "fullName": "Sandbox.newpage",
    "wiki": "xwiki",
    "space": "Sandbox",
    "name": "newpage",
    "title": "Hello world",
    "rawTitle": "Hello world",
    "parent": "",
    "parentId": "",
    "version": "1.1",
    "author": "XWiki.admin",
    "authorName": null,
    "xwikiRelativeUrl": "http://localhost:8080/bin/view/Sandbox/newpage",
    "xwikiAbsoluteUrl": "http://localhost:8080/bin/view/Sandbox/newpage",
    "translations": {
        "links": [],
        "translations": [],
        "default": ""
    },
    "syntax": "xwiki/2.0"
}
"@ | ConvertFrom-Json | ConvertTo-Json
        $script:result | ConvertTo-Json | Should -Be $expectedResult
    }

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
            $splat['SpacePath'] = $splat
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

    function MockRestMethod
    {
        param(
            $MockWith,
            [scriptblock] $ParameterFilter
        )

        $splat = @{}
        if ($ParameterFilter)
        {
            $splat['ParameterFilter'] = $ParameterFilter
        }

        if ($MockWith)
        {
            $splat['MockWith'] = $MockWith
        }

        Mock -CommandName 'Invoke-XWRestMethod' -ModuleName 'XWikiAutomation' @splat
    }

    function ThenRestMethodCalled
    {
        param(
            [int] $Times = 1,
            [scriptblock] $ParameterFilter
        )

        $splat = @{}
        if ($ParameterFilter)
        {
            $splat['ParameterFilter'] = $ParameterFilter
        }

        Should -Invoke 'Invoke-XWRestMethod' -ModuleName 'XWikiAutomation' -Times $Times
    }
}

Describe 'Get-XWPage' {
    BeforeEach {
        MockRestMethod
        $script:session = $xwTestSession
        $script:spacePath = $null
        $script:wikiName = $null
        $script:pageName = $null
        $script:result = $null
    }

    It 'should handle single item space paths' {
        $parameterFilter = { $Name -eq 'wikis/xwiki/spaces/Main/pages' }
        MockRestMethod -ParameterFilter $parameterFilter
        GivenSpacePath -SpacePath 'Main'
        WhenInvokingRestMethod
        ThenRestMethodCalled -ParameterFilter $parameterFilter
    }

    It 'should handle multiple item space paths' {
        $parameterFilter = { $Name -eq 'wikis/xwiki/spaces/Main/spaces/SubSpace/spaces/ThirdSpace/pages' }
        MockRestMethod -ParameterFilter $parameterFilter
        GivenSpacePath -SpacePath 'Main', 'SubSpace', 'ThirdSpace'
        WhenInvokingRestMethod
        ThenRestMethodCalled -ParameterFilter $parameterFilter
    }

    It 'should handle getting data by name' {
        $parameterFilter = { $Name -eq 'wikis/xwiki/spaces/Main/pages/myPage' }
        MockRestMethod -ParameterFilter $parameterFilter
        GivenSpacePath -SpacePath 'Main'
        GivenPageName -Name 'myPage'
        WhenInvokingRestMethod
        ThenRestMethodCalled -ParameterFilter $parameterFilter
    }

    It 'should handle different wikis' {
        $parameterFilter = { $Name -eq 'wikis/xwikipagetests/spaces/Main/spaces/SubSpace/pages' }
        MockRestMethod -ParameterFilter $parameterFilter
        GivenSpacePath -SpacePath 'Main', 'SubSpace'
        GivenWikiName -Name 'xwikipagetests'
        WhenInvokingRestMethod
        ThenRestMethodCalled -ParameterFilter { $Name -eq 'wikis/xwikipagetests/spaces/Main/spaces/SubSpace/pages' }
    }

    It 'should remove unneccessary links from result' {
        GivenSpaceResponse
        GivenSpacePath -SpacePath 'Main'
        WhenInvokingRestMethod
        ThenRestMethodCalled
        ThenResponseCleaned
    }
}