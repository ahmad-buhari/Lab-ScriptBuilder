#Script: Customize Windows Server Lab
#Drafting initial lab prep workflow

##Menu Selection        
$TitleInfo = "PowerShell Lab Builder"
$quit = "`nPress X or Ctrl+C to quit"
$CommandMenu = " `nSelect the following options:
`nPress 1 - Configure Machine Info
`nPress 2 - Update Server and HelpMenu (*must run PowerShell as administrator)
`nPress 3 - Create New Lab Domain and Active Directory
`nPress 4 - Create new Top Level OU, e.g new Base name with additional OU for computers and users
`nPress 5 - Create New Computer(s) 
`nPress 6 - To compress (zip) file 
"


Clear-Host
#Looping statement until var $selection ends
do {
        
    
    $selection = Read-Host -Prompt "`n$TitleInfo `n$quit `n`n $CommandMenu"
   
                
    # Iterating through loop
    Try {
        1
        switch ([int]$selection) {

            '1' {
                
                #Clearing Terminal
                Clear-Host

                #Phase 1 Prepping Server 
                ##Getting Server Details
                $name = Read-Host -Prompt "`nNew Machine Name"
                $ipNew = Read-Host "`nEnter new IPaddress" ;
                $gateNew = Read-Host "`nEnter new subnet" ;
                $dnsNew = Read-Host -Prompt "`nEnter DNS IPaddress"

                #Verfiy Selection
                Write-Host "`New Machine name $name with IPaddress of $ipNew, gateway $gateNew, and DNS IP of $dnsNew" -ForegroundColor Yellow
                $response = Read-Host -Prompt "`nProceed with config Y or N"
                if (($response -match "Y") -or ($response -match "YES")) {

                    #Rename Machine
                    Write-Host "`nRenaming Computer" -ForegroundColor Yellow
                    Rename-Computer -NewName $name -WarningAction SilentlyContinue
                    

                    #Configure Network 
                    Write-Host "`nConfiguring Network" -ForegroundColor Yellow
                    $netConfigure = New-NetIPAddress -InterfaceIndex $ip.InterfaceIndex -IPAddress $ipNew -PrefixLength 24 -DefaultGateway $gateNew ;
                    $netConfigure
                    #Setup DNS          
                    $dns = Set-DnsClientServerAddress -InterfaceIndex $ip.InterfaceIndex -ServerAddresses $ipdns, "8.8.8.8"
                    $dns
                }

                else {
                    Clear-Host
                    Write-host "`nRestarting" -ForegroundColor Red
                }
            }

            '2' {

                #Clearing Terminal
                Clear-Host
                
                #Step2
                #Installing Windows Update PSModule
                Write-Host "`nInstalling PSWindowUpdateModule" -ForegroundColor Yellow
                $installerA = Install-Module -Name PSWindowsUpdate -Scope CurrentUser -Verbose -WarningAction SilentlyContinue
                $installerA
                #Installing Updates for Windows
                $updateB = Install-WindowsUpdate -AcceptAll -IgnoreReboot
                $updateB
                #Step2
                #Update PowerShell Help
                Write-Host "`nUpdating Powershell Help" -ForegroundColor Yellow
                $updateHelp = Update-Help -Force -ErrorAction Ignore
                $updateHelp
            }

            '3' {
                
                #Clearing Terminal
                Clear-Host

                #PrepInfo
                Write-Host "`nConfiguring New Doman" -ForegroundColor Yellow
                $domain = Read-Host -Prompt "`nEnter Domain Name (no spaces)" 
                
                #Install AD Services
                $ADprep = Install-WindowsFeature –Name AD-Domain-Services -IncludeManagementTools
                $ADprep

                #Configure AD Specifics
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
                Write-Host "`n***Restarting machine for update, cancel within 10 secs***" -ForegroundColor Red
                Wait-Event -timeout 10
                Restart-Computer
            }

            '4' {

                #Clearing Terminal
                Clear-Host

                #Creating Top Level OU
                $newBaseOU = Read-Host "Enter Base Name"
                Write-Host "`nCreating Top Level OU" -ForegroundColor Yellow
                
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
            }

            '5' {

                #Clearing Terminal
                Clear-Host

                #Creating Compuers
                ##Define spreadsheet
                $ComputerCreationType = Read-Host -Prompt "`nPress 1 to create single computer `nPress 2 to create computer from list"
                
                #Defining Choice
                if ($ComputerCreationType -eq 1 ) { 
                    
                    $ComputerCreateSingle = Read-Host -Prompt "`nEnter new Computer Name"
                    $ComputerCreateSingle2 = New-ADComputer -Name $ComputerCreateSingle -Path "OU=$newBaseOU-Computers,OU=$newBaseOU,DC=$domain,DC=LAB"
                    $ComputerCreateSingle2    
                }

                if ($ComputerCreationType -eq 2) { 

                    $ComputerList = Read-Host "Enter File Info, enter absolut path to file (csv or txt extensions only)"

                    #Pulled Info into variable
                    $fetch = Get-Content "$ComputerList"
    
                    #Transfer variable into array
                    $comps = @($fetch)
    
                    #Add Comptuer Objects
                    foreach ($computer in $comps) { New-ADComputer -Name $computer -Path "OU=$newBaseOU-Computers,OU=$newBaseOU,DC=$domain,DC=LAB" }
                    
                }

                else {

                    Clear-Host
                    Write-host "`nRestarting" -ForegroundColor Red
                    
                }

            }

            '6' {

                Clear-Host
                $dir = Get-Location
                $FileLocation = Read-Host -prompt "`nEnter Full/Absolute Path to file, $dir"
                $NewFileLocation = Read-Host -Prompt "`nEnter Full/Absolute Path to new compressed file location"
                $CompressLevel = Read-Host -Prompt "`nChoose compression leve of new file. `nPress 1 for Fastest `nPress 2 for Optimal `nPress 3 for No Compresion"

                if ($CompressLevel -eq 1) { $CompressLevelChoice = "Fastest" }
                if ($CompressLevel -eq 2) { $CompressLevelChoice = "Optimal" }
                if ($CompressLevel -eq 3) { $CompressLevelChoice = "No Compression" }

                #Valdatiation
                Write-Host "`nCompressing file from `n$dir\$FileLocation to $dir\$NewFileLocation `nwith compression type $CompressLevel" -ForegroundColor Yellow
                $validate = Read-Host -Prompt "`nProcced with compression Y or N?"

                if ($validate -match "Yes" -or "y") { Compress-Archive -Path "$dir\$FileLocation" -DestinationPath "$dir\$NewFileLocation.zip" -CompressionLevel "$CompressLevelChoice" }
                if ($validate -match "No" -or "n") { Write-Host "Canceling" -ForegroundColor Red }

                else { Write-Host "Canceling" -ForegroundColor Red }


            }
        
        }

    }


    #Error Statement
    catch {                
        Write-Host 'Restart Powershell script' -ForegroundColor Red; 
    }
    #Error Statement 2
    if ($selection -igt "5" -and -not "X") { Write-Host "`nTry Again" -ForegroundColor Red }
                    
        
        
    #Loop Limit (case insenstive)          
} until ($selection -contains "X")



#Remove Objects
#foreach ($computer in $comps) { Remove-ADComputer -Identity $computer -Confirm:$false }






