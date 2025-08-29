-- Police System Client - Simplified
-- Basic client for police system

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Wait for remote functions (optional)
local success, policeSystemRemotes = pcall(function()
	return ReplicatedStorage:WaitForChild("PoliceSystemRemotes", 5)
end)

if success and policeSystemRemotes then
	print("[Police Client] Connected to police system")
else
	print("[Police Client] Police system not available")
end

-- Simple damage feedback
local function SetupDamageFeedback()
	local function connectToCharacter(character)
		local humanoid = character:WaitForChild("Humanoid")
		
		humanoid.HealthChanged:Connect(function(newHealth)
			if newHealth <= 0 then
				print("[Police Client] You were killed by police!")
			end
		end)
	end
	
	-- Connect to current character
	if player.Character then
		connectToCharacter(player.Character)
	end
	
	-- Connect to future characters
	player.CharacterAdded:Connect(connectToCharacter)
end

-- Initialize
print("[Police Client] Starting...")
SetupDamageFeedback()
print("[Police Client] Ready.")