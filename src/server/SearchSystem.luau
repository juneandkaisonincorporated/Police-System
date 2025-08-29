local _PathfindingService = game:GetService("PathfindingService")
local _Players = game:GetService("Players")

local SearchSystem = {}
SearchSystem.activeSearches = {}
SearchSystem.searchGrids = {}

function SearchSystem.InitiateSearch(lastKnownPosition, officerCount, escapeTime, policeManager)
	local searchId = tostring(lastKnownPosition) .. "_" .. tick()
	
	local baseRadius = 30
	local officerMultiplier = math.min(officerCount / 5, 3)
	local timeMultiplier = math.min(escapeTime / 10, 2.5)
	local searchRadius = baseRadius * officerMultiplier * timeMultiplier
	
	print("[MANHUNT] Search radius: " .. math.floor(searchRadius) .. " studs | " .. officerCount .. " officers")
	
	local searchData = {
		id = searchId,
		center = lastKnownPosition,
		radius = searchRadius,
		startTime = tick(),
		officersAssigned = {},
		gridPoints = {},
		perimeterPoints = {},
		isActive = true
	}
	
	SearchSystem.GenerateSearchGrid(searchData)
	SearchSystem.GeneratePerimeter(searchData)
	SearchSystem.AssignOfficersToSearch(searchData, policeManager)
	
	SearchSystem.activeSearches[searchId] = searchData
	
	task.spawn(function()
		task.wait(120)
		SearchSystem.EndSearch(searchId)
	end)
	
	return searchId
end

function SearchSystem.GenerateSearchGrid(searchData)
	local center = searchData.center
	local radius = searchData.radius
	local gridSpacing = 40
	
	for x = -radius, radius, gridSpacing do
		for z = -radius, radius, gridSpacing do
			local gridPoint = center + Vector3.new(x, 5, z)
			local distanceFromCenter = (gridPoint - center).Magnitude
			
			if distanceFromCenter <= radius then
				table.insert(searchData.gridPoints, {
					position = gridPoint,
					searched = false,
					priority = distanceFromCenter,
					assignedOfficer = nil
				})
			end
		end
	end
	
	table.sort(searchData.gridPoints, function(a, b) return a.priority < b.priority end)

end

function SearchSystem.GeneratePerimeter(searchData)
	local center = searchData.center
	local radius = searchData.radius + 15
	local perimeterPoints = 16
	
	for i = 1, perimeterPoints do
		local angle = (i / perimeterPoints) * 2 * math.pi
		local perimeterPos = center + Vector3.new(
			math.cos(angle) * radius,
			5,
			math.sin(angle) * radius
		)
		
		table.insert(searchData.perimeterPoints, {
			position = perimeterPos,
			angle = angle,
			occupied = false
		})
	end
	

end

function SearchSystem.AssignOfficersToSearch(searchData, policeManager)
	if not policeManager then return end
	
	local availableOfficers = policeManager:GetAvailableOfficers()
	local searchOfficers = math.min(#availableOfficers, 8)
	local perimeterOfficers = math.min(#availableOfficers - searchOfficers, 6)
	
	for i = 1, searchOfficers do
		local officer = availableOfficers[i]
		if officer then
			officer.searchAssignment = "grid"
			officer.searchData = searchData
			table.insert(searchData.officersAssigned, officer)
		end
	end
	
	for i = searchOfficers + 1, searchOfficers + perimeterOfficers do
		local officer = availableOfficers[i]
		if officer then
			officer.searchAssignment = "perimeter"
			officer.searchData = searchData
			table.insert(searchData.officersAssigned, officer)
		end
	end
	

end

function SearchSystem.GetNextSearchPoint(officer)
	if not officer.searchData then return nil end
	
	local searchData = officer.searchData
	
	if officer.searchAssignment == "grid" then
		for _, gridPoint in pairs(searchData.gridPoints) do
			if not gridPoint.searched and not gridPoint.assignedOfficer then
				gridPoint.assignedOfficer = officer
				return gridPoint.position
			end
		end
	elseif officer.searchAssignment == "perimeter" then
		for _, perimeterPoint in pairs(searchData.perimeterPoints) do
			if not perimeterPoint.occupied then
				perimeterPoint.occupied = officer
				return perimeterPoint.position
			end
		end
	end
	
	return nil
end

function SearchSystem.CompleteSearchPoint(officer)
	if not officer.searchData then return end
	
	local searchData = officer.searchData
	
	for _, gridPoint in pairs(searchData.gridPoints) do
		if gridPoint.assignedOfficer == officer then
			gridPoint.searched = true
			gridPoint.assignedOfficer = nil
			break
		end
	end
end

function SearchSystem.UpdateSearch(searchId, newLastKnownPosition)
	local searchData = SearchSystem.activeSearches[searchId]
	if not searchData then return end
	
	local timeSinceLastUpdate = tick() - (searchData.lastUpdate or 0)
	if timeSinceLastUpdate < 10 then return end
	
	searchData.center = newLastKnownPosition
	searchData.lastUpdate = tick()
	searchData.gridPoints = {}
	searchData.perimeterPoints = {}
	
	SearchSystem.GenerateSearchGrid(searchData)
	SearchSystem.GeneratePerimeter(searchData)
	print("[SEARCH] Target reacquired - updating grid")
end

function SearchSystem.EscalateSearch(searchId, policeManager)
	local searchData = SearchSystem.activeSearches[searchId]
	if not searchData then return end
	

	
	searchData.radius = searchData.radius * 1.5
	local backupCount = math.min(4, 20 - #searchData.officersAssigned)
	
	for i = 1, backupCount do
		task.spawn(function()
			task.wait(i * 1.5)
			policeManager:SpawnBackupOfficer("SWAT", searchData.center)
		end)
	end
	
	task.spawn(function()
		task.wait(3)
		policeManager:SpawnSniperOfficer("SniperFBI", CFrame.new(searchData.center + Vector3.new(0, 80, 0)), nil)
	end)
end

function SearchSystem.EndSearch(searchId)
	local searchData = SearchSystem.activeSearches[searchId]
	if not searchData then return end
	
	for _, officer in pairs(searchData.officersAssigned) do
		if officer then
			officer.searchAssignment = nil
			officer.searchData = nil
		end
	end
	
	SearchSystem.activeSearches[searchId] = nil
end

function SearchSystem.IsSearchActive()
	for _, _ in pairs(SearchSystem.activeSearches) do
		return true
	end
	return false
end

return SearchSystem
