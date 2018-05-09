--[[
	Replaces the building to the upgraded unit name
]]--
function UpgradeBuilding( event )
	local caster = event.caster
	local new_unit = event.UnitName
	local position = caster:GetAbsOrigin()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local playerID = hero:GetPlayerID()
	local player = PlayerResource:GetPlayer(playerID)
	local currentHealthPercentage = caster:GetHealthPercent() * 0.01

	-- Keep the gridnav blockers and orientation
	local blockers = caster.blockers
	local angle = caster:GetAngles()


	-- if new_unit == "tent_2" then
	-- 		ModifyMaxFood(player,30)
			
	-- 	end

    -- New building
	local building = BuildingHelper:PlaceBuilding(player, new_unit, position, false, 0)
	building.blockers = blockers
	building:SetAngles(0, -angle.y, 0)

	-- If the building to ugprade is selected, change the selection to the new one
	if IsCurrentlySelected(caster) then
		AddUnitToSelection(building)
	end
	
	--Tech tree fix
	local TechTree = {"build_house","lumber_house","deforestation_house","research_center","ultra_research_center","citadel_of_faith","slayers_vault","command_center","base_of_operations"}
	local bValid = true
	for _,value in pairs(TechTree) do
		if caster:GetUnitName() == value then
			bValid=false
		end
	end
	if bValid then
		if player.buildings[caster:GetUnitName()] <= 1 then
			player.buildings[caster:GetUnitName()] = 0
		else
			player.buildings[caster:GetUnitName()] = player.buildings[caster:GetUnitName()] - 1
		end
	end
	-- Remove the old building from the structures list
	if IsValidEntity(caster) then
		local buildingIndex = getIndex(player.structures, caster)
        table.remove(player.structures, buildingIndex)
		
		-- Remove old building entity
		caster:RemoveSelf()
    end

	local newRelativeHP = building:GetMaxHealth() * currentHealthPercentage
	if newRelativeHP == 0 then newRelativeHP = 1 end --just incase rounding goes wrong
	building:SetHealth(newRelativeHP)

	-- Add 1 to the buildings list for that name. The old name still remains
	if not player.buildings[new_unit] then
		player.buildings[new_unit] = 1
	else
		player.buildings[new_unit] = player.buildings[new_unit] + 1
	end

	if  player.upgrades["research_tower_quality"] == 1 then 

		if building:GetUnitName() == "Tower_Of_Opal_Spire" then
				local research = CustomNetTables:GetTableValue("upgrades","research_tower_quality")
				local towername  = research["abilitylevel"]
				local lvl = towername.lvl
				--local basedmgmax = towername.BaseDamageMax
				local max=building:GetAttackDamage()+(20*lvl)
				local min = building:GetAttackDamage()+(20*lvl)
				building:SetBaseDamageMax(max)
				building:SetBaseDamageMin(min)
			end
				if building:GetUnitName() == "Tower_Of_Pink_Diamond" then
				--local research = CustomNetTables:GetTableValue("upgrades","research_tower_quality")
				--local towername  = research[building:GetUnitName()]
				--local basedmgmin = towername.BaseDamageMin
				--local basedmgmax = towername.BaseDamageMax
				local max=building:GetAttackDamage()+(20*lvl)
				local min = building:GetAttackDamage()+(20*lvl)
				building:SetBaseDamageMax(max)
				building:SetBaseDamageMin(min)
			end
	end
	
	if  player.upgrades["research_iron_plate"] == 1 then 

		local walls = {
		"Carnelian_wall",
		"Wall_Of_Topaz",
		"Wall_Of_Amethyst",
		"Wall_Of_Sapphire",
		"Wall_Of_Emerald",
		"Wall_Of_Chrysoprase",
		"Wall_Of_Garnet",
		"Wall_Of_Ruby",
		"Wall_Of_Diamond",
		"Wall_Of_Onyx",
		}
		local wallsvalue = {
		"5",
		"10",
		"15",
		"20",
		"25",
		"25",
		"30",
		"30",
		"35",
		"40",
		}
			for key,value in pairs(walls) do
				
				if building:GetUnitName() == walls[key] then

						local research = CustomNetTables:GetTableValue("upgrades","research_iron_plate")																												
						local towername  = research["abilitylevel"]
						local lvl = towername.lvl
						local armor = building:GetPhysicalArmorBaseValue()
						print(armor)
						building:SetPhysicalArmorBaseValue(armor+(wallsvalue[key]*lvl))
						
				end
			end	
	end
	if  player.upgrades["research_glissenning_powder"] == 1 then 
				if building:GetUnitName() == "Tower_Of_Pink_Diamond" then
				--local research = CustomNetTables:GetTableValue("upgrades","research_glissenning_powder")
				--local towername  = research[building:GetUnitName()]
				--local basedmgmin = towername.BaseDamageMin
				--local basedmgmax = towername.BaseDamageMax
				local max=building:GetAttackDamage()+400
				local min = building:GetAttackDamage()+400

				building:SetBaseDamageMax(max)
				building:SetBaseDamageMin(min)
			end
	end
	
	if  player.upgrades["research_wall_quality"] == 1 then 

		local walls = {
		"Carnelian_wall",
		"Wall_Of_Topaz",
		"Wall_Of_Amethyst",
		"Wall_Of_Sapphire",
		"Wall_Of_Emerald",
		"Wall_Of_Chrysoprase",
		"Wall_Of_Garnet",
		"Wall_Of_Ruby",
		"Wall_Of_Diamond",
		"Wall_Of_Onyx",
		}
			for key,value in pairs(walls) do

				if building:GetUnitName() == walls[key] then

						local research = CustomNetTables:GetTableValue("upgrades","research_wall_quality")
						local towername  = research["abilitylevel"]
						local lvl = towername.lvl
						local health = building:GetMaxHealth()+(building:GetBaseMaxHealth()/100*(20*lvl))
						building:SetMaxHealth(health)
						building:SetHealth(health)
					
				end
			end	
	end

	if  player.upgrades["research_tower_defence"] == 1 then 

		local towers = {
			"Tower_Of_Pearls",
			 "Tower_Of_Lesser_Mana_Energy",
	 "Tower_Of_Mana_Energy",
	 "Tower_Of_Opal_Spire",
	 "Tower_Of_Pink_Diamond",
	 "Tower_Of_Calcite_Outl",
	 "Tower_Of_Flame",
	 "Tower_Of_Frost",
	 "Tower_Of_Blood",
	 "Tower_Of_Orange_Calcite",
	 "Tower_Of_Super_Flame",
	 "Tower_Of_Ultimate_Flame",
		}
			for key,value in pairs(towers) do

				if building:GetUnitName() == towers[key] then

					--	local research = CustomNetTables:GetTableValue("upgrades","research_tower_defence")
					--	local towername  = research[building:GetUnitName()]
					--	local health = towername.Health
						local health = building:GetMaxHealth()+1500
						building:SetMaxHealth(health)
						building:SetHealth(health)
					
				end
			end	
	end


		if building:GetUnitName() == "super_gold_mine" then
			building:SetRenderColor(3,255 ,3 )
		end
		if building:GetUnitName() == "ultra_gold_mine" then
			building:SetRenderColor(255,3 ,3 )
		end
		if building:GetUnitName() == "elite_gold_mine" then
			building:SetRenderColor(255,227 , 66)
		end
	-- Add the new building to the structures list
	table.insert(player.structures, building)

		--	player.buildings[building:GetUnitName()] = player.buildings[building:GetUnitName()] + 1
		
		 CustomNetTables:SetTableValue( "buildings", tostring(playerID),{player.buildings})
	-- Update the abilities of the units and structures
	for k,unit in pairs(player.units) do
		CheckAbilityRequirements( unit, player )
	end

	for k,structure in pairs(player.structures) do
		CheckAbilityRequirements( structure, player )
	end
