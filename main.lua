Player = require("libs/player")

function love.load()
	print("Loading...")
	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	love.graphics.setBackgroundColor(0.2, 0.5, 0.8)

	Player:load()

	-- PLAYER = love.graphics.newImage("src/images/entities/player/idle/00.png")
	-- MUSIC = love.audio.newSource("src/music.wav", "stream")
	-- love.audio.play(MUSIC)
	print("Loaded!")
end

function love.update(dt)
	Player:update(dt)
end

function love.draw()
	-- love.graphics.draw(PLAYER, 300, 200, 0, 7, 7)
	Player:draw()
end
