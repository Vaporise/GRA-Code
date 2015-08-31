#$packages = @("Junos Pulse", "RSA SecurID Software Token with Automation")
#foreach($package in $packages){
 # $app = Get-WmiObject -Class Win32_Product | Where-Object {
 #   $_.Name -match "$package"
  #}
  #$app.Uninstall()
#}



function UninstallSearch($x)
{
    #Searching registry for GRAv6 Installation
    $Results = Get-ChildItem $x -Recurse -ErrorAction SilentlyContinue | foreach {gp ($_.pspath)}
    $Results | where {$_.publisher -like "*Juniper Networks*" -or $_.publisher -like "*RSA*" -and $_.displayname -like "*Junos*" -or $_.displayname -like "*RSA*" -or $_.displayname -like "*Juniper Networks*"}  | foreach {

    UninstallApplication($_)
    }
} 

function UninstallApplication ($x)
{
    #Execute uninstall-command
    $uninstallargs = "/X "+$x.pschildname+" /passive /norestart"
    start-process msiexec.exe -args $uninstallargs -wait

    #If uninstall should fail and key still exists, remove the registry entry by force
    if ((test-path $x.pspath) -like "true") 
    {
        Write-Output ":-- Uninstall registry key is still present, cleaning up..."
        Write-Output ":-- Cleaning up:" $x.pspath

        remove-item $x.pspath -force -recurse
    }
} 

   

function RunProcess($executable, $arguments)
{
    Start-Process $executable $arguments -Wait -WindowStyle Hidden
    Write-Host "Process execution has completed"

}   



$RegPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" 

UninstallSearch($RegPath) 

$RegPath2 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

UninstallSearch($RegPath2)

