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

    .PARAMETER  Environment
    Specifies which environment the application should
    be deployed to.

    .PARAMETER  RunScriptName
    Specifies which environment the application should
    be deployed to.

    .INPUTS
    System.String

    .OUTPUTS
    None. This script does not return any objects.

    .NOTES
    This script automatically sets the $VerbosePreference to Continue,
    so all verbose messages are displayed, and the $ErrorActionPreference
    to Stop so that non-terminating errors stop the script.


    .EXAMPLE
    Publish-AzureWebsiteDevbox.ps1 -Launch [Environment]

    .LINK
    Show-AzureWebsite
#>
Param(
    [Parameter(Mandatory = $true)]
    [Switch]$Launch,
    [String]$Environment,
	[String]$actualWebsiteName,
    [String]$runScriptName
)

# Begin - Actual script -----------------------------------------------------------------------------------------------------------------------------

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"


$scriptPath = Split-Path -parent $PSCommandPath
$mergedWebsiteName = "iam-atlas-" + $Environment

Write-Verbose ("You are deploying to the " + $Environment + " environment!")

If ($Environment -match "live-uk") {$resourceGroup = "IAM_Live_Server_ResourceGroup2"}
elseif ($Environment -match "demo") {$resourceGroup = "IAM_Demo_Scheduler_ResourceGroup"}
else {$resourceGroup = "Default-SQL-WestEurope"}

If ($Environment -match "live-uk") {$jobCollectionName = "LIVE-UK-Atlas-System-Jobs"}
elseif ($Environment -match "demo") {$jobCollectionName = "DEMO-Atlas-System-Jobs"}
elseif ($Environment -match "dev") {$jobCollectionName = "Atlas-System-Jobs"}
elseif ($Environment -match "test") {$jobCollectionName = "TEST-Atlas-System-Jobs"}
elseif ($Environment -match "uat") {$jobCollectionName = "UAT-Atlas-System-Jobs"}


#$azureAccountEmail = "Atlas.ReleaseAgent@iam.org.uk"
#$azurePass = ConvertTo-SecureString "AtlasDev201504~!” -AsPlainText -Force

#$psCred = New-Object System.Management.Automation.PSCredential($azureAccountEmail, $azurePass)

Write-Verbose("About to execute Login-AzureRmAccount")
#Login-AzureRmAccount
#$azureAccount = "Atlas.ReleaseAgent@iam.org.uk"
#$pass = ConvertTo-SecureString "AtlasDev201504~!" -AsPlainText –Force
#$cred = New-Object -typename System.Management.Automation.PSCredential `
#     -argumentlist $username, $SecurePassword

Login-AzureRmAccount #-Credential $cred

Write-Verbose("Past Login-AzureRmAccount")



#Login-AzureRmAccount -Credential $cred -ServicePrincipal –TenantId <Your TenantId>

Write-Verbose("Environment: " + $Environment + " website: " + $actualWebsiteName)

Write-Verbose("Disabling scheduled jobs for: " + $actualWebsiteName + ". Job Collection Name: " + $jobCollectionName + ". Resource Group: " + $resourceGroup)

Disable-AzureRmSchedulerJobCollection -JobCollectionName $jobCollectionName -ResourceGroupName $resourceGroup

# Verify that the account credentials are current in the Windows
#  PowerShell session. This call fails if the credentials have
#  expired in the session.
Write-Verbose "Verifying that Windows Azure credentials in the Windows PowerShell session have not expired."
Get-AzureWebsite | Out-Null

# Mark the start time of the script execution
$startTime = Get-Date

# Build and publish the project via web deploy package using msbuild.exe
Write-Verbose ("[Start] deploying to Windows Azure website {0}" -f $websiteName)

##############################################################################################################
#
# List the projects and put projects and project paths into an array
#
##############################################################################################################

$uiProject = "ui-"
$uiProjectPath = ".\IAM.Atlas.UI\IAM.Atlas.UI.csproj"

$webAPIProject = "webapi-"
$webAPIProjectPath = ".\IAM.Atlas.WebAPI\IAM.Atlas.WebAPI.csproj"


$schedulerAPIProject = "scheduler-"
$schedulerAPIProjectPath = ".\IAM.Atlas.Scheduler.WebService\IAM.Atlas.Scheduler.WebService.csproj"

$dorsAPIProject = "dors-"
$dorsAPIProjectPath = ".\IAM.DORS.Webservice\IAM.DORS.Webservice.csproj"

