# OnAir Mega Script - Combines all tools into One
# Ron Egli - Github.com/SmugZombie
# Version 1.1.7
# Made for use with alreadydev.com

# Load INI Items
$INI = "OnAir.ini"
$ScriptVersion =                Get-Content -Path $INI | Where-Object { $_ -match 'Version=' }; $ScriptVersion = $ScriptVersion.Split('=')[1]
$ScriptName =                   Get-Content -Path $INI | Where-Object { $_ -match 'ScriptName=' }; $ScriptName = $ScriptName.Split('=')[1]
$DebugMode =                    Get-Content -Path $INI | Where-Object { $_ -match 'Debug=' }; $DebugMode = $DebugMode.Split('=')[1]
$StatusUrl =                    Get-Content -Path $INI | Where-Object { $_ -match 'Status=' }; $StatusUrl = $StatusUrl.Split('=')[1]
$OnAirUrl =                     Get-Content -Path $INI | Where-Object { $_ -match 'OnAir=' }; $OnAirUrl = $OnAirUrl.Split('=')[1]
$OnAirReloadUrl =               Get-Content -Path $INI | Where-Object { $_ -match 'OnAirReload=' }; $OnAirReloadUrl = $OnAirReloadUrl.Split('=')[1]
$PlayTrackerUrl =               Get-Content -Path $INI | Where-Object { $_ -match 'PlayTracker=' }; $PlayTrackerUrl = $PlayTrackerUrl.Split('=')[1]
$FullScreenUrl =                Get-Content -Path $INI | Where-Object { $_ -match 'FullScreen=' }; $FullScreenUrl = $FullScreenUrl.Split('=')[1]
$AutoPurgeUrl =                 Get-Content -Path $INI | Where-Object { $_ -match 'AutoPurge=' }; $AutoPurgeUrl = $AutoPurgeUrl.Split('=')[1]
$AutoPurgeConfirmUrl =          Get-Content -Path $INI | Where-Object { $_ -match 'AutoPurgeConfirm=' }; $AutoPurgeConfirmUrl = $AutoPurgeConfirmUrl.Split('=')[1]
$AutoRenameUrl =                Get-Content -Path $INI | Where-Object { $_ -match 'AutoRename=' }; $AutoRenameUrl = $AutoRenameUrl.Split('=')[1]
$AutoRenameConfirmUrl =         Get-Content -Path $INI | Where-Object { $_ -match 'AutoRenameConfirm=' }; $AutoRenameConfirmUrl = $AutoRenameConfirmUrl.Split('=')[1]
$RemoteMediaUrl =               Get-Content -Path $INI | Where-Object { $_ -match 'RemoteMedia=' }; $RemoteMediaUrl = $RemoteMediaUrl.Split('=')[1]
$RemotePlayUrl =                Get-Content -Path $INI | Where-Object { $_ -match 'RemotePlay=' }; $RemotePlayUrl = $RemotePlayUrl.Split('=')[1]
$RemotePlayDownloadUrl =        Get-Content -Path $INI | Where-Object { $_ -match 'RemotePlayDownload=' }; $RemotePlayDownloadUrl = $RemotePlayDownloadUrl.Split('=')[1]
$RemotePlayDownloadConfirmUrl = Get-Content -Path $INI | Where-Object { $_ -match 'RemotePlayDownloadConfirm=' }; $RemotePlayDownloadConfirmUrl = $RemotePlayDownloadConfirmUrl.Split('=')[1]
$RemoteGifUrl =                 Get-Content -Path $INI | Where-Object { $_ -match 'RemoteGif=' }; $RemoteGifUrl = $RemoteGifUrl.Split('=')[1]
$RemoteTalkUrl =                Get-Content -Path $INI | Where-Object { $_ -match 'RemoteTalk=' }; $RemoteTalkUrl = $RemoteTalkUrl.Split('=')[1]
$MediaDir =                     Get-Content -Path $INI | Where-Object { $_ -match 'MediaDir=' }; $MediaDir = $MediaDir.Split('=')[1]
$GifsDir =                      Get-Content -Path $INI | Where-Object { $_ -match 'GifsDir=' }; $GifsDir = $GifsDir.Split('=')[1]
$OnlineCheckUrl =               Get-Content -Path $INI | Where-Object { $_ -match 'OnlineCheckUrl=' }; $OnlineCheckUrl = $OnlineCheckUrl.Split('=')[1]
$CustomScriptUrl =              Get-Content -Path $INI | Where-Object { $_ -match 'CustomScriptUrl=' }; $CustomScriptUrl = $CustomScriptUrl.Split('=')[1]
# Change Window Title
$host.ui.RawUI.WindowTitle = "$ScriptName $ScriptVersion - [AlreadyDev]"
# Track Reloads
$reload = (Invoke-WebRequest -Uri $OnAirReloadUrl -UseBasicParsing).Content
###############################
# FUNCTIONS
###############################

