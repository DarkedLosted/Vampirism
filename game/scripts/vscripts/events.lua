function vampirism:PlayerInfoUpdate(event)
  local playerid=event.Playerid
  local data={}

  for nPlayerID = 0, ( DOTA_MAX_TEAM_PLAYERS - 1 ) do
      if PlayerResource:GetPlayer(nPlayerID) then
      
      if PlayerResource:GetTeam( nPlayerID ) == PlayerResource:GetTeam( playerid ) then
       -- print("data added player:"..nPlayerID)
        table.insert(data,PlayerResource:GetPlayer(nPlayerID))
      end
    end
  end
 -- print("playerid:"..playerid)
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerid),"Player_Inf_Upd_response",data)
end


function vampirism:OnItemPickedUp( event )
  local item = EntIndexToHScript( event.ItemEntityIndex )
  local hero = EntIndexToHScript( event.HeroEntityIndex )

  
  local itemname= event.itemname
    if itemname == "item_gold_coin" or itemname == "item_gold_big_coin" then
      local purchaser = PlayerResource:GetPlayer(GameRules.LeakTable[event.ItemEntityIndex])
    -- local purchaser = item:GetPurchaser()
    local amount = item:GetSpecialValueFor("amount")
      purchaser.leaked = purchaser.leaked + amount
      CustomGameEventManager:Send_ServerToPlayer(player,"player_leak_changed",{pID=GameRules.LeakTable[event.ItemEntityIndex],leaked=purchaser.leaked})
  end
end


function vampirism:SetUpFountains()

  LinkLuaModifier( "modifier_fountain_aura_lua","libraries/modifiers/modifier_fountain_aura_lua", LUA_MODIFIER_MOTION_NONE )
  LinkLuaModifier( "modifier_fountain_aura_effect_lua", "libraries/modifiers/modifier_fountain_aura_effect_lua",LUA_MODIFIER_MOTION_NONE )

  local fountainEntities = Entities:FindAllByClassname( "ent_dota_fountain")
  for _,fountainEnt in pairs( fountainEntities ) do
    --print("fountain unit " .. tostring( fountainEnt ) )
    fountainEnt:AddNewModifier( fountainEnt, fountainEnt, "modifier_fountain_aura_lua", {} )
  end
end

-- Called whenever a player changes its current selection, it keeps a list of entity indexes
function vampirism:OnPlayerSelectedEntities( event )
  local pID = event.pID
  GameRules.SELECTED_UNITS[pID] = event.selected_entities
  -- This is for Building Helper to know which is the currently active builder
  local mainSelected = GetMainSelectedEntity(pID)
  if IsValidEntity(mainSelected) and IsBuilder(mainSelected) then
    local player = PlayerResource:GetPlayer(pID)
    player.activeBuilder = mainSelected
  end
end

