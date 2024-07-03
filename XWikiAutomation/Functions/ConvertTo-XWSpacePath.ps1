
function ConvertTo-XWSpacePath
{
    <#
    .SYNOPSIS
    Converts a page reference to a space path.

    .DESCRIPTION
    The `ConvertTo-XWSpacePath` function converts a page reference to a space path. The page reference is a string that
    is provided by XWiki to identify a page. The page reference is in the format `space.page`. This function will split
    the page reference on the `.` character unless it is escaped with a `\`. It is returned as a hashtable with the
    spacepath under the key `SpacePath`, and the page name under the key `PageName`.

    .EXAMPLE
    ConvertTo-XWSpacePath -PageReference 'Main.WebHome'

    Demonstrates converting the page reference 'Main.WebHome' to the space path 'Main', 'WebHome'.
    #>
    [CmdletBinding()]
    param(
        # The page reference to convert.
        [Parameter(Mandatory)]
        [String] $PageReference
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $parts = $PageReference -split '(?<!\\)\.'
    $pageName = $parts[$parts.Length - 1]
    $spacePath = $parts[0..($parts.Length - 2)]

    return @{
        SpacePath = $spacePath
        PageName = $pageName
    }
}