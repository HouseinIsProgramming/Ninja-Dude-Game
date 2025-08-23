local Anim = require("libs.Animation")

local player = {}

function player:load()
	local img_base_path = "src/images/entities/player"

	local path_suffixes = {
		idle_suffixes = {
			"/idle/00.png",
			"/idle/01.png",
			"/idle/02.png",
			"/idle/03.png",
			"/idle/04.png",
			"/idle/05.png",
			"/idle/06.png",
			"/idle/07.png",
			"/idle/08.png",
			"/idle/09.png",
			"/idle/10.png",
			"/idle/11.png",
			"/idle/12.png",
			"/idle/13.png",
			"/idle/14.png",
			"/idle/15.png",
			"/idle/16.png",
			"/idle/17.png",
			"/idle/18.png",
			"/idle/19.png",
			"/idle/20.png",
			"/idle/21.png",
		},

		jump_suffixes = {
			"/jump/0.png",
		},

		run_suffixes = {
			"/run/0.png",
			"/run/1.png",
			"/run/2.png",
			"/run/3.png",
			"/run/4.png",
			"/run/5.png",
			"/run/6.png",
			"/run/7.png",
		},

		slide_suffixes = {
			"/slide/0.png",
		},

		wall_slide_suffixes = {
			"/wall_slide/0.png",
		},
	}

	self.paddingX = 2
	self.paddingT = 1

	self.animations = {
		idle = Anim:new(
			path_suffixes.idle_suffixes,
			img_base_path,
			0.1,
			self.paddingX,
			self.paddingT
		),
		jump = Anim:new(
			path_suffixes.jump_suffixes,
			img_base_path,
			0.1,
			self.paddingX,
			self.paddingT
		),
		run = Anim:new(
			path_suffixes.run_suffixes,
			img_base_path,
			0.1,
			self.paddingX,
			self.paddingT
		),
		slide = Anim:new(
			path_suffixes.slide_suffixes,
			img_base_path,
			0.1,
			self.paddingX,
			self.paddingT
		),
		wall_slide = Anim:new(
			path_suffixes.wall_slide_suffixes,
			img_base_path,
			0.1,
			self.paddingX,
			self.paddingT
		),
	}

	self.current_animation = self.animations.idle

	self.state = "idle"
	self.facing = "right"

	self.x = love.graphics.getWidth() / 2
	self.y = love.graphics.getHeight() / 2

	self.scale = 5

	self.speed = 1000

	self.base_width = self.animations.idle.base_width
	self.base_height = self.animations.idle.base_height
	self.width = self.base_width * self.scale
	self.height = self.base_height * self.scale
end

function player:update(dt)
	self:movement(dt)
	self:animation_state(dt)
	self:checkBoundries()
	self:logEverything()
end

function player:draw()
	self.current_animation:draw(self.x, self.y, 0, self.scale, self.scale)
end

function player:animation_state(dt)
	self.current_animation:update(dt)

	local new_state = "idle"
	if love.keyboard.isDown("a") then
		new_state = "run"
		self.facing = "left"
	elseif love.keyboard.isDown("d") then
		new_state = "run"
		self.facing = "right"
	elseif love.keyboard.isDown("w") then
		new_state = "jump"
	elseif love.keyboard.isDown("s") then
		new_state = "slide"
	end

	-- Switch animation if state changed
	if new_state ~= self.state then
		self.state = new_state
		-- Reset animation to first frame when switching
		self.current_animation = self.animations[self.state]
		self.current_animation.current_frame_index = 1
		self.current_animation.animation_timer = 0
	end
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