function debug($message) {
    if($DebugMode -eq "True"){
        Write-Host $message
    }
}

# Auto magically removes democratically chosen for deletion files
function autoPurge {
    # Grab the latest sounds pending deletion from AD servers
    $response_AP = (Invoke-WebRequest -Uri $AutoPurgeUrl -UseBasicParsing).Content
    debug("AutoPurgeResponse: $response_AP")
    # Due to the intricacies of PS... This has to be a csv... so we parse it as such
    $pendingDeletion = $response_AP.split(",")
    # Iterate through the list (if it exists)
    $pendingDeletion | ForEach-Object {
        $orig = $_                 # Assign a default field to be used later
        $file = "$MediaDir\$_"   # Add the base path so we can rename / check if exists
        # Check if the file name contains chars
        if($orig -ne ""){
            # Check if the file exists
            if([System.IO.File]::Exists($file)){
                Write-Host "$file Exists"
                # Delete / Rename File
                Rename-Item -Path "$file" -NewName "$file.deleted"
                # Confirm Delete With AD Server
                $confirmation_AP = (Invoke-WebRequest -Uri "$AutoPurgeConfirmUrl$orig" -UseBasicParsing).Content
                # Display Confirmation back to user
                Write-Host "$orig Has been deleted"
            }else{
                Write-Host "$file Not Exists"
                # File doesn't exist, so might as well tell the server its gone... 
                $confirmation_AP = (Invoke-WebRequest -Uri "$AutoPurgeConfirmUrl$orig" -UseBasicParsing).Content
            }
        }
    }
}

function remoteFullScreen {
    # Grab the latest invocation of remote fullscreen available on the webserver at the time
    $response_FS = (Invoke-WebRequest -Uri $FullScreenUrl -UseBasicParsing).Content
    debug("RemoteFullScreenResponse: $response_FS")
    if($response_FS -ne ""){ #If response is not empty, play it
        $video = $response_FS.split("#")[0]
        $processor = $response_FS.split("#")[1]
        # Script here to play the file
        if($global:safe_mode -eq 0) {
            if($video -eq "stop"){
                remoteFullScreenStop
            }elseif($video -eq "pause"){
                remoteFullScreenpause
            }else{
                Write-Host "Now Remote Playing: $video"
                ./FullScreenYouTube.exe "$processor" "- YouTube" "chrome.exe --app=$video"
            }            
        }else{
            Write-Host "Skipping Remote FullScreen ($response_FS) - Safe Mode Enabled"
        }
    }
}

function remoteFullScreenStop {
    ./FullScreenYouTube.exe stop
    Write-Host "Stopping FullScreen Process"
}

function remoteFullScreenPause {
    ./FullScreenYouTube.exe pause
    Write-Host "Pausing/Playing FullScreen Process"
}

