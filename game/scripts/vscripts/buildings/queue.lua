--[[
	Creates an item on the buildings inventory to consume the queue.
]]

function EnqueueUnit( event )
	local caster = event.caster
	local ability = event.ability
	local pID = caster:GetPlayerOwner():GetPlayerID()
	--check If  enough resources to upd
	local player = PlayerResource:GetPlayer(pID)
	local lumber_cost = ability:GetSpecialValueFor("lumber_cost")
	local gold_cost =  ability:GetGoldCost(1)
	local food_cost = ability:GetSpecialValueFor("food_cost")
	--Workers Foods
	local workerid = ability:GetSpecialValueFor("worker_id")
	
	PlayerResource:ModifyGold(pID, gold_cost, false, 0)
 	CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})

	
	--Slayer fix
	if ability:GetAbilityName() == "research_slayer_traning" or ability:GetAbilityName() == "research_slayer_adept" then
		if not player.slayer then
			SendErrorMessage(caster:GetPlayerOwnerID(), "#error_buy_a_slayer")
			ability:SetHidden(false)
			return 
		end
	end
	if ability:GetAbilityName() == "research_slayer" then
		if not PlayerHasEnoughFood(player,food_cost) then
				--SendErrorMessage(caster:GetPlayerOwnerID(), "#error_buy_a_slayer")
				ability:SetHidden(false)
				return 
			else
				ModifyFood(player,10)
		end
		if not PlayerHasEnoughLumber(player,lumber_cost) then
			ability:SetHidden(false)
				return 
			end

	end
	if not PlayerHasEnoughLumber( player, lumber_cost ) then
		CustomGameEventManager:Send_ServerToPlayer( player, "ResearchStop" ,player)
		return 
	end
	if not PlayerHasEnoughGold(player,gold_cost) then
		PlayerResource:ModifyGold(pID, gold_cost, false, 0)
		CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
		CustomGameEventManager:Send_ServerToPlayer( player, "ResearchStop" ,player)

		return 
	end

	if  string.match(ability:GetAbilityName(), "research_") then
	  PlayerResource:ModifyGold(pID, -gold_cost, false, 0)
	  CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
		ModifyLumber(player,-lumber_cost)
	end

	if workerid~=0 then
		if not WorkersHire(player,workerid,food_cost,gold_cost,lumber_cost)  then
			return
		end
	end
	
	-- Initialize queue
	if not caster.queue then
		caster.queue = {}
	end

	-- Queue up to 6 units max
	if #caster.queue < 6 then
		local ability_name = ability:GetAbilityName()
		local item_name = "item_"..ability_name
		local item = CreateItem(item_name, caster, caster)
		caster:AddItem(item)

		-- RemakeQueue
		caster.queue = {}
		for itemSlot = 0, 5, 1 do
			local item = caster:GetItemInSlot( itemSlot )
			if item ~= nil then
				table.insert(caster.queue, item:GetEntityIndex())
			end
		end
	else
		-- Refund with message
		if ability:GetAbilityName() == "train_peasant" then
			ModifyFood(player,-food_cost)
		end
 		PlayerResource:ModifyGold(pID, gold_cost, false, 0)
 		CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
 		ModifyLumber(player,lumber_cost)
		SendErrorMessage(caster:GetPlayerOwnerID(), "#error_queue_full")
	end
end


