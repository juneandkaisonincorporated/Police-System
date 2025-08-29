

local _ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)
local WeaponSystem = require(script.Parent.WeaponSystem)
local AIBehavior = require(script.Parent.AIBehavior)
local CommunicationSystem = require(script.Parent.CommunicationSystem)
local SearchSystem = require(script.Parent.SearchSystem)
local TeamTactics = require(script.Parent.TeamTactics)

local PoliceOfficer = {}
PoliceOfficer.__index = PoliceOfficer

function PoliceOfficer.new(officerType, spawnPoint, manager)
	local self = setmetatable({}, PoliceOfficer)
	
	self.officerType = officerType
	self.config = Config.OfficerTypes[officerType]
	self.spawnPoint = spawnPoint
	self.manager = manager
	self.state = "patrolling"
	self.health = self.config.health
	self.maxHealth = self.config.health
	self.lastAttackTime = 0
	self.walking = false
	self.shooting = false
	self.canShoot = true
	self.ticksSinceMove = 0
	self.hasCalledBackup = false
	self.inCover = false
	self.coverPosition = nil
	self.tacticalMode = false
	self.lastSeenTarget = nil
	self.lastSeenTime = 0
	self.searchAssignment = nil
	self.searchData = nil
	
	if self:CreateCharacter() then
		self:SetupWeapon()
		if self.officerType:find("Sniper") then
			self:SetupSniperPosition()
		else
			self:StartBehaviorLoops()
		end
	else
		warn("[Police Officer] Failed to create " .. officerType .. " officer")
		return nil
	end
	
	return self
end

function PoliceOfficer:CreateCharacter()
	local officerModel = Config.AssetLoader.GetOfficerModel(self.officerType)
	if not officerModel then
		warn("[Police Officer] Failed to get officer model for " .. self.officerType)
		return false
	end
	
	self.character = officerModel
	self.character.Name = self.officerType .. "Officer"
	self.character.Parent = workspace
	self.character:PivotTo(self.spawnPoint)
	
	self.humanoid = self.character:WaitForChild("Humanoid")
	self.humanoidRootPart = self.character:WaitForChild("HumanoidRootPart")
	self.torso = self.character:WaitForChild("Torso")
	self.head = self.character:WaitForChild("Head")
	self.rightArm = self.character:WaitForChild("Right Arm")
	
	self.humanoid.MaxHealth = self.maxHealth
	self.humanoid.Health = self.health
	self.humanoid.WalkSpeed = self.config.patrolSpeed
	
	self.humanoid.HealthChanged:Connect(function(newHealth)
		self.health = newHealth
		if newHealth <= 0 and self.state ~= "dead" then
			self:Die()
		end
	end)
	
	self.humanoid.Running:Connect(function(speed)
		self.walking = speed > 5
	end)
	
	return true
end

function PoliceOfficer:SetupWeapon()
	if not self.character then return end
	
	local weaponName = self:SelectWeapon()
	if weaponName then
		self.weapon, self.weaponConfig = WeaponSystem.SetupWeapon(self.character, weaponName, self.rightArm)
		if self.weapon then

		else
			warn("[Police Officer] Weapon model not found: " .. weaponName)
		end
	end
end

function PoliceOfficer:SelectWeapon()
	local defaultWeapon = self.config.weapon
	local randomChance = self.config.randomWeaponChance or 0
	
	if randomChance > 0 and math.random() < randomChance then
		local weaponPool = Config.RandomWeaponPools.General
		local totalChance = 0
		for _, weaponData in pairs(weaponPool) do
			totalChance = totalChance + weaponData.chance
		end
		
		local randomValue = math.random() * totalChance
		local currentChance = 0
		
		for _, weaponData in pairs(weaponPool) do
			currentChance = currentChance + weaponData.chance
			if randomValue <= currentChance then
				return weaponData.weapon
			end
		end
	end
	
	return defaultWeapon
end

