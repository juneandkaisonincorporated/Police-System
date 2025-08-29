

local _ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local WeaponSystem = {}

function WeaponSystem.SetupWeapon(character, weaponName, rightArm)
	local weaponModel = Config.AssetLoader.GetWeaponModel(weaponName)
	if not weaponModel then
		warn("[Weapon System] Weapon model not found: " .. weaponName)
		return nil
	end
	
	local weapon = weaponModel
	weapon.Name = weaponName
	weapon.Parent = character
	
	local weaponPart = weapon:FindFirstChild("Handle") or weapon:FindFirstChildOfClass("BasePart")
	if weaponPart then
		local weaponWeld = Instance.new("Weld")
		weaponWeld.Name = weaponName .. "Weld"
		weaponWeld.Part0 = rightArm
		weaponWeld.Part1 = weaponPart
		weaponWeld.Parent = weaponPart
		weaponWeld.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, 0, math.rad(90))
	end
	
	local gunConfig = Config.WeaponConfigs[weaponName] or {
		damage = 25, fireRate = 0.5, range = 60, bulletSpeed = 1200, bulletSpread = Vector3.new(25, 25, 0)
	}
	
	return weapon, gunConfig
end

function WeaponSystem.PlayWeaponSound(weapon, weaponConfig)
	if not weaponConfig.soundId then return end
	
	local shootSound = weapon:FindFirstChild("shoot")
	if shootSound then
		shootSound.Volume = 0.3
		shootSound:Play()
	else
		local sound = Instance.new("Sound")
		sound.Name = "shoot"
		sound.SoundId = weaponConfig.soundId
		sound.Volume = 0.3
		sound.Parent = weapon
		sound:Play()
		sound.Ended:Connect(function() sound:Destroy() end)
	end
end

function WeaponSystem.CreateRaycastBullet(startPos, targetPos, weaponConfig, officerConfig, character, addSpread)
	local direction = (targetPos - startPos).Unit
	local distance = (targetPos - startPos).Magnitude
	
	local baseAccuracy = officerConfig.accuracy or 0.8
	local recoilFactor = officerConfig.recoil or 1.0
	local weaponSpread = weaponConfig.bulletSpread or Vector3.new(25, 25, 0)
	
	local distancePenalty = math.max(0, (distance - 10) / 300)
	local finalAccuracy = math.max(0.8, baseAccuracy - distancePenalty)
	
	local accuracyMult = (1.0 - finalAccuracy) * 0.2
	local finalSpread = weaponSpread * accuracyMult * recoilFactor * 0.3
	
	local spreadOffset = Vector3.new(
		math.random(-finalSpread.X, finalSpread.X) / 150,
		math.random(-finalSpread.Y, finalSpread.Y) / 150,
		math.random(-finalSpread.Z, finalSpread.Z) / 150
	)
	
	if addSpread then spreadOffset = spreadOffset * 2 end
	direction = (direction + spreadOffset).Unit
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {character}
	
	local maxRange = 500
	local rayResult = workspace:Raycast(startPos, direction * maxRange, raycastParams)
	
	local hitPos = rayResult and rayResult.Position or (startPos + direction * maxRange)
	local actualDistance = (hitPos - startPos).Magnitude
	
	WeaponSystem.CreateBulletTrail(startPos, hitPos, actualDistance)
	
	if rayResult then
		local hitPart = rayResult.Instance
		local parent = hitPart.Parent
		
		if parent and not parent:IsA("Accessory") then
			local humanoid = parent:FindFirstChildOfClass("Humanoid")
			local isPoliceOfficer = parent.Name:find("Officer") or parent.Name:find("SWAT") or parent.Name:find("FBI") or 
								   parent.Name:find("Captain") or parent.Name:find("Juggernaut") or parent.Name:find("Cloaker") or
								   parent.Name:find("Taser") or parent.Name:find("Responder") or parent.Name:find("Rescue") or
								   parent.Name:find("Shield") or parent.Name:find("Sniper") or parent.Name:find("Skulldozer")
			
			if humanoid and not isPoliceOfficer then
				local player = Players:GetPlayerFromCharacter(parent)
				if player then
					local baseDamage = weaponConfig.damage
					local finalDamage = baseDamage
					
					if weaponConfig.weaponType == "Sniper" then
						finalDamage = math.random(baseDamage * 0.9, baseDamage * 1.1)
					else
						finalDamage = math.random(baseDamage * 0.3, baseDamage * 0.4)
					end
					
					humanoid:TakeDamage(finalDamage)
					print("[HIT] " .. player.Name .. " -" .. math.floor(finalDamage) .. " HP")
				end
			end
		end
	end
end

function WeaponSystem.CreateBulletTrail(startPos, endPos, distance)
	local bullet = Instance.new("Part")
	bullet.Name = "BulletTrail"
	bullet.Size = Vector3.new(0.2, 0.2, distance)
	bullet.Material = Enum.Material.Neon
	bullet.Color = Color3.fromRGB(255, 255, 0)
	bullet.CanCollide = false
	bullet.Anchored = true
	bullet.Shape = Enum.PartType.Cylinder
	bullet.Transparency = 0
	
	local midPoint = (startPos + endPos) / 2
	bullet.CFrame = CFrame.new(midPoint, endPos) * CFrame.Angles(0, math.rad(90), 0)
	bullet.Parent = workspace
	
	task.spawn(function()
		task.wait(0.1)
		for i = 1, 10 do
			bullet.Transparency = i / 10
			task.wait(0.01)
		end
		bullet:Destroy()
	end)
end

return WeaponSystem