$netcallProject = "netcall-"
$netcallProjectPath = ".\IAM.Atlas.Netcall.WebService\IAM.Atlas.Netcall.WebService.csproj"

$projects = ($uiProject, $webAPIProject, $schedulerAPIProject, $dorsAPIProject, $netcallProject)
$projectPath = ($uiProjectPath, $webAPIProjectPath, $schedulerAPIProjectPath, $dorsAPIProjectPath, $netcallProjectPath)


##############################################################################################################
#
# Get the publish file settings
#
##############################################################################################################

$publishSettingsPath = $scriptPath + "\Atlas-" + $Environment + ".publishsettings.xml"
[Xml]$xml = Get-Content $publishSettingsPath
if (!$xml) {throw "Error: Cannot find a publishsettings file for the $website web site in $scriptPath."}
$password = $xml.publishData.publishProfile.userPWD[0]


##############################################################################################################
#
# Get the database details for the current Environment
#
##############################################################################################################

$database = $xml.publishData.publishProfile.SQLServerDBConnectionString[0].Split(";")
$databaseCredentials = $database.Split("=");

$databaseServer = $databaseCredentials[1]
$databaseName = $databaseCredentials[3]
$databaseUser = $databaseCredentials[5]
$databasePassword = $databaseCredentials[7]


##############################################################################################################
# Create Log File
#############################################################################################################
$scriptLog = ".\IAM.Atlas.Data\SQLScripts\scriptRunner_" + (Get-Date -UFormat "%d_%m_%Y_%H_%M_%S") + ".txt"
New-Item $scriptLog -type file | Out-Null
Write-Verbose "Created the ScriptLog file"


##############################################################################################################
# Set and run the prerelease script
##############################################################################################################

	# Create a new object
    $PreReleaseScripts = @()

    # Get the preRelease path & prerelease path script
	$runPreReleaseSqlScript = Get-Item -Path ".\IAM.Atlas.Data\SQLScripts\ReleaseScripts\Pre-Release.sql"

    # Add to the object
    $PreReleaseScripts += $runPreReleaseSqlScript

    # Loop through the list of release properties
    Foreach ($script in $PreReleaseScripts)
    {
        Write-Verbose "Running .... $script"
        & SQLCMD -S $databaseServer -d $databaseName -U $databaseUser -P $databasePassword -I -l 300 -m-1 -u -i $script >> $scriptLog
        $scriptResult = Get-Content $scriptLog | Select-Object -last 1
        If ($scriptResult -NotLike "*rows affected*" ) {
            $ranAllScriptsSuccessfully = $false
            break
        }
		Write-Output " Output        Completed: $script"
		Write-Verbose " Verbose         Completed: $script"
        Write-Verbose "Script Result : $scriptResult"
    }


##############################################################################################################
#
# Deploy the IAM.Atlas.UI & IAM.Atlas.WebAPI Projects
#
##############################################################################################################

Foreach ($project in $projects)
{
    $projectIndex = $projects.IndexOf($project)

    # If is the UI project create a new globalJS file & then upload
    If ($project -eq "ui-") {
        $newFilePath = ".\IAM.Atlas.UI\app_assets\js\globals.js"
        #$apiPath = "http://" + $mergedWebsiteName + ".azurewebsites.net"
		$apiPath = $actualWebsiteName
        New-Item $newFilePath -type file -force -value "var apiServer = '$apiPath/webapi/api'; var apiServerImagePath = '$apiPath/webapi'; var schedulerServer = '$apiPath/scheduler'"
    }

    # Get Publish Settings for the UI project
    $publishFile = Join-Path $scriptPath -ChildPath ($project + $mergedWebsiteName + ".pubxml")

    # Run MSBuild to publish the project
    & "C:\Program Files (x86)\MSBuild\12.0\bin\amd64\MSBuild.exe" $projectPath[$projectIndex] /p:VisualStudioVersion=14.0 /p:DeployOnBuild=true /p:PublishProfile=$publishFile /p:Password=$password

    # Once the build has finished revert to the old globals
    If ($project -eq "ui-") {
        $newFilePath = ".\IAM.Atlas.UI\app_assets\js\globals.js"
        New-Item $newFilePath -type file -force -value "var apiServer = 'http://localhost:63105/api'; var apiServerImagePath = 'http://localhost:63105'; var schedulerServer = 'http://localhost:51955/'"
    }


    Write-Verbose "[Finish] deploying the $project project to Windows Azure website $mergedWebsiteName"
    # Mark the finish time of the script execution
    $finishTime = Get-Date

    # Output the time consumed in seconds
    Write-Output "Total time used (seconds): ($finishTime - $startTime).TotalSeconds)"s
}


