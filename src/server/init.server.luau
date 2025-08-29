-- Police AI System - Server Initialization
-- Main server-side entry point for the police AI system

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local PoliceManager = require(script.PoliceManager)
local CommunicationSystem = require(script.CommunicationSystem)

local policeManager = nil

-- Initialize the police AI system
local function InitializePoliceSystem()
	local missingAssets = Config.AssetLoader.CheckAssets()
	if #missingAssets > 0 then
		print("[ERROR] Missing assets - system disabled")
		return
	end
	
	policeManager = PoliceManager.new()
	policeManager:Start()
end

-- Setup remote functions for client communication
local function SetupRemoteFunctions()
	-- Create RemoteFunction container
	local remoteContainer = Instance.new("Folder")
	remoteContainer.Name = "PoliceSystemRemotes"
	remoteContainer.Parent = ReplicatedStorage
	
	-- Get police statistics
	local getStatsFunction = Instance.new("RemoteFunction")
	getStatsFunction.Name = "GetPoliceStats"
	getStatsFunction.Parent = remoteContainer
	
	getStatsFunction.OnServerInvoke = function(player)
		if policeManager then
			return policeManager:GetStats()
		end
		return nil
	end
	
	-- Force spawn officer
	local spawnOfficerFunction = Instance.new("RemoteFunction")
	spawnOfficerFunction.Name = "SpawnOfficer"
	spawnOfficerFunction.Parent = remoteContainer
	
	spawnOfficerFunction.OnServerInvoke = function(player, officerType)
		if policeManager then
			return policeManager:ForceSpawnOfficer(officerType or "Officer")
		end
		return nil
	end
	
	-- Remove all officers
	local removeOfficersFunction = Instance.new("RemoteFunction")
	removeOfficersFunction.Name = "RemoveAllOfficers"
	removeOfficersFunction.Parent = remoteContainer
	
	removeOfficersFunction.OnServerInvoke = function(player)
		if policeManager then
			policeManager:RemoveAllOfficers()
			return true
		end
		return false
	end
	
	-- Check assets
	local checkAssetsFunction = Instance.new("RemoteFunction")
	checkAssetsFunction.Name = "CheckAssets"
	checkAssetsFunction.Parent = remoteContainer
	
	checkAssetsFunction.OnServerInvoke = function(player)
		return Config.AssetLoader.CheckAssets()
	end
	
end

