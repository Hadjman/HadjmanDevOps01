#Install .Net 4.5
#Server 2016 includes .Net 4.6/4.5.x  on Windows 2016 Server

#Install IIS Role
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

#Generate Certificate
$DNSName = "consultmanager" #Can add FQDN if needed
$SSLCert = New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\my -DnsName $DNSName

#Remove Default Site
Remove-Website -Name "Default Web Site"

#Create Application Pools
$AppPools = @(
    ('cartapi'),
    ('mobile'),
    ('orderintake'),
    ('survey'),
    ('surveyapi')
)

foreach ($AppPool in $AppPools) {
    New-WebAppPool -Name $AppPool
}

#Create Web Sites
$WebSites = @(
    ('cartapi', 'cartapi', 'D:\SOC\wwwrootcartapi', 'cart-api.qa.socccc.com'),
    ('mobile', 'mobile', 'D:\SOC\wwwrootmobile', 'mobile.qa.socccc.com'),
    ('orderintake', 'orderintake', 'D:\SOC\wwwrootorderintake', 'intake.qa.socccc.com'),
    ('survey', 'survey', 'D:\SOC\wwwrootsurvey', 'survey.qa.socccc.com'),
    ('surveyapi', 'surveyapi', 'D:\SOC\wwwrootsurveyapi', 'survey-api.qa.socccc.com')
)

foreach ($WebSite in $WebSites) {
    $SiteName = $WebSite[0]
    $App = $WebSite[1]
    $Path = $WebSite[2]
    $HostHeader = $WebSite[3]
    New-Item -ItemType Directory -Force -Path $Path
    New-WebSite -Name $SiteName -physicalPath $Path -ApplicationPool $App
    New-WebBinding -Name $SiteName -Protocol https -IPAddress '*' -HostHeader $HostHeader -Port 443
    Get-WebBinding -Port 80 -Name $SiteName | Remove-WebBinding
    $binding = Get-WebBinding -Name $SiteName -Protocol "https"
    $binding.AddSslCertificate($SSLCert.GetCertHashString(), "my")
    Start-WebSite $SiteName
    #---- uncomment next three lines for testing ----
    #Copy-Item -Path "C:\inetpub\wwwroot\iisstart.htm" -Destination $Path\iisstart.htm
    #Copy-Item -Path "C:\inetpub\wwwroot\iisstart.png" -Destination $Path\iisstart.png
    #Add-Content C:\Windows\System32\drivers\etc\hosts "`n 127.0.0.1 $HostHeader"
}


#Create applications
$WebApps = @(
    ('device', 'mobile', 'D:\SOC\wwwrootmobile\wwwrootdevicemobwebapi', 'mobile'),
    ('physician', 'mobile', 'D:\SOC\wwwrootmobile\wwwrootphymob.webapi', 'mobile'),
    ('orderintakeapi', 'orderintake', 'D:\SOC\wwwrootorderintake\api', 'orderintake')
)

foreach ($WebApp in $WebApps) {
    $AppName = $WebApp[0]
    $SiteName = $WebApp[1]
    $Path = $WebApp[2]
    $AppPool = $WebApp[3]
    New-Item -ItemType Directory -Force -Path $Path
    New-WebApplication -Site $SiteName -Name $AppName -physicalPath $Path -ApplicationPool $AppPool
}
