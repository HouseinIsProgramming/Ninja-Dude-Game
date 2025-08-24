local Animation = {}
Animation.__index = Animation

--- this creates a new Animation object
---@param sprite_path_suffixes table
---@param sprite_base_path string
---@param frame_duration number
---@param paddingX number
---@param paddingT number
function Animation:new(sprite_path_suffixes, sprite_base_path, frame_duration, paddingX, paddingT)
	local anim = {}
	setmetatable(anim, self)

	anim.frame_data = {}
	anim.current_frame_index = 1
	anim.frame_duration = frame_duration
	anim.animation_timer = 0

	anim.paddingX = paddingX
	anim.paddingT = paddingT

	local calculated_base_width = 0
	local calculated_base_height = 0

	for i, path_s in ipairs(sprite_path_suffixes) do
		local full_path = sprite_base_path .. path_s

		-- Load as ImageData first, then process to remove black background
		local imageData = love.image.newImageData(full_path)

		imageData:mapPixel(function(_, _, r, g, b, a)
			-- If pixel is black (or very close to black), make it transparent
			if r < 0.1 and g < 0.1 and b < 0.1 then
				return r, g, b, 0 -- Set alpha to 0 (transparent)
			end
			return r, g, b, a -- Keep original pixel
		end)

		local img = love.graphics.newImage(imageData)
		local full_width = img:getWidth()
		local full_height = img:getHeight()

		local visible_quad = {
			x = anim.paddingX,
			y = anim.paddingT,
			w = full_width - (anim.paddingX * 2),
			h = full_height - anim.paddingT,
		}

		local quad = love.graphics.newQuad(
			visible_quad.x,
			visible_quad.y,
			visible_quad.w,
			visible_quad.h,
			full_width,
			full_height
		)
		anim.frame_data[i] = {
			img = img,
			qd = quad,
			vis_w = visible_quad.w,
			vis_h = visible_quad.h,
		}

		if i == 1 then
			calculated_base_width = visible_quad.w
			calculated_base_height = visible_quad.h
		end
	end

	anim.base_width = calculated_base_width
	anim.base_height = calculated_base_height

	return anim
end

function Animation:update(dt)
	self.animation_timer = self.animation_timer + dt
	if self.animation_timer > self.frame_duration then
		self.current_frame_index = self.current_frame_index + 1
		if self.current_frame_index > #self.frame_data then
			self.current_frame_index = 1
		end
		self.animation_timer = 0
	end
end

function Animation:draw(x, y, r, sx, sy, ox, oy, kx, ky)
	local curr_frame = self.frame_data[self.current_frame_index]
	love.graphics.draw(curr_frame.img, curr_frame.qd, x, y, r, sx, sy, ox, oy, kx, ky)
end

return Animation
