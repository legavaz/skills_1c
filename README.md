# OpenCode — глобальные настройки (архив)

Архив глобальных настроек OpenCode для развёртывания в любом проекте.
Источник: `C:\Users\lega\.config\opencode`.

## Состав

| Элемент | Описание |
|---|---|
| `opencode.jsonc.tpl` | Шаблон конфига с плейсхолдерами `{{...}}` |
| `skills/` | 80 скиллов 1С/EDT/Obsidian/Excel/DXF (без `node_modules`, ставятся через npm) |
| `package.json`, `package-lock.json` | Плагин `@opencode-ai/plugin` для opencode |
| `tui.json` | Плагин TUI `@hxnnxs/opencode-voice` (голосовой ввод) |
| `restore.ps1` | Скрипт развёртывания в проект |

## Требования на машине

- **OpenCode** (глобально): `npm i -g opencode-ai`
- **mcpvault** (для Obsidian MCP): `npm i -g @bitbonsai/mcpvault`
- **uvx** (для Excel MCP): пакет `uv` (напр. `uvx excel-mcp-server`)
- **aiblueprint-mcp.exe** (для DXF MCP): `C:\Users\lega\.local\bin\aiblueprint-mcp.exe`
- **Remote MCP `1c` (:6003)** и **`edt` (:8765)** — внешние серверы, должны быть запущены отдельно

## Восстановление в проекте

```powershell
.\restore.ps1 -Project E:\path\to\project
```

Разворачивает в проект:
- `.opencode\skills\` — все скиллы
- `.opencode\opencode.jsonc` — конфиг с MCP (пути подставляются автоматически)
- `.opencode\package.json`, `package-lock.json`

### Параметры

| Параметр | Описание |
|---|---|
| `-Project <путь>` | Обязательный. Проект, куда разворачивать |
| `-InstallPlaywright` | Дополнительно `npm install` в `skills\web-test\scripts` (13 МБ) |
| `-Force` | Перезаписать существующий `.opencode\skills` |

### Переменные окружения для переопределения путей

| Переменная | Назначение |
|---|---|
| `OBSIDIAN_VAULT` | Путь к vault Obsidian (по умолчанию `E:\Обсидиан\Обсидиан`) |

## Обновление архива из источника

```powershell
# копирование skills (без node_modules/__pycache__)
# затем обновить opencode.jsonc.tpl, package.json, tui.json вручную при необходимости
```

## Примечания

- Скиллы рассчитаны на размещение в проекте (путь `.opencode/skills/<имя>/scripts/...`).
- `web-test` требует `npm install` (Playwright) — см. `-InstallPlaywright`.
- Плагин голосового ввода `@hxnnxs/opencode-voice` в `tui.json` — устанавливается по необходимости.