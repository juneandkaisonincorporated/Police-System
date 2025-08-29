

local workspace = game:GetService("Workspace")

local TacticalSystem = {}

function TacticalSystem.FindNearestCover(position, enemyPosition)
	local coverObjects = {}
	local searchRadius = 50
	
	for _, obj in pairs(workspace:GetPartBoundsInBox(CFrame.new(position), Vector3.new(searchRadius, searchRadius, searchRadius))) do
		if obj.CanCollide and obj.Size.Y > 4 and obj.Size.X > 2 and obj.Size.Z > 2 then
			local coverPos = obj.Position
			local distanceToEnemy = (coverPos - enemyPosition).Magnitude
			local distanceToOfficer = (coverPos - position).Magnitude
			
			if distanceToOfficer < 30 and distanceToEnemy > distanceToOfficer then
				table.insert(coverObjects, {
					part = obj,
					position = coverPos,
					distance = distanceToOfficer,
					protection = distanceToEnemy - distanceToOfficer
				})
			end
		end
	end
	
	if #coverObjects > 0 then
		table.sort(coverObjects, function(a, b) return a.protection > b.protection end)
		return coverObjects[1]
	end
	
	return nil
end

function TacticalSystem.GetCoverPosition(coverObject, officerPosition, enemyPosition)
	local coverPart = coverObject.part
	local coverCenter = coverPart.Position
	
	local enemyDirection = (enemyPosition - coverCenter).Unit
	local coverOffset = enemyDirection * -(coverPart.Size.Magnitude / 2 + 3)
	
	return coverCenter + coverOffset
end

function TacticalSystem.GetPeekPosition(coverPosition, enemyPosition, peekSide)
	local direction = (enemyPosition - coverPosition).Unit
	local rightVector = direction:Cross(Vector3.new(0, 1, 0))
	
	local peekOffset = rightVector * (peekSide and 3 or -3)
	return coverPosition + peekOffset + Vector3.new(0, 1, 0)
end

function TacticalSystem.IsInCover(officerPosition, enemyPosition, coverObjects)
	for _, coverObj in pairs(coverObjects) do
		local coverPart = coverObj.part
		local rayDirection = (enemyPosition - officerPosition).Unit * 100
		
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		raycastParams.FilterDescendantsInstances = {}
		
		local rayResult = workspace:Raycast(officerPosition, rayDirection, raycastParams)
		
		if rayResult and rayResult.Instance == coverPart then
			return true
		end
	end
	
	return false
end

function TacticalSystem.ShouldSeekCover(officerHealth, maxHealth, hasWeapon)
	local healthRatio = officerHealth / maxHealth
	
	if healthRatio < 0.3 then return true end
	if healthRatio < 0.6 and not hasWeapon then return true end
	if math.random() < 0.3 then return true end
	
	return false
end

return TacticalSystem
