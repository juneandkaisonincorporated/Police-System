-- Police Manager Class
-- Manages police officer spawning based on player count with continuous patrol behavior

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Shared.Config)
local PoliceOfficer = require(script.Parent.PoliceOfficer)
local CommunicationSystem = require(script.Parent.CommunicationSystem)

local PoliceManager = {}
PoliceManager.__index = PoliceManager

-- Constructor
function PoliceManager.new()
	local self = setmetatable({}, PoliceManager)
	
	self.activeOfficers = {}
	self.spawnPoints = {}
	self.isRunning = false
	self.assetsReady = false
	self.lastSpawnTime = 0
	self.lastPlayerCount = 0
	
	-- Setup spawn points
	self:SetupSpawnPoints()
	
	-- Check assets
	self:CheckAssetsReady()
	
	return self
end

-- Setup spawn points around the map
function PoliceManager:SetupSpawnPoints()
	-- Generate spawn points well above ground level
	self.spawnPoints = {
		CFrame.new(0, 20, 0),
		CFrame.new(50, 20, 50),
		CFrame.new(-50, 20, -50),
		CFrame.new(50, 20, -50),
		CFrame.new(-50, 20, 50),
		CFrame.new(100, 20, 0),
		CFrame.new(-100, 20, 0),
		CFrame.new(0, 20, 100),
		CFrame.new(0, 20, -100),
		CFrame.new(75, 20, 25),
		CFrame.new(-75, 20, -25),
		CFrame.new(25, 20, 75),
		CFrame.new(-25, 20, -75),
		CFrame.new(120, 20, 60),
		CFrame.new(-120, 20, -60),
	}
	

end

-- Check if assets are ready
function PoliceManager:CheckAssetsReady()
	local missingAssets = Config.AssetLoader.CheckAssets()
	self.assetsReady = #missingAssets == 0
	
	if not self.assetsReady then
		print("[Police Manager] Assets not ready - cannot spawn officers")
		print("[Police Manager] Missing assets:")
		for _, missingAsset in pairs(missingAssets) do
			print("  - " .. missingAsset)
		end
		return false
	else
		print("[Police Manager] Assets verified - officers can spawn")
		return true
	end
end

-- Calculate how many officers should be active based on player count
function PoliceManager:CalculateTargetOfficerCount()
	local playerCount = #Players:GetPlayers()
	
	-- Scale officer count based on players: 2 officers per player, max 15
	local targetCount = math.min(playerCount * 2, 15)
	
	-- Minimum of 3 officers if any players are online
	if playerCount > 0 then
		targetCount = math.max(targetCount, 3)
	else
		targetCount = 0 -- No officers if no players
	end
	
	return targetCount
end

-- Start the police manager
function PoliceManager:Start()
	if self.isRunning then return end
	
	-- Check if assets are ready
	if not self:CheckAssetsReady() then
		print("[Police Manager] Cannot start - assets not ready")
		return
	end
	
	self.isRunning = true
	
	-- Start spawn management loop
	self:StartSpawnLoop()
	
	print("[Police Manager] Started - Officers will spawn based on player count")
end

-- Stop the police manager
function PoliceManager:Stop()
	self.isRunning = false
	
	-- Remove all officers
	self:RemoveAllOfficers()
	
	print("[Police Manager] Stopped - All officers removed")
end

-- Start automatic spawning loop based on player count
function PoliceManager:StartSpawnLoop()
	RunService.Heartbeat:Connect(function()
		if not self.isRunning then return end
		
		local currentTime = tick()
		local playerCount = #Players:GetPlayers()
		local targetOfficerCount = self:CalculateTargetOfficerCount()
		local currentOfficerCount = #self.activeOfficers
		
		-- Clean up dead officers first
		self:CleanupDeadOfficers()
		currentOfficerCount = #self.activeOfficers
		
		-- Check if we need to spawn more officers
		if currentOfficerCount < targetOfficerCount and currentTime - self.lastSpawnTime >= 3 then
			self:SpawnRandomOfficer()
			self.lastSpawnTime = currentTime
		end
		
		-- Log player count changes
		if playerCount ~= self.lastPlayerCount then
			print("[Police Manager] Player count changed: " .. playerCount .. " players, target officers: " .. targetOfficerCount)
			self.lastPlayerCount = playerCount
		end
	end)
end

