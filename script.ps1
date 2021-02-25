#Function: Customize Windows Server Lab



#New Name
$name = Read-Host -Prompt "`nNew Machine Name"
Rename-Computer -NewName $name -WarningAction SilentlyContinue


#Update PowerShell Help
Write-Host "`nUpdating Powershell Help" -ForegroundColor Yellow
$updateA = Update-Help -Force 
$updateA

#Installing Update Module
Write-Host "`nInstalling PSWindowUpdateModule" -ForegroundColor Yellow
$installerA = Install-Module -Name PSWindowsUpdate -Verbose -WarningAction SilentlyContinue
$installerA

#Installing Update
$updateB = Install-WindowsUpdate -AcceptAll -IgnoreReboot
$updateB

#Get-IPaddress
Write-host "`nLooking IPaddress"
$ip = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet0
Write-Host "`nIPaddress is" $ip.IPAddress "on interface" $ip.InterfaceIndex -ForegroundColor Yellow


#Configure Network 
$ipNew = Read-Host "`nEnter new IPaddress" ;
$gateNew = Read-Host "`nEnter new subnet" ;

$netConfigure = New-NetIPAddress -InterfaceIndex $ip.InterfaceIndex -IPAddress $ipNew -PrefixLength 24 -DefaultGateway $gateNew ;
$netConfigure