local function SetupChatCommands()
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			if message:sub(1, 1) == "/" then
				local command = message:sub(2):lower()
				
				if command == "policestats" then
					if policeManager then
						policeManager:PrintStatus()
					else
						print("Police Manager not initialized")
					end
					
				elseif command == "spawnofficer" then
					if policeManager then
						policeManager:ForceSpawnOfficer("Officer")
					else
						print("Police Manager not initialized")
					end
					
				elseif command == "spawnswat" then
					if policeManager then
						policeManager:ForceSpawnOfficer("SWAT")
					else
						print("Police Manager not initialized")
					end
					
				elseif command == "spawnfbi" then
					if policeManager then
						policeManager:ForceSpawnOfficer("FBI")
					else
						print("Police Manager not initialized")
					end
					
				elseif command == "spawnjuggernaut" then
					if policeManager then
						policeManager:ForceSpawnOfficer("Juggernaut")
					else
						print("Police Manager not initialized")
					end
					
				elseif command == "spawnblackjuggernaut" then
					if policeManager then
						policeManager:ForceSpawnOfficer("BlackJuggernaut")
					else
						print("Police Manager not initialized")
					end
					
				elseif command == "spawnsniperswat" then
					if policeManager then
						policeManager:ForceSpawnOfficer("SniperSWAT")
					else
						print("Police Manager not initialized")
					end
					
				elseif command == "spawnsniperfbi" then
					if policeManager then
						policeManager:ForceSpawnOfficer("SniperFBI")
					else
						print("Police Manager not initialized")
					end
					
				elseif command == "spawncaptain" then
					if policeManager then
						policeManager:ForceSpawnOfficer("Captain")
					else
						print("Police Manager not initialized")
					end
					
				elseif command == "spawncloaker" then
					if policeManager then
						policeManager:ForceSpawnOfficer("Cloaker")
					else
						print("Police Manager not initialized")
					end
					
				elseif command == "spawntaser" then
					if policeManager then
						policeManager:ForceSpawnOfficer("TaserOperator")
					else
						print("Police Manager not initialized")
					end
					
				elseif command == "test" then
					-- Make player invincible and spawn one of every officer type
					local character = player.Character
					if character and character:FindFirstChild("Humanoid") then
						local humanoid = character.Humanoid
						
						-- Make invincible
						humanoid.MaxHealth = math.huge
						humanoid.Health = math.huge
						
						-- Spawn one of every officer type
						if policeManager then
							local allOfficerTypes = {
								"Officer", "FirstResponder", "TaserOperator",
								"SWAT", "SniperSWAT", "RiotShieldSWAT", 
								"FBI", "SniperFBI", "RiotShieldFBI",
								"Captain", "CaptainEscort", "Cloaker", "HostageRescueTeam",
								"Juggernaut", "BlackJuggernaut", "Skulldozer"
							}
							
							for i, officerType in pairs(allOfficerTypes) do
								-- Spawn with slight delay and different positions
								task.spawn(function()
									task.wait(i * 0.5) -- Stagger spawning
									policeManager:ForceSpawnOfficer(officerType)
								end)
							end
							
							print("[Test Mode] " .. player.Name .. " is now invincible! Spawning all " .. #allOfficerTypes .. " officer types...")
						else
							print("Police Manager not initialized")
						end
					else
						print("Player character not found")
					end
					
				elseif command == "god" then
					local character = player.Character
					if character and character:FindFirstChild("Humanoid") then
						local humanoid = character.Humanoid
						humanoid.MaxHealth = math.huge
						humanoid.Health = math.huge
						print("[God Mode] " .. player.Name .. " is now invincible!")
					else
						print("Player character not found")
					end
					
				elseif command:sub(1, 5) == "level" then
					local levelStr = command:sub(7)
					local level = tonumber(levelStr)
					if level and level >= 1 and level <= 5 then
						CommunicationSystem.SetThreatLevel(level)
						print("[Threat Level] Set to Level " .. level)
					else
						print("Usage: /level [1-5]")
					end
					
				elseif command == "removeofficers" then
					if policeManager then
						policeManager:RemoveAllOfficers()
						print("Removed all officers")
					else
						print("Police Manager not initialized")
					end
					
				elseif command == "checkassets" then
					local missingAssets = Config.AssetLoader.CheckAssets()
					if #missingAssets == 0 then
						print("[Police System] All assets are ready!")
					else
						print("[Police System] Missing assets:")
						for _, missingAsset in pairs(missingAssets) do
							print("  - " .. missingAsset)
						end
					end
					
				elseif command == "guntypes" then
					print("Available gun types:")
					for gunType, _ in pairs(Config.WeaponConfigs) do
						print("   - " .. gunType)
					end
					
				elseif command == "gunconfig" then
					print("Gun configurations:")
					for gunType, config in pairs(Config.WeaponConfigs) do
						print("   " .. gunType .. ":")
						print("     Damage: " .. config.damage)
						print("     Fire Rate: " .. config.fireRate .. "s")
						print("     Weapon Type: " .. config.weaponType)
					end
					
				elseif command == "help" then
					print("=== Police AI System Commands ===")
					print("System Commands:")
					print("  /policestats     - Show system status and officer counts")
					print("  /checkassets     - Verify all required assets are present")
					print("  /guntypes        - List all available weapon types")
					print("  /gunconfig       - Show weapon configurations and stats")
					print("  /test            - Make yourself invincible + spawn all officer types")
					print("  /god             - Make yourself invincible")
					print("  /level [1-5]     - Set threat level manually")
					print("")
					print("Officer Spawning:")
					print("  /spawnofficer    - Regular officer (poor accuracy)")
					print("  /spawnswat       - SWAT officer (good accuracy)")
					print("  /spawnfbi        - FBI agent (excellent accuracy)")
					print("  /spawnjuggernaut - Heavy Juggernaut (poor accuracy, high recoil)")
					print("  /spawncaptain    - Captain (good accuracy)")
					print("  /spawncloaker    - Cloaker (excellent accuracy)")
					print("  /removeofficers  - Remove all active officers")
					print("")
					print("Accuracy System:")
					print("  - Basic Officers: 60-70% accuracy, high recoil")
					print("  - SWAT: 75-85% accuracy, moderate recoil")
					print("  - FBI: 85-95% accuracy, low recoil")
					print("  - Heavy Units: 45-55% accuracy, very high recoil")
					print("  - Specialists: 80-90% accuracy, low recoil")
					print("")
					print("Universal Weapon Pool:")
					print("  - ANY officer can get ANY weapon (even patrol cop with sniper)")
					print("  - Realistic probabilities: Common weapons more likely")
					print("  - Shotguns fire multiple pellets with spread")
					print("  - All weapons have proper sounds and recoil")
					print("================================")
					
				else
					print("Unknown command. Type /help for available commands.")
				end
			end
		end)
	end)
	
end

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
	end)
end)

-- Main initialization
local function Main()
	SetupRemoteFunctions()
	SetupChatCommands()
	InitializePoliceSystem()
	print("[Police System] Online")
end

-- Start the system
Main()

-- Cleanup on shutdown
game:BindToClose(function()
	if policeManager then
		policeManager:Stop()
	end
end)