function PoliceManager:SpawnRandomOfficer()
	local availableTypes = CommunicationSystem.GetThreatLevelOfficers()
	local officerType = availableTypes[math.random(1, #availableTypes)]
	local spawnPoint = self:GetRandomSpawnPoint()
	
	self:SpawnOfficer(officerType, spawnPoint)
end

function PoliceManager:SpawnBackupOfficer(officerType, nearPosition)
	local spawnPoint = self:GetNearbySpawnPoint(nearPosition)
	local officer = self:SpawnOfficer(officerType, spawnPoint)
	if officer then

	end
	return officer
end

function PoliceManager:SpawnSniperOfficer(sniperType, sniperPosition, targetPlayer)
	local officer = self:SpawnOfficer(sniperType, sniperPosition)
	if officer then
		print("[SNIPER DEPLOYED] " .. targetPlayer.Name .. " - ELIMINATION AUTHORIZED")
	end
	return officer
end

function PoliceManager:GetNearbySpawnPoint(position)
	local nearbyPoints = {}
	for _, spawnPoint in pairs(self.spawnPoints) do
		local distance = (spawnPoint.Position - position).Magnitude
		if distance < 100 and distance > 30 then
			table.insert(nearbyPoints, spawnPoint)
		end
	end
	
	if #nearbyPoints > 0 then
		return nearbyPoints[math.random(1, #nearbyPoints)]
	else
		return self:GetRandomSpawnPoint()
	end
end

function PoliceManager:GetTotalOfficerCount()
	return #self.activeOfficers
end

function PoliceManager:GetAvailableOfficers()
	local available = {}
	for _, officer in pairs(self.activeOfficers) do
		if officer and officer.character and officer.character.Parent and officer.state ~= "dead" then
			table.insert(available, officer)
		end
	end
	return available
end

-- Select random officer type based on spawn rates
function PoliceManager:SelectRandomOfficerType()
	local totalRate = 0
	for _, config in pairs(Config.OfficerTypes) do
		totalRate = totalRate + config.spawnRate
	end
	
	local randomValue = math.random() * totalRate
	local currentRate = 0
	
	for officerType, config in pairs(Config.OfficerTypes) do
		currentRate = currentRate + config.spawnRate
		if randomValue <= currentRate then
			return officerType
		end
	end
	
	return "Officer" -- Fallback
end

-- Get random spawn point
function PoliceManager:GetRandomSpawnPoint()
	if #self.spawnPoints == 0 then
		return CFrame.new(0, 20, 0) -- Fallback
	end
	
	return self.spawnPoints[math.random(1, #self.spawnPoints)]
end

-- Spawn a specific officer type
function PoliceManager:SpawnOfficer(officerType, spawnPoint)
	if not self.assetsReady then
		warn("[Police Manager] Cannot spawn officer - assets not ready")
		return nil
	end
	
	-- Validate officer type
	if not Config.OfficerTypes[officerType] then
		warn("[Police Manager] Invalid officer type: " .. tostring(officerType))
		return nil
	end
	
	-- Create officer
	local officer = PoliceOfficer.new(officerType, spawnPoint, self)
	
	if officer then
		table.insert(self.activeOfficers, officer)

		return officer
	else
		warn("[Police Manager] Failed to spawn " .. officerType .. " officer")
		return nil
	end
end

-- Force spawn a specific officer type (for commands)
function PoliceManager:ForceSpawnOfficer(officerType)
	local spawnPoint = self:GetRandomSpawnPoint()
	return self:SpawnOfficer(officerType, spawnPoint)
end

-- Respawn an officer (called when an officer dies)
function PoliceManager:RespawnOfficer(officerType, originalSpawnPoint)
	if not self.isRunning then return end
	
	local targetCount = self:CalculateTargetOfficerCount()
	if #self.activeOfficers >= targetCount then
		print("[Police Manager] Not respawning " .. officerType .. " - target officer count reached")
		return
	end
	
	local spawnPoint = originalSpawnPoint or self:GetRandomSpawnPoint()
	self:SpawnOfficer(officerType, spawnPoint)
	print("[Police Manager] Respawned " .. officerType .. " officer")
end

-- Clean up dead officers from active list
function PoliceManager:CleanupDeadOfficers()
	for i = #self.activeOfficers, 1, -1 do
		local officer = self.activeOfficers[i]
		if officer.state == "dead" or not officer.character or not officer.character.Parent then
			table.remove(self.activeOfficers, i)
		end
	end
end

-- Remove all officers
function PoliceManager:RemoveAllOfficers()
	for _, officer in pairs(self.activeOfficers) do
		if officer and officer.Destroy then
			officer:Destroy()
		end
	end
	
	self.activeOfficers = {}
end

-- Get police system stats
function PoliceManager:GetStats()
	local playerCount = #Players:GetPlayers()
	local targetCount = self:CalculateTargetOfficerCount()
	
	local stats = {
		isRunning = self.isRunning,
		totalOfficers = #self.activeOfficers,
		targetOfficers = targetCount,
		maxOfficers = 15,
		playerCount = playerCount,
		spawnPoints = #self.spawnPoints,
		assetsReady = self.assetsReady,
		officerCounts = {}
	}
	
	-- Count officers by type
	for _, officer in pairs(self.activeOfficers) do
		local officerType = officer.officerType
		stats.officerCounts[officerType] = (stats.officerCounts[officerType] or 0) + 1
	end
	
	return stats
end

-- Print status
function PoliceManager:PrintStatus()
	local stats = self:GetStats()
	
	print("[Police Manager] Status:")
	print("  Running: " .. tostring(stats.isRunning))
	print("  Players Online: " .. stats.playerCount)
	print("  Officers: " .. stats.totalOfficers .. "/" .. stats.targetOfficers .. " (target based on players)")
	print("  Spawn Points: " .. stats.spawnPoints)
	print("  Assets Ready: " .. tostring(stats.assetsReady))
	
	if stats.totalOfficers > 0 then
		print("  Officer Types:")
		for officerType, count in pairs(stats.officerCounts) do
			print("    - " .. officerType .. ": " .. count)
		end
		
		print("  Officer Details:")
		for i, officer in pairs(self.activeOfficers) do
			local info = officer:GetInfo()
			print("    " .. i .. ". " .. info.type .. " - Health: " .. info.health .. "/" .. info.maxHealth .. " - State: " .. info.state .. " - Weapon: " .. info.weapon)
		end
	end
end

return PoliceManager