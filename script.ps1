#Function: Customize Windows Server Lab
#Drafting initial lab prep workflow



#Step1 
#New Name
$name = Read-Host -Prompt "`nNew Machine Name"
Rename-Computer -NewName $name -WarningAction SilentlyContinue

#Step2
#Configure Network 
$ipNew = Read-Host "`nEnter new IPaddress" ;
$gateNew = Read-Host "`nEnter new subnet" ;
$netConfigure = New-NetIPAddress -InterfaceIndex $ip.InterfaceIndex -IPAddress $ipNew -PrefixLength 24 -DefaultGateway $gateNew ;
$netConfigure

#Setup DNS
$dns = Set-DnsClientServerAddress -InterfaceIndex $ip.InterfaceIndex -ServerAddresses $ipnew,"8.8.8.8"
$dns


#Get-IPaddress
Write-host "`nLooking IPaddress"
$ip = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet0
Write-Host "`nIPaddress is" $ip.IPAddress "on interface" $ip.InterfaceIndex -ForegroundColor Yellow


#Step2
#Update PowerShell Help
Write-Host "`nUpdating Powershell Help" -ForegroundColor Yellow
$updateHelp = Update-Help -Force 
$updateHelp

#Step3
#Installing Windows Update PSModule
Write-Host "`nInstalling PSWindowUpdateModule" -ForegroundColor Yellow
$installerA = Install-Module -Name PSWindowsUpdate -Verbose -WarningAction SilentlyContinue
$installerA

#Step4
#Installing Updates for Windows
$updateB = Install-WindowsUpdate -AcceptAll -IgnoreReboot
$updateB




#Install AD Services
Write-host "Installing AD Feature"
$ADprep = Install-WindowsFeature –Name AD-Domain-Services -IncludeManagementTools
$ADprep

#Configure AD Specifics
$domain = Read-Host -Prompt "Enter Domain Name"
$ADprep2 = Install-ADDSForest `
-DomainName "$domain.LAB" `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "7" `
-DomainNetbiosName $domain `
-ForestMode "7" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$true `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true
$ADprep2


#AD Base Prep

$newBaseOU = Read-Host "Enter Base Name"

    #New OrganizationalUnit Base
    New-ADOrganizationalUnit `
    -Name $newBaseOU `
    -Path "DC=$domain,DC=LAB" `
    -ProtectedFromAccidentalDeletion $false

    #New OrganizationalUnit Computer
    New-ADOrganizationalUnit `
    -Name $newBaseOU-Computers `
    -Path "OU=$newBaseOU,DC=$domain,DC=LAB" `

    -ProtectedFromAccidentalDeletion $false

    #New OrganizationalUnit Users
    New-ADOrganizationalUnit `
    -Name $newBaseOU-Users `
    -Path "OU=$newBaseOU,DC=$domain,DC=LAB" `
    -ProtectedFromAccidentalDeletion $false


#Creating Lab Users, Compuers

#Define spreadsheet
$ComputerList = Read-Host "Enter File Info"

#Pulled Info into variable
$fetch = Get-Content "$ComputerList"

#Transfer variable into array
$comps = @($fetch)


#Add Comptuer Objects
foreach ($computer in $comps) {New-ADComputer -Name $computer -Path "OU= M-Computers,OU=$base,DC=$domain,DC=LAB" }


#Remove Objects
foreach ($computer in $comps){Remove-ADComputer -Identity $computer -Confirm:$false}



