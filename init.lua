-- love-dialog - Dialog system for LÖVE2D games
-- Provides letter-by-letter text display, character names, choices, and dialog trees

---@class DialogChoice
---@field text string Text of the choice
---@field key string Unique key for the choice
---@field value any? Optional value associated with the choice
---@field next DialogData|fun(): DialogData? Next dialog or function returning next dialog
---@field callback fun(key: string, value: any)? Callback function when choice is selected

---@class DialogData
---@field text string The dialog text to display
---@field name string? Character name
---@field key string? Unique key for this dialog
---@field choices DialogChoice[]? Array of choice options

---@class DialogConfig
---@field text_speed number? Speed of text appearance (seconds per character)
---@field background_color number[]? Dialog background color [r, g, b, a]
---@field background_image love.Image? Background image
---@field background_image_mode "fill"|"fit"|"stretch"|"tile"? Image display mode
---@field text_color number[]? Text color [r, g, b, a]
---@field name_color number[]? Character name color [r, g, b, a]
---@field choice_color number[]? Choice text color [r, g, b, a]
---@field choice_selected_color number[]? Selected choice color [r, g, b, a]
---@field font_size number? Text font size
---@field name_font_size number? Name font size
---@field font_path string? Path to text font (nil = default font)
---@field name_font_path string? Path to name font (nil = default font)
---@field padding number? Padding
---@field dialog_height number? Dialog window height
---@field show_background boolean? Show default background
---@field name_position "top"|"left"|"none"? Name position
---@field custom_background_draw fun(dialog: Dialog, x: number, y: number, width: number, height: number)? Custom background draw
---@field custom_text_draw fun(dialog: Dialog, text: string, x: number, y: number, width: number)? Custom text draw
---@field custom_name_draw fun(dialog: Dialog, name: string, x: number, y: number)? Custom name draw
---@field custom_choices_draw fun(dialog: Dialog, choices: DialogChoice[], x: number, y: number, width: number)? Custom choices draw
---@field border_width number? Border thickness
---@field border_color number[]? Border color [r, g, b, a]
---@field corner_radius number? Corner radius for rounded rectangles

---@class Dialog
---@field config DialogConfig
---@field current_dialog DialogData?
---@field current_text string
---@field displayed_text string
---@field text_timer number
---@field is_text_complete boolean
---@field is_active boolean
---@field choices DialogChoice[]
---@field selected_choice number
---@field callback fun()?
---@field font love.Font
---@field name_font love.Font
local Dialog = {}
Dialog.__index = Dialog

-- Default configuration
local DEFAULT_CONFIG = {
	text_speed = 0.05,
	background_color = { 0, 0, 0, 0.8 },
	background_image = nil,
	background_image_mode = "fill",
	text_color = { 1, 1, 1, 1 },
	name_color = { 1, 1, 0, 1 },
	choice_color = { 0.8, 0.8, 1, 1 },
	choice_selected_color = { 1, 1, 1, 1 },
	font_size = 16,
	name_font_size = 18,
	font_path = nil,
	name_font_path = nil,
	padding = 20,
	dialog_height = 120, -- Smaller dialog height
	show_background = true,
	name_position = "top",
	custom_background_draw = nil,
	custom_text_draw = nil,
	custom_name_draw = nil,
	custom_choices_draw = nil,
	border_width = 0,
	border_color = { 1, 1, 1, 1 },
	corner_radius = 0,
}

---@param config DialogConfig?
---@return Dialog
function Dialog.new(config)
	local dialog = setmetatable({}, Dialog)

	dialog.config = {}
	for k, v in pairs(DEFAULT_CONFIG) do
		dialog.config[k] = v
	end

	if config then
		for k, v in pairs(config) do
			dialog.config[k] = v
		end
	end

	-- Create fonts
	if dialog.config.font_path then
		dialog.font = love.graphics.newFont(dialog.config.font_path, dialog.config.font_size)
	else
		dialog.font = love.graphics.newFont(dialog.config.font_size)
	end

	if dialog.config.name_font_path then
		dialog.name_font = love.graphics.newFont(dialog.config.name_font_path, dialog.config.name_font_size)
	else
		dialog.name_font = love.graphics.newFont(dialog.config.name_font_size)
	end

	dialog.current_dialog = nil
	dialog.current_text = ""
	dialog.displayed_text = ""
	dialog.text_timer = 0
	dialog.is_text_complete = false
	dialog.is_active = false
	dialog.choices = {}
	dialog.selected_choice = 1
	dialog.callback = nil

	-- Initialize choice bounds storage
	dialog.choice_bounds = {}

	return dialog
