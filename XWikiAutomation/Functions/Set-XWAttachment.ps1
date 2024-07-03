
function Set-XWAttachment
{
    <#
    .SYNOPSIS
    Uploads an attachment to a page.

    .DESCRIPTION
    The `Set-XWAttachment` function uploads an attachment to a page. Provide the path to the space as the `SpacePath`
    parameter, the name of the page as the `PageName` parameter, and the name of the attachment as the `AttachmentName`.
    You can provide the content of the attachment as a string via the `Content` parameter or as a file via the `InFile`
    parameter.

    .EXAMPLE
    Set-XWAttachment -Session $session -SpacePath 'Sandbox' -PageName 'WebHome' -AttachmentName 'MyTextFile.txt' -Content 'Hello, World!'

    Demonstrates uploading a text file named 'MyTextFile.txt' with the content 'Hello, World!' to the page 'WebHome' in
    the 'Sandbox' space.

    .EXAMPLE
    Set-XWAttachment -Session $session -SpacePath 'Sandbox' -PageName 'WebHome' -AttachmentName 'MyTextFile.txt' -InFile 'C:\temp\MyTextFile.txt'

    Demonstrates uploading a text file named 'MyTextFile.txt' with the content of the file at 'C:\temp\MyTextFile.txt'
    to the page 'WebHome' in the 'Sandbox' space.

    .EXAMPLE
    Set-XWAttachment -Session $session -SpacePath 'Sandbox' -PageName 'WebHome' -AttachmentName 'XWikiLogo.png' -InFile 'C:\temp\XWikiLogo.png'

    Demonstrates uploading an image file named 'XWikiLogo.png' with the content of the file at 'C:\temp\XWikiLogo.png'
    to the page 'WebHome' in the 'Sandbox' space.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessage('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName='InFile')]
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

        # The name of the attachment.
        [Parameter(Mandatory)]
        [String] $AttachmentName,

        # The path to the file to upload.
        [Parameter(Mandatory, ParameterSetName='InFile')]
        [String] $InFile,

        # The content of the attachment.
        [Parameter(Mandatory, ParameterSetName='Content')]
        [String] $Content,

        # The name of the wiki the page belongs to. Defaults to xwiki.
        [String] $WikiName = 'xwiki'
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $path = "wikis/$WikiName/spaces/$($SpacePath -join '/')/pages/$PageName/attachments/$AttachmentName"

    if ($PSCmdlet.ParameterSetName -eq 'InFile')
    {
        return Invoke-XWRestMethod -Session $Session -Name $path -Method Put -InFile $InFile
    }

    return Invoke-XWRestMethod -Session $Session -Name $path -Method Put -Body $Content
}