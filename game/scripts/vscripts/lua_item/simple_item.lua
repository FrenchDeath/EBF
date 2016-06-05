require( "libraries/Timers" )
require( "lua_abilities/Check_Aghanim" )

function refresher( keys )
    local caster = keys.caster
    
    -- Reset cooldown for abilities
    local no_refresh_skill = {["mirana_arrow"] = true}
    for i = 0, caster:GetAbilityCount() - 1 do
        local ability = caster:GetAbilityByIndex( i )
        if ability and ability ~= keys.ability and not no_refresh_skill[ ability:GetAbilityName() ] then
            ability:EndCooldown()
        end
    end
    for i=0, 5, 1 do
        local current_item = keys.caster:GetItemInSlot(i)
        if current_item ~= nil then
            if current_item:GetName() ~= "item_refresher" then  --Refresher Orb does not refresh itself.
                current_item:EndCooldown()
            end
        end
    end
end




-- Clears the force attack target upon expiration
function BerserkersCallEnd( keys )
    local target = keys.target

    target:SetForceAttackTarget(nil)
end


function Cooldown_powder(keys)
    local item = keys.ability
    local caster = keys.caster
    local dust_effect = ParticleManager:CreateParticle("particles/chronos_powder.vpcf", PATTACH_ABSORIGIN  , caster)
    ParticleManager:SetParticleControl(dust_effect, 0, caster:GetAbsOrigin())
    if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_challenger" then
        item:StartCooldown(45)
    end
    if GetMapName() == "epic_boss_fight_hard" then
        item:StartCooldown(35)
    end
    if GetMapName() == "epic_boss_fight_normal" then
        item:StartCooldown(25)
    end
end

function Cooldown_pixels(keys)
    local item = keys.ability
    local caster = keys.caster
    local dust_effect = ParticleManager:CreateParticle("particles/chronos_powder.vpcf", PATTACH_ABSORIGIN  , caster)
    ParticleManager:SetParticleControl(dust_effect, 0, caster:GetAbsOrigin())
    if GetMapName() == "epic_boss_fight_impossible" or GetMapName() == "epic_boss_fight_challenger" then
        item:StartCooldown(18)
    end
    if GetMapName() == "epic_boss_fight_hard" then
        item:StartCooldown(15)
    end
    if GetMapName() == "epic_boss_fight_normal" then
        item:StartCooldown(12)
    end
end

function ares_powder(keys)
    local caster = keys.caster
    local radius = keys.item:GetLevelSpecialValueFor("Radius", 0)
    caster.ennemyunit = FindUnitsInRadius(caster:GetTeam(),
                              caster:GetAbsOrigin(),
                              nil,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
    for _,unit in pairs(caster.ennemyunit) do
        unit:SetForceAttackTarget(nil)
        if caster:IsAlive() then
            local order = 
            {
                UnitIndex = target:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                TargetIndex = caster:entindex()
            }
            ExecuteOrderFromTable(order)
        else
            unit:Stop()
        end
        unit:SetForceAttackTarget(caster)
    end
end
function ares_powder_end(keys)

    for _,unit in pairs(caster.ennemyunit) do
        unit:SetForceAttackTarget(nil)
    end
end

function tank_boosterApply(keys)
    local caster = keys.caster
    local item = keys.ability
    local modifierName = "health_booster"
	local curr_health = caster:GetHealth()
    local health_stacks = caster:GetStrength()
    item:ApplyDataDrivenModifier( caster, caster, modifierName, {})
    caster:SetModifierStackCount( modifierName, caster, health_stacks)

end

function tank_booster(keys)
    local caster = keys.caster
    local item = keys.ability
    local modifierName = "health_booster"
	local curr_health = caster:GetHealth()
    local health_stacks = caster:GetStrength()
    caster:SetModifierStackCount( modifierName, caster, health_stacks)
	if curr_health > caster:GetHealth() then
		caster:SetHealth(curr_health)
	end

end

function Have_Item(unit,item_name)
    local haveit = false
    for itemSlot = 0, 5, 1 do
        local Item = unit:GetItemInSlot( itemSlot )
        if Item ~= nil and Item:GetName() == item_name then
            haveit = true
        end
    end
    return haveit
end

function add_soul_charge(keys)
    local caster = keys.caster
    local item = keys.ability

    if caster.Soul_Charge== nil then
        caster.Soul_Charge = 0 
    end
    caster.Soul_Charge = caster.Soul_Charge + 1
    if caster.Soul_Charge == 1 then 
        item:ApplyDataDrivenModifier(caster, caster, "gauntlet_bonus_soul", {})
    end
    caster:SetModifierStackCount( "gauntlet_bonus_soul", caster, caster.Soul_Charge)
    Timers:CreateTimer(20.0,function()
        caster.Soul_Charge = caster.Soul_Charge - 1
        caster:SetModifierStackCount( "gauntlet_bonus_soul", caster, caster.Soul_Charge)
        if caster.Soul_Charge == 0 then
            caster:RemoveModifierByName( "gauntlet_bonus_soul" )
        end
    end)

end

function scale_asura(keys)
    local caster = keys.caster
    local item = keys.ability
    
        Timers:CreateTimer(2.0,function()
                local stack = GameRules._roundnumber
                caster:SetModifierStackCount( "scale_per_round_heart", caster, stack)
                caster:SetModifierStackCount( "scale_per_round_plate", caster, stack)
                caster:SetModifierStackCount( "scale_per_round_rapier", caster, stack)
                caster:SetModifierStackCount( "scale_per_round_staff", caster, stack)
                caster:SetModifierStackCount( "scale_per_round_sword", caster, stack)
                caster:SetModifierStackCount( "scale_display", caster, stack)
                if Have_Item(caster,item:GetName()) == true then
                    return 2.0
                end
        end)

end

function Berserker(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability
    caster.check = true
    
    Timers:CreateTimer(0.5,function()
        if HasCustomItem(caster,item) then
            local damage_total = item:GetLevelSpecialValueFor("health_percent_damage", item:GetLevel()-1) * caster:GetMaxHealth() * 0.01
            if caster:GetModifierStackCount( "berserker_bonus_damage", ability ) ~= damage_total and caster.check == true and item ~= nil then
                if caster:IsRealHero() then
                    item:ApplyDataDrivenModifier(caster, caster, "berserker_bonus_damage", {})
                    caster:SetModifierStackCount( "berserker_bonus_damage", item, damage_total )
                end
            end
            return 0.5
        end
    end)
end

function Berserker_destroy(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability
    local health_reduction = item:GetLevelSpecialValueFor("health_percent_lose", item:GetLevel()-1) * caster:GetMaxHealth() * 0.01
    caster.check = false
    Timers:CreateTimer(0.1,function()
        caster:SetModifierStackCount( "berserker_bonus_damage", item, 0 )
        caster:RemoveModifierByName( "berserker_bonus_damage" )
    end)
end

function Pierce(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability
	local int_scaling = 1+(caster:GetIntellect()/1600)
    local percent = item:GetLevelSpecialValueFor("Pierce_percent", 0)
    local damage = (keys.damage_on_hit*percent*0.01)/int_scaling
    local damageTable = {victim = target,
                attacker = caster,
                damage = damage,
                damage_type = DAMAGE_TYPE_PURE,
                ability = keys.ability,
                }
    ApplyDamage(damageTable)
end


function Pierce_Splash(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability
    local radius = item:GetLevelSpecialValueFor("radius", 0)
    local percent = item:GetLevelSpecialValueFor("splash_damage", 0)
	local percent_p = item:GetLevelSpecialValueFor("Pierce_percent", 0)
	local int_scaling = 1+(caster:GetIntellect()/1600)
    local damage = keys.damage_on_hit*0.01/int_scaling
    local nearbyUnits = FindUnitsInRadius(target:GetTeam(),
                              target:GetAbsOrigin(),
                              nil,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
    for _,unit in pairs(nearbyUnits) do
        if unit ~= target then
            local damageTable = {victim = unit,
                        attacker = caster,
                        damage = damage*(1-percent_p),
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                        ability = keys.ability
                        }
            ApplyDamage(damageTable)
        end
    end
	for _,unit in pairs(nearbyUnits) do
		local damageTable = {victim = unit,
                attacker = caster,
                damage = damage*percent_p,
                damage_type = DAMAGE_TYPE_PURE,
                ability = keys.ability
                }
		ApplyDamage(damageTable)
	end
end

function ToggleItem(keys)
	for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item == nil then
			keys.caster:AddItem(CreateItem("item_dummy_datadriven", keys.caster, keys.caster))
		end
	end
	
	keys.caster:RemoveItem(keys.ability)
	keys.caster:AddItem(CreateItem(keys.ItemName, keys.caster, keys.caster))  --This should be put into the same slot that the removed item was in.
	
	for i=0, 5, 1 do  --Remove all dummy items from the player's inventory.
		local current_item = keys.caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_dummy_datadriven" then
				keys.caster:RemoveItem(current_item)
			end
		end
	end
end

function LightningJump(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local jump_delay = 0.25
	local radius = 800
	
	-- Removes the hidden modifier
	target:RemoveModifierByName("modifier_arc_lightning_hammer")
	
	-- Waits on the jump delay
	Timers:CreateTimer(jump_delay,
    function()
		-- Finds the current instance of the ability by ensuring both current targets are the same
		local current
		for i=0,ability.instance do
			if ability.target[i] ~= nil then
				if ability.target[i] == target then
					current = i
				end
			end
		end
	
		-- Adds a global array to the target, so we can check later if it has already been hit in this instance
		if target.hit == nil then
			target.hit = {}
		end
		-- Sets it to true for this instance
		target.hit[current] = true
	
		-- Decrements our jump count for this instance
		ability.jump_count[current] = ability.jump_count[current] - 1
	
		-- Checks if there are jumps left
		if ability.jump_count[current] > 0 then
			-- Finds units in the radius to jump to
			local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE , 0, false)
			local closest = radius
			local new_target
			for i,unit in ipairs(units) do
				-- Positioning and distance variables
				local unit_location = unit:GetAbsOrigin()
				local vector_distance = target:GetAbsOrigin() - unit_location
				local distance = (vector_distance):Length2D()
				-- Checks if the unit is closer than the closest checked so far
				if distance < closest then
					-- If the unit has not been hit yet, we set its distance as the new closest distance and it as the new target
					if unit.hit == nil then
						new_target = unit
						closest = distance
					elseif unit.hit[current] == nil then
						new_target = unit
						closest = distance
					end
				end
			end
			-- Checks if there is a new target
			if new_target ~= nil then
				-- Creates the particle between the new target and the last target
				local lightningBolt = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, target)
				ParticleManager:SetParticleControl(lightningBolt,0,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))   
				ParticleManager:SetParticleControl(lightningBolt,1,Vector(new_target:GetAbsOrigin().x,new_target:GetAbsOrigin().y,new_target:GetAbsOrigin().z + new_target:GetBoundingMaxs().z ))
				-- Sets the new target as the current target for this instance
				ability.target[current] = new_target
				-- Applies the modifer to the new target, which runs this function on it
				ability:ApplyDataDrivenModifier(caster, new_target, "modifier_arc_lightning_hammer", {})
			else
				-- If there are no new targets, we set the current target to nil to indicate this instance is over
				ability.target[current] = nil
			end
		else
			-- If there are no more jumps, we set the current target to nil to indicate this instance is over
			ability.target[current] = nil
		end
	end)
end

--[[Author: YOLOSPAGHETTI
	Date: March 24, 2016
	Keeps track of all instances of the spell (since more than one can be active at once)]]
function NewInstance(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	-- Keeps track of the total number of instances of the ability (increments on cast)
	if ability.instance == nil then
		ability.instance = 0
		ability.jump_count = {}
		ability.target = {}
	else
		ability.instance = ability.instance + 1
	end
	
	-- Sets the total number of jumps for this instance (to be decremented later)
	ability.jump_count[ability.instance] = ability:GetLevelSpecialValueFor("jump_count", (ability:GetLevel() -1))
	-- Sets the first target as the current target for this instance
	ability.target[ability.instance] = target
	
	-- Creates the particle between the caster and the first target
	local lightningBolt = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(lightningBolt,0,Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))   
    ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))   
end

function CD_divine_armor(keys)
    keys.ability:StartCooldown(33)
end

function CD_Bahamut(keys)
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_*")) do
        if unit:GetTeam() == DOTA_TEAM_GOODGUYS then
            for itemSlot = 0, 5, 1 do --a For loop is needed to loop through each slot and check if it is the item that it needs to drop
                    if unit ~= nil then --checks to make sure the killed unit is not nonexistent.
                        local Item = unit:GetItemInSlot( itemSlot ) -- uses a variable which gets the actual item in the slot specified starting at 0, 1st slot, and ending at 5,the 6th slot.
                        if Item ~= nil and Item:GetName() == "item_bahamut_chest" or Item ~= nil and Item:GetName() == "item_asura_plate" then
                            Item:StartCooldown(40)
                        end
                    end
            end
        end
    end
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
        if unit:GetTeam() == DOTA_TEAM_GOODGUYS and unit:HasInventory() then
            for itemSlot = 0, 5, 1 do --a For loop is needed to loop through each slot and check if it is the item that it needs to drop
                    if unit ~= nil then --checks to make sure the killed unit is not nonexistent.
                        local Item = unit:GetItemInSlot( itemSlot ) -- uses a variable which gets the actual item in the slot specified starting at 0, 1st slot, and ending at 5,the 6th slot.
                        if Item ~= nil and Item:GetName() == "item_bahamut_chest" or Item ~= nil and Item:GetName() == "item_asura_plate" then
                            Item:StartCooldown(40)
                        end
                    end
            end
        end
    end
        
end

function CD_pure(keys)
    local CD = keys.cooldown
    if keys.ability:GetCooldownTimeRemaining() <=CD then
        keys.ability:StartCooldown(CD)
    end
end

function item_blink_boots_check_charge(keys)
    local item = keys.ability

    if item:GetCurrentCharges() == 0 then item:SetCurrentCharges(1) end
    if item.blink_charge == nil then item:SetCurrentCharges(3) end

    item.blink_charge = true
    item.blink_next_charge = GameRules:GetGameTime() + 8

    Timers:CreateTimer(0.3,function() 
        if item.blink_charge == true then
            if GameRules:GetGameTime() >= item.blink_next_charge and item:GetCurrentCharges() < 3 then
                item:SetCurrentCharges(item:GetCurrentCharges()+1)
                item.blink_next_charge = GameRules:GetGameTime() + 8
            end
            return 0.3
        end
    end)
end

function item_blink_boots_stop_charge(keys)
    local item = keys.ability
    item.blink_charge = false
end

function item_blink_boots_blink(keys)
    local item = keys.ability
    local caster = keys.caster
    if item:GetCurrentCharges() > 0 then
        local nMaxBlink = 1500 
        local nClamp = 1200
        local vPoints = item:GetCursorPosition() 
        local vOrigin = caster:GetAbsOrigin()

        ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, caster)
        caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
        local vDistance = vPoints - vOrigin
        if vDistance:Length2D() > nMaxBlink then
            vPoints = vOrigin + (vPoints - vOrigin):Normalized() * nClamp
        end
        caster:SetAbsOrigin(vPoints)
        FindClearSpaceForUnit(caster, vPoints, false)
        ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, caster)
        if item:GetCurrentCharges() == 3 then
            item.blink_next_charge = GameRules:GetGameTime() + 8
        end
        item:SetCurrentCharges(item:GetCurrentCharges()-1)
        if item:GetCurrentCharges() == 0 then
            item:StartCooldown(item.blink_next_charge - GameRules:GetGameTime())
        end
    end
end


function item_dagon_datadriven_on_spell_start(keys)
    local caster = keys.caster
    local item = keys.ability
    local int_multiplier = item:GetLevelSpecialValueFor("damage_per_int", 0) 
    local damage = caster:GetIntellect() * int_multiplier + item:GetLevelSpecialValueFor("damage_base", 0) 
    print (damage)
    local dagon_particle = ParticleManager:CreateParticle("particles/dagon_mystic.vpcf",  PATTACH_ABSORIGIN_FOLLOW, keys.caster)
    ParticleManager:SetParticleControlEnt(dagon_particle, 1, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), false)
    local particle_effect_intensity = (200 + caster:GetIntellect()^0.2) --Control Point 2 in Dagon's particle effect takes a number between 400 and 800, depending on its level.
    ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))
    
    keys.caster:EmitSound("DOTA_Item.Dagon.Activate")
    keys.target:EmitSound("DOTA_Item.Dagon5.Target")
        
    ApplyDamage({victim = keys.target, attacker = keys.caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL,ability = keys.ability,})
end

function ShowPopup( data )
    if not data then return end

    local target = data.Target or nil
    if not target then error( "ShowNumber without target" ) end
    local number = tonumber( data.Number or nil )
    local pfx = data.Type or "miss"
    local player = data.Player or nil
    local color = data.Color or Vector( 255, 255, 255 )
    local duration = tonumber( data.Duration or 1 )
    local presymbol = tonumber( data.PreSymbol or nil )
    local postsymbol = tonumber( data.PostSymbol or nil )

    local path = "particles/msg_fx/msg_" .. pfx .. ".vpcf"
    local particle = ParticleManager:CreateParticle(path, PATTACH_OVERHEAD_FOLLOW, target)
    if player ~= nil then
        local particle = ParticleManager:CreateParticleForPlayer( path, PATTACH_OVERHEAD_FOLLOW, target, player)
    end

    local digits = 0
    if number ~= nil then digits = #tostring( number ) end
    if presymbol ~= nil then digits = digits + 1 end
    if postsymbol ~= nil then digits = digits + 1 end

    ParticleManager:SetParticleControl( particle, 1, Vector( presymbol, number, postsymbol ) )
    ParticleManager:SetParticleControl( particle, 2, Vector( duration, digits, 0 ) )
    ParticleManager:SetParticleControl( particle, 3, color )
