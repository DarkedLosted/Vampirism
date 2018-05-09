------------------------------------------
--             Build Scripts
------------------------------------------

-- A build ability is used (not yet confirmed)
-- function dump(data )
-- 	return json.encode(data)
-- end
function Build( event )
-- local request = CreateHTTPRequestScriptVM( "POST", "http://vampirismreborn.000webhostapp.com/Stats/test.txt" )
-- local encoded = dump(PlayerResource:GetPlayerName(0))
-- request:SetHTTPRequestGetOrPostParameter('test',encoded)

-- request:Send( function( result )
-- 	print( "GET response:\n" )
-- 	if result.StatusCode ~= 200 or not result.Body then
--             print("[Rewards] Failed to contact rewards server.")
--              DeepPrintTable(result)
--             return
--         end

-- 	-- Try to decode the result
--         local obj, pos, err = json.decode(result.Body, 1, nil)

--         -- Process the result
--         if err then
--             print("Error in response : " .. err)
            
--         end
--           if obj == nil then
-- 		      obj = result.Body
-- 		  end
-- 		  print(result.Body)
-- 		  print(dump(result.Body))
-- 	-- for k,v in pairs( result ) do
-- 	-- 	print( string.format( "%s : %s\n", k, v ) )
-- 	-- 	PrintTable(v)
-- 	-- end
-- 	print( "Done." )
-- end )

	
	

    local caster = event.caster
    local ability = event.ability
    local ability_name = ability:GetAbilityName()
    local building_name = ability:GetAbilityKeyValues()['UnitName']
    local gold_cost = ability:GetGoldCost(1) 
	local lumber_cost = ability:GetSpecialValueFor("lumber_cost")
    local hero = caster:IsRealHero() and caster or caster:GetOwner()
    local playerID = hero:GetPlayerID()
    local player = PlayerResource:GetPlayer(playerID)	
    
      if caster:IsIdle() then
        caster:Stop()
    end

  -- FireGameEvent("dota_player_kill",{target=1,message="sdf"})
	
    -- If the ability has an AbilityGoldCost, it's impossible to not have enough gold the first time it's cast
    -- Always refund the gold here, as the building hasn't been placed yet
    hero:ModifyGold(gold_cost, false, 0)
    CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
    -- Makes a building dummy and starts panorama ghosting
    BuildingHelper:AddBuilding(event)

    -- Additional checks to confirm a valid building position can be performed here
    event:OnPreConstruction(function(vPos)

        -- Check for minimum height if defined
        if not BuildingHelper:MeetsHeightCondition(vPos) then
            BuildingHelper:print("Failed placement of " .. building_name .." - Placement is below the min height required")
            SendErrorMessage(playerID, "#error_invalid_build_position")
            return false
        end

        -- If not enough resources to queue, stop
        if PlayerResource:GetGold(playerID) < gold_cost then
            BuildingHelper:print("Failed placement of " .. building_name .." - Not enough gold!")
            SendErrorMessage(playerID, "#error_not_enough_gold")
            return false
        end

        if player.lumber < lumber_cost then
            BuildingHelper:print("Failed placement of " .. building_name .." - Not enough lumber!")
            SendErrorMessage(playerID, "#error_not_enough_lumber")
            return false
        end

        if caster:GetTeamNumber() == 3 then
	        if not caster.lastBuildTime then
	        	caster.lastBuildTime = GameRules:GetDOTATime(false,false)
	        	return true
	        else
	        	if caster.lastBuildTime == GameRules:GetDOTATime(false,false) then
	        		caster.lastBuildTime = nil
	        		return false
	        	end
	        end
 		end
 		
        return true
    end)

    -- Position for a building was confirmed and valid
    event:OnBuildingPosChosen(function(vPos)
        -- Spend resources      			
        hero:ModifyGold(-gold_cost, false, 0)
        CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
        ModifyLumber( player, -lumber_cost)
        
        -- Play a sound
        EmitSoundOnClient("DOTA_Item.ObserverWard.Activate", PlayerResource:GetPlayer(playerID))
      
    end)
    
    -- The construction failed and was never confirmed due to the gridnav being blocked in the attempted area
    event:OnConstructionFailed(function()
        local playerTable = BuildingHelper:GetPlayerTable(playerID)
        local building_name = playerTable.activeBuilding

        BuildingHelper:print("Failed placement of " .. building_name)
    end)

    -- Cancelled due to ClearQueue
    event:OnConstructionCancelled(function(work)
        local building_name = work.name
        BuildingHelper:print("Cancelled construction of " .. building_name)

        -- Refund resources for this cancelled work
        if work.refund then
            hero:ModifyGold(gold_cost, false, 0)
            CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
            ModifyLumber( player, lumber_cost)
        end
    end)

    -- A building unit was created
    event:OnConstructionStarted(function(unit)
        BuildingHelper:print("Started construction of " .. unit:GetUnitName() .. " " .. unit:GetEntityIndex())
        -- Play construction sound
          unit:AddNewModifier(unit, nil, "modifier_attack_disabled", {})
           unit:AddNewModifier(unit, nil, "modifier_pre_build", {})
          
       -- unit:AddNewModifier(nil, nil, "modifier_stunn", {})
        -- If it's an item-ability and has charges, remove a charge or remove the item if no charges left
        if ability.GetCurrentCharges and not ability:IsPermanent() then
            local charges = ability:GetCurrentCharges()
            charges = charges-1
            if charges == 0 then
            	CustomGameEventManager:Send_ServerToPlayer( player, "building_helper_end", player )
                ability:RemoveSelf()
            else
                ability:SetCurrentCharges(charges)
            end
        end

        -- Units can't attack while building
        unit.original_attack = unit:GetAttackCapability()
        unit:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)

        -- Give item to cancel
        unit.item_building_cancel = CreateItem("item_building_cancel", hero, hero)
        if unit.item_building_cancel then 
            unit:AddItem(unit.item_building_cancel)
            unit.gold_cost = gold_cost
        end

        -- FindClearSpace for the builder
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
        caster:AddNewModifier(caster, nil, "modifier_phased", {duration=0.03})

        -- Remove invulnerability on npc_dota_building baseclass
        unit:RemoveModifierByName("modifier_invulnerable")

     --[[]]   -- Check the abilities of this building, disabling those that don't meet the requirements
    	CheckAbilityRequirements( unit, player )

		-- Add the building handle to the list of structures
		
		table.insert(player.structures, unit)
    end)

    -- A building finished construction
    event:OnConstructionCompleted(function(unit)
        BuildingHelper:print("Completed construction of " .. unit:GetUnitName() .. " " .. unit:GetEntityIndex())
        
        -- Play construction complete sound
         unit:RemoveModifierByName("modifier_attack_disabled")
         unit:RemoveModifierByName("modifier_pre_build")
         
                 --Grave Fix
        if unit:GetUnitName()== "vampiric_grave" then
         unit:AddAbility("vampire_grave_ability")
         local abil = unit:FindAbilityByName("vampire_grave_ability")
         abil:SetLevel(abil:GetMaxLevel())
     	end
       -- unit:RemoveModifierByName("modifier_stunn")
        -- Remove item_building_cancel
        for i=0,5 do
            local item = unit:GetItemInSlot(i)
            if item then
            	if item:GetAbilityName() == "item_building_cancel" then
            		item:RemoveSelf()
                end
            end
        end

        local building_name = unit:GetUnitName()
		local builders = {}
		if unit.builder then
			table.insert(builders, unit.builder)
		elseif unit.units_repairing then
			builders = unit.units_repairing
		end

		-- Add 1 to the player building tracking table for that name
		if not player.buildings[building_name] then
			player.buildings[building_name] = 1
		else
			player.buildings[building_name] = player.buildings[building_name] + 1
		end

        -- Custom functions
        CustomNetTables:SetTableValue( "buildings", tostring(playerID),{player.buildings})
       -- CustomNetTables:SetTableValue( "ply", tostring(playerID),{buildings=player.buildings})
      
		-- if building_name == "tent_1" then
		-- 	ModifyMaxFood(player,25)
		-- end

		if  player.upgrades["research_wall_quality"] == 1 then 
				if unit:GetUnitName() == "Carnelian_wall" then
						
						local research = CustomNetTables:GetTableValue("upgrades","research_wall_quality")
						local towername  = research["abilitylevel"]
						local lvl = towername.lvl
						local health = unit:GetMaxHealth()+(unit:GetBaseMaxHealth()/100*(20*lvl))
						unit:SetMaxHealth(health)
						unit:SetHealth(health)
				end	
		end
		if player.upgrades["research_infrastructure"] == 1 then
			if unit:GetUnitName() == "research_center" then
			unit:SetMaxHealth(unit:GetBaseMaxHealth()+300)
			unit:SetHealth(unit:GetBaseMaxHealth()+300)
			end
			if unit:GetUnitName() == "slayer_tavern" then
			unit:SetMaxHealth(unit:GetBaseMaxHealth()+300)
			unit:SetHealth(unit:GetBaseMaxHealth()+300)
			end
		end
		if  player.upgrades["research_iron_plate"] == 1 then 
				if unit:GetUnitName() == "Carnelian_wall" then
						local research = CustomNetTables:GetTableValue("upgrades","research_iron_plate")
						
						local towername  = research[unit:GetUnitName()]
						local armor = towername.PhysicalArmorBaseValue
						unit:SetPhysicalArmorBaseValue(armor+(towername.armor*research["abilitylevel"].lvl))
				end	
		end
		
		if  player.upgrades["research_mana_regeneration"] == 1 then 
				if unit:GetUnitName() == "wall_of_health" then
						local abil = unit:AddAbility("mana_regeneration")
						abil:SetLevel(abil:GetMaxLevel())
				end	
		end

		if  player.upgrades["research_tower_of_health"] == 1 then 
				if unit:GetUnitName() == "wall_of_health" then
						local research = CustomNetTables:GetTableValue("upgrades","research_tower_of_health")
						local towername  = research[unit:GetUnitName()]
						local health = towername.Health
						unit:SetMaxHealth(health)
						unit:SetHealth(health)

				end	
		end

		if unit:GetUnitName() == "human_surplus" then
			local shopEnt = Entities:FindByName(nil, "trigger_surplus") -- entity name in hammer
			local shop = SpawnEntityFromTableSynchronous('trigger_shop', {origin = unit:GetAbsOrigin(), shoptype = 1, model=shopEnt:GetModelName()})
			table.insert(shops,shop)
			--PrintTable(shops)
			DeepPrintTable(shopEntAct)
		end	

		if unit:GetUnitName() == "super_gold_mine" then
			unit:SetRenderColor(3,255 ,3 )
		end
		if unit:GetUnitName() == "ultra_gold_mine" then
			unit:SetRenderColor(255,3 ,3 )
		end
		if unit:GetUnitName() == "elite_gold_mine" then
			unit:SetRenderColor(255,227 , 66)
		end
		
        -- Remove the item
        if unit.item_building_cancel then
            UTIL_Remove(unit.item_building_cancel)
        end

        -- Give the unit their original attack capability
        unit:SetAttackCapability(unit.original_attack)


		-- Update the abilities of the builders and buildings
    	for k,units in pairs(player.units) do
    		CheckAbilityRequirements( units, player )
    	end

    	for k,structure in pairs(player.structures) do
    		CheckAbilityRequirements( structure, player )

    	end

    end)

    -- These callbacks will only fire when the state between below half health/above half health changes.
    -- i.e. it won't fire multiple times unnecessarily.
    event:OnBelowHalfHealth(function(unit)
        BuildingHelper:print(unit:GetUnitName() .. " is below half health.")
        local ability = unit:FindAbilityByName("ability_building")
       -- ability:ApplyDataDrivenModifier(unit, unit, "modifier_onfire", {})
         ApplyModifier(unit, "modifier_onfire")
    end)

    event:OnAboveHalfHealth(function(unit)
        BuildingHelper:print(unit:GetUnitName().. " is above half health.")  
        unit:RemoveModifierByName("modifier_onfire")      
    end)
