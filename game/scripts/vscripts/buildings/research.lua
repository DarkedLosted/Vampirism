--[[
	Adds the search to the player research list
]]
LinkLuaModifier("modifier_rifles", "libraries/modifiers/modifier_rifles", LUA_MODIFIER_MOTION_NONE)

function ResearchComplete( event )
	local caster = event.caster
	local player = caster:GetPlayerOwner()
	local ability = event.ability
	local research_name = ability:GetAbilityName()

	-- It shouldn't be possible to research the same upgrade more than once.
	player.upgrades[research_name] = 1

	-- Go through all the upgradeable units and upgrade with the research
	for _,unit in pairs(player.units) do
		CheckAbilityRequirements( unit, player )
	end

	-- Also, on the buildings that have the upgrade, disable the upgrade and/or apply the next rank.
	for _,structure in pairs(player.structures) do
		CheckAbilityRequirements( structure, player )
	end
end

function LumberResearchComplete( event )
	local player = event.caster:GetPlayerOwner()
	local ability = event.ability
	local level = ability:GetLevel()-1
	local base_lumber_carried = event.ability:GetSpecialValueFor("base_lumber_carried")
	local extra_lumber_carried = event.ability:GetLevelSpecialValueFor("extra_lumber_carried", level-1)
	print("research lumber level:"..level)
	print("base_lumber_carried:"..base_lumber_carried)
	print("extra_lumber_carried:"..extra_lumber_carried)
	player.LumberCarried = base_lumber_carried +extra_lumber_carried
	print("player.LumberCarried:"..player.LumberCarried)
	CustomNetTables:SetTableValue("upgrades","research_lumber", {abilitylevel ={lvl=level} })
	
end


-- When queing a research, disable it to prevent from being queued again
function DisableResearch( event )
	local ability = event.ability
	print("Set Hidden "..ability:GetAbilityName())
	ability:SetHidden(true)

end

function MultiResearch ( event )
	local caster = event.caster
	local ability = event.ability
	
	local ability_level = ability:GetLevel()
	local ability_maxlevel = ability:GetMaxLevel() 

	if  ability_level < ability_maxlevel then
		--ability:SetLevel(ability_level+1) 
		caster:AddAbility(ability:GetAbilityName())
		local newabil = caster:FindAbilityByName(ability:GetAbilityName())
		newabil:SetLevel(ability_level+1)
		newabil:SetHidden(false) 
	
	end
	
	
end

-- Reenable the parent ability without item_ in its name
function ReEnableResearch( event )
	local caster = event.caster
	local ability = event.ability
	local item_name = ability:GetAbilityName()
	local research_ability_name = string.gsub(item_name, "item_", "")

	print("Unhide "..research_ability_name)
	local research_ability = caster:FindAbilityByName(research_ability_name)
	research_ability:SetHidden(false)

	
end


function WorkersHealth ( event )
	-- body
	local player = event.caster:GetPlayerOwner()
	local health = event.ability:GetSpecialValueFor("extra_health")

	for key,value in pairs(player.units) do
		if value:GetUnitName() == "peasant" then

		value:SetMaxHealth(health)
		value:SetHealth(health)
		end
	end

end

function WallHealth ( event )
	-- body
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

	local player = event.caster:GetPlayerOwner()
	local ability = event.ability
	local ability_level = ability:GetLevel()-1

	CustomNetTables:SetTableValue("upgrades","research_wall_quality", {abilitylevel ={lvl=ability_level} })
	for key,value in pairs(player.structures) do
		
		
		for key1,value1 in pairs(walls) do
			if value:GetUnitName() == walls[key1] then
			local maxhp = value:GetMaxHealth()+(value:GetBaseMaxHealth()/100*20)
			value:SetMaxHealth(maxhp)
			value:SetHealth(maxhp)
			end
		end
		
	end
end

function Infrastructure ( event )
	-- body
	local player = event.caster:GetPlayerOwner()
	
	for key,value in pairs(player.structures) do
		if value:GetUnitLabel() == "infrastructure" then
			value:SetMaxHealth(value:GetBaseMaxHealth()+300)
			value:SetHealth(value:GetBaseMaxHealth()+300)
		end
	end
end

