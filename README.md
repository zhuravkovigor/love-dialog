# Love Dialog Library

Библиотека для создания диалоговых систем в LÖVE2D с поддержкой анимированного текста, веток диалогов и кастомизации.

## Основные возможности

- Анимированный вывод текста по символам
- Система ветвления диалогов
- Настраиваемые шрифты и цвета
- Поддержка вариантов ответов
- Возможность отключения UI по умолчанию
- Система ключей для персонажей

## Быстрый старт

```lua
local Dialog = require("libs/love-dialog")

-- Создание диалога с настройками по умолчанию
local dialog = Dialog.new()

-- Или с кастомными настройками
local dialog = Dialog.new({
    text_speed = 0.03,
    font_path = "fonts/custom.ttf",
    name_font_path = "fonts/bold.ttf",
    font_size = 18,
    name_font_size = 24,
    show_background = false
})

function love.load()
    -- Пример простого диалога
    local simple_dialog = {
        key = "hero",
        name = "Герой",
        text = "Привет! Как дела?"
    }

    dialog:start(simple_dialog)
end

function love.update(dt)
    dialog:update(dt)
end

function love.draw()
    dialog:draw()
end

function love.keypressed(key)
    dialog:keypressed(key)
end
```

## Структура диалога

### Простой диалог

```lua
local simple_dialog = {
    key = "character_id",        -- Ключ персонажа
    name = "Имя персонажа",      -- Имя для отображения
    text = "Текст диалога"       -- Текст для показа
}
```

### Диалог с вариантами ответов

```lua
local dialog_with_choices = {
    key = "npc",
    name = "НПС",
    text = "Что ты хочешь узнать?",
    choices = {
        {
            text = "О городе",
            key = "city_info",
            callback = function(key, value)
                print("Выбрана информация о городе")
            end,
            next = {
                key = "npc",
                name = "НПС",
                text = "Этот город очень древний..."
            }
        },
        {
            text = "О квестах",
            key = "quests",
            next = function()
                -- Динамическое создание следующего диалога
                return {
                    key = "npc",
                    name = "НПС",
                    text = "У меня есть задание для тебя!"
                }
            end
        },
        {
            text = "Пока",
            key = "goodbye"
            -- Если next не указан, диалог закроется
        }
    }
}
```

## Конфигурация шрифтов

```lua
local config = {
    text_speed = 0.05,                      -- Скорость печати текста
    background_color = {0.2, 0.2, 0.2, 0.8}, -- Цвет фона
    text_color = {1, 1, 1, 1},              -- Цвет текста
    name_color = {1, 1, 0.5, 1},            -- Цвет имени
    choice_color = {0.8, 0.8, 1, 1},        -- Цвет вариантов
    choice_selected_color = {1, 1, 1, 1},   -- Цвет выбранного варианта
    font_size = 16,                         -- Размер шрифта текста
    name_font_size = 20,                    -- Размер шрифта имени
    font_path = "fonts/main.ttf",           -- Путь к шрифту текста (nil = шрифт по умолчанию)
    name_font_path = "fonts/bold.ttf",      -- Путь к шрифту имени (nil = шрифт по умолчанию)
    padding = 20,                           -- Отступы
    dialog_height = 150,                    -- Высота диалогового окна
    show_background = true,                 -- Показывать фон
    name_position = "top"                   -- Позиция имени: "top", "left", "none"
}

dialog:setConfig(config)
```

## Управление

- **Пробел/Enter** - Пропустить анимацию текста или выбрать вариант ответа
- **Стрелки вверх/вниз** - Навигация по вариантам ответов
- **Escape** - Закрыть диалог
