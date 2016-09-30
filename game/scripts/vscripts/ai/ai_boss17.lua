--[[
Broodking AI
]]

require( "ai/ai_core" )
function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
	thisEntity.kick = thisEntity:FindAbilityByName("creature_kick")
	thisEntity.punch = thisEntity:FindAbilityByName("creature_punch")
	thisEntity.kick:SetHidden(false)
	thisEntity.bloodlust = thisEntity:FindAbilityByName("boss_ogre_magi_bloodlust_champ")
	thisEntity.smash = thisEntity:FindAbilityByName("creature_melee_smash")
	if not thisEntity.bloodlust then thisEntity.bloodlust = thisEntity:FindAbilityByName("boss_ogre_magi_bloodlust_champ_vh") end
	if not thisEntity.smash then thisEntity.smash = thisEntity:FindAbilityByName("creature_melee_smash_h") end
end


function AIThink()
	if thisEntity.bloodlust:IsFullyCastable() and thisEntity:GetHealth() < 0.5*thisEntity:GetMaxHealth() and not thisEntity:HasModifier("modifier_ogre_magi_bloodlust") then
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			TargetIndex = thisEntity:entindex(),
			AbilityIndex = thisEntity.bloodlust:entindex()
		})
		return 0.25
	end
	if thisEntity.kick:IsFullyCastable() then
		local target = AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.kick:GetCastRange() + 50, true)
		if target then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = thisEntity.kick:entindex()
			})
			return 0.25
		end
	end
	if thisEntity.punch:IsFullyCastable() then
		local target = AICore:WeakestEnemyHeroInRange( thisEntity, thisEntity.punch:GetCastRange() + 50, true)
		if target then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex =  thisEntity.punch:entindex()
			})
			return 0.25
		end
	end
	if thisEntity.smash:IsFullyCastable() and AICore:TotalEnemyHeroesInRange( thisEntity, 500) > 2 then
		print(AICore:TotalEnemyHeroesInRange( thisEntity, 500))
		local target = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.smash:GetCastRange())
		if target then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position = target:GetOrigin(),
				AbilityIndex = thisEntity.smash:entindex()
			})
			return 0.25
		end
	end
	AICore:AttackHighestPriority( thisEntity )
	return 0.25
end