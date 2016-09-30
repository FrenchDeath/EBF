function ClockStopperAutoCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability:IsCooldownReady() and ability:GetAutoCastState() and not caster:IsInvulnerable() and not caster:HasModifier("clock_stopper_buff") and caster:IsAttacking() then
		ability:CastAbility()
	end
	if caster:HasModifier("modifier_faceless_void_chronosphere_speed")	then
		if caster:HasScepter() or HasCustomScepter(caster) then
		ability:ApplyDataDrivenModifier(caster,caster, "clock_stopper_buff", {duration = 0.5})
		end
	end
end

function AdamantiumShellAutoCast(keys)
	local caster = keys.caster
	local ability = keys.ability
	local unit = keys.target
	if ability:IsCooldownReady() and ability:GetAutoCastState() then
		caster:Interrupt()
		order = 
		{
			UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			TargetIndex = unit:entindex(),
			AbilityIndex = ability:entindex(),
			Queue = true
		}
		ExecuteOrderFromTable(order)
	end
end