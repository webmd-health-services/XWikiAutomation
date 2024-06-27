
function Set-XWPage
{
    <#
    .SYNOPSIS
    Creates or edits an XWiki page.

    .DESCRIPTION
    The `Set-XWPage` function creates or edits an XWiki page. It can set the title, parent page, hidden status, and
    the content of the page. If the page already exists, it will be updated with the new information. Only the fields
    that are edited need to be provided.

    .EXAMPLE
    Set-XWPage -Session $session -SpacePath 'Main' -Name 'HomePage' -Title 'XWiki Home'

    Demonstrates creating or editing a page named 'HomePage' in the space 'Main' with the title 'XWiki Home'.

    .EXAMPLE
    Set-XWPage -Session $session -SpacePath 'Main' -Name 'HomePage' -Content 'This is the content of the page.'

    Demonstrates creating or editing a page named 'HomePage' in the space 'Main' with the content 'This is the content
    of the page.'

    .EXAMPLE
    Set-XWPage -Session $session -SpacePath 'Main' -Name 'HomePage' -Hidden $true

    Demonstrates creating or editing a page named 'HomePage' in the space 'Main' and hiding it.

    .EXAMPLE
    Set-XWPage -Session $session -SpacePath 'Main' -Name 'HomePage' -Parent 'ParentPage'

    Demonstrates creating or editing a page named 'HomePage' in the space 'Main' with the parent page 'ParentPage'. If
    the page already exists, it will be moved to be a child of 'ParentPage'.
    #>
    [CmdletBinding(DefaultParameterSetName='ByAttribute')]
    param (
        # The Session object for an XWiki session. Create a new Session using `New-XWSession`.
        [Parameter(Mandatory)]
        [Object] $Session,

        # The space path to get to the page.
        [Parameter(Mandatory)]
        [String[]] $SpacePath,

        # The name of the page to edit.
        [Parameter(Mandatory)]
        [String] $Name,

        # The new title of the page.
        [Parameter(ParameterSetName='ByAttribute')]
        [String] $Title,

        # The new parent page of this page.
        [Parameter(ParameterSetName='ByAttribute')]
        [String] $Parent,

        # Whether the page should be hidden or not.
        [Parameter(ParameterSetName='ByAttribute')]
        [bool] $Hidden,

        # The new content of the page.
        [Parameter(ParameterSetName='ByAttribute')]
        [String] $Content,

        # An XML object representing the page.
        [Parameter(ParameterSetName='ByXML')]
        [xml] $Body,

        # The name of the wiki the page belongs to. Defaults to xwiki.
        [String] $WikiName = 'xwiki'
    )

    $path = "wikis/${WikiName}/spaces/$($SpacePath -join '/spaces/')/pages/${Name}"

    if ($PSCmdlet.ParameterSetName -eq 'ByXML')
    {
        return Invoke-XWRestMethod -Session $Session -Name $path -Method Put -Body $body.ToString()
    }

    $formData = @{}

    if ($Title)
    {
        $formData['title'] = $Title
    }
    if ($Parent)
    {
        $formData['parent'] = $Parent
    }
    if ($null -ne $Hidden)
    {
        $formData['hidden'] = $Hidden
    }
    if ($Content)
    {
        $formData['content'] = $Content
    }

    Invoke-XWRestMethod -Session $session -Name $path -Method Put -Form $formData |
        Select-Object -ExpandProperty 'page'
}