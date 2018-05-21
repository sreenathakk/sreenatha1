Param(
    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string] $RdbrokerURI,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string] $fileURI,

    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string] $TenantName,

    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string] $AadTenantId,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string] $FriendlyName,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string] $Description,

    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [string] $HostPoolName,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string] $HostPoolFriendlyName,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string] $HostPoolDescription,
         
    [Parameter(Mandatory=$True)]
    [String] $Username,
    [Parameter(Mandatory=$True)]
    [string] $Password,
    [Parameter(Mandatory=$True)]
    [string] $ResourceGroupName
 
)

try {
$AdminKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}”
$UserKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}”
Set-ItemProperty -Path $AdminKey -Name “IsInstalled” -Value 0
Set-ItemProperty -Path $UserKey -Name “IsInstalled” -Value 0
Stop-Process -Name Explorer
“IE Enhanced Security Configuration (ESC) has been disabled on this machine.” 
}
catch {"Failed to disable IE ESC" }
Invoke-WebRequest -Uri $fileURI -OutFile "C:\PSModules.zip"
Start-Sleep -Seconds 30
New-Item -Path "C:\PSModules" -ItemType directory -Force -ErrorAction SilentlyContinue
Expand-Archive "C:\PSModules.zip" -DestinationPath "C:\PSModules" -ErrorAction SilentlyContinue
Set-Location "C:\PSModules"
Import-Module ".\PSModules\Microsoft.RDInfra.RDPowershell.dll"
$SecurePass = $Password | ConvertTo-SecureString -asPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($Username,$SecurePass)
Set-RdsContext -DeploymentUrl $RdbrokerURI -Credential $Credential
$newRdsTenant=New-RdsTenant -Name $TenantName -AadTenantId $AadTenantId -FriendlyName $FriendlyName -Description $Description
$newRDSHostPool=New-RdsHostPool -TenantName $TenantName  -Name $HostPoolName -Description $HostPoolDescription -FriendlyName $HostPoolFriendlyName
<#
Remove-Item -Path "C:\PowershellModules.zip" -Recurse -force
Remove-Item -Path "C:\PowershellModules" -Recurse -Force
#>
.\RemoveRG.ps1 -AadTenantId $AadTenantId -Username $Username -Password $Password -ResourceGroupName $ResourceGroupName