function remotePlay {
    # Grab the latest invocation of remote play available on the webserver at the time
    $response_RP = (Invoke-WebRequest -Uri $RemotePlayUrl -UseBasicParsing).Content
    debug("RemotePlayResponse: $response_RP")
    if($response_RP -ne ""){ #If response is not empty, play it
        # Script here to play the file
        if($global:safe_mode -eq 0) {
            if($response_RP -eq "stop"){
                remoteStop 1
            }else{
                Write-Host "Now Remote Playing: $response_RP"
                $sound = $response_RP.split(":")[0]
                ./OnAirPlayer.exe filename=$sound
            }            
        }else{
            Write-Host "Skipping Remote Play ($response_RP) - Safe Mode Enabled"
        }
    }
}

function remoteStop($force=1) {
    $ProcessActive = Get-Process OnAirPlayer -ErrorAction SilentlyContinue
    if($ProcessActive -eq $null)
    {
        # Process not running, do nothing
    }
    else
    {
        Stop-Process -name "OnAirPlayer"
        ./GifDisplay.exe filename=shh.gif
    } 

    $ProcessActive = Get-Process "voice" -ErrorAction SilentlyContinue
    if($ProcessActive -eq $null)
    {
        # Process not running, do nothing
    }
    else
    {
        Stop-Process -name "voice"
        ./GifDisplay.exe filename=shh.gif
    } 
    if($force -eq 0){
        remoteFullScreenPause
    }else{
        remoteFullScreenStop
    }
    
}

function remoteMedia {
    # Grab the latest sounds pending deletion from AD servers
    $response_RM = (Invoke-WebRequest -Uri $RemoteMediaUrl -UseBasicParsing).Content
    debug("RemoteMediaResponse: $response_RM")
    # Due to the intricacies of PS... This has to be a csv... so we parse it as such
    $pendingDeletion = $response_RM.split(",")

    # Iterate through the list (if it exists)
    $pendingDeletion | ForEach-Object {

        $file = $_                 # Assign a default field to be used later

        if($file -ne ""){
            $client = new-object System.Net.WebClient
            $client.DownloadFile("$RemotePlayDownloadUrl$file","$MediaDir\$file")
            Write-Host "Downloaded: $file"
            $confirm_RM = (Invoke-WebRequest -Uri "$RemotePlayDownloadConfirmUrl$file" -UseBasicParsing).Content
        }

    }
}

function remoteGif {
    $response_RG = (Invoke-WebRequest -Uri $RemoteGifUrl -UseBasicParsing).Content
    debug("RemoteGifResponse: $response_RG")
    If($response_RG -eq "random"){
        $gifs = Load-Gifs $GifsDir
        $gifs_random = Get-Random -Minimum 0 -Maximum ($gifs.Length)
        $gif = $gifs[$gifs_random]
        ./GifDisplay.exe filename=$gif
    }elseif($response_RG -ne ""){
        Write-Host "Displaying Gif: $response_RG"
        # Script here to play the file
        ./GifDisplay.exe filename=$response_RG
    }
}

function remoteTalk {
    #Write-Host "Checking remoteTalk"
    if($global:safe_mode -eq 0) { # If safemode not enabled
        $response_RT = (Invoke-WebRequest -Uri $RemoteTalkUrl -UseBasicParsing).Content
        debug("RemoteTalkResponse: $response_RT")
        $seed = Get-Random -Minimum 1000 -Maximum 9999
        if($response_RT -ne ""){
            Write-Host "Saying: $response_RT"
            # Script here to play the file
            #echo $response_RT | ./voice.exe -f
            Set-Content -Path C:/Temp/voice.$seed.temp -Value $response_RT
            $msbuild = "C:/Temp/voice.exe"
            $arguments = "-f -k C:/Temp/voice.$seed.temp"
            Start-Process -NoNewWindow $msbuild $arguments
        }
    }
}

