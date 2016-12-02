--[[
Holdout Example

	Underscore prefix such as "_function()" denotes a local function and is used to improve readability
	
	Variable Prefix Examples
		"fl"	Float
		"n"		Int
		"v"		Table
		"b"		Boolean
]]
DAMAGE_TYPES = {
	    [0] = "DAMAGE_TYPE_NONE",
	    [1] = "DAMAGE_TYPE_PHYSICAL",
	    [2] = "DAMAGE_TYPE_MAGICAL",
	    [4] = "DAMAGE_TYPE_PURE",
	    [7] = "DAMAGE_TYPE_ALL",
	    [8] = "DAMAGE_TYPE_HP_REMOVAL",
	}
MAXIMUM_ATTACK_SPEED	= 600
MINIMUM_ATTACK_SPEED	= 20

require("internal/util")
require("lua_item/simple_item")
require("lua_boss/boss_32_meteor")
require( "epic_boss_fight_game_round" )
require( "epic_boss_fight_game_spawner" )
require('lib.optionsmodule')
require('stats')
require( "libraries/Timers" )
require( "libraries/notifications" )
require( "libraries/containers" )
require( "statcollection/init" )
require("libraries/utility")

if CHoldoutGameMode == nil then
	CHoldoutGameMode = class({})
end

-- Precache resources
function Precache( context )
	--PrecacheResource( "particle", "particles/generic_gameplay/winter_effects_hero.vpcf", context )
	PrecacheResource( "particle", "particles/items2_fx/veil_of_discord.vpcf", context )	
	PrecacheResource( "particle_folder", "particles/frostivus_gameplay", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_melee.vpcf", context )

	PrecacheResource( "soundfile", "soundevents/game_sounds_custom.vsndevts", context)
	PrecacheResource( "soundfile", "soundevents/music.vsndevts", context)
	
	PrecacheResource( "model", "models/heroes/troll_warlord/troll_warlord.vmdl", context)
	PrecacheResource( "model", "models/heroes/treant_protector/treant_protector.vmdl", context)
	PrecacheResource( "model", "models/heroes/furion/furion.vmdl", context)
	PrecacheResource( "model", "models/heroes/wraith_king/wraith_frost.vmdl", context)
	PrecacheResource( "model", "models/heroes/shadow_demon/shadow_demon.vmdl", context)
	PrecacheResource( "model", "models/heroes/slark/slark.vmdl", context)
	PrecacheResource( "model", "models/heroes/weaver/weaver.vmdl", context)
	PrecacheResource( "model", "models/heroes/death_prophet/death_prophet.vmdl", context)
	PrecacheResource( "model", "models/heroes/axe/axe.vmdl", context)

	PrecacheItemByNameSync( "item_tombstone", context )
	PrecacheItemByNameSync( "item_bag_of_gold", context )
	PrecacheItemByNameSync( "item_slippers_of_halcyon", context )

    PrecacheUnitByNameSync("npc_dota_boss32_trueform", context)
    PrecacheUnitByNameSync("npc_dota_boss32_trueform_h", context)
    PrecacheUnitByNameSync("npc_dota_boss32_trueform_vh", context)

    PrecacheUnitByNameSync("npc_dota_boss12_b", context)
    PrecacheUnitByNameSync("npc_dota_boss12_b_h", context)
    PrecacheUnitByNameSync("npc_dota_boss12_b_vh", context)
    PrecacheUnitByNameSync("npc_dota_boss12_c", context)
    PrecacheUnitByNameSync("npc_dota_boss12_c_vh", context)
    PrecacheUnitByNameSync("npc_dota_boss12_d", context)
	PrecacheUnitByNameSync("npc_dota_boss21", context)
	PrecacheUnitByNameSync("npc_dota_boss21_h", context)
	PrecacheUnitByNameSync("npc_dota_boss22", context)
	PrecacheUnitByNameSync("npc_dota_boss22_h", context)
	PrecacheUnitByNameSync("npc_dota_boss22_vh", context)

	PrecacheUnitByNameSync("npc_dota_hero_phantom_lancer", context)

end

-- Actually make the game mode when we activate
function Activate()
	GameRules.holdOut = CHoldoutGameMode()
	GameRules.holdOut:InitGameMode()	
end

function DeleteAbility( unit)
    for i=0,15,1 do
					local ability = unit:GetAbilityByIndex(i)
					if ability ~= nil then
						unit:RemoveAbility(ability:GetName())
						if ability ~= nil then
							ability:Destroy()
						end
					end
				end
end
function TeachAbility( unit, ability_name, level )
    if not level then level = 1 end
        unit:AddAbility(ability_name)
        local ability = unit:FindAbilityByName(ability_name)
        if ability then
            ability:SetLevel(tonumber(level))
            return ability
        end
end
function levelAbility( unit, ability_name, level )
    if not level then level = 1 end
        local ability = unit:FindAbilityByName(ability_name)
        if ability then
            ability:SetLevel(tonumber(level))
            return ability
        end
end


function CHoldoutGameMode:InitGameMode()
	print ("Epic Boss Fight loaded Version 0.09.01-03")
	print ("Made By FrenchDeath , a noob in coding ")
	print ("Thank to DrTeaSpoon and Noya from Moddota.com for all the help they give :D")
	GameRules._finish = false
	GameRules.vote_Yes = 0
	GameRules.vote_No = 0
	GameRules.voteRound_Yes = 0;
	GameRules.voteRound_No = 0;
	
	GameRules._Elites = LoadKeyValues( "scripts/kv/elites.kv" )
	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")

	 --Load unit KVs into main kv
	MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_heroes_custom.txt"))
	MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_heroes.txt"))
	MergeTables(GameRules.UnitKV, LoadKeyValues("scripts/npc/npc_units.txt"))
	
	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
	MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_abilities.txt"))
	MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/npc_items_custom.txt"))
	MergeTables(GameRules.AbilityKV, LoadKeyValues("scripts/npc/items.txt"))
	
	

	
	self._nRoundNumber = 1
	GameRules._roundnumber = 1
	GameRules.Recipe_Table = LoadKeyValues("scripts/kv/componements.kv")
	self._NewGamePlus = false
	self._message = false
	self.Last_Target_HB = nil
	self.Shield = false
	self.Last_HP_Display = -1
	self._currentRound = nil
	self._regenround25 = false
	self._regenround13 = false
	self._regenNG = false
	self._check_check_dead = false
	self._flLastThinkGameTime = nil
	self._check_dead = false
	self._timetocheck = 0
	self._freshstart = true
	self.boss_master_id = -1
	Life = SpawnEntityFromTableSynchronous( "quest", { 
		name = "Life", 
		title = "#LIFETITLE" } )
	Life._life = 10
	if GetMapName() == "epic_boss_fight_normal" then Life._life = 12 
		GameRules:SetHeroSelectionTime( 90.0 )
		Life._MaxLife = 12
	end
	if GetMapName() == "epic_boss_fight_hard" then Life._life = 9 
		GameRules:SetHeroSelectionTime( 50.0 )
		Life._MaxLife = 9
	end
	if GetMapName() == "epic_boss_fight_impossible" then Life._life = 6 
		GameRules:SetHeroSelectionTime( 40.0 )
		Life._MaxLife = 6
	end
	if GetMapName() == "epic_boss_fight_challenger" then Life._life = 1 
		GameRules:SetHeroSelectionTime( 30.0 )
		Life._MaxLife = 1
	end

	LifeBar = SpawnEntityFromTableSynchronous( "subquest_base", { 
           show_progress_bar = true, 
           progress_bar_hue_shift = -119 
         } )
	Life:AddSubquest( LifeBar )
	GameRules._live = Life._life
	GameRules._used_live = 0
	-- text on the quest timer at start
	Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
	Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._life )

	-- value on the bar
	LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
	LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._life )



	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 7)
	
	if GetMapName() == "epic_boss_fight_boss_master" then Life._life = 9 
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 1 )
		GameRules:SetHeroSelectionTime( 45.0 )
		Life._MaxLife = 9
	else 
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	end


	self:_ReadGameConfiguration()
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( true )


	GameRules:SetTreeRegrowTime( 10.0 )
	GameRules:SetCreepMinimapIconScale( 4 )
	GameRules:SetRuneMinimapIconScale( 1.5 )
	GameRules:SetGoldTickTime( 600.0 )
	GameRules:SetGoldPerTick( 0 )
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1400)
	xpTable = {
		0,-- 1
		200,-- 2
		500,-- 3
		900,-- 4
		1400,-- 5
		2000,-- 6
		2600,-- 7
		3200,-- 8
		4400,-- 9
		5400,-- 10
		6000,-- 11
		8200,-- 12
		9000,-- 13
		10400,-- 14
		11900,-- 15
		13500,-- 16
		15200,-- 17
		17000,-- 18
		18900,-- 19
		20900,-- 20
		23000,-- 21
		25200,-- 22
		27500,-- 23
		29900,-- 24
		32400, -- 25
		40000, -- 26
		50000, -- 27
		65000, -- 28
		80000, -- 29
		100000, -- 30
		125000, -- 31
		150000, -- 32
		175000, -- 33
		200000, -- 34
		250000, -- 35
		300000, -- 36
		350000, --37
		400000, --38
		500000, --39
		600000, --40
		700000, --41
		800000, --42
		1000000, --43
		1500000, --44
		2000000, --45
		3000000, --46
		4000000, --47
		5000000, --48
		6000000, --49
		7000000, --50
		8000000, --51
		9000000, --52
		10000000, --53
		12000000, --54
		14000000, --55
		16000000, --56
		18000000, --57
		20000000, --58
		22000000, --59
		24000000, --60
		26000000, --61
		28000000, --62
		30000000, --63
		35000000, --64
		40000000, --65
		45000000, --66
		50000000, --67
		55000000, --68
		60000000, --69
		70000000, --70
		80000000, --71
		90000000, --72
		100000000, --73
		125000000, --74
		150000000, --75
		175000000, --76
		200000000, --77
		250000000, --78
		300000000, --79
		400000000, --80
	}

	GameRules:GetGameModeEntity():SetUseCustomHeroLevels( true )
    GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 80 )
    GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( xpTable )
	
	GameRules:GetGameModeEntity():SetMaximumAttackSpeed(MAXIMUM_ATTACK_SPEED)
	GameRules:GetGameModeEntity():SetMinimumAttackSpeed(MINIMUM_ATTACK_SPEED)
	
	-- Custom console commands
	Convars:RegisterCommand( "holdout_test_round", function(...) return self:_TestRoundConsoleCommand( ... ) end, "Test a round of holdout.", FCVAR_CHEAT )
	Convars:RegisterCommand( "holdout_spawn_gold", function(...) return self._GoldDropConsoleCommand( ... ) end, "Spawn a gold bag.", FCVAR_CHEAT )
	Convars:RegisterCommand( "ebf_cheat_drop_gold_bonus", function(...) return self._GoldDropCheatCommand( ... ) end, "Cheat gold had being detected !",0)
	Convars:RegisterCommand( "ebf_gold", function(...) return self._Goldgive( ... ) end, "hello !",0)
	
	Convars:RegisterCommand( "getdunked", function()
											if Convars:GetDOTACommandClient() then
												local player = Convars:GetDOTACommandClient()
												local hero = player:GetAssignedHero() 
												hero:ForceKill(true)
											end
										end, "fixing bug",0)
		
	Convars:RegisterCommand( "ebf_max_level", function(...) return self._LevelGive( ... ) end, "hello !",0)
	Convars:RegisterCommand( "ebf_drop", function(...) return self._ItemDrop( ... ) end, "hello",0)
	Convars:RegisterCommand( "ebf_give_core", function(...) return self._GiveCore( ... ) end, "hello",0)
	Convars:RegisterCommand( "ebf_test_living", function(...) return self._CheckLivingEnt( ... ) end, "hello",0)
	Convars:RegisterCommand( "steal_game", function(...) return self._fixgame( ... ) end, "look like someone try to steal my map :D",0)
	Convars:RegisterCommand( "holdout_status_report", function(...) return self:_StatusReportConsoleCommand( ... ) end, "Report the status of the current holdout game.", FCVAR_CHEAT )

	-- Hook into game events allowing reload of functions at run time
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CHoldoutGameMode, "OnNPCSpawned" ), self )
	ListenToGameEvent( "player_reconnected", Dynamic_Wrap( CHoldoutGameMode, 'OnPlayerReconnected' ), self )
	ListenToGameEvent( "player_disconnect", Dynamic_Wrap( CHoldoutGameMode, 'OnPlayerDisconnected' ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( CHoldoutGameMode, 'OnEntityKilled' ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CHoldoutGameMode, "OnGameRulesStateChange" ), self )
	ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap( CHoldoutGameMode, "OnHeroPick"), self )
	ListenToGameEvent('player_connect_full', Dynamic_Wrap( CHoldoutGameMode, 'OnConnectFull'), self)
    ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(CHoldoutGameMode, 'OnAbilityUsed'), self)
	
	
	-- CustomGameEventManager:RegisterListener('Boss_Master', Dynamic_Wrap( CHoldoutGameMode, 'Boss_Master'))
	CustomGameEventManager:RegisterListener('Demon_Shop', Dynamic_Wrap( CHoldoutGameMode, 'Buy_Demon_Shop_check'))
	CustomGameEventManager:RegisterListener('Tell_Threat', Dynamic_Wrap( CHoldoutGameMode, 'Tell_threat'))
	CustomGameEventManager:RegisterListener('Buy_Perk', Dynamic_Wrap( CHoldoutGameMode, 'Buy_Perk_check'))
	CustomGameEventManager:RegisterListener('Asura_Core', Dynamic_Wrap( CHoldoutGameMode, 'Buy_Asura_Core_shop'))
	CustomGameEventManager:RegisterListener('Tell_Core', Dynamic_Wrap( CHoldoutGameMode, 'Asura_Core_Left'))

	CustomGameEventManager:RegisterListener('mute_sound', Dynamic_Wrap( CHoldoutGameMode, 'mute_sound'))
	CustomGameEventManager:RegisterListener('unmute_sound', Dynamic_Wrap( CHoldoutGameMode, 'unmute_sound'))
	CustomGameEventManager:RegisterListener('Health_Bar_Command', Dynamic_Wrap( CHoldoutGameMode, 'Health_Bar_Command'))

	CustomGameEventManager:RegisterListener('Vote_NG', Dynamic_Wrap( CHoldoutGameMode, 'vote_NG_fct'))
	CustomGameEventManager:RegisterListener('Vote_Round', Dynamic_Wrap( CHoldoutGameMode, 'vote_Round'))



	-- Register OnThink with the game engine so it is called every 0.25 seconds
	GameRules:GetGameModeEntity():SetDamageFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterDamage" ), self )
	GameRules:GetGameModeEntity():SetModifierGainedFilter( Dynamic_Wrap( CHoldoutGameMode, "FilterModifiers" ), self )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 0.25 ) 
	GameRules:GetGameModeEntity():SetThink( "Update_Health_Bar", self, 0.09 ) 
