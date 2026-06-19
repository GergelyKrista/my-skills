# Install every skill in this repo into Claude Code's global skills directory.
# Usage:  .\install.ps1            (installs all skills)
#         .\install.ps1 <name>     (installs one skill folder)
param([string]$Name)

$dest = Join-Path $HOME ".claude\skills"
New-Item -ItemType Directory -Force -Path $dest | Out-Null

function Install-One($dir) {
  $skill = Join-Path $dir.FullName "SKILL.md"
  if (-not (Test-Path $skill)) { Write-Host "skip: $($dir.Name) (no SKILL.md)"; return }
  $target = Join-Path $dest $dir.Name
  if (Test-Path $target) { Remove-Item -Recurse -Force $target }
  Copy-Item -Recurse -Force $dir.FullName $dest
  Write-Host "installed: $($dir.Name) -> $target"
}

if ($Name) {
  Install-One (Get-Item $Name)
} else {
  Get-ChildItem -Directory | ForEach-Object { Install-One $_ }
}

Write-Host "Done. Restart Claude Code to activate the skill(s)."
