
<#
.SYNOPSIS
Installs XWiki on the local machine.

.DESCRIPTION
The `Install-LocalXWiki.ps1` script installs XWiki on the local machine. Using the `-Docker` switch will start XWiki
in a Docker container. The Docker container that is started will use PostgreSQL as the database, but it will need
interactive setup to configure the XWiki instance. The `-Windows` switch will install XWiki on the local machine
using the default flavor of XWiki. This will include the Jetty server, HSQLDB database, and will come with an
already created Admin:admin user account.

.EXAMPLE
.\Install-LocalXWiki.ps1 -Docker

Demonstrates starting XWiki inside of a container.

.EXAMPLE
.\Install-LocalXWiki.ps1 -Windows

Demonstrates installing XWiki on the local windows machine.
#>
[CmdletBinding(DefaultParameterSetName='Windows')]
param(
    [Parameter(Mandatory, ParameterSetName='Docker')]
    [switch] $Docker,

    [Parameter(Mandatory, ParameterSetName='Windows')]
    [switch] $Windows
)

Set-StrictMode -Version 'Latest'
$InformationPreference = 'Continue'
$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'PSModules\Carbon' -Resolve) -Force -Verbose:$false

if ($Docker)
{
    if (-not (Get-Command -Name 'docker') -and (Get-Command -Name 'podman'))
    {
        Set-Alias -Name 'docker' -Value 'podman'
    }

    docker network create xwikiautomation
    docker run --net=xwiki-nw --name postgres-xwiki -e POSTGRES_ROOT_PASSWORD=xwiki -e POSTGRES_USER=xwiki `
               -e POSTGRES_PASSWORD=xwiki -e POSTGRES_DB=xwiki -e POSTGRES_INITDB_ARGS="--encoding=UTF8" -d postgres:16
    docker run --net=xwiki-nw --name xwiki -p 8080:8080 -e DB_USER=xwiki -e DB_PASSWORD=xwiki `
               -e DB_DATABASE=xwiki -e DB_HOST=postgres-xwiki -d xwiki:stable-postgres-tomcat
    $msg = 'XWiki has been successfully started in Docker. It is available at http://localhost:8080/'
    Write-Information -MessageData $msg
    return
}

$outPath = Join-Path -Path $PSScriptRoot -ChildPath '.output'
$zipFilePath = Join-Path -Path $outPath -ChildPath 'xwiki.zip'
$xwikiRoot = Join-Path -Path $outPath -ChildPath 'xwiki'

Install-CDirectory -Path $outPath

if (-not (Test-Path -Path $zipFilePath))
{
    Invoke-WebRequest -Uri 'https://nexus.xwiki.org/nexus/content/groups/public/org/xwiki/platform/xwiki-platform-distribution-flavor-jetty-hsqldb/15.10.10/xwiki-platform-distribution-flavor-jetty-hsqldb-15.10.10.zip' -OutFile '.output/xwiki.zip'
}

if (-not (Test-Path -Path $xwikiRoot))
{
    Expand-Archive -Path $zipFilePath -DestinationPath $outPath -Force
    $xwikiUnzippedFolder = Get-ChildItem -Path $outPath -Filter 'xwiki*' -Directory | Select-Object -First 1
    Move-Item -Path $xwikiUnzippedFolder.FullName -Destination $xwikiRoot -Force
}

if (-not (Get-Command -Name 'java'))
{
    Write-Error 'No Java installation found. Please install Java and try again.'
    return
}

if (-not (Test-Path -Path (Join-Path -Path $xwikiRoot -ChildPath 'start_xwiki.bat')))
{
    Write-Error 'No XWiki installation found. Please re-run the script and try again.'
    return
}

$msg = 'XWiki has been successfully downloaded to the ${xwikiRoot} folder. Run it using the ./start_xwiki.bat script.'
Write-Information -MessageData $msg