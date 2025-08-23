local player = {}

function player:load()
	local img_base_path = "src/images/entities/player"

	local idle_sprite_paths = {
		img_base_path .. "/idle/00.png",
		img_base_path .. "/idle/01.png",
		img_base_path .. "/idle/02.png",
		img_base_path .. "/idle/03.png",
		img_base_path .. "/idle/04.png",
		img_base_path .. "/idle/05.png",
		img_base_path .. "/idle/06.png",
		img_base_path .. "/idle/07.png",
		img_base_path .. "/idle/08.png",
		img_base_path .. "/idle/09.png",
	}

	self.paddingY = 3
	self.paddingX = 2

	self.idle_frames = {}
	for i, path in ipairs(idle_sprite_paths) do
		-- self.idle_frames[i] = love.graphics.newImage(path)
		local img = love.graphics.newImage(path)
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
		self.idle_frames[i] = {
			img = img,
			qd = quad,
			vis_w = visible_quad.w,
			vis_h = visible_quad.h,
		}
	end

	self.current_frame_index = 1
	self.frame_duration = 0.1
	self.animation_timer = 0

	self.x = love.graphics.getWidth() / 2
	self.y = love.graphics.getHeight() / 2

	self.scale = 5

	self.base_width = self.idle_frames[1].vis_w
	self.base_height = self.idle_frames[1].vis_h

	self.speed = 1000

	self.width = self.base_width * self.scale
	self.height = self.base_height * self.scale
end

function player:update(dt)
	self.animation_timer = self.animation_timer + dt
	if self.animation_timer > self.frame_duration then
		self.current_frame_index = self.current_frame_index + 1
		if self.current_frame_index > #self.idle_frames then
			self.current_frame_index = 1
		end
		self.animation_timer = 0
	end

	self:movement(dt)
	self:checkBoundries()
	self:logEverything()
end

function player:draw()
	love.graphics.draw(
		self.idle_frames[self.current_frame_index].img,
		self.idle_frames[self.current_frame_index].qd,
		self.x,
		self.y,
		0,
		self.scale,
		self.scale
	)
end

function player:movement(dt)
	if love.keyboard.isDown("a") then
		self.x = self.x - self.speed * dt
	end

	if love.keyboard.isDown("d") then
		self.x = self.x + self.speed * dt
	end

	if love.keyboard.isDown("w") then
		self.y = self.y - self.speed * dt
	end

	if love.keyboard.isDown("s") then
		self.y = self.y + self.speed * dt
	end
end

function player:checkBoundries()
	if self.x > love.graphics.getWidth() - self.width then
		self.x = love.graphics.getWidth() - self.width
	end
	if self.x < 0 then
		self.x = 0
	end
	if self.y > love.graphics.getHeight() - self.height then
		self.y = love.graphics.getHeight() - self.height
	end
	if self.y < 0 then
		self.y = 0
	end
end

function player:logEverything()
	print("player.x: " .. self.x)
	print("player.y: " .. self.y)
	print("player.width: " .. self.width)
	print("player.height: " .. self.height)
	print("player.speed: " .. self.speed)
end

return player
