function vampirism:FilterExecuteOrder( filterTable )
    --[[
    print("-----------------------------------------")
    for k, v in pairs( filterTable ) do
        print("Order: " .. k .. " " .. tostring(v) )
    end
    ]]

    local units = filterTable["units"]
    local order_type = filterTable["order_type"]
    local issuer = filterTable["issuer_player_id_const"]
    local abilityIndex = filterTable["entindex_ability"]
    local targetIndex = filterTable["entindex_target"]
    local queue = tobool(filterTable["queue"])
    local x = tonumber(filterTable["position_x"])
    local y = tonumber(filterTable["position_y"])
    local z = tonumber(filterTable["position_z"])
    local point = Vector(x,y,z)

    -- Skip Prevents order loops
    local unit = EntIndexToHScript(units["0"])
    if unit and unit.skip then
        unit.skip = false
        return true
    end

    if units then
        for n,unit_index in pairs(units) do
            local unit = EntIndexToHScript(unit_index)
            if unit and IsValidEntity(unit) then
                if not unit:IsBuilding() and not IsCustomBuilding(unit) then

                    -- Set hold position
                    if order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
                        unit.bHold = true
                    end
                end
            end
        end
    end

    ------------------------------------------------
    --           Coin PickUp              --
    ------------------------------------------------
     -- if order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then
     --      local item = EntIndexToHScript(targetIndex)
     --     local item_name = item:GetModelName()
     --     if string.match(item_name,"gold_coin001") then
     --          for key,value in pairs(units) do
     --            local hero = EntIndexToHScript(value)
     --            local name = hero:GetUnitName() 
     --            if name == "npc_dota_hero_night_stalker" then
     --                    hero:MoveToPosition(item:GetAbsOrigin())
     --                    SendErrorMessage(hero:GetPlayerOwnerID(),"#error_you_cant_pick_up_this")
     --                    return false
     --            end
     --          end
     --      end
     --  end

    
    
      ------------------------------------------------
    --           Fel Beast Attack             --
    ------------------------------------------------
    if order_type == DOTA_UNIT_ORDER_ATTACK_MOVE then
            for key,value in pairs(units) do
                local hero = EntIndexToHScript(value)
                local name = hero:GetUnitName() 
                if name == "Fel_Beast" or  name == "Assasin" then
                        SendErrorMessage(hero:GetPlayerOwnerID(),"#cant_attack")
                        return false
                end
            end
    end
     if order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
          local target = EntIndexToHScript(targetIndex)
          
          local item_name = target:GetModelName()
         if not string.match(item_name,"gold_coin001") then
         local target_name = target:GetUnitName()
         end

         if target_name ~= "engineer" then
              for key,value in pairs(units) do
                local hero = EntIndexToHScript(value)
                local name = hero:GetUnitName() 
                if name == "Fel_Beast" then
                        
                        SendErrorMessage(hero:GetPlayerOwnerID(),"#cant_attack")
                        return false
                end
              end
          end
      end

       ------------------------------------------------
    --              Sell Item Orders              --
    ------------------------------------------------
        if order_type == DOTA_UNIT_ORDER_SELL_ITEM then
        
            local item = EntIndexToHScript(filterTable.entindex_ability)
            local item_name = item:GetAbilityName()
            print(unit:GetUnitName().." "..ORDERS[order_type].." "..item_name)

            local player = unit:GetPlayerOwner()
            local playerID = player:GetPlayerID()

            local bool = unit:CanSellItems() and item:IsSellable()
            if bool then
                SellItem(unit, item)
            else
                SendErrorMessage( playerID, "#error_cant_sell" )
            end

            return false
         end
      ------------------------------------------------
    --          Assasin Attack               --
    ------------------------------------------------

     if order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
        

          local target = EntIndexToHScript(targetIndex)

           local item_name = target:GetModelName()
         if not string.match(item_name,"gold_coin001") then
          local target_name = target:GetUnitName()
            end

          local workers = {   "peasant",
                        "furbolg_harvester",
                        "fang_harvester",
                        "fire_spawn_deforester",
                        "satyr_harvester"}
         for key,value in pairs(workers) do               
             if target_name == value then

               return true
              end
         end
                     for key,value in pairs(units) do
                        local hero = EntIndexToHScript(value)
                        local name = hero:GetUnitName() 
                        
                        if name == "Assasin" then
                             SendErrorMessage(hero:GetPlayerOwnerID(),"#cant_attack")
                            return false
                        end
                    end
      end

           ------------------------------------------------
    --          Builder Attack               --
    ------------------------------------------------
     -- if order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
          
     --                 for key,value in pairs(units) do
     --                    local hero = EntIndexToHScript(value)
     --                    local name = hero:GetUnitName() 
     --                    if   name ~="npc_dota_hero_kunkka" then
     --                            return true
     --                    end
                        
     --                    local target = EntIndexToHScript(targetIndex)
     --                     local target_owner = target:GetPlayerOwner()

     --                    if hero:GetPlayerOwner() == target_owner then
     --                        -- if target:IsDeniable() then
                                
     --                        --         Timers:CreateTimer(0.5,function()
     --                        --         --target:SetHealth(1)
     --                        --         local damage_table = {}
     --                        --         damage_table.victim = target
     --                        --         damage_table.attacker = hero                  
     --                        --         damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
     --                        --         damage_table.damage = 500000
     --                        --         ApplyDamage(damage_table)
     --                        --         end)
                               
     --                        -- end
     --                        return true

     --                    else
     --                         SendErrorMessage(hero:GetPlayerOwnerID(),"#cant_attack")
     --                        return false
     --                    end
     --                end
     --  end
    ------------------------------------------------
    --           Ability Multi Order              --
    ------------------------------------------------
    if abilityIndex and abilityIndex ~= 0 and IsMultiOrderAbility(EntIndexToHScript(abilityIndex)) then
        print("Multi Order Ability")

        local ability = EntIndexToHScript(abilityIndex) 
        local abilityName = ability:GetAbilityName()
        local entityList = GetSelectedEntities(unit:GetPlayerOwnerID())
        for _,entityIndex in pairs(entityList) do
            local caster = EntIndexToHScript(entityIndex)
            -- Make sure the original caster unit doesn't cast twice
            if caster and caster ~= unit and caster:HasAbility(abilityName) then
                
                local abil = caster:FindAbilityByName(abilityName)
                if abil and abil:IsFullyCastable() then

                    caster.skip = true
                    if order_type == DOTA_UNIT_ORDER_CAST_POSITION then
                        ExecuteOrderFromTable({ UnitIndex = entityIndex, OrderType = order_type, Position = point, AbilityIndex = abil:GetEntityIndex(), Queue = queue})

                    elseif order_type == DOTA_UNIT_ORDER_CAST_TARGET then
                        ExecuteOrderFromTable({ UnitIndex = entityIndex, OrderType = order_type, TargetIndex = targetIndex, AbilityIndex = abil:GetEntityIndex(), Queue = queue})

                    else --order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET or order_type == DOTA_UNIT_ORDER_CAST_TOGGLE or order_type == DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO
                        ExecuteOrderFromTable({ UnitIndex = entityIndex, OrderType = order_type, AbilityIndex = abil:GetEntityIndex(), Queue = queue})
                    end
                end
            end
        end
        return true

    ------------------------------------------------
    --              ClearQueue Order              --
    ------------------------------------------------
    -- Cancel queue on Stop and Hold
    elseif order_type == DOTA_UNIT_ORDER_STOP or order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
        for n, unit_index in pairs(units) do 
            local unit = EntIndexToHScript(unit_index)
            if IsBuilder(unit) then
                BuildingHelper:ClearQueue(unit)
            end
        end
        return true

    -- Cancel builder queue when casting non building abilities
    elseif (abilityIndex and abilityIndex ~= 0) and IsBuilder(unit) then
        local ability = EntIndexToHScript(abilityIndex)
        --print("ORDER FILTER",ability:GetAbilityName(), IsBuildingAbility(ability))
        if not IsBuildingAbility(ability) then
            BuildingHelper:ClearQueue(unit)
        end
        return true
    end

    return true
