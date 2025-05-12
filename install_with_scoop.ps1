# install_with_scoop.ps1
$logFile = "$PSScriptRoot\install_log.txt"

function Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Write-Host $logEntry
    Add-Content -Path $logFile -Value $logEntry
}

function SafeInvoke {
    param(
        [ScriptBlock]$action,
        [string]$description
    )
    try {
        Log "START: $description"
        & $action
