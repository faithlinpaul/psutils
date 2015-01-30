PSUtils:
==================
Remote execute cmd or ps shell commands using winrm.

Usage:  
------

powershell -ExecutionPolicy ByPass -Command .\utils.ps1 -action ***"start-website-Default Website"*** -hostname mytargetserver.mydomain.com  

powershell -ExecutionPolicy ByPass -Command .\utils.ps1 -action ***"start-exec-get-service winrm"*** -hostname mytargetserver.mydomain.com  

powershell -ExecutionPolicy ByPass -Command .\utils.ps1 -action ***"start-cmd-iisreset /restart"*** -hostname mytargetserver.mydomain.com  


Possible actions:  
-----------------
  
                1. start-website-maintenance | stop-website-maintenance | get-website-maintenance |                 stop-iis | start-iis                                       *PS C:\>get-website name*     
                
                2. start-service-MyService | stop-service-MyService | get-service-winrm     *PS C:\>start-service winrm*    
                
                3. start-exec-get-service  | start-exec-cmd /c sc query                       *PS C:\> #powershell*  
                
                4. start-cmd-sc query      | start-cmd-echo %PATH%                           *C:\>    #cmd*  
                
                5. cscript c:\windows\system32\iisweb.vbs /start "WebsiteName"                     *IIS6 - start website*  
                
                6. cscript c:\windows\system32\iisweb.vbs /stop "WebsiteName"                      *IIS6 - stop website*  
                
                7. cscript c:\windows\system32\iisweb.vbs /query                                   *IIS6 - list websites*  
                

