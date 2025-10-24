# Create OSD Log File

function Write-DeploymentLogEntry {
	param (
		[parameter(Mandatory = $true, HelpMessage = "Value added to the log file.")]
		[ValidateNotNullOrEmpty()]
		[string]$Value,

		[parameter(Mandatory = $false, HelpMessage = "Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.")]
		[ValidateNotNullOrEmpty()]
		[ValidateSet("1", "2", "3")]
		[string]$Severity,
       
        [parameter(Mandatory = $true, HelpMessage = "Specify what type of log file this is (AppInstall/Remediation/Platform")]
		[ValidateNotNullOrEmpty()]
        [ValidateSet("AppInstall", "Remediation", "Platform")]
        [string]$LogType, 
        
        [parameter(Mandatory = $false, HelpMessage = "Name of the log file.")]
		[ValidateNotNullOrEmpty()]
		[string]$LogFileName

	)
    

# Detect if script is running in user or system contex...
  $Context = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
 
  if ($Context -like '*SYSTEM*') {
      Write-Host "Script is running in System context."
      $LogFilePath = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs"
  
 
  } else {
      Write-Host "Script is running in User context $context"
      if(!(Test-Path "$env:LOCALAPPDATA\DeploymentLogs")) {New-Item -Path "$env:LOCALAPPDATA\DeploymentLogs" -ItemType Directory -Force}
      $LogFilePath = "$env:LOCALAPPDATA\DeploymentLogs"
 
  
  }
    
    # Set Log file name and output path
      $LogFile = "TPS-$LogType-$LogFileName"
      $OutputPath = Join-Path -Path $LogFilePath -ChildPath $LogFile

    # Construct time stamp for log entry
	  $Time = -join @((Get-Date -Format "HH:mm:ss.fff"), " ", (Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias))
	
	# Construct date for log entry
      $Date = (Get-Date -Format "MM-dd-yyyy")
	
	# Construct final log entry
      $LogText = "<![LOG[$($Value)]LOG]!><time=""$($Time)"" date=""$($Date)"" component=""$($OutputPath)"" context=""$($Context)"" type=""$($Severity)"" thread=""$($PID)"" file="""">"

     Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $OutputPath -ErrorAction Stop

}