param(
  # Default base directory for projects
  [string]$ProjDir  = (Join-Path $env:USERPROFILE "Documents\Projects"),

  # Name of the repository folder
  [string]$RepoName = "vsv_analysis",

  # GitHub repo URL to clone
  [string]$RepoUrl  = "https://github.com/cedanl/vsv_analysis.git",

  # R version to install with Scoop
  [string]$RVersion = "4.5.0",

  # Optional flag to skip "scoop update"
  [switch]$NoUpdateScoop
)

# -------------------- General setup --------------------
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'          # stop immediately on any error
$sw = [System.Diagnostics.Stopwatch]::StartNew()  # for runtime measurement

# Logging to a file for debugging
$LogDir = Join-Path $env:TEMP "setup"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$Log = Join-Path $LogDir ("setup_{0:yyyyMMdd_HHmmss}.log" -f (Get-Date))
Start-Transcript -Path $Log -Append | Out-Null
Write-Host "Log: $Log"

# Helper function for external commands with error checking
function Exec {
  param(
    [string]$Cmd,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
  )

  Write-Host ">> $Cmd $($Args -join ' ')"
  $p = Start-Process -FilePath $Cmd -ArgumentList $Args -NoNewWindow -PassThru -Wait
  if ($p.ExitCode -ne 0) { throw "Command failed ($($p.ExitCode)): $Cmd $($Args -join ' ')" }
}


# -------------------- 0) Check Scoop --------------------
$Scoop = "$env:USERPROFILE\scoop\shims\scoop.ps1"

if (-not (Test-Path $Scoop)) {
  Write-Host "Scoop not found. Installing"
  # Allow downloaded scripts to run
  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
  # Install Scoop
  iwr -useb get.scoop.sh | iex
  if (-not (Test-Path $Scoop)) { throw "Scoop installation did not succeed" }
} else {
  Write-Host "Scoop detected: $Scoop"
  if (-not $NoUpdateScoop) {
    & $Scoop update | Write-Host
  } else {
    Write-Host "Skipping Scoop update (NoUpdateScoop)."
  }
}
& $Scoop --version | Write-Host

# -------------------- 1) Buckets --------------------
Write-Host "Ensuring buckets are added"
& $Scoop bucket add main     *> $null   # basic programs
& $Scoop bucket add extras   *> $null   # GUI programs like RStudio
& $Scoop bucket add versions *> $null   # alternative versions

# -------------------- 2) Programs --------------------
# 1) Install Rtools (compiler toolchain for R packages)
Write-Host "Installing Rtools"
& $Scoop install rtools.json

Write-Host "Installing RStudio via Scoop"
& $Scoop install rstudio

# Install the specific R version
Write-Host "Installing R @$RVersion"
& $Scoop install "r@$RVersion"
Write-Host "Holding R version to prevent upgrades"
& $Scoop hold r

# -------------------- 3) GitHub repository --------------------
# Make sure base directory exists
New-Item -ItemType Directory -Force -Path $ProjDir | Out-Null
$RepoPath = Join-Path $ProjDir $RepoName

# Clone repo if not already present
if (-not (Test-Path $RepoPath)) {
  Write-Host "Cloning $RepoUrl -> $RepoPath"
  Exec "git" "clone" $RepoUrl $RepoPath
} else {
  Write-Host "Repo already exists at $RepoPath"
}
Set-Location $RepoPath
Write-Host "Working directory: $(Get-Location)"

# # -------------------- 4) RStudio preferences --------------------
$Prefs = "$env:LOCALAPPDATA\RStudio\rstudio-prefs.json"
$PrefsObj = @{
  restore_last_project      = $true
  restore_source_documents  = $false
  load_workspace            = $false
  save_workspace            = "never"
  always_save_history       = $false
  restore_workspace         = $false
  rmd_chunk_output_inline   = $false
}
$PrefsObj | ConvertTo-Json -Depth 2 | Out-File -Encoding utf8 $Prefs

Write-Host "RStudio preferences written to: $Prefs"

# -------------------- 5) renv dependencies --------------------
$Rscript = "$env:USERPROFILE\scoop\shims\Rscript.exe"
if (-not (Test-Path $Rscript)) { throw "Rscript not found: $Rscript" }

if (Test-Path "renv.lock") {
  Write-Host "renv.lock found: restoring environment"
  & $Rscript -e "if(!requireNamespace('renv', quietly=TRUE)) install.packages('renv', repos='https://cran.r-project.org'); renv::restore()"
} else {
  Write-Host "No renv.lock: initializing clean renv"
  & $Rscript -e "install.packages('renv', repos='https://cran.r-project.org'); renv::init(bare=TRUE)"
}

# -------------------- 2b) Add R to user environment --------------------
# $RBinPath = Join-Path $env:USERPROFILE "scoop\apps\r\$RVersion\bin"

# # Update PATH for current session
# $env:PATH = "$RBinPath;$env:PATH"

# # Persist PATH for user environment
# $CurrentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
# if (-not ($CurrentPath -like "*$RBinPath*")) {
#     [System.Environment]::SetEnvironmentVariable(
#         "PATH",
#         "$RBinPath;$CurrentPath",
#         "User"
#     )
#     Write-Host "Added R bin to user PATH: $RBinPath"
# } else {
#     Write-Host "R bin already present in PATH."
# }


# -------------------- 6) Launch RStudio --------------------
$ProjFile = Join-Path $RepoPath "$RepoName.Rproj"

# Try to resolve RStudio executable
$RStudioExe = "$env:USERPROFILE\scoop\apps\rstudio\current\rstudio.exe"

Write-Host "Launching RStudio: $RStudioExe"

$RHome = "$env:USERPROFILE\scoop\apps\r\$RVersion\bin\R.exe"
[System.Environment]::SetEnvironmentVariable("RSTUDIO_WHICH_R", $RHome, "Process")
Write-Host "Forcing RStudio to use: $RHome"

if (Test-Path $ProjFile) {
  Write-Host "Opening project: $ProjFile"
  Start-Process $RStudioExe $ProjFile
} else {
  Write-Host "No project file found. Opening plain RStudio."
  Start-Process $RStudioExe
}

# -------------------- Done --------------------
$sw.Stop()
Write-Host ("Setup completed in {0:n1} seconds" -f $sw.Elapsed.TotalSeconds)
Set-Location (Join-Path $env:USERPROFILE "Documents")
Stop-Transcript | Out-Null

## Notes:
## Open specific file
## renv.lock is not always in the same place + renv::restore() is not optimal
## 

