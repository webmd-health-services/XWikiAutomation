
function Remove-XWPage
{
    <#
    .SYNOPSIS
    Deletes an XWiki page.

    .DESCRIPTION
    The `Remove-XWPage` function deletes an XWiki page. Provide the path to the space and the name of the page to
    delete. If the page does not exist, no action is taken.

    .EXAMPLE
    Remove-XWPage -Session $session -SpacePath 'Main' -Name 'HomePage'

    Demonstrates deleting the page named 'HomePage' in the space 'Main'.

    .EXAMPLE
    Remove-XWPage -Session $session -SpacePath 'Main' -Name 'Snoopy' -WikiName 'cartoons'

    Demonstrates deleting the page named 'Snoopy' in the space 'Main' in the wiki named 'cartoons'.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessage('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [Object] $Session,

        [Parameter(Mandatory)]
        [String[]] $SpacePath,

        [Parameter(Mandatory)]
        [String] $Name,

        [String] $WikiName = 'xwiki'
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $path = "wikis/${WikiName}/spaces/$($SpacePath -join '/spaces/')/pages/${Name}"

    Invoke-XWRestMethod -Session $Session -Name $path -Method Delete
}