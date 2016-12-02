--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 1 )
	thisEntity.summon = thisEntity:FindAbilityByName("creature_summon_slither")
	thisEntity.crush = thisEntity:FindAbilityByName("creature_slithereen_crush")
end


function AIThink()
	local radius = thisEntity.crush:GetSpecialValueFor("crush_radius")
	if AICore:TotalNotDisabledEnemyHeroesInRange( thisEntity, radius ) > math.floor(AICore:TotalEnemyHeroesInRange( thisEntity, radius )/2) 
	and thisEntity.crush:IsFullyCastable()
	and AICore:TotalEnemyHeroesInRange( thisEntity, radius ) ~= 0  then
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			AbilityIndex = thisEntity.crush:entindex()
		})
		return 0.25
	end
	AICore:AttackHighestPriority( thisEntity )
	return 0.25
end