function rifles ( event )
	-- body
	local player = event.caster:GetPlayerOwner()
	local hero = player:GetAssignedHero()
	hero:AddNewModifier(hero, nil, "modifier_rifles", {})
end

function TowerDamage ( event )
	-- body
	local player = event.caster:GetPlayerOwner()
	local ability = event.ability
	local ability_level = ability:GetLevel()-1
	CustomNetTables:SetTableValue("upgrades","research_tower_quality", {abilitylevel ={lvl=ability_level} })


	for key,value in pairs(player.structures) do
		print(value:GetUnitName())
		if value:GetUnitName() == "Tower_Of_Opal_Spire"  then
			
			local max=value:GetAttackDamage()+20
			local min = value:GetAttackDamage()+20
			value:SetBaseDamageMax(max)
			value:SetBaseDamageMin(min)
			--CustomNetTables:SetTableValue("upgrades","research_tower_quality", {Tower_Of_Opal_Spire ={BaseDamageMax=max,BaseDamageMin=min} })
		
		end
		if value:GetUnitName() == "Tower_Of_Pink_Diamond"  then
			
			local max=value:GetAttackDamage()+20
			local min = value:GetAttackDamage()+20
			value:SetBaseDamageMax(max)
			value:SetBaseDamageMin(min)
			--CustomNetTables:SetTableValue("upgrades","research_glissenning_powder", {Tower_Of_Pink_Diamond ={BaseDamageMax=max,BaseDamageMin=min} })
		
		end
	end
end

	function IronPlate ( event )
	-- body
	local ability = event.ability
	
	local ability_level = ability:GetLevel()
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
		CustomNetTables:SetTableValue("upgrades","research_iron_plate", {abilitylevel ={lvl=ability_level-1}, Carnelian_wall={PhysicalArmorBaseValue=10,armor=5}  })
		local player = event.caster:GetPlayerOwner()
		for key,value in pairs(player.structures) do
			for key1,value1 in pairs(walls) do
				if value:GetUnitName() == walls[key1-1]  then		
				print(walls[value:GetUnitName()])
				local armor=value:GetPhysicalArmorBaseValue()+wallsvalue[key1-1]
				 value:SetPhysicalArmorBaseValue(armor)
					
				 end
			end
		end
	
	end

function research_tower_defence ( event )
	local player = event.caster:GetPlayerOwner()
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
	for key,value in pairs(player.structures) do
		for key1,value1 in pairs(towers) do
			if value:GetUnitName() == towers[key1-1] then
			local maxhp = value:GetMaxHealth()+1500
			value:SetMaxHealth(maxhp)
			value:SetHealth(maxhp)
					
			end
		end
	end
end

function research_human_training ( event )
	local player = event.caster:GetPlayerOwner()

	local hero = event.caster:GetOwner()
	hero:SetMaxHealth(1000)
	hero:SetHealth(1000)

end


function research_tower_of_health ( event )
		local player = event.caster:GetPlayerOwner()
		
		for key,value in pairs(player.structures) do
			if value:GetUnitName() == "wall_of_health" then
			local maxhp =(value:GetBaseMaxHealth()+1500)
			value:SetMaxHealth(maxhp)
			value:SetHealth(maxhp)
			CustomNetTables:SetTableValue("upgrades","research_tower_of_health", {wall_of_health ={Health=maxhp} })
			end
		end

end

function research_glissenning_powder ( event )
	local player = event.caster:GetPlayerOwner()
	for key,value in pairs(player.structures) do
		if value:GetUnitName() == "Tower_Of_Pink_Diamond"  then
			
			local max=value:GetAttackDamage()+400
			local min = value:GetAttackDamage()+400
			value:SetBaseDamageMax(max)
			value:SetBaseDamageMin(min)
			--CustomNetTables:SetTableValue("upgrades","research_glissenning_powder", {Tower_Of_Pink_Diamond ={BaseDamageMax=max,BaseDamageMin=min} })
		
		end
	end
end


function research_human_damage_upgrade ( event )
	local player = event.caster:GetPlayerOwner()
	local hero = event.caster:GetOwner()
	local max=hero:GetAttackDamage()+100
	local min = hero:GetAttackDamage()+100
			hero:SetBaseDamageMax(max)
			hero:SetBaseDamageMin(min)
	CustomNetTables:SetTableValue("upgrades","research_human_damage_upgrade", {abilitylevel ={lvl=ability_level} })

