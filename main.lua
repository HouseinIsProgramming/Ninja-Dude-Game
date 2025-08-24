local Player = require("libs/player")
local Physics = require("libs.Physics")

local world
local PPM = 16
local groundBody
local groundShape
local groundFixture
local debugMode = false -- Toggle for physics debug rendering

-- Platform system
local platforms = {}
local groundData = {}

function love.load()
	print("Loading...")
	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	love.graphics.setBackgroundColor(0.2, 0.5, 0.8)

	world = love.physics.newWorld(0, 20 * PPM, true)

	Player:setPhysicsContext(world, PPM)
	Player:load()

	-- Tell Physics.lua about the player AFTER it's loaded
	Physics.setPlayerRef(Player)

	world:setCallbacks(Physics.beginContact, Physics.endContact, Physics.preSolve, Physics.postSolve)

	-- Create main ground
	local groundWidth_px = love.graphics.getWidth()
	local groundHeight_px = 20
	
	groundData = {
		x = 0,
		y = love.graphics.getHeight() - groundHeight_px,
		width = groundWidth_px,
		height = groundHeight_px
	}

	groundBody = love.physics.newBody(
		world,
		(groundWidth_px / 2) / PPM,
		(love.graphics.getHeight() - (groundHeight_px / 2)) / PPM,
		"static"
	)
	groundShape = love.physics.newRectangleShape(groundWidth_px / PPM, groundHeight_px / PPM)
	groundFixture = love.physics.newFixture(groundBody, groundShape, 1)
	groundFixture:setUserData("ground")

	-- Create platforms
	local platformConfigs = {
		{x = 200, y = 400, width = 120, height = 15},
		{x = 450, y = 320, width = 100, height = 15},
		{x = 100, y = 280, width = 80, height = 15},
		{x = 600, y = 250, width = 140, height = 15},
		{x = 350, y = 180, width = 90, height = 15}
	}

	for i, config in ipairs(platformConfigs) do
		local platform = {
			-- Visual data
			x = config.x,
			y = config.y,
			width = config.width,
			height = config.height,
			
			-- Physics data
			body = love.physics.newBody(
				world,
				(config.x + config.width / 2) / PPM,
				(config.y + config.height / 2) / PPM,
				"static"
			),
			shape = love.physics.newRectangleShape(config.width / PPM, config.height / PPM)
		}
		
		platform.fixture = love.physics.newFixture(platform.body, platform.shape, 1)
		platform.fixture:setUserData("ground")
		
		platforms[i] = platform
	end

	-- PLAYER = love.graphics.newImage("src/images/entities/player/idle/00.png")
	-- MUSIC = love.audio.newSource("src/music.wav", "stream")
	-- love.audio.play(MUSIC)
	print("Loaded!")
end

function love.update(dt)
	Player:update(dt)
	world:update(dt)
end

function love.draw()
	-- Draw visible ground and platforms
	love.graphics.setColor(0, 0.8, 0, 1)  -- Green color
	
	-- Draw main ground
	love.graphics.rectangle("fill", groundData.x, groundData.y, groundData.width, groundData.height)
	
	-- Draw platforms
	for _, platform in ipairs(platforms) do
		love.graphics.rectangle("fill", platform.x, platform.y, platform.width, platform.height)
	end
	
	-- Reset color for player
	love.graphics.setColor(1, 1, 1, 1)
	Player:draw()

	-- Debug mode: Draw physics hitboxes
	if debugMode then
		love.graphics.setLineStyle("rough")
		love.graphics.setLineWidth(2) -- Make hitboxes more visible
		love.graphics.setColor(1, 0, 0, 1) -- Red for all hitboxes

		for _, body in ipairs(world:getBodies()) do
			-- Only draw active bodies for performance/clarity
			if body:isActive() then
				local px, py = body:getPosition()
				local rotation = body:getAngle()

				for _, fixture in ipairs(body:getFixtures()) do
					local shape = fixture:getShape()
					local shape_type = shape:getType()

					-- All hitboxes are red in debug mode
					love.graphics.setColor(1, 0, 0, 1)

					-- Convert local points (on shape) to world points (on screen)
					-- Apply body's position, rotation, and PPM scaling
					local points = { shape:getPoints() } -- Get points in local body coordinates (meters)
					local worldPoints_px = {}
					for i = 1, #points, 2 do
						local x_local = points[i]
						local y_local = points[i + 1]
						-- Convert local body point to world point, then to pixels
						local wx, wy = body:getWorldPoint(x_local, y_local)
						table.insert(worldPoints_px, wx * PPM)
						table.insert(worldPoints_px, wy * PPM)
					end

					-- Draw the shape as a polygon using pixel coordinates
					love.graphics.polygon("line", worldPoints_px)

					-- Optionally draw circles for CircleShape (getPoints doesn't work well for circles)
					if shape_type == "circle" then
						local radius = shape:getRadius()
						love.graphics.circle("line", px * PPM, py * PPM, radius * PPM)
					end
				end
			end
		end

		-- Reset line width
		love.graphics.setLineWidth(1)
	end

	love.graphics.setColor(1, 1, 1, 1)
end

function love.keypressed(key)
	if key == "p" then
		debugMode = not debugMode
		print("Debug mode:", debugMode and "ON" or "OFF")
	end
end
