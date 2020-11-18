Param(
	$ServerName
    ,$DriveName
)
begin
{
  Get-ChildItem -Path "C:\ShadowCopyLogs\$ServerName`_$DriveName`_shadowCopy.log" -ErrorAction SilentlyContinue | where {$_.LastWriteTime -GT (Get-Date).AddDays(-1)} | Get-Content -ErrorAction SilentlyContinue
}