end



function CancelBuilding( keys )
    local building = keys.unit
    local hero = building:GetOwner()
    local playerID = building:GetPlayerOwnerID()

    BuildingHelper:print("CancelBuilding "..building:GetUnitName().." "..building:GetEntityIndex())

    -- Refund here
    if building.gold_cost then
        hero:ModifyGold(building.gold_cost, false, 0)
        CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
    end

    -- Eject builder
    local builder = building.builder_inside
    if builder then
        BuildingHelper:ShowBuilder(builder)
    end

    building:ForceKill(true) --This will call RemoveBuilding
end


function SendErrorMessage( pID, string )
    Notifications:ClearBottom(pID)
    Notifications:Bottom(pID, {text=string, style={color='#E62020'}, duration=2})
    EmitSoundOnClient("General.Cancel", PlayerResource:GetPlayer(pID))
end
--------------------------------
--       Repair Scripts       --
--------------------------------
function RepairCheck ( event )
	local caster = event.caster
	local ability = event.ability
	if not ability:GetAutoCastState() then
		return
	end
	local buildingArr = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_FARTHEST, false)
	--buildingArr = SortListByClosest(buildingArr,caster:GetAbsOrigin())
	buildingArr=SortListByPriority(buildingArr,caster:GetAbsOrigin())
	for k,v in pairs(buildingArr) do
		if IsCustomBuilding(v) and v:GetHealthDeficit() > 0 and caster.state ~= "repairing" then
			caster:CastAbilityOnTarget(v,ability,caster:GetPlayerID())
		end
	end
	
