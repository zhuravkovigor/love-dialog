-- Type definitions for love-dialog library
-- This file provides JSDoc-style type annotations for better IDE support

---@meta

---@class DialogConfig
---@field textSpeed? number Speed of text appearance (seconds per character, default: 0.05)
---@field backgroundColor? table RGBA color for dialog background (default: {0.2, 0.2, 0.2, 0.8})
---@field textColor? table RGBA color for dialog text (default: {1, 1, 1, 1})
---@field nameColor? table RGBA color for character name (default: {1, 1, 0.5, 1})
---@field choiceColor? table RGBA color for choice options (default: {0.8, 0.8, 1, 1})
---@field choiceSelectedColor? table RGBA color for selected choice (default: {1, 1, 1, 1})
---@field fontSize? number Font size for dialog text (default: 16)
---@field nameFontSize? number Font size for character name (default: 20)
---@field fontPath? string Path to custom font for text (nil = default font)
---@field nameFontPath? string Path to custom font for name (nil = default font)
---@field padding? number Padding inside dialog box (default: 20)
---@field dialogHeight? number Height of dialog box (default: 150)
---@field showBackground? boolean Show default background (default: true)
---@field namePosition? "top"|"left"|"none" Position of character name (default: "top")

---@class DialogChoice
---@field text string Text to display for this choice
---@field key? string Identifier for this choice
---@field value? any Value associated with this choice
---@field callback? fun(key: string?, value: any?) Function to call when choice is selected
---@field next? DialogData|fun(): DialogData Next dialog or function returning next dialog

---@class DialogData
---@field text string The text content of the dialog
---@field name? string Name of the character speaking
---@field key? string Identifier for this dialog (for character variations)
---@field choices? DialogChoice[] Array of choice options
---@field callback? fun() Function to call when dialog finishes

---@class Dialog
---@field config DialogConfig Configuration for this dialog instance
---@field font love.Font Font object for dialog text
---@field name_font love.Font Font object for character name
---@field current_dialog DialogData|nil Currently active dialog data
---@field current_text string Current full text to display
---@field displayed_text string Currently displayed portion of text
---@field text_timer number Timer for text animation
---@field is_text_complete boolean Whether text animation is complete
---@field is_active boolean Whether dialog is currently active
---@field choices DialogChoice[] Current available choices
---@field selected_choice number Index of currently selected choice
---@field callback fun()|nil Callback function for when dialog closes
---@field dialog_tree DialogData Original dialog data tree
local Dialog = {}

---Create a new dialog instance
---@param config? DialogConfig Configuration options
---@return Dialog dialog New dialog instance
function Dialog.new(config) end

---Start a new dialog
---@param dialog_data DialogData Dialog data to display
---@param callback? fun() Function to call when dialog ends
function Dialog:start(dialog_data, callback) end

---Update dialog state (call in love.update)
---@param dt number Delta time in seconds
function Dialog:update(dt) end

---Handle key press events (call in love.keypressed)
---@param key string Key that was pressed
function Dialog:keypressed(key) end

---Draw the dialog (call in love.draw)
function Dialog:draw() end

---Close the current dialog
function Dialog:close() end

---Check if dialog is currently active
---@return boolean active Whether dialog is active
function Dialog:isActive() end

---Update dialog configuration
---@param config DialogConfig New configuration options
function Dialog:setConfig(config) end

---Skip text animation and show full text immediately
function Dialog:skipTextAnimation() end

return Dialog