end

---@param dialog_data DialogData
---@param callback fun()|nil
function Dialog:start(dialog_data, callback)
	if type(dialog_data) == "table" then
		self.current_dialog = dialog_data
	else
		error("Dialog data must be a table")
	end

	self.callback = callback
	self.is_active = true
	self:_processCurrentDialog()
end

-- Process current dialog
function Dialog:_processCurrentDialog()
	if not self.current_dialog then
		return
	end

	-- Get dialog text
	self.current_text = self.current_dialog.text or ""
	self.displayed_text = ""
	self.text_timer = 0
	self.is_text_complete = false

	-- Process choice options
	self.choices = self.current_dialog.choices or {}
	self.selected_choice = 1
end

---@param dt number
function Dialog:update(dt)
	if not self.is_active then
		return
	end

	-- Text animation
	if not self.is_text_complete then
		self.text_timer = self.text_timer + dt
		local chars_to_show = math.floor(self.text_timer / self.config.text_speed)

		if chars_to_show >= #self.current_text then
			self.displayed_text = self.current_text
			self.is_text_complete = true
		else
			self.displayed_text = self.current_text:sub(1, chars_to_show)
		end
	end
end

---@param key string
function Dialog:keypressed(key)
	if not self.is_active then
		return
	end

	if key == "space" or key == "return" then
		if not self.is_text_complete then
			-- Skip text animation
			self.displayed_text = self.current_text
			self.is_text_complete = true
			return
		end

		if #self.choices > 0 then
			-- Select current choice
			self:_selectChoice(self.selected_choice)
		else
			-- Close dialog
			self:close()
		end
	elseif key == "up" and #self.choices > 0 then
		self.selected_choice = math.max(1, self.selected_choice - 1)
	elseif key == "down" and #self.choices > 0 then
		self.selected_choice = math.min(#self.choices, self.selected_choice + 1)
	elseif key == "escape" then
		self:close()
	end
end

---@param choice_index number
function Dialog:_selectChoice(choice_index)
	local choice = self.choices[choice_index]
	if not choice then
		return
	end

	-- Call callback if exists
	if choice.callback then
		choice.callback(choice.key, choice.value)
	end

	-- Move to next dialog if exists
	if choice.next then
		if type(choice.next) == "function" then
			self.current_dialog = choice.next()
		else
			self.current_dialog = choice.next
		end

		if self.current_dialog then
			self:_processCurrentDialog()
		else
			self:close()
		end
	else
		self:close()
	end
end

-- Close dialog
function Dialog:close()
	self.is_active = false
	self.current_dialog = nil

	if self.callback then
		self.callback()
	end
end

-- Draw dialog
function Dialog:draw()
	if not self.is_active or not self.current_dialog then
		return
	end

	local screen_width = love.graphics.getWidth()
	local screen_height = love.graphics.getHeight()

	-- Save current graphics settings
	local old_font = love.graphics.getFont()
	local old_color = { love.graphics.getColor() }

	local dialog_x = 0
	local dialog_y = screen_height - self.config.dialog_height
	local dialog_width = screen_width
	local dialog_height = self.config.dialog_height

	-- Custom background draw or default
	if self.config.custom_background_draw then
		self.config.custom_background_draw(self, dialog_x, dialog_y, dialog_width, dialog_height)
	elseif self.config.show_background then
		self:_drawDefaultBackground(dialog_x, dialog_y, dialog_width, dialog_height)
	end

	local text_x = self.config.padding
	local text_y = dialog_y + self.config.padding

	-- Custom name draw or default
	if self.current_dialog.name and self.config.name_position ~= "none" then
		if self.config.custom_name_draw then
			self.config.custom_name_draw(self, self.current_dialog.name, text_x, text_y)
			-- For custom name drawing, move down by default
			if self.config.name_position == "top" then
				text_y = text_y + self.name_font:getHeight() + 10
			end
		else
			text_x, text_y = self:_drawDefaultName(self.current_dialog.name, text_x, text_y)
		end
	end

	-- Custom text draw or default
	if self.config.custom_text_draw then
		self.config.custom_text_draw(self, self.displayed_text, text_x, text_y, screen_width - self.config.padding * 2)
	else
		self:_drawDefaultText(self.displayed_text, text_x, text_y, screen_width - self.config.padding * 2)
	end

	-- Custom choices draw or default (centered on screen)
	if self.is_text_complete and #self.choices > 0 then
		if self.config.custom_choices_draw then
			self.config.custom_choices_draw(
				self,
				self.choices,
				text_x,
				text_y + self.font:getHeight() * 3,
				screen_width - self.config.padding * 2
			)
		else
			self:_drawDefaultChoices()
		end
	end

	-- Restore graphics settings
	love.graphics.setFont(old_font)
	love.graphics.setColor(old_color[1], old_color[2], old_color[3], old_color[4])
end

-- Default background drawing
function Dialog:_drawDefaultBackground(x, y, width, height)
	-- Draw background image if exists
	if self.config.background_image then
		self:_drawBackgroundImage(x, y, width, height)
	end

	-- Draw colored background
	love.graphics.setColor(
		self.config.background_color[1],
		self.config.background_color[2],
		self.config.background_color[3],
		self.config.background_color[4]
	)

	love.graphics.rectangle("fill", x, y, width, height)

	-- Draw border if configured
	if self.config.border_width > 0 then
		love.graphics.setColor(
			self.config.border_color[1],
			self.config.border_color[2],
			self.config.border_color[3],
			self.config.border_color[4]
		)
		love.graphics.setLineWidth(self.config.border_width)
		love.graphics.rectangle("line", x, y, width, height)
	end
end

-- Draw background image
function Dialog:_drawBackgroundImage(x, y, width, height)
	local img = self.config.background_image
	local img_width = img:getWidth()
	local img_height = img:getHeight()

	love.graphics.setColor(1, 1, 1, 1)

	if self.config.background_image_mode == "stretch" then
		local scale_x = width / img_width
		local scale_y = height / img_height
		love.graphics.draw(img, x, y, 0, scale_x, scale_y)
	elseif self.config.background_image_mode == "fit" then
		local scale = math.min(width / img_width, height / img_height)
		local scaled_width = img_width * scale
		local scaled_height = img_height * scale
		local offset_x = (width - scaled_width) / 2
		local offset_y = (height - scaled_height) / 2
		love.graphics.draw(img, x + offset_x, y + offset_y, 0, scale, scale)
	elseif self.config.background_image_mode == "fill" then
		local scale = math.max(width / img_width, height / img_height)
		local scaled_width = img_width * scale
		local scaled_height = img_height * scale
		local offset_x = (width - scaled_width) / 2
		local offset_y = (height - scaled_height) / 2
		love.graphics.draw(img, x + offset_x, y + offset_y, 0, scale, scale)
	elseif self.config.background_image_mode == "tile" then
		for tile_x = x, x + width, img_width do
			for tile_y = y, y + height, img_height do
				love.graphics.draw(img, tile_x, tile_y)
			end
		end
	end
end

-- Default name drawing
function Dialog:_drawDefaultName(name, x, y)
	love.graphics.setFont(self.name_font)
	love.graphics.setColor(
		self.config.name_color[1],
		self.config.name_color[2],
		self.config.name_color[3],
		self.config.name_color[4]
	)

	if self.config.name_position == "top" then
		love.graphics.print(name, x, y)
		return x, y + self.name_font:getHeight() + 10
	elseif self.config.name_position == "left" then
		local name_text = name .. ": "
		love.graphics.print(name_text, x, y)
		return x + self.name_font:getWidth(name_text), y
	end

	return x, y
end

-- Default text drawing
function Dialog:_drawDefaultText(text, x, y, width)
	love.graphics.setFont(self.font)
	love.graphics.setColor(
		self.config.text_color[1],
		self.config.text_color[2],
		self.config.text_color[3],
		self.config.text_color[4]
	)
	love.graphics.printf(text, x, y, width)
end

-- Default choices drawing (centered on screen with background blocks)
function Dialog:_drawDefaultChoices()
	local screen_width = love.graphics.getWidth()
	local screen_height = love.graphics.getHeight()

	-- Clear previous choice bounds
	self.choice_bounds = {}

	-- Choice box settings
	local choice_padding = 15
	local choice_margin = 10
	local choice_height = self.font:getHeight() + choice_padding * 2

	-- Calculate total height of all choices
	local total_choices_height = #self.choices * choice_height + (#self.choices - 1) * choice_margin

	-- Center choices on screen
	local choices_start_y = (screen_height - total_choices_height) / 2
	local choice_y = choices_start_y

	love.graphics.setFont(self.font)

	for i, choice in ipairs(self.choices) do
		-- Calculate choice box sizing with better width calculation
		local min_width = 300 -- Minimum width for choice boxes
		local text_width = (self.font.getWidth and self.font:getWidth(choice.text)) or (#choice.text * 8)
		local box_width = math.max(min_width, text_width + choice_padding * 2)
		local choice_x = (screen_width - box_width) / 2

		-- Store bounds for mouse detection
		self.choice_bounds[i] = {
			x = choice_x,
			y = choice_y,
			width = box_width,
			height = choice_height,
		}

		-- Determine choice state
		local is_selected = i == self.selected_choice

		-- Draw choice background box
		if is_selected then
			-- Selected choice background
			love.graphics.setColor(
				self.config.choice_selected_color[1],
				self.config.choice_selected_color[2],
				self.config.choice_selected_color[3],
				self.config.choice_selected_color[4] * 0.4 -- More visible background
			)
			love.graphics.rectangle("fill", choice_x, choice_y, box_width, choice_height)

			-- Selected choice border
			love.graphics.setColor(
				self.config.choice_selected_color[1],
				self.config.choice_selected_color[2],
				self.config.choice_selected_color[3],
				self.config.choice_selected_color[4]
			)
			love.graphics.setLineWidth(3)
			love.graphics.rectangle("line", choice_x, choice_y, box_width, choice_height)

			-- Selected choice text
			love.graphics.setColor(
				self.config.choice_selected_color[1],
				self.config.choice_selected_color[2],
				self.config.choice_selected_color[3],
				self.config.choice_selected_color[4]
			)
			love.graphics.print(choice.text, choice_x + choice_padding, choice_y + choice_padding)
		else
			-- Normal choice background
			love.graphics.setColor(
				self.config.choice_color[1],
				self.config.choice_color[2],
				self.config.choice_color[3],
				self.config.choice_color[4] * 0.05 -- Very subtle background
			)
			love.graphics.rectangle("fill", choice_x, choice_y, box_width, choice_height)

			-- Normal choice border
			love.graphics.setColor(
				self.config.choice_color[1],
				self.config.choice_color[2],
				self.config.choice_color[3],
				self.config.choice_color[4] * 0.3
			)
			love.graphics.setLineWidth(1)
			love.graphics.rectangle("line", choice_x, choice_y, box_width, choice_height)

			-- Normal choice text
			love.graphics.setColor(
				self.config.choice_color[1],
				self.config.choice_color[2],
				self.config.choice_color[3],
				self.config.choice_color[4] * 0.8
			)
			love.graphics.print(choice.text, choice_x + choice_padding, choice_y + choice_padding)
		end

		choice_y = choice_y + choice_height + choice_margin
	end

	-- Reset line width
	love.graphics.setLineWidth(1)
end

---@return boolean
function Dialog:isActive()
	return self.is_active
end

---@param config DialogConfig
function Dialog:setConfig(config)
	for k, v in pairs(config) do
		self.config[k] = v
	end

	-- Update fonts if changed
	if config.font_size or config.font_path then
		if self.config.font_path then
			self.font = love.graphics.newFont(self.config.font_path, self.config.font_size)
		else
			self.font = love.graphics.newFont(self.config.font_size)
		end
	end

	if config.name_font_size or config.name_font_path then
		if self.config.name_font_path then
			self.name_font = love.graphics.newFont(self.config.name_font_path, self.config.name_font_size)
		else
			self.name_font = love.graphics.newFont(self.config.name_font_size)
		end
	end
end

-- Skip text animation
function Dialog:skipTextAnimation()
	if not self.is_text_complete then
		self.displayed_text = self.current_text
		self.is_text_complete = true
	end
end

---@param x number
---@param y number
---@param button number
function Dialog:mousepressed(x, y, button)
	if not self.is_active or button ~= 1 then -- Only left mouse button
		return
	end

	-- If text is not complete, skip animation on click
	if not self.is_text_complete then
		self.displayed_text = self.current_text
		self.is_text_complete = true
		return
	end

	-- Check if click is on any choice
	for i, bounds in ipairs(self.choice_bounds) do
		if x >= bounds.x and x <= bounds.x + bounds.width and y >= bounds.y and y <= bounds.y + bounds.height then
			-- Use the already selected choice (set by mousemoved)
			self:_selectChoice(self.selected_choice)
			return
		end
	end

	-- If no choices, close dialog on click
	if #self.choices == 0 then
		self:close()
	end
end

---@param x number
---@param y number
function Dialog:mousemoved(x, y)
	if not self.is_active or not self.is_text_complete or #self.choices == 0 then
		return
	end

	-- Check if mouse is over any choice and update selected_choice
	for i, bounds in ipairs(self.choice_bounds) do
		if x >= bounds.x and x <= bounds.x + bounds.width and y >= bounds.y and y <= bounds.y + bounds.height then
			self.selected_choice = i
			return
		end
	end
end

return Dialog
