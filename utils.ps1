<#
Utils.ps1
-Faithlin Paul
-Execute windows commands remotely using powershell remoting
#> 

param ($action,$hostname,$username="myusername")


<#   -action  [ start-website-maintenance | stop-website-maintenance | get-website-maintenance |
                stop-iis | start-iis | 
                start-service-MyService | stop-service-MyService | get-service-winrm |
                start-exec-get-service  | start-exec-cmd /c sc query             PS shell 
                start-cmd-sc query      | start-cmd-echo %PATH%      ]           cmd shell  
#>

$mydir 	= Split-Path -Parent $MyInvocation.MyCommand.Path

Function MainFunction{

$isValidIP = ($hostname -As [IPAddress]) -As [Bool]

$arraction      =  (([string]$action).ToLower()).Split("-")
$actionverb     =  $arraction[0] 
$actiontype     =  $arraction[1] 
$actionname     =  $arraction[2]


if($actionverb -eq $null  ) { throw "ERROR: No action specified" }


Switch ($actiontype) {

        "website" {

    $actionverb+"ing $actionname"
    $cmd = @"

    Import-Module WebAdministration  
    $actionverb-Website -name "$actionname"
    sleep 2
    `$websites = Get-Website 

    foreach (`$w in `$websites) {
        "Path:" + `$w.physicalPath.ToString()
        foreach (`$a in `$w.Attributes) { `$a.Name.ToString()+ ":" + `$a.Value.ToString() }
    }
    "=========================================="
    "Website Status Codes: 1=Started; 3=Stopped"
    "=========================================="

"@
        }

        "iis" {
        $cmd = @"
        iisreset /$actionverb
        iisreset /status
"@     
        }

        "service" {
        $cmd = @"
        $actionverb-Service -name "$actionname" -verbose  -ea Stop
        "=========================================="
        if("$actionverb" -ne "get") {`Get-Service -name "$actionname"  -ea Stop }        
"@ 
        }

        "exec" {
        $index = (([string]$action).ToLower()).indexof("start-exec-")
        if( $index -eq 0){  $action = ([string]$action).Substring(11)}
        else             {  $action = "echo nothing"}
        
        $cmd = $action

        }

        "cmd" {
        $index = (([string]$action).ToLower()).indexof("start-cmd-")
        if( $index -eq 0){  $action = ([string]$action).Substring(10)}
        else             {  $action = "echo nothing"}
        
        $cmd = "cmd /c " + $action

        }
}

 

#$cmd 

$cmd = $cmd + "; return `$LASTEXITCODE "
$sb =  { param ([string] $cmd ) 
        $r = "0"
        try {  
            $r = Invoke-Expression $cmd
            if($r.gettype().name -eq "Int32") {return $r.tostring()}
            else {return $r }
        } 
        catch  [Exception] { return  $_.Exception.Message + " -1"  }
}
 
if($cmd.tolower().indexof("schtasks") -ne -1 ) { $ErrorActionPreference = "SilentlyContinue" } 



if($isValidIP ){
	
    if($global:creds_username -ne $null)	{ 	$username	=	$global:creds_username	}	
	
    $global:creds = . $mydir\creds.ps1 -username $username
    if($global:creds -eq -1) { throw "ERROR: Couldn't get credentials" }

    $result = Invoke-Command -ComputerName $hostname -Credential $global:creds -ScriptBlock $sb -ArgumentList $cmd
}
else{

    $result = Invoke-Command -ComputerName $hostname -ScriptBlock $sb -ArgumentList $cmd

}



return $result

}


try{

    $result = MainFunction
    return $result
    if( $result.gettype().name -eq "String" -and $result.substring($result.length-1) -ne "0") { 
        exit -1
    }
    else{
        exit 0
    }


}
catch [Exception] {
  write-host $_.Exception.Message
  write-host "ERROR: [Utils.ps1] Exception Caught !!!!"
  return $_
  exit -1
}