end

function CHoldoutGameMode:vote_Round (event)
 	local ID = event.pID
 	local vote = event.vote
 	local player = PlayerResource:GetPlayer(ID)

 	if player~= nil then
	 	if vote == 1 then
	 		GameRules.voteRound_Yes = GameRules.voteRound_Yes + 1
			GameRules.voteRound_No = GameRules.voteRound_No - 1

			local event_data =
			{
				No = GameRules.voteRound_No,
				Yes = GameRules.voteRound_Yes,
			}
			CustomGameEventManager:Send_ServerToAllClients("RoundVoteResults", event_data)
		end
	end
end

function CHoldoutGameMode:vote_NG_fct (event)
 	local ID = event.pID
 	local vote = event.vote
 	local player = PlayerResource:GetPlayer(ID)
 	--print ("vote"..vote)
 	if player~= nil then
	 	if player.Has_Voted ~= true then
	 		player.Has_Voted = true
	 		if vote == 1 then
	 			GameRules.vote_Yes = GameRules.vote_Yes + 1
	 		else
	 			GameRules.vote_No = GameRules.vote_No + 1
	 		end
			local event_data =
			{
			No = GameRules.vote_No,
			Yes = GameRules.vote_Yes,
			}
			CustomGameEventManager:Send_ServerToAllClients("VoteResults", event_data)
	 	end
	end
end

function CHoldoutGameMode:Health_Bar_Command (event)
 	local ID = event.pID
 	local player = PlayerResource:GetPlayer(ID)
 	--print (event.Enabled)
 	if event.Enabled == 0 then
 		player.HB = false
 		player.Health_Bar_Open = false
 	else
 		player.HB = true
 	end
end