##############################################################################################################
#
# Start the Script Runner process here
#
##############################################################################################################

# Put the list of SQL Scripts into an Array
Write-Verbose "Get list of SQL Scipts"
$sqlScripts = Get-ChildItem -Path ".\IAM.Atlas.Data\SQLScripts\*Sprint_*" –Recurse

# Set a flag
$runTheSqlScripts = $false

# Set flag
$ranAllScriptsSuccessfully = $true


# If Script name not set! Dont Run
If (![string]::IsNullOrEmpty($runScriptName)) {

    Write-Verbose "Script flag specified"

    Foreach ($script in $sqlScripts)
    {

        # Get the SQL Script filename
        $scriptName = split-path $script -leaf -resolve

        # If the name of script is found.
        # Set the flag to true
        If ($scriptName -like "*$runScriptName*") {
            Write-Verbose "Script found run from this script"
            $runTheSqlScripts = $true
        }

        # If the scriptname is not found dont run the scripts
        If ($runTheSqlScripts) {

            Write-Verbose "Running .... $script"

            # Run the SQL Command
            & SQLCMD -S $databaseServer -d $databaseName -U $databaseUser -P $databasePassword -I -l 300 -m-1 -u -i $script >> $scriptLog
            $scriptResult = Get-Content $scriptLog | Select-Object -last 1
            # If the result is an error
            # Set the flag to false and break out of the loop
            If ($scriptResult -NotLike "*rows affected*") {
                $ranAllScriptsSuccessfully = $false
                break
            }
            Write-Output "         Completed: $scriptName"
        }
    }

}

##############################################################################################################
# Set and run the SetupAdministrationMenuItems script
##############################################################################################################

# Should always get here
If ($ranAllScriptsSuccessfully) {

	Write-Output "Completed running all SPRINT scripts successfully."

	# Create a new object
    $AdminMenuItemScripts = @()

    # Get the preRelease path & prerelease path script
	$runAdminMenuItemScript = Get-Item -Path ".\IAM.Atlas.Data\SQLScripts\ReleaseScripts\SetupAdministrationMenuItems.sql"

    # Add to the object
    $AdminMenuItemScripts += $runAdminMenuItemScript

    # Loop through the list of release properties
    Foreach ($script in $AdminMenuItemScripts)
    {
        Write-Verbose "Running .... $script"
        & SQLCMD -S $databaseServer -d $databaseName -U $databaseUser -P $databasePassword -I -l 300 -m-1 -u -i $script >> $scriptLog
        $scriptResult = Get-Content $scriptLog | Select-Object -last 1
        If ($scriptResult -NotLike "*rows affected*" ) {
            $ranAllScriptsSuccessfully = $false
            break
        }
		Write-Output " Output        Completed: $script"
		Write-Verbose " Verbose         Completed: $script"
        Write-Verbose "Script Result : $scriptResult"
    }
}


##############################################################################################################


If ($ranAllScriptsSuccessfully) {

    Write-Output "Completed running the SetupAdministrationMenuItems script successfully."

##############################################################################################################
# Set and run the View scripts
##############################################################################################################

	# Put the list of SQL Scripts into an Array
	Write-Verbose "Get list of View Scripts"
	$sqlViewScripts = Get-ChildItem -Path ".\IAM.Atlas.Data\SQLScripts\*ReleaseViewScripts\*" –Recurse

	# Set flag
	$ranAllScriptsSuccessfully = $true

		Foreach ($script in $sqlViewScripts)
		{

            Write-Verbose "Running .... $script"

				& SQLCMD -S $databaseServer -d $databaseName -U $databaseUser -P $databasePassword -I -l 300 -m-1 -u -i $script >> $scriptLog
				$scriptResult = Get-Content $scriptLog | Select-Object -last 1
				# If the result is an error
                # Set the flag to false and break out of the loop
                If ($scriptResult -NotLike "*rows affected*") {
                    $ranAllScriptsSuccessfully = $false
                    break
                }
				Write-Output "         Completed: $scriptResult"

		}

}

