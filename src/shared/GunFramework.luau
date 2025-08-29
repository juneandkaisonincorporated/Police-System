-- Gun Framework - Simplified
-- Basic shooting mechanics for police officers

local Debris = game:GetService("Debris")
local DamageSystem = require(script.Parent.DamageSystem)

local GunFramework = {}

-- Basic gun configurations
GunFramework.GunConfigs = {
	["G17"] = { damage = 25, fireRate = 0.5, range = 60 },
	["AK-47"] = { damage = 35, fireRate = 0.2, range = 100 },
	["MP5"] = { damage = 20, fireRate = 0.1, range = 80 },
	["Deagle"] = { damage = 50, fireRate = 0.8, range = 80 },
	["Sniper"] = { damage = 100, fireRate = 2.5, range = 200 },
	["Minigun"] = { damage = 15, fireRate = 0.05, range = 100 },
	["Shotgun"] = { damage = 60, fireRate = 1.2, range = 50 },
	["P90"] = { damage = 18, fireRate = 0.08, range = 70 },
	["RPG-7"] = { damage = 200, fireRate = 3.0, range = 80 },
	["M1911"] = { damage = 30, fireRate = 0.6, range = 70 },
	["P22"] = { damage = 20, fireRate = 0.4, range = 50 },
	["Python"] = { damage = 55, fireRate = 1.0, range = 90 },
	["Locomotive 12G"] = { damage = 70, fireRate = 1.5, range = 40 },
	["M3EMR"] = { damage = 90, fireRate = 2.0, range = 180 },
	["Queen's Wrath"] = { damage = 95, fireRate = 2.2, range = 190 },
	["Rattlesnake"] = { damage = 85, fireRate = 1.8, range = 170 },
	["Raven"] = { damage = 80, fireRate = 1.6, range = 160 },
	["BRK9000 SAW"] = { damage = 25, fireRate = 0.1, range = 120 },
	["Brenner-21"] = { damage = 30, fireRate = 0.15, range = 130 },
	["The Judge"] = { damage = 45, fireRate = 0.9, range = 35 },
	["RPK"] = { damage = 40, fireRate = 0.25, range = 110 },
	["AK-5"] = { damage = 32, fireRate = 0.22, range = 95 },
	["AK74"] = { damage = 33, fireRate = 0.21, range = 98 },
	["AMCAR"] = { damage = 28, fireRate = 0.18, range = 85 },
	["AUG"] = { damage = 30, fireRate = 0.19, range = 90 },
	["Mosconi 12G"] = { damage = 75, fireRate = 1.8, range = 35 },
	["Street Sweeper 12G"] = { damage = 50, fireRate = 0.8, range = 45 },
	["Bluntforce D780"] = { damage = 35, fireRate = 0.12, range = 140 },
}

-- Simple Gun class
local Gun = {}
Gun.__index = Gun

function Gun.new(weaponTool, gunType)
	local self = setmetatable({}, Gun)
	self.weaponTool = weaponTool
	self.gunType = gunType
	self.config = GunFramework.GunConfigs[gunType] or { damage = 25, fireRate = 0.5, range = 60 }
	self.lastFireTime = 0
	self.isEquipped = false
	return self
end

function Gun:Equip(character)
	if not character then return false end
	
	-- Find right arm or similar
	local rightArm = character:FindFirstChild("Right Arm") or 
					 character:FindFirstChild("RightArm") or
					 character:FindFirstChild("RightHand")
	
	if not rightArm then
		-- Try any arm-like part
		for _, child in pairs(character:GetChildren()) do
			if child:IsA("BasePart") and (child.Name:find("Arm") or child.Name:find("Hand")) then
				rightArm = child
				break
			end
		end
	end
	
	if not rightArm then
		warn("[Gun] No arm found for weapon")
		return false
	end
	
	-- Find weapon part
	local weaponPart = self.weaponTool:FindFirstChild("Handle") or 
					   self.weaponTool:FindFirstChildOfClass("BasePart")
	
	if not weaponPart then
		warn("[Gun] No weapon part found")
		return false
	end
	
	-- Create weld
	self.weaponWeld = Instance.new("Weld")
	self.weaponWeld.Part0 = rightArm
	self.weaponWeld.Part1 = weaponPart
	self.weaponWeld.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, 0, math.rad(90))
	self.weaponWeld.Parent = weaponPart
	
	self.isEquipped = true
	self.character = character
	print("[Gun] Equipped " .. self.gunType .. " to " .. character.Name)
	return true
end

function Gun:Unequip()
	if self.weaponWeld then
		self.weaponWeld:Destroy()
		self.weaponWeld = nil
	end
	self.isEquipped = false
end

