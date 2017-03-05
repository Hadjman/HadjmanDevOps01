<#*****************************************************************************************************
*    Script to Configure IIS websites :: version 1.0
*    Developed By Kalith Guruge of Sri Lanka on 19/2/2017
*
*    This script only handle the given set of requirments and will not handle anything beyond its scope.

*    Running the script is at your own risk.Developer holds no responsibility for any kind of data loss.
*
*******************************************************************************************************#>
Write-Host "Installing web erver [IIS] features...."
Install-WindowsFeature -Name web-server -IncludeManagementTools -IncludeAllSubFeature -Verbose

Write-Host "Removing Directory Browsing...."
Remove-WindowsFeature -Name Web-Dir-Browsing -Verbose

Write-Host "Installing .NET framework 4.5 features...."
Install-WindowsFeature -Name NET-Framework-45-Features -IncludeAllSubFeature -IncludeManagementTools -Verbose

Write-Host "Removing Default Web Site...."
Get-Website -Name "Default Web Site" |Remove-Website -Verbose

$Cfriendlyname="consultmanager"

Write-Host "`nCreating a self signed certificate for $Cfriendlyname and binding it to for all IPs for port 443."
$Cert=New-SelfSignedCertificate -DnsName $Cfriendlyname -CertStoreLocation cert:Localmachine\My
Set-Location IIS:\SslBindings
$Cert|New-Item 0.0.0.0!443


$Ppath="D:\SOC\wwwroot"#original


$Hostpath=".qa.socccc.com"
$port=443

$apppools="cartapi","mobile","orderintake","survey","surveyapi"

Write-Host "Creating App pools and Web sites..."
foreach($pool in $apppools)
{
    New-WebAppPool -Name $pool
    
    if($pool -eq "cartapi") { $hostheader= "cart-api"+$Hostpath}
    elseif($pool -eq "surveyapi") { $hostheader= "survey-api"+$Hostpath} 
    elseif($pool -eq "orderintake") { $hostheader= "intake"+$Hostpath} 
    else {$hostheader = $pool+$Hostpath}

    
    if(!(Test-Path -Path ($Ppath+$pool)))
    {
        New-Item -ItemType Directory -Path $Ppath$pool
        }

        New-Website -Name $pool -Port $port -PhysicalPath "$Ppath$pool" -ApplicationPool $pool -HostHeader $hostheader -Ssl


    }


Write-Host "Creating applications...."

$devicepath=$Ppath+'mobile\wwwrootdevicemobwebapi'
$physicianpath=$Ppath+'mobile\wwwrootphymob.webapi'
$odrintkapipath=$Ppath+"orderintake\api"


if(!(Test-Path -Path $devicepath))
    {
        New-Item -ItemType Directory -Path $devicepath
        }

if(!(Test-Path -Path $physicianpath ))
    {
        New-Item -ItemType Directory -Path $physicianpath
        }

if(!(Test-Path -Path $odrintkapipath))
    {
        New-Item -ItemType Directory -Path $odrintkapipath
        }

New-WebApplication -Site "mobile" -Name "Device" -PhysicalPath $devicepath -ApplicationPool "mobile"

New-WebApplication -Site "mobile" -Name "physician" -PhysicalPath $physicianpath -ApplicationPool "mobile"

New-WebApplication -Site "orderintake" -Name "orderintakeapi" -PhysicalPath $odrintkapipath -ApplicationPool "orderintake"