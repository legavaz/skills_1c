<#
.SYNOPSIS
  Разворачивает глобальные настройки OpenCode из архива в проект.

.DESCRIPTION
  Копирует skills/ в <проект>\.opencode\skills\,
  генерирует .opencode\opencode.jsonc из шаблона opencode.jsonc.tpl,
  копирует package.json / package-lock.json (для плагина @opencode-ai/plugin).
  При -InstallPlaywright ставит node_modules в skills\web-test\scripts.

.EXAMPLE
  .\restore.ps1 -Project E:\project\edt
  .\restore.ps1 -Project E:\project\edt -InstallPlaywright -Force
#>
param(
  [Parameter(Mandatory=$true)][string]$Project,
  [switch]$InstallPlaywright,
  [switch]$Force
)

$ErrorActionPreference = "Stop"
$ArchiveRoot = $PSScriptRoot

if (-not (Test-Path $Project)) {
  Write-Error "Проект не найден: $Project"
}

$DotO = Join-Path $Project ".opencode"
$SkillsDst = Join-Path $DotO "skills"
$CfgDst = Join-Path $DotO "opencode.jsonc"

# ---------- 1. Skills ----------
if (Test-Path $SkillsDst) {
  if ($Force) { Remove-Item $SkillsDst -Recurse -Force }
  else { Write-Error "В проекте уже есть $SkillsDst. Запустите с -Force для перезаписи." }
}
Copy-Item (Join-Path $ArchiveRoot "skills") $SkillsDst -Recurse -Force
$skillCount = (Get-ChildItem $SkillsDst -Directory).Count

# ---------- 2. package.json / package-lock.json ----------
foreach ($f in @("package.json", "package-lock.json")) {
  Copy-Item (Join-Path $ArchiveRoot $f) (Join-Path $DotO $f) -Force
}

# ---------- 3. opencode.jsonc из шаблона ----------
$tpl = Get-Content (Join-Path $ArchiveRoot "opencode.jsonc.tpl") -Raw -Encoding UTF8

# Определение путей
$vault = "E:\Обсидиан\Обсидиан"
if ($env:OBSIDIAN_VAULT) { $vault = $env:OBSIDIAN_VAULT }

$aib = "C:\Users\lega\.local\bin\aiblueprint-mcp.exe"
if (-not (Test-Path $aib)) {
  $found = Get-ChildItem "$env:USERPROFILE\.local\bin" -Filter "aiblueprint-mcp*" -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($found) { $aib = $found.FullName }
}

$workspace = Join-Path $vault "Чертежи"

$tpl = $tpl.Replace("{{OBSIDIAN_VAULT}}", $vault.Replace("\","\\"))
$tpl = $tpl.Replace("{{AIBLUEPRINT_EXE}}", $aib.Replace("\","\\"))
$tpl = $tpl.Replace("{{AIBLUEPRINT_WORKSPACE}}", $workspace.Replace("\","\\"))

Set-Content -Path $CfgDst -Value $tpl -Encoding UTF8

# ---------- 4. Playwright (опционально) ----------
if ($InstallPlaywright) {
  $wt = Join-Path $SkillsDst "web-test\scripts"
  if (Test-Path (Join-Path $wt "package.json")) {
    Push-Location $wt
    try { npm install --no-audit --no-fund }
    finally { Pop-Location }
  } else {
    Write-Warning "web-test\scripts\package.json не найден — npm install пропущен"
  }
}

# ---------- 5. Сводка ----------
Write-Host ""
Write-Host "Развёрнуто в $Project" -ForegroundColor Green
Write-Host "  Скиллов:        $skillCount -> $SkillsDst"
Write-Host "  Конфигурация:   $CfgDst"
Write-Host ""
Write-Host "MCP-серверы:" -ForegroundColor Cyan
Write-Host "  obsidian (local) -> $vault"
Write-Host "  excel    (local) -> uvx excel-mcp-server"
Write-Host "  dxf      (local) -> $aib"
Write-Host "  1c / edt (remote, требуют запущенного сервера):"
Write-Host "    http://localhost:6003/mcp (1c)"
Write-Host "    http://localhost:8765/mcp (edt)"