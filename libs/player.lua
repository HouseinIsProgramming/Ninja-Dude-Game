local Anim = require("libs.Animation")

local player = {}

local physicsWorld
local PPM

function player:setPhysicsContext(worldRef, ppmRef)
	physicsWorld = worldRef
	PPM = ppmRef
end

player.body = nil
player.fixture = nil
player.shape = nil

player.isGrounded = false

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
		idle = Anim:new(path_suffixes.idle_suffixes, img_base_path, 0.1, self.paddingX, self.paddingT),
		jump = Anim:new(path_suffixes.jump_suffixes, img_base_path, 0.1, self.paddingX, self.paddingT),
		run = Anim:new(path_suffixes.run_suffixes, img_base_path, 0.1, self.paddingX, self.paddingT),
		slide = Anim:new(path_suffixes.slide_suffixes, img_base_path, 0.1, self.paddingX, self.paddingT),
		wall_slide = Anim:new(path_suffixes.wall_slide_suffixes, img_base_path, 0.1, self.paddingX, self.paddingT),
	}

	self.current_animation = self.animations.idle

	self.state = "idle"
	self.facing = "right"

	self.scale = 5

	self.speed = 1000

	self.base_width = self.animations.idle.base_width
	self.base_height = self.animations.idle.base_height

	self.width = self.base_width * self.scale
	self.height = self.base_height * self.scale

	self.body = love.physics.newBody(
		physicsWorld,
		(love.graphics.getWidth() / 2 / PPM),
		(love.graphics.getWidth() / 2 / PPM),
		"dynamic"
	)

	self.body:setMass(1)

	self.shape = love.physics.newRectangleShape(self.base_width / PPM, self.base_height / PPM)

	self.fixture = love.physics.newFixture(self.body, self.shape, 1)

	self.fixture:setFriction(0.5)
	self.fixture:setRestitution(0)

	self.body:setFixedRotation(true)
	self.body:setUserData(self)
end

function player:update(dt)
	local vx, vy = self.body:getLinearVelocity()

	if love.keyboard.isDown("space") and self.isGrounded then
		self.body:applyLinearImpulse(0, -10 * self.body:getMass())
		self.isGrounded = false
	end

	local target_vx = 0
	if not love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
		if love.keyboard.isDown("a") then
			target_vx = -self.speed / PPM
		end
		if love.keyboard.isDown("d") then
			target_vx = self.speed / PPM
		end
	end

	local force_x = (target_vx - vx) * self.body:getMass() * 10
	self.body:applyForce(target_vx, 0)

	if math.abs(vx) > self.speed / PPM then
		self.body:setLinearVelocity(math.sign(x) * (self.speed / PPM), vy)
	end

	self:checkBoundries()
	self:logEverything()
end

function player:draw()
	local px, py = self.body.getPosition(self)
	local rotation = self.body.getAngle(self)

	local draw_x = (px * PPM) - (self.width / 2)
	local draw_y = (py * PPM) - (self.width / 2)

	local origin_x = self.base_width / 2
	local origin_y = self.base_height / 2

	self.current_animation:draw(draw_x, draw_y, rotation, self.scale, self.scale, origin_x, origin_y)
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
