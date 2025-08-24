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
	world:draw()
	love.graphics.setColor(1, 1, 1, 1)
end