end
-- Start moving to repair
function RepairStart( event )

	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local target_class = target:GetClassname()
	local player = caster:GetPlayerOwner()

	caster:Interrupt() -- Stops any instance of Hold/Stop the builder might have

	-- Possible states
		-- moving_to_repair
		-- moving_to_build (set on Building Helper when a build queue advances)
		-- repairing
		-- idle

	-- Repair Building / Siege
	if target_class == "npc_dota_creature" then
		if IsCustomBuilding(target) and target:GetHealthDeficit() > 0  and not target:HasModifier("modifier_burst_gem") then

			--ability:SetChanneling(true)

			caster.repair_target = target
			player.target_repair = target
			local target_pos = target:GetAbsOrigin()
			
			ability.cancelled = false
			caster.state = "moving_to_repair"

			-- Destroy any old move timer
			if caster.moving_timer then
				Timers:RemoveTimer(caster.moving_timer)
			end

			-- Fake toggle the ability, cancel if any other order is given
			if ability:GetToggleState() == false then
				ability:ToggleAbility()
			end

			-- Recieving another order will cancel this
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_on_order_cancel_repair", {})

			local collision_size = GetCollisionSize(target)*2 + 64

			caster.moving_timer = Timers:CreateTimer(function()

				-- End if killed
				if not (caster and IsValidEntity(caster) and caster:IsAlive()) then
					return
				end

				-- Move towards the target until close range
				if not ability.cancelled and caster.state == "moving_to_repair" then
					if caster.repair_target and IsValidEntity(caster.repair_target) then
						local distance = (target_pos - caster:GetAbsOrigin()):Length()
						
						if distance > collision_size then
							caster:MoveToNPC(target)
							return 0.1 --THINK_INTERVAL
						else
                            --print("Reached target, starting the Repair process")
                            -- Must refresh the modifier to make sure the OnCreated is executed
                            if caster:HasModifier("modifier_builder_repairing") then
                                caster:RemoveModifierByName("modifier_builder_repairing")
                            end
                            Timers:CreateTimer(function()
								ability:ApplyDataDrivenModifier(caster, caster, "modifier_builder_repairing", {})
							end)
							return
						end
					else
						print("Building was killed in the way of a builder to repair it")
						caster:RemoveModifierByName("modifier_on_order_cancel_repair")
						CancelGather(event)
					end
				else
					return
				end
			end)
		else
			print("Not a valid repairable unit or already on full health")
		end
	else
		print("Not a valid target for this ability")
		caster:Stop()
	end
