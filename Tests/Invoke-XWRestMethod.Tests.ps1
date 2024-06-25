Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    function MockIrm
    {
        param(
            [Object] $MockWith,
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


        Mock -CommandName 'Invoke-RestMethod' -ModuleName 'XWikiAutomation' @splat
    }

    function ThenRestMethodInvoked
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

        Should -Invoke 'Invoke-RestMethod' -ModuleName 'XWikiAutomation' -Times $Times @splat
    }

    function ThenRestMethodNotInvoked
    {
        Should -Not -Invoke 'Invoke-RestMethod' -ModuleName 'XWikiAutomation'
    }
}

Describe 'Invoke-XWRestMethod' {
    BeforeEach {
        $script:session = $xwTestSession
    }

    It 'should always make GET requests' {
        MockIrm -MockWith { 'get-request' }
        $res = Invoke-XWRestMethod -Session $script:session -Name 'wikis' -Method Get
        $res | Should -Be 'get-request'
        $res = Invoke-XWRestMethod -Session $script:session -Name 'wikis' -Method Get -WhatIf
        $res | Should -Be 'get-request'
        ThenRestMethodInvoked -Times 2

    }

    It 'should not make PUT requests with WhatIf' {
        MockIrm -MockWith { 'put-request' }
        $res = Invoke-XWRestMethod -Session $script:session -Name 'wikis' -Method Put
        $res | Should -Be 'put-request'
        $res = Invoke-XWRestMethod -Session $script:session -Name 'wikis' -Method Put -WhatIf
        $res | Should -BeNullOrEmpty
        ThenRestMethodInvoked -Times 1
    }

    It 'should call using the media=json query parameter' {
        $parameterFilter = { $Uri.ToString().EndsWith('media=json') }
        MockIrm -MockWith { 'get-request' } -ParameterFilter $parameterFilter
        $res = Invoke-XWRestMethod -Session $script:session -Name 'wikis' -Method Get -AsJson
        $res | Should -Be 'get-request'
        ThenRestMethodInvoked -ParameterFilter $parameterFilter
    }

}