-- Destroys an item on the buildings inventory, refunding full cost of purchasing and reordering the queue
-- If its the first slot, the channeling ability is also set to not channel, refunding the full price.
function DequeueUnit( event )
	local caster = event.caster
	local item = event.ability
	local player = caster:GetPlayerOwner()
	local pID = player:GetPlayerID()

	local item_ability = EntIndexToHScript(item:GetEntityIndex())
	local item_ability_name = item_ability:GetAbilityName()

	-- Get tied ability
	local train_ability_name = string.gsub(item_ability_name, "item_", "")
	local train_ability = caster:FindAbilityByName(train_ability_name)
	local gold_cost = train_ability:GetGoldCost( train_ability:GetLevel() )
	local lumber_cost = train_ability:GetSpecialValueFor("lumber_cost")

	print("Start dequeue")
	if  string.match(train_ability_name , "train_") then
	--ModifyFood(player,-5)
	local unitname = string.gsub(train_ability_name, "train_", "")
	WorkersDie(player,unitname )
	end
	

	if train_ability_name == "research_slayer" then
		ModifyFood(player,-10)
	end

	for itemSlot = 0, 5, 1 do
       	local item = caster:GetItemInSlot( itemSlot )
        if item ~= nil then
        	local current_item = EntIndexToHScript(item:GetEntityIndex())

        	if current_item == item_ability then
        		--print("Q")
        		--DeepPrintTable(caster.queue)
        		local queue_element = getIndex(caster.queue, item:GetEntityIndex())
        		--print(item:GetEntityIndex().." in queue at "..queue_element)
	            table.remove(caster.queue, queue_element)

	            caster:RemoveItem(item)
	            
	            -- Refund ability cost
	            PlayerResource:ModifyGold(pID, gold_cost, false, 0)
	            CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
				print("Refund gold:",gold_cost)
				ModifyLumber(player,lumber_cost)
				print("Refund lumber:",lumber_cost)
				-- Set not channeling if the cancelled item was the first slot
				if itemSlot == 0 then

					train_ability:SetChanneling(false)
					train_ability:EndChannel(true)
					print("Cancel current channel")

					-- Fake mana channel bar
					caster:SetMana(0)
					caster:SetBaseManaRegen(0)
				else
					print("Removed unit in queue slot",itemSlot)					
				end
				ReorderItems(caster)
				break
			end
        end
    end

   local buildabil =  caster:FindAbilityByName("ability_building")
   local buildabilq =  caster:FindAbilityByName("ability_building_queue")
   if buildabil then
	   	Timers:CreateTimer(0.1, function() 
	   	buildabil:SetHidden(true)
	   	end)
   	end
   	if buildabilq then
	   	Timers:CreateTimer(0.1, function() 
	   	buildabilq:SetHidden(true)
	   	end)
   	end
   	
	Timers:CreateTimer(0.1, function() 
	for k,structure in pairs(player.structures) do
    		CheckAbilityRequirements( structure, player )

    end
    end)
end

-- Moves on to the next element of the queue
function NextQueue( event )
	local caster = event.caster
	local ability = event.ability
	ability:SetChanneling(false)
	--print("Move next!")

	-- Dequeue
	--DeepPrintTable(event)
	local hAbility = EntIndexToHScript(ability:GetEntityIndex())

	for itemSlot = 0, 5, 1 do
       	local item = caster:GetItemInSlot( itemSlot )
        if item ~= nil then
        	local item_name = tostring(item:GetAbilityName())

        	-- Remove the "item_" to compare
        	local train_ability_name = string.gsub(item_name, "item_", "")

        	if train_ability_name == hAbility:GetAbilityName() then

        		local train_ability = caster:FindAbilityByName(train_ability_name)

        		print("Q")
        		DeepPrintTable(caster.queue)
        		local queue_element = getIndex(caster.queue, item:GetEntityIndex())
        		if IsValidEntity(item) then
	        		print(item:GetEntityIndex().." in queue at "..queue_element)
		            table.remove(caster.queue, queue_element)
	            	caster:RemoveItem(item)
	            end

            	break
            elseif item then
        		--print(item_name,hAbility:GetAbilityName())
        	end
        end
    end
end