end

-- Toggles Off Move to Repair
function CancelRepair( event )
	
	local caster = event.caster
	local ability = event.ability
	
	local ability_order = event.event_ability
	if ability_order then
		local order_name = ability_order:GetAbilityName()
		--print("CancelGather Order: "..order_name)
		if string.match(order_name,"build_") then
			--print(" return")
			return
		end
	end

	ability.cancelled = true
	caster.state = "idle"
	
	ToggleOff(ability)
end

-- Repair Ratios
-- Repair Cost Ratio = 0.35 - Takes 105g to fully repair a building that costs 300. Also applies to lumber
-- Repair Time Ratio = 1.5 - Takes 150 seconds to fully repair a building that took 100seconds to build
-- Builders can assist the construction with multiple peasants
-- In that case, extra resources are consumed, and they add up for every extra builder repairing the same building
-- Powerbuild Rate = 0.60 - Fastens the ratio by 60%
function Repair( event )
	

	local caster = event.caster -- The builder
	local ability = event.ability
	local building = event.target -- The building to repair

	if not building:IsAlive() or not caster:IsAlive()  then
		BuilderStopRepairing(event)
	end

	local player = caster:GetPlayerOwner()
	local hero = player:GetAssignedHero()
	local pID = hero:GetPlayerID()

	local building_name = building:GetUnitName()
	local gold_cost = building.GoldCost
	local lumber_cost = building.LumberCost
	local build_time = building:GetKeyValue("BuildTime")
	if not build_time then
		build_time = 20
	end

	local repairpower=0

	if string.match(building_name,"Wall_") then
	 repairpower = building:GetKeyValue("RepairPower")

	end

	local state = building.state -- "completed" or "building"
	local health_deficit = building:GetHealthDeficit()

	ToggleOn(ability)
	
	-- If its an unfinished building, keep track of how much does it require to mark as finished
	if not building.constructionCompleted and not building.health_deficit then
		building.missingHealthToComplete = health_deficit

	end

	-- Scale costs/time according to the stack count of builders reparing this
	if health_deficit > 0 and building:IsAlive() then
		-- Initialize the tracking
		if not building.health_deficit then
			building.health_deficit = health_deficit
			building.gold_used = 0
			building.lumber_used = 0
			building.HPAdjustment = 0
			building.GoldAdjustment = 0
			building.time_started = GameRules:GetGameTime()
		end
		
		local stack_count = building:GetModifierStackCount( "modifier_repairing_building", ability )

		-- HP
		local health_per_second=20

		if stack_count > 1 then
			 
			 if string.match(building_name,"Wall_") then
			 health_per_second = (repairpower *(stack_count*0.6))/5
			else
			 health_per_second = (building:GetMaxHealth() /  ( build_time * 1.5 ) * (stack_count*0.75) )/5
			end
		else
			if string.match(building_name,"Wall_") then

			 health_per_second = repairpower/5
			-- print("health_per_second:"..health_per_second)
			else
			 health_per_second = (building:GetMaxHealth() /  ( build_time * 1.5 ) * stack_count)/5
			end
		end
		--local health_per_second = (building:GetMaxHealth() / 100)* 0.5 * stack_count
		
		local health_float = health_per_second - math.floor(health_per_second) -- floating point component
		health_per_second = math.floor(health_per_second) -- round down

		-- Don't expend resources for the first peasant repairing the building if its a construction
		if not building.constructionCompleted then
			stack_count = stack_count - 1
		end

		-- Gold
		local gold_per_second = 0--gold_cost / ( build_time * 1.5 ) * 0.35 * stack_count
		local gold_float = 0--gold_per_second - math.floor(gold_per_second) -- floating point component
		gold_per_second = 0--math.floor(gold_per_second) -- round down

		-- Lumber takes floats just fine
		local lumber_per_second = 0--lumber_cost / ( build_time * 1.5 ) * 0.35 * stack_count

		--[[print("Building is repaired for "..health_per_second)
		if gold_per_second > 0 then
			print("Cost is "..gold_per_second.." gold and "..lumber_per_second.." lumber per second")
		else
			print("Cost is "..gold_float.." gold and "..lumber_per_second.." lumber per second")
		end]]
			
		local healthGain = 0
		if PlayerHasEnoughGold( player, math.ceil(gold_per_second+gold_float) ) and PlayerHasEnoughLumber( player, lumber_per_second ) then
			-- Health
			building.HPAdjustment = building.HPAdjustment + health_float
			if building.HPAdjustment > 1 then
				healthGain = health_per_second + 1
				building:SetHealth(building:GetHealth() + healthGain)
				building.HPAdjustment = building.HPAdjustment - 1
			else
				healthGain = health_per_second
				building:SetHealth(building:GetHealth() + health_per_second)
			end
			
			-- Consume Resources
			building.GoldAdjustment = building.GoldAdjustment + gold_float
			if building.GoldAdjustment > 1 then
				hero:ModifyGold( -gold_per_second - 1, false, 0)
				CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
				building.GoldAdjustment = building.GoldAdjustment - 1
				building.gold_used = building.gold_used + gold_per_second + 1
			else
				hero:ModifyGold( -gold_per_second, false, 0)
				CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
				building.gold_used = building.gold_used + gold_per_second
			end
			
			ModifyLumber( player, -lumber_per_second )
			building.lumber_used = building.lumber_used + lumber_per_second
		else
			-- Remove the modifiers on the building and the builders
			building:RemoveModifierByName("modifier_repairing_building")
			for _,builder in pairs(building.units_repairing) do
				if builder and IsValidEntity(builder) then
					builder:RemoveModifierByName("modifier_builder_repairing")
				end
			end
			--print("Repair Ended, not enough resources!")
			building.health_deficit = nil
			building.missingHealthToComplete = nil

			-- Toggle off
			ToggleOff(ability)
		end

		-- Decrease the health left to finish construction and mark building as complete
		if building.missingHealthToComplete then
			building.missingHealthToComplete = building.missingHealthToComplete - healthGain
		end

	-- Building Fully Healed
	else
		-- Remove the modifiers on the building and the builders
		building:RemoveModifierByName("modifier_repairing_building")
		for _,builder in pairs(building.units_repairing) do
			if builder and IsValidEntity(builder) then
				builder:RemoveModifierByName("modifier_builder_repairing")
				builder.state = "idle"

				--This should only be done to the additional assisting builders, not the main one that started the construction
				if not builder.work then
                	BuildingHelper:AdvanceQueue(builder)
                end
			end
		end
		-- Toggle off
		ToggleOff(ability)

		print("Repair End")
		--print("Start HP/Gold/Lumber/Time: ", building.health_deficit, gold_cost, lumber_cost, build_time)
		--print("Final HP/Gold/Lumber/Time: ", building:GetHealth(), building.gold_used, math.floor(building.lumber_used), GameRules:GetGameTime() - building.time_started)
		building.health_deficit = nil
	end

	-- Construction Ended
	if building.missingHealthToComplete and building.missingHealthToComplete <= 0 then
		building.missingHealthToComplete = nil
		building.constructionCompleted = true -- BuildingHelper will track this and know the building ended
	else
		--print("Missing Health to Complete building: ",building.missingHealthToComplete)
	end
