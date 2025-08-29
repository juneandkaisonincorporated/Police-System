local Config = {}
Config.OfficerTypes = {
	Officer = { health = 100, damage = 25, detectionRadius = 80, attackRange = 60, patrolSpeed = 8, chaseSpeed = 12, weapon = "G17", spawnRate = 0.6, respawnTime = 10, randomWeaponChance = 0.4, accuracy = 0.95, recoil = 0.3, modelName = "Bricktech Officer", threatLevel = 1 },
	FirstResponder = { health = 90, damage = 25, detectionRadius = 75, attackRange = 55, patrolSpeed = 10, chaseSpeed = 14, weapon = "G17", spawnRate = 0.25, respawnTime = 8, randomWeaponChance = 0.4, accuracy = 0.93, recoil = 0.4, modelName = "First Responder", threatLevel = 1 },
	TaserOperator = { health = 95, damage = 30, detectionRadius = 70, attackRange = 50, patrolSpeed = 8, chaseSpeed = 12, weapon = "P22", spawnRate = 0.1, respawnTime = 10, randomWeaponChance = 0.3, accuracy = 0.94, recoil = 0.3, modelName = "Taser Operator", threatLevel = 1 },
	
	SWAT = { health = 150, damage = 40, detectionRadius = 90, attackRange = 70, patrolSpeed = 10, chaseSpeed = 14, weapon = "AK-47", spawnRate = 0.03, respawnTime = 15, randomWeaponChance = 0.5, accuracy = 0.98, recoil = 0.1, modelName = "SWAT Officer", threatLevel = 2 },
	SniperSWAT = { health = 80, damage = 75, detectionRadius = 300, attackRange = 250, patrolSpeed = 7, chaseSpeed = 11, weapon = "Sniper", spawnRate = 0.01, respawnTime = 18, randomWeaponChance = 0.3, accuracy = 0.995, recoil = 0.02, modelName = "Sniper SWAT", threatLevel = 3 },
	RiotShieldSWAT = { health = 200, damage = 30, detectionRadius = 80, attackRange = 50, patrolSpeed = 6, chaseSpeed = 10, weapon = "MP5", spawnRate = 0.02, respawnTime = 20, randomWeaponChance = 0.3, accuracy = 0.96, recoil = 0.2, modelName = "RiotShield SWAT", threatLevel = 2 },
	
	FBI = { health = 120, damage = 45, detectionRadius = 100, attackRange = 80, patrolSpeed = 9, chaseSpeed = 13, weapon = "MP5", spawnRate = 0.01, respawnTime = 12, randomWeaponChance = 0.6, accuracy = 0.98, recoil = 0.1, modelName = "FBI Officer", threatLevel = 3 },
	SniperFBI = { health = 90, damage = 85, detectionRadius = 400, attackRange = 350, patrolSpeed = 8, chaseSpeed = 12, weapon = "Queen's Wrath", spawnRate = 0.005, respawnTime = 20, randomWeaponChance = 0.4, accuracy = 0.998, recoil = 0.01, modelName = "Sniper FBI", threatLevel = 4 },
	RiotShieldFBI = { health = 220, damage = 40, detectionRadius = 85, attackRange = 55, patrolSpeed = 7, chaseSpeed = 11, weapon = "P90", spawnRate = 0.01, respawnTime = 22, randomWeaponChance = 0.4, accuracy = 0.97, recoil = 0.15, modelName = "RiotShield FBI", threatLevel = 3 },
	
	Captain = { health = 130, damage = 50, detectionRadius = 85, attackRange = 65, patrolSpeed = 9, chaseSpeed = 13, weapon = "Deagle", spawnRate = 0.02, respawnTime = 12, randomWeaponChance = 0.3, accuracy = 0.96, recoil = 0.2, modelName = "Captain", threatLevel = 2 },
	CaptainEscort = { health = 140, damage = 55, detectionRadius = 90, attackRange = 70, patrolSpeed = 10, chaseSpeed = 15, weapon = "Python", spawnRate = 0.015, respawnTime = 14, randomWeaponChance = 0.4, accuracy = 0.95, recoil = 0.25, modelName = "Captain Escort", threatLevel = 2 },
	Cloaker = { health = 110, damage = 60, detectionRadius = 95, attackRange = 75, patrolSpeed = 12, chaseSpeed = 18, weapon = "MP5", spawnRate = 0.008, respawnTime = 15, randomWeaponChance = 0.5, accuracy = 0.99, recoil = 0.05, modelName = "Cloaker", threatLevel = 4 },
	HostageRescueTeam = { health = 160, damage = 55, detectionRadius = 95, attackRange = 75, patrolSpeed = 11, chaseSpeed = 16, weapon = "AK-5", spawnRate = 0.005, respawnTime = 18, randomWeaponChance = 0.5, accuracy = 0.98, recoil = 0.1, modelName = "Hostage Rescue Team", threatLevel = 3 },
	
	Juggernaut = { health = 300, damage = 70, detectionRadius = 100, attackRange = 80, patrolSpeed = 6, chaseSpeed = 9, weapon = "Minigun", spawnRate = 0.003, respawnTime = 25, randomWeaponChance = 0.2, accuracy = 0.88, recoil = 1.2, modelName = "Juggernaut", threatLevel = 4 },
	BlackJuggernaut = { health = 350, damage = 80, detectionRadius = 110, attackRange = 90, patrolSpeed = 5, chaseSpeed = 8, weapon = "BRK9000 SAW", spawnRate = 0.002, respawnTime = 30, randomWeaponChance = 0.2, accuracy = 0.90, recoil = 1.0, modelName = "BlackJuggenaut", threatLevel = 4 },
	Skulldozer = { health = 400, damage = 90, detectionRadius = 120, attackRange = 100, patrolSpeed = 4, chaseSpeed = 7, weapon = "Minigun", spawnRate = 0.001, respawnTime = 35, randomWeaponChance = 0.1, accuracy = 0.85, recoil = 1.5, modelName = "Skulldozer", threatLevel = 4 },
}


Config.System = {
	maxOfficers = 20,
	spawnInterval = 3,
	despawnTime = 300,
	debugMode = true,
	
	threatEscalation = {
		level1 = { maxOfficers = 8, types = {"Officer", "FirstResponder", "TaserOperator"} },
		level2 = { maxOfficers = 12, types = {"Officer", "FirstResponder", "SWAT", "Captain"} },
		level3 = { maxOfficers = 16, types = {"SWAT", "RiotShieldSWAT", "FBI", "Captain", "CaptainEscort"} },
		level4 = { maxOfficers = 20, types = {"FBI", "SniperFBI", "Cloaker", "HostageRescueTeam", "Juggernaut"} },
		level5 = { maxOfficers = 25, types = {"SniperFBI", "BlackJuggernaut", "Skulldozer", "Cloaker"} }
	},
	
	customPatrolPaths = {},
	
	assets = {
		officers = "Law Enforcement",
		weapons = "Weapons",
		sounds = "Sounds",
		effects = "Effects",
		ui = "UI",
	},
}

Config.WeaponConfigs = {
	["G17"] = { damage = 25, fireRate = 0.5, bulletSpeed = 1000, bulletSpread = Vector3.new(15, 15, 0), weaponType = "Pistol", pelletCount = 1, soundId = "rbxassetid://1583819337" },
	["M1911"] = { damage = 30, fireRate = 0.6, bulletSpeed = 1100, bulletSpread = Vector3.new(12, 12, 0), weaponType = "Pistol", pelletCount = 1, soundId = "rbxassetid://1583819337" },
	["P22"] = { damage = 20, fireRate = 0.4, bulletSpeed = 900, bulletSpread = Vector3.new(10, 10, 0), weaponType = "Pistol", pelletCount = 1, soundId = "rbxassetid://1583819337" },
	["Deagle"] = { damage = 50, fireRate = 0.8, bulletSpeed = 1200, bulletSpread = Vector3.new(8, 8, 0), weaponType = "Pistol", pelletCount = 1, soundId = "rbxassetid://1583819337" },
	["Python"] = { damage = 55, fireRate = 1.0, bulletSpeed = 1300, bulletSpread = Vector3.new(5, 5, 0), weaponType = "Pistol", pelletCount = 1, soundId = "rbxassetid://1583819337" },
	["JP36"] = { damage = 22, fireRate = 0.45, bulletSpeed = 950, bulletSpread = Vector3.new(12, 12, 0), weaponType = "Pistol", pelletCount = 1, soundId = "rbxassetid://1583819337" },
	["M1014"] = { damage = 28, fireRate = 0.7, bulletSpeed = 1050, bulletSpread = Vector3.new(14, 14, 0), weaponType = "Pistol", pelletCount = 1, soundId = "rbxassetid://1583819337" },
	["Mac"] = { damage = 24, fireRate = 0.55, bulletSpeed = 980, bulletSpread = Vector3.new(16, 16, 0), weaponType = "Pistol", pelletCount = 1, soundId = "rbxassetid://1583819337" },
	["Model"] = { damage = 26, fireRate = 0.52, bulletSpeed = 1020, bulletSpread = Vector3.new(13, 13, 0), weaponType = "Pistol", pelletCount = 1, soundId = "rbxassetid://1583819337" },
	["Bronco .44"] = { damage = 48, fireRate = 0.9, bulletSpeed = 1250, bulletSpread = Vector3.new(6, 6, 0), weaponType = "Pistol", pelletCount = 1, soundId = "rbxassetid://1583819337" },
	["Chimano"] = { damage = 23, fireRate = 0.48, bulletSpeed = 970, bulletSpread = Vector3.new(14, 14, 0), weaponType = "Pistol", pelletCount = 1, soundId = "rbxassetid://1583819337" },
	["Compact-5"] = { damage = 21, fireRate = 0.42, bulletSpeed = 920, bulletSpread = Vector3.new(17, 17, 0), weaponType = "Pistol", pelletCount = 1, soundId = "rbxassetid://1583819337" },
	
	-- Assault Rifles & SMGs (Sound ID: 5910000043)
	["AK-47"] = { damage = 35, fireRate = 0.23, bulletSpeed = 1200, bulletSpread = Vector3.new(25, 25, 0), weaponType = "AssaultRifle", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	["MP5"] = { damage = 20, fireRate = 0.12, bulletSpeed = 1100, bulletSpread = Vector3.new(20, 20, 0), weaponType = "SMG", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	["P90"] = { damage = 18, fireRate = 0.08, bulletSpeed = 1000, bulletSpread = Vector3.new(30, 30, 0), weaponType = "SMG", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	["AK-5"] = { damage = 32, fireRate = 0.22, bulletSpeed = 1150, bulletSpread = Vector3.new(22, 22, 0), weaponType = "AssaultRifle", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	["AK74"] = { damage = 33, fireRate = 0.21, bulletSpeed = 1180, bulletSpread = Vector3.new(23, 23, 0), weaponType = "AssaultRifle", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	["AMCAR"] = { damage = 28, fireRate = 0.18, bulletSpeed = 1050, bulletSpread = Vector3.new(18, 18, 0), weaponType = "AssaultRifle", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	["AUG"] = { damage = 30, fireRate = 0.19, bulletSpeed = 1100, bulletSpread = Vector3.new(19, 19, 0), weaponType = "AssaultRifle", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	["RPK"] = { damage = 40, fireRate = 0.25, bulletSpeed = 1250, bulletSpread = Vector3.new(28, 28, 0), weaponType = "LMG", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	["Assault Rifle"] = { damage = 29, fireRate = 0.20, bulletSpeed = 1080, bulletSpread = Vector3.new(20, 20, 0), weaponType = "AssaultRifle", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	["Commando"] = { damage = 31, fireRate = 0.24, bulletSpeed = 1120, bulletSpread = Vector3.new(21, 21, 0), weaponType = "AssaultRifle", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	["Crosskill"] = { damage = 34, fireRate = 0.26, bulletSpeed = 1180, bulletSpread = Vector3.new(24, 24, 0), weaponType = "AssaultRifle", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	["Sub Machine Gun"] = { damage = 19, fireRate = 0.10, bulletSpeed = 1050, bulletSpread = Vector3.new(32, 32, 0), weaponType = "SMG", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	
	-- Heavy Weapons (Sound ID: 5910000043)
	["Minigun"] = { damage = 12, fireRate = 0.05, bulletSpeed = 900, bulletSpread = Vector3.new(40, 40, 0), weaponType = "Heavy", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	["BRK9000 SAW"] = { damage = 25, fireRate = 0.15, bulletSpeed = 1100, bulletSpread = Vector3.new(35, 35, 0), weaponType = "Heavy", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	["Brenner-21"] = { damage = 30, fireRate = 0.18, bulletSpeed = 1200, bulletSpread = Vector3.new(32, 32, 0), weaponType = "Heavy", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	["Bluntforce D780"] = { damage = 35, fireRate = 0.20, bulletSpeed = 1250, bulletSpread = Vector3.new(30, 30, 0), weaponType = "Heavy", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	
	-- Shotguns (Sound ID: 642890855) - Multiple pellets
	["Shotgun"] = { damage = 15, fireRate = 1.2, bulletSpeed = 800, bulletSpread = Vector3.new(60, 60, 0), weaponType = "Shotgun", pelletCount = 8, soundId = "rbxassetid://642890855" },
	["Locomotive 12G"] = { damage = 18, fireRate = 1.5, bulletSpeed = 750, bulletSpread = Vector3.new(70, 70, 0), weaponType = "Shotgun", pelletCount = 10, soundId = "rbxassetid://642890855" },
	["Mosconi 12G"] = { damage = 25, fireRate = 2.0, bulletSpeed = 900, bulletSpread = Vector3.new(50, 50, 0), weaponType = "Shotgun", pelletCount = 6, soundId = "rbxassetid://642890855" },
	["Street Sweeper 12G"] = { damage = 12, fireRate = 0.8, bulletSpeed = 700, bulletSpread = Vector3.new(80, 80, 0), weaponType = "Shotgun", pelletCount = 12, soundId = "rbxassetid://642890855" },
	["The Judge"] = { damage = 20, fireRate = 0.9, bulletSpeed = 600, bulletSpread = Vector3.new(90, 90, 0), weaponType = "Shotgun", pelletCount = 5, soundId = "rbxassetid://642890855" },
	["Broomstick"] = { damage = 16, fireRate = 1.1, bulletSpeed = 780, bulletSpread = Vector3.new(65, 65, 0), weaponType = "Shotgun", pelletCount = 7, soundId = "rbxassetid://642890855" },
	
	-- Sniper Rifles (Sound ID: 9068554227)
	["Sniper"] = { damage = 75, fireRate = 2.5, bulletSpeed = 2500, bulletSpread = Vector3.new(1, 1, 0), weaponType = "Sniper", pelletCount = 1, soundId = "rbxassetid://9068554227" },
	["M3EMR"] = { damage = 70, fireRate = 2.0, bulletSpeed = 2300, bulletSpread = Vector3.new(1.5, 1.5, 0), weaponType = "Sniper", pelletCount = 1, soundId = "rbxassetid://9068554227" },
	["Rattlesnake"] = { damage = 80, fireRate = 1.8, bulletSpeed = 2600, bulletSpread = Vector3.new(1, 1, 0), weaponType = "Sniper", pelletCount = 1, soundId = "rbxassetid://9068554227" },
	["Queen's Wrath"] = { damage = 85, fireRate = 2.2, bulletSpeed = 2800, bulletSpread = Vector3.new(0.5, 0.5, 0), weaponType = "Sniper", pelletCount = 1, soundId = "rbxassetid://9068554227" },
	["Raven"] = { damage = 72, fireRate = 1.6, bulletSpeed = 2400, bulletSpread = Vector3.new(1.5, 1.5, 0), weaponType = "Sniper", pelletCount = 1, soundId = "rbxassetid://9068554227" },
	["M14"] = { damage = 75, fireRate = 1.5, bulletSpeed = 1600, bulletSpread = Vector3.new(5, 5, 0), weaponType = "Sniper", pelletCount = 1, soundId = "rbxassetid://9068554227" },
	["14gr's Reinfeld"] = { damage = 22, fireRate = 1.3, bulletSpeed = 820, bulletSpread = Vector3.new(55, 55, 0), weaponType = "Shotgun", pelletCount = 9, soundId = "rbxassetid://642890855" },
	["Repeater"] = { damage = 65, fireRate = 1.4, bulletSpeed = 1500, bulletSpread = Vector3.new(6, 6, 0), weaponType = "Sniper", pelletCount = 1, soundId = "rbxassetid://9068554227" },
	["Reinfeld"] = { damage = 17, fireRate = 1.25, bulletSpeed = 790, bulletSpread = Vector3.new(62, 62, 0), weaponType = "Shotgun", pelletCount = 8, soundId = "rbxassetid://642890855" },
	
	-- Special/Other Weapons (Sound ID: 9068554227)
	["'The Hazard'"] = { damage = 45, fireRate = 0.6, bulletSpeed = 1300, bulletSpread = Vector3.new(8, 8, 0), weaponType = "Special", pelletCount = 1, soundId = "rbxassetid://9068554227" },
	["'The Nimble'"] = { damage = 22, fireRate = 0.35, bulletSpeed = 1100, bulletSpread = Vector3.new(12, 12, 0), weaponType = "Special", pelletCount = 1, soundId = "rbxassetid://9068554227" },
	["'The Silent'"] = { damage = 28, fireRate = 0.45, bulletSpeed = 950, bulletSpread = Vector3.new(8, 8, 0), weaponType = "Special", pelletCount = 1, soundId = "rbxassetid://9068554227" },
	["Chicago Typewriter"] = { damage = 22, fireRate = 0.11, bulletSpeed = 1000, bulletSpread = Vector3.new(28, 28, 0), weaponType = "SMG", pelletCount = 1, soundId = "rbxassetid://5910000043" },
	["RPG-7"] = { damage = 150, fireRate = 3.0, bulletSpeed = 600, bulletSpread = Vector3.new(10, 10, 0), weaponType = "Explosive", pelletCount = 1, soundId = "rbxassetid://9068554227" },
	
	-- Additional weapons from your collection
	["Crossbill"] = { damage = 35, fireRate = 0.25, bulletSpeed = 1180, bulletSpread = Vector3.new(22, 22, 0), weaponType = "AssaultRifle", pelletCount = 1, soundId = "rbxassetid://5910000043" },
}

-- Universal Weapon Pool - ANY officer can get ANY weapon, but with realistic probabilities
Config.RandomWeaponPools = {
	-- Universal pool - all officers use this with different chances based on their role
	General = {
		-- Common weapons (higher chance for basic officers)
		{weapon = "G17", chance = 0.15}, {weapon = "M1911", chance = 0.12}, {weapon = "P22", chance = 0.08},
		{weapon = "JP36", chance = 0.06}, {weapon = "Mac", chance = 0.05}, {weapon = "Chimano", chance = 0.05},
		
		-- Assault rifles (moderate chance for all)
		{weapon = "AK-47", chance = 0.08}, {weapon = "MP5", chance = 0.08}, {weapon = "AK-5", chance = 0.06},
		{weapon = "AK74", chance = 0.06}, {weapon = "AMCAR", chance = 0.05}, {weapon = "AUG", chance = 0.05},
		{weapon = "Assault Rifle", chance = 0.05}, {weapon = "Commando", chance = 0.04},
		
		-- SMGs
		{weapon = "P90", chance = 0.06}, {weapon = "Sub Machine Gun", chance = 0.04}, {weapon = "Chicago Typewriter", chance = 0.03},
		
		-- Shotguns (good for close quarters)
		{weapon = "Shotgun", chance = 0.05}, {weapon = "Locomotive 12G", chance = 0.04}, {weapon = "The Judge", chance = 0.03},
		{weapon = "Street Sweeper 12G", chance = 0.03}, {weapon = "Mosconi 12G", chance = 0.02}, {weapon = "Broomstick", chance = 0.02},
		{weapon = "14gr's Reinfeld", chance = 0.02}, {weapon = "Reinfeld", chance = 0.02},
		
		-- Heavy weapons (rare for basic officers)
		{weapon = "Python", chance = 0.04}, {weapon = "Deagle", chance = 0.04}, {weapon = "Bronco .44", chance = 0.03},
		{weapon = "RPK", chance = 0.02}, {weapon = "Minigun", chance = 0.01}, {weapon = "BRK9000 SAW", chance = 0.01},
		
		-- Sniper rifles (very rare for basic officers)
		{weapon = "Sniper", chance = 0.015}, {weapon = "M3EMR", chance = 0.01}, {weapon = "Rattlesnake", chance = 0.008},
		{weapon = "Queen's Wrath", chance = 0.005}, {weapon = "Raven", chance = 0.008}, {weapon = "M14", chance = 0.01},
		{weapon = "Repeater", chance = 0.006},
		
		-- Special weapons (very rare)
		{weapon = "'The Hazard'", chance = 0.005}, {weapon = "'The Nimble'", chance = 0.004}, {weapon = "'The Silent'", chance = 0.003},
		{weapon = "RPG-7", chance = 0.001}, -- Extremely rare
	},
}

-- Asset Loader Module
Config.AssetLoader = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Function to get an officer model
function Config.AssetLoader.GetOfficerModel(officerType)
	local officerConfig = Config.OfficerTypes[officerType]
	if not officerConfig or not officerConfig.modelName then
		warn("Config.AssetLoader: Missing configuration for officer type '%s' or its modelName.", officerType)
		return nil, "Configuration for officer type or its modelName is missing."
	end

	local officersFolder = ReplicatedStorage.Assets:FindFirstChild(Config.System.assets.officers)
	if not officersFolder then
		warn("Config.AssetLoader: Officer assets folder not found at 'ReplicatedStorage/Assets/%s'.", Config.System.assets.officers)
		return nil, "Assets folder not found in ReplicatedStorage/" .. Config.System.assets.officers
	end

	local officerModel = officersFolder:FindFirstChild(officerConfig.modelName)
	if not officerModel then
		warn("Config.AssetLoader: Officer model '%s' not found in 'ReplicatedStorage/Assets/%s'.", officerConfig.modelName, Config.System.assets.officers)
		return nil, "Officer model not found: " .. officerConfig.modelName
	end

	return officerModel:Clone()
end

-- Function to get a weapon model
function Config.AssetLoader.GetWeaponModel(weaponName)
	local weaponsFolder = ReplicatedStorage.Assets:FindFirstChild(Config.System.assets.weapons)
	if not weaponsFolder then
		warn("Config.AssetLoader: Weapon assets folder not found at 'ReplicatedStorage/Assets/%s'.", Config.System.assets.weapons)
		return nil, "Assets folder not found in ReplicatedStorage/" .. Config.System.assets.weapons
	end

	local weaponModel = weaponsFolder:FindFirstChild(weaponName)
	if not weaponModel then
		warn("Config.AssetLoader: Weapon model '%s' not found in 'ReplicatedStorage/Assets/%s'.", weaponName, Config.System.assets.weapons)
		return nil, "Weapon model not found: " .. weaponName
	end

	return weaponModel:Clone()
end

-- Function to get a sound object (currently disabled)
function Config.AssetLoader.GetSound(officerType, soundType)
	-- Sounds are currently disabled for testing
	return nil
end

-- Function to get an effect object
function Config.AssetLoader.GetEffect(effectName)
	local effectsFolder = ReplicatedStorage.Assets:FindFirstChild(Config.System.assets.effects)
	if not effectsFolder then
		warn("Config.AssetLoader: Effect assets folder not found at 'ReplicatedStorage/Assets/%s'.", Config.System.assets.effects)
		return nil, "Assets folder not found in ReplicatedStorage/" .. Config.System.assets.effects
	end

	local effect = effectsFolder:FindFirstChild(effectName)
	if not effect then
		warn("Config.AssetLoader: Effect '%s' not found in 'ReplicatedStorage/Assets/%s'.", effectName, Config.System.assets.effects)
		return nil, "Effect not found: " .. effectName
	end

	return effect:Clone()
end

-- Function to check if all required assets are present
function Config.AssetLoader.CheckAssets()
	local missingAssets = {}

	-- Check officer models
	for officerType, officerConfig in pairs(Config.OfficerTypes) do
		local model, errorMsg = Config.AssetLoader.GetOfficerModel(officerType)
		if not model then
			table.insert(missingAssets, "Officer model: " .. officerConfig.modelName .. " (" .. errorMsg .. ")")
		else
			model:Destroy() -- Clean up cloned model
		end
	end

	-- Check weapon models (only the ones we actually use in weapon pools)
	local weaponNamesToCheck = {
		-- Officer weapons
		"G17", "M1911", "P22", "Deagle", "Python", "Shotgun", "MP5", "The Judge",
		-- SWAT weapons  
		"AK-47", "P90", "AK-5", "AK74", "AMCAR", "AUG", "RPK",
		-- FBI weapons
		"Sniper", "M3EMR", "Rattlesnake", "Queen's Wrath", "Raven"
	}

	for _, weaponName in ipairs(weaponNamesToCheck) do
		local weaponModel, errorMsg = Config.AssetLoader.GetWeaponModel(weaponName)
		if not weaponModel then
			table.insert(missingAssets, "Weapon model: " .. weaponName .. " (" .. errorMsg .. ")")
		else
			weaponModel:Destroy() -- Clean up cloned model
		end
	end

	return missingAssets
end

return Config
