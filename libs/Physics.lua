local M = {}

---@class PlayerObject
---@field body love.Body
---@field fixture love.Fixture
---@field shape love.Shape
---@field isGrounded boolean
---@field state string
---@field current_animation table
---@field [string] any

---@type PlayerObject
local PlayerRef

---@param playerObject PlayerObject
function M.setPlayerRef(playerObject)
	PlayerRef = playerObject
end

---@param a love.Fixture
---@param b love.Fixture
function M.beginContact(a, b, collision)
	local dataA = a:getUserData()
	local dataB = b:getUserData()

	if (dataA == PlayerRef and dataB == "ground") or (dataB == PlayerRef and dataA == "ground") then
		PlayerRef.isGrounded = true
		print("player is grounded in beginContact")
	end
end

---@param a love.Fixture
---@param b love.Fixture
function M.endContact(a, b, collision)
	local dataA = a:getUserData()
	local dataB = b:getUserData()

	if (dataA == PlayerRef and dataB == "ground") or (dataB == PlayerRef and dataA == "ground") then
		PlayerRef.isGrounded = false
		print("player is no longer grounded in beginContact")
	end
end

---@param a love.Fixture
---@param b love.Fixture
function M.preSolve(a, b, collision)
	-- This function is called *before* the collision is resolved.
	-- You can adjust collision properties here (e.g., disable contact, change friction).
end

---@param a love.Fixture
---@param b love.Fixture
function M.postSolve(a, b, collision)
	-- This function is called *after* the collision has been resolved.
	-- You can inspect the impulse/force applied during collision here.
end

return M