function comma_value(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

---============================================================
-- rounds a number to the nearest decimal places
--
function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

--===================================================================
-- given a numeric value formats output with comma to separate thousands
-- and rounded to given decimal places
--
--
function set_comma_thousand(amount, decimal)
  local str_amount,  formatted, famount, remain

  decimal = decimal or 2  -- default 2 decimal places

  famount = math.abs(round(amount,decimal))
  famount = math.floor(famount)

  remain = round(math.abs(amount) - famount, decimal)

        -- comma to separate the thousands
  formatted = comma_value(famount)

        -- attach the decimal portion
  if (decimal > 0) then
    remain = string.sub(tostring(remain),3)
    formatted = formatted .. "." .. remain ..
                string.rep("0", decimal - string.len(remain))
  end
  return formatted
end

function CHoldoutGameMode:Update_Health_Bar()
		local higgest_ennemy_hp = 0
		local biggest_ennemy = nil
		for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
			if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
				if unit:GetMaxHealth() > higgest_ennemy_hp and unit:IsAlive() then
					biggest_ennemy = unit
					higgest_ennemy_hp = unit:GetMaxHealth()
				end
			end
		end
		if self.Last_Target_HB ~= biggest_ennemy and biggest_ennemy ~= nil then
			if self.Last_Target_HB ~= nil then
				ParticleManager:DestroyParticle(self.Last_Target_HB.HB_particle, false)
			end
			self.Last_Target_HB = biggest_ennemy
			GameRules.focusedUnit = self.Last_Target_HB
			self.Last_Target_HB.HB_particle = ParticleManager:CreateParticle("particles/health_bar_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW   , self.Last_Target_HB)
            ParticleManager:SetParticleControl(self.Last_Target_HB.HB_particle, 0, self.Last_Target_HB:GetAbsOrigin())
            ParticleManager:SetParticleControl(self.Last_Target_HB.HB_particle, 1, self.Last_Target_HB:GetAbsOrigin())
		end
		local ability
		local abilityname = ""
		if biggest_ennemy ~= nil and not biggest_ennemy:IsNull() and biggest_ennemy:IsAlive() then
			if biggest_ennemy.elite then
				for k,v in pairs(GameRules._Elites)	do
					ability = biggest_ennemy:FindAbilityByName(k)
					if ability then
						abilityname = abilityname..v.." " -- add space for boss bar
					end
				end
			end
		end
		Timers:CreateTimer(0.1,function()
			if biggest_ennemy ~= nil and not biggest_ennemy:IsNull() and biggest_ennemy:IsAlive() then
				if biggest_ennemy.have_shield == nil then biggest_ennemy.have_shield = false end
				CustomNetTables:SetTableValue( "HB","HB", {HP = biggest_ennemy:GetHealth() , Max_HP = biggest_ennemy:GetMaxHealth() , MP = biggest_ennemy:GetMana() ,Max_MP = biggest_ennemy:GetMaxMana() , Name = biggest_ennemy:GetUnitName() , shield = biggest_ennemy.have_shield, elite =  abilityname})
			elseif biggest_ennemy ~= nil and not biggest_ennemy:IsNull() and biggest_ennemy:IsAlive() == false then 
				CustomNetTables:SetTableValue( "HB","HB", {HP = 0 , Max_HP = 1 , MP = biggest_ennemy:GetMana() ,Max_MP = biggest_ennemy:GetMaxMana() , Name = biggest_ennemy:GetUnitName() , shield = biggest_ennemy.have_shield, elite = abilityname})
			end
		end)

	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
		return nil
	end
	return 0.09

end


function increase_damage_player(ID,Damage)
	
end

function CHoldoutGameMode:FilterModifiers( filterTable )
	local parent_index = filterTable["entindex_parent_const"]
    local caster_index = filterTable["entindex_caster_const"]
	local ability_index = filterTable["entindex_ability_const"]
    if not parent_index or not caster_index or not ability_index then
        return true
    end
	local duration = filterTable["duration"]
    local parent = EntIndexToHScript( parent_index )
    local caster = EntIndexToHScript( caster_index )
	local ability = EntIndexToHScript( ability_index )
	if ability:GetName() == "enigma_black_hole" 
	or ability:GetName() == "life_stealer_devour"  then return true end
	if parent == caster or not caster or not ability or duration > 99 or duration == -1 then return true end
	-- 1 is ULTIMATE
	if parent:IsCreature() and (caster:HasAbility("perk_disable_piercing") or ability:GetAbilityType() == 1 or ability:PiercesDisableResistance()) then
		if caster:HasAbility("perk_disable_piercing") and ability:GetAbilityType() ~= 1 and not ability:PiercesDisableResistance() then -- ignore perk if already pierces
			local chance = caster:FindAbilityByName("perk_disable_piercing"):GetSpecialValueFor("chance")
			if math.random(100) > chance then
				return true
			end
		end
		local resistance = parent:GetDisableResistance() / 100
		filterTable["duration"] = duration / (1 - resistance)
		local name =  filterTable["name_const"]
		Timers:CreateTimer(duration,function()
 			parent:RemoveModifierByName( name )
 		end)
	end
	return true
end

function CHoldoutGameMode:FilterDamage( filterTable )
    local total_damage_team = 0
    local dps = 0
    local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]
    if not victim_index or not attacker_index then
        return true
    end
	
	local damage = filterTable["damage"] --Post reduction
	if damage == 0 or filterTable["damagetype_const"] == 0 then return true end
	local inflictor = filterTable["entindex_inflictor_const"]

    local victim = EntIndexToHScript( victim_index )
    local attacker = EntIndexToHScript( attacker_index )
    local damagetype = filterTable["damagetype_const"]
	
	if not inflictor and attacker:IsCreature() then -- modifying right click damage types
		damagetype = attacker:GetAttackDamageType()
		filterTable["damagetype_const"] = damagetype
		local armorreduction = (100 - victim:GetPhysicalArmorReduction())/100
		local damagefilter = filterTable["damage"] / armorreduction -- PURE DAMAGE
		if damagetype == 2 then -- magical damage
			filterTable["damage"] = damagefilter *  (1 - victim:GetMagicalArmorValue())
		elseif damagetype == 4 then -- pure damage
			filterTable["damage"] = damagefilter + victim:GetHealth()*0.02 -- make pure damage relevant vs very large hp pools
		end
	end

   -- remove int scaling thanks for fucking with my shit valve
	if attacker == victim and attacker:FindAbilityByName("new_game_damage_increase") then -- stop self damaging abilities from ravaging bosses
		local amp = attacker:FindAbilityByName("new_game_damage_increase")
		local reduction = 1+(amp:GetSpecialValueFor("spell_amp")/100)
		filterTable["damage"] = filterTable["damage"]/reduction
	end
	if inflictor and attacker:IsHero() and not attacker:IsCreature() then
		local ability = EntIndexToHScript( inflictor )
		local aether_multiplier = get_aether_multiplier(attacker)
		local realmult = aether_multiplier
		if aether_multiplier > 4 then 
			aether_multiplier = 4
		end -- clamp lens stacking damage to 10x
		local no_aether = {["elder_titan_earth_splitter"] = true,
						   ["enigma_midnight_pulse"] = true,
						   ["cloak_and_dagger_ebf"] = true,
						   ["tricks_of_the_trade_datadriven"] = true,
						   ["phoenix_sun_ray"] = true,
						   ["item_bloodthorn"] = true,
						   ["item_bloodthorn2"] = true,
						   ["item_bloodthorn3"] = true,
						   ["item_bloodthorn4"] = true,
						   ["item_purethorn"] = true,
						   ["abyssal_underlord_firestorm"] = true,
						   ["huskar_life_break"] = true} -- stop %hp based and right click damage abilities from being amped by aether lens
		local newintscaling = attacker:GetIntellect()/(10000)
		if no_aether[ability:GetName()] or not ability:IsAetherAmplified() then
			aether_multiplier = 1
			newintscaling = 0
		end
	    filterTable["damage"] = filterTable["damage"]*(aether_multiplier + newintscaling)/((attacker:GetIntellect()/1600 + realmult))
		if attacker:HasModifier("spellcrit") then
			local item_crit = {
						   ["item_Dagon_Mystic"] = true,
						   ["item_asura_staff"] = true,}
			local ability = EntIndexToHScript( inflictor )
			local nocrit = true
			if item_crit[ability:GetName()] or (not ability:IsItem() and not no_aether[ability:GetName()]) or not ability:IsAetherAmplified() then
				nocrit = false
			end
			if not nocrit and not attacker.essencecritactive then
				local crititem = attacker:FindItemByName("item_purethorn") or attacker:FindItemByName("item_bloodthorn4") or attacker:FindItemByName("item_bloodthorn3") or attacker:FindItemByName("item_bloodthorn2")
				local chance = crititem:GetSpecialValueFor("spell_crit_chance")
				if chance > math.random(100) then
					local mult = crititem:GetSpecialValueFor("spell_crit_multiplier") / 100
					filterTable["damage"] = filterTable["damage"]*mult
					victim:ShowPopup( {
                    PostSymbol = 4,
                    Color = Vector( 100, 100, 255 ),
                    Duration = 0.7,
                    Number = filterTable["damage"],
                    pfx = "spell_custom"} )
				end
			end
		end
	end
	
	
	--- THREAT AND UI NO MORE DAMAGE MANIPULATION ---
	local damage = filterTable["damage"]
	if not victim:IsHero() and victim ~= attacker then
		local ability
		if inflictor then
			ability = EntIndexToHScript( inflictor )
		end
		if not inflictor or (ability and not ability:HasNoThreatFlag()) then
			if not victim.threatTable then victim.threatTable = {} end
			if not attacker.threat then attacker.threat = 0 end
			local addedthreat = (damage / victim:GetMaxHealth())*100
			local threatcheck = (victim:GetHealthPercent())*100
			if addedthreat > threatcheck then addedthreat = threatcheck end -- remove threat from overkill damage
			attacker.threat = attacker.threat + addedthreat
			attacker.lastHit = GameRules:GetGameTime()
			PlayerResource:SortThreat()
			local event_data =
			{
				threat = attacker.threat,
				lastHit = attacker.lastHit,
				aggro = attacker.aggro
			}
			local player = attacker:GetPlayerOwner()
			CustomGameEventManager:Send_ServerToPlayer( player, "Update_threat", event_data )
		end
	end
    local attackerID = attacker:GetPlayerOwnerID()
    if attackerID and PlayerResource:HasSelectedHero( attackerID ) then
	    local hero = PlayerResource:GetSelectedHeroEntity(attackerID)
	    local player = PlayerResource:GetPlayer(attackerID)
	    local start = false
	    if hero.damageDone == 0 and damage>0 then 
	    	start = true
	    end
	    hero.damageDone = math.floor(hero.damageDone + damage)
	    if start == true then 
	    	start = false
	    	hero.first_damage_time = GameRules:GetGameTime()
	   	end
	   	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
				if PlayerResource:HasSelectedHero( nPlayerID ) then
					local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
					if hero then
						total_damage_team = hero.damageDone + total_damage_team	
					end
				end
			end
		end
		for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
				if PlayerResource:HasSelectedHero( nPlayerID ) then
					local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
					if hero then
						local key = "player_"..hero:GetPlayerID()
					    CustomNetTables:SetTableValue( "Damage",key, {Team_Damage = total_damage_team , Hero_Damage = hero.damageDone , First_hit = hero.first_damage_time} )
						
					end
				end
			end
		end
    end
    return true
end


function GetHeroDamageDone(hero)
    return hero.damageDone
end

function update_asura_core(hero)
		local key = "player_"..hero:GetPlayerID()
		CustomNetTables:SetTableValue( "Asura_core",key, {core = hero.Asura_Core} )
end

function CHoldoutGameMode:OnAbilityUsed(event)
	--will be used in future :p
    local PlayerID = event.PlayerID
    local abilityname = event.abilityname
	local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
	local abilityused = hero:FindAbilityByName(abilityname)
	if not abilityused then abilityused = hero:FindItemByName(abilityname) end
	if self._threat[abilityname] then
		local ability = hero:FindAbilityByName(abilityname)
		local modifier = 0
		local escapemod = 0
		if not ability then ability = hero:FindItemByName(abilityname)
		if self._threat[abilityname] < 0 then
			escapemod = 2
		end
		else modifier = (self._threat[abilityname]*ability:GetLevel())/ability:GetMaxLevel() end
		if not hero.threat then hero.threat = self._threat[abilityname]
		else hero.threat = hero.threat + self._threat[abilityname] + modifier end
		local player = PlayerResource:GetPlayer(PlayerID)
		hero.lastHit = GameRules:GetGameTime() - escapemod
		PlayerResource:SortThreat()
		local event_data =
		{
			threat = hero.threat,
			lastHit = hero.lastHit,
			aggro = hero.aggro
		}
		CustomGameEventManager:Send_ServerToPlayer( player, "Update_threat", event_data )
	end
	if abilityname == "troll_warlord_battle_trance_ebf" then
		local trance = hero:FindAbilityByName("troll_warlord_battle_trance_ebf")
		local duration = trance:GetSpecialValueFor("trance_duration")
		local max_as = trance:GetSpecialValueFor("attack_speed_max")
		GameRules:GetGameModeEntity():SetMaximumAttackSpeed(MAXIMUM_ATTACK_SPEED + max_as)
		Timers:CreateTimer(duration,function()
 			GameRules:GetGameModeEntity():SetMaximumAttackSpeed(MAXIMUM_ATTACK_SPEED)
 		end)
	end
	if abilityused and abilityused:HasPureCooldown() then
		if abilityused:GetCooldownTimeRemaining() < abilityused:GetCooldown(-1) then
			abilityused:EndCooldown()
			abilityused:StartCooldown(abilityused:GetCooldown(-1))
		end
	end
    if abilityname == "rubick_spell_steal" then
		local spellsteal = hero:FindAbilityByName("rubick_spell_steal")
        local target = spellsteal:GetCursorTarget()	
		local speed = spellsteal:GetSpecialValueFor("projectile_speed")
		local range = (hero:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
		local delay = range/speed
        hero.target = target
		if abilityname == "rubick_spell_steal" then
			local target = hero:FindAbilityByName("rubick_spell_steal"):GetCursorTarget()
			local caster = hero
			caster:SetContextThink("SpellStealDelay",function()
				if caster:GetAbilityByIndex(4):GetName() == "oracle_purifying_flames_heal" then
					caster:RemoveAbility("oracle_purifying_flames_damage")
					local newAb = caster:AddAbility("oracle_purifying_flames_damage")
					newAb:SetLevel(caster:GetAbilityByIndex(4):GetLevel())
					newAb:SetStolen(true)
					caster:SwapAbilities("oracle_purifying_flames_damage", "rubick_empty2", true, false)
					caster:RemoveAbility("rubick_empty2")
					
				elseif caster:GetAbilityByIndex(4):GetName() == "oracle_purifying_flames_damage" then
					caster:RemoveAbility("oracle_purifying_flames_heal")
					local newAb = caster:AddAbility("oracle_purifying_flames_heal")
					newAb:SetLevel(caster:GetAbilityByIndex(4):GetLevel())
					newAb:SetStolen(true)
					caster:SwapAbilities("oracle_purifying_flames_heal", "rubick_empty2", true, false)
					caster:RemoveAbility("rubick_empty2")
				end
					return nil
			end,delay)
		end
	end 
	if hero:GetName() == "npc_dota_hero_rubick"  and abilityname ~= "rubick_spell_steal" and hero:IsRealHero() then
		local spell_echo = hero:FindAbilityByName("rubick_spell_echo")
		if spell_echo:GetLevel()-1 >= 0 then
			if hero:FindAbilityByName(abilityname) then
				local ability = hero:FindAbilityByName(abilityname)
				spell_echo.echo = ability
				spell_echo.echotime = GameRules:GetGameTime()
				if ability:GetCursorTarget() then
					spell_echo.echotarget = ability:GetCursorTarget()
					spell_echo.type = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
				elseif ability:GetCursorTargetingNothing() then
					spell_echo.echotarget = ability:GetCursorTargetingNothing()
					spell_echo.type = DOTA_ABILITY_BEHAVIOR_NO_TARGET
				elseif ability:GetCursorPosition() then
					spell_echo.echotarget = ability:GetCursorPosition()
					spell_echo.type = DOTA_ABILITY_BEHAVIOR_POINT
				end
			end
		end
	end
	--print (abilityname)
end

function CHoldoutGameMode:Buy_Asura_Core_shop(event)
	pID = event.pID
	local player = PlayerResource:GetPlayer(pID)
	local hero = player:GetAssignedHero() 
	--print ("bought item")
	if hero:GetGold() >= 24999 then
		PlayerResource:SpendGold(pID, 24999, 0)
	 	hero.Asura_Core = hero.Asura_Core + 1
		Notifications:Top(pID, {text="You have purchased an Asura Core", duration=3})
		update_asura_core(hero)
	else
		Notifications:Top(pID, {text="You don't have enough gold to purchase an Asura Core", duration=3})
	end
end


function CHoldoutGameMode:_Buy_Demon_Shop(pID,item_name,Hprice,item_recipe)
	local player = PlayerResource:GetPlayer(pID)
	local hero = player:GetAssignedHero() 
	local money = hero:GetGold() 
	local Have_Recipe = false
	if item_recipe ~= nil and item_recipe ~= "none" then
		--print ("check if have the item")
		for itemSlot = 0, 11, 1 do
			local item = hero:GetItemInSlot(itemSlot)
			if item ~= nil and item:GetName() == item_recipe then 
				Have_Recipe = true  
				--print ("have the item")
			end
		end
	elseif item_recipe == "none" then
		Have_Recipe = true
	end
	if Have_Recipe == true then
		if hero.Asura_Core >= Hprice or money > 24999 then
			if hero.Asura_Core < Hprice then
				self:_Buy_Asura_Core(pID)
			end
			local found_recipe = false
			for itemSlot = 0, 11, 1 do
				local item = hero:GetItemInSlot(itemSlot)
				if item ~= nil and item:GetName() == item_recipe and found_recipe == false then 
					item:Destroy()
					found_recipe = true
				end
			end
			hero.Asura_Core = hero.Asura_Core - Hprice
			update_asura_core(hero)
			hero:AddItemByName(item_name)
		else
			return
		end
	end
end

function CHoldoutGameMode:Asura_Core_Left(event)
	--print ("show asura core count")
	local pID = event.pID
	local player = PlayerResource:GetPlayer(pID)
	local hero = player:GetAssignedHero() 
	local message = "I have "..hero.Asura_Core.." Asura Cores"
	Say(player, message, true)
end

function CHoldoutGameMode:Tell_threat(event)
	--print ("show asura core count")
	local pID = event.pID
	local player = PlayerResource:GetPlayer(pID)
	local hero = player:GetAssignedHero() 
	local result = math.floor( hero.threat*10 + 0.5 ) / 10
	if result == 0 then result = "no" end
	local message = "I have "..result.." threat!"
	Say(player, message, true)
end

function CHoldoutGameMode:Buy_Demon_Shop_check(event)
	--print ("buy an asura item")
	local pID = event.pID
	local item_name = event.item_name
	local price = event.price
	local item_recipe = event.item_recipe
	if price == nil then return end
	local player = PlayerResource:GetPlayer(pID)
	local hero = player:GetAssignedHero()
	if hero ~= nil then
		--print (hero.Asura_Core)
		if hero.Asura_Core+1 >= price then --check if player have enought Asura Heart (or have enought if he buy one) to buy item
			CHoldoutGameMode:_Buy_Demon_Shop(pID,item_name,price,item_recipe)
		else
		    Notifications:Top(pID, {text="You don't have enough Asura Cores to purchase this", duration=3})
		end
	end
end

function CHoldoutGameMode:Buy_Perk_check(event)
	--print ("buy perk")
	local pID = event.pID
	local perk_name = event.perk_name
	local price = event.price
	local pricegain = event.pricegain
	local message = CHoldoutGameMode._message
	if price == nil then return end
	local player = PlayerResource:GetPlayer(pID)
	local hero = player:GetAssignedHero()
	if hero ~= nil then
		local perk = hero:FindAbilityByName(perk_name)
		local checksum = true
		if perk and perk:GetLevel() >= perk:GetMaxLevel() then
			checksum = false
		end
		if hero.Asura_Core+1 >= price and checksum then --check if player asura core count is sufficient and perk not maxed
			CHoldoutGameMode:_Buy_Perk(pID, perk_name, price, pricegain)
		elseif not message and checksum then
		    Notifications:Top(pID, {text="You need "..(price - hero.Asura_Core).." more Asura Cores", duration=2})
			CHoldoutGameMode._message = true
			Timers:CreateTimer(2,function()
				CHoldoutGameMode._message = false
			end)
		elseif not message and not checksum then
			Notifications:Top(pID, {text="Perk is maxed!", duration=2})
			CHoldoutGameMode._message = true
			Timers:CreateTimer(2,function()
				CHoldoutGameMode._message = false
			end)
		end
	end
end

function CHoldoutGameMode:_Buy_Perk(pID,perk_name,Hprice, pricegain)
	local player = PlayerResource:GetPlayer(pID)
	local hero = PlayerResource:GetSelectedHeroEntity(pID)
	local money = hero:GetGold()
	local difference = hero.Asura_Core - Hprice
	if difference >= 0 or -difference >= (money/24999) then
		while difference < 0 do
			self:_Buy_Asura_Core(pID)
		end
		hero.Asura_Core = hero.Asura_Core - Hprice
		update_asura_core(hero)
		if not hero:FindAbilityByName(perk_name) then
			hero:AddAbility(perk_name)
		end
		local perk = hero:FindAbilityByName(perk_name)
		perk:SetLevel(perk:GetLevel()+1)
		local event_data =
		{
			perk = perk_name,
			price = Hprice,
			pricegain = pricegain or 0,
			level = perk:GetLevel() or 0
		}
		CustomGameEventManager:Send_ServerToPlayer( player, "Update_perk", event_data )
	else
		return
	end
end

function CHoldoutGameMode:_EnterNG()
	print ("Enter NG+ :D")
	self._NewGamePlus = true
	GameRules._NewGamePlus = true
	CustomNetTables:SetTableValue( "New_Game_plus","NG", {NG = 1} )
	-- for _,courier in pairs ( Entities:FindAllByName( "npc_dota_courier*")) do
		-- for i=0, 16 do
			-- local curritem = courier:GetItemInSlot(i)
			-- if curritem then
				-- local itemname = curritem:GetName()
				-- courier:RemoveItem(curritem)
			-- end
		-- end
	-- end
	-- for _,bear in pairs ( Entities:FindAllByName( "npc_dota_lone_druid_bear*")) do
		-- local druid = bear:GetOwnerEntity()
		-- local gold = druid:GetGold()
		-- druid:SetGold(0, false)
		-- local totalgold = 0
		-- for i=0, 16 do
			-- local curritem = bear:GetItemInSlot(i)
			-- if curritem then
				-- local itemname = curritem:GetName()
				-- if string.match(itemname, "chest") or string.match(itemname, "armor") or string.match(itemname, "blade_mail") then
					-- bear:AddItemByName("item_ancient_plate")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "butterfly") or string.match(itemname, "s_a_y") then
					-- bear:AddItemByName("item_ancient_butterfly")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "Dagon") then
					-- bear:AddItemByName("item_ancient_staff")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "heart") then
					-- bear:AddItemByName("item_ancient_heart")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "octarine") then
					-- bear:AddItemByName("item_ancient_core")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "fury") or string.match(itemname, "rage") or string.match(itemname, "gungnir") then
					-- bear:AddItemByName("item_ancient_fury")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "lens") then
					-- bear:AddItemByName("item_ancient_lens")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "soul") then
					-- bear:AddItemByName("item_ancient_soul")
					-- bear:RemoveItem(curritem)
				-- elseif string.match(itemname, "thorn") then
					-- bear:AddItemByName("item_ancient_thorn")
					-- bear:RemoveItem(curritem)
				-- elseif i < 6 then
					-- bear:RemoveItem(curritem)
					-- totalgold = totalgold + 2000
				-- else
					-- bear:RemoveItem(curritem)
				-- end
			-- end
		-- end
		-- for i=0, GameRules:NumDroppedItems() do
			-- local curritem = GameRules:GetDroppedItem(i)
			-- if curritem then
				-- curritem:RemoveSelf()
			-- end
		-- end
		-- druid.Asura_Core = 5 + math.ceil(gold/25000)
		-- update_asura_core(druid)
		-- druid:SetGold(totalgold, true)
	-- end
	-- for _,hero in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
		-- local gold = hero:GetGold()
		-- hero:SetGold(0, false)
		-- local totalgold = 0
		-- for i=0, 16 do
			-- local curritem = hero:GetItemInSlot(i)
			-- if curritem then
				-- local itemname = curritem:GetName()
				-- if itemname == "item_ultimate_scepter" then
					-- hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
				-- end
				-- if string.match(itemname, "chest") or string.match(itemname, "armor") or string.match(itemname, "blade_mail") then
					-- hero:AddItemByName("item_ancient_plate")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "butterfly") or string.match(itemname, "s_a_y") then
					-- hero:AddItemByName("item_ancient_butterfly")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "Dagon") then
					-- hero:AddItemByName("item_ancient_staff")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "heart") then
					-- hero:AddItemByName("item_ancient_heart")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "octarine") then
					-- hero:AddItemByName("item_ancient_core")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "fury") or string.match(itemname, "rage") or string.match(itemname, "gungnir") then
					-- hero:AddItemByName("item_ancient_fury")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "lens") then
					-- hero:AddItemByName("item_ancient_lens")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "soul") then
					-- hero:AddItemByName("item_ancient_soul")
					-- hero:RemoveItem(curritem)
				-- elseif string.match(itemname, "thorn") then
					-- hero:AddItemByName("item_ancient_thorn")
					-- hero:RemoveItem(curritem)
				-- elseif i < 6 then
					-- hero:RemoveItem(curritem)
					-- totalgold = totalgold + 2000
				-- else
					-- hero:RemoveItem(curritem)
				-- end
			-- end
		-- end
		-- for i=0, GameRules:NumDroppedItems() do
			-- local curritem = GameRules:GetDroppedItem(i)
			-- if curritem then
				-- curritem:RemoveSelf()
			-- end
		-- end
		-- hero.Asura_Core = 5 + math.ceil(gold/25000)
		-- update_asura_core(hero)
		-- hero:SetGold(totalgold, true)
	-- end
