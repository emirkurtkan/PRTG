# PRTG
PRTG Shadow Copy Status

![screenshot_21](https://user-images.githubusercontent.com/74365711/99497969-be99b400-2987-11eb-99ab-543d3c0fd423.png)

In this article we will monitor Windows Shadow Copy via PRTG.
Defaultly there is no sensor in PRTG for Shadow Copy Status. We can monitor Shadow Copy service name as “Volume Shadow Copy”.
What if service is working fine but Shadow Copies are not taken. We have to check last shadow copy taken time.
I created two custom scripts for this process and its working fine.
Firstly, PRTG is not able to run a 64 bit powershell commands by default. We have to use a custom exe for this.
I wrote a powershell script for checking target server’s shadow copy status. This scripts is also creating a log file on the PRTG probe server. This log file creating as a xml result.
We have to create a task scheduler on PRTG probe server for this script. You can use this command while creating task Schedule on PRTG Probe.
This script should work as a local admin user on target server.
-file C:\ShadowCopyLogs\Scripts\ShadowCopyWriter.ps1 -Servername TARGER_SERVER_FQDN -DriveLetter E:   

![image](https://user-images.githubusercontent.com/74365711/99498248-2f40d080-2988-11eb-9e86-4b949a894f88.png)

After this, script will automatically create a result file in “C:\ShadowCopyLogs\”.
Result file names like SERVERNAME`_DRIVENAME_shadowCopy.log
Now, we got this important data on the PRTG probe server. 

![image](https://user-images.githubusercontent.com/74365711/99498286-4384cd80-2988-11eb-987e-e71389f73a80.png)

After that, We are creating a sensor on the Target Server name as EXE/Script Advanced.
We will use Shadow Copy Status.ps1 for checking exist result logs via PRTG. 
This script is checking last edit time for result logs. So If something happens to Task Scheduler, Script will know it via Last Edit time and Script will not able to read old data. So we will get an error. 

Example : -ServerName SERVERFQDN -DriveName E
