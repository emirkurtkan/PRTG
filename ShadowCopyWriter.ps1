Param(
	$ServerName,
    $DriveLetter
)
Begin
{	$script:CurrentErrorActionPreference = $ErrorActionPreference
    $ShadowCopyStats = @()

	Function GetShadowCopyStats
	{	Param($Computer)

try
{
    
        Import-Module @("Microsoft.PowerShell.Management","PSDiagnostics")
		$WMITarget = "$Computer"
		Get-WmiObject -Class "Win32_ComputerSystem" -Property "Name" -ComputerName $WMITarget | out-null
		If ($? -eq $False)
		{	$bWMIConnection = $False
			$WMITarget = "$Computer."
			Get-WmiObject -Class "Win32_ComputerSystem" -Property "Name" -ComputerName $WMITarget | out-null
			If($? -eq $False){$bWMIConnection = $False}Else{$bWMIConnection = $True}
		}

            $xml = '<prtg>'
                $Volumes = gwmi Win32_Volume -Property SystemName,DriveLetter,DeviceID -Filter "DriveType=3" -ComputerName $WMITarget |
			        Select SystemName,@{n="DriveLetter";e={$_.DriveLetter.ToUpper()}},DeviceID | Sort DriveLetter

                $ShadowCopies = gwmi Win32_ShadowCopy -Property VolumeName,InstallDate,Count -ComputerName $WMITarget |
				        Select VolumeName,InstallDate,Count,
				        @{n="CreationDate";e={$_.ConvertToDateTime($_.InstallDate)}}

} 
catch [Exception]
{
    #Write-Warning $_.Exception|format-list -force
$Error[0].Exception.StackTrace
$Error[0].Exception.InnerException.StackTrace
$Error[0].StackTrace
write-error "Unable to connect Server"
}

		        If($Volumes)
		        {
                    ForEach($Volume in $Volumes)
		            {
                        If($Volume.DriveLetter -eq $DriveLetter) {

                    
				            $VolumeShares = $VolumeShadowStorage = $DiffVolume = $VolumeShadowCopies = $Null
				            $VolumeShadowCopies = $ShadowCopies | ?{$_.VolumeName -eq $Volume.DeviceID} | Sort InstallDate

				            If($VolumeShadowCopies)
				            {
                                $xml += '<result><channel>ShadowCopyCount</channel><value>' + (($VolumeShadowCopies | Measure-Object -Property Count -Sum).Sum) + '</value></result>'
                                
                                $AgeOldest = New-TimeSpan -Start (($VolumeShadowCopies | Select -First 1).CreationDate) -End (Get-Date) 
                                $AgeLatest = New-TimeSpan -Start (($VolumeShadowCopies | Select -Last 1).CreationDate) -End (Get-Date) 
                        
                                $xml += '<result><channel>OldestShadowCopy</channel><value>' + [math]::Round($AgeOldest.TotalHours,0) + '</value><unit>TimeHours</unit></result>'
                                $xml += '<result><channel>LatestShadowCopy</channel><value>' + [math]::Round($AgeLatest.TotalHours,0) + '</value><unit>TimeHours</unit></result>'
				            }Else{
                                $xml += '<result><channel>ShadowCopyCount</channel><value>0</value></result>'
                                $xml += '<result><channel>OldestShadowCopy</channel><value>0</value><unit>TimeHours</unit></result>'
                                $xml += '<result><channel>LatestShadowCopy</channel><value>0</value><unit>Date</unit></result>'
                          
                            }
				            If($VolumeShadowStorage -Or $ShowAllVolumes){$Output += $Object}
                        }
		            }
                }
            $xml += '</prtg>'

            $DriveName = $DriveLetter -replace ":",""
            WriteXmlToScreen $xml | Out-File C:\ShadowCopyLogs\$ServerName`_$DriveName`_shadowCopy.log
            
        
	}


    Function WriteXmlToScreen ([xml]$xml)
    {
        $StringWriter = New-Object System.IO.StringWriter;
        $XmlWriter = New-Object System.Xml.XmlTextWriter $StringWriter;
        $XmlWriter.Formatting = "indented";
        $xml.WriteTo($XmlWriter);
        $XmlWriter.Flush();
        $StringWriter.Flush();
            $host.UI.RawUI.BufferSize = new-object System.Management.Automation.Host.Size(550,7000)

        Write-Output $StringWriter.ToString();
    }
}
Process
{	If($ServerName)
	{ForEach($Server in $ServerName){$ShadowCopyStats += GetShadowCopyStats $Server}}
	Else
	{$ShadowCopyStats += GetShadowCopyStats $_}
}
End
{	$ErrorActionPreference = $script:CurrentErrorActionPreference
	$ShadowCopyStats
}