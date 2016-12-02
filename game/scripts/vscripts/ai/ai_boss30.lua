--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	if thisEntity:GetUnitName() == "npc_dota_boss30_h" then 
		thisEntity.suffix = "_h"
	elseif thisEntity:GetUnitName() == "npc_dota_boss30_vh" then
		thisEntity.suffix = "_vh"
	else
		thisEntity.suffix = ""
	end
	thisEntity.impale = thisEntity:FindAbilityByName("boss_melee_impale"..thisEntity.suffix)
	thisEntity.carapace = thisEntity:FindAbilityByName("boss_carapace"..thisEntity.suffix)
	thisEntity.impale2 = thisEntity:FindAbilityByName("boss_melee_impale_b"..thisEntity.suffix)
end


function AIThink()
	local radius = 500
	if AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, radius, false ) <= AICore:TotalEnemyHeroesInRange( thisEntity, radius ) 
	and AICore:TotalEnemyHeroesInRange( thisEntity, radius ) ~= 0 
	and thisEntity.impale:IsFullyCastable() then
		local smashRadius = thisEntity.impale:GetSpecialValueFor("impact_radius")
		local position = AICore:OptimalHitPosition(thisEntity, radius, smashRadius)
		if position then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position = position,
				AbilityIndex = thisEntity.impale:entindex()
			})
			return 0.25
		end
	end
	if thisEntity.impale2:IsFullyCastable() then
		local target = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.impale2:GetCastRange(), false )
		if target then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				Position = target:GetOrigin(),
				AbilityIndex = thisEntity.impale2:entindex()
			})
			return 0.25
		end
	end
	if thisEntity.carapace:IsFullyCastable() then
		if  AICore:BeingAttacked( thisEntity ) >= 1 then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = thisEntity.carapace:entindex()
			})
			return 0.25
		end
	end
	AICore:AttackHighestPriority( thisEntity )
	return 0.25
end