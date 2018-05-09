require('libraries/timers')

tree_target = nil
LinkLuaModifier("modifier_no_collision", "libraries/modifiers/modifier_no_collision", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_attack_trees", "libraries/modifiers/modifier_attack_trees", LUA_MODIFIER_MOTION_NONE)
print("Gather Start")

function Gather( event  )

 	function ReturnResources( event )
		--print("Debug string from ReturnResources")
			local caster =  event.caster
			local ability = event.ability
			--print("Return Resources")
			-- LUMBER
			
				if caster.lumber_gathered and caster.lumber_gathered > 0 then
						caster:SetNoCollision(true)
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_returning_resources", {})
					--print("Debug string 2")
					-- Find where to return the resources
					local building = CDOTA_BaseNPC:FindClosestResourceDeposit(caster) 
					--print("Returning "..caster.lumber_gathered.." Lumber back to "..building:GetUnitName())
				
					-- Set On, Wait one frame, as OnOrder gets executed before this is applied.
					Timers:CreateTimer(0.03, function() 
						if ability:GetToggleState() == false then
							ability:ToggleAbility()
							
							--print("Return Ability Toggled On")
						end
					end)

					if building then
					ExecuteOrderFromTable({ UnitIndex = caster:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET, TargetIndex = building:GetEntityIndex(), Position = building:GetAbsOrigin(), Queue = false}) 
					caster.target_building = building
					end

				end
	end
			
			-- local test = FindClosesttarget(event)
			local caster = event.caster
			if GridNav:GetAllTreesAroundPoint(caster:GetAbsOrigin() ,1000,true) == nil then
			 SendErrorMessage((event.caster:GetPlayerOwner()):GetPlayerID(), "#Cant find tree near")
			return 0
			end
				
				--local target =  caster.targetindex or test
				local ability = event.ability
				--local target_class = target:GetClassname()
				local target_position 
				--print(target)
				--print("Gather OnAbilityPhaseStart")
				-- Initialize variable to keep track of how much resource is the unit carrying
				if not caster.lumber_gathered then
					caster.lumber_gathered = 0
				end
			-- Intialize the variable to stop the return (workaround for ExecuteFromOrder being good and MoveToNPC now working after a Stop)
				caster.manual_order = false
				-- Gather Lumber
				--if target_class == "ent_dota_tree" then
					--print("Moving to ", target_class)
					if caster.target_tree == nil then
						local test = FindClosesttarget(event)
					caster.target_tree = caster.targetindex or test
						if caster.target_tree then
						target_position= caster.target_tree:GetAbsOrigin() 
						end
					end
					--[[if caster.target_tree and (caster.target_tree:GetAbsOrigin() - caster:GetAbsOrigin() ):Length() > 400 then
						caster.target_tree = FindClosesttarget(event)
						target_position= caster.target_tree:GetAbsOrigin() 
						print("tttttt")
					end]]
					if caster.targetindex then
						caster.target_tree= caster.targetindex 
						target_position= caster.target_tree:GetAbsOrigin() 
						
					end

					--[[Timers:CreateTimer(2, function() 
					
						local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length()
						local collision = distance > 155
						if collision then
							caster.target_tree = FindClosesttarget(event)
						print(collision)
						end
					end)]]
						
					ability:ApplyDataDrivenModifier(caster, caster, "modifier_gathering_lumber", {})
					
					caster:SetNoCollision(true)
					-- Visual fake toggle
					if ability:GetToggleState() == false then
						ability:ToggleAbility()
					end

					-- Hide Return
					local return_ability = caster:FindAbilityByName("peasant_return_resources")
					return_ability:SetHidden(true)
					ability:SetHidden(false)
					--print("Gathering Lumber ON, Return OFF")
					-- Visual fake toggle
						if ability:GetToggleState() == false then
							ability:ToggleAbility()

						end

						-- Hide Return
					--	local return_ability = caster:FindAbilityByName("peasant_return_resources")
					--	return_ability:SetHidden(true)
						--ability:SetHidden(false)
						--print("Gathering Lumber ON, Return OFF")
				--end
			end
		
	-- Toggles Off Gather
		function ToggleOffGather( event )
			local caster = event.caster
			local gather_ability = caster:FindAbilityByName("peasant_gather")

			if gather_ability:GetToggleState() == true then
				gather_ability:ToggleAbility()
				caster:SetNoCollision(false)

			--[[	if caster.target_tree.worker  then
				print("target tree before off:"..caster.target_tree.worker)
				caster.target_tree.worker = caster.target_tree.worker -1
				print("target tree off:"..caster.target_tree.worker)
				end]]

				--print("Toggled Off Gather")
			end

		end

		-- Toggles Off Return because of an order (e.g. Stop)
		function ToggleOffReturn( event )
			local caster = event.caster
			local return_ability = caster:FindAbilityByName("peasant_return_resources")

			if return_ability:GetToggleState() == true then 
				return_ability:ToggleAbility()
				--print("Toggled Off Return")
			end
		end


		function CheckTreePosition( event )
		
			local caster = event.caster
				if not caster.target_tree then
				return
				end

			local ability = event.ability
			local target = caster.target_tree -- Index tree so we know which target to start with

			local target_class = target:GetClassname()

			if target_class == "ent_dota_tree" then
				caster:MoveToTargetToAttack(target)
				--print("Moving to "..target_class)
			end

			local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length()
			local collision = distance < 150

			if not collision then
				--print("Moving to tree, distance: ",distance)
			elseif not caster:HasModifier("modifier_chopping_wood") then
				caster:SetNoCollision(false)
				caster:RemoveModifierByName("modifier_gathering_lumber")
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_chopping_wood", {})
				--print("Reached tree")
			end
		end





		function Gather1Lumber( event )
			
			local caster = event.caster
			local ability = event.ability
			local player = caster:GetPlayerOwner()
			local max_lumber_carried = 10
			local lumber_per_hit = 1

			--- Upgraded on LumberResearchComplete
			if player.LumberCarried and not  caster:IsNull() and caster:GetUnitName()=="peasant" then 
				max_lumber_carried = player.LumberCarried
				--print("player.LumberCarried:"..player.LumberCarried)
			end
			if caster:GetUnitName() == "furbolg_harvester" then
				max_lumber_carried=5
			end
			local return_ability = caster:FindAbilityByName("peasant_return_resources")
			caster.gather_cap = max_lumber_carried
			caster.lumber_gathered = caster.lumber_gathered + lumber_per_hit
		
			--print("Gathered "..caster.lumber_gathered)

			-- Show the stack of resources that the unit is carrying
			if not caster:HasModifier("modifier_returning_resources") then
		        return_ability:ApplyDataDrivenModifier( caster, caster, "modifier_returning_resources", nil)
		    end
		    caster:SetModifierStackCount("modifier_returning_resources", caster, caster.lumber_gathered)
		 
			-- Increase up to the max, or cancel
			if caster.lumber_gathered < max_lumber_carried then

				-- Fake Toggle the Return ability
				if return_ability:GetToggleState() == false or return_ability:IsHidden() then
					--print("Gather OFF, Return ON")
					return_ability:SetHidden(false)
					if return_ability:GetToggleState() == false then
						return_ability:ToggleAbility()
					end
					ability:SetHidden(true)
				end
			else
				local player = caster:GetOwner():GetPlayerID()
				caster:RemoveModifierByName("modifier_chopping_wood")

				-- Return Ability On		
				caster:CastAbilityNoTarget(return_ability, player)
				return_ability:ToggleAbility()
			end
		end

		

		
	


-- Aux to find resource deposit
		


		
		function CheckBuildingPosition( event )

		local caster = event.caster
		local ability = event.ability

		if not caster.target_building or not IsValidEntity(caster.target_building) then
			-- Find where to return the resources
			caster.target_building = CDOTA_BaseNPC:FindClosestResourceDeposit( caster )
			if caster.target_building then
				--print("Resource delivery position set to "..caster.target_building:GetUnitName())
			else
				--print("ERROR finding the closest resource deposit")
				return
			end
		end

		local target = caster.target_building

		local distance = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length()
		local collision = distance <= (target:GetHullRadius()+110)
		if not collision then
			--print("Moving to building, distance: ",distance)
		else

			local hero = caster:GetOwner()
			local player = caster:GetPlayerOwner()
			local pID = hero:GetPlayerID()

			local returned_type = nil

		

			if not caster:IsNull() and caster.lumber_gathered and caster.lumber_gathered > caster.gather_cap-1 then
				--print("Reached building, give resources")
			
				caster:RemoveModifierByName("modifier_returning_resources")
				--print("Removed modifier_returning_resources")
				if caster:GetUnitName() == "furbolg_harvester" then
					ModifyLumber(player, caster.lumber_gathered*20)
					PopupLumber(caster, caster.lumber_gathered*20)
					elseif caster:GetUnitName() == "fang_harvester" then
					ModifyLumber(player, caster.lumber_gathered*200)
					PopupLumber(caster, caster.lumber_gathered*200)
					elseif caster:GetUnitName() == "fire_spawn_deforester" then
					ModifyLumber(player, caster.lumber_gathered*800)
					PopupLumber(caster, caster.lumber_gathered*800)
					elseif caster:GetUnitName() == "satyr_harvester" then
					ModifyLumber(player, caster.lumber_gathered*4000)
					PopupLumber(caster, caster.lumber_gathered*4000)
		    		else
		    		ModifyLumber(player, caster.lumber_gathered)
		    		PopupLumber(caster, caster.lumber_gathered)
		    	end

				caster.lumber_gathered = 0

				returned_type = "lumber"
	
			
			end
			
			-- if caster.lumber_gathered and  caster:GetUnitName() == "peasant" and caster.lumber_gathered > player.LumberCarried-1 then
			-- 		caster:RemoveModifierByName("modifier_returning_resources")
			-- 		ModifyLumber(player, caster.lumber_gathered)
		 --    		PopupLumber(caster, caster.lumber_gathered)
		 --    		caster.lumber_gathered = 0
			-- 		returned_type = "lumber"
			-- end
			-- Return Ability Off
			if ability:ToggleAbility() == true then
				ability:ToggleAbility()
				--print("Return Ability Toggled Off")
			end

			-- Gather Ability
			local gather_ability = caster:FindAbilityByName("peasant_gather")
			if gather_ability:ToggleAbility() == false then
				-- Fake toggle On
				gather_ability:ToggleAbility() 
				--print("Gather Ability Toggled On")
			end

			if returned_type == "lumber" then
				caster:CastAbilityOnTarget(caster.target_tree, gather_ability, pID)
				--print("Casting ability to target tree")
			elseif returned_type == "gold" then
				caster:CastAbilityOnTarget(caster.target_mine, gather_ability, pID)
				--print("Casting ability to target mine")
			end
			

		end
	end

function CDOTA_BaseNPC:FindClosestResourceDeposit(caster)
			--print("Debug string from deposit resource")
			local position = caster:GetAbsOrigin()

			-- Find a Lumber Mill, a Town Hall and Barracks
			--local lumber_mill = Entities:FindByModel(nil, "models/buildings/building_plain_reference.vmdl")
			--local town_hall = Entities:FindByModel(nil, "models/props_garden/building_garden005.vmdl")
			
			-- Find a building to deliver
			local player = caster:GetPlayerOwner()
			if not player then print("ERROR, NO PLAYER") return end
			local buildings = player.structures
			local distance = math.huge
			local closest_building = nil

			for _,building in pairs(buildings) do
				if not building:IsNull() and IsValidDepositName( building:GetUnitName() ) then
				   --print(building)
					local this_distance = (position - building:GetAbsOrigin()):Length()
					if this_distance < distance then
						distance = this_distance
						closest_building = building
						
					end
				end
			end
			
			if not closest_building then
		      --print("Error: Can't find a deposit for "..caster.."!")
		    end
		    return closest_building     
		end


		function IsValidDepositName( name )
			
			-- Possible Delivery Buildings are:
			local possible_deposits = { "lumber_house",
										"build_house",
										"deforestation_house"
									  }
		
			for i=1,#possible_deposits do 
				if name == possible_deposits[i] then
					return true
				end
			end

			return false
		end
-- Aux to find resource deposit


		function ReplaceUnit( unit, new_unit_name )
			print("Replacing "..unit:GetUnitName().." with "..new_unit_name)

			local hero = unit:GetOwner()
			local player = unit:GetPlayerOwner()
			local pID = hero:GetPlayerID()

			local position = unit:GetAbsOrigin()
			local health = unit:GetHealth()
			unit:RemoveSelf()

			local new_unit = CreateUnitByName(new_unit_name, position, true, hero, hero, hero:GetTeamNumber())
			new_unit:SetOwner(hero)
			new_unit:SetControllableByPlayer(pID, true)
			new_unit:SetAbsOrigin(position)
			new_unit:SetHealth(health)
			FindClearSpaceForUnit(new_unit, position, true)

			return new_unit
		end



		function CDOTA_BaseNPC:SetNoCollision(bAble)
		    if bAble then
		        self:AddNewModifier(self, nil, "modifier_no_collision", {})
		    else
		        self:RemoveModifierByName("modifier_no_collision")
		    end
		end

		function CDOTA_BaseNPC:SetAttacktree(bAble)
		    if bAble then
		        self:AddNewModifier(self, nil, "modifier_attack_trees", {})
		    else
		        self:RemoveModifierByName("modifier_attack_trees")
		    end
		end

		function AttackTree(unit, tree)
		    local tree_pos = tree:GetAbsOrigin()
		    
		    --ExecuteOrderFromTable({UnitIndex = unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = location, Queue = false}) 

		    -- Move towards the tree until close range    
		    unit.gatherer_timer = Timers:CreateTimer(0.03, function() 
		        if not IsValidEntity(unit) or not unit:IsAlive() then return end -- End if killed

		        local distance = (tree_pos - unit:GetAbsOrigin()):Length()
		        unit:MoveToPosition(tree_pos)
		        
		        if distance > 150 then
		            return ThinkInterval
		        else
		        	print("statrgesture")
		            unit:StartGesture(ACT_DOTA_ATTACK)
		            unit.gatherer_timer = Timers:CreateTimer(0.5, function() 
		                tree:CutDown(unit:GetTeamNumber())
		            end)
		            return
		        end
		    end)
		end

function SpawnUnit( keys)
	local caster = keys.caster
	local ability = keys.ability
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local pID = hero:GetPlayerID()
	local unitname = ability:GetSpecialValueFor("worker_id")
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
		if unitname == key then
		unitname = id[unitname]
		end
	end
	print(unitname)

		local unit = CreateUnitByName(unitname, caster:GetAbsOrigin() , true, caster:GetOwner(), caster:GetOwner(), caster:GetTeam()) 
		if unitname == "peasant" then
		unit:SetHullRadius(1)
		end
		unit:AddNewModifier(unit, nil, "modifier_phased", {})
		Timers:CreateTimer(0.3, function() 

			unit:RemoveModifierByName("modifier_phased") end)

		local food_cost = ability:GetSpecialValueFor("food_cost")
		local player = PlayerResource:GetPlayer(pID)	

		unit:SetOwner(hero)
		unit:SetControllableByPlayer(pID,true)
		
		table.insert(player.units, unit)

		unit:AddNewModifier( unit, nil, "modifier_low_priority", {} )
		
		if unitname~="tower_builder" and unitname~="super_tower_builder" and unitname~="goblin_tower_builder" then
		unit:SetAttacktree(true)
		end
		if unit then
			if unitname == "goblin_tower_builder" then
				local blink =unit:FindAbilityByName("global_blink")
				blink:SetHidden(false)
			end
	  	 local gatherspell = unit:FindAbilityByName("peasant_gather")
	   		if gatherspell then
		   		if gatherspell:IsFullyCastable() then
		      		Timers:CreateTimer(0.1, function() 
		      			 unit:CastAbilityNoTarget(gatherspell,unit:GetPlayerOwnerID())
		      			end)
		   		end
		   	end
		end
		if  player.upgrades["research_worker_motivation"] == 1 then
		Timers:CreateTimer(0.9, function() 
			unit:SetMaxHealth(400)
		unit:SetHealth(400)
		end)
		end


end

function SlayerSpawn( keys )
	local caster = keys.caster
	local ability = keys.ability

	local pID = caster:GetPlayerOwner():GetPlayerID()
	local player = PlayerResource:GetPlayer(pID)	
	local slayer = CreateHeroForPlayer("npc_dota_hero_invoker",player)
	player.slayer=slayer
	FindClearSpaceForUnit(slayer, caster:GetOrigin(), false)
	slayer:SetControllableByPlayer(pID,true)
	slayer:SetOwner(player)
	ability:SetHidden(true)
	local playername = PlayerResource:GetPlayerName(pID)
	player.slayer = slayer

	CustomGameEventManager:Send_ServerToPlayer(player,"SlayerSpawn",{hero=slayer:GetEntityIndex()})
	GameRules:SendCustomMessage("<font color='"..ColorText(pID).."'>"..playername.."</font> Create a slayer at "..ConvertToTime(GameRules:GetGameTime()).." ", 0, 0)
end

function SlayerRespawn( keys )
	local caster = keys.caster
	local ability = keys.ability
	local pID = caster:GetPlayerOwner():GetPlayerID()
	local player = PlayerResource:GetPlayer(pID)	

	player.slayer:SetRespawnPosition(caster:GetAbsOrigin())
	player.slayer:RespawnHero(false,false)


end

CustomGameEventManager:RegisterListener("tree_cut_order", Dynamic_Wrap(vampirism, "ordercuttree"))
function vampirism:ordercuttree( event )
	local caster = event.localHeroIndex
	local position = event.position
	
	if EntIndexToHScript(caster):FindAbilityByName("peasant_gather") then
	--local treetarget = event.target
	 position = GetGroundPosition(Vector(position["0"], position["1"], 0), nil)
	--local tree = GridNav:GetAllTreesAroundPoint(position, 32, true)
	--tree = tree[1]
--local treeid = GetTreeIdForEntityIndex(treetarget) 
--PrintTable(treetarget)
	--print(treetarget)

	   caster = EntIndexToHScript(caster)
	 local entityList = GetSelectedEntities(caster:GetPlayerOwnerID())
        for _,entityIndex in pairs(entityList) do
	--ExecuteOrderFromTable({ UnitIndex = caster, OrderType = DOTA_UNIT_ORDER_CAST_TARGET_TREE, TargetIndex = tree:GetEntityIndex() ,AbilityIndex = ability:GetAbilityIndex(), Position = position, Queue = false}) 
  		 ExecuteOrderFromTable({UnitIndex = entityIndex, OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = position, Queue = false})
  -- if then
   caster = EntIndexToHScript(entityIndex)
		  local ability = caster:FindAbilityByName("peasant_gather")
		  local treetarget = Entities:FindByClassnameNearest("ent_dota_tree" , position, 96)  
		   caster.targetindex=treetarget
		   				if caster then
		   				TreeFree(caster)
		   				end
		   						if treetarget then
		   							if not treetarget.worker then
						    	  		treetarget.worker = 1
						    	  	end
						    	  	if treetarget.worker  then
						    	  		treetarget.worker = treetarget.worker + 1	
						    	  	end
						    	  end
		   	caster:CastAbilityNoTarget(ability,caster:GetPlayerOwnerID())
		   --	caster.targetindex = treetarget
			end
		end
  -- end
end

function FindClosesttarget( event )
		local caster = event.caster
		local position = caster:GetAbsOrigin()
		local player = caster:GetPlayerOwner()
		local pID = player:GetPlayerID()
				
		tree_target = Entities:FindByClassnameNearest("ent_dota_tree" , position, 1000)  
				      
					   if tree_target == nil then
						  print("Can't find tree around")
						   SendErrorMessage((event.caster:GetPlayerOwner()):GetPlayerID(), "#Cant find tree near")
						  	return
					   end
				      	
				    	  local targets = 	GridNav:GetAllTreesAroundPoint(position,1000,true)
				    	  local sorted_tree = SortListByClosest(targets, position)
				    	  for _,tree in pairs(sorted_tree) do
				    	  	if GridNav:IsTraversable(tree:GetAbsOrigin()) then
						    	  	if not tree.worker then
						    	  		tree.worker = 1
						    	  		return tree
						    	  	end
						    	  	if tree.worker <4 then
						    	  		tree.worker = tree.worker + 1
						    	  		return tree
						    	  	end
					    	  end
				    	  end
				      	--return tree_target
			end


			
function GetTreeID( table )
	return GetTreeIdForEntityIndex(table:GetEntityIndex())
end
--[[
function TreeidExchange( table )
	local t = {}
		for i = 1, #table do
		local treeid=table[i]
			if not ttree[treeid] then
				t[treeid] = 0			
			end
		--treeid=GetTreeIdForEntityIndex(treeid:GetEntityIndex()) 
		--table.insert(t,treeid,0)
		end
	return t
end

function treecheck( table,position )
	--PrintTable(table)
	local distance = math.huge
	local closest_tree = nil
	for k,tree in pairs(table) do
				if tree<2  then
				  
					local this_distance = (position - k:GetAbsOrigin()):Length()
					print("Local path:"..this_distance)
				    print(GridNav:CanFindPath(position,k:GetAbsOrigin()) )

					if this_distance < distance then
						distance = this_distance
						closest_tree = k
						
					end
				end
			end
			 ttree[closest_tree]=ttree[closest_tree]+1
			print("distance short"..distance)

	return closest_tree
	--[[for k ,v in pairs(table) do
		if v<2 then
			--print("Treeid Choosen:"..k)
			ttree[k]= ttree[k]+1
			return k
			
			--break
		end
	end
end
]]

function SortListByPriority( list, position )
    local building = {}
    local sorted_list = {}
    for _,v in pairs(list) do
    	if string.match(v:GetUnitName(),"Wall_") then
    		building[#building+1]=v
    	end
    end

    for _,build in pairs(list) do
    	building[#building+1]=build
        -- local closest_building = GetClosestEntityToPosition(building, position)
        -- sorted_list[#sorted_list+1] = building[closest_building]
        -- building[closest_building] = nil -- Remove it
    end
    return building
end

	--Credits to Noya
function SortListByClosest( list, position )
    local trees = {}
    for _,v in pairs(list) do
        trees[#trees+1] = v
    end

    local sorted_list = {}
    for _,tree in pairs(list) do
        local closest_tree = GetClosestEntityToPosition(trees, position)
        sorted_list[#sorted_list+1] = trees[closest_tree]
        trees[closest_tree] = nil -- Remove it
    end
    return sorted_list
end

function GetClosestEntityToPosition(list, position)
    local distance = 20000
    local closest = nil

    for k,ent in pairs(list) do
        local this_distance = (position - ent:GetAbsOrigin()):Length()
        if this_distance < distance then
            distance = this_distance
            closest = k
        end
    end

    return closest  
end