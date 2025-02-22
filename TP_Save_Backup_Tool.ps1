﻿<##
.SYNOPSIS
The Parasites game save backup tool.	

.DESCRIPTION
This PowerShell script creates a backup folder under The Parasites game root folder.
Checks modified date for save files and creates back-up then takes a screenshot.

.LINK
https://github.com/dante-35/TP_Save_Backup_Tool/

.NOTES
Author: Barbatos Lupus Rex | License: CC0

Scrips from other authors used:
save-screenshot Author: Peter Mortensen url: https://stackoverflow.com/questions/2969321/how-can-i-do-a-screen-capture-in-windows-powershell
new-zipfile  Author: Markus Fleschutz url: https://github.com/fleschutz/PowerShell/blob/main/docs/new-zipfile.md
Retrieve the script/executable path Author: JacquesFS url: https://github.com/MScholtes/PS2EXE
##>


# Options

[boolean]$RunGame = $true # to run game when this scrip/application start set it $true, otherwise $false
[int32]$RunWait = 30 # Wait time in second for game to start. you can decrease this value according to your pc specs.
[boolean]$CloseSelf = $true # to close his scrip/application after exiting game or when game crashes set it $true, otherwise $false. Checks if the game occurs at interval.
[boolean]$TakeScreenshot = $true # to take a screen shot of the game after each backup set it $true, otherwise $false . If not backed-up savegame exist, that save will be backed-up but screenshot may not be accurate.
[string]$CheckInterval = 30 # Checking interval in seconds of the save file has changed and if game is running.
[string]$GameExe = "TheParasites.exe"
[string]$BackupFolder = "" # If blank creates "SaveBackups" folder inside game folder.Entered path must exists!!
[string]$SaveFolder = "" # Leave blank for default save folder. C:\Users\<Username>\AppData\Local\TheParasites\Saved\SaveGames
[string]$SaveFile = "SaveServer\Player.sav" # file to check for changes. if some reason your game changes different file you can change.

Function CheckSaveFolder {
    if ("$SaveFolder" -eq "") {
        $Path = [Environment]::GetFolderPath('LocalApplicationData')
        $SaveFolder = "$Path\TheParasites\Saved\SaveGames" 
        #if (-not(Test-Path "$Path\TheParasites\Saved\SaveGames" -pathType container)) { throw "TheParasites\Saved\SaveGames folder at $Path doesn't exist (yet)" }
        $Result = Check_folder $SaveFolder
        if ("$Result" -eq "")  { throw "$SaveFolder Folder doesnt Exist. You must have Gamesave file."}
    } else {
        $Result = Check_folder $SaveFolder
        if ("$Result" -eq "") { throw "$SaveFolder Folder doesnt Exist. You must have Gamesave file."}
    }
    Write-Host " ☑ SaveFolder -- $SaveFolder"
    return $SaveFolder
}

Function Check_folder { param([string]$FolderPath)
     if (-not(Test-Path "$FolderPath" -pathType container)) { 
     $FolderPath = ""
     }
     return $FolderPath
}

Function CheckGame {
    return get-process | ?{$_.path -eq "$CurFolder\$GameExe"}
}

Function GetSaveDate {
    return (Get-Item "$SaveFolder\$SaveFile").LastWriteTime
}

Function CheckSaveFile {param([string]$FileToCheck)
    return Test-Path $FileToCheck -PathType Leaf
}

Function ZipSaveFolder {
    $StopWatch = [system.diagnostics.stopwatch]::startNew()
	compress-archive -path $SaveFolder -destinationPath "$BackupName.zip"
	[int]$Elapsed = $StopWatch.Elapsed.TotalSeconds
	Write-Host " ☑ created zip file $("$BackupName.zip").zip in $Elapsed sec"
}

function MakeBackup {
    if ($TakeScreenshot){TakeSS}
    ZipSaveFolder
}

