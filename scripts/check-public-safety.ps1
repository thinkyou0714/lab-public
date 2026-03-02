$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$allowedExampleLines = @(
  'N8N_BASIC_AUTH_PASSWORD=change-this-password',
  'WEBHOOK_URL=http://TAILSCALE_IP_HERE:5678'
)
$sourceExemptMarker = 'Source-Exempt: operational-doc'

$files = Get-ChildItem -Path $repoRoot -Recurse -File |
  Where-Object {
    $_.FullName -notlike "$repoRoot\.git\*" -and
    $_.FullName -notlike "$repoRoot\.jj\*" -and
    $_.Name -notin @('.env', 'check-public-safety.ps1')
  }

$patterns = @(
  @{
    Name = 'placeholder password'
    Regex = 'changeme|change-this-password'
  },
  @{
    Name = 'hardcoded tailnet IP'
    Regex = 'http://100\.\d{1,3}\.\d{1,3}\.\d{1,3}:5678'
  },
  @{
    Name = 'local absolute path'
    Regex = 'C:/Users/|C:\\Users\\'
  },
  @{
    Name = 'latest image tag'
    Regex = 'n8nio/n8n:latest'
  }
)

$hits = @()
foreach ($file in $files) {
  foreach ($pattern in $patterns) {
    $matches = Select-String -Path $file.FullName -Pattern $pattern.Regex -AllMatches
    foreach ($match in $matches) {
      if ($file.Name -eq '.env.example' -and $allowedExampleLines -contains $match.Line.Trim()) {
        continue
      }

      $hits += [PSCustomObject]@{
        File = $file.FullName.Substring($repoRoot.Length + 1)
        Line = $match.LineNumber
        Problem = $pattern.Name
        Text = $match.Line.Trim()
      }
    }
  }

  if ($file.Extension -eq '.md') {
    $content = Get-Content $file.FullName -Raw
    $hasExemption = $content -match [regex]::Escape($sourceExemptMarker)
    $hasSourceUrl = $content -match '出典:\s*https?://[A-Za-z0-9]'

    if (-not $hasExemption -and -not $hasSourceUrl) {
      $hits += [PSCustomObject]@{
        File = $file.FullName.Substring($repoRoot.Length + 1)
        Line = 1
        Problem = 'missing source or exemption'
        Text = 'Markdown files need a source URL or Source-Exempt: operational-doc.'
      }
    }
  }
}

if (-not (Test-Path (Join-Path $repoRoot 'LOG_POLICY.md'))) {
  $hits += [PSCustomObject]@{
    File = 'LOG_POLICY.md'
    Line = 0
    Problem = 'missing policy file'
    Text = 'LOG_POLICY.md is required in repo root.'
  }
}

if ($hits.Count -gt 0) {
  $hits | Format-Table -AutoSize | Out-String | Write-Host
  exit 1
}

Write-Host 'Public safety check passed.'