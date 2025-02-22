First of all, I realize that this page is not good in grammar and order, I will update it soon.

This PowerShell script creates a backup folder under The Parasites game root folder.
Checks modified date for save files and creates back-up then takes a screenshot.

I've made this tool to make regular backups of The Parasites game save file.
Powershell scripts normally wants special permission to run so i've compiled it using Markus Scholtes's PS2EXE.
If you want you can download my script and compile it using PS2EXE.
You can get PS2EXE from Markus Scholtes's github page https://github.com/MScholtes/PS2EXE
You can check Virustotal scan results for TP_Save_Backup_Tool.zip below
https://www.virustotal.com/gui/url/ce39f99a22ad301b806adbbf6ab8a19b9ecae34884d079395609b1db7cd758db/details
How to use :
Download TP_Save_Backup_Tool.zip or .ps1 file.
Copy ps1 file or extract zip file to The Parasites game's root folder where TheParasites.exe is.
run TP_Save_Backup_Tool.exe it will run TheParasites.exe , create "SaveBackups" folder under Parasites game's root folder and make first backup.
If you start TP_Save_Backup_Tool when game is already running it wont try o run game again.
Tool will check every 30 second to if your Save file has changed, if it detects a change it will wait 5 second to the game finish writing save file, than tool will take a screenshot and backup save files with file change date as as name. Than it will sleep 30secs again.
When you exit the game or if it crashes TP_Save_Backup_Tool will close it self. Tool may close late because it checks if its in same interval as checking if save file has changed.

For Powershell you need to run Set-ExecutionPolicy: with admin rights.

  Set-ExecutionPolicy Restricted <-- Will not allow any powershell scripts to run.  Only individual commands may be run.
  Set-ExecutionPolicy AllSigned <-- Will allow signed powershell scripts to run.
  Set-ExecutionPolicy RemoteSigned <-- Allows unsigned local script and signed remote powershell scripts to run.
  Set-ExecutionPolicy Unrestricted <-- Will allow unsigned powershell scripts to run.  Warns before running downloaded scripts.
  Set-ExecutionPolicy Bypass <-- Nothing is blocked and there are no warnings or prompts.

Performance : 
I have AMD Ryzen 5 5600 6-Core Processor, PowerColor RX 6700 XT Red Devil 12GB gpu, 32Gb 3600Mhz ram, 512gb gen4 Kingston Nv2 ssd as bootdrive and 1Tb KIOXIA-EXCERIA G2 Gen3 SSD as gamedrive.
Tools resource usage in my is:
When Sleep ~40Mb Ram %0 Cpu
When Checking if there had been a change ~40Mb Ram ~%0.5 Cpu
When taking screenshot an backing up ~80Mb Ram ~%2 Cpu
I haven't observed a remarkable FPS drop.

How it works 
* get current folder
* check if save folder exist
* check if BackupFolder folder exist 
* create BackupFolder folder if it doesn't exist 
* check if game is running
* run game if its not running
* wait 20secs for game to start
* check if the last save backed up
* if its not take screenshot and backup last save
* ---loop point---
* wait 30 seconds
* Check Save file's last modified date
* if its new wait 5 secs to give time to game to finish writing save file. take a screenshot and backup save
* check if game is running, if not exit.
* return to wait 30 seconds.
*and repeat

Have Fun!! Happy Surviving !!

Author: Barbatos Lupus Rex | License: CC0

Scrips from other authors used:
save-screenshot Author: Peter Mortensen url: https://stackoverflow.com/questions/2969321/how-can-i-do-a-screen-capture-in-windows-powershell
new-zipfile  Author: Markus Fleschutz url: https://github.com/fleschutz/PowerShell/blob/main/docs/new-zipfile.md
Retrieve the script/executable path Author: JacquesFS url: https://github.com/MScholtes/PS2EXE
