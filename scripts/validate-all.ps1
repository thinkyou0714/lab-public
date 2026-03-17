$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$tmpDir = Join-Path $repoRoot '.tmp-validate'
$composeDir = Join-Path $repoRoot 'infra\n8n'
$composeEnv = Join-Path $composeDir '.env'

function Invoke-CheckedPwshFile {
  param(
    [string]$Path,
    [string[]]$Arguments = @(),
    [string]$FailureMessage
  )

  & pwsh -File $Path @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw $FailureMessage
  }
}

try {
  Invoke-CheckedPwshFile -Path (Join-Path $PSScriptRoot 'check-public-safety.ps1') -FailureMessage 'Public safety check failed.'
  Invoke-CheckedPwshFile -Path (Join-Path $PSScriptRoot 'new-from-template.ps1') -Arguments @('-Template', 'public-note', '-OutputPath', '.tmp-validate/generated-note.md') -FailureMessage 'Public note template generation failed.'
  Invoke-CheckedPwshFile -Path (Join-Path $PSScriptRoot 'new-from-template.ps1') -Arguments @('-Template', 'operational-doc', '-OutputPath', '.tmp-validate/generated-ops.md') -FailureMessage 'Operational doc template generation failed.'

  Copy-Item (Join-Path $composeDir '.env.example') $composeEnv -Force
  Push-Location $composeDir
  & docker compose -f docker-compose.yml config | Out-Null
  if ($LASTEXITCODE -ne 0) {
    throw 'Compose config check failed.'
  }
}
finally {
  if ((Get-Location).Path -eq $composeDir) {
    Pop-Location
  }

  if (Test-Path $composeEnv) {
    Remove-Item $composeEnv -Force
  }

  if (Test-Path $tmpDir) {
    Remove-Item $tmpDir -Recurse -Force
  }
}

Write-Host 'Validation passed.'