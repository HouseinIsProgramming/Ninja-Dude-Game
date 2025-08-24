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
	--
	local vx, vy = self.body:getLinearVelocity()

	if love.keyboard.isDown("space") and self.isGrounded then
		self.body:applyLinearImpulse(0, -10 * self.body:getMass())
		self.isGrounded = false
	end

	local target_vx = 0
	if not love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
		if love.keyboard.isDown("a") then
			target_vx = -self.speed / PPM
			self.facing = "left"
		end
		if love.keyboard.isDown("d") then
			target_vx = self.speed / PPM
			self.facing = "right"
		end
	end

	local force_x = (target_vx - vx) * self.body:getMass() * 10
	self.body:applyForce(force_x, 0)

	if math.abs(vx) > self.speed / PPM then
		self.body:setLinearVelocity(math.sign(x) * math.abs(target_vx), vy)
	end

	-- slow down faster
	if target_vx == 0 and self.isGrounded then
		local current_vx = self.body:getLinearVelocity()
		self.body:setLinearVelocity(current_vx * 0.9, vy)
	end

	local desired_state = "idle"
	if not self.isGrounded then
		if vy > 5 / PPM then
			desired_state = "wall_slide"
		elseif vy < -5 / PPM then
			desired_state = "jump"
		end
	else -- Player is grounded
		if target_vx ~= 0 then
			desired_state = "run"
		else
			desired_state = "idle"
		end
	end

	if desired_state ~= self.state then
		self.state = desired_state
		self.current_animation = self.animations[self.state]
		self.current_animation.current_frame_index = 1 -- Reset animation to first frame
		self.current_animation.animation_timer = 0
	end

	self.current_animation:update(dt)

	-- self:checkBoundries()
	-- self:logEverything()
end

function player:draw()
	local current_animation_data = self.current_animation.frame_data[self.current_animation.current_frame_index]

	local px, py = self.body:getPosition()
	local rotation = self.body:getAngle()

	local draw_x = (px * PPM) - (self.width / 2)
	local draw_y = (py * PPM) - (self.height / 2)

	local origin_x = self.base_width / 2
	local origin_y = self.base_height / 2

	self.current_animation:draw(draw_x, draw_y, rotation, self.scale, self.scale, origin_x, origin_y)
end

function player:logEverything()
	local px, py = self.body:getPosition() -- Get position in meters
	local vx, vy = self.body:getLinearVelocity() -- Get velocity in meters/second

	print("player.physics_x (m): " .. px .. ", physics_y (m): " .. py)
	print("player.vx (m/s): " .. vx .. ", vy (m/s): " .. vy)
	print("player.width (scaled visual): " .. self.width) -- Visual width
	print("player.height (scaled visual): " .. self.height) -- Visual height
	print("player.speed (target, px/s): " .. self.speed)
	print("player.state: " .. self.state)
	print("player.isGrounded: " .. tostring(self.isGrounded))
end

return player
