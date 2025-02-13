param (
    [string]$Drive,
    [string]$Warning,
    [string]$Critical,
    [switch]$Help
)

# Constants for return values
$intOK = 0
$intWarning = 1
$intCritical = 2
$intUnknown = 3

# Help function
function Show-Help {
    Write-Output "Plugin help screen:"
    Write-Output "Example: .\check_disk.ps1 -Drive C:\ -Warning 200 -Critical 100"
    Exit $intUnknown
}

if ($Help -or -not $Drive -or -not $Warning -or -not $Critical) {
    Show-Help
}

# Convert parameters to usable format
$WarningValue = if ($Warning -match "%$") { $Warning.TrimEnd('%') } else { [int]$Warning }
$CriticalValue = if ($Critical -match "%$") { $Critical.TrimEnd('%') } else { [int]$Critical }
$WarningIsPercentage = $Warning -match "%$"
$CriticalIsPercentage = $Critical -match "%$"

# Retrieve drive information
$DriveInfo = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$Drive'"
if (-not $DriveInfo) {
    Write-Output "Unknown: Drive $Drive not found."
    Exit $intUnknown
}

$FreeSpaceMB = [math]::Round($DriveInfo.FreeSpace / 1MB, 0)
$TotalSpaceMB = [math]::Round($DriveInfo.Size / 1MB, 0)
$UsedSpaceMB = $TotalSpaceMB - $FreeSpaceMB
$FreeSpacePercentage = [math]::Round(($FreeSpaceMB / $TotalSpaceMB) * 100, 0)
$UsedSpacePercentage = 100 - $FreeSpacePercentage

# Determine warning/critical thresholds
if ($CriticalIsPercentage) {
    if ($FreeSpacePercentage -le $CriticalValue) {
        Write-Output "Critical: Drive $Drive - Free: $FreeSpaceMB MB ($FreeSpacePercentage%) | 'Total'=${TotalSpaceMB}MB 'Free'=${FreeSpaceMB}MB 'Used'=${UsedSpaceMB}MB"
        Exit $intCritical
    }
} else {
    if ($FreeSpaceMB -le $CriticalValue) {
        Write-Output "Critical: Drive $Drive - Free: $FreeSpaceMB MB ($FreeSpacePercentage%) | 'Total'=${TotalSpaceMB}MB 'Free'=${FreeSpaceMB}MB 'Used'=${UsedSpaceMB}MB"
        Exit $intCritical
    }
}

if ($WarningIsPercentage) {
    if ($FreeSpacePercentage -le $WarningValue) {
        Write-Output "Warning: Drive $Drive - Free: $FreeSpaceMB MB ($FreeSpacePercentage%) | 'Total'=${TotalSpaceMB}MB 'Free'=${FreeSpaceMB}MB 'Used'=${UsedSpaceMB}MB"
        Exit $intWarning
    }
} else {
    if ($FreeSpaceMB -le $WarningValue) {
        Write-Output "Warning: Drive $Drive - Free: $FreeSpaceMB MB ($FreeSpacePercentage%) | 'Total'=${TotalSpaceMB}MB 'Free'=${FreeSpaceMB}MB 'Used'=${UsedSpaceMB}MB"
        Exit $intWarning
    }
}

# Output OK status
Write-Output "OK: Drive $Drive - Total: $TotalSpaceMB MB - Free: $FreeSpaceMB MB ($FreeSpacePercentage%) - Used: $UsedSpaceMB MB ($UsedSpacePercentage%) | 'Total'=${TotalSpaceMB}MB 'Free'=${FreeSpaceMB}MB 'Used'=${UsedSpaceMB}MB"
Exit $intOK
