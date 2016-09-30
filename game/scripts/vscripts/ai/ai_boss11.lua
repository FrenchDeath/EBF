--[[
Broodking AI
]]

require( "ai/ai_core" )
function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
	thisEntity.spike = thisEntity:FindAbilityByName("creature_aoe_spikes")
	thisEntity.lightning = thisEntity:FindAbilityByName("creature_lightning_storm")
end


function AIThink()
	if thisEntity.spike:IsFullyCastable() and thisEntity.lightning:IsFullyCastable() then
		local range = thisEntity.spike:GetCastRange()
		if thisEntity.spike:GetCastRange() < thisEntity.lightning:GetCastRange() then range = thisEntity.lightning:GetCastRange() end
		local target = AICore:HighestThreatHeroInRange( thisEntity, range, 15, false )
		if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, range, false ) end
		if target then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				AbilityIndex = thisEntity.spike:entindex(),
				Position = target:GetOrigin()
			})
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = thisEntity.lightning:entindex()
			})
			return 0.25
		end
	elseif thisEntity.spike:IsFullyCastable() then
		local target = AICore:HighestThreatHeroInRange( thisEntity, thisEntity.spike:GetCastRange(), 15, false )
		if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, thisEntity.spike:GetCastRange(), false ) end
		if target then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				AbilityIndex = thisEntity.spike:entindex(),
				Position = target:GetOrigin()
			})
			return 0.25
		end
	elseif thisEntity.lightning:IsFullyCastable() then
		local target = AICore:HighestThreatHeroInRange( thisEntity, thisEntity.lightning:GetCastRange(), 0, false )
		if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, thisEntity.lightning:GetCastRange(), false ) end
		if target then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				TargetIndex = target:entindex(),
				AbilityIndex = thisEntity.lightning:entindex()
			})
		end
		return 0.25
	end
	AICore:AttackHighestPriority( thisEntity )
	return 0.25
end