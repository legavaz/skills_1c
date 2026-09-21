<#
.SYNOPSIS
  Разворачивает глобальные настройки OpenCode из архива в проект.

.DESCRIPTION
  Работает по манифесту restore.config.json: только компоненты и MCP-серверы
  с enabled=true. Читает локальные пути из restore.local.json (или из env /
  авто-поиска). Копирует skills/, package.json/package-lock.json, tui.json,
  генерирует opencode.jsonc из opencode.jsonc.tpl, при необходимости ставит
  node_modules в skills\web-test\scripts (Playwright).

.EXAMPLE
  .\restore.ps1 -Project E:\project\edt
  .\restore.ps1 -Project E:\project\edt -Force
  .\restore.ps1 -Project E:\project\edt -Models
#>
param(
  [Parameter(Mandatory=$true)][string]$Project,
  [switch]$Force,
  [switch]$Models
)

$ErrorActionPreference = "Stop"
$ArchiveRoot = $PSScriptRoot

if (-not (Test-Path $Project)) {
  Write-Error "Проект не найден: $Project"
}

$DotO = Join-Path $Project ".opencode"
$SkillsDst = Join-Path $DotO "skills"
$CfgDst = Join-Path $DotO "opencode.jsonc"

# ---------- Манифест ----------
$ManifestPath = Join-Path $ArchiveRoot "restore.config.json"
if (-not (Test-Path $ManifestPath)) {
  Write-Error "Не найден манифест: $ManifestPath"
}
$Manifest = Get-Content $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

function Is-Enabled {
  param($item)
  return ($item -and $item.enabled)
}

# ---------- Локальные пути ----------
$vault = $null
$aib = $null

$LocalPath = Join-Path $ArchiveRoot "restore.local.json"
if (Test-Path $LocalPath) {
  $local = Get-Content $LocalPath -Raw -Encoding UTF8 | ConvertFrom-Json
  $vault = $local.obsidianVault
  $aib = $local.aiblueprintExe
}

if (-not $vault) { $vault = $env:OBSIDIAN_VAULT }
if (-not $vault) { $vault = "E:\Обсидиан\Обсидиан" }  # локальный путь по умолчанию

if (-not $aib) {
  $found = Get-ChildItem "$env:USERPROFILE\.local\bin" -Filter "aiblueprint-mcp*" -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($found) { $aib = $found.FullName }
}

$workspace = Join-Path $vault "Чертежи"

# ---------- Модели Plan/Build ----------
$ModelsComp = $Manifest.components | Where-Object { $_.id -eq "models" }
$EnableModels = (Is-Enabled $ModelsComp) -or $Models

# ---------- Выбор включённых MCP ----------
$EnabledMCP = @{}
foreach ($p in $Manifest.mcpServers.PSObject.Properties) {
  if (Is-Enabled $p.Value) { $EnabledMCP[$p.Name] = $p.Value }
}

# ---------- 1. Skills ----------
if (Is-Enabled ($Manifest.components | Where-Object { $_.id -eq "skills" })) {
  if (Test-Path $SkillsDst) {
    if ($Force) { Remove-Item $SkillsDst -Recurse -Force }
    else { Write-Error "В проекте уже есть $SkillsDst. Запустите с -Force для перезаписи." }
  }
  Copy-Item (Join-Path $ArchiveRoot "skills") $SkillsDst -Recurse -Force
}

# ---------- 2. package.json / package-lock.json ----------
if (Is-Enabled ($Manifest.components | Where-Object { $_.id -eq "package" })) {
  foreach ($f in @("package.json", "package-lock.json")) {
    Copy-Item (Join-Path $ArchiveRoot $f) (Join-Path $DotO $f) -Force
  }
}

# ---------- 3. tui.json ----------
if (Is-Enabled ($Manifest.components | Where-Object { $_.id -eq "tui" })) {
  Copy-Item (Join-Path $ArchiveRoot "tui.json") (Join-Path $DotO "tui.json") -Force
}