function AdvanceQueue( event )
	local caster = event.caster
	local ability = event.ability
	local player = caster:GetPlayerOwner()

	if not IsChanneling( caster ) and caster:GetUnitName() ~= "wall_of_health"   and caster:GetUnitName() ~= "super_wall_of_health" then
		caster:SetMana(0)
		caster:SetBaseManaRegen(0)
	end

	if caster and IsValidEntity(caster) and not IsChanneling( caster ) and not caster:HasModifier("modifier_construction") then
		
		-- RemakeQueue
		caster.queue = {}

		-- Check the first item that contains "train" on the queue
		for itemSlot=0,5 do
			local item = caster:GetItemInSlot(itemSlot)
			if item and IsValidEntity(item) then

				table.insert(caster.queue, item:GetEntityIndex())

				local item_name = tostring(item:GetAbilityName())
				if not IsChanneling( caster ) then

					-- Items that contain "train" "revive" or "research" will start a channel of an ability with the same name without the item_ affix
					if string.find(item_name, "train_") or string.find(item_name, "_revive") or string.find(item_name, "research_") then
						-- Find the name of the tied ability-item: 
						--	ability = human_train_footman
						-- 	item = item_human_train_footman
						local train_ability_name = string.gsub(item_name, "item_", "")

						local ability_to_channel = caster:FindAbilityByName(train_ability_name)


						ability_to_channel:SetChanneling(true)
						print("->"..ability_to_channel:GetAbilityName()," started channel")

						-- Fake mana channel bar
						local channel_time = ability_to_channel:GetChannelTime()
						caster:SetMana(0)
						caster:SetBaseManaRegen(caster:GetMaxMana()/channel_time)

						-- Cheats
						if GameRules.WarpTen then
							ability_to_channel:EndChannel(false)
							ReorderItems(caster)
							return
						end

						-- After the channeling time, check if it was cancelled or spawn it
						-- EndChannel(false) runs whatever is in the OnChannelSucceded of the function
						local time = ability_to_channel:GetChannelTime()
						Timers:CreateTimer(time, function()
							--print("===Queue Table====")
							--DeepPrintTable(caster.queue)
							if IsValidEntity(item) then
								ability_to_channel:EndChannel(false)
								ReorderItems(caster)
								--print("Unit finished building")
							else
								--print("This unit was interrupted")
							end
						end)

					-- Items that contain "research_" will start a channel of an ability with the same name  without the item_ affix
					elseif string.find(item_name, "research_") then
						-- Find the name of the tied ability-item: 
						--	ability = human_research_defend
						-- 	item = item_human_research_defend
						local research_ability_name = string.gsub(item_name, "item_", "")

						local ability_to_channel = caster:FindAbilityByName(research_ability_name)
						if ability_to_channel then
							ability_to_channel:SetChanneling(true)
							print("->"..ability_to_channel:GetAbilityName()," started channel")

							-- Fake mana channel bar
							local channel_time = ability_to_channel:GetChannelTime()
							caster:SetMana(0)
							caster:SetBaseManaRegen(caster:GetMaxMana()/channel_time)

							-- Cheats
							if GameRules.WarpTen then
								ability_to_channel:EndChannel(false)
								ReorderItems(caster)
								return
							end

							-- After the channeling time, check if it was cancelled or spawn it
							-- EndChannel(false) runs whatever is in the OnChannelSucceded of the function
							Timers:CreateTimer(ability_to_channel:GetChannelTime(), 
							function()
								--print("===Queue Table====")
								--DeepPrintTable(caster.queue)
								if IsValidEntity(item) then
									ability_to_channel:EndChannel(false)
									ReorderItems(caster)
									print("Research complete!")
								else
									--print("This Research was interrupted")
								end
							end)
						end
					end
				end
			end
		end
	end
end

-- Auxiliar function that goes through every ability and item, checking for any ability being channelled
function IsChanneling ( unit )
	
	for abilitySlot=0,15 do
		local ability = unit:GetAbilityByIndex(abilitySlot)
		if ability ~= nil and ability:IsChanneling() then 
			return true
		end
	end

	for itemSlot=0,5 do
		local item = unit:GetItemInSlot(itemSlot)
		if item ~= nil and item:IsChanneling() then
			return true
		end
	end

	return false
end