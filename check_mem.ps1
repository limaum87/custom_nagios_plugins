param (
    [int]$Warning,
    [int]$Critical,
    [switch]$Help
)

# Função de ajuda
function Show-Help {
    $scriptName = "Check Memory"
    Write-Output ""
    Write-Output "### $scriptName Version 2.0 ###"
    Write-Output "Usage: $scriptName -Warning <warnlevel> -Critical <critlevel>"
    Write-Output "       warnlevel and critlevel are percentage values without the % symbol"
    Write-Output "Example: .\$scriptName -Warning 80 -Critical 90"
    Write-Output ""
    Write-Output "This script is released under an open license and is free for everyone to use, modify, and distribute."
    Write-Output "No copyright restrictions. Shared for the benefit of all."
    Write-Output ""
    Exit
}

# Verifica se ajuda foi requisitada ou parâmetros são inválidos
if ($Help -or -not $Warning -or -not $Critical -or $Warning -le 0 -or $Critical -le 0) {
    Show-Help
}

# Obter informações da memória
$memory = Get-CimInstance -ClassName Win32_OperatingSystem
$memTotalMB = [math]::Round($memory.TotalVisibleMemorySize / 1024, 0)
$memFreeMB = [math]::Round($memory.FreePhysicalMemory / 1024, 0)
$memUsedMB = $memTotalMB - $memFreeMB
$memUsedPercent = [math]::Round(($memUsedMB / $memTotalMB) * 100, 0)

# Avaliar limites
if ($memUsedPercent -ge $Critical) {
    Write-Output "Memory: CRITICAL Total: $memTotalMB MB - Used: $memUsedMB MB - $memUsedPercent% used! | 'TOTAL'=${memTotalMB}MB;;;; 'USED'=${memUsedMB}MB;;;;"
    Exit 2
} elseif ($memUsedPercent -ge $Warning) {
    Write-Output "Memory: WARNING Total: $memTotalMB MB - Used: $memUsedMB MB - $memUsedPercent% used! | 'TOTAL'=${memTotalMB}MB;;;; 'USED'=${memUsedMB}MB;;;;"
    Exit 1
} else {
    Write-Output "Memory: OK Total: $memTotalMB MB - Used: $memUsedMB MB - $memUsedPercent% used! | 'TOTAL'=${memTotalMB}MB;;;; 'USED'=${memUsedMB}MB;;;;"
    Exit 0
}
