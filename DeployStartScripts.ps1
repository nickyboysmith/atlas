<# 
    .SYNOPSIS  
    Publishes a Windows Azure website project  
             
    .DESCRIPTION 
    The Publish-AzureWebsiteDevbox.ps1 script publishes 
    the project that is associated with a Windows Azure 
    website.  
 
    To run this script, you must have a Windows Azure  
    website associated with your Windows Azure account. 
    To verify, run the Get-AzureWebsite cmdlet.        
 
    .PARAMETER  Launch 
    Starts a browser that displays the website. This 
    switch parameter is optional. 

    .INPUTS 
    System.String 
 
    .OUTPUTS 
    None. This script does not return any objects. 
 
    .NOTES 
    This script automatically sets the $VerbosePreference to Continue,  
    so all verbose messages are displayed, and the $ErrorActionPreference 
    to Stop so that non-terminating errors stop the script. 
 
 
    .EXAMPLE 
    Publish-AzureWebsiteDevbox.ps1 -Launch
  
    .LINK 
    Show-AzureWebsite 
#>  

 
# Begin - Actual script ----------------------------------------------------------------------------------------------------------------------------- 
  
# Set the output level to verbose and make the script stop on error 
$VerbosePreference = "Continue" 
$ErrorActionPreference = "Stop" 

##############################################################################################################
#
# Start the Script Runner process here
#
##############################################################################################################

# Create Log File
$scriptLog = ".\IAM.Atlas.Data\SQLScripts\scriptRunner_" + (Get-Date -UFormat "%d_%m_%Y_%H_%M_%S") + ".txt"
New-Item $scriptLog -type file | Out-Null
Write-Verbose "Created the ScriptLog file"

# Put the list of SQL Scripts into an Array
Write-Verbose "Get list of SQL Scripts"
$sqlScripts = Get-ChildItem -Path ".\IAM.Atlas.Data\SQLScripts\*Sprint_*" –Recurse

Foreach ($script in $sqlScripts) 
{
    # Get the SQL Script filename
    $scriptName = split-path $script -leaf -resolve
    
    # Run the SQL Command
    & SQLCMD -S .\SQLEXPRESS -d AtlasTestDB -E  -l 300 -i $script >> $scriptLog

    Write-Verbose "Completed: $scriptName"
}

Write-Output ""
Write-Output "Completed running all scripts successfully................ BADA BING, BADA BOOM!"

 
##############################################################################################################
#
# If the -Launch flag has been set! Fire the test application site
#
##############################################################################################################

 
# End - Actual script ----------------------------------------------------------------------------------------