function PoliceOfficer:SetupSniperPosition()
	if not self.character then return end
	
	local sniperPositions = {
		CFrame.new(300, 100, 300),
		CFrame.new(-300, 100, -300),
		CFrame.new(300, 100, -300),
		CFrame.new(-300, 100, 300),
		CFrame.new(0, 150, 400),
		CFrame.new(400, 150, 0),
		CFrame.new(-400, 150, 0),
		CFrame.new(0, 150, -400),
		CFrame.new(250, 120, 0),
		CFrame.new(-250, 120, 0),
		CFrame.new(0, 120, 250),
		CFrame.new(0, 120, -250)
	}
	
	local bestPosition = sniperPositions[math.random(1, #sniperPositions)]
	self.character:PivotTo(bestPosition)
	self.humanoid.WalkSpeed = 0
	
	print("[SNIPER] " .. self.officerType .. " taking overwatch position")
	
	task.spawn(function()
		while self.character and self.character.Parent and self.humanoid.Health > 0 do
			local victim, head, distance = AIBehavior.FindNearestPlayer(self.head.Position, self.config.detectionRadius)
			
			if victim and head and distance <= self.config.attackRange then
				AIBehavior.FaceTarget(self.humanoidRootPart, head.Position)
				
				self:CreateSniperLaser(head.Position)
				task.wait(1)
				
				self:FireWeapon(head.Position)
				task.wait(self.weaponConfig.fireRate or 2.5)
			else
				task.wait(0.5)
			end
		end
	end)
end

function PoliceOfficer:CreateSniperLaser(targetPos)
	if not self.weapon then return end
	
	local weaponPart = self.weapon:FindFirstChild("Handle") or self.weapon:FindFirstChildOfClass("BasePart")
	if not weaponPart then return end
	
	local startPos = weaponPart.Position
	local distance = (targetPos - startPos).Magnitude
	
	local laser = Instance.new("Part")
	laser.Name = "SniperLaser"
	laser.Size = Vector3.new(0.1, 0.1, distance)
	laser.Material = Enum.Material.Neon
	laser.Color = Color3.fromRGB(255, 0, 0)
	laser.CanCollide = false
	laser.Anchored = true
	laser.Shape = Enum.PartType.Cylinder
	laser.Transparency = 0.3
	
	local midPoint = (startPos + targetPos) / 2
	laser.CFrame = CFrame.new(midPoint, targetPos) * CFrame.Angles(0, math.rad(90), 0)
	laser.Parent = workspace
	
	local laserLight = Instance.new("PointLight")
	laserLight.Brightness = 5
	laserLight.Range = 20
	laserLight.Color = Color3.fromRGB(255, 0, 0)
	laserLight.Parent = weaponPart
	
	task.spawn(function()
		for i = 1, 10 do
			laser.Transparency = 0.3 + (i * 0.07)
			task.wait(0.1)
		end
		laser:Destroy()
		laserLight:Destroy()
	end)
	
	print("[SNIPER LASER] " .. self.officerType .. " targeting...")
end

function PoliceOfficer:StartBehaviorLoops()
	if not self.character then return end
	
	task.spawn(function()
		while self.character and self.character.Parent and self.humanoid.Health > 0 do
			local searchRadius = self.searchAssignment and self.config.detectionRadius * 1.2 or self.config.detectionRadius
			local victim, head, _distance = AIBehavior.FindNearestPlayer(self.head.Position, searchRadius)
			
			if victim and head and self.canShoot then
				if not self.hasCalledBackup then
					self.hasCalledBackup = true
					CommunicationSystem.RequestBackup(self.humanoidRootPart.Position, self.officerType, victim, self.manager)
				end
				
				self.lastSeenTarget = victim
				self.lastSeenTime = tick()
				CommunicationSystem.UpdatePlayerPosition(victim.Name, head.Position)
				
				if self.searchAssignment then
					self.searchAssignment = nil
					self.searchData = nil
				end
				
				local allOfficers = self.manager:GetAvailableOfficers()
				local shouldChase = TeamTactics.ShouldChaseTarget(self, head.Position, allOfficers)
				local distance = (self.humanoidRootPart.Position - head.Position).Magnitude
				
				if distance > 30 and shouldChase then
					self:ChaseTarget(victim, head, allOfficers)
				elseif not self.tacticalMode and (self.health < self.maxHealth * 0.7 or math.random() < 0.3) then
					self.tacticalMode = true
					self:UseTactics(victim, head)
				else
					self:EngageTarget(victim, head, allOfficers)
				end
				
				task.wait(self.weaponConfig.fireRate or 0.5)
			else
				if self.lastSeenTarget and tick() - self.lastSeenTime > 8 and not self.searchAssignment then
					self:InitiateSearch()
				end
				
				if self.searchAssignment then
					self:ExecuteSearchBehavior()
				else
					self.shooting = false
					self.tacticalMode = false
					self.humanoid.WalkSpeed = self.config.patrolSpeed
					self.hasCalledBackup = false
				end
				task.wait(0.1)
			end
		end
	end)
	
	task.spawn(function()
		while self.character and self.character.Parent and self.humanoid.Health > 0 do
			if not self.shooting and not self.walking then
				self:IdleWander()
			end
			task.wait(math.random(3, 8))
		end
	end)
	
	task.spawn(function()
		local lastHealth = self.humanoid.Health
		while self.character and self.character.Parent and self.humanoid.Health > 0 do
			task.wait(0.2)
			if self.humanoid.Health < lastHealth and not self.walking then
				self:QuickReposition()
			end
			lastHealth = self.humanoid.Health
		end
	end)
end

function PoliceOfficer:FireWeapon(targetPos)
	if not self.weapon then return end
	
	local weaponPart = self.weapon:FindFirstChild("Handle") or self.weapon:FindFirstChildOfClass("BasePart")
	if not weaponPart then return end
	
	local barrelPos = weaponPart.CFrame * CFrame.new(0, 0, -weaponPart.Size.Z/2 - 2)
	AIBehavior.FireWeapon(self.weapon, self.weaponConfig, barrelPos.Position, targetPos, self.config, self.character)
end

function PoliceOfficer:ChaseTarget(victim, head, allOfficers)
	self.walking = true
	self.humanoid.WalkSpeed = self.config.chaseSpeed
	
	local optimalPos = TeamTactics.GetOptimalSpacing(self, allOfficers, head.Position)
	local flankPos = TeamTactics.GetFlankingPosition(self, head.Position, allOfficers)
	
	local targetPos = flankPos or optimalPos
	self.humanoid:MoveTo(targetPos)
end

function PoliceOfficer:EngageTarget(victim, head, allOfficers)
	self.shooting = true
	self.walking = false
	self.humanoid.WalkSpeed = 0
	
	local optimalPos = TeamTactics.GetOptimalSpacing(self, allOfficers, head.Position)
	if (self.humanoidRootPart.Position - optimalPos).Magnitude > 10 then
		self.humanoid:MoveTo(optimalPos)
		task.wait(0.3)
	end
	
	AIBehavior.FaceTarget(self.humanoidRootPart, head.Position)
	self:FireWeapon(head.Position)
	
	self.ticksSinceMove = self.ticksSinceMove + 1
	if self.ticksSinceMove >= 20 then
		self.ticksSinceMove = 0
		local evasivePos = TeamTactics.AvoidPlayerLOS(self, head.Position)
		if evasivePos then
			self.humanoid:MoveTo(evasivePos)
		end
	end
end

function PoliceOfficer:UseTactics(victim, head)
	if not victim or not head then return end
	
	task.spawn(function()
		local success = AIBehavior.SeekCover(self.humanoid, self.humanoidRootPart, self.torso, head.Position, self.character)
		
		if success then
			self.inCover = true
			self.coverPosition = self.humanoidRootPart.Position
			
			for i = 1, 4 do
				if not victim.Character or not victim.Character:FindFirstChild("Head") then break end
				
				local currentHead = victim.Character.Head
				AIBehavior.PeekAndShoot(self.humanoid, self.humanoidRootPart, self.coverPosition, currentHead.Position, 
									 self.weapon, self.weaponConfig, self.config, self.character)
				
				task.wait(math.random(1, 2))
			end
			
			self.inCover = false
			self.tacticalMode = false
		else
			self.tacticalMode = false
		end
	end)
end

function PoliceOfficer:IdleWander()
	if self.shooting or self.walking then return end
	self.walking = true
	self.humanoid.WalkSpeed = self.config.patrolSpeed
	
	AIBehavior.PatrolMovement(self.humanoid, self.humanoidRootPart, self.torso, self.spawnPoint, self.character)
	self.walking = false
end

function PoliceOfficer:QuickReposition()
	self.walking = true
	self.shooting = false
	self.canShoot = false
	
	AIBehavior.QuickReposition(self.humanoid, self.torso, self.config.chaseSpeed, self.config.patrolSpeed, self.character)
	
	self.walking = false
	self.canShoot = true
end

function PoliceOfficer:InitiateSearch()
	if not self.lastSeenTarget then return end
	
	local lastKnownPos = self.humanoidRootPart.Position
	if self.lastSeenTarget.Character and self.lastSeenTarget.Character:FindFirstChild("HumanoidRootPart") then
		lastKnownPos = self.lastSeenTarget.Character.HumanoidRootPart.Position
	end
	
	local officerCount = self.manager:GetTotalOfficerCount()
	CommunicationSystem.ReportPlayerLost(self.lastSeenTarget.Name, lastKnownPos, officerCount, self.manager)
	
	self.lastSeenTarget = nil
end

function PoliceOfficer:ExecuteSearchBehavior()
	if self.shooting or self.tacticalMode then return end
	
	local searchPoint = SearchSystem.GetNextSearchPoint(self)
	if searchPoint then
		self.walking = true
		self.humanoid.WalkSpeed = self.config.patrolSpeed
		
		if self.searchAssignment == "perimeter" then
			self.humanoid:MoveTo(searchPoint)
			task.wait(3)
		else
			self.humanoid:MoveTo(searchPoint)
			
			local timeout = 0
			while (self.humanoidRootPart.Position - searchPoint).Magnitude > 8 and timeout < 5 do
				timeout = timeout + task.wait(0.2)
			end
			
			task.wait(math.random(2, 4))
			SearchSystem.CompleteSearchPoint(self)
		end
		
		self.walking = false
	end
end

function PoliceOfficer:Die()
	if self.state == "dead" then return end
	
	self.state = "dead"

	
	CommunicationSystem.ReportOfficerDown(self.officerType, self.humanoidRootPart.Position, self.manager)
	
	local corpse = self.character:Clone()
	for _, script in pairs(corpse:GetDescendants()) do
		if script:IsA("Script") or script:IsA("LocalScript") then
			script.Enabled = false
		end
	end
	corpse.Parent = workspace
	Debris:AddItem(corpse, 15)
	
	task.spawn(function()
		task.wait(self.config.respawnTime)
		if self.manager then
			self.manager:RespawnOfficer(self.officerType, self.spawnPoint)
		end
		if self.character and self.character.Parent then
			self.character:Destroy()
		end
	end)
end

function PoliceOfficer:GetInfo()
	return {
		type = self.officerType,
		health = self.health,
		maxHealth = self.maxHealth,
		state = self.state,
		position = self.humanoidRootPart and self.humanoidRootPart.Position or Vector3.new(0, 0, 0),
		weapon = self.weapon and self.weapon.Name or "None"
	}
end

function PoliceOfficer:Destroy()
	if self.character and self.character.Parent then
		self.character:Destroy()
	end
end

return PoliceOfficer