

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage.Shared.Config)
local SearchSystem = require(script.Parent.SearchSystem)

local CommunicationSystem = {}
CommunicationSystem.currentThreatLevel = 1
CommunicationSystem.lastEscalation = 0
CommunicationSystem.activeAlerts = {}
CommunicationSystem.lastKnownPlayerPositions = {}
CommunicationSystem.activeSearches = {}

function CommunicationSystem.CalculateThreatLevel()
	if CommunicationSystem.currentThreatLevel > 1 then
		return CommunicationSystem.currentThreatLevel
	end
	
	local playerCount = #Players:GetPlayers()
	local baseLevel = 1
	
	if playerCount >= 1 then baseLevel = 2 end
	if playerCount >= 3 then baseLevel = 3 end
	if playerCount >= 5 then baseLevel = 4 end
	if playerCount >= 8 then baseLevel = 5 end
	
	return baseLevel
end

function CommunicationSystem.RequestBackup(officerPosition, officerType, targetPlayer, policeManager)
	if not policeManager then return end
	
	local currentTime = tick()
	if currentTime - CommunicationSystem.lastEscalation < 10 then return end
	
	local threatLevel = CommunicationSystem.CalculateThreatLevel()
	local escalationConfig = Config.System.threatEscalation["level" .. threatLevel]
	
	if not escalationConfig then return end
	
	print("[BACKUP] " .. targetPlayer.Name .. " spotted - Threat Level " .. threatLevel)
	
	local backupCount = math.min(6, escalationConfig.maxOfficers - policeManager:GetTotalOfficerCount())
	
	for i = 1, backupCount do
		task.spawn(function()
			task.wait(i * 2)
			local backupType = escalationConfig.types[math.random(1, #escalationConfig.types)]
			policeManager:SpawnBackupOfficer(backupType, officerPosition)
		end)
	end
	
	if threatLevel >= 3 then
		task.spawn(function()
			task.wait(5)
			CommunicationSystem.RequestSniper(officerPosition, targetPlayer, policeManager)
		end)
	end
	
	CommunicationSystem.lastEscalation = currentTime
end

function CommunicationSystem.RequestSniper(targetArea, targetPlayer, policeManager)
	print("[SNIPER] " .. targetPlayer.Name .. " - YOU ARE BEING HUNTED")
	
	local sniperTypes = {"SniperSWAT", "SniperFBI"}
	local sniperType = sniperTypes[math.random(1, #sniperTypes)]
	
	local TeamTactics = require(script.Parent.TeamTactics)
	local existingSnipers = {}
	for _, officer in pairs(policeManager:GetAvailableOfficers()) do
		if officer.officerType:find("Sniper") then
			table.insert(existingSnipers, officer)
		end
	end
	
	local sniperPos = TeamTactics.GetSniperPosition(targetArea, existingSnipers)
	policeManager:SpawnSniperOfficer(sniperType, sniperPos, targetPlayer)
end

function CommunicationSystem.BroadcastThreat(officerPosition, targetPlayer, allOfficers)
	for _, officer in pairs(allOfficers) do
		if officer and officer.character and officer.character.Parent then
			local distance = (officer.humanoidRootPart.Position - officerPosition).Magnitude
			if distance < 150 then
				officer.alertedToThreat = true
				officer.lastKnownTargetPosition = targetPlayer.Character.HumanoidRootPart.Position
			end
		end
	end
end

function CommunicationSystem.GetThreatLevelOfficers()
	local threatLevel = CommunicationSystem.CalculateThreatLevel()
	local escalationConfig = Config.System.threatEscalation["level" .. threatLevel]
	return escalationConfig and escalationConfig.types or {"Officer"}
end

function CommunicationSystem.SetThreatLevel(level)
	CommunicationSystem.currentThreatLevel = level
	print("[THREAT LEVEL] Manually set to " .. level)
end

function CommunicationSystem.ReportPlayerLost(playerName, lastPosition, officerCount, policeManager)
	local escapeTime = tick() - (CommunicationSystem.lastKnownPlayerPositions[playerName] or tick())
	
	print("[ALERT] SUSPECT LOST - " .. playerName)
	
	local searchId = SearchSystem.InitiateSearch(lastPosition, officerCount, escapeTime, policeManager)
	CommunicationSystem.activeSearches[playerName] = searchId
	
	return searchId
end

function CommunicationSystem.ReportOfficerDown(officerType, position, policeManager)
	print("[CRITICAL] OFFICER DOWN - " .. officerType)
	
	for playerName, searchId in pairs(CommunicationSystem.activeSearches) do
		SearchSystem.EscalateSearch(searchId, policeManager)
	end
	
	local threatLevel = math.min(5, CommunicationSystem.CalculateThreatLevel() + 1)
	local escalationConfig = Config.System.threatEscalation["level" .. threatLevel]
	
	if escalationConfig then
		for i = 1, 3 do
			task.spawn(function()
				task.wait(i * 2)
				local backupType = escalationConfig.types[math.random(1, #escalationConfig.types)]
				policeManager:SpawnBackupOfficer(backupType, position)
			end)
		end
	end
end

function CommunicationSystem.UpdatePlayerPosition(playerName, position)
	CommunicationSystem.lastKnownPlayerPositions[playerName] = tick()
	
	if CommunicationSystem.activeSearches[playerName] then
		SearchSystem.UpdateSearch(CommunicationSystem.activeSearches[playerName], position)
	end
end

return CommunicationSystem
