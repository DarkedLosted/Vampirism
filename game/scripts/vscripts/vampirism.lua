
DEBUG_SPEW = 1

function vampirism:InitGameMode()


	LimitPathingSearchDepth(0.3)
	-- Get Rid of Shop button - Change the UI Layout if you want a shop button
	GameRules:GetGameModeEntity():SetHUDVisible(6, false)
	--GameRules:GetGameModeEntity():SetHUDVisible(5, false)

	GameRules:GetGameModeEntity():SetHUDVisible(2, false)
	GameRules:GetGameModeEntity():SetHUDVisible(9, false)
	GameRules:GetGameModeEntity():SetHUDVisible(1, false)
 	 GameRules:GetGameModeEntity():SetHUDVisible(12, false)
 	--GameRules:GetGameModeEntity():SetHUDVisible(11, false)
 	GameRules:GetGameModeEntity():SetHUDVisible(25, false)
 	GameRules:GetGameModeEntity():SetHUDVisible(23, false)
 	GameRules:GetGameModeEntity():SetHUDVisible(24, false)
 	GameRules:GetGameModeEntity():SetHUDVisible(10, false)
 	

	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1300)

	GameRules:GetGameModeEntity():SetRecommendedItemsDisabled( true )
    GameRules:GetGameModeEntity():SetCustomBuybackCostEnabled( true )
    GameRules:GetGameModeEntity():SetCustomBuybackCooldownEnabled( true )
    GameRules:GetGameModeEntity():SetBuybackEnabled( false )
    GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride ( true )
   

    -- GameRules:GetGameModeEntity():SetCustomHeroMaxLevel ( 200 )
    GameRules:GetGameModeEntity():SetUseCustomHeroLevels  ( true )
  	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )

    GameRules:GetGameModeEntity():SetBotThinkingEnabled( false )
    GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled( false )

    GameRules:GetGameModeEntity():SetFogOfWarDisabled(false)
    GameRules:GetGameModeEntity():SetGoldSoundDisabled( false )
    GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )

   -- GameRules:GetGameModeEntity():SetAlwaysShowPlayerInventory( false )
    GameRules:GetGameModeEntity():SetAnnouncerDisabled( false )

    GameRules:GetGameModeEntity():SetFountainConstantManaRegen( 0)
    GameRules:GetGameModeEntity():SetFountainPercentageHealthRegen( 0 )
    GameRules:GetGameModeEntity():SetFountainPercentageManaRegen( 0 )
    GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
    GameRules:GetGameModeEntity():SetMaximumAttackSpeed( 400 )
    GameRules:GetGameModeEntity():SetMinimumAttackSpeed( 20 )
    GameRules:GetGameModeEntity():SetStashPurchasingDisabled ( true )

   

    GameRules:GetGameModeEntity():SetUnseenFogOfWarEnabled( false )

    GameRules:GetGameModeEntity():SetDaynightCycleDisabled( true )
    GameRules:GetGameModeEntity():SetKillingSpreeAnnouncerDisabled( true )
    GameRules:GetGameModeEntity():SetStickyItemDisabled( true )
    --dunge options
    GameRules:GetGameModeEntity():DisableHudFlip( true )
    GameRules:GetGameModeEntity():SetFriendlyBuildingMoveToEnabled( true )
 	GameRules:GetGameModeEntity():SetDeathOverlayDisabled( true )
 	GameRules:GetGameModeEntity():SetHudCombatEventsDisabled( true )
 	 GameRules:GetGameModeEntity():SetStashPurchasingDisabled( true )
 	GameRules:SetCustomGameAllowHeroPickMusic(false)
 	GameRules:SetCustomGameAllowBattleMusic(false)
	GameRules:SetCustomGameAllowMusicAtGameStart(true)
	-- Setup rules
  GameRules:SetHeroRespawnEnabled( false )
  GameRules:SetUseUniversalShopMode( false )
  GameRules:SetSameHeroSelectionEnabled( true )
   --GameRules:SetCustomGameSetupTimeout( 0 ) 

  GameRules:SetHeroSelectionTime( 0 )
  GameRules:SetShowcaseTime( 0.0 )
  GameRules:SetPreGameTime( 1)
  GameRules:SetPostGameTime( 20 )
  GameRules:SetTreeRegrowTime( 60 )
  GameRules:SetStrategyTime( 0.0 )
  --Lua Modifiers
 	LinkLuaModifier("modifier_client_convars", "libraries/modifiers/modifier_client_convars", LUA_MODIFIER_MOTION_NONE)
 	 LinkLuaModifier("modifier_attack_disabled", "libraries/modifiers/modifier_attack_disabled", LUA_MODIFIER_MOTION_NONE)
 	  LinkLuaModifier("modifier_stunn", "libraries/modifiers/modifier_stunn", LUA_MODIFIER_MOTION_NONE)
 	    LinkLuaModifier("modifier_upgrade_building", "libraries/modifiers/modifier_upgrade_building", LUA_MODIFIER_MOTION_NONE)
 	     LinkLuaModifier("modifier_rifles", "libraries/modifiers/modifier_rifles", LUA_MODIFIER_MOTION_NONE)
 	    LinkLuaModifier("modifier_vampire_spawn", "libraries/modifiers/modifier_vampire_spawn", LUA_MODIFIER_MOTION_NONE)
 		LinkLuaModifier("modifier_command_restricted", "libraries/modifiers/modifier_command_restricted", LUA_MODIFIER_MOTION_NONE)
 		LinkLuaModifier("modifier_pre_build", "libraries/modifiers/modifier_pre_build", LUA_MODIFIER_MOTION_NONE)
 		LinkLuaModifier("modifier_low_priority", "libraries/modifiers/modifier_low_priority", LUA_MODIFIER_MOTION_NONE)
 		LinkLuaModifier("modifier_fow_vision", "libraries/modifiers/modifier_fow_vision", LUA_MODIFIER_MOTION_NONE)
 		--LinkLuaModifier("modifier_FORCE_DRAW_MINIMAP", "libraries/modifiers/modifier_FORCE_DRAW_MINIMAP", LUA_MODIFIER_MOTION_NONE)
 		LinkLuaModifier("modifier_agillity", "libraries/modifiers/modifier_agillity", LUA_MODIFIER_MOTION_NONE)
 		--filter
 		 

 	 -- Modifier Applier
    GameRules.Applier = CreateItem("item_apply_modifiers", nil, nil)
 GameRules:SetUseCustomHeroXPValues ( true )
  GameRules:SetGoldPerTick(0)
  GameRules:SetGoldTickTime(0)
  GameRules:SetUseBaseGoldBountyOnHeroes(false)

  GameRules:SetFirstBloodActive( false )
  GameRules:SetHideKillMessageHeaders( true )

  GameRules:SetStartingGold( 0 )
  GameRules:SetCustomGameSetupAutoLaunchDelay( 20 )
	-- DebugPrint
	Convars:RegisterConvar('debug_spew', tostring(DEBUG_SPEW), 'Set to 1 to start spewing debug info. Set to 0 to disable.', 0)
	
	-- Event Hooks
	ListenToGameEvent('entity_killed', Dynamic_Wrap(vampirism, 'OnEntityKilled'), self)
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(vampirism, 'OnPlayerPickHero'), self)
  	ListenToGameEvent('npc_spawned', Dynamic_Wrap(vampirism, 'OnNPCSpawned'), self)
  	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(vampirism, 'OnGameRulesStateChange'), self)
  	ListenToGameEvent( "dota_player_reconnected", Dynamic_Wrap( vampirism, 'OnPlayerReconnected' ), self )
  	ListenToGameEvent('player_disconnect', Dynamic_Wrap(vampirism, 'OnDisconnect'), self)
  	ListenToGameEvent('player_connect_full', Dynamic_Wrap(vampirism, 'OnConnectFull'), self)
  	ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( vampirism, 'OnItemPickedUp' ), self )

  -- Don't end the game if everyone is unassigned
    SendToServerConsole("dota_surrender_on_disconnect 0")
    -- Increase time to load and start even if not all players loaded
    SendToServerConsole("dota_wait_for_players_to_load_timeout 240")

	-- Filters
    GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( vampirism, "FilterExecuteOrder" ), self )
    GameRules:GetGameModeEntity():SetModifyExperienceFilter( Dynamic_Wrap( vampirism, "FilterExperience" ), self )
    GameRules:GetGameModeEntity():SetModifyGoldFilter( Dynamic_Wrap( vampirism, "FilterGold" ), self )
 	GameRules:GetGameModeEntity():SetDamageFilter( Dynamic_Wrap( vampirism, "FilterDamage" ), self )
    -- Register Listener
    CustomGameEventManager:RegisterListener( "update_selected_entities", Dynamic_Wrap(vampirism, 'OnPlayerSelectedEntities'))
   	CustomGameEventManager:RegisterListener( "repair_order", Dynamic_Wrap(vampirism, "RepairOrder"))  	
    CustomGameEventManager:RegisterListener( "building_helper_build_command", Dynamic_Wrap(BuildingHelper, "BuildCommand"))
	CustomGameEventManager:RegisterListener( "building_helper_cancel_command", Dynamic_Wrap(BuildingHelper, "CancelCommand"))
	CustomGameEventManager:RegisterListener("buildui_command", Dynamic_Wrap(vampirism, 'OnBuildUI'))
	CustomGameEventManager:RegisterListener("hire_command", Dynamic_Wrap(vampirism, 'OnHire'))
	CustomGameEventManager:RegisterListener("buy_command", Dynamic_Wrap(vampirism, 'OnShopBuy'))
	CustomGameEventManager:RegisterListener("tradeui_send", Dynamic_Wrap(vampirism, 'OnTradeUISend'))
	CustomGameEventManager:RegisterListener("research_command", Dynamic_Wrap(vampirism, 'ResearchStart'))
	CustomGameEventManager:RegisterListener("research_command_cancel", Dynamic_Wrap(vampirism, 'ResearchCancel'))
	CustomGameEventManager:RegisterListener( "Player_Inf_Upd", Dynamic_Wrap(vampirism, 'PlayerInfoUpdate') )

	--CustomGameEventManager:RegisterListener("tree_cut_order", Dynamic_Wrap(vampirism, "TreeTarget"))
	CustomGameEventManager:RegisterListener("tree_cut_order", Dynamic_Wrap(vampirism, "ordercuttree"))

	-- Full units file to get the custom values
	GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
  	GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  	GameRules.HeroKV = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")
  	GameRules.ItemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
  	GameRules.Requirements = LoadKeyValues("scripts/kv/tech_tree.kv")

  	-- Store and update selected units of each pID
	GameRules.SELECTED_UNITS = {}
	GameRules.LeakTable = {}
	GameRules.DropTable = LoadKeyValues("scripts/kv/item_drops.kv")
	GameRules.DebugMode = false
	GameRules.MapAlertAbl=GameRules:GetDOTATime(false,false)
	-- Keeps the blighted gridnav positions
	--GameRules.Blight = {}

	-- GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 0.5 )
	vampirism:SetUpFountains()
	

	--custom lvl
	--for i=1,100 do
 -- XP_PER_LEVEL_TABLE[i] = (i-1) * 100
	--end
