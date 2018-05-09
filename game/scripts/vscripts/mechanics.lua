-- Contains general mechanics used extensively thourought different scripts

function SendErrorMessage( pID, string )
	Notifications:ClearBottom(pID)
	Notifications:Bottom(pID, {text=string, style={color='#E62020'}, duration=2})
	EmitSoundOnClient("General.Cancel", PlayerResource:GetPlayer(pID))
end

function SendTradeGoldMessage( pID, string )
	Notifications:ClearTop(pID)
	Notifications:Top(pID, {text=string, style={color='gold'}, duration=2})
	EmitSoundOnClient("General.Sell", PlayerResource:GetPlayer(pID))
end
function SendTradeLumberMessage( pID, string )
	Notifications:ClearTop(pID)
	Notifications:Top(pID, {text=string, style={color='green'}, duration=2})
	EmitSoundOnClient("General.Sell", PlayerResource:GetPlayer(pID))
end

function ReceiveTradeGoldMessage( pID, string )
	Notifications:ClearTop(pID)
	Notifications:Top(pID, {text=string, style={color='gold'}, duration=2})
	EmitSoundOnClient("General.Coins", PlayerResource:GetPlayer(pID))
end
function ReceiveTradeLumberMessage( pID, string )
	Notifications:ClearTop(pID)
	Notifications:Top(pID, {text=string, style={color='green'}, duration=2})
	EmitSoundOnClient("Gift_Received_Stinger", PlayerResource:GetPlayer(pID))
end
-- Modifies the lumber of this player. Accepts negative values
function ModifyLumber( player, lumber_value )
	if lumber_value == 0 then return end
	if lumber_value > 0 then
		if player.lumber + lumber_value > 1000000 then
			player.lumber = 1000000
			CustomGameEventManager:Send_ServerToPlayer(player, "player_lumber_changed", { lumber = math.floor(player.lumber) })
			return 
		end
		player.lumber = player.lumber + lumber_value
	    CustomGameEventManager:Send_ServerToPlayer(player, "player_lumber_changed", { lumber = math.floor(player.lumber) })
	else
		if PlayerHasEnoughLumber( player, math.abs(lumber_value) ) then
			player.lumber = player.lumber + lumber_value
		    CustomGameEventManager:Send_ServerToPlayer(player, "player_lumber_changed", { lumber = math.floor(player.lumber) })
		end
	end
end

function ModifyFood( player, food_value )
	if food_value == 0 then return end
	if food_value > 0 then
		if player.food+food_value<=250 then
		player.food = player.food + food_value
	    CustomGameEventManager:Send_ServerToPlayer(player, "player_food_changed", { food = math.floor(player.food) })
		else
			player.food = 250
	    CustomGameEventManager:Send_ServerToPlayer(player, "player_food_changed", { food = math.floor(player.food) })
		end
	else
		--if PlayerHasEnoughFood( player, math.abs(food_value) ) then
			player.food = player.food + food_value
		    CustomGameEventManager:Send_ServerToPlayer(player, "player_food_changed", { food = math.floor(player.food) })
		--end
	end
end

function ModifyMaxFood( player, maxfood_value )

	if maxfood_value == 0 then return end
	if maxfood_value > 0 then
		if player.maxfood+maxfood_value<=250 then
		player.maxfood = player.maxfood + maxfood_value
	    CustomGameEventManager:Send_ServerToPlayer(player, "player_maxfood_changed", { maxfood = math.floor(player.maxfood) })
		else
			player.maxfood = 250
	    CustomGameEventManager:Send_ServerToPlayer(player, "player_maxfood_changed", { maxfood = math.floor(player.maxfood) })
		end
	else
			if player.maxfood + maxfood_value <30 then
				player.maxfood =30
			else
			player.maxfood = player.maxfood +maxfood_value
		    CustomGameEventManager:Send_ServerToPlayer(player, "player_maxfood_changed", { maxfood = math.floor(player.maxfood) })
			end
	end
	
end

function SetMaxFood( player )
	player.maxfood = 0
	CustomGameEventManager:Send_ServerToPlayer(player, "player_maxfood_changed", { maxfood = math.floor(player.maxfood) })
end
-- Returns Int
function GetGoldCost( unit )
	if unit and IsValidEntity(unit) then
		if unit.GoldCost then
			return unit.GoldCost
		end
	end
	return 0
end

