
function Get-XWPage
{
    <#
    .SYNOPSIS
    Gets all pages inside of a space.

    .DESCRIPTION
    The `Get-XWPage` function gets all of the content for all of the pages in a given space. Provide the path to the
    space as the `SpacePath` parameter.

    To get the details on a specific page rather than all pages inside of a space, provide the name of the page to the
    `Name` parameter.

    .EXAMPLE
    Get-XWPage -Session $session -SpacePath 'foo', 'bar'

    Demonstrates getting all of the pages within the space 'foo/bar'.

    .EXAMPLE
    Get-XWPage -Session $session -SpacePath 'Main' -Name 'MyPage'

    Demonstrates getting the page named 'MyPage'inside of the space named 'Main'.

    .EXAMPLE
    Get-XWPage -Session $session -SpacePath 'scooby', 'doo' -WikiName 'cartoons'

    Demonstrates getting all of the pages within the space 'scooby/doo' inside of the wiki named 'cartoons'.
    #>
    [CmdletBinding()]
    param(
        # The Session object for an XWiki session. Create a new Session using `New-XWSession`.
        [Parameter(Mandatory)]
        [Object] $Session,

        # The space path to get to the page.
        [Parameter(Mandatory)]
        [String[]] $SpacePath,

        # The name of the page.
        [String] $Name,

        # The name of the wiki the page belongs to. Defaults to xwiki.
        [String] $WikiName = 'xwiki'
    )

    $path = "wikis/${WikiName}/spaces/$($SpacePath -join '/spaces/')/pages"

    if ($Name)
    {
        $path = "${path}/${Name}"
    }

    Invoke-XWRestMethod -Session $Session -Name $path -AsJson |
        Select-Object -ExpandProperty 'pageSummaries' |
        Select-Object -ExcludeProperty 'links'
}