-- Teams
MAX_NUMBER_OF_TEAMS = 2                -- How many potential teams can be in this game mode?
USE_CUSTOM_TEAM_COLORS = true           -- Should we use custom team colors?
USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS = true          -- Should we use custom team colors to color the players/minimap?

TEAM_COLORS = {}                        -- If USE_CUSTOM_TEAM_COLORS is set, use these colors.
TEAM_COLORS[0] = { 255, 0, 0 }  --    Red
TEAM_COLORS[1]  = { 0, 0, 255 }   --    blue
TEAM_COLORS[2] = { 0, 255, 255 }  --    teal
TEAM_COLORS[3] = { 102, 51, 153 }   --    purple
TEAM_COLORS[4] = { 255, 255, 0 }   --    yellow
TEAM_COLORS[5] = { 255, 165, 0 }  --    orange
TEAM_COLORS[6] = { 50, 205, 50 }  --    green
TEAM_COLORS[7] = { 255, 105, 180 }  --    pink
--TEAM_COLORS[DOTA_TEAM_CUSTOM_7] = { 169, 169, 169 }  --    gray
--TEAM_COLORS[DOTA_TEAM_CUSTOM_8] = { 137, 207, 240 }  --    light blue
TEAM_COLORS[8] = { 0, 106, 78 }  --   dark Green
TEAM_COLORS[9] = {75, 54, 33 }   --    Brown
USE_AUTOMATIC_PLAYERS_PER_TEAM = false   -- Should we set the number of players to 10 / MAX_NUMBER_OF_TEAMS?

CUSTOM_TEAM_PLAYER_COUNT = {}           -- If we're not automatically setting the number of players per team, use this table
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 10
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 2
-- CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_1] = 1
-- CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_2] = 1
-- CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_3] = 1
-- CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_4] = 1
-- CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_5] = 1
-- CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_6] = 1
-- CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_7] = 1
-- CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_CUSTOM_8] = 1

-- This is multiteam configuration stuff
  if USE_AUTOMATIC_PLAYERS_PER_TEAM then
    local num = math.floor(10 / MAX_NUMBER_OF_TEAMS)
    local count = 0
    for team,number in pairs(TEAM_COLORS) do
      if count >= MAX_NUMBER_OF_TEAMS then
        GameRules:SetCustomGameTeamMaxPlayers(team, 0)
      else
        GameRules:SetCustomGameTeamMaxPlayers(team, num)
      end
      count = count + 1
    end
  else
    local count = 0
    for team,number in pairs(CUSTOM_TEAM_PLAYER_COUNT) do
      if count >= MAX_NUMBER_OF_TEAMS then
        GameRules:SetCustomGameTeamMaxPlayers(team, 0)
      else
        GameRules:SetCustomGameTeamMaxPlayers(team, number)
      end
      count = count + 1
    end
  end

  if USE_CUSTOM_TEAM_COLORS then
    for team,color in pairs(TEAM_COLORS) do
     -- SetTeamCustomHealthbarColor(team, color[1], color[2], color[3])
   
    end
  end
	for nPlayerID=0,9 do
		local color = TEAM_COLORS[nPlayerID]
 		PlayerResource:SetCustomPlayerColor( nPlayerID, color[1], color[2], color[3] )

	end


end

-- function vampirism:OnThink()
-- 	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		
-- 	end

-- 	return 5
-- end

function vampirism:OnConnectFull(keys)

end

function vampirism:OnGameRulesStateChange( keys )
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_HERO_SELECTION  then
	
	--Timers:CreateTimer(0.5, function()
	self:ForceAssignHeroes()
	--end)
		--Bot.Add()
	end
	 if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

   		 vampirism:OnGameInProgress()
   		 local sound = Entities:FindByName(nil,"vampsound")
   		 Timers:CreateTimer(function()
   		 sound:EmitSoundParams("valve_ti4.music.smoke",0,60,999)
   		 if GameRules:GetGameTime() < 240 then
   		 return 46
   		end
   		  end)
   		end
end

function vampirism:OnGameInProgress()
	slayerpool()
	urnsystem()
	goldsystem()
	GoldIncomeTime()
	VampireHelp()
end

function vampirism:ForceAssignHeroes()
	PauseGame(true)
	for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			local hPlayer = PlayerResource:GetPlayer( nPlayerID )
			if hPlayer and not PlayerResource:HasSelectedHero( nPlayerID ) then
				--hPlayer:MakeRandomHeroSelection()
				local hero = CreateHeroForPlayer("npc_dota_hero_kunkka" , hPlayer) 
                 UTIL_Remove(hero)
			end
		else
			local hPlayer = PlayerResource:GetPlayer( nPlayerID )
			if hPlayer and not PlayerResource:HasSelectedHero( nPlayerID ) then
				--hPlayer:MakeRandomHeroSelection()
				local hero = CreateHeroForPlayer("npc_dota_hero_night_stalker" , hPlayer) 
                 UTIL_Remove(hero)
			end
		end
	end

	PauseGame(false)