function remoteRename {
    # Grab the latest sounds pending deletion from AD servers
    $response_AR = (Invoke-WebRequest -Uri $AutoRenameUrl -UseBasicParsing).Content
    debug("AutoRenameResponse: $response_AR")
    # Due to the intricacies of PS... This has to be a csv... so we parse it as such
    $pendingRename = $response_AR.split(",")
    # Iterate through the list (if it exists)
    $pendingRename | ForEach-Object {
        $orig = $_                 # Assign a default field to be used later

        $before = $_.split(":")[0]
        $after = $_.split(":")[1]

        $before_file = "$MediaDir\$before"   # Add the base path so we can rename / check if exists
        $after_file = "$MediaDir\$after"   # Add the base path so we can rename / check if exists
        # Check if the file name contains chars
        if($orig -ne ""){
            # Check if the file exists
            if([System.IO.File]::Exists($before_file)){
                Write-Host "$before Exists"
                # Delete / Rename File
                Rename-Item -Path "$before_file" -NewName "$after_file"
                # Confirm Delete With AD Server
                if([System.IO.File]::Exists($after_file)){
                    $confirmation_AR = (Invoke-WebRequest -Uri "$AutoRenameConfirmUrl$before" -UseBasicParsing).Content
                    # Display Confirmation back to user
                    Write-Host "$before Has been renamed to $after"
                }
            }else{
                Write-Host "$before Not Exists"
                # File doesn't exist, so might as well tell the server its gone... 
                $confirmation_AR = (Invoke-WebRequest -Uri "$AutoRenameConfirmUrl$before" -UseBasicParsing).Content
            }
        }
    }
}

function CheckOnAir {
    $response_OA = (Invoke-WebRequest -Uri $OnAirUrl -UseBasicParsing).Content
    debug("OnAirResponse: $response_OA")
    #echo $response
    If ($response_OA -eq $global:current_total) {
        #echo "Nothing Changed"
    }elseIf($response_OA -eq 0){
        #echo "All Calls Over"
        $global:safe_mode = 0
        $gifs = Load-Gifs $GifsDir
        $gifs_random = Get-Random -Minimum 0 -Maximum ($gifs.Length)
        $global:current_total = $response_OA
        $sound = $sounds[$global:sounds_ind]
        $gif = $gifs[$gifs_random]
        ./OnAirPlayer.exe filename=$sound
        ./GifDisplay.exe filename=$gif
        Write-Host "Last played sound: $sound"
        $webhook = (Invoke-WebRequest -Uri "$PlayTrackerUrl$sound" -UseBasicParsing).Content
        $global:sounds_ind = $global:sounds_ind + 1
        If ($global:sounds_ind -ge $sounds.Length) {
            $sounds = Load-Sounds $sounds_dir
            $global:sounds_ind = 0
        }
    }elseIf($global:current_total -eq 0 -AND $response_OA -gt $global:current_total){
        $global:current_total = $response_OA
        $global:safe_mode = 1
        remoteStop 0
        ./OnAirPlayer.exe filename=alert.wav
    }else {
        $global:current_total = $response_OA
    }
}

function Load-Sounds {
    param([string]$directory)
    if($global:sfw_mode -eq 1){
        # Exclude NSFW
        $sounds_list = Get-ChildItem -Path $directory"/*" -Include *.wav -Exclude *_NSFW* | ForEach-Object {$_.name} | Sort-Object {Get-Random}
    }else{
        # Include All
        $sounds_list = Get-ChildItem $directory -Filter "*.wav"  | ForEach-Object {$_.name} | Sort-Object {Get-Random}
    }

    return $sounds_list
}

function Load-Gifs {
    param([string]$directory)
    if($global:sfw_mode -eq 1){
        # Exclude NSFW
        $gifs_list = Get-ChildItem -Path $directory"/*" -Include *.gif -Exclude *_NSFW* | ForEach-Object {$_.name} | Sort-Object {Get-Random}
    }else{
        # Include All
        $gifs_list = Get-ChildItem $directory -Filter "*.gif"  | ForEach-Object {$_.name} | Sort-Object {Get-Random}
    }
    return $gifs_list
}

