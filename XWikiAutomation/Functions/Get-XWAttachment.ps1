
function Get-XWAttachment
{
    <#
    .SYNOPSIS
    Get an attachment from a page.

    .DESCRIPTION
    The `Get-XWAttachment` function gets an attachment from a page. If provided with an `AttachmentName`, it will
    download the attachment with that name. If not, it will get the metadata for all attachments.

    If the attachment is an image or another type of file that cannot be displayed as text, you can use the `OutFile`
    parameter to save the attachment to a file.

    .EXAMPLE
    Get-XWAttachment -Session $session -SpacePath 'Sandbox' -PageName 'WebHome'

    Demonstrates getting metadata for all attachments on the page 'WebHome' in the 'Sandbox' space.

    .EXAMPLE
    Get-XWAttachment -Session $session -SpacePath 'Sandbox' -PageName 'WebHome' -AttachmentName 'LICENSE.txt'

    Demonstrates getting the contents of the attachment named 'LICENSE.txt' on the page 'WebHome' in the 'Sandbox'
    space. This will return the contents of the attachment as a string.

    .EXAMPLE
    Get-XWAttachment -Session $session -SpacePath 'Sandbox' -PageName 'WebHome' -AttachmentName 'XWikiLogo.png' -OutFile 'C:\temp\XWikiLogo.png'

    Demonstrates saving the attachment named 'XWikiLogo.png' on the page 'WebHome' in the 'Sandbox' space to the file at
    the path 'C:\temp\XWikiLogo.png'.
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
        [Parameter(Mandatory)]
        [String] $PageName,

        # The name of the wiki the page belongs to. Defaults to xwiki.
        [String] $WikiName = 'xwiki',

        # The name of the attachment to get.
        [String] $AttachmentName,

        # The path to save the attachment to.
        [String] $OutFile
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $path = "wikis/$WikiName/spaces/$($SpacePath -join '/')/pages/$PageName/attachments"

    $params = @{}

    if ($OutFile)
    {
        $params['OutFile'] = $OutFile
    }

    if ($AttachmentName)
    {
        $path += "/$AttachmentName"
        return Invoke-XWRestMethod -Session $Session -Name $path @params
    }

    Invoke-XWRestMethod -Session $Session -Name $path -AsJson @params |
        Select-Object -ExpandProperty 'attachments'
}