end

function CHoldoutGameMode:OnHeroPick (event)
 	local hero = EntIndexToHScript(event.heroindex)
 	if hero:GetName() == "npc_dota_hero_invoker" then levelAbility( hero, "invoker_reset", 1) end
	hero:RemoveAbility('attribute_bonus')
	if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		local item = CreateItem('item_courier', hero, hero)
		hero:AddItem(item)
		local playerID = hero:GetPlayerOwnerID()
		hero:CastAbilityImmediately(item, playerID)
		hero:AddItemByName("item_flying_courier")
	end

	hero.damageDone = 0
	hero.Ressurect = 0
	stats:ModifyStatBonuses(hero)
	hero:AddAbility('lua_attribute_bonus')
	local ID = hero:GetPlayerID()
	hero:SetGold(0 , false)
	hero:SetGold(0 , true)
	local player = PlayerResource:GetPlayer(ID)
 	player.HB = true
 	player.Health_Bar_Open = false
 	hero.Asura_Core=0
 	Timers:CreateTimer(2.5,function()
 			if self._NewGamePlus == true and PlayerResource:GetGold(ID)>= 80000 then
 				self._Buy_Asura_Core(ID)
 			end
 			return 2.5
 		end)
	--[[if PlayerResource:GetSteamAccountID( ID ) == 42452574 then
		print ("look like maker of map is here :D")
		message_creator =f true
	end ]]
	--[[if PlayerResource:GetSteamAccountID( ID ) == 86736807 then
		print ("look like a chalenger is here :D")
		message_chalenger = true
		self.chalenger = hero
		GameRules:GetGameModeEntity():SetThink( "Chalenger", self, 0.25 ) 
	end]]
	--[[if PlayerResource:GetSteamAccountID( ID ) == 99364848 then
		print ("look like a naughty guy is here :D")
		message_chalenger = true
		Timers:CreateTimer(0.1,function()
			if hero:GetHealth() >= 2  then hero:SetHealth (1) end
			return 0.1
		end)
	end]]
	if hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then 
		DeleteAbility(hero)
		TeachAbility (hero , "hide_hero")
		hero:AddNoDraw()
		self.boss_master_id = ID
		LinkLuaModifier( "setabilitylayout", "lua_abilities/heroes/modifiers/setabilitylayout.lua" ,LUA_MODIFIER_MOTION_NONE )
		hero:AddNewModifier(hero, nil, "setabilitylayout", nil)
		hero:AddAbility("boss_master_slow_aura")
		hero:AddAbility("boss_master_damage_aura")
		hero:AddAbility("boss_master_armor_aura")
		hero:AddAbility("boss_master_attackspeed_aura")
		hero:AddAbility("boss_master_health_aura")
		hero:AddAbility("boss_master_evasion_aura")
    end
