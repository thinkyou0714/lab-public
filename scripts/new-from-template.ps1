param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('public-note', 'operational-doc')]
  [string]$Template,

  [Parameter(Mandatory = $true)]
  [string]$OutputPath
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$templatePath = Join-Path $repoRoot (Join-Path 'templates' ($Template + '.md'))
$targetPath = Join-Path $repoRoot $OutputPath

if (-not (Test-Path $templatePath)) {
  throw "Template not found: $templatePath"
}

if (Test-Path $targetPath) {
  throw "Target already exists: $targetPath"
}

$targetDir = Split-Path -Parent $targetPath
if ($targetDir -and -not (Test-Path $targetDir)) {
  New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

$today = Get-Date -Format 'yyyy-MM-dd'
$content = Get-Content $templatePath -Raw
$content = $content -replace 'YYYY-MM-DD', $today

Set-Content -Path $targetPath -Value $content -NoNewline
Write-Host "Created $OutputPath from template '$Template'."