Function Set-Speaker($Volume){$wshShell = new-object -com wscript.shell;1..50 | % {$wshShell.SendKeys([char]174)};1..$Volume | % {$wshShell.SendKeys([char]175)}}

function CheckNet {
    #Write-Host "Checking"
    $response_ping = (Test-Connection -ComputerName $OnlineCheckUrl -Count 1 -Q)
    If ($response_ping -AND $global:fails -lt $global:fail_limit){
        $global:fails = 0
    }elseIf($response_ping -AND $global:fails -gt $global:fail_limit){
        $global:fails = 0
        ./GifDisplay.exe filename=/protected/signal.jpg
        ./OnAirPlayer.exe filename=/protected/backonline.wav
    }else{
        #Write-Host "Fail"
        $global:fails = $global:fails + 1
        #Write-Host $global:fails
        if( $global:fails -eq $global:fail_limit ){
            ./GifDisplay.exe filename=/protected/nosignal.gif
            ./OnAirPlayer.exe filename=/protected/networkoutage.wav
        }
    }
}

function toggleSFWMode([int]$mode) {
    $global:sfw_mode = $mode
    $global:sounds = Load-Sounds $MediaDir
}

function CheckStatus {
    $response_ST = (Invoke-WebRequest -Uri $StatusUrl -UseBasicParsing).Content
}

function CustomScript {
    $response_CS = (Invoke-WebRequest -Uri $CustomScriptUrl -UseBasicParsing).Content
    if($response_CS -ne ""){
        Write-Host "DEBUG: $response_CS"
        switch ($response_CS) {
            "jackbox"  {
                Write-Host "Launching Jackbox Games"
                $msbuild = "C:\Program Files\JackboxPartyPack1\The Jackbox Party Pack.exe"
                $arguments = ""
                Start-Process -filepath $msbuild -WorkingDirectory "C:\Program Files\JackboxPartyPack1" #$arguments
                break
            }
            default {break}
        }
    }
}


###############################
# MAIN
###############################
Write-Host "Running: $ScriptName $ScriptVersion"

debug("Debug Mode Enabled")
debug($ScriptVersion)
$global:current_total = 0
$global:safe_mode = 0
$global:sfw_mode = 1
$sounds = Load-Sounds $MediaDir
#Write-Host $sounds
$global:sounds_ind = 0
$global:fails = 0
$global:fail_limit = 3
Set-Speaker -Volume 50

while($true)
{
    CheckNet
    CheckOnAir
    remotePlay
    remoteMedia
    remoteGif
    remoteTalk
    remoteFullScreen
    autoPurge
    remoteRename
    CustomScript
    Start-Sleep -s 1
}

<#
Changelog:
1.0.7 - Added Online Checking
1.0.8 - Added Voice Support
1.0.9 - Enhanced Voice Support
1.0.10 - Added SafeMode for Voice, Added remotestop for Voice
1.0.11 - Fixed remote stop for voice
1.0.12 - Updated voice to use output/temp textfile
1.0.13 - Added ignore _NSFW files for autoplaying sounds *edit - apparently didnt work
1.1.0 - Added ability to rename files remotely both NSFW and on demand, fixed ignore _NSFW on autoplay for both gifs and audio, added user auditing to remote play
1.1.0 Todo - Add ability to remote toggle sfw_mode, rewrite how audio/gifs are loaded so can be loaded dynmically without reloading the script
1.1.1 - Added Remote FullScreen Tool
1.1.2 - Moved all (remaining) variables to config
1.1.3 - Adjusted some workings with OnAir (core) functionality
1.1.4 - Added Seed to Computron voice file to prevent repeating self on multiple overlapping requests
1.1.4 - ToDo - Create Stats script to keep track of current totals, runtime, last start
1.1.5 - Added Pause support to fullscreenyoutube.exe, Added soft stop (pause/play on new call) vs hard stop (stopallsounds)
1.1.6 - Added support for non embedded fullscreen youtube
1.1.7 - Adding Custom Script Support
#>