end

------------------------------------------------
--             Repair Right-Click             --
------------------------------------------------
function vampirism:RepairOrder( event )
    local pID = event.pID
    local entityIndex = event.mainSelected
    local targetIndex = event.targetIndex
    local building = EntIndexToHScript(targetIndex)
    local selectedEntities = GetSelectedEntities(pID)
    local queue = tobool(event.queue)

    local unit = EntIndexToHScript(entityIndex)
    local repair_ability = unit:FindAbilityByName("repair")

    -- Repair
    if repair_ability and repair_ability:IsFullyCastable() and not repair_ability:IsHidden() then
        ExecuteOrderFromTable({ UnitIndex = entityIndex, OrderType = DOTA_UNIT_ORDER_CAST_TARGET, TargetIndex = targetIndex, AbilityIndex = repair_ability:GetEntityIndex(), Queue = queue})
    end
end

ORDERS = {
    [0] = "DOTA_UNIT_ORDER_NONE",
    [1] = "DOTA_UNIT_ORDER_MOVE_TO_POSITION",
    [2] = "DOTA_UNIT_ORDER_MOVE_TO_TARGET",
    [3] = "DOTA_UNIT_ORDER_ATTACK_MOVE",
    [4] = "DOTA_UNIT_ORDER_ATTACK_TARGET",
    [5] = "DOTA_UNIT_ORDER_CAST_POSITION",
    [6] = "DOTA_UNIT_ORDER_CAST_TARGET",
    [7] = "DOTA_UNIT_ORDER_CAST_TARGET_TREE",
    [8] = "DOTA_UNIT_ORDER_CAST_NO_TARGET",
    [9] = "DOTA_UNIT_ORDER_CAST_TOGGLE",
    [10] = "DOTA_UNIT_ORDER_HOLD_POSITION",
    [11] = "DOTA_UNIT_ORDER_TRAIN_ABILITY",
    [12] = "DOTA_UNIT_ORDER_DROP_ITEM",
    [13] = "DOTA_UNIT_ORDER_GIVE_ITEM",
    [14] = "DOTA_UNIT_ORDER_PICKUP_ITEM",
    [15] = "DOTA_UNIT_ORDER_PICKUP_RUNE",
    [16] = "DOTA_UNIT_ORDER_PURCHASE_ITEM",
    [17] = "DOTA_UNIT_ORDER_SELL_ITEM",
    [18] = "DOTA_UNIT_ORDER_DISASSEMBLE_ITEM",
    [19] = "DOTA_UNIT_ORDER_MOVE_ITEM",
    [20] = "DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO",
    [21] = "DOTA_UNIT_ORDER_STOP",
    [22] = "DOTA_UNIT_ORDER_TAUNT",
    [23] = "DOTA_UNIT_ORDER_BUYBACK",
    [24] = "DOTA_UNIT_ORDER_GLYPH",
    [25] = "DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH",
    [26] = "DOTA_UNIT_ORDER_CAST_RUNE",
    [27] = "DOTA_UNIT_ORDER_PING_ABILITY",
    [28] = "DOTA_UNIT_ORDER_MOVE_TO_DIRECTION",
}