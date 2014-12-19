psutils
=======
powershell script utils.ps1 to remote execute using PS remoting

Usage:


powershell -ExecutionPolicy ByPass -Command .\utils.ps1 -action "start-website-Default Website" -hostname mytargetserver.mydomain.com
powershell -ExecutionPolicy ByPass -Command .\utils.ps1 -action "start-exec-get-service winrm" -hostname mytargetserver.mydomain.com
powershell -ExecutionPolicy ByPass -Command .\utils.ps1 -action "start-cmd-iisreset /restart" -hostname mytargetserver.mydomain.com

Possible actions:
<#   -action  [ start-website-maintenance | stop-website-maintenance | get-website-maintenance |
                stop-iis | start-iis | 
                start-service-MyService | stop-service-MyService | get-service-winrm |
                start-exec-get-service  | start-exec-cmd /c sc query       PS shell 
                start-cmd-sc query      | start-cmd-echo %PATH%      ]           cmd shell  
                cscript c:\windows\system32\iisweb.vbs /start "WebsiteName"
                cscript c:\windows\system32\iisweb.vbs /stop "WebsiteName"
                cscript c:\windows\system32\iisweb.vbs /query 

#>
