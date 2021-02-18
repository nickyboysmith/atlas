#Requires -Version 4

function Update-Web.Config {
<# 
 .SYNOPSIS
  Function/script to update web.config file

 .DESCRIPTION
  Function/script to update web.config file.
  Script can:
  - Replace text within web.config file preserving case
  - Remove sections/nodes from web.config file
  - Comment out sections in web.config file
  The script will make a backup copy of the web.config file before updating it.

 .PARAMETER Destination
  This is the full path of the folder where web.config file resides.
  For example: 'e:\websites\mywebsite.com'

 .PARAMETER OldPath
  Old path inside the web.config file.
  If this parameter is provided, the script will replace all occurences of the
  $OldPath with the $Destination path
  This is useful when migrating website from one directory structure to another

 .PARAMETER CommentSection
  Section(s) in web.config to comment out.
  For example: 'httpHandlers','configSections'

 .PARAMETER RemoveSection
  Section(s) in web.config to Remove.
  Must provide full section path such as '/configuration/configSections'

 .EXAMPLE
  Update-Web.Config -Destination E:\WebSites\Mywebsite1.com -CommentSection configSections -Verbose
  Comments out 'configSections' section

 .EXAMPLE
  Update-Web.Config -Destination E:\WebSites\Mywebsite1.com -OldPath D:\backme.up\websites\www.MyWebsite1.com\www -Verbose
  Replaces all occurrences of the string 'D:\backme.up\websites\www.MyWebsite1.com\www' with 'E:\WebSites\Mywebsite1.com' 

 .EXAMPLE
  Update-Web.Config -Destination E:\WebSites\Mywebsite1.com -RemoveSection '/configuration/configSections' -Verbose
  Removes '/configuration/configSections' section from web.config file

 .EXAMPLE
  Update-Web.Config -Destination E:\WebSites\Mywebsite1.com -OldPath D:\backme.up\websites\www.MyWebsite1.com\www -CommentSection configSections -RemoveSection '/configuration/runtime' -Verbose
  Replaces all occurrences of the string 'D:\backme.up\websites\www.MyWebsite1.com\www' with 'E:\WebSites\Mywebsite1.com' 
  Comments out 'configSections' section
  Removes '/configuration/runtime' section from web.config file

 .LINK
  http://superwidgets.wordpress.com/category/powershell/
  
 .NOTES
  Script by Sam Boutros
  v1.0 - 1/11/2015

#>

    [CmdletBinding()] 
    Param(
    [Parameter(Mandatory=$true,  Position=0)]
        [ValidateScript({ (Test-Path -Path "$Destination\web.config") })]
        [String]$Destination, 
    [Parameter(Mandatory=$false, Position=1)]
        [String]$OldPath, 
    [Parameter(Mandatory=$false, Position=2)]
        [String[]]$CommentSection,
    [Parameter(Mandatory=$false, Position=3)]
        [String[]]$RemoveSection 
    )

    Begin {
        # Make a backup copy before editing
        [XML]$XMLConfig = Get-Content "$Destination\web.config"
        $XMLConfig.Save("$Destination\web.config") # re-write the file neatly
        $WebConfig = Get-Content "$Destination\web.config"
        $ConfigBackup = "$Destination\web.config.$(Get-Date -Format yyyyMMdd_hhmmsstt).backup"
        try { Rename-Item -Path "$Destination\web.config" -NewName $ConfigBackup -Force -EA 1 } catch { throw }
        Write-Verbose "Backed up '$Destination\web.config' to '$ConfigBackup'"
    }

    Process {
    
        # Remove $RemoveSection node(s):
        if ($RemoveSection) {
            $FoundSection = $false
            $RemoveSection | % {
                if ($XMLConfig.SelectSingleNode($_)) {
                    $XMLConfig.configuration.RemoveChild($XMLConfig.SelectSingleNode($_)) 
                    $XMLConfig.Save("$Destination\web.config") 
                    Write-Verbose "Removed node '$_' from '$Destination\web.config'"
                    $FoundSection = $true
                } else {
                    Write-Warning "Node '$_' does not exist in '$Destination\web.config', skipping.."
                } 
            } 
            if ($FoundSection) {
                $WebConfig = Get-Content "$Destination\web.config"
                Remove-Item -Path "$Destination\web.config" -Force -Confirm:$false
            }
        } 


        if ($OldPath) { Write-Verbose "Updating web.config paths from '$OldPath' to '$Destination'" }
        foreach ($Line in $WebConfig) {

            # Comment out $CommentSection(s) in web.config - start
            $CommentSection | % {
                if ($Line.ToLower().IndexOf("<$_>".ToLower()) -gt 0) { 
                    '<!--' | Out-File "$Destination\web.config" -Append
                    Write-Verbose "Commenting out '<$_>' section in '$Destination\web.config'"
                }
            }

            # Build new web.config, update paths
            $Found = $Line.ToLower().IndexOf($OldPath.ToLower())
            if ($Found -gt 0) { 
                Write-Verbose "Updating line '$Line'"
                # Cannot use .replace method here since it's case sensitive, and I must preserve case
                $Line.Substring(0,$Found) + $Destination +
                $Line.Substring($Found+$OldPath.Length,$Line.Length-($Found+$OldPath.Length)) | 
                    Out-File "$Destination\web.config" -Append
            } else {
                $Line | Out-File "$Destination\web.config" -Append
            }

            # Comment out $CommentSection(s) in web.config - end
            $CommentSection | % {
                if ($Line.ToLower().IndexOf("</$_>".ToLower()) -gt 0) { 
                    '-->' | Out-File "$Destination\web.config" -Append
                }
            }

        } # end foreach $Line

    } # Process

}