# Аналитический отчёт: AI-инструменты для разработки на 1С

Источник: https://aitools1c.dev/
Дата анализа: 07.09.2026

---

## Обзор

- **91 инструмент** в **16 категориях**
- MCP-серверы, Skills, LSP, IDE-интеграции
- Цель: дать ИИ-агентам доступ к метаданным, BSL-коду, формам, справке и тестам 1С

---

## Необходимые навыки для работы с 1С

1. BSL (Basic Script Language) — основной язык
2. Метаданные конфигурации — объекты, реквизиты, формы, роли
3. Справка платформы — API, методы, свойства, конструкторы
4. BSL Language Server — диагностика, навигация, форматирование
5. Формы 1С — управляемые формы
6. Запросы и СКД — язык запросов, схемы компоновки
7. Журнал регистрации и технологический журнал
8. YaXUnit — тестирование
9. 1С:EDT — среда разработки
10. БСП — стандартные подсистемы

---

## Топ популярных инструментов (по звёздам GitHub)

| Инструмент | Тип | ★ | Описание |
|---|---|---|---|
| Claude Code LSPs: bsl-lsp | LSP | 493 | BSL Language Server для Claude Code |
| 1C Skills for Claude Code | Skill | 469 | 72 skills для полного цикла |
| 1c_mcp | MCP-конструктор | 458 | MCP-серверы на платформе 1С |
| ast-index | MCP | 492 | Структурный поиск по BSL |
| 1C MCP Toolkit | MCP+Skill | 196 | Интеграция AI с базами 1С |
| BSL Context | MCP | 181 | Справка платформы для AI |
| EDT-MCP | MCP+IDE | 215 | MCP-host внутри 1C:EDT |
| 1C AI Feature Dev Workflow | Skill | 147 | Workflow разработки фич |
| 1C AI Development Kit | Skill | 146 | Инструкции для AI на 1С |
| CodePilot1C MCP Host | MCP+IDE | 137 | MCP-плагин для 1C:EDT |

---

## Типы инструментов

- **MCP** (Model Context Protocol) — доступ к метаданным, коду, справке
- **Skills/Rules** — инструкции для ИИ-агента
- **LSP** — диагностика, навигация, форматирование BSL
- **IDE** — плагины для EDT, Cursor, VS Code

---

## Ключевые категории

| Категория | Кол-во |
|---|---|
| Метаданные конфигурации | 33 |
| Кодовая база | 31 |
| Проверка кода | 27 |
| Справка платформы и BSL | 23 |
| Данные и запросы | 21 |
| Агентские навыки | 24 |
| Формы | 16 |
| Среда разработки | 17 |

---

## Рабочая схема

```
Разработчик → ИИ-агент → MCP/Skills/LSP → Контекст 1С
```

**Три обязательных слоя:**
1. ИИ-агент — принимает задачу, вызывает инструменты
2. MCP-серверы — дают доступ к метаданным, BSL, формам, справке
3. Skills/Rules — задают стандарты, ограничения, порядок действий

---

## Среды подключения

- **Cursor** — MCP-серверы для метаданных, BSL, справки
- **Claude Code** — терминальный агент с MCP-доступом
- **Codex** — локальный проект + MCP-контекст
- **1C:EDT** — полноценная IDE с MCP-интеграцией

---

## Самые популярные инструменты

### ИИ-агент: Claude Code

Самый популярный ИИ-агент для разработки на 1С. Подтверждается количеством инструментов, созданных именно под него:

| Инструмент | ★ | Ссылка |
|---|---|---|
| Claude Code LSPs: bsl-lsp | 493 | https://github.com/Piebald-AI/claude-code-lsps |
| 1C Skills for Claude Code | 469 | https://github.com/Nikolay-Shirokov/cc-1c-skills |
| Claude Code BSL LSP | 33 | https://github.com/1c-syntax/claude-code-bsl-lsp |
| Claude Code Skills for 1C | 32 | https://github.com/Desko77/claude-code-skills-1c |

### MCP-сервер: 1c_mcp

Самый популярный MCP-сервер для 1С — **458 ★**

- **Автор:** vladimir-kharin
- **GitHub:** https://github.com/vladimir-kharin/1c_mcp
- **Описание:** Конструктор MCP-серверов на платформе 1С. Расширение берёт на себя техническую часть протокола (MCP, resources, prompts), а разработчик реализует бизнес-логику tools в обработках. Поддерживает обнаружение контейнеров из других расширений.

### Топ-5 MCP-серверов для 1С

| MCP-сервер | ★ | GitHub |
|---|---|---|
| 1c_mcp | 458 | https://github.com/vladimir-kharin/1c_mcp |
| EDT-MCP | 215 | https://github.com/DitriXNew/EDT-MCP |
| 1C MCP Toolkit | 196 | https://github.com/ROCTUP/1c-mcp-toolkit |
| BSL Context | 181 | https://github.com/alkoleft/mcp-bsl-platform-context |
| CodePilot1C MCP Host | 137 | https://github.com/ondysss/codepilot1c-edt |

---

## Ресурсы

- Каталог: https://aitools1c.dev/tools/
- Гайды: https://aitools1c.dev/guides/
- Глоссарий: https://aitools1c.dev/glossary/