end


function dev_armor(keys)
    local killedUnit = EntIndexToHScript( keys.caster_entindex )
    local origin = killedUnit:GetAbsOrigin()
    Timers:CreateTimer(0.03,function()
        killedUnit:RespawnHero(false, false, false)
        killedUnit:SetAbsOrigin(origin)
    end)

end

function check_admin(keys)
    local caster = keys.caster
    local item = keys.ability
    local ID = caster:GetPlayerID()
    if ID ~= nil and PlayerResource:IsValidPlayerID( ID ) then
        if PlayerResource:GetSteamAccountID( ID ) == 42452574 or PlayerResource:GetSteamAccountID( ID ) == 36111451 then
            print ("Here is the Nerf hammer in the hand of the great lord FrenchDeath")
        else
            Timers:CreateTimer(0.3,function()
				Notifications:Top(pID, {text="YOU HAVE NO RIGHT TO HAVE THIS ITEM!", duration=3})
                caster:RemoveItem(item)
            end)
        end
    end
end


function Berserker_damage(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability
    local health_reduction = item:GetLevelSpecialValueFor("health_percent_lose", item:GetLevel()-1) * caster:GetMaxHealth() * 0.01

    if caster:IsRealHero() then
        caster:SetHealth(caster:GetHealth()-health_reduction)
        if caster:GetHealth() <=0 then
          caster:SetHealth(1)
        end
    end
end

function Crests(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability

    local armor_percent = item:GetLevelSpecialValueFor("active_armor_percent", 0) * 0.01
    local active_damage_reduction = item:GetLevelSpecialValueFor("active_damage_reduction", 0)
    local active_duration = item:GetLevelSpecialValueFor("active_duration", 0)

    local new_armor_target = math.floor(target:GetPhysicalArmorValue() * (armor_percent))
    local new_armor_caster = math.floor(caster:GetPhysicalArmorValue() * (armor_percent))

    local armor_modifier = "crest_armor_reduction"
    local debuff = "crest_debuff"
    item:ApplyDataDrivenModifier(caster, target, armor_modifier, { duration = active_duration })
    target:SetModifierStackCount( armor_modifier, item, new_armor_target )

    item:ApplyDataDrivenModifier(caster, target, debuff, { duration = active_duration })
    target:SetModifierStackCount( debuff, item, 1 )


    item:ApplyDataDrivenModifier(caster, caster, armor_modifier, { duration = active_duration })
    caster:SetModifierStackCount( armor_modifier, item, new_armor_caster )

    item:ApplyDataDrivenModifier(caster, caster, debuff, { duration = active_duration })
    caster:SetModifierStackCount( debuff, item, 1 )
end

function veil(keys)
    local item = keys.ability
    local point = keys.target_points[1]

    local Magical_ress_reduction = item:GetLevelSpecialValueFor("MR_debuff", 0)
    local active_duration = item:GetLevelSpecialValueFor("active_duration", 0)
    local debuff_radius = item:GetLevelSpecialValueFor("debuff_radius", 0)
    local debuff = "veil_debuff"
    local nearbyUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                              point,
                              nil,
                              debuff_radius,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
    local new_armor_target =  0
    for _,unit in pairs(nearbyUnits) do
        --[[if unit.oldMR ~= nil then
            unit.oldMR = (unit:GetBaseMagicalResistanceValue() - unit.lastusedmr)
        end
        unit.oldMR = unit:GetBaseMagicalResistanceValue()
        unit.lastusedmr = Magical_ress_reduction
        ]]
        new_armor_target =  math.floor(unit:GetBaseMagicalResistanceValue()  + Magical_ress_reduction)
        
        unit:SetBaseMagicalResistanceValue(new_armor_target)
        item:ApplyDataDrivenModifier(caster, unit, debuff, { duration = active_duration })
        unit:SetModifierStackCount( debuff, item, 1 )
    end
end

function scythe_decay(keys)
    local item = keys.ability
	local target = keys.target
	local magic_reduction = keys.magic_reduction
    local new_armor_target =  0
    new_armor_target =  math.floor(target:GetBaseMagicalResistanceValue()  + magic_reduction)
    target:SetBaseMagicalResistanceValue(new_armor_target)
    end

function restoremagicress(keys)
    print ("test")
    local item = keys.ability
    local unit = keys.target
    local magic_reduction = keys.magic_reduction
    --unit.oldMR = true
    unit:SetBaseMagicalResistanceValue(unit:GetBaseMagicalResistanceValue() - magic_reduction)
end

function Splash(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability
    local radius = item:GetLevelSpecialValueFor("radius", 0)
    local percent = item:GetLevelSpecialValueFor("splash_damage", 0)
    local damage = keys.damage_on_hit*percent*0.01
    local nearbyUnits = FindUnitsInRadius(target:GetTeam(),
                              target:GetAbsOrigin(),
                              nil,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
    for _,unit in pairs(nearbyUnits) do
        if unit ~= target then
            local damageTable = {victim = unit,
                        attacker = caster,
                        damage = damage,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                        ability = keys.ability,
                        }
            ApplyDamage(damageTable)
        end
    end
end

function Boss_Splash(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability
    local radius = item:GetLevelSpecialValueFor("radius", 0)
    local percent = item:GetLevelSpecialValueFor("splash_damage", 0)
    local damage = keys.damage_on_hit*percent*0.01
    local nearbyUnits = FindUnitsInRadius(target:GetTeam(),
                              target:GetAbsOrigin(),
                              nil,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
    for _,unit in pairs(nearbyUnits) do
        if unit ~= target then
            local damageTable = {victim = unit,
                        attacker = caster,
                        damage = damage,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                        ability = keys.ability,
                        }
            ApplyDamage(damageTable)
        end
    end
end




function Splash_melee(keys)
    local caster = keys.caster
    local target = keys.target
    local item = keys.ability
    local radius = item:GetLevelSpecialValueFor("radius", 0)
    local percent = item:GetLevelSpecialValueFor("splash_damage", 0)
    local damage = keys.damage_on_hit*percent*0.01
	local damagefilter = 1+(caster:GetIntellect()/1600)
    if caster:IsRangedAttacker() == false then
        local damageTable = {victim = target,
							attacker = caster,
                            damage = damage/damagefilter,
                            ability = keys.ability,
                            damage_type = DAMAGE_TYPE_PURE,
                            }
        ApplyDamage(damageTable)
		DoCleaveAttack( caster, target, item, damage, radius, "particles/econ/items/faceless_void/faceless_void_weapon_bfury/faceless_void_weapon_bfury_cleave.vpcf" )
    end
end