-- An entity died
function vampirism:OnEntityKilled( event )
 
    
  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript(event.entindex_killed)
  if killedUnit:GetUnitName() == "ring_ghost" then
    return
  end
  local player = killedUnit:GetOwner() 
  local pID = player:GetPlayerID()
  --corpse
  local posit = killedUnit:GetAbsOrigin()
  if killedUnit:FindAbilityByName("ability_building") then
  -- killedUnit:SetAbsOrigin(Vector(posit.x, posit.y+400, posit.z))
  TechTreeRecursive(killedUnit)
  EmitSoundOnLocationWithCaster(killedUnit:GetAbsOrigin(),"Hero_EarthSpirit.StoneRemnant.Destroy",killedUnit)
  Timers:CreateTimer(0.3,function ()
    UTIL_RemoveImmediate(killedUnit) 
  end)
  end
  -- The Killing entity
  local killerEntity
  if event.entindex_attacker then
    killerEntity = EntIndexToHScript(event.entindex_attacker)
  end

  if  killedUnit:IsNull() then
    return
  end

  if killedUnit:IsCreature() and killerEntity then
       if killerEntity:GetUnitName()=="npc_dota_hero_night_stalker" then
        vampirism:CheckWinCondition()
        RollDrops(killedUnit,killerEntity)
        local playerKiller = killerEntity:GetOwner() 
        

        local ply =PlayerResource:GetPlayer(pID)
        ply.fed=ply.fed+GetUnitKV(killedUnit:GetUnitName(),"BountyGoldMax")
      CustomGameEventManager:Send_ServerToPlayer(ply, "player_fed_changed", {pID=pID,fed=ply.fed})

    CustomGameEventManager:Send_ServerToPlayer(playerKiller, "player_gold_changed", {})
      end
    end

    if killerEntity and killerEntity:GetUnitName()=="npc_dota_hero_night_stalker" then
       if killedUnit:GetUnitName() == "npc_dota_hero_invoker" then
            killerEntity:ModifyGold(15,false,0)
             CustomGameEventManager:Send_ServerToPlayer(killerEntity:GetOwner(), "player_gold_changed", {})
             SendOverheadEventMessage( killerEntity:GetOwner(), OVERHEAD_ALERT_GOLD  , killerEntity, 15, nil )
       end
       local playerKiller = killerEntity:GetOwner() 
       CustomGameEventManager:Send_ServerToPlayer(playerKiller, "player_gold_changed", {})
  end

    if killedUnit:GetUnitName() == "npc_dota_hero_kunkka" then
      vampirism:CheckWinCondition()
      HumanDie(killedUnit)
    end
    if  killedUnit:IsNull() then
    return
  end
    if killedUnit:GetUnitName() == "npc_dota_hero_night_stalker" then
      vampirism:CheckWinCondition()
    end
  --connect check
     --player = CustomNetTables:GetTableValue("ply",tostring(player:GetPlayerID()))
    -- DeepPrintTable(player)
  --Refresh selection unit on death immediately
  local selected_entities= GameRules.SELECTED_UNITS[pID]
  if not killedUnit:IsNull() and (killedUnit:GetUnitName()=="peasant") then
    TreeFree(killedUnit)
    for _,entity in pairs(selected_entities) do
      if entity then
        if not EntIndexToHScript(entity):IsAlive() then
        PlayerResource:RemoveFromSelection(pID,entity)
        print("Entity Remove From MainSelected")
        end
      end
    end

    GameRules.SELECTED_UNITS[pID] = selected_entities
  end
  ----
  if not killedUnit:IsNull() and killedUnit:GetUnitName() == "npc_dota_hero_invoker" then
    
     player.slayer = killedUnit
     player.upgrades["research_slayer_respawn"] = nil

     for _,structure in pairs(player.structures) do
    CheckAbilityRequirements( structure, player )
    end
    
     local ply =PlayerResource:GetPlayer(pID)
        ply.fed=ply.fed+15
      CustomGameEventManager:Send_ServerToPlayer(ply, "player_fed_changed", {pID=pID,fed=ply.fed})

  end
  -- Player owner of the unit

  local player = killedUnit:GetPlayerOwner()

  --Research Stop
  if killedUnit:GetUnitName() == "research_center"   then
    CustomGameEventManager:Send_ServerToPlayer( player, "ResearchStop" ,player)
  end
  if killedUnit:GetUnitName() == "slayers_vault" then
  CustomGameEventManager:Send_ServerToPlayer( player, "ResearchStop" ,player)
  end
  if killedUnit:GetUnitName() == "ultra_research_center" then
  CustomGameEventManager:Send_ServerToPlayer( player, "ResearchStop" ,player)
  end
  -- Building Killed
  if IsCustomBuilding(killedUnit) then

     -- Building Helper grid cleanup
    BuildingHelper:RemoveBuilding(killedUnit, true)

    -- Check units for downgrades
    local building_name = killedUnit:GetUnitName()
        
    -- Substract 1 to the player building tracking table for that name
    if player.buildings[building_name] then
      player.buildings[building_name] = player.buildings[building_name] - 1
    end
    CustomNetTables:SetTableValue( "buildings", tostring(pID),{player.buildings})
    -- if building_name == "tent_1" then
    --  ModifyMaxFood(player,-25)
    -- end
    -- if building_name == "tent_2" then
    --  ModifyMaxFood(player,-55)
    -- end
    -- possible unit downgrades
    for k,units in pairs(player.units) do
        CheckAbilityRequirements( units, player )
    end

    -- possible structure downgrades
    for k,structure in pairs(player.structures) do
      CheckAbilityRequirements( structure, player )
    end

  end
  --[[if killedUnit:GetUnitName() == "peasant" then
      ModifyFood(player,-5)
    end]]
    if killedUnit:GetUnitLabel() == "gatherunit" then
    WorkersDie(player,killedUnit:GetUnitName())
    end
    if  killedUnit:GetUnitLabel() == "vampireminion" then
      VampireMinionsDie(player,killedUnit:GetUnitName())
    end
    if killedUnit:GetUnitName() == "human_surplus" then
      print(killedUnit)
      for key,value in pairs(shops) do
          if killedUnit:GetAbsOrigin() ==value:GetAbsOrigin() then
             UTIL_Remove(value)
            table.remove(shops,key )
        end
      end
    end
  -- Cancel queue of a builder when killed
  if IsBuilder(killedUnit) then
    BuildingHelper:ClearQueue(killedUnit)
  end

  -- Table cleanup
  if player then
    -- Remake the tables
    local table_structures = {}
    for _,building in pairs(player.structures) do
      if building and IsValidEntity(building) and building:IsAlive() then
        --print("Valid building: "..building:GetUnitName())
        table.insert(table_structures, building)
      end
    end
    player.structures = table_structures
    
    local table_units = {}
    for _,unit in pairs(player.units) do
      if unit and IsValidEntity(unit) then
        table.insert(table_units, unit)
      end
    end
    player.units = table_units    
  end
  
  --CustomNetTables:SetTableValue( "ply",tostring(pID),player)