function Gun:ShootAt(targetPos)
	if not self.isEquipped then return false end
	
	local currentTime = tick()
	if currentTime - self.lastFireTime < self.config.fireRate then
		return false -- Cooldown
	end
	
	-- Find weapon barrel position
	local weaponPart = self.weaponTool:FindFirstChild("Handle") or 
					   self.weaponTool:FindFirstChild("Barrel") or
					   self.weaponTool:FindFirstChild("Main") or
					   self.weaponTool:FindFirstChildOfClass("BasePart")
	
	local startPos = self.character.HumanoidRootPart.Position + Vector3.new(0, 1, 0)
	local barrelOffset = Vector3.new(0, 0, -2) -- Default barrel offset
	
	if weaponPart then
		-- Calculate barrel position from weapon
		startPos = weaponPart.Position
		-- Try to find the front of the weapon (barrel end)
		local weaponCFrame = weaponPart.CFrame
		local weaponSize = weaponPart.Size
		barrelOffset = weaponCFrame.LookVector * (weaponSize.Z / 2 + 1) -- Front of weapon + 1 stud
		startPos = startPos + barrelOffset
	end
	
	-- Create bullet
	local bullet = Instance.new("Part")
	bullet.Name = "Bullet"
	bullet.Size = Vector3.new(0.2, 0.2, 1)
	bullet.Material = Enum.Material.Neon
	bullet.Color = Color3.fromRGB(255, 255, 0)
	bullet.CanCollide = false
	bullet.Anchored = false
	bullet.Shape = Enum.PartType.Ball
	
	-- Position bullet at barrel
	bullet.CFrame = CFrame.new(startPos, targetPos)
	bullet.Parent = workspace
	
	-- Add velocity
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(8000, 8000, 8000)
	bodyVelocity.Velocity = bullet.CFrame.LookVector * 200
	bodyVelocity.Parent = bullet
	
	-- Create muzzle flash at barrel
	local muzzleFlash = Instance.new("PointLight")
	muzzleFlash.Brightness = 3
	muzzleFlash.Range = 10
	muzzleFlash.Color = Color3.fromRGB(255, 200, 100)
	muzzleFlash.Parent = weaponPart or self.character.HumanoidRootPart
	Debris:AddItem(muzzleFlash, 0.1)
	
	-- Handle collision
	local hitConnection
	hitConnection = bullet.Touched:Connect(function(hit)
		if hit:IsDescendantOf(self.character) then return end
		if hit.Name == "Bullet" then return end
		if hit.CanCollide == false then return end -- Don't hit non-solid parts
		
		-- Check if hit a player
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)
		
		if humanoid and player then
			-- Apply damage directly
			local damage = self.config.damage
			humanoid:TakeDamage(damage)
			DamageSystem.CreateDamageIndicator(hit.Position, damage, Color3.fromRGB(255, 0, 0))
			print("[Gun] " .. self.gunType .. " hit " .. player.Name .. " for " .. damage .. " damage")
		end
		
		-- Destroy bullet on any solid collision
		hitConnection:Disconnect()
		bullet:Destroy()
	end)
	
	-- Clean up bullet after time
	Debris:AddItem(bullet, 5)
	
	self.lastFireTime = currentTime
	return true
end

function Gun:GetInfo()
	return {
		gunType = self.gunType,
		damage = self.config.damage,
		fireRate = self.config.fireRate,
		range = self.config.range,
		isEquipped = self.isEquipped
	}
end

-- Simple Gun Manager
local GunManager = {}
GunManager.__index = GunManager

function GunManager.new(character)
	local self = setmetatable({}, GunManager)
	self.character = character
	self.equippedGun = nil
	self.availableGuns = {}
	return self
end

function GunManager:AddGun(weaponTool, gunType)
	local gun = Gun.new(weaponTool, gunType)
	if gun then
		table.insert(self.availableGuns, gun)
		return gun
	end
	return nil
end

function GunManager:EquipBestGun()
	if #self.availableGuns == 0 then return nil end
	
	-- Just equip the first available gun
	local gun = self.availableGuns[1]
	if gun:Equip(self.character) then
		self.equippedGun = gun
		return gun
	end
	return nil
end

function GunManager:ShootAt(targetPos)
	if self.equippedGun then
		return self.equippedGun:ShootAt(targetPos)
	end
	return false
end

function GunManager:GetEquippedGunInfo()
	if self.equippedGun then
		return self.equippedGun:GetInfo()
	end
	return nil
end

function GunManager:LoadGunsFromTools()
	-- Look for gun tools in character
	for _, tool in pairs(self.character:GetChildren()) do
		if tool:IsA("Tool") and GunFramework.GunConfigs[tool.Name] then
			self:AddGun(tool, tool.Name)
		end
	end
end

-- Public API
GunFramework.Gun = Gun
GunFramework.GunManager = GunManager

function GunFramework.GetGunConfig(gunType)
	return GunFramework.GunConfigs[gunType]
end

function GunFramework.GetAvailableGunTypes()
	local types = {}
	for gunType, _ in pairs(GunFramework.GunConfigs) do
		table.insert(types, gunType)
	end
	return types
end

return GunFramework