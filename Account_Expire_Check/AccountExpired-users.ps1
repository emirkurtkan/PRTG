Import-Module ActiveDirectory


$server=Search-ADAccount -AccountExpired -UsersOnly -Server SERVERNAME.domain.local | select SamAccountName
if ($server.count -eq $null -and $server -eq $null){
    $a=0
}
Elseif ($server.count -eq $null -and $server -ne $null){
    $a=1
}
Else
{
    $a=@($server.count)
    
}
Write-Host "<prtg>"
Write-Host "<result>" 
"<channel>Locked Out Users</channel>" 
    
"<value>"+ $a +"</value>" 
"</result>"
"<text>" + (($server | select SamAccountName | ConvertTo-Csv -NoTypeInformation | select -skip 1 ) -join ", ").replace("""","") + "</text>"
Write-Host "</prtg>"