end

function BuilderRepairing( event )

	local caster = event.caster
	local ability = event.ability
	local player = caster:GetPlayerOwner()
	local target = player.target_repair

    print("Builder Repairing ",target:GetUnitName())
	
	caster.state = "repairing"

	-- Apply a modifier stack to the building, to show how many peasants are working on it (and scale the Powerbuild costs)
	local modifierName = "modifier_repairing_building"
	if target:HasModifier(modifierName) then
		target:SetModifierStackCount( modifierName, ability, target:GetModifierStackCount( modifierName, ability ) + 1 )
	else
		ability:ApplyDataDrivenModifier( caster, target, modifierName, { Duration = duration } )
		target:SetModifierStackCount( modifierName, ability, 1 )
	end

	-- Keep a list of the units repairing this building
	if not target.units_repairing then
		target.units_repairing = {}
		table.insert(target.units_repairing, caster)
	else
		table.insert(target.units_repairing, caster)
	end

end

function BuilderStopRepairing( event )
	
	local caster = event.caster
	local ability = event.ability
	local player = caster:GetPlayerOwner()
	local building = player.target_repair
	


	local ability_order = event.event_ability
	if ability_order then
		local order_name = ability_order:GetAbilityName()
		if string.match(order_name,"build_") then
			return
		end
	end
	
	caster:RemoveModifierByName("modifier_on_order_cancel_repair")
	caster:RemoveModifierByName("modifier_builder_repairing")
	caster:RemoveGesture(ACT_DOTA_ATTACK)

	caster.state = "idle"

	-- Apply a modifier stack to the building, to show how many builders are working on it (and scale the Powerbuild costs)
	local modifierName = "modifier_repairing_building"

	if building and IsValidEntity(building) and building:HasModifier(modifierName) then
	
		local current_stack = building:GetModifierStackCount( modifierName, ability )
		if current_stack > 1 then
			building:SetModifierStackCount( modifierName, ability, current_stack - 1 )
			
		else
			building:RemoveModifierByName( modifierName )
		end
	end

	-- Remove the builder from the list of units repairing the building
	local builder = getIndex(building.units_repairing, caster)
	if builder and builder ~= -1 then
		table.remove(building.units_repairing, builder)
	end
end

function RepairAnimation( event )
	local caster = event.caster
	local player = caster:GetPlayerOwner()
	local building = player.target_repair

	if not building:IsAlive() then
		BuilderStopRepairing( event )
	end

	caster:StartGesture(ACT_DOTA_ATTACK)
end