-- Returns Int
function GetLumberCost( unit )
	if unit and IsValidEntity(unit) then
		if unit.LumberCost then
			return unit.LumberCost
		end
	end
	return 0
end

-- Returns float
function GetBuildTime( unit )
	if unit and IsValidEntity(unit) then
		if unit.BuildTime then
			return unit.BuildTime
		end
	end
	return 0
end

function GetCollisionSize( unit )
	if unit and IsValidEntity(unit) then
		if GameRules.UnitKV[unit:GetUnitName()]["CollisionSize"] and GameRules.UnitKV[unit:GetUnitName()]["CollisionSize"] then
			return GameRules.UnitKV[unit:GetUnitName()]["CollisionSize"]
		end
	end
	return 0
end



-- Returns bool
function PlayerHasEnoughGold( player, gold_cost )
	local hero = player:GetAssignedHero()
	local pID = hero:GetPlayerID()
	local gold = hero:GetGold()

	if gold < gold_cost then
		SendErrorMessage(pID, "#error_not_enough_gold")
		return false
	else
		return true
	end
end

-- Returns bool
function PlayerHasEnoughLumber( player, lumber_cost )
	local pID = player:GetAssignedHero():GetPlayerID()

	if player.lumber < lumber_cost then
		SendErrorMessage(pID, "#error_not_enough_lumber")
		return false
	else
		return true
	end
end

-- Returns bool
function PlayerHasEnoughFood( player, food_cost )
	local pID = player:GetAssignedHero():GetPlayerID()
	
	if player.maxfood < player.food+food_cost then
		SendErrorMessage(pID, "#error_not_enough_food")
		return false
	else
		return true
	end
end

-- Returns bool
function PlayerHasResearch( player, research_name )
	if player.upgrades[research_name] then
		return true
	else
		return false
	end
end

-- Returns bool
function PlayerHasRequirementForAbility( player, ability_name )
	local requirements = GameRules.Requirements
	local buildings = player.buildings
	local upgrades = player.upgrades
	local requirement_failed = false

	if requirements[ability_name] then

		-- Go through each requirement line and check if the player has that building on its list
		for k,v in pairs(requirements[ability_name]) do

			-- If it's an ability tied to a research, check the upgrades table
			if requirements[ability_name].research then
				if k ~= "research" and (not upgrades[k] or upgrades[k] == 0) then
					--print("Failed the research requirements for "..ability_name..", no "..k.." found")
					return false
				end
			else
				--print("Building Name","Need","Have")
				--print(k,v,buildings[k])

				-- If its a building, check every building requirement
				if not buildings[k] or buildings[k] == 0 then
					--print("Failed one of the requirements for "..ability_name..", no "..k.." found")
					return false
				end
			end
		end
	end

	return true
end

-- Builders require the "builder" label in its unit definition
function IsBuilder( unit )
	if not IsValidEntity(unit) then
		return
	end
	return (unit:GetUnitLabel() == "builder")
end

-- A BuildingHelper ability is identified by the "Building" key.
function IsBuildingAbility( ability )
	if not IsValidEntity(ability) then
		return
	end

	local ability_name = ability:GetAbilityName()
	local ability_table = GameRules.AbilityKV[ability_name]
	if ability_table and ability_table["Building"] then
		return true
	else
		ability_table = GameRules.ItemKV[ability_name]
		if ability_table and ability_table["Building"] then
			return true
		end
	end

	return false
end

function IsCustomBuilding( unit )
    local ability_building = unit:FindAbilityByName("ability_building")
    local ability_tower = unit:FindAbilityByName("ability_tower")
    if ability_building or ability_tower then
        return true
    else
        return false
    end
end

-- Shortcut for a very common check
function IsValidAlive( unit )
	return (IsValidEntity(unit) and unit:IsAlive())
end

function AddUnitToSelection( unit )
	local player = unit:GetPlayerOwner()
	CustomGameEventManager:Send_ServerToPlayer(player, "add_to_selection", { ent_index = unit:GetEntityIndex() })
end

function RemoveUnitFromSelection( unit )
	local player = unit:GetPlayerOwner()
	local ent_index = unit:GetEntityIndex()
	CustomGameEventManager:Send_ServerToPlayer(player, "remove_from_selection", { ent_index = unit:GetEntityIndex() })
end

function GetSelectedEntities( playerID )
	return GameRules.SELECTED_UNITS[playerID]