function TakeSS
{
    param(
    [Switch]$OfWindow
    )

     
    begin {
        Add-Type -AssemblyName System.Drawing
        $jpegCodec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
            Where-Object { $_.FormatDescription -eq "JPEG" }
    }
    process {
	Add-Type -Assembly System.Windows.Forms
        Start-Sleep -Milliseconds 250
        if ($OfWindow) {
            [Windows.Forms.Sendkeys]::SendWait("%{PrtSc}")
        } else {
            [Windows.Forms.Sendkeys]::SendWait("{PrtSc}")
        }
        Start-Sleep -Milliseconds 250
        $bitmap = [Windows.Forms.Clipboard]::GetImage()
        $ep = New-Object Drawing.Imaging.EncoderParameters
        $ep.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]100)
        $screenCapturePathBase = "$BackupName"
        $c = 0
        while (Test-Path "${screenCapturePathBase}${c}.jpg") {
            $c++
        }
        $bitmap.Save("${screenCapturePathBase}${c}.jpg", $jpegCodec, $ep)
        Write-Host " ☑ Screenshot Taken -- ${screenCapturePathBase}${c}.jpg"
    }
}

try {
    #get current folder
        if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript")
    { # Powershell script
	    $CurFolder = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
    }
    else
    { # PS2EXE compiled script
	    $CurFolder = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
    }
    Write-Host " ☑ Running folder -- $CurFolder"
    
    
    #check if save folder exist 
    $SaveFolder = CheckSaveFolder

    #check if BackupFolder folder exist 
    if ("$BackupFolder" -eq "") {
    $BackupFolder = Check_folder "$CurFolder\SaveBackups" 
        if ("$BackupFolder" -eq "") {
        new-item "$CurFolder\SaveBackups" -type directory
        $BackupFolder = Check_folder "$CurFolder\SaveBackups"
        if ("$BackupFolder" -eq "") {throw "Can not crete folder $CurFolder\SaveBackups . Please check if you have write premissons to folder!"}
        }
    } else {
    $Result = Check_folder $BackupFolder
    if ("$Result" -eq "") { "Res $Result --- $BackupFolder Folder doesnt Exist"}
    }
    Write-Host " ☑ BackupFolder -- $BackupFolder"

    #before start check if game is running
    if (CheckGame){
    Write-Host " ☑ $CurFolder\$GameExe is running"
    } else {
    # run game if its set allowed
    Write-Host " ☑ $CurFolder\$GameExe is not running"
        if($RunGame)
        {
        Write-Host " ☑ starting $CurFolder\$GameExe"
        Start-Process -FilePath "$CurFolder\$GameExe"
        Start-Sleep -Seconds $RunWait
        #check if game has started
            if(-not(CheckGame)){throw "cannot start $CurFolder\$GameExe exiting"}
        }
    }
    
    #check if the last save backed up
    $LastSaveTime = GetSaveDate
    Write-Host " ☑ LastSaveTime -- $LastSaveTime"

    $BackupName = "$BackupFolder\" + ($LastSaveTime.ToString("yy-MM-dd_HH-mm-ss"))
    Write-Host " ☑ BackupName -- $BackupName"
    if (-not (CheckSaveFile ($BackupName +".zip"))) {MakeBackup}
    
    [boolean]$Loop = $true
    do {
        Start-Sleep -Seconds $CheckInterval
         $NewSaveTime = GetSaveDate
         if ($NewSaveTime -gt $LastSaveTime) {
            $LastSaveTime = $NewSaveTime
            $BackupName = "$BackupFolder\" + ($LastSaveTime.ToString("yy-MM-dd_HH-mm-ss"))
            Write-Host " ☑ New SaveFile Found, modified date : $LastSaveTime"
            #Give time to game to finish writig save file
            Start-Sleep -Seconds 5
            if (-not (CheckSaveFile ($BackupName +".zip"))) {MakeBackup}
         }
        if ($CloseSelf) {
            if (-not (CheckGame)){
            Write-Host " ☑ Game is not running. Exiting..."
            $Loop = $false
            }
        }
    } while ($Loop)
    
	exit 0 # success
} catch {
	"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
}
