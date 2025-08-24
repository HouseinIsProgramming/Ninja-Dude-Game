local M = {}

function M.beginContact(a, b, collision)
	-- This function is called when two fixtures *first* touch
	-- We'll use this to detect when the player lands on the ground.
end

function M.endContact(a, b, collision)
	-- This function is called when two fixtures *stop* touching
	-- We'll use this to detect when the player leaves the ground.
end

function M.preSolve(a, b, collision)
	-- This function is called *before* the collision is resolved.
	-- You can adjust collision properties here (e.g., disable contact, change friction).
end

function M.postSolve(a, b, collision)
	-- This function is called *after* the collision has been resolved.
	-- You can inspect the impulse/force applied during collision here.
end

return M
