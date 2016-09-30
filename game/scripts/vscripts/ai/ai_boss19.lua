--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	thisEntity.armor = thisEntity:FindAbilityByName("boss_living_armor")
	thisEntity.summon = thisEntity:FindAbilityByName("creature_summon_tree")
	thisEntity.summon2 = thisEntity:FindAbilityByName("creature_summon_tree2")
	thisEntity.sprout = thisEntity:FindAbilityByName("furion_sprout")
end


function AIThink()
	if not thisEntity:IsChanneling() then
		if thisEntity.armor:IsFullyCastable() and not thisEntity:HasModifier("modifier_treant_living_armor") then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = thisEntity:entindex(),
				AbilityIndex = thisEntity.armor:entindex()
			})
			return 0.25
		end
		if thisEntity.summon:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.summon:entindex()
			})
			return 0.25
		end
		if thisEntity.summon2:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.summon2:entindex()
			})
			return 0.25
		end
		radius = thisEntity:GetAttackRange()+thisEntity:GetAttackRangeBuffer()
		target = AICore:HighestThreatHeroInRange(thisEntity, radius, 0, true)
		if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, radius, true) end
		if not target then target = AICore:NearestEnemyHeroInRange( thisEntity, 9999, true) end
		if target then
			if target:GetHealth() < target:GetMaxHealth()*0.4 then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
					Position = target:GetOrigin(),
					AbilityIndex = thisEntity.sprout:entindex()
				})
				return 0.25
			end
		end
		AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else return 0.5 end
end