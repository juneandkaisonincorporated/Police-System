local Players = game:GetService("Players")

local TeamTactics = {}

function TeamTactics.GetOptimalSpacing(officer, allOfficers, targetPosition)
	local idealSpacing = 15
	local officerPos = officer.humanoidRootPart.Position
	local adjustedPos = officerPos
	
	for _, otherOfficer in pairs(allOfficers) do
		if otherOfficer ~= officer and otherOfficer.character and otherOfficer.character.Parent then
			local otherPos = otherOfficer.humanoidRootPart.Position
			local distance = (officerPos - otherPos).Magnitude
			
			if distance < idealSpacing then
				local pushDirection = (officerPos - otherPos).Unit
				local pushDistance = idealSpacing - distance
				adjustedPos = adjustedPos + pushDirection * pushDistance
			end
		end
	end
	
	return adjustedPos
end

function TeamTactics.ShouldChaseTarget(officer, targetPosition, allOfficers)
	local officerPos = officer.humanoidRootPart.Position
	local distanceToTarget = (officerPos - targetPosition).Magnitude
	
	local closerOfficers = 0
	for _, otherOfficer in pairs(allOfficers) do
		if otherOfficer ~= officer and otherOfficer.character and otherOfficer.character.Parent then
			local otherDistance = (otherOfficer.humanoidRootPart.Position - targetPosition).Magnitude
			if otherDistance < distanceToTarget then
				closerOfficers = closerOfficers + 1
			end
		end
	end
	
	return closerOfficers < 3
end

function TeamTactics.GetFlankingPosition(officer, targetPosition, allOfficers)
	local officerPos = officer.humanoidRootPart.Position
	local targetDirection = (targetPosition - officerPos).Unit
	
	local leftFlank = targetDirection:Cross(Vector3.new(0, 1, 0)) * 25
	local rightFlank = targetDirection:Cross(Vector3.new(0, -1, 0)) * 25
	
	local leftPos = targetPosition + leftFlank
	local rightPos = targetPosition + rightFlank
	
	local leftOccupied = false
	local rightOccupied = false
	
	for _, otherOfficer in pairs(allOfficers) do
		if otherOfficer ~= officer and otherOfficer.character and otherOfficer.character.Parent then
			local otherPos = otherOfficer.humanoidRootPart.Position
			if (otherPos - leftPos).Magnitude < 20 then leftOccupied = true end
			if (otherPos - rightPos).Magnitude < 20 then rightOccupied = true end
		end
	end
	
	if not leftOccupied then return leftPos end
	if not rightOccupied then return rightPos end
	return nil
end

function TeamTactics.AvoidPlayerLOS(officer, targetPosition)
	local officerPos = officer.humanoidRootPart.Position
	local directionToTarget = (targetPosition - officerPos).Unit
	
	local evasiveDirections = {
		directionToTarget:Cross(Vector3.new(0, 1, 0)),
		directionToTarget:Cross(Vector3.new(0, -1, 0)),
		-directionToTarget
	}
	
	for _, direction in pairs(evasiveDirections) do
		local evasivePos = officerPos + direction * math.random(20, 35)
		
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {officer.character}
		
		local rayResult = workspace:Raycast(evasivePos, (targetPosition - evasivePos).Unit * 100, raycastParams)
		
		if not rayResult or rayResult.Distance > 50 then
			return evasivePos
		end
	end
	
	return nil
end

function TeamTactics.GetSniperPosition(targetPosition, existingSnipers)
	local sniperPositions = {
		CFrame.new(300, 80, 300),
		CFrame.new(-300, 80, -300),
		CFrame.new(300, 80, -300),
		CFrame.new(-300, 80, 300),
		CFrame.new(0, 120, 400),
		CFrame.new(400, 120, 0),
		CFrame.new(-400, 120, 0),
		CFrame.new(0, 120, -400)
	}
	
	for _, sniperPos in pairs(sniperPositions) do
		local distance = (sniperPos.Position - targetPosition).Magnitude
		if distance > 200 then
			local occupied = false
			for _, existingSniper in pairs(existingSnipers) do
				if existingSniper.character and existingSniper.character.Parent then
					local sniperDistance = (existingSniper.humanoidRootPart.Position - sniperPos.Position).Magnitude
					if sniperDistance < 50 then
						occupied = true
						break
					end
				end
			end
			
			if not occupied then
				return sniperPos
			end
		end
	end
	
	return sniperPositions[math.random(1, #sniperPositions)]
end

return TeamTactics