end


function research_human_survival_hp ( event )	
	local player = event.caster:GetPlayerOwner()
	local hero = event.caster:GetOwner()
	hero:SetMaxHealth(1300)
	hero:SetHealth(1300)
	
end

function research_slayer_traning ( event )
	local player = event.caster:GetPlayerOwner()
	local ability = event.ability
	local hero = event.caster:GetOwner()	
			local max=player.slayer:GetBaseDamageMax()+965
			local min = player.slayer:GetBaseDamageMin()+965
			local maxhp = player.slayer:GetMaxHealth()+10000
			player.slayer:SetBaseDamageMax(max)
			player.slayer:SetBaseDamageMin(min)

			player.slayer:SetMaxHealth(maxhp)
			player.slayer:SetBaseMaxHealth(maxhp)
			player.slayer:SetHealth(maxhp)
		
end

function train_slayer_upgrade_dmg ( event )
	local player = event.caster:GetPlayerOwner()
	local hero = event.caster:GetOwner()
		local max=player.slayer:GetBaseDamageMax()+64
			local min = player.slayer:GetBaseDamageMin()+64
			player.slayer:SetBaseDamageMax(max)
			player.slayer:SetBaseDamageMin(min)
end


function research_slayer_adept ( event )
	local player = event.caster:GetPlayerOwner()
	local hero = event.caster:GetOwner()
	
		local max=player.slayer:GetBaseDamageMax()+20
			local min = player.slayer:GetBaseDamageMin()+20
			local maxhp = player.slayer:GetMaxHealth()+500
			local mana = player.slayer:GetMaxMana()+500

		--	player.slayer:SetMana(mana)
			player.slayer:SetMaxHealth(maxhp)
		--	player.slayer:SetBaseMaxHealth(maxhp)
			player.slayer:SetHealth(maxhp)
		
			player.slayer:SetBaseDamageMax(max)
			player.slayer:SetBaseDamageMin(min)

end

function research_human_teleport( event )
	local player = event.caster:GetPlayerOwner()
	local hero = event.caster:GetOwner()
	local abil = hero:FindAbilityByName("humans_teleport")
	abil:SetLevel(abil:GetMaxLevel())
end

function research_blink_extansion (event)
	local player = event.caster:GetPlayerOwner()

	for key,value in pairs(player.units) do
			if value:GetUnitName() == "super_tower_builder" then	
	
				local oldtp = value:FindAbilityByName("human_blink")
				local newtp = value:FindAbilityByName("global_blink")
				oldtp:SetHidden(true)
				newtp:SetHidden(false)
			end
	end
end

function research_mana_regeneration ( event )
	local player = event.caster:GetPlayerOwner()
	local hero = event.caster:GetOwner()
		for key,value in pairs(player.structures) do
		if value:GetUnitName() == "wall_of_health" then
				local abil = value:AddAbility("mana_regeneration")
				abil:SetLevel(abil:GetMaxLevel())
				
		end
	end
end

function research_engineers_health ( event )
	local player = event.caster:GetPlayerOwner()
	local hero = event.caster:GetOwner()
	for key,value in pairs(player.units) do
		if value:GetUnitName() == "engineer" then
			local health = value:GetMaxHealth()+400
		value:SetMaxHealth(health)
		value:SetHealth(health)
		end
	end
end

function VampireLvlUp(event )
	local player = event.caster:GetPlayerOwner()
	local hero = event.caster:GetOwner()
	hero:HeroLevelUp(true)
end

function VampireAgillity( event )
	local player = event.caster:GetPlayerOwner()
	local hero = event.caster:GetOwner()
	hero:ModifyAgility(100)
end

function VampireInt( event )
	local player = event.caster:GetPlayerOwner()
	local hero = event.caster:GetOwner()
	hero:ModifyIntellect(100)
end

function VampireStrenght( event )
	local player = event.caster:GetPlayerOwner()
	local hero = event.caster:GetOwner()
	hero:ModifyStrength(100)
end

function VampireAllStats( event )
	local player = event.caster:GetPlayerOwner()
	local hero = event.caster:GetOwner()
	hero:ModifyStrength(100)
	hero:ModifyIntellect(100)
	hero:ModifyAgility(100)
end