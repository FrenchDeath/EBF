require("libraries/Timers")

function ManaDrain(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- If its an illusion then kill it
	if target:IsIllusion() then
		target:ForceKill(true)
	else
		-- Location variables
		local caster_location = caster:GetAbsOrigin()
		local target_location = target:GetAbsOrigin()

		-- Distance variables
		local distance = (target_location - caster_location):Length2D()
		local break_distance = ability:GetLevelSpecialValueFor("break_distance", (ability:GetLevel() - 1))
		local direction = (target_location - caster_location):Normalized()

		-- If the leash is broken then stop the channel
		if distance >= break_distance or not caster:IsChanneling() then
			ability:SetChanneling(false)
			StopSoundEvent(keys.sound, target)
			target:RemoveModifierByName(keys.modifier)
			caster:Stop()
			return
		end

		-- Make sure that the caster always faces the target
		caster:SetForwardVector(direction)

		-- Mana calculation
		local mana_per_second = ability:GetLevelSpecialValueFor("mana_per_second", (ability:GetLevel() - 1))
		local tick_interval = ability:GetLevelSpecialValueFor("tick_interval", (ability:GetLevel() - 1))
		local mana_drain = mana_per_second * tick_interval
		
		if not ability.channel then ability.channel = 0 end
		ability.channel = ability.channel + tick_interval
		
		local target_mana = target:GetMana()

		-- Mana drain part
		-- If the target has enough mana then drain the maximum amount
		-- otherwise drain whatever is left
		if target_mana >= mana_drain then
			target:ReduceMana(mana_drain)
			caster:GiveMana(mana_drain)
		else
			target:ReduceMana(target_mana)
			caster:GiveMana(target_mana)
		end
	end
end

function ManaBall(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local manaradius = (ability:GetSpecialValueFor("mana_per_second"))/5
	local projectileTable = {
        Ability = ability,
        EffectName = "particles/ice_ball_final.vpcf",
        vSpawnOrigin = caster:GetOrigin(),
        fDistance = ability:GetCastRange(),
        fStartRadius = 200 + manaradius,
        fEndRadius = 200 + manaradius,
        fExpireTime = GameRules:GetGameTime() + 1,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = GetGroundPosition((target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized(), caster) * ability:GetCastRange()
    }
    ability.manaball = ProjectileManager:CreateLinearProjectile( projectileTable )
end

function ManaBallHit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local duration = ability:GetSpecialValueFor("duration")
	if ability.channel == 0 then ability.channel = 0.25 end
	local damage = ability:GetAbilityDamage() * (ability.channel/duration)

	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})

end

function ManaBallReset(keys)
	keys.ability.channel = 0
end