##############################################################################################################
# Set and run the RunEveryRelease script
##############################################################################################################

# Should always get here
If ($ranAllScriptsSuccessfully) {

	Write-Output "Completed running all VIEW scripts successfully."

	# Create a new object
    $RunEveryReleaseScripts = @()

    # Get the RunEveryRelease path & RunEveryRelease path script
	$runRunEveryReleaseSqlScript = Get-Item -Path ".\IAM.Atlas.Data\SQLScripts\Data\RunEveryRelease.sql"

    # Add to the object
    $RunEveryReleaseScripts += $runRunEveryReleaseSqlScript

    # Loop through the list of release properties
    Foreach ($script in $RunEveryReleaseScripts)
    {
        Write-Verbose "Running .... $script"
        & SQLCMD -S $databaseServer -d $databaseName -U $databaseUser -P $databasePassword -I -l 300 -m-1 -u -i $script >> $scriptLog
        $scriptResult = Get-Content $scriptLog | Select-Object -last 1
        If ($scriptResult -NotLike "*rows affected*" ) {
            $ranAllScriptsSuccessfully = $false
            break
        }
		Write-Output " Output        Completed: $script"
		Write-Verbose " Verbose         Completed: $script"
        Write-Verbose "Script Result : $scriptResult"
    }
}

##############################################################################################################
# Set and run the recompilation script
##############################################################################################################

# Should always get here
If ($ranAllScriptsSuccessfully) {

	Write-Output "Completed running the RunEveryReleaseScript successfully."

	# Create a new object
    $recompilationScripts = @()

    # Get the preRelease path & prerelease path script
	$runRecompilationSqlScript = Get-Item -Path ".\IAM.Atlas.Data\SQLScripts\ReleaseScripts\RecompileStoredProceduresAndFunctions.sql"

    # Add to the object
    $recompilationScripts += $runRecompilationSqlScript

    # Loop through the list of release properties
    Foreach ($script in $recompilationScripts)
    {
        Write-Verbose "Running .... $script"
        & SQLCMD -S $databaseServer -d $databaseName -U $databaseUser -P $databasePassword -I -l 300 -m-1 -u -i $script >> $scriptLog
        $scriptResult = Get-Content $scriptLog | Select-Object -last 1
        If ($scriptResult -NotLike "*rows affected*" ) {
            $ranAllScriptsSuccessfully = $false
            break
        }
		Write-Output " Output        Completed: $script"
		Write-Verbose " Verbose         Completed: $script"
        Write-Verbose "Script Result : $scriptResult"
    }
}


##############################################################################################################

##############################################################################################################
# Set and run the postrelease script
##############################################################################################################

# Should always get here
If ($ranAllScriptsSuccessfully) {

	Write-Output "Completed running the recompilation successfully."

	# Create a new object
    $PostReleaseScripts = @()

    # Get the preRelease path & prerelease path script
	$runPostReleaseSqlScript = Get-Item -Path ".\IAM.Atlas.Data\SQLScripts\ReleaseScripts\Post-Release.sql"

    # Add to the object
    $PostReleaseScripts += $runPostReleaseSqlScript

    # Loop through the list of release properties
    Foreach ($script in $PostReleaseScripts)
    {
        Write-Verbose "Running .... $script"
        & SQLCMD -S $databaseServer -d $databaseName -U $databaseUser -P $databasePassword -I -l 300 -m-1 -u -i $script >> $scriptLog
        $scriptResult = Get-Content $scriptLog | Select-Object -last 1
        If ($scriptResult -NotLike "*rows affected*" ) {
            $ranAllScriptsSuccessfully = $false
            break
        }
		Write-Output " Output        Completed: $script"
		Write-Verbose " Verbose         Completed: $script"
        Write-Verbose "Script Result : $scriptResult"
    }
}


##############################################################################################################

Write-Verbose("Re-enabling the scheduled job collection")

Enable-AzureRmSchedulerJobCollection -JobCollectionName $jobCollectionName -ResourceGroupName $resourceGroup

##############################################################################################################



Write-Output ""
Write-Output "Finished deploying................ BADA BING, BADA BOOM!"


##############################################################################################################
#
# If the -Launch flag has been set! Fire the test application site
#
##############################################################################################################

If ($Launch)
{
    Show-AzureWebsite -Name $mergedWebsiteName
}

# End - Actual script ----------------------------------------------------------------------------------------
