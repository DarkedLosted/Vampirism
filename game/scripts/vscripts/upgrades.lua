-- Go through every ability and check if the requirements are met
-- Swaps abilities with _disabled to their non disabled version and viceversa
-- This is called in multiple events:
	-- On every unit & building after a building is destroyed
	-- On single building after spawning in OnConstructionStarted
function CheckAbilityRequirements( unit, player )

	local requirements = GameRules.Requirements
	local buildings = player.buildings
	local upgrades = player.upgrades

	-- Check the Researches for this player, adjusting the abilities that have been already upgraded
   CheckResearchRequirements( unit, player )
   FoodLimit(player)
	-- The disabled abilities end with this affix
	local len = string.len("_disabled")

	if IsValidEntity(unit) then
		local hero = unit:GetPlayerOwner()
		local pID = hero:GetPlayerID()

		--print("--- Checking Requirements on "..unit:GetUnitName().." ---")
		for abilitySlot=0,15 do
			local ability = unit:GetAbilityByIndex(abilitySlot)

			-- If the ability exists
			if ability then
				local ability_name = ability:GetAbilityName()
				
				
				local building_name = string.sub(ability_name,7,string.len(ability_name))
				 if hero.buildings[building_name] then
				  if building_name =="Tower_Of_Blood" then
						 if hero.buildings[building_name] >0 then
						 	ability:SetHidden(true)
						 else
						 	ability:SetHidden(false)
						 end
					end
				end
			
				-- Exists and isn't hidden, check its requirements
				if IsValidEntity(ability) then
					local disabled = false
				
					-- By default, all abilities that have a requirement start as _disabled
					-- This is to prevent applying passive modifier effects that have to be removed later
					-- The disabled ability is just a dummy for tooltip, precache and level 0.
					-- Check if the ability is disabled or not
					if string.find(ability_name, "_disabled") then
						-- Cut the disabled part from the name to check the requirements
						local ability_len = string.len(ability_name)
						ability_name = string.sub(ability_name, 1 , ability_len - len)
						disabled = true
					end

					-- Check if it has requirements on the KV table
					local player_has_requirements = PlayerHasRequirementForAbility( player, ability_name)

					--[[Act accordingly to the disabled/enabled state of the ability
						If the ability is _disabled
							Requirements succeed: Enable (the player has the necessary researches or buildings to utilize this)
						 	Requirements fail: Do nothing
						Else ability was enabled
						 	Requirements succeed: Do nothing
							Requirements fail: Set disabled (the player lost some requirement due to building destruction)
					]]

					-- Unlock all abilities cheat
					if GameRules.DebugMode then
						player_has_requirements = true
					end

					if disabled then
						if player_has_requirements then
							-- Learn the ability and remove the disabled one (as we might run out of the 16 ability slot limit)
							--print("SUCCESS, ENABLED "..ability_name)
							unit:AddAbility(ability_name)

							local disabled_ability_name = ability_name.."_disabled"
							unit:SwapAbilities(disabled_ability_name, ability_name, false, true)
							unit:RemoveAbility(disabled_ability_name)

							-- Set the new ability level
							local ability = unit:FindAbilityByName(ability_name)
							--ability:SetLevel(ability:GetMaxLevel())
							ability:SetLevel(1)
							if string.find(ability:GetAbilityName(), "build_") then
							ability:SetHidden(true)
							end

						else
							--print("Ability Still DISABLED "..ability_name)
						end
					else
						if player_has_requirements then
							--print("Ability Still ENABLED "..ability_name)
							--ability:SetLevel(1)
						else	
							-- Disable the ability, swap to a _disabled
							--print("FAIL, DISABLED "..ability_name)

							local disabled_ability_name = ability_name.."_disabled"
							unit:AddAbility(disabled_ability_name)					
							unit:SwapAbilities(ability_name, disabled_ability_name, false, true)
							unit:RemoveAbility(ability_name)

							-- Set the new ability level
							--print("Finding",disabled_ability_name)
							local disabled_ability = unit:FindAbilityByName(disabled_ability_name)
							disabled_ability:SetLevel(0)
							if  string.find(disabled_ability:GetAbilityName(), "build_") then
							disabled_ability:SetHidden(true)
							end
						
						end
					end				
				else
					--print("->Ability is hidden or invalid")	
				end
			end
		end
	else
		print("Not a Valid Entity!, there's currently ",#player.units,"units and",#player.structures,"structures in the table")
	end	
end

-- In addition and run just before CheckAbilityRequirements, when a building starts construction
function CheckResearchRequirements( unit, player )
	if IsValidEntity(unit) then
		for abilitySlot=0,15 do
			local ability = unit:GetAbilityByIndex(abilitySlot)

			if ability then
				local ability_name = ability:GetAbilityName()

				if string.find(ability_name, "research_") then
					--print("find ability:"..ability_name)
					
					ability:SetHidden(true)
					

					if PlayerHasResearch(player, ability_name) then
						-- Player already has the research, remove it
						local ability_level = ability:GetLevel()
						local ability_maxlevel = ability:GetMaxLevel() 

						if  ability_level < ability_maxlevel then
						print(ability_name.." research level:"..ability_level)
						print(ability_name.." research max level:"..ability_maxlevel)
						ability:SetLevel(ability_level+1)
						ability:SetHidden(true)
						elseif ability_level == ability_maxlevel then
							ability:SetLevel(ability_level+1)
							ability:SetHidden(true)
						else
							
							ability:SetHidden(true)
							--unit:RemoveAbility(ability_name)	
						end

					else
						
						if not ability:IsChanneling()  then
						ability:SetHidden(false)
						end

					end
				end

				if string.match (ability_name,"research_") and not string.match (ability_name,"train_") and ability_name  ~= "research_slayer"  and ability_name  ~= "research_slayer_respawn" then
					ability:SetHidden(true)
				end
			end
		end
	end
end