# ---------- 4. opencode.jsonc из шаблона ----------
if (Is-Enabled ($Manifest.components | Where-Object { $_.id -eq "config" })) {
  $cfg = @{
    '$schema' = "https://opencode.ai/config.json"
    mcp = @{}
    experimental = @{ mcp_timeout = 30000 }
  }

  if ($EnabledMCP.ContainsKey("1c")) {
    $cfg.mcp["1c"] = @{ type = "remote"; url = "http://localhost:6003/mcp"; enabled = $true }
  }
  if ($EnabledMCP.ContainsKey("edt")) {
    $cfg.mcp["edt"] = @{ type = "remote"; url = "http://localhost:8765/mcp"; enabled = $true }
  }
  if ($EnabledMCP.ContainsKey("obsidian")) {
    $cfg.mcp["obsidian"] = @{ type = "local"; command = @("cmd","/c","mcpvault",$vault); enabled = $true }
  }
  if ($EnabledMCP.ContainsKey("excel")) {
    $cfg.mcp["excel"] = @{ type = "local"; command = @("cmd","/c","uvx","excel-mcp-server","stdio"); enabled = $true }
  }
  if ($EnabledMCP.ContainsKey("dxf") -and $aib) {
    $cfg.mcp["dxf"] = @{
      type = "local"
      command = @("cmd","/c",$aib)
      enabled = $true
      environment = @{ AIBLUEPRINT_WORKSPACE = $workspace }
    }
  }

  if ($EnabledMCP.ContainsKey("obsidian")) {
    $cfg.permission = @{ external_directory = @{ "$vault/**" = "allow" } }
  }

  if ($EnableModels -and $ModelsComp) {
    $cfg.agent = @{
      plan  = @{ model = $ModelsComp.plan.model;  options = @{ reasoningEffort = $ModelsComp.plan.reasoningEffort } }
      build = @{ model = $ModelsComp.build.model; options = @{ reasoningEffort = $ModelsComp.build.reasoningEffort } }
    }
  }

  $cfg | ConvertTo-Json -Depth 10 | Set-Content -Path $CfgDst -Encoding UTF8
}

# ---------- 5. Playwright (по манифесту) ----------
$pw = $Manifest.components | Where-Object { $_.id -eq "playwright" }
if (Is-Enabled $pw) {
  $wt = Join-Path $SkillsDst "web-test\scripts"
  if (Test-Path (Join-Path $wt "package.json")) {
    Push-Location $wt
    try { npm install --no-audit --no-fund }
    finally { Pop-Location }
  } else {
    Write-Warning "web-test\scripts\package.json не найден — npm install пропущен"
  }
}

# ---------- 6. Сводка ----------
Write-Host ""
Write-Host "Развёрнуто в $Project" -ForegroundColor Green
if (Is-Enabled ($Manifest.components | Where-Object { $_.id -eq "skills" })) {
  $skillCount = (Get-ChildItem $SkillsDst -Directory).Count
  Write-Host "  Скиллов:        $skillCount -> $SkillsDst"
}
Write-Host "  Конфигурация:   $CfgDst"
if ($EnableModels) {
  Write-Host "  Модели:         Plan=$($ModelsComp.plan.model)@$($ModelsComp.plan.reasoningEffort), Build=$($ModelsComp.build.model)@$($ModelsComp.build.reasoningEffort)"
} else {
  Write-Host "  Модели:         не установлены (флаг -Models или enabled в манифесте)"
}
Write-Host ""
Write-Host "MCP-серверы (включены):" -ForegroundColor Cyan
foreach ($name in ($EnabledMCP.Keys | Sort-Object)) {
  Write-Host "  $name -> $($EnabledMCP[$name].name)"
}
Write-Host ""
Write-Host "Пропущены (disabled):" -ForegroundColor DarkGray
foreach ($p in $Manifest.mcpServers.PSObject.Properties) {
  if (-not (Is-Enabled $p.Value)) { Write-Host "  $($p.Name)" }
}
foreach ($c in $Manifest.components) {
  if (-not (Is-Enabled $c)) { Write-Host "  $($c.id)" }
}