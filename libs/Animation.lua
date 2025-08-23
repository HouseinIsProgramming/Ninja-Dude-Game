local Animation = {}
Animation.__index = Animation

--- this creates a new Animation object
---@param sprite_path_suffixes string[]
---@param sprite_base_path string
---@param frame_duration number
---@param paddingX number
---@param paddingT number
function Animation:new(
	sprite_path_suffixes,
	sprite_base_path,
	frame_duration,
	paddingX,
	paddingT
)
	local anim = {}
	setmetatable(anim, self)

	anim.frame_data = {}
	anim.current_frame_index = 1
	anim.frame_duration = frame_duration
	anim.animation_timer = 0

	anim.paddingX = paddingX
	anim.paddingY = paddingT

	local calculated_base_width = 0
	local calculated_base_height = 0

	-- local img_base_path = "src/images/entities/player"
	--
	-- local idle_sprite_paths = {
	-- 	img_base_path .. "/idle/00.png",
	-- 	img_base_path .. "/idle/01.png",
	-- 	img_base_path .. "/idle/02.png",
	-- 	img_base_path .. "/idle/03.png",
	-- 	img_base_path .. "/idle/04.png",
	-- 	img_base_path .. "/idle/05.png",
	-- 	img_base_path .. "/idle/06.png",
	-- 	img_base_path .. "/idle/07.png",
	-- 	img_base_path .. "/idle/08.png",
	-- 	img_base_path .. "/idle/09.png",
	-- }

	for i, path_s in ipairs(sprite_path_suffixes) do
		local full_path = sprite_base_path .. path_s
		local img = love.graphics.newImage(full_path)
		local full_width = img:getWidth()
		local full_height = img:getHeight()

		local visible_quad = {
			x = self.paddingX,
			y = self.paddingY,
			w = full_width - (self.paddingX * 2),
			h = full_height - self.paddingY,
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

	self.base_width = calculated_base_width
	self.base_height = calculated_base_height

	return anim
end

function Animation:update(dt)
	self.animation_timer = self.animation_timer + dt
	if self.animation_timer > self.frame_duration then
		self.current_frame_index = self.current_frame_index + 1
		if self.current_frame_index > #self.idle_frames then
			self.current_frame_index = 1
		end
		self.animation_timer = 0
	end
end

function Animation:draw(x, y, r, sx, sy, ox, oy, kx, ky)
	local curr_frame = self.frame_data[self.current_frame_index]
	love.graphics.draw(
		curr_frame.img,
		curr_frame.qd,
		x,
		y,
		r,
		sx,
		sy,
		ox,
		oy,
		kx,
		ky
	)
end

return Animation
