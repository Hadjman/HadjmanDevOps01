New-SMBShare -Name "XynApps" -Path "E:\XynApps" -FullAccess "Prod\Domain Admins", "Xceedtech\Domain Admins", "myanite\grpnemoITAdmins" -ChangeAccess "myanite\grpNemoApplicationSupport" -ReadAccess "myanite\grpNemoReadOnly" -Description "Local Xynergy Agent Install Folder"

echo y|cacls "e:\xynapps" /T /g everyone:F

CD c:\Windows\Microsoft.NET\Framework\v4.0.30319\

.\installutil -u "\\FS4-MCV-APPS02.prod.xceedtech.net\ProdApps\XynCloud01\XynergyDTXAgentWinService\PS-MCV-VNA9P64\XynergyDTXAgentService.exe"

.\installutil "E:\XynApps\XynergyDTXAgentWinService\XynergyDTXAgentService.exe"

Set-Service xyncld01-XynDTXAgentService -startuptype "automatic"

$UserName = "Prod\XYNCldProcSvc"
$Password = "mstdsj&amp;!P"

$svc_Obj= Get-WmiObject Win32_Service -filter "name='xyncld01-XynDTXAgentService'"
$StopStatus = $svc_Obj.StopService() 
If ($StopStatus.ReturnValue -eq "0") 
    {Write-host "The service Stopped successfully"} 
$ChangeStatus = $svc_Obj.change($null,$null,$null,$null,$null,
                      $null, $UserName,$Password,$null,$null,$null)
If ($ChangeStatus.ReturnValue -eq "0")  
    {Write-host "User Name set successfully for the service"} 
$StartStatus = $svc_Obj.StartService() 
If ($ChangeStatus.ReturnValue -eq "0")  
    {Write-host "The service  Started successfully"}

Services.msc
