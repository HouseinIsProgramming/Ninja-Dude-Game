local Player = require("libs/player")
local Physics = require("libs.Physics")

local world
local PPM = 32
local groundBody
local groundShape
local groundFixture

function love.load()
	print("Loading...")
	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	love.graphics.setBackgroundColor(0.2, 0.5, 0.8)

	world = love.physics.newWorld(0, 9.81 * PPM, true)

	Player:setPhysicsContext(world, PPM)

	world:setCallbacks(Physics.beginContact, Physics.endContact, Physics.preSolve, Physics.postSolve)

	Player:load()

	local groundWidth_px = love.graphics.getWidth()
	local groundHeight_px = 10

	groundBody = love.physics.newBody(
		world,
		(groundWidth_px / 2) / PPM,
		(love.graphics.getHeight() - (groundHeight_px / 2)) / PPM,
		"static"
	)
	groundShape = love.physics.newRectangleShape(groundWidth_px / PPM, groundHeight_px / PPM)
	groundFixture = love.physics.newFixture(groundBody, groundShape, 1)
	groundFixture:setUserData("ground")

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
	-- love.graphics.draw(PLAYER, 300, 200, 0, 7, 7)
	Player:draw()

	love.graphics.setLineStyle("rough")
	love.graphics.setColor(0, 1, 0, 1)

	for body in world:getBodies() do
		-- Only draw active bodies for performance/clarity
		if body:isActive() then
			local px, py = body:getPosition()
			local rotation = body:getAngle()

			for fixture in body:getFixtures() do
				local shape = fixture:getShape()
				local shape_type = shape:getType()

				-- Set color based on user data
				local userData = fixture:getUserData()
				if userData == "ground" then
					love.graphics.setColor(0, 1, 0, 1) -- Green for ground
				elseif userData == Player then
					love.graphics.setColor(1, 0, 0, 1) -- Red for player
				else
					love.graphics.setColor(0.5, 0.5, 0.5, 1) -- Gray for other objects
				end

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

	love.graphics.setColor(1, 1, 1, 1)
end
