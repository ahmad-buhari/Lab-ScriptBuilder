#Function: Customize Windows Server Lab
#Drafting initial lab prep workflow


#Defining Custom Function 
## Reference from https://docs.microsoft.com/en-us/powershell/scripting/learn/ps101/09-functions?view=powershell-7.1
function Build-Lab {


    #Assiging Parameters for function
    ##Add additional param with , (comma) 
    param ([string]$Title = '')

    #Clears screen when function start
    Clear-Host

    #Outpput Menu Title & Menu Selection
    Write-Host "---$Title---" -ForegroundColor Yellow

}

#Variables for Menu        
$TitleInfo = "PowerShell Lab Builder"
$CommandMenu = " `nSelect the following options:
`nPress 1 - Configure Machine Info
`nPress 2 - Configure Domain Server & Active Directory
"

PowerShell-Menu -Title "$TitleInfo"

#Looping statement until var $selection ends
do {
        
    $selection = Read-Host -Prompt "`n $CommandMenu"
   
                
    # Iterating through loop
    Try { 
        switch ([int]$selection) {

            '1' {

                #Phase 1 Prepping Server 

                #Getting Server Details
                $name = Read-Host -Prompt "`nNew Machine Name"
                $ipNew = Read-Host "`nEnter new IPaddress" ;
                $gateNew = Read-Host "`nEnter new subnet" ;
                $ipdns = Read-Host -Prompt "`nEnter DNS IPaddress"

                #Verfiy
                Write-Host "`New Machine name $name with IPaddress of $ipNew, gateway $gateNew, and DNS IP of $dns" -ForegroundColor Yellow
                $response = Read-Host -Prompt "`nProceed with config Y or N"
                if (($response -match "Y") -or ($response -match "YES")) {

                    #Rename Machine
                    Rename-Computer -NewName $name -WarningAction SilentlyContinue
                    Write-Host "`nRenaming Computer" -ForegroundColor Yellow

                    #Configure Network 

                    $netConfigure = New-NetIPAddress -InterfaceIndex $ip.InterfaceIndex -IPAddress $ipNew -PrefixLength 24 -DefaultGateway $gateNew ;
                    $netConfigure
                    Write-Host "`nConfiguring Network" -ForegroundColor Yellow

                    #Setup DNS
                                            
                    $dns = Set-DnsClientServerAddress -InterfaceIndex $ip.InterfaceIndex -ServerAddresses $ipdns, "8.8.8.8"
                    $dns
                                            
                                            
                }

                else {
                    Write-host "`nPlease restart" -ForegroundColor DarkMagenta

                                                                                                    
                }




            }
        
        }

    }


    #Error Statement
    catch {
        [System.OutOfMemoryException]
                        
        Write-Host 'Restart Powershell script' -ForegroundColor Red; 
    
    }
    #Error Statement 2
    if ($selection -gt 10) { Write-Host "`n Please Choose Options" -ForegroundColor Red }
                    
        
        
    #Loop Limit            
} until ($selection -eq 10)




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
foreach ($computer in $comps) { New-ADComputer -Name $computer -Path "OU= M-Computers,OU=$base,DC=$domain,DC=LAB" }


#Remove Objects
foreach ($computer in $comps) { Remove-ADComputer -Identity $computer -Confirm:$false }






