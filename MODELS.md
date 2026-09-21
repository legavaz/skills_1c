# Модели OpenCode — переключение и настройка

Справочник по выбору и настройке моделей, используемых в OpenCode, в т.ч.
для режимов **Plan** и **Build**.

## Как переключить модель на лету

В TUI откройте команду:

```
/models
```

Полный идентификатор модели имеет формат `provider/model`, например
`opencode-go/deepseek-v4-flash`. Введите его в поле выбора.

## Уровень рассуждений (reasoning effort)

Для моделей DeepSeek доступны уровни рассуждений:

| Уровень | Назначение |
|---|---|
| `low` | Быстро, дёшево. Для рядовых правок (Build). |
| `high` | Глубже, дороже. Для планирования и сложных задач (Plan). |
| `max` | Максимально глубокое рассуждение. |

Задаётся опцией `reasoningEffort`. Переключение между вариантами/уровнями
на лету — горячая клавиша цикла вариантов (`variant_cycle`, см. `/keybinds`).

## Как настроить модель в конфиге

Конфиг: `opencode.json` / `opencode.jsonc` (или `.opencode/opencode.jsonc`
в проекте).

### Модель по умолчанию (на верхнем уровне)

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "model": "opencode-go/deepseek-v4-flash"
}
```

### Раздельные модели для Plan и Build (через `agent`)

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "plan": {
      "model": "opencode-go/deepseek-v4-flash",
      "options": { "reasoningEffort": "high" }
    },
    "build": {
      "model": "opencode-go/deepseek-v4-flash",
      "options": { "reasoningEffort": "low" }
    }
  }
}
```

- `agent.plan` — используется в режиме Plan (планирование; у этого агента
  по умолчанию запрещено редактирование файлов).
- `agent.build` — режим Build (основная работа).
- `options.reasoningEffort` — уровень рассуждений для выбранной модели.

### Варианты модели (variants)

Вместо дублирования можно задать именованные варианты одной модели:

```jsonc
{
  "provider": {
    "opencode-go": {
      "models": {
        "deepseek-v4-flash": {
          "variants": {
            "high": { "reasoningEffort": "high" },
            "low":  { "reasoningEffort": "low" }
          }
        }
      }
    }
  }
}
```

## Доступные модели DeepSeek (провайдер `opencode-go`)

| Модель | Reasoning effort | Комментарий |
|---|---|---|
| `deepseek-v4-flash` | low / high / max | Базовая, универсальная (используется по умолчанию) |
| `deepseek-v4.1-flash` | low / high / max | Обновлённая версия Flash |
| `deepseek-v4-pro` | high / max | Мощная (низкого уровня `low` нет) |
| `deepseek-v4-flash-vision-exp` | — | Flash с поддержкой изображений (vision) |

## Текущая настройка в проектах

Проект `edt` (и развёртывание через `restore.ps1 -Models`) использует:

- **Plan** → `opencode-go/deepseek-v4-flash` @ `high`
- **Build** → `opencode-go/deepseek-v4-flash` @ `low`

## Примечание

После изменения `opencode.json` / `opencode.jsonc` необходимо **перезапустить
OpenCode** — конфиг читается один раз при старте и не перезагружается на лету.