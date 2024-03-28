Write-Host "Welcome to Abuzzcar's XboxMediaUSBMedia Creation Script" -ForegroundColor Yellow
Write-Host "The current disks will be displayed, please wait a moment." -ForegroundColor Red

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "Please run this script as an Administrator!"
    $(Write-Host "Press Any Key to exit." -ForegroundColor Green -NoNewLine; Read-Host)
    exit
}

Write-Host "!--------------------------------------------------------------------!" -ForegroundColor Green
get-disk
Write-Host
Write-Host "!--------------------------------------------------------------------!" -ForegroundColor Green

Write-Host
$DriveNumber = $(Write-Host "Please input a drive Number to be formatted, CANNOT be disk number 0:" -ForegroundColor Red -NoNewLine; Read-Host)
Write-Host

#Only formats if it is NOT 0
IF ($DriveNumber -ne 0){
    Write-Host ("Attempting to format:" + $DriveNumber )
    
    # Wipes content of the selected disk
    clear-disk -number $DriveNumber -removedata
    
    #creates a new partition and allocates it to maximum size, then formats into NTFS with the Label of XboxMediaUSBDrive
    new-partition -disknumber $DriveNumber -usemaximumsize | format-volume -filesystem NTFS -newfilesystemlabel XboxMediaUSBDrive
    get-partition -disknumber $DriveNumber | set-partition -newdriveletter X

    [bool] $hasNewDriveLetter = $false
    $driveLetters = @('D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z')

    foreach ($driveLetter in $driveLetters) {
    # Check if the drive exists
        if (!(Test-Path -Path "$driveLetter`:\\")) {
        # If the drive doesn't exist, save and write as new partition disk letter
        $firstNonExistingDriveLetter = $driveLetter 
        Write-Host $firstNonExistingDriveLetter "isn't populated, therefore this is the new drive letter for the XboxMediaUSBDrive" -ForegroundColor Cyan
        get-partition -disknumber $DriveNumber | set-partition -newdriveletter $firstNonExistingDriveLetter
        break
        }
    }
}else{
    Write-Host ("Cannot Write to the drive where the Windows Installation is present")
    break
}

$consoles = "Atari 5200", "Nintendo SNES/SFC", "Bandai WonderSwan/Color", "Game Boy Advance", "Atari Lynx", "Neo Geo Pocket/Color", "NEC PC-FX", "NEC PC Engine/SuperGrafx/CD", "Sony PlayStation", "Sega Saturn", "Nintendo Virtual Boy", "Sega Genesis (Mega Drive)", "MSX/SVI/ColecoVision/SG-1000", "Nintendo NES/Famicom", "Nintendo 3DS", "Amstrad CPC", "Philips CDi", "Nintendo 64"
$directories = "Cores", "System/BIOS", "Screenshots", "Cheats", "Thumbnails"

$DrivePath = $firstNonExistingDriveLetter + ':'

$mainFolder = Join-Path -Path $DrivePath -ChildPath "ROMS"

# Create the main folder if it doesn't exist
if (!(Test-Path -Path $mainFolder)) {
    New-Item -ItemType Directory -Path $mainFolder
}

foreach ($directory in $directories) {
    $directoryPath = Join-Path -Path $DrivePath -ChildPath $directory

    if (!(Test-Path -Path $directoryPath)) {
        New-Item -ItemType Directory -Path $directoryPath
    }
}

foreach ($console in $consoles) {
    $consoleFolder = Join-Path -Path $mainFolder -ChildPath $console

    if (!(Test-Path -Path $consoleFolder)) {
        New-Item -ItemType Directory -Path $consoleFolder
    }
}

$principal = "ALL APPLICATION PACKAGES"
$acl = Get-Acl -Path $DrivePath
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($principal, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$acl.AddAccessRule($accessRule)
Set-Acl -Path $DrivePath -AclObject $acl


$(Write-Host "Press Any Key to exit." -ForegroundColor Green -NoNewLine; Read-Host)   