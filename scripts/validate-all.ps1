$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$tmpDir = Join-Path $repoRoot '.tmp-validate'
$notePath = Join-Path $tmpDir 'generated-note.md'
$opsPath = Join-Path $tmpDir 'generated-ops.md'
$composeDir = Join-Path $repoRoot 'infra\n8n'
$composeEnv = Join-Path $composeDir '.env'

try {
  pwsh -File (Join-Path $PSScriptRoot 'check-public-safety.ps1')
  pwsh -File (Join-Path $PSScriptRoot 'new-from-template.ps1') -Template public-note -OutputPath '.tmp-validate/generated-note.md'
  pwsh -File (Join-Path $PSScriptRoot 'new-from-template.ps1') -Template operational-doc -OutputPath '.tmp-validate/generated-ops.md'
  Copy-Item (Join-Path $composeDir '.env.example') $composeEnv -Force
  Push-Location $composeDir
  docker compose -f docker-compose.yml config | Out-Null
  Pop-Location
}
finally {
  if (Test-Path $composeEnv) {
    Remove-Item $composeEnv -Force
  }

  if (Test-Path $notePath) {
    Remove-Item $notePath -Force
  }

  if (Test-Path $opsPath) {
    Remove-Item $opsPath -Force
  }

  if (Test-Path $tmpDir) {
    Remove-Item $tmpDir -Force
  }
}

Write-Host 'Validation passed.'