-- Utility functions for the Police AI System
-- Simplified version - only essential functions

local Utilities = {}

-- Get all players within a radius of a position
function Utilities.GetPlayersInRadius(position, radius)
	local Players = game:GetService("Players")
	local nearbyPlayers = {}
	
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (position - player.Character.HumanoidRootPart.Position).Magnitude
			if distance <= radius then
				table.insert(nearbyPlayers, {
					player = player,
					distance = distance
				})
			end
		end
	end
	
	-- Sort by distance (closest first)
	table.sort(nearbyPlayers, function(a, b)
		return a.distance < b.distance
	end)
	
	return nearbyPlayers
end

return Utilities