end

function IsCurrentlySelected( unit )
	local entIndex = unit:GetEntityIndex()
	local playerID = unit:GetPlayerOwnerID()
	local selectedEntities = GetSelectedEntities( playerID )
	for _,v in pairs(selectedEntities) do
		if v==entIndex then
			return true
		end
	end
	return false
end

-- Force-check the game event
function UpdateSelectedEntities()
	FireGameEvent("dota_player_update_selected_unit", {})
end

function GetMainSelectedEntity( playerID )
	if GameRules.SELECTED_UNITS[playerID]["0"] then
		return EntIndexToHScript(GameRules.SELECTED_UNITS[playerID]["0"])
	end
	return nil
end

-- ToggleAbility On only if its turned Off
function ToggleOn( ability )
	if ability:GetToggleState() == false then
		ability:ToggleAbility()
	end
end

-- ToggleAbility Off only if its turned On
function ToggleOff( ability )
	if ability:GetToggleState() == true then
		ability:ToggleAbility()
	end
end

function IsMultiOrderAbility( ability )
	if IsValidEntity(ability) then
		local ability_name = ability:GetAbilityName()
		local ability_table = GameRules.AbilityKV[ability_name]

		if not ability_table then
			ability_table = GameRules.ItemKV[ability_name]
		end

		if ability_table then
			local AbilityMultiOrder = ability_table["AbilityMultiOrder"]
			if AbilityMultiOrder and AbilityMultiOrder == 1 then
				return true
			end
		else
			print("Cant find ability table for "..ability_name)
		end
	end
	return false
end

-- Goes through every ability and item, checking for any ability being channelled
function IsChanneling ( hero )
	
	for abilitySlot=0,15 do
		local ability = hero:GetAbilityByIndex(abilitySlot)
		if ability ~= nil and ability:IsChanneling() then 
			return true
		end
	end

	for itemSlot=0,5 do
		local item = hero:GetItemInSlot(itemSlot)
		if item ~= nil and item:IsChanneling() then
			return true
		end
	end

	return false
end

-- Global item applier
function ApplyModifier( unit, modifier_name )
	local item = CreateItem("item_apply_modifiers", nil, nil)
	item:ApplyDataDrivenModifier(unit, unit, modifier_name, {})
	item:RemoveSelf()
end

-- Removes the first item by name if found on the unit. Returns true if removed
function RemoveItemByName( unit, item_name )
	for i=0,15 do
		local item = unit:GetItemInSlot(i)
		if item and item:GetAbilityName() == item_name then
			item:RemoveSelf()
			return true
		end
	end
	return false
end

-- Takes all items and puts them 1 slot back
function ReorderItems( caster )
	local slots = {}
	for itemSlot = 0, 5, 1 do

		-- Handle the case in which the caster is removed
		local item
		if IsValidEntity(caster) then
			item = caster:GetItemInSlot( itemSlot )
		end

       	if item ~= nil then
			table.insert(slots, itemSlot)
       	end
    end

    for k,itemSlot in pairs(slots) do
    	caster:SwapItems(itemSlot,k-1)
    end
end

function OnStartTouch(trigger)
 	if trigger.activator:GetName() == "npc_dota_hero_invoker" then
    table.insert(slayers,trigger.activator )
  end
end
 
function OnEndTouch(trigger)
 

  if trigger.activator:GetName() == "npc_dota_hero_invoker" then
  	for key,value in pairs(slayers) do
  		if trigger.activator ==value then
    		table.remove(slayers,key )
		end
	end
  end
end

function OnStartTouchShop(trigger)
	print(trigger.activator:GetName())
	local player = trigger.activator:GetPlayerOwner()
 if trigger.activator:GetName() == "npc_dota_hero_night_stalker" then
   CustomGameEventManager:Send_ServerToPlayer( player, "ShopOn" ,player)
  end
 if trigger.activator:GetName() == "npc_dota_hero_invoker" then
   CustomGameEventManager:Send_ServerToPlayer( player, "ShopOnHuman" ,player)
  end
end

function OnEndTouchShop(trigger)
local player = trigger.activator:GetPlayerOwner()
  if trigger.activator:GetName() == "npc_dota_hero_night_stalker" then
   CustomGameEventManager:Send_ServerToPlayer( player, "ShopOff" ,player)
  end
  if trigger.activator:GetName() == "npc_dota_hero_invoker" then
  CustomGameEventManager:Send_ServerToPlayer( player, "ShopOff" ,player)
  end
end

function slayerpool(  )

	Timers:CreateTimer(function()
	
	if slayers ~= nil then
		for key,value in pairs(slayers) do
			value:HeroLevelUp(true)
		end
	end
	return 60 end)
end

function goldsystem()
	
		print("Gold system Activated!")
		local playersgold = {}

		Timers:CreateTimer(function()	
		if players ~= nil then
			for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
				if PlayerResource:GetPlayer(nPlayerID) then
					if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
						local player=PlayerResource:GetPlayer( nPlayerID )

							for j,building in pairs(player.structures) do
								if building and not building:IsNull() then 
									if building:GetUnitName() == "gold_mine" then
										if playersgold[player] == nil then
											playersgold[player] = 2
										else
										playersgold[player]= playersgold[player] +2
										end
									end
								end
							end
						
							local hero = player:GetAssignedHero()
							if playersgold[player] ~= nil then
							hero:ModifyGold(tonumber(playersgold[player]),false,0) 
							CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
							end
					end
				end
			end

			for k in pairs (playersgold) do
	   		 playersgold[k] = nil
			end
		end
		return 60 end)


		Timers:CreateTimer(function()
		if players ~= nil then	
			for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
				if PlayerResource:GetPlayer(nPlayerID) then
					if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
						local player=PlayerResource:GetPlayer( nPlayerID )

						for j,building in pairs(player.structures) do
							if building and not building:IsNull() then 
								if building:GetUnitName() == "super_gold_mine" then
									if playersgold[player] == nil then
										playersgold[player] = 2
									else
									playersgold[player]= playersgold[player] +2
									end
								end
							end
						end

						local hero = player:GetAssignedHero()
						if playersgold[player] ~= nil then
						hero:ModifyGold(tonumber(playersgold[player]),false,0) 
						CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
						end
					end
				end
			end

			for k in pairs (playersgold) do
	   		 playersgold[k] = nil
			end
		end	
		return 15 end)

		Timers:CreateTimer(function()	
		if players ~= nil then
			for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
				if PlayerResource:GetPlayer(nPlayerID) then
					if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
						local player=PlayerResource:GetPlayer( nPlayerID )
						
							for j,building in pairs(player.structures) do
								if building and not building:IsNull() then 
									if building:GetUnitName() == "ultra_gold_mine" then
										if playersgold[player] == nil then
											playersgold[player] = 2
										else
										playersgold[player]= playersgold[player] +2
										end
									end
								end
							end
							
							local hero = player:GetAssignedHero()
							if playersgold[player] ~= nil then
							hero:ModifyGold(tonumber(playersgold[player]),false,0) 
							
							CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
							end
					end
				end
			end

			for k in pairs (playersgold) do
	   		 playersgold[k] = nil
			end
		end
		return 6 end)

		Timers:CreateTimer(function()	
		if players ~= nil then
			for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
				if PlayerResource:GetPlayer(nPlayerID) then
					if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
						local player=PlayerResource:GetPlayer( nPlayerID )
							for j,building in pairs(player.structures) do
								if building and not building:IsNull() then 
									if building:GetUnitName() == "elite_gold_mine" then
										if playersgold[player] == nil then
											playersgold[player] = 2
										else
										playersgold[player]= playersgold[player] +2
										end
									end
								end
							end


							local hero = player:GetAssignedHero()
							if playersgold[player] ~= nil then
							hero:ModifyGold(tonumber(playersgold[player]),false,0) 
							CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
							end
					end	
				end
			end

			for k in pairs (playersgold) do
	   		 playersgold[k] = nil
			end
		end
		return 4 end)
	
end

function urnsystem()
	
		print("Urn system Activated!")
		local income = 20
	Timers:CreateTimer(60,function()
	
	if vampires ~= nil then

		for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
			if PlayerResource:GetPlayer(nPlayerID) then
				if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_BADGUYS then
					local vampire=PlayerResource:GetPlayer( nPlayerID ):GetAssignedHero()
					if GameRules:GetDOTATime(false,false) > 720 then
						income =30
					end
					if GameRules:GetDOTATime(false,false)  > 1440 then
						income = 40
					end
					if GameRules:GetDOTATime(false,false)  > 2160 then
						income = 50
					end
					if GameRules:GetDOTATime(false,false)  > 2880 then
						income =60
					end
					if GameRules:GetDOTATime(false,false)  > 3600 then
						income = 70
					end
					if vampire:HasItemInInventory("item_urn_dracula") then
						vampire:ModifyGold(income, false,0) 
						local player = vampire:GetPlayerOwner()
						CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
					end
				end
			end
		end
	end	
	return 60 end)
end

function CoinPickUp( keys )
	local caster = keys.caster
	local player = caster:GetPlayerOwner()
	local hero = player:GetAssignedHero()
	local ability = keys.ability
	if ability:GetSpecialValueFor("amount") > 1 then 
		hero:ModifyGold(3,false , 0)
		CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
		--PopupGoldGain(caster,3)
		 SendOverheadEventMessage( player, OVERHEAD_ALERT_GOLD  , caster, 3, nil )
		 --player.slayer:HeroLevelUp(true)
	else
		hero:ModifyGold(1,false , 0)
		 CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
		--PopupGoldGain(caster,1)
		 SendOverheadEventMessage( player, OVERHEAD_ALERT_GOLD  , caster, 1, nil )
		 --player.slayer:HeroLevelUp(true)
		-- player.slayer:AddExperience(2000,false,false)
	end
end

function RollDrops(unit,killer)
    local DropInfo = GameRules.DropTable[unit:GetUnitName()]
    if DropInfo then
        for k,ItemTable in pairs(DropInfo) do
            local chance = ItemTable.Chance or 100
            local max_drops = ItemTable.Multiple or 1
            local item_name = ItemTable.Item
            for i=1,max_drops do
                if RollPercentage(chance) then
                    print("Creating "..item_name)
                    local item = CreateItem(item_name, nil, nil)
                    item:SetPurchaseTime(0)
                    GameRules.LeakTable[item:GetEntityIndex()]=killer:GetPlayerID()
                    print(item:GetEntityIndex())
                    local pos = unit:GetAbsOrigin()
                    local drop = CreateItemOnPositionSync( pos, item )
                    local pos_launch = pos
                    
                   -- item:LaunchLoot(false, 200, 0.75, pos_launch)
                end
            end
        end
    end
end

function WorkersDie( player,unitname )
	local amount
	local id = {
	"peasant",
	"furbolg_harvester",
	"fang_harvester",
	"fire_spawn_deforester",
	"satyr_harvester"
	}
	local food = {
	5,
	20,
	30,
	40,
	60
	}
	for key,val in pairs(id) do
		if unitname == val then
		amount = food[key]
		end
	end
	if amount then
		ModifyFood(player,-amount)
	end
end

function WorkersHire( player,workerid,food_cost,gold,lumber )
	local  workername
	local id = {
	"peasant",
	"furbolg_harvester",
	"fang_harvester",
	"fire_spawn_deforester",
	"satyr_harvester",
	"tower_builder",
	"super_tower_builder",
	"goblin_tower_builder"
	}
	for key,val in pairs(id) do
		if workerid == key then
		workername = id[workerid]
		end
	end

	if workername then
		if not PlayerHasEnoughFood( player, food_cost ) then
			return false
		end

		if not PlayerHasEnoughGold( player, gold ) then
			return false
		end

		if not PlayerHasEnoughLumber( player, lumber ) then
			return false
		end
	print("nice")
	ModifyFood(player,food_cost)
	ModifyLumber(player,-lumber)
	player:GetAssignedHero():ModifyGold(-gold,false,0)
	CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
	return true
	end

end

function VampireMinionsDie( player, unitname )
	local food_cost = GetUnitKV(unitname,"FoodCost") or 0
	ModifyFood(player,-food_cost)
end

function SellItem( unit, item )
    local player = unit:GetPlayerOwner()
    local playerID = player:GetPlayerID()
    local item_name = item:GetAbilityName()
    local GoldCost = GetItemKV(item_name,"GoldCost")
    local LumberCost = GetItemKV(item_name,"LumberCost")
    local hero = player:GetAssignedHero()

      -- 10 second sellback Thx Noya
    local time = item:GetPurchaseTime()
    local refund_factor = GameRules:GetGameTime() <= time+10 and 1 or 0.5
    if GoldCost then
       hero:ModifyGold(GoldCost*refund_factor,false,0)
		CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
        PopupGoldGain( unit, GoldCost*refund_factor)
    end

    if LumberCost then
        ModifyLumber(player,LumberCost*refund_factor)
        PopupLumber( unit, LumberCost*refund_factor)
    end

    EmitSoundOnClient("General.Sell", player)

    item:RemoveSelf()
end

function ItemsLoad( )
	local units={
	"Shade",
	"Abomination",
	"Fel_Beast",
	"Assasin",
	"French_Man",
	"Infernal",
	"Doom_Guard",
	"Meat_Carrier",
	""}
	local table ={}
	for key,uname in pairs(units) do
	local gold_cost = GetUnitKV(uname,"GoldCost") or 0
	local lumber_cost = GetUnitKV(uname,"LumberCost") or 0
	table[uname] ={gold=gold_cost,lumber=lumber_cost}
	end

	CustomNetTables:SetTableValue("upgrades","UnitHire", table )
	
	local items={
	"item_vampiric_boots",
	"item_sphere_of_doom",
	"item_vamp_invul",
	"item_dracula_helm",
	"item_ring_hell_lords",
	"item_pulse_staff",
	"item_immunity_shield",
	"item_urn_dracula",
	"item_demonic_remains",
	"item_rod_of_teleportation",
	"item_burst_gem",
	"item_build_massive_grave",
	"item_cloak_of_shadows",
	"item_windwalk_potion",
	"item_silent_whisper",
	"item_refresh_potion",
	"item_claws_dreadlord",
	"item_gaunthlets_underworld",
	"item_gaunthlets_hellfire",
		"item_replenishment_potion",
		"item_scroll_of_beast",
		"item_shop_ring_regen",
		"item_shop_att",
		"item_shop_ring_protection",
		"item_sentry_wards",
		"item_wand_cyclone",
		"item_wand_shadowsight"
	}
local tableitems ={}
	for key,uname in pairs(items) do
	local gold_cost = GetItemKV(uname,"GoldCost") or 0
	local lumber_cost = GetItemKV(uname,"LumberCost") or 0
	local time_restock = GetItemKV(uname,"TimeRestock") or 120
	tableitems[uname] ={gold=gold_cost,lumber=lumber_cost,time=time_restock}
	end
	CustomNetTables:SetTableValue("upgrades","ItemBuy", tableitems )
	local HumanItems={
	"item_pendant_mana",
	"item_pendant_vitality",
	"item_orb_venom",
	"item_summon_engineers",
	"item_Master_Slayer",
	"item_Circlet_Slayer",
	"item_Divinity_Jewel",
	"item_gold_convert"
	}
	local tableitemss ={}
	for key,uname in pairs(HumanItems) do
	local gold_cost = GetItemKV(uname,"GoldCost") or 0
	local lumber_cost = GetItemKV(uname,"LumberCost") or 0
	local time_restock = GetItemKV(uname,"TimeRestock") or 1
	tableitemss[uname] ={gold=gold_cost,lumber=lumber_cost,time=time_restock}
	end
	CustomNetTables:SetTableValue("upgrades","ItemBuyHuman", tableitemss )

end


function ShopFind ( keys )
	local caster = keys.caster
	local position = caster:GetAbsOrigin()
	local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 400, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		
		if caster:GetName() == "npc_dota_hero_invoker" then
		   CustomGameEventManager:Send_ServerToPlayer( player, "ShopOnHuman" ,player)
		end

	  if caster:GetName() == "npc_dota_hero_invoker" then
	 	 CustomGameEventManager:Send_ServerToPlayer( player, "ShopOff" ,player)
	  end

end

function TreeFree( caster )
	if caster.target_tree then
		if caster.target_tree.worker  then
		caster.target_tree.worker = caster.target_tree.worker -1
		end
	end
end

function GoldIncomeTime()
	local incomeHuman = 2
	local incomeVampire = 100
	local incomeLumber = 1500
	Timers:CreateTimer(720,function()		
		for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
			if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_BADGUYS then
				local hPlayer = PlayerResource:GetPlayer( nPlayerID )
				local hero  = PlayerResource:GetPlayer( nPlayerID ):GetAssignedHero()
				hero:ModifyGold(incomeVampire, false,0) 
				ModifyLumber(hPlayer,incomeLumber)
				CustomGameEventManager:Send_ServerToPlayer(hPlayer, "player_gold_changed", {})
			end
			if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
				local hPlayer = PlayerResource:GetPlayer( nPlayerID )
				local hero  = PlayerResource:GetPlayer( nPlayerID ):GetAssignedHero()
				hero:ModifyGold(incomeHuman, false,0) 
				CustomGameEventManager:Send_ServerToPlayer(hPlayer, "player_gold_changed", {})
			end
		end
		
		--GameRules:SendCustomMessage("For "..ConvertToTime(GameRules:GetDOTATime(false,false)).." min, all <font color='#899eb2'>Humans </font> receive <font color='#FFD700'>"..incomeHuman.."</font> golds, All <font color='#325b49'>Vampire</font> receive "..incomeVampire.." golds and "..incomeLumber.." lumbers", 0, 0)
		GameRules:SendCustomMessage("<font color='#2684ff'>If you experience any bugs, please submit an issue on Workshop page</font>",0,0)
		System_msg("For "..ConvertToTime(GameRules:GetDOTATime(false,false)).." min, all <font color='#899eb2'>Humans </font> receive <font color='#FFD700'>"..incomeHuman.."</font> golds, All <font color='#325b49'>Vampire</font> receive <font color='#FFD700'>"..incomeVampire.."</font> golds and <font color='#008000'>"..incomeLumber.."</font> lumbers",10)
		incomeHuman= incomeHuman+1
		incomeLumber = incomeLumber + 1500
		incomeVampire=incomeVampire + incomeVampire
	return 720
	 end)
end

function VampireHelp()
	Timers:CreateTimer(60,function()
	if vampires ~= nil then
		for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
			if PlayerResource:GetPlayer(nPlayerID) then
				if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_BADGUYS then
					local vampire=PlayerResource:GetPlayer( nPlayerID ):GetAssignedHero()
					if vampire and not vampire:IsNull() then
						vampire.lvl = vampire:GetLevel()
					end
				end
			end
		end
	end
	end)
	local lvl=0
	Timers:CreateTimer(180,function()
	if vampires ~= nil then
		
		for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
			if PlayerResource:GetPlayer(nPlayerID) then
				if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_BADGUYS then
					local vampire=PlayerResource:GetPlayer( nPlayerID ):GetAssignedHero()
					if vampire and not vampire:IsNull() then
						lvl = vampire:GetLevel()
						if vampire.lvl >=lvl then
							vampire:HeroLevelUp(true)
							vampire.lvl = vampire:GetLevel()
						else
							vampire.lvl = vampire:GetLevel()
						end
					end
				end
			end
		end
	end	
	return 180 end)
	Timers:CreateTimer(300,function()
	if vampires ~= nil then
		for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
			if PlayerResource:GetPlayer(nPlayerID) then
				if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_BADGUYS then
					local vampire=PlayerResource:GetPlayer( nPlayerID ):GetAssignedHero()
						if vampire and not vampire:IsNull() then
							vampire:ModifyGold(25, false,0) 
							local player = vampire:GetPlayerOwner()
							CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
						end
				end	
			end	
		end
	end	
	return 300 end)

end

function TechTreeRecursive(unit)
	local unitName = unit:GetUnitName()
	local player = unit:GetPlayerOwner()
	local hero = player:GetAssignedHero()

	if unitName == "lumber_house" then
		player.buildings["build_house"] = player.buildings["build_house"] - 1
	end
	if unitName == "deforestation_house" then
		player.buildings["build_house"] = player.buildings["build_house"] - 1
		player.buildings["lumber_house"] = player.buildings["lumber_house"] - 1
	end
	if unitName == "ultra_research_center" then
		player.buildings["research_center"] = player.buildings["research_center"] - 1
	end
	if unitName == "citadel_of_faith" then
		player.buildings["slayers_vault"] = player.buildings["slayers_vault"] - 1
	end
	if unitName == "command_center" then
		player.buildings["slayers_vault"] = player.buildings["slayers_vault"] - 1
		player.buildings["citadel_of_faith"] = player.buildings["citadel_of_faith"] - 1
	end
	if unitName == "base_of_operations" then
		player.buildings["slayers_vault"] = player.buildings["slayers_vault"] - 1
		player.buildings["citadel_of_faith"] = player.buildings["citadel_of_faith"] - 1
		player.buildings["command_center"] = player.buildings["command_center"] - 1
	end
end

