#server info ( Change this with your Active Directory Server )
$DomainController = SERVERNAME.domain.local

#times
$Daysactive = 7
$Daysinactive = 21

# Logged in within 7 days, no "stock" comment in description;
$activetime = (Get-Date).Adddays(-($Daysactive))
#Not logged in within 21 days;
$inactivetime = (Get-Date).Adddays(-($Daysinactive))


# Logged in within 7 days, no "stock" comment in description, Devices in "Computers" organizational unit;
$ActiveComputers = Get-ADComputer -Filter {LastLogonTimeStamp -gt $activetime} -ResultPageSize 2000 -resultSetSize $null -Properties Name, Lastlogondate, Description -Server $DomainController -SearchBase "OU=Computers,DC=domain,DC=local" | where {$_.Description -notlike "*stock*"} | Measure-Object | select -ExpandProperty Count
#Not logged in within 21 days, Devices in "Computers" organizational unit;
$InactiveComputers=Get-ADComputer -Filter {LastLogonTimeStamp -lt $inactivetime} -ResultPageSize 2000 -resultSetSize $null -Properties Name, Lastlogondate, Description -Server $DomainController -SearchBase "OU=Computers,DC=domain,DC=local" | where {$_.Description -notlike "*stock*"} | Measure-Object | select -ExpandProperty Count


$PRTG="
<prtg>
  <result>
    <channel>Active Computers</channel>
    <value>$ActiveComputers</value>
  </result>
  <result>
    <channel>Inactive Computers</channel>
    <value>$InactiveComputers</value>
  </result>
</prtg>
"

$PRTG
