$ErrorActionPreference = 'Stop'

Set-Location "C:\Users\icech\Desktop\Research with AI\Paper reading"

$gitCmd = "C:\Program Files\Git\cmd\git.exe"
if (!(Test-Path $gitCmd)) {
  Write-Output "Git executable not found at: $gitCmd"
  exit 1
}

# Initialize repo if missing
& $gitCmd rev-parse --is-inside-work-tree 1>$null 2>$null
if ($LASTEXITCODE -ne 0) {
  & $gitCmd init | Out-Null
}

# Skip when remote origin is not configured
$remotes = & $gitCmd remote
if ($LASTEXITCODE -ne 0) {
  Write-Output "Unable to read remotes. Skipping backup."
  exit 0
}

if (-not ($remotes -contains 'origin')) {
  Write-Output "Origin remote is not set. Skipping backup."
  exit 0
}

& $gitCmd add -A
& $gitCmd diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
  Write-Output "No changes to backup."
  exit 0
}

$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
& $gitCmd commit -m "auto backup: $ts" 1>$null
if ($LASTEXITCODE -ne 0) {
  Write-Output "Commit failed. Check git user.name/user.email and repo state."
  exit 1
}

& $gitCmd push origin HEAD
if ($LASTEXITCODE -eq 0) {
  Write-Output "Backup pushed successfully at $ts"
} else {
  Write-Output "Push failed. Check authentication and remote permissions."
  exit 1
}