end

--[[
	Disable any queue-able ability that the building could have, because the caster will be removed when the channel ends
	A modifier from the ability can also be passed here to attach particle effects
]]--
function StartUpgrade( event )	
	local caster = event.caster
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local playerID = hero:GetPlayerID()
	local player = PlayerResource:GetPlayer(playerID)
	local ability = event.ability
	local ability_name = ability:GetAbilityName()
	local AbilityKV = GameRules.AbilityKV
	local UnitKV = GameRules.UnitKV
	local modifier_name = "modifier_upgrade_building"
	local abilities = {}


	local gold_cost = ability:GetGoldCost(1)
	local lumber_cost = ability:GetSpecialValueFor("lumber_cost")

	 
	--hero:ModifyGold(gold_cost, false, 0)
	CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})
-- If not enough resources to queue, stop
       
		if not PlayerHasEnoughLumber( player, lumber_cost ) then
			-- PlayerResource:ModifyGold(playerID, gold_cost, false, 0)
			return 
		end


	if not PlayerHasEnoughGold(player,gold_cost) then
			-- PlayerResource:ModifyGold(playerID, gold_cost, false, 0)
			return 
		end
		ModifyLumber( player, -lumber_cost)
		hero:ModifyGold(-gold_cost, false, 0)
		CustomGameEventManager:Send_ServerToPlayer(player, "player_gold_changed", {})

		caster:AddNewModifier(caster, nil, "modifier_attack_disabled", {})
	-- Check to not disable when the queue was full
	if #caster.queue < 5 then

		-- Iterate through abilities marking those to disable
		for i=0,15 do
			local abil = caster:GetAbilityByIndex(i)
			if abil then
				local ability_name = abil:GetName()

				-- Abilities to hide can be filtered to include the strings train_ and research_, and keep the rest available
				--if string.match(ability_name, "train_") or string.match(ability_name, "research_") then
					table.insert(abilities, abil)
				--end
			end
		end

		-- Keep the references to enable if the upgrade gets canceled
		caster.disabled_abilities = abilities

		for k,disable_ability in pairs(abilities) do
			disable_ability:SetHidden(true)		
		end
		PrintTable(abilities)
		-- Pass a modifier with particle(s) of choice to show that the building is upgrading. Remove it on CancelUpgrade
		if modifier_name then
			ability:ApplyDataDrivenModifier(caster, caster, modifier_name, {})
			caster.upgrade_modifier = modifier_name
		end

	end

	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local playerID = hero:GetPlayerID()
	--FireGameEvent( 'ability_values_force_check', { player_ID = playerID })

end

--[[
	Replaces the building to the upgraded unit name
]]--
function CancelUpgrade( event )
	
	local caster = event.caster
	local abilities = caster.disabled_abilities
	PrintTable(abilities)
	if abilities then
	for k,ability in pairs(abilities) do
		ability:SetHidden(false)		
	end
	end
	caster:RemoveModifierByName("modifier_attack_disabled")
	
	local upgrade_modifier = caster.upgrade_modifier
	if upgrade_modifier and caster:HasModifier(upgrade_modifier) then
		caster:RemoveModifierByName(upgrade_modifier)
	end

	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local playerID = hero:GetPlayerID()
	--FireGameEvent( 'ability_values_force_check', { player_ID = playerID })
end

-- Forces an ability to level 0
function SetLevel0( event )
	local ability = event.ability
	if ability:GetLevel() == 1 then
		ability:SetLevel(0)	
	end
end