function HumanDie( hero )
	local player = hero:GetPlayerOwner()
	local pID = player:GetPlayerID()
	
		CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "player_gold_changed", {})
		ModifyLumber(player,-player.lumber)
		 local playername = PlayerResource:GetPlayerName(pID)
		 if player.slayer then 
		 player.slayer:RemoveSelf()
    	 UTIL_Remove(player.slayer)
    	 end

    	 --Humans left
    	 local HumanLive=0
    	     for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
		    	if PlayerResource:GetPlayer(nPlayerID) then
					if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
						local human=PlayerResource:GetPlayer( nPlayerID ):GetAssignedHero()
						if human and human:IsAlive() then
				    		HumanLive = HumanLive +1
				    	end
				    end 
			    end
		    end

  		GameRules:SendCustomMessage("<font color='"..ColorText(pID).."'>"..playername.." </font>  defeated!", 0, 0)
  		GameRules:SendCustomMessage("<font color='#00FFFF'>"..HumanLive.."</font> Humans left ", 0, 0)
    	for k,units in pairs(player.units) do
    		units:RemoveSelf()
    		UTIL_Remove(unit)
    	end

    	for k,structure in pairs(player.structures) do
    		structure:RemoveSelf()
    		UTIL_Remove(structure)
    	end
    	

   
end

function modifierRemove()
	for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
    	if PlayerResource:GetPlayer(nPlayerID) then
				local hero=PlayerResource:GetPlayer( nPlayerID ):GetAssignedHero()
          	hero:RemoveModifierByName("modifier_client_convars")
	    end
    end
end

function FoodLimit(player)
	local pID = player:GetPlayerID()
	local hero = player:GetAssignedHero()
	local fTent = 0
	local fTent2=0

	if player.buildings["tent_1"] then
		fTent = 25*player.buildings["tent_1"]
	end
	if player.buildings["tent_2"] then
		fTent2 = 55*player.buildings["tent_2"]
	end
	SetMaxFood(player)
	ModifyMaxFood(player,fTent+fTent2+30)
end

function playerReconnect( newPlayer,pID )
	local player = CustomNetTables:GetTableValue("ply",tostring(pID))
	newPlayer.units  = player.units 
	newPlayer.structures = player.structures 
	newPlayer.buildings = player.buildings 
	newPlayer.upgrades = player.upgrades 
	newPlayer.lumber = player.lumber
	newPlayer.food = player.food 
	newPlayer.LumberCarried = player.LumberCarried 
	newPlayer.target_repair = player.target_repair
	newPlayer.maxfood = player.maxfood
	newPlayer.slayer = player.slayer
	newPlayer.upgrades = player.upgrades
	newPlayer.buildings = player.buildings
	print("Reinitial player"..tostring(pID).." finished")

end

function CoinConvert( keys )
	local caster = keys.caster
	local player = caster:GetOwner() 
	local pID = player:GetPlayerID()
	local hero = player:GetAssignedHero()
	hero:ModifyGold(1,false,0)
end

function MapAlert (hEnt)

	local pos = hEnt:GetAbsOrigin()
	if hEnt:GetTeamNumber() ~= 3 and (GameRules:GetDOTATime(false,false) - GameRules.MapAlertAbl) > 25 then

	MinimapEvent(hEnt:GetTeamNumber(),hEnt,pos[1],pos[2],512,4)
	--EmitGlobalSound("announcer_ann_base_underattack_01")
		if hEnt:GetUnitName()=="npc_dota_hero_invoker" then
		EmitAnnouncerSoundForPlayer("invoker_invo_underattack_02",hEnt:GetOwner():GetPlayerID())
		else
		EmitAnnouncerSoundForTeam("announcer_ann_custom_adventure_alerts_44",2)
		end
	GameRules.MapAlertAbl = GameRules:GetDOTATime(false,false)
	end
	-- Timers:CreateTimer(15,function ()
	-- 	GameRules.MapAlertAbl =true
	-- end)
end

function System_msg(Stext, Idelay )
	CustomGameEventManager:Send_ServerToAllClients( "system_msg", {text=Stext,delay=Idelay})
end
function Vampire_msg(player,Stext,soundName, Idelay,count )
	if count == "all" then
	CustomGameEventManager:Send_ServerToAllClients("vampire_msg", {text=Stext,delay=Idelay,soundName=soundName})
	else
		CustomGameEventManager:Send_ServerToPlayer(player,"vampire_msg", {text=Stext,delay=Idelay,soundName=soundName})
	end
end