end



function vampirism:OnTradeUISend(keys)
  local playerID = keys.playerID
  local playeridrec = keys.reciverid
  local typeof =keys.type
  local playerreciver = PlayerResource:GetPlayer(playeridrec)
  local unit = keys.heroent
  local player = PlayerResource:GetPlayer(playerID)
  local hero = player:GetAssignedHero()
  local heroreciver = playerreciver:GetAssignedHero()
  local Amount = tonumber(keys.Amount) or 0
  
  if typeof == "gold" then
    if PlayerHasEnoughGold(player,Amount) then
      --print("Trade was succeful")
      CustomGameEventManager:Send_ServerToAllClients("trade_succeful",{Player1=playerID,Player2=playeridrec,amount=Amount,type=typeof})
      --print("pIDreciver"..pIDreciver)
    hero:ModifyGold(-Amount,false,0)
    CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
    heroreciver:ModifyGold(Amount,false,0)
    CustomGameEventManager:Send_ServerToPlayer(heroreciver, "player_gold_changed", {})
    -- SendTradeGoldMessage(playerID,"You send "..Amount.." gold")
    -- ReceiveTradeGoldMessage(playeridrec,"You recieve "..Amount.." gold")
    end
  else
    if PlayerHasEnoughLumber(player,Amount) then
      --print("Trade was succeful")
        CustomGameEventManager:Send_ServerToAllClients("trade_succeful",{Player1=playerID,Player2=playeridrec,amount=Amount,type=typeof})
      --print("pIDreciver"..pIDreciver)
    ModifyLumber(player,-Amount)
    ModifyLumber(playerreciver,Amount)
    -- SendTradeLumberMessage(playerID,"You send "..Amount.." lumber")
    -- ReceiveTradeLumberMessage(playeridrec,"You recieve "..Amount.." lumber")
    end
  end
end


function vampirism:OnBuildUI( keys )
  local playerID = keys.playerID
  local hero = EntIndexToHScript(keys.heroent)
  local unit = keys.heroent
  local buildingnames = keys.buildingname
  --local ent = EntIndexToHScript(hero:GetEntityIndex())
  local player = PlayerResource:GetPlayer(playerID)
    if  hero:FindAbilityByName("build_"..buildingnames) == nil then
      return nil
    end

  local spell = hero:FindAbilityByName("build_"..buildingnames)
  spell:SetHidden(false) 
  ExecuteOrderFromTable({ UnitIndex = unit, OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET, AbilityIndex = spell:GetEntityIndex(), Queue = false})
  --hero:CastAbilityNoTarget(spell,player)
  spell:SetHidden(true) 
  CustomNetTables:SetTableValue( "buildings", tostring(playerID),{player.buildings})
  --CustomNetTables:SetTableValue( "ply",tostring(playerID),player)
  --ModifyLumber(player,5000)
end