end

function CHoldoutGameMode:mute_sound (event)
 	local ID = event.pID
 	local player = PlayerResource:GetPlayer(ID)
 	StopSoundOn("music.music",player)
 	player.NoMusic = true
end
function CHoldoutGameMode:unmute_sound (event)
 	local ID = event.pID
 	local player = PlayerResource:GetPlayer(ID)
 	EmitSoundOnClient("music.music",player)
 	player.NoMusic = false
end

function CHoldoutGameMode:Boss_Master (event)
 	local ID = event.pID
 	local commandname = event.Command
 	local player = PlayerResource:GetPlayer(ID)
 	if commandname == "magic_immunity_1" then

 	elseif commandname == "magic_immunity_2" then

 	elseif commandname == "damage_immunity" then

 	elseif commandname == "double_damage" then

 	elseif commandname == "quad_damage" then

 	end
 	
end


-- Read and assign configurable keyvalues if applicable
function CHoldoutGameMode:_ReadGameConfiguration()
	local kv = LoadKeyValues( "scripts/maps/" .. GetMapName() .. ".txt" )
	kv = kv or {} -- Handle the case where there is not keyvalues file
	
	self._threat = LoadKeyValues( "scripts/kv/threat.kv" )

	self._bAlwaysShowPlayerGold = kv.AlwaysShowPlayerGold or false
	self._bRestoreHPAfterRound = kv.RestoreHPAfterRound or false
	self._bRestoreMPAfterRound = kv.RestoreMPAfterRound or false
	self._bRewardForTowersStanding = kv.RewardForTowersStanding or false
	self._bUseReactiveDifficulty = kv.UseReactiveDifficulty or false

	self._flPrepTimeBetweenRounds = tonumber( kv.PrepTimeBetweenRounds or 0 )
	self._flItemExpireTime = tonumber( kv.ItemExpireTime or 10.0 )

	self:_ReadRandomSpawnsConfiguration( kv["RandomSpawns"] )
	self:_ReadLootItemDropsConfiguration( kv["ItemDrops"] )
	self:_ReadRoundConfigurations( kv )
end

-- Verify spawners if random is set
function CHoldoutGameMode:OnConnectFull()
	SendToServerConsole("dota_combine_models 0")
    SendToConsole("dota_combine_models 0") 
    SendToServerConsole("dota_health_per_vertical_marker 1000")
end

function CHoldoutGameMode:ChooseRandomSpawnInfo()
	if #self._vRandomSpawnsList == 0 then
		error( "Attempt to choose a random spawn, but no random spawns are specified in the data." )
		return nil
	end
	return self._vRandomSpawnsList[ RandomInt( 1, #self._vRandomSpawnsList ) ]
end

-- Verify valid spawns are defined and build a table with them from the keyvalues file
function CHoldoutGameMode:_ReadRandomSpawnsConfiguration( kvSpawns )
	self._vRandomSpawnsList = {}
	if type( kvSpawns ) ~= "table" then
		return
	end
	for _,sp in pairs( kvSpawns ) do			-- Note "_" used as a shortcut to create a temporary throwaway variable
		table.insert( self._vRandomSpawnsList, {
			szSpawnerName = sp.SpawnerName or "",
			szFirstWaypoint = sp.Waypoint or ""
		} )
	end
end


-- If random drops are defined read in that data
function CHoldoutGameMode:_ReadLootItemDropsConfiguration( kvLootDrops )
	self._vLootItemDropsList = {}
	if type( kvLootDrops ) ~= "table" then
		return
	end
	for _,lootItem in pairs( kvLootDrops ) do
		table.insert( self._vLootItemDropsList, {
			szItemName = lootItem.Item or "",
			nChance = tonumber( lootItem.Chance or 0 )
		})
	end
end


-- Set number of rounds without requiring index in text file
function CHoldoutGameMode:_ReadRoundConfigurations( kv )
	self._vRounds = {}
	while true do
		local szRoundName = string.format("Round%d", #self._vRounds + 1 )
		local kvRoundData = kv[ szRoundName ]
		if kvRoundData == nil then
			return
		end
		local roundObj = CHoldoutGameRound()
		roundObj:ReadConfiguration( kvRoundData, self, #self._vRounds + 1 )
		table.insert( self._vRounds, roundObj )
	end
end

function CHoldoutGameMode:OnPlayerReconnected(keys) 
	if self._NewGamePlus == true then
		local player = EntIndexToHScript(keys.player)
		CustomGameEventManager:Send_ServerToPlayer(player,"Display_Shop", {})
	end
end

function CHoldoutGameMode:OnPlayerDisconnected(keys) 
	local playerID = keys.playerID
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	if hero then hero.disconnect = GameRules:GetGameTime() end
end

-- When game state changes set state in script
function CHoldoutGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		if GetMapName() ~= "epic_boss_fight_challenger" then
			ShowGenericPopup( "#holdout_instructions_title", "#holdout_instructions_body", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
		else
			ShowGenericPopup( "#holdout_instructions_title_challenger", "#holdout_instructions_body_challenger", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
		end
	elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			local player = PlayerResource:GetPlayer(nPlayerID)
			if player ~= nil then
				--print ("play music")
				Timers:CreateTimer(0.1,function()
								if player.NoMusic ~= true then
								    player:SetMusicStatus(0, 0)
									EmitSoundOnClient("music.music",player)
									return 480
								end
							end)
				self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
			end
		end
	end
end

function CHoldoutGameMode:DegradeThreat()
	if not GameRules:IsGamePaused() then
		local heroes = Entities:FindAllByName("npc_dota_hero*")
		local holdaggro = { ["item_asura_plate"] = true, 
							["item_bahamut_chest"] = true, 
							["item_divine_armor"] = true, 
							["item_titan_armor"] = true, 
							["item_assault"] = true,
							["item_blade_mail"] = true,
							["item_blade_mail2"] = true,
							["item_blade_mail3"] = true,
							["item_blade_mail4"] = true}
		local currTime = GameRules:GetGameTime()
		decayDelay = 2
		for _,hero in pairs(heroes) do
			for i=0, 5, 1 do
				local current_item = hero:GetItemInSlot(i)
				if current_item ~= nil and holdaggro[ current_item:GetName() ] then
					decayDelay = 5
				end
			end
			if hero.threat then
				if not hero:IsAlive() then
					hero.threat = 0
				end
				if hero.threat < 0 then hero.threat = 0 end
			else hero.threat = 0 end
			if hero.lastHit then
				if hero.lastHit + decayDelay <= currTime and hero.threat > 0 then
					hero.threat = hero.threat - (hero.threat/10)
				end
			else hero.lastHit = currTime end
			PlayerResource:SortThreat()
			local event_data =
			{
				threat = hero.threat,
				lastHit = hero.lastHit,
				aggro = hero.aggro or 0
			}
			local player = hero:GetPlayerOwner()
			CustomGameEventManager:Send_ServerToPlayer( player, "Update_threat", event_data )
		end
	end
end

function CHoldoutGameMode:_regenlifecheck()
	if self._regenround25 == false and self._nRoundNumber >= 26 then
		self._regenround25 = true
		local messageinfo = {
		message = "One life has been gained , you just hit a checkpoint !",
		duration = 5
		}
		SendToServerConsole("dota_health_per_vertical_marker 100000")
		FireGameEvent("show_center_message",messageinfo)   
		self._checkpoint = 26
		Life._MaxLife = Life._MaxLife + 1
		Life._life = Life._life + 1
		GameRules._live = Life._life
		Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
   		Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
		-- value on the bar
		LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
		LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
	end
	if self._regenround13 == false and self._nRoundNumber >= 14 then
		self._regenround13 = true
		local messageinfo = {
		message = "One life has been gained , you just hit a checkpoint !",
		duration = 5
		}
		SendToConsole("dota_combine_models 0")
		SendToServerConsole("dota_health_per_vertical_marker 10000")
		FireGameEvent("show_center_message",messageinfo)   
		self._checkpoint = 14
		Life._MaxLife = Life._MaxLife + 1
		Life._life = Life._life + 1
		GameRules._live = Life._life
		Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
   		Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
		-- value on the bar
		LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
		LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
	end
	if self._regenNG == false and self._NewGamePlus == true then
		self._regenNG = true
		
		local messageinfo = {
		message = "Five life has been gained , Welcome to NewGame + .Mouahahaha !",
		duration = 5
		}
		SendToConsole("dota_combine_models 0")
		SendToServerConsole("dota_health_per_vertical_marker 100000")
		FireGameEvent("show_center_message",messageinfo)   
		self._checkpoint = 1
		if GetMapName() ~= "epic_boss_fight_challenger" then
			Life._MaxLife = Life._MaxLife + 5
			Life._life = Life._life + 5
		else
			Life._MaxLife = Life._MaxLife + 1
			Life._life = Life._life + 1
		end
		GameRules._live = Life._life
		Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
   		Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
		-- value on the bar
		LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
		LifeBar:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, Life._MaxLife )
	end
end

function CHoldoutGameMode:_Start_Vote()
	CustomGameEventManager:Send_ServerToAllClients("Display_Vote", {})
	local time = 0
	Timers:CreateTimer(1,function()
		time = time + 1
		CustomGameEventManager:Send_ServerToAllClients("refresh_time", {time = 60-time})
		if time >= 60 or (GameRules.vote_Yes + GameRules.vote_No) == PlayerResource:GetTeamPlayerCount() then
			CustomGameEventManager:Send_ServerToAllClients("Close_Vote", {})
			if GameRules.vote_Yes >= GameRules.vote_No then
				self:_EnterNG()
				self._nRoundNumber = 1
				self._flPrepTimeEnd = GameRules:GetGameTime() + 70-time
			else
				SendToConsole("dota_health_per_vertical_marker 250")
				GameRules:SetCustomVictoryMessage ("Congratulations!")
				GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
				GameRules._finish = true
			end
		else
			return 1
		end
	end)
end

function CHoldoutGameMode:spawn_unit( place , unitname , radius , unit_number)
    if radius == nil then radius = 400 end
    if core == nil then core = false end
    if unit_number == nil then unit_number = 1 end
    for i = 0, unit_number-1 do
        --print   ("spawn unit : "..unitname)
        PrecacheUnitByNameAsync( unitname, function() 
        local unit = CreateUnitByName( unitname ,place + RandomVector(RandomInt(radius,radius)), true, nil, nil, DOTA_TEAM_BADGUYS ) 
            Timers:CreateTimer(0.03,function()
            end)
        end,
        nil)
    end
end

if simple_item == nil then
    print ( '[simple_item] creating simple_item' )
    simple_item = {} -- Creates an array to let us beable to index simple_item when creating new functions
    simple_item.__index = simple_item
    simple_item.midas_gold_on_round = 0
    simple_item._round = 1
end

function simple_item:start() -- Runs whenever the simple_item.lua is ran
    print('[simple_item] simple_item started!')
end

function simple_item:midas_gold(bonus) -- Runs whenever the simple_item.lua is ran
    if simple_item._totalgold == nil then 
        simple_item._totalgold = 0 
    end
    simple_item._totalgold = simple_item._totalgold + bonus
    CustomNetTables:SetTableValue( "midas","total", {gold = simple_item._totalgold } )

end

function CHoldoutGameMode:CheckHP()
	local dontdelete = {["npc_dota_lone_druid_bear"] = true}
	for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
		if unit:GetHealth() == 0 and not unit:IsRealHero() and not dontdelete[unit:GetClassname()] and not unit:IsNull() then
			unit:SetHealth(2)
			unit:ForceKill(true)
			Timers:CreateTimer(10,function()
				if not unit:IsNull() then
					unit:RemoveSelf()
				end
				if not unit:IsNull() then
					UTIL_Remove(unit)
				end
			end)
		end
	end
end


function CHoldoutGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:_CheckForDefeat()
		self:_ThinkLootExpiry()
		self:_regenlifecheck()
		self:CheckHP()
		self:DegradeThreat()
		if self._flPrepTimeEnd ~= nil then
			self:_ThinkPrepTime()
		elseif self._currentRound ~= nil then
			self._currentRound:Think()
			if self._currentRound:IsFinished() then 
				self._currentRound:End()
				self._currentRound = nil
				-- Heal all players
				self:_RefreshPlayers()
				local midascounter1 = 0
				local midascounter2 = 0
				local midascounter3 = 0
				if self.boss_master_id ~= -1 then
					local boss_master = PlayerResource:GetSelectedHeroEntity(self.boss_master_id)
					boss_master:HeroLevelUp(true)
				end
				for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
					if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and unit:HasModifier("passive_midas_4") and unit:IsRealHero() and not unit:HasOwnerAbandoned() then
						midascounter1 = midascounter1+1
					elseif unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and unit:HasModifier("passive_midas_3") and unit:IsRealHero() and not unit:HasOwnerAbandoned() then
						midascounter2 = midascounter2+1
					elseif unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and unit:HasModifier("passive_midas_2") and unit:IsRealHero() and not unit:HasOwnerAbandoned() then
						midascounter3 = midascounter3+1
					end
					
				end
				local ngmodifier = 0
				if self._NewGamePlus then ngmodifier = math.floor(37/2) end
				local midas_gold = math.floor((self._nRoundNumber + ngmodifier)*(30*(midascounter3/PlayerResource:GetTeamPlayerCount()) + 45*(midascounter2/PlayerResource:GetTeamPlayerCount()) + 60*(midascounter1/PlayerResource:GetTeamPlayerCount())))
				for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
					if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and not unit:IsIllusion() then
						local midas_modifier = 0
						if unit:HasModifier("passive_midas_4") then
							midas_modifier = self._nRoundNumber*60
						elseif unit:HasModifier("passive_midas_3") then
							midas_modifier = self._nRoundNumber*30
						elseif unit:HasModifier("passive_midas_2") then
							midas_modifier = self._nRoundNumber*15
						elseif unit:HasModifier("passive_midas_1") then
							midas_modifier = self._nRoundNumber*15
						end
						local totalgold = unit:GetGold() + midas_gold + midas_modifier
				        unit:SetGold(0 , false)
				        unit:SetGold(totalgold, true)
					end
				end
				simple_item:midas_gold(midas_gold)
				

				
				self._nRoundNumber = self._nRoundNumber + 1
				boss_meteor:SetRoundNumer(self._nRoundNumber)
				GameRules._roundnumber = self._nRoundNumber
				-- if math.random(1,25) == 25 then
					-- self:spawn_unit( Vector(0,0,0) , "npc_dota_treasure" , 2000)
					-- for _,unit in pairs ( Entities:FindAllByModel( "models/courier/flopjaw/flopjaw.vmdl")) do
						-- Waypoint = Entities:FindByName( nil, "path_invader1_1" )
						-- unit:SetInitialGoalEntity(Waypoint) 
						-- Timers:CreateTimer(15,function()
							-- unit:ForceKill(true)
						-- end)
					-- end
					-- self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds + 15

				-- end 
				if self._nRoundNumber > #self._vRounds then
					if self._NewGamePlus == false then
						self:_Start_Vote()
					else
						SendToConsole("dota_health_per_vertical_marker 250")
						GameRules:SetCustomVictoryMessage ("Congratulations!")
						GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
						GameRules._finish = true
					end
				else
					self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
					
					GameRules.voteRound_No = PlayerResource:GetTeamPlayerCount()
					GameRules.voteRound_Yes = 0
					
					
		
					CustomGameEventManager:Send_ServerToAllClients("Display_RoundVote", {})
					local event_data =
					{
						No = GameRules.voteRound_No,
						Yes = GameRules.voteRound_Yes,
					}
					CustomGameEventManager:Send_ServerToAllClients("RoundVoteResults", event_data)

					Timers:CreateTimer(1,function()
						if GameRules.voteRound_Yes == PlayerResource:GetTeamPlayerCount() then
							CustomGameEventManager:Send_ServerToAllClients("Close_RoundVote", {})
							if self._flPrepTimeEnd~= nil then
								self._flPrepTimeEnd = 0
							end
						else
							return 1
						end
					end)
				end
			end
		end
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
		return nil
	end
	return 0.25
end


function CHoldoutGameMode:_Connection_states()
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		local player_connection_state = PlayerResource:GetConnectionState(nPlayerID)
		local hero = GetAssignedHero(nPlayerID)
		if hero~=nil and player_connection_state == 4 and hero.Abandonned ~= true then 
			hero.Abandonned = true
			for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
				if self._NewGamePlus == false then
					local totalgold = unit:GetGold() + (self._nRoundNumber^1.3)*100
				else
					local totalgold = unit:GetGold() + ((36+self._nRoundNumber)^1.3)*100
				end
				unit:SetGold(0 , false)
				unit:SetGold(totalgold, true)
			end
			for itemSlot = 0, 5, 1 do
	          	local Item = hero:GetItemInSlot( itemSlot )
	           	hero:RemoveItem(Item)
	        end
	        Timers:CreateTimer(0.1,function()
	        	hero:SetGold(0, true)
	        	return 0.5
	        end)
		end
	end
end

function CDOTA_PlayerResource:SortThreat()
	local currThreat = 0
	local secondThreat = 0
	local aggrounit 
	local aggrosecond
	for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
		if not unit.threat then unit.threat = 0 end
		if unit.threat > currThreat then
			currThreat = unit.threat
			aggrounit = unit
		elseif unit.threat > secondThreat and unit.threat < currThreat then
			secondThreat = unit.threat
			aggrosecond = unit
		end
	end
	for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
		if unit == aggrosecond then unit.aggro = 2
		elseif unit == aggrounit then unit.aggro = 1
		else unit.aggro = 0 end
	end
end

function CHoldoutGameMode:_RefreshPlayers()
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero ~=nil then
					if not hero:IsAlive() then
						hero:RespawnHero(false, false, false)
					end
					hero:SetHealth( hero:GetMaxHealth() )
					hero:SetMana( hero:GetMaxMana() )
					hero.threat = 0
				end
			end
		end
	end
end


function CHoldoutGameMode:_CheckForDefeat()
	if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		return
	end
	self._check_dead = false
	local AllRPlayersDead = true
	local PlayerNumberRadiant = 0
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			PlayerNumberRadiant = PlayerNumberRadiant + 1
			if not PlayerResource:HasSelectedHero( nPlayerID ) and self._nRoundNumber == 1 and self._currentRound == nil then
				AllRPlayersDead = false
			elseif PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero and hero:IsAlive() then
					AllRPlayersDead = false
				end
			end
		end
	end


		if AllRPlayersDead and PlayerNumberRadiant>0 then 
			self._check_dead = true
			if self._entPrepTimeQuest then
				self:_RefreshPlayers()
				return
			end
			for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
					if PlayerResource:HasSelectedHero( nPlayerID ) and PlayerResource:GetSelectedHeroEntity( nPlayerID ) ~= nil then
						local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
						for slot = 0,5 do
							if hero:GetItemInSlot(slot) ~= nil and hero:GetItemInSlot(slot):GetName() == "item_ressurection_stone" then
								if  hero:GetItemInSlot(slot):GetCooldownTimeRemaining() >= hero:GetItemInSlot(slot):GetCooldownTime() - 5 then
									self._check_dead = false
								end
							end
						end
						if hero:GetName() == "npc_dota_hero_skeleton_king" then
							local ability = hero:FindAbilityByName("skeleton_king_reincarnation")
							local reincarnation_CD = ability:GetCooldownTimeRemaining()
							local reincarnation_level = ability:GetLevel()
							local reincarnation_CD_total = ability:GetCooldown(reincarnation_level-1)
							reincarnation_CD = ability:GetCooldownTimeRemaining()
							reincarnation_level = ability:GetLevel()
							reincarnation_CD_total = ability:GetCooldown(reincarnation_level-1)
							reincarnation_CD_total = reincarnation_CD_total * get_octarine_multiplier(hero)
							if reincarnation_level >= 1 and reincarnation_CD >= reincarnation_CD_total - 5 then
								self._check_dead = false
							end
						end
					end
				end
			end
			Timers:CreateTimer(3,function()
				for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
					if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
						if not PlayerResource:HasSelectedHero( nPlayerID ) and self._nRoundNumber == 1 and self._currentRound == nil then
							self._check_dead = false
						elseif PlayerResource:HasSelectedHero( nPlayerID ) then
							local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
							if hero and hero:IsAlive() then
								self._check_dead = false
							end
						end
					end
				end

				if self._check_dead == true and Life._life > 0 then
					if self._currentRound ~= nil then
						self._currentRound:End()
						self._currentRound = nil
					end
					self._flPrepTimeEnd = GameRules:GetGameTime() + 20
					Life._life = Life._life - 1
					GameRules._live = Life._life
					GameRules._used_live = GameRules._used_live + 1 
					Life:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
		   			LifeBar:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Life._life )
					self._check_dead = false
					for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
						if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
							unit:ForceKill(true)
						end
					end
					for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
						if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and not unit:IsIllusion() then
							local totalgold = unit:GetGold() + ((((self._nRoundNumber/1.5)+5)/((Life._life/2) +0.5))*500)
				            unit:SetGold(0 , false)
				            unit:SetGold(totalgold, true)
			        	end
					end
					if delay ~= nil then
						self._flPrepTimeEnd = GameRules:GetGameTime() + tonumber( delay )
					end
					self:_RefreshPlayers()
				end
			end)
		end
		if PlayerNumberRadiant == 0 or Life._life == 0 then
			self:_OnLose()
		end
end


function CHoldoutGameMode:_OnLose()
	--[[Say(nil,"You just lose all your life , a vote start to chose if you want to continue or not", false)
	if self._checkpoint == 14 then
		Say(nil,"if you continue you will come back to round 13 , you keep all the current item and gold gained", false)
	elif self._checkpoint == 26 then
		Say(nil,"if you continue you will come back to round 25 , you keep all the current item and gold gained", false)
	elseif self._checkpoint == 46 then
		Say(nil,"if you continue you will come back to round 45 , you keep with all the current item and gold gained", false)
	elseif self._checkpoint == 61 then
		Say(nil,"if you continue you will come back to round 60 , you keep with all the current item and gold gained", false)
	elseif self._checkpoint == 76 then
		Say(nil,"if you continue you will come back to round 75 , you keep with all the current item and gold gained", false)
	elseif self._checkpoint == 91 then
		Say(nil,"if you continue you will come back to round 90 , you keep with all the current item and gold gained", false)
	else
		Say(nil,"if you continue you will come back to round begin and have all your money and item erased", false)
	end
	Say(nil,"If you want to retry , type YES in thes chat if you don't want type no , no vote will be taken as a yes", false)
	Say(nil,"At least Half of the player have to vote yes for game to restart on last check points", false)]]
	SendToConsole("dota_health_per_vertical_marker 250")
	GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
end


function CHoldoutGameMode:_ThinkPrepTime()
	if GameRules:GetGameTime() >= self._flPrepTimeEnd then
		CustomGameEventManager:Send_ServerToAllClients("Close_RoundVote", {})
		self._flPrepTimeEnd = nil
		if self._entPrepTimeQuest then
			UTIL_RemoveImmediate( self._entPrepTimeQuest )
			self._entPrepTimeQuest = nil
		end

		if self._nRoundNumber > #self._vRounds then
			GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
			Say(nil,"If you wish you can support me on patron (link in description of the gamemode), anyways, thank for playing <3", false)
			return false
		end
		self._currentRound = self._vRounds[ self._nRoundNumber ]
		self._currentRound:Begin()
		return
	end

	if not self._entPrepTimeQuest then
		self._entPrepTimeQuest = SpawnEntityFromTableSynchronous( "quest", { name = "PrepTime", title = "#DOTA_Quest_Holdout_PrepTime" } )
		self._entPrepTimeQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_ROUND, self._nRoundNumber )
		self._entPrepTimeQuest:SetTextReplaceString( self:GetDifficultyString() )
		self:_RefreshPlayers()
		self._vRounds[ self._nRoundNumber ]:Precache()
	end
	self._entPrepTimeQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self._flPrepTimeEnd - GameRules:GetGameTime() )
end

function CHoldoutGameMode:_ThinkLootExpiry()
	if self._flItemExpireTime <= 0.0 then
		return
	end

	local flCutoffTime = GameRules:GetGameTime() - self._flItemExpireTime

	for _,item in pairs( Entities:FindAllByClassname( "dota_item_drop")) do
		local containedItem = item:GetContainedItem()
		if containedItem:GetAbilityName() == "item_bag_of_gold" or item.Holdout_IsLootDrop then
			self:_ProcessItemForLootExpiry( item, flCutoffTime )
		end
	end
end


function CHoldoutGameMode:_ProcessItemForLootExpiry( item, flCutoffTime )
	if item:IsNull() then
		return false
	end
	if item:GetCreationTime() >= flCutoffTime then
		return true
	end

	local containedItem = item:GetContainedItem()
	if containedItem and containedItem:GetAbilityName() == "item_bag_of_gold" then
		if self._currentRound and self._currentRound.OnGoldBagExpired then
			self._currentRound:OnGoldBagExpired()
		end
	end

	local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, item )
	ParticleManager:SetParticleControl( nFXIndex, 0, item:GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	local inventoryItem = item:GetContainedItem()
	if inventoryItem then
		UTIL_RemoveImmediate( inventoryItem )
	end
	UTIL_RemoveImmediate( item )
	return false
end


function CHoldoutGameMode:GetDifficultyString()
	local nDifficulty = PlayerResource:GetTeamPlayerCount()
	if nDifficulty > 10 then
		return string.format( "(+%d)", nDifficulty )
	elseif nDifficulty > 0 then
		return string.rep( "+", nDifficulty )
	else
		return ""
	end
end

LinkLuaModifier( "modifier_boss_attackspeed", "lua_abilities/heroes/modifiers/modifier_boss_attackspeed.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_damagedecrease", "lua_abilities/heroes/modifiers/modifier_boss_damagedecrease.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_attack_animation_tweak", "lua_abilities/heroes/modifiers/modifier_attack_animation_tweak.lua" ,LUA_MODIFIER_MOTION_NONE )


function CHoldoutGameMode:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if not spawnedUnit or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:IsPhantom() or spawnedUnit:IsIllusion() then
		return
	end

	-- Attach client side hero effects on spawning players
	if spawnedUnit:GetUnitName() == "npc_dota_furion_treant" then
		local scaleAb = spawnedUnit:AddAbility("neutral_power_passive")
		scaleAb:SetLevel(scaleAb:GetMaxLevel())
	end
	if string.match(spawnedUnit:GetUnitName(), "npc_dota_venomancer_plague_ward") then
		local scaleAb = spawnedUnit:AddAbility("neutral_power_passive")
		scaleAb:SetLevel(scaleAb:GetMaxLevel())
	end
	if spawnedUnit:IsRealHero() then
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_attack_animation_tweak", {})
	end
	if spawnedUnit:IsCreature() then
		local difficulty_multiplier = (PlayerResource:GetTeamPlayerCount() / 7)^0.2
		spawnedUnit:SetMaxHealth (difficulty_multiplier*spawnedUnit:GetMaxHealth())
		spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
		spawnedUnit:SetBaseDamageMin(difficulty_multiplier*spawnedUnit:GetBaseDamageMin())
		spawnedUnit:SetBaseDamageMax(difficulty_multiplier*spawnedUnit:GetBaseDamageMax())
		spawnedUnit:SetPhysicalArmorBaseValue(difficulty_multiplier*spawnedUnit:GetPhysicalArmorBaseValue())
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_boss_attackspeed", {})
		if GetMapName() == "epic_boss_fight_boss_master" then
			spawnedUnit:SetOwner(PlayerResource:GetSelectedHeroEntity(self.boss_master_id))
			spawnedUnit:SetControllableByPlayer(self.boss_master_id,true)
			spawnedUnit.boss_master = self.boss_master_id
		end
		if spawnedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
			Timers:CreateTimer(0.03,function()
				if spawnedUnit:GetUnitName() ~= "npc_dota_boss36" then
					if self._NewGamePlus == true and spawnedUnit.Holdout_IsCore and spawnedUnit:GetUnitName() ~= "npc_dota_money" then
						local Number_Round = self._nRoundNumber
						spawnedUnit:SetMaxHealth((1250000+spawnedUnit:GetMaxHealth())* Number_Round^0.1 )
						spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
						local modifiermin = 5000000
						local modifiermax = 7500000
						if spawnedUnit:GetUnitName() == "npc_dota_boss39" then
							modifiermin = -50000
							modifiermax = -50000
						end
						spawnedUnit:SetBaseDamageMin((spawnedUnit:GetBaseDamageMin()+modifiermin)*((Number_Round/2)^0.8) )
						spawnedUnit:SetBaseDamageMax((spawnedUnit:GetBaseDamageMax()+modifiermax)*((Number_Round/2)^0.9) )
						spawnedUnit:SetPhysicalArmorBaseValue(spawnedUnit:GetPhysicalArmorBaseValue() + (750*(Number_Round^1.5) ) )
						if spawnedUnit:GetBaseMagicalResistanceValue() < 99 then
							if not string.find(spawnedUnit:GetUnitName(), "npc_dota_boss33_a") then
								spawnedUnit:SetBaseMagicalResistanceValue(50 + spawnedUnit:GetBaseMagicalResistanceValue()/2)
							end
						end
						spawnedUnit:AddAbility("new_game_damage_increase")
						spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_boss_damagedecrease", {})
					elseif self._NewGamePlus == true and not spawnedUnit.Holdout_IsCore then
						local Number_Round = self._nRoundNumber
						spawnedUnit:SetMaxHealth((650000+spawnedUnit:GetMaxHealth())* Number_Round^0.1 )
						spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
						spawnedUnit:SetBaseDamageMin((spawnedUnit:GetBaseDamageMin()+500000)*(Number_Round^0.5 ) )
						spawnedUnit:SetBaseDamageMax((spawnedUnit:GetBaseDamageMax()+600000)*(Number_Round^0.6 ) )
						spawnedUnit:SetPhysicalArmorBaseValue(spawnedUnit:GetPhysicalArmorBaseValue() + (600*(Number_Round)^1.2 ) )
						if spawnedUnit:GetBaseMagicalResistanceValue() < 99 then
							if not string.find(spawnedUnit:GetUnitName(), "npc_dota_boss33_a") then
								spawnedUnit:SetBaseMagicalResistanceValue(30 + spawnedUnit:GetBaseMagicalResistanceValue()/1.45)
							end
						end
						spawnedUnit:AddAbility("new_game_damage_increase")
						spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_boss_damagedecrease", {})
					end
				end
			end)
		end
	end
end

function CHoldoutGameMode:OnEntityKilled( event )
	local check_tombstone = true
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	if killedUnit:GetUnitName() == "npc_dota_treasure" then
		local count = -1
		Timers:CreateTimer(0.5,function()
			if count <= GameRules:GetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS) then
				count = count + 1
				local Item_spawn = CreateItem( "item_present_treasure", nil, nil )
				local drop = CreateItemOnPositionForLaunch( killedUnit:GetAbsOrigin(), Item_spawn )
				Item_spawn:LaunchLoot( false, 300, 0.75, killedUnit:GetAbsOrigin() + RandomVector( RandomFloat( 50, 350 ) ) )
				return 0.25
			end
		end)
	end

	if killedUnit.Asura_To_Give ~= nil then
		for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
			if not unit:IsIllusion() then
				unit.Asura_Core = unit.Asura_Core + killedUnit.Asura_To_Give
				update_asura_core(unit)
			end
		end
		Notifications:TopToAll({text="You have received an Asura Core", duration=3.0})
	end
	if killedUnit and killedUnit:IsRealHero() then
		for itemSlot = 0, 5, 1 do
	        local Item = killedUnit:GetItemInSlot( itemSlot )
	        if Item ~= nil and Item:GetName() == "item_ressurection_stone" and Item:IsCooldownReady() then
	            	self._check_check_dead = true
	            	check_tombstone = false
	            	self._check_dead = false
	            	if Life._life == 1 then
	            		AllRPlayersDead = false
	            	end
	        end
	    end
	    if killedUnit:GetName() == ( "npc_dota_hero_skeleton_king") then
			local ability = killedUnit:FindAbilityByName("skeleton_king_reincarnation")
			local reincarnation_CD = 0
			local reincarnation_CD_total = 0
			local reincarnation_level = 0
			reincarnation_CD = ability:GetCooldownTimeRemaining()
			reincarnation_level = ability:GetLevel()
			reincarnation_CD_total = ability:GetCooldown(reincarnation_level-1)
			reincarnation_CD_total = reincarnation_CD_total * get_octarine_multiplier(killedUnit)
			--print (reincarnation_CD)
			--print (reincarnation_CD_total)
			if reincarnation_level >= 1 and reincarnation_CD >= reincarnation_CD_total - 5 then
				check_tombstone = false
				if reincarnation_level < 6 then
					Timers:CreateTimer(2,function()
						killedUnit:RespawnHero(false, false, false)
						killedUnit:SetHealth( killedUnit:GetMaxHealth() )
						killedUnit:SetMana( killedUnit:GetMaxMana() )
					end)
				end
				if reincarnation_level >= 6 then
					for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
						if unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
							Timers:CreateTimer(1.5,function()
								if not unit:IsAlive() then 
									unit:RespawnHero(false, false, false)
								end
								unit:SetHealth( unit:GetMaxHealth() )
								unit:SetMana( unit:GetMaxMana() )
							end)
						end
					end
				end
			end
		end	
		if GetMapName() ~= "epic_boss_fight_challenger" then
			if check_tombstone == true and killedUnit.NoTombStone ~= true then
				local newItem = CreateItem( "item_tombstone", killedUnit, killedUnit )
				newItem:SetPurchaseTime( 0 )
				newItem:SetPurchaser( killedUnit )
				local tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} )
				tombstone:SetContainedItem( newItem )
				tombstone:SetAngles( 0, RandomFloat( 0, 360 ), 0 )
				FindClearSpaceForUnit( tombstone, killedUnit:GetAbsOrigin(), true )	
			end
		end
	end
end

function CHoldoutGameMode:CheckForLootItemDrop( killedUnit )
	for _,itemDropInfo in pairs( self._vLootItemDropsList ) do
		if RollPercentage( itemDropInfo.nChance ) then
			local newItem = CreateItem( itemDropInfo.szItemName, nil, nil )
			newItem:SetPurchaseTime( 0 )
			local drop = CreateItemOnPositionSync( killedUnit:GetAbsOrigin(), newItem )
			drop.Holdout_IsLootDrop = true
		end
	end
end


-- Custom game specific console command "holdout_test_round"
function CHoldoutGameMode:_TestRoundConsoleCommand( cmdName, roundNumber, delay, NG)
	local nRoundToTest = tonumber( roundNumber )
	--print( "Testing round %d", nRoundToTest )
	if nRoundToTest <= 0 or nRoundToTest > #self._vRounds then
		print( "Cannot test invalid round %d", nRoundToTest )
		return
	end
	GameRules._roundnumber = nRoundToTest
	--print (NG)
	if NG then
		self:_EnterNG()
	end

	local nExpectedGold = 0
	local nExpectedXP = 0
	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
		if PlayerResource:IsValidPlayer( nPlayerID ) then
			PlayerResource:SetBuybackCooldownTime( nPlayerID, 0 )
			PlayerResource:SetBuybackGoldLimitTime( nPlayerID, 0 )
			PlayerResource:ResetBuybackCostTime( nPlayerID )
		end
	end

	if self._entPrepTimeQuest then
		UTIL_RemoveImmediate( self._entPrepTimeQuest )
		self._entPrepTimeQuest = nil
	end

	if self._currentRound ~= nil then
		self._currentRound:End()
		self._currentRound = nil
	end

	for _,item in pairs( Entities:FindAllByClassname( "dota_item_drop")) do
		local containedItem = item:GetContainedItem()
		if containedItem then
			UTIL_RemoveImmediate( containedItem )
		end
		UTIL_RemoveImmediate( item )
	end

	self._flPrepTimeEnd = GameRules:GetGameTime() + 5
	self._nRoundNumber = nRoundToTest
	--print(self._nRoundNumber)
	if delay ~= nil then
		self._flPrepTimeEnd = GameRules:GetGameTime() + tonumber( delay )
	end
