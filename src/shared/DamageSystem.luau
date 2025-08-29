local DamageSystem = {}

function DamageSystem.ApplyDamage(target, damage, source)
	if not target or not target.Character then
		return false
	end
	
	local humanoid = target.Character:FindFirstChild("Humanoid")
	if not humanoid then
		return false
	end
	
	humanoid.Health = math.max(0, humanoid.Health - damage)
	return true
end

function DamageSystem.CreateDamageIndicator(position, damage, color)
	-- Damage indicators disabled
end

return DamageSystem