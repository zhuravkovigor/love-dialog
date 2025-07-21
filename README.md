# Love Dialog

A modern dialog system library for LÖVE2D games with typewriter text animation, branching dialogs, and extensive customization options.

## ✨ Features

- **Typewriter Animation**: Letter-by-letter text display with configurable speed
- **Dialog Branching**: Complex dialog trees with choices and conditional paths
- **Mouse & Keyboard Support**: Unified selection system for both input methods
- **Customizable UI**: Full control over appearance or use default styled components
- **Character System**: Associate dialogs with character keys for easy management
- **Font Support**: Custom fonts for text and character names
- **Responsive Design**: Automatic text wrapping and choice centering

## 🚀 Quick Start

```lua
local Dialog = require("libs.love-dialog")

-- Create dialog with default settings
local dialog = Dialog.new()

-- Or with custom configuration
local dialog = Dialog.new({
    text_speed = 0.03,
    background_color = {0.1, 0.1, 0.2, 0.9},
    text_color = {0.9, 0.9, 1, 1},
    choice_color = {0.7, 0.9, 1, 1},
    choice_selected_color = {1, 1, 0.8, 1},
    font_size = 18,
    dialog_height = 120,
    show_background = true
})

function love.load()
    -- Simple dialog example
    local simple_dialog = {
        name = "System",
        text = "Welcome! Ready to start?",
        choices = {
            {
                text = "Yes, let's go!",
                key = "start",
                callback = function(key, value)
                    print("User chose to start")
                end
            },
            {
                text = "Not now",
                key = "cancel"
            }
        }
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

function love.mousepressed(x, y, button)
    dialog:mousepressed(x, y, button)
end

function love.mousemoved(x, y)
    dialog:mousemoved(x, y)
end
```

```

## 📖 Dialog Structure

### Basic Dialog
```lua
local dialog_data = {
    text = "Hello, world!",          -- Required: dialog text
    name = "Character Name",         -- Optional: character name
    key = "unique_dialog_id"         -- Optional: unique identifier
}
```

### Dialog with Choices
```lua
local branching_dialog = {
    text = "What would you like to do?",
    name = "Guide",
    choices = {
        {
            text = "Option 1",
            key = "choice1",
            next = {
                text = "You chose option 1!",
                name = "Guide"
            }
        },
        {
            text = "Option 2", 
            key = "choice2",
            callback = function(key, value)
                -- Handle choice selection
                print("Selected:", key)
            end,
            next = function()
                -- Dynamic next dialog
                return {
                    text = "Dynamic response!",
                    name = "Guide"
                }
            end
        }
    }
}
```

## ⚙️ Configuration Options

```lua
local config = {
    -- Text animation
    text_speed = 0.03,                    -- Seconds per character
    
    -- Colors (RGBA format)
    background_color = {0.1, 0.1, 0.2, 0.9},
    text_color = {0.9, 0.9, 1, 1},
    name_color = {1, 0.8, 0.6, 1},
    choice_color = {0.7, 0.9, 1, 1},
    choice_selected_color = {1, 1, 0.8, 1},
    
    -- Fonts
    font_size = 18,
    name_font_size = 22,
    font_path = "path/to/font.ttf",       -- Optional custom font
    name_font_path = "path/to/bold.ttf",  -- Optional custom name font
    
    -- Layout
    padding = 20,
    dialog_height = 120,
    name_position = "top",                -- "top", "left", "none"
    show_background = true,               -- Enable/disable default background
    
    -- Custom rendering callbacks
    custom_background_draw = function(dialog, x, y, width, height)
        -- Custom background rendering
    end,
    custom_text_draw = function(dialog, text, x, y, width)
        -- Custom text rendering
    end,
    custom_name_draw = function(dialog, name, x, y)
        -- Custom name rendering
    end,
    custom_choices_draw = function(dialog)
        -- Custom choice rendering
    end
}
```

## 🎮 Controls

### Keyboard
- **↑/↓ Arrow Keys**: Navigate choices
- **Enter/Space**: Select choice or skip text animation
- **Escape**: Close dialog

### Mouse
- **Click**: Select choice or skip text animation
- **Hover**: Highlight choices
- **Move**: Update selection

## 🌟 Advanced Examples

### Complex Branching Dialog
```lua
local complex_dialog = {
    text = "Welcome to the adventure! What's your class?",
    name = "Elder",
    key = "class_selection",
    choices = {
        {
            text = "Warrior",
            key = "warrior",
            value = {class = "warrior", hp = 100},
            next = {
                text = "A mighty warrior! Your journey begins...",
                name = "Elder",
                key = "warrior_intro"
            },
            callback = function(key, value)
                -- Save player class
                player.class = value.class
                player.hp = value.hp
            end
        },
        {
            text = "Mage",
            key = "mage", 
            value = {class = "mage", mp = 100},
            next = function()
                -- Dynamic dialog based on game state
                if player.has_magic_item then
                    return {
                        text = "A mage with a magic item! Impressive!",
                        name = "Elder"
                    }
                else
                    return {
                        text = "A wise choice. Magic flows through you.",
                        name = "Elder"
                    }
                end
            end
        }
    }
}
```

### Custom Rendering
```lua
local custom_dialog = Dialog.new({
    show_background = false,
    custom_background_draw = function(dialog, x, y, width, height)
        -- Draw custom background with gradient
        love.graphics.setColor(0.2, 0.1, 0.3, 0.8)
        love.graphics.rectangle("fill", x, y, width, height)
        
        -- Add border
        love.graphics.setColor(0.6, 0.4, 0.8, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, width, height)
    end,
    custom_choices_draw = function(dialog)
        -- Custom choice rendering with animations
        -- Implementation depends on your needs
    end
})
```

## 📝 API Reference

### Dialog Methods

#### `Dialog.new(config?)`
Creates a new dialog instance with optional configuration.

#### `dialog:start(dialog_data, callback?)`
Starts a dialog with the given data and optional completion callback.

#### `dialog:update(dt)`
Updates the dialog animation. Call this in `love.update(dt)`.

#### `dialog:draw()`
Renders the dialog. Call this in `love.draw()`.

#### `dialog:keypressed(key)`
Handles keyboard input. Call this in `love.keypressed(key)`.

#### `dialog:mousepressed(x, y, button)`
Handles mouse clicks. Call this in `love.mousepressed(x, y, button)`.

#### `dialog:mousemoved(x, y)`
Handles mouse movement for choice highlighting. Call this in `love.mousemoved(x, y)`.

#### `dialog:isActive()`
Returns true if dialog is currently active.

#### `dialog:close()`
Manually closes the dialog.

#### `dialog:setConfig(config)`
Updates dialog configuration.

#### `dialog:skipTextAnimation()`
Immediately shows full text, skipping animation.

## 📄 License

MIT License - feel free to use in your projects!

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

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