end

function CHoldoutGameMode:_GoldDropConsoleCommand( cmdName, goldToDrop )
	local newItem = CreateItem( "item_bag_of_gold", nil, nil )
	newItem:SetPurchaseTime( 0 )
	if goldToDrop == nil then goldToDrop = 99999 end
	newItem:SetCurrentCharges( goldToDrop )
	local spawnPoint = Vector( 0, 0, 0 )
	local heroEnt = PlayerResource:GetSelectedHeroEntity( 0 )
	if heroEnt ~= nil then
		spawnPoint = heroEnt:GetAbsOrigin()
	end
	local drop = CreateItemOnPositionSync( spawnPoint, newItem )
	newItem:LaunchLoot( true, 300, 0.75, spawnPoint + RandomVector( RandomFloat( 50, 350 ) ) )
end

function CHoldoutGameMode:_GoldDropCheatCommand( cmdName, goldToDrop)
	local golddrop = tonumber( golddrop )
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
			if PlayerResource:GetSteamAccountID( nPlayerID ) == 42452574 or PlayerResource:GetSteamAccountID( ID ) == 36111451 then
				print ("Cheat gold activate")
				local newItem = CreateItem( "item_bag_of_gold", nil, nil )
				newItem:SetPurchaseTime( 0 )
				if goldToDrop == nil then goldToDrop = 99999 end
				newItem:SetCurrentCharges( goldToDrop )
				local spawnPoint = Vector( 0, 0, 0 )
				local heroEnt = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if heroEnt ~= nil then
					spawnPoint = heroEnt:GetAbsOrigin()
				end
				local drop = CreateItemOnPositionSync( spawnPoint, newItem )
				newItem:LaunchLoot( true, 300, 0.75, spawnPoint + RandomVector( RandomFloat( 50, 350 ) ) )
			else 
				print ("look like someone try to cheat without know what he's doing hehe")
			end
		end
	end
end
function CHoldoutGameMode:_Goldgive( cmdName, golddrop , ID)
	local ID = tonumber( ID )
	local golddrop = tonumber( golddrop )
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
			if PlayerResource:GetSteamAccountID( nPlayerID ) == 42452574 or PlayerResource:GetSteamAccountID( nPlayerID ) == 36111451 then
				if ID == nil then ID = nPlayerID end
				if golddrop == nil then golddrop = 99999 end
				PlayerResource:GetSelectedHeroEntity(ID):SetGold(golddrop, true)
			else 
				print ("look like someone try to cheat without know what he's doing hehe")
			end
		end
	end
end


	

function CHoldoutGameMode:_LevelGive( cmdName, golddrop , ID)
	local ID = tonumber( ID )
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
			if PlayerResource:GetSteamAccountID( nPlayerID ) == 42452574 or PlayerResource:GetSteamAccountID( ID ) == 36111451 then
				if ID == nil then ID = nPlayerID end
				if golddrop == nil then golddrop = 99999 end
				local hero = PlayerResource:GetSelectedHeroEntity(ID)
				for i=0,74,1 do
					hero:HeroLevelUp(false)
				end
				hero:SetAbilityPoints(0) 
				for i=0,15,1 do
					local ability = hero:GetAbilityByIndex(i)
					if ability ~= nil then
						ability:SetLevel(ability:GetMaxLevel() )
					end
				end
			else 
				print ("look like someone try to cheat without know what he's doing hehe")
			end
		end
	end
end
function CHoldoutGameMode:_ItemDrop(item_name)
	if item_name ~= nil then
		for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
				if PlayerResource:GetSteamAccountID( nPlayerID ) == 42452574 or PlayerResource:GetSteamAccountID( nPlayerID ) == 36111451 then
					--print ("master had dropped an item")
					local newItem = CreateItem( item_name, nil, nil )
					if newItem == nil then newItem = "item_heart_divine" end
					local spawnPoint = Vector( 0, 0, 0 )
					local heroEnt = PlayerResource:GetSelectedHeroEntity( nPlayerID )
					if heroEnt ~= nil then
						heroEnt:AddItemByName(item_name)
					else
						local drop = CreateItemOnPositionSync( spawnPoint, newItem )
						newItem:LaunchLoot( true, 300, 0.75, spawnPoint + RandomVector( RandomFloat( 50, 350 ) ) )
					end
				else 
					print ("look like someone try to cheat without know what he's doing hehe")
				end
			end
		end
	end
end

function CHoldoutGameMode:_GiveCore(amount)
	if amount ~= nil then
		for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS and PlayerResource:IsValidPlayerID( nPlayerID ) then
				if PlayerResource:GetSteamAccountID( nPlayerID ) == 42452574 or PlayerResource:GetSteamAccountID( nPlayerID ) == 36111451 then
					local heroEnt = PlayerResource:GetSelectedHeroEntity( nPlayerID )
					if heroEnt ~= nil then
						heroEnt.Asura_Core = heroEnt.Asura_Core + amount
						update_asura_core(heroEnt)
					end
				end
			end
		end
	end
end

function CHoldoutGameMode:_CheckLivingEnt(amount)
	for k,v in pairs(Entities:FindAllByName( "npc_*")) do
		if v:IsAlive() then
			print(k,v:GetUnitName(), "living")
		end
	end	
end

function CHoldoutGameMode:_fixgame(item_name)
	if item_name ~= nil then
		for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
				if PlayerResource:GetSteamAccountID( nPlayerID ) == 42452574 and PlayerResource:IsValidPlayerID( nPlayerID ) then
					--print ("master is not happy , someone is a stealer :D")
					for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
						for itemSlot = 0, 5, 1 do
		            		local Item = unit:GetItemInSlot( itemSlot )
		            		unit:RemoveItem(Item)
		            	end
		            end
					--print ("Master frenchDeath has ruined the game , now he gonna leave :D, FUCK YOU MOD STEALER !")
				else 
					print ("you don't have acces to this kid")
				end
			end
		end
	end
end


function CHoldoutGameMode:_StatusReportConsoleCommand( cmdName )
	print( "*** Holdout Status Report ***" )
	print( string.format( "Current Round: %d", self._nRoundNumber ) )
	if self._currentRound then
		self._currentRound:StatusReport()
	end
	print( "*** Holdout Status Report End *** ")
end