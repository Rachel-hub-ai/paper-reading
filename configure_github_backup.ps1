param(
  [Parameter(Mandatory=$true)]
  [string]$RepoUrl,
  [Parameter(Mandatory=$true)]
  [string]$GitName,
  [Parameter(Mandatory=$true)]
  [string]$GitEmail
)

$ErrorActionPreference = 'Stop'
Set-Location "C:\Users\icech\Desktop\Research with AI\Paper reading"

$gitCmd = "C:\Program Files\Git\cmd\git.exe"
if (!(Test-Path $gitCmd)) {
  Write-Error "Git not found at $gitCmd"
  exit 1
}

& $gitCmd rev-parse --is-inside-work-tree 1>$null 2>$null
if ($LASTEXITCODE -ne 0) {
  & $gitCmd init
}

& $gitCmd branch -M main
& $gitCmd config user.name "$GitName"
& $gitCmd config user.email "$GitEmail"

$remotes = & $gitCmd remote
if ($remotes -contains 'origin') {
  & $gitCmd remote set-url origin "$RepoUrl"
} else {
  & $gitCmd remote add origin "$RepoUrl"
}

& $gitCmd add -A
& $gitCmd diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
  & $gitCmd commit -m "init backup"
}

& $gitCmd push -u origin main
Write-Output "GitHub backup is configured and initial push is completed."