end
-- A player picked a hero
function vampirism:OnPlayerPickHero(keys)
	
	local hero = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)
	local playerID = hero:GetPlayerID()

	if hero:GetUnitName()=="npc_dota_hero_invoker" then
		
		local ability = hero:GetAbilityByIndex(0)
		if ability then ability:SetLevel(ability:GetMaxLevel()) end
		 ability = hero:GetAbilityByIndex(5)
		if ability then ability:SetLevel(ability:GetMaxLevel()) end
		hero:SetAbilityPoints(0)

		return
	end
	vampires={}
	-- Initialize Variables for Tracking
	player.units = {} -- This keeps the handle of all the units of the player, to iterate for unlocking upgrades
	player.structures = {} -- This keeps the handle of the constructed units, to iterate for unlocking upgrades
	player.buildings = {} -- This keeps the name and quantity of each building
	player.upgrades = {} -- This kees the name of all the upgrades researched
	player.lumber = 0 -- Secondary resource of the player
	player.food = 0 -- Third resource of the player
	player.LumberCarried = 5
	player.target_repair = {}
	player.fed = 0
	player.leaked = 0

	CustomGameEventManager:Send_ServerToPlayer(player, "player_fed_changed", {pID=player:GetPlayerID(),fed=player.fed})
	CustomGameEventManager:Send_ServerToPlayer(player,"player_leak_changed",{pID=player:GetPlayerID(),leaked=player.leaked})
	if hero:GetUnitName() == "npc_dota_hero_night_stalker" then
		
		if PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS) ==1 then
			 BuildingHelper:BlockGridSquares(4, 4,  Vector(1216,1280,393))
		end
		Timers:CreateTimer(7,function ()
			if not GridNav:IsBlocked(Vector(960,1280,303)) then
				--if not hero:IsNull() then
					local research_center = BuildingHelper:PlaceBuilding(hero:GetOwner(), "vampire_research_center", Vector(960,1280,303), 4, 4, 0) -- CreateUnitByName("vampire_research_center",Vector(860,1280,303),true,hero,hero,3)
				--end
				Timers:CreateTimer(1,function ()
				 if  hero:IsNull() then
				 	UTIL_Remove(research_center)
				 end
				end)
				research_center:SetAbsOrigin(Vector(960,1280,393))
				research_center:AddNewModifier( research_center, nil, "modifier_invulnerable", {} )
			else
				local research_center = BuildingHelper:PlaceBuilding(player, "vampire_research_center", Vector(1216,1280,393), 4, 4, 0)--CreateUnitByName("vampire_research_center",Vector(1416,1280,303),true,hero,hero,3)
				research_center:AddNewModifier( research_center, nil, "modifier_invulnerable", {} )
			end
		end)
		
		if not GameRules.DebugMode then
		hero:AddNewModifier( hero, nil, "modifier_command_restricted", {duration = 55} )
		hero:AddNewModifier( hero, nil, "modifier_vampire_spawn", {duration = 55} )
			Timers:CreateTimer(55,function () 
				CustomGameEventManager:Send_ServerToAllClients( "vampire_spawn", {})
			end)
		end
		Timers:CreateTimer(55,function ()
			EmitGlobalSound("night_stalker_nstalk_ability_dark_07")
			--Vampire_msg(player,"Tonight my enemies will pay","night_stalker_nstalk_ability_dark_07",8)
			end)
		player.maxfood = 10
		hero:SetHullRadius(35)
		table.insert(vampires,hero)
		local a =hero:FindAbilityByName("vampire_poison")
		a:SetLevel(1)
		hero:AddExperience(500, 0, false, true)
	else
		player.maxfood = 30
		hero:SetHasInventory(false)
		
	end
	 player.slayer = nil

	--player.buildname = {}
    -- Create city center in front of the hero
   	-- CreateUnitByName("vampire_research_center",hero:GetAbsOrigin(),true,hero,hero,3)
   	-- CreateUnitByName("build_house",hero:GetAbsOrigin(),true,hero,hero,2)

   	-- if hero:HasItemInInventory("item_tpscroll") then
   	-- 	print("sdf")
   	Timers:CreateTimer(0.1,function() 
   		hero:RemoveItem(hero:GetItemInSlot(0))
   		end)
   	-- 	hero:RemoveItem(hero:GetItemInSlot(1))
   	-- 	hero:RemoveItem(hero:GetItemInSlot(2))
   	-- end


    slayers={}
    shops={}
    players = {}
    table.insert(players,player)
	--CustomNetTables:SetTableValue( "buildings", "",{ {buildin_house=0,slayer_tavern=0,Carnelian_wall=0,tower_pearl=0,wall_of_health=0,research_center=0,human_surplus=0,slayers_vault=0,gold_mine=0} } )
	 player.upgrades["research_slayer_respawn"] = 1
	player.buildings['build_house']=0
	player.buildings['Carnelian_wall']=0
	player.buildings['tower_pearl']=0
	player.buildings['wall_of_health']=0
	player.buildings['slayer_tavern']=0
	player.buildings['research_center']=0
	player.buildings['slayers_vault']=0
	player.buildings['gold_mine']=0

	CustomNetTables:SetTableValue( "buildings", tostring(playerID),{player.buildings})

	CheckAbilityRequirements( hero, player )
	CheckAbilityRequirements( building, player )
	-- Add the hero to the player units list
	table.insert(player.units, hero)
	hero.state = "idle" --Builder state
 	hero:AddNewModifier(hero, nil, "modifier_client_convars", {})
 	ItemsLoad()
 	
	CustomNetTables:SetTableValue( "ply",tostring(playerID),player)
	-- Give Initial Resources
	--hero:SetGold(5000, false)
	ModifyLumber(player, 50)
	-- local item = CreateItem("item_build_massive_grave", hero, hero)
	-- hero:AddItem(item)
	if GameRules.DebugMode then
		ModifyLumber(player, 5000000020)
		ModifyMaxFood(player,250)
		hero:ModifyGold(999999,false,0)
		CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
	end
	--local item = CreateItem("item_summon_engineers", hero, hero)
	--hero:AddItem(item)
	--local item = CreateItem("item_sphere_of_doom", hero, hero)
	--hero:AddItem(item)

	-- Learn all abilities (this isn't necessary on creatures)
	if hero:GetUnitName() == "npc_dota_hero_night_stalker" then
		hero:SetAbilityPoints(3)
	else
		hero:AddNewModifier( hero, nil, "modifier_low_priority", {} )
	for i=0,15 do
		local ability = hero:GetAbilityByIndex(i)
		if ability and ability:GetAbilityName() ~="humans_teleport" then ability:SetLevel(ability:GetMaxLevel()) end
	end
	hero:SetAbilityPoints(0)
	end
	
end

function vampirism:OnDisconnect(keys)
    print('Player Disconnected ' )

   local PlayerID = keys.PlayerID
	--local player = PlayerResource:GetPlayer(PlayerID)
	 print("playerid disconnected "..tostring(keys.PlayerID))
	  local player = PlayerResource:GetPlayer(PlayerID )
	  if GameRules:GetDOTATime(false,false) < 130 then
	 	 player:GetAssignedHero():SetAbsOrigin( vector(-4416,5856,16) )
	  end
    CustomNetTables:SetTableValue( "ply",tostring(PlayerID),player)
        print(keys.reason)
end


function vampirism:OnPlayerReconnected(keys )
    print ( 'OnPlayerReconnect' )
     local PlayerID = keys.player_id
     print("playerid recconected "..tostring(keys.player_id))
     local player = PlayerResource:GetPlayer(PlayerID )
	 playerReconnect(player,PlayerID)
   	 ModifyLumber(player,50)
end



function vampirism:OnNPCSpawned(keys)
  local npc = EntIndexToHScript(keys.entindex)
   local position = npc:GetAbsOrigin()
  npc.targetindex = nil
  
  if npc:GetUnitName() == "ring_ghost" then
		return
	end

  local player = npc:GetOwnerEntity()
  if not player then
  	return 
  end
  local playerID = player:GetPlayerID()

  if npc:GetUnitName() == "engineer" then
 	if  player.upgrades["research_engineers_health"] == 1 then 
	 	npc:SetMaxHealth(1200)
		npc:SetHealth(1200)
	 end
end
--npc:SetAttacktree(true)
function vampirism:CheckWinCondition()
	local VampireLive =0
	local HumanLive = 0
    --CustomNetTables:SetTableValue("dotacraft_player_table", tostring(player:GetPlayerID()), {Status = "defeated"})
    for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
    	if PlayerResource:GetPlayer(nPlayerID) then
			if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_BADGUYS then
				local vampire=PlayerResource:GetPlayer( nPlayerID ):GetAssignedHero()
				if vampire and vampire:IsAlive() then
					VampireLive = VampireLive +1
				end
			end
		end
	end

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
    print("VampireLive:"..VampireLive)
    print("HumanLive:"..HumanLive)
   	if VampireLive == 0 then
        GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
        modifierRemove()
   	end
   	if HumanLive == 0 then
        GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
        modifierRemove()
   	end
end






end