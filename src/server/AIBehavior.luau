

local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

local WeaponSystem = require(script.Parent.WeaponSystem)
local TacticalSystem = require(script.Parent.TacticalSystem)

local AIBehavior = {}

function AIBehavior.FindNearestPlayer(headPosition, detectionRadius)
	local bestPlayer, bestHead, bestDistance = nil, nil, nil
	
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
			local humanoid = player.Character.Humanoid
			local head = player.Character.Head
			
			if humanoid.Health > 0 then
				local distance = (head.Position - headPosition).Magnitude
				if distance < detectionRadius then
					if not bestDistance or distance < bestDistance then
						bestPlayer, bestHead, bestDistance = player, head, distance
					end
				end
			end
		end
	end
	
	return bestPlayer, bestHead, bestDistance
end

function AIBehavior.FaceTarget(humanoidRootPart, targetPos)
	local position = humanoidRootPart.Position
	local lookDirection = Vector3.new(targetPos.X, position.Y, targetPos.Z) - position
	
	if lookDirection.Magnitude > 0.001 then
		humanoidRootPart.CFrame = CFrame.lookAt(position, position + lookDirection.Unit)
	end
end

function AIBehavior.FireWeapon(weapon, weaponConfig, barrelPos, targetPos, officerConfig, character)
	task.spawn(function()
		WeaponSystem.PlayWeaponSound(weapon, weaponConfig)
		task.wait(0.03)
		
		local weaponPart = weapon:FindFirstChild("Handle") or weapon:FindFirstChildOfClass("BasePart")
		if weaponPart then
			local muzzleFlash = Instance.new("PointLight")
			muzzleFlash.Brightness = 4
			muzzleFlash.Range = 15
			muzzleFlash.Color = Color3.fromRGB(255, 200, 100)
			muzzleFlash.Parent = weaponPart
			game:GetService("Debris"):AddItem(muzzleFlash, 0.12)
		end
		
		local pelletCount = weaponConfig.pelletCount or 1
		for i = 1, pelletCount do
			if i > 1 then task.wait(0.008) end
			WeaponSystem.CreateRaycastBullet(barrelPos, targetPos, weaponConfig, officerConfig, character, i > 1)
		end
	end)
end

function AIBehavior.SeekCover(humanoid, humanoidRootPart, torso, targetPosition, character)
	local cover = TacticalSystem.FindNearestCover(humanoidRootPart.Position, targetPosition)
	if not cover then return false end
	
	local coverPos = TacticalSystem.GetCoverPosition(cover, humanoidRootPart.Position, targetPosition)
	
	humanoid.WalkSpeed = 16
	
	local success = pcall(function()
		local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
		path:ComputeAsync(humanoidRootPart.Position, coverPos)
		
		if path.Status == Enum.PathStatus.Success then
			local waypoints = path:GetWaypoints()
			for _, wp in pairs(waypoints) do
				humanoid:MoveTo(wp.Position)
				if wp.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
				
				local timeout = 0
				while (torso.Position - wp.Position).Magnitude > 3 and timeout < 2 do
					timeout = timeout + task.wait(0.05)
				end
			end
		else
			humanoid:MoveTo(coverPos)
			task.wait(2)
		end
	end)
	
	if not success then
		humanoid:MoveTo(coverPos)
		task.wait(2)
	end
	
	return true
end

function AIBehavior.PeekAndShoot(humanoid, humanoidRootPart, coverPosition, targetPosition, weapon, weaponConfig, officerConfig, character)
	local peekSide = math.random() < 0.5
	local peekPos = TacticalSystem.GetPeekPosition(coverPosition, targetPosition, peekSide)
	
	humanoid:MoveTo(peekPos)
	task.wait(0.5)
	
	local weaponPart = weapon:FindFirstChild("Handle") or weapon:FindFirstChildOfClass("BasePart")
	if weaponPart then
		local barrelPos = weaponPart.CFrame * CFrame.new(0, 0, -weaponPart.Size.Z/2 - 2)
		AIBehavior.FireWeapon(weapon, weaponConfig, barrelPos.Position, targetPosition, officerConfig, character)
	end
	
	task.wait(0.3)
	humanoid:MoveTo(coverPosition)
	task.wait(1)
end

function AIBehavior.PatrolMovement(humanoid, humanoidRootPart, torso, spawnPoint, character)
	local wanderRadius = Vector3.new(80, 20, 80)
	local offset = Vector3.new(
		math.random(-wanderRadius.X, wanderRadius.X),
		math.random(-wanderRadius.Y, wanderRadius.Y),
		math.random(-wanderRadius.Z, wanderRadius.Z)
	)
	local targetPos = spawnPoint.Position + offset
	
	local waypoint = Instance.new("Part")
	waypoint.Size = Vector3.new(1, 1, 1)
	waypoint.Anchored = true
	waypoint.CanCollide = false
	waypoint.Transparency = 1
	waypoint.CFrame = CFrame.new(targetPos)
	waypoint.Name = "PatrolPoint"
	waypoint.Parent = character
	
	local success = pcall(function()
		local path = PathfindingService:CreatePath({
			AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, AgentCanClimb = false, WaypointSpacing = 4
		})
		
		path:ComputeAsync(humanoidRootPart.Position, targetPos)
		
		if path.Status == Enum.PathStatus.Success then
			local waypoints = path:GetWaypoints()
			for _, wp in pairs(waypoints) do
				humanoid:MoveTo(wp.Position)
				if wp.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
				
				local timeout = 0
				while (torso.Position - wp.Position).Magnitude > 4 and timeout < 3 do
					timeout = timeout + task.wait(0.1)
				end
			end
		else
			humanoid:MoveTo(targetPos)
		end
	end)
	
	if not success then humanoid:MoveTo(targetPos) end
	if waypoint then waypoint:Destroy() end
end

function AIBehavior.QuickReposition(humanoid, torso, chaseSpeed, patrolSpeed, character)
	local sideBias = (math.random() < 0.5) and -1 or 1
	local offset = CFrame.new(-math.random(20, 40) * sideBias, math.random(-20, 20), -math.random(10, 30))
	local targetPos = torso.CFrame:ToWorldSpace(offset).Position
	
	humanoid.WalkSpeed = chaseSpeed
	
	local waypoint = Instance.new("Part")
	waypoint.Size = Vector3.new(1, 1, 1)
	waypoint.Anchored, waypoint.CanCollide, waypoint.Transparency = true, false, 1
	waypoint.CFrame = CFrame.new(targetPos)
	waypoint.Parent = character
	
	local success = pcall(function()
		local path = PathfindingService:CreatePath()
		path:ComputeAsync(humanoid.RootPart.Position, targetPos)
		
		if path.Status == Enum.PathStatus.Success then
			local waypoints = path:GetWaypoints()
			for _, wp in pairs(waypoints) do
				humanoid:MoveTo(wp.Position)
				local timeout = 0
				while (torso.Position - wp.Position).Magnitude > 4 and timeout < 2 do
					timeout = timeout + task.wait(0.05)
				end
			end
		else
			humanoid:MoveTo(targetPos)
			task.wait(2)
		end
	end)
	
	if not success then
		humanoid:MoveTo(targetPos)
		task.wait(2)
	end
	
	if waypoint then waypoint:Destroy() end
	humanoid.WalkSpeed = patrolSpeed
end

return AIBehavior
