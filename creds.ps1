<#
    Faithlin Paul
    1.Loads $global:creds with the credentials for requested username
    2.Also can be used to reuse import/export functions in other scripts by dot sourcing as below
           . $path\creds.ps1
#>

param($username)

$mydir 	= Split-Path -Parent $MyInvocation.MyCommand.Path


function Import-PSCredential {
        param ( $Path = "credentials.enc.xml" )
 
        # Import credential file
        $import = Import-Clixml $Path
       
        # Test for valid import
        if ( $import.PSObject.TypeNames -notcontains 'Deserialized.ExportedPSCredential' ) {
                Throw "Input is not a valid ExportedPSCredential object, exiting."
        }
        $Username = $import.Username
       
        # Decrypt the password and store as a SecureString object for safekeeping
        $SecurePass = $import.EncryptedPassword | ConvertTo-SecureString
       
        # Build the new credential object
        $Credential = New-Object System.Management.Automation.PSCredential $Username, $SecurePass
        return $Credential
}


function Export-PSCredential {
        param ( $Credential = (Get-Credential), $Path = "credentials.enc.xml" )
       
        # Test for valid credential object
        if ( !$Credential -or ( $Credential -isnot [system.Management.Automation.PSCredential] ) ) {
                Throw "You must specify a credential object to export to disk."
        }
       
        # Create temporary object to be serialized to disk
        $export = "" | Select-Object Username, EncryptedPassword
       
        # Give object a type name which can be identified later
        $export.PSObject.TypeNames.Insert(0,"ExportedPSCredential")
       
        $export.Username = $Credential.Username
 
        # Encrypt SecureString password using Data Protection API
        # Only the current user account can decrypt this cipher
        $export.EncryptedPassword = $Credential.Password | ConvertFrom-SecureString
 
        # Export using the Export-Clixml cmdlet
        $export | Export-Clixml $Path
        Write-Host -foregroundcolor Green "Credentials saved to: " -noNewLine
 
        # Return FileInfo object referring to saved credentials
        Get-Item $Path
}

Function MainFunction{

    $credsPath = "$mydir\creds\creds-$env:COMPUTERNAME-$username.xml"
 
    if(Test-Path $credsPath) { $global:creds = Import-PSCredential $credsPath ; return $global:creds }
    else { 

$message = @"
                "ERROR: Credentials file doesnot exist: $credsPath"
                "1.Please export credentials for $env:COMPUTERNAME"
                "2.Or change buildagent to the one we have creds available at $mydir\creds 
"@
                 $message
                 return -1
                 exit -1
    }
}

if($username -ne $null){

    return MainFunction
}
else { return $null}
