if not Bot then
    Bot = class({}) 
end

function Bot:Init()
	Bot:print("Bot Init")
	Bot.Test = true
	Bot.LocationTable = {}
	Bot.AreaCheked={}
	Bot.ID = {}
	Bot.Player = {}
	Bot.Settings = LoadKeyValues("scripts/kv/Bot_settings.kv")
	Bot.Hero = {}
	Bot.PlayersFinded = {}
	Bot.Ability={}
	Bot.AttackTarget = false
	Bot:BasePosRewrite()
	Bot.ThinkInterval = 1
	Bot.CurrentMoveTarget = nil
	Bot.CurrentMoveWall = nil
	Bot.Agressive = true
	 Timers:CreateTimer(75,function()
        return Bot:Think()
    	end)
	  Timers:CreateTimer(75,function()
        return Bot:ThinkNav()
    	end)
	  Timers:CreateTimer(75,function()
        return Bot:StackCheck()
    	end)
	--  Timers:CreateTimer(75,function()
	-- return  Bot:CheckAround()
	--  end)
	ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(Bot, 'OnLevelUp'), self)
end

function Bot:Add()
	local player_count = PlayerResource:GetPlayerCount()
    local playerID=player_count
         Bot:print("AddBot "..playerID)
         Tutorial:AddBot("npc_dota_hero_night_stalker",'','',false)
        Bot.ID= playerID
         Timers:CreateTimer(60,function ()
         	Bot:LevelInit(playerID)
         end)
         
        

                if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:IsFakeClient(playerID) then
                    if PlayerResource:GetSelectedHeroEntity(playerID) then
                        Bot:InitFakePlayer(playerID)
                    else
                        local player = PlayerResource:GetPlayer(playerID)
                        if player then
                            if not Bot.Hero then
                                local h = CreateHeroForPlayer("npc_dota_hero_night_stalker", player)
                                Bot:print("CreateHeroForPlayer "..playerID)
                                UTIL_Remove(h)
                            end
                        end
                        
                    end
                end
    	
end

function Bot:InitFakePlayer(playerID, hero)
    local hero = PlayerResource:GetSelectedHeroEntity(playerID) or hero
    if hero then
        if hero.initialized then
            return
        end

        hero.initialized = true
        local teamNumber = hero:GetTeamNumber()
        Bot:print("InitFakePlayer "..playerID.." "..hero:GetUnitName().." on team "..teamNumber)
        Bot.ID= playerID

    else
        Bot:print("Tried to initialize a player AI without a hero or teamnumber")
        print(playerID, hero, teamNumber)
    end
end

function Bot:LevelInit(playerID)
	
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local skillBuild = Bot:GetSkillBuild()
    local abilityName = nil
     Bot.Hero = hero
    	for i=1,3 do
    		abilityName = skillBuild[tostring(i)]
    		local ability = hero:FindAbilityByName(abilityName)
    		if not Bot.Ability[abilityName] then
		    	Bot.Ability[abilityName] = ability
		    end
    		if abilityName then hero:UpgradeAbility(ability) end
    	end
end
function Bot:OnLevelUp(keys)
	local player = EntIndexToHScript(keys.player)
    local botLvl = tostring(keys.level)
    if keys.level >35 then
    	return
    end
    local playerID = player:GetPlayerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local skillBuild = Bot:GetSkillBuild()
    local abilityName = skillBuild[botLvl]

    Bot:print("Bot lvl "..botLvl.." learned "..abilityName)

    local ability = hero:FindAbilityByName(abilityName)
    if not Bot.Ability[abilityName] then
    	Bot.Ability[abilityName] = ability
    end
    if abilityName then hero:UpgradeAbility(ability) end

    local BasePos = Bot.GetBasePositions()["1"]

    
    --Bot:Move(hero,BasePos)
    
end

function Bot:ThinkNav()
	Bot:TargetRich()
	Bot:CheatWherePlayers()
	
	
	
	return 10
end
function Bot:StackCheck()
	local pos = Bot.Hero:GetAbsOrigin()
	Timers:CreateTimer(15,function ()
		if Bot.Hero:GetAbsOrigin() ==pos then
			local vector = RandomVector(100)
			Bot:Move(Bot.Hero:GetAbsOrigin()+vector)
		end
	end)

	return 15
end
function Bot:Think()
	-- if Bot.Hero:HasModifier("modifier_command_restricted") then
	-- 	return Bot.ThinkInterval
	-- end
	Bot:Heal()
	if Bot.Agressive then
	--Bot:TargetRich()
		if not Bot.AttackTarget then 
				Bot:CheckReveal() 
				--print(Bot.AttackTarget)
				if Bot.AttackTarget then
					return Bot.ThinkInterval
				end

		end
	end

	return Bot.ThinkInterval
end

function Bot:CheckAround()
	local enemyarr = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Bot.Hero:GetAbsOrigin(), nil, 550, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	if #enemyarr>3 then
			--Bot.Hero:SetForceAttackTarget(enemyarr[RandomInt(0,#enemyarr)])
			Bot:print("Prepare for light!")
		if Bot.Ability["vampire_light"] and Bot.Ability["vampire_light"]:IsFullyCastable() then
			Bot.Hero:UseAbilityTarget(Bot.Ability["vampire_light"],enemyarr[RandomInt(0,#enemyarr)])
			Bot:print("Oh yea!")
		end
	end
	return 5
end
function Bot:CheckReveal()
	
	--Bot:print("Base Number:"..baseNumber)
	
	if Bot.Ability["vampire_reveal"] and Bot.Ability["vampire_reveal"]:IsFullyCastable() then
		local baseNumber =  Bot:BaseNumberRandom()
		local BasePos = Bot.GetBasePositions()[baseNumber]
		local WallPos = Bot.GetWallPositions()[baseNumber]

		Bot:UseAbility(Bot.Ability["vampire_reveal"],BasePos)
		local ability_level = Bot.Ability["vampire_reveal"]:GetLevel() - 1
		local vision_radius = Bot.Ability["vampire_reveal"]:GetLevelSpecialValueFor("vision_radius", ability_level) 
		BasePos.z=BasePos.z-200
		local enemyarr = FindUnitsInRadius(DOTA_TEAM_BADGUYS, BasePos, nil, vision_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE+DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		Bot:print("Enemy count:"..#enemyarr)
		Bot:print("Base Number:"..baseNumber)
		if #enemyarr>3 then
			--Bot.Hero:MoveToPositionAggressive(WallPos)
			Bot.CurrentMoveTarget = BasePos
			Bot.CurrentMoveWall=WallPos
			ExecuteOrderFromTable({ UnitIndex = Bot.Hero:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE, Position = WallPos, Queue = true})
			ExecuteOrderFromTable({ UnitIndex = Bot.Hero:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE, Position = BasePos, Queue = true})
			Bot.AttackTarget = true
			Bot:print("Move on")
			return BasePos
		end
		Bot:print("Path Lenght:"..Bot:GetPathLenght(BasePos))
	end
end


function Bot:TargetRich()
	if Bot.CurrentMoveTarget and Bot.AttackTarget and Bot.Hero:GetAbsOrigin().x ~= Bot.CurrentMoveTarget.x and Bot.Hero:GetAbsOrigin().y ~= Bot.CurrentMoveTarget.y then
	--Bot.Hero:MoveToPositionAggressive(Bot.CurrentMoveTarget)
	ExecuteOrderFromTable({ UnitIndex = Bot.Hero:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE, Position = Bot.CurrentMoveWall, Queue = true})
	ExecuteOrderFromTable({ UnitIndex = Bot.Hero:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE, Position = Bot.CurrentMoveTarget, Queue = true})
	else
	Bot.CurrentMoveTarget = false
	Bot.AttackTarget = false
	end
	print(Bot.AttackTarget)
end

function Bot:Heal()
	--print(Bot.Hero:GetHealthPercent())
	if Bot.Hero:GetHealthPercent() > 97 then
		Bot.Agressive = true
	end
	if Bot.Hero:GetHealthPercent() < 80 then
		if Bot.Ability["vampire_heal"] and Bot.Ability["vampire_heal"]:IsFullyCastable() then
			Bot:UseAbilityTarget(Bot.Ability["vampire_heal"],Bot.Hero)
		end
	end
	if Bot.Hero:GetHealthPercent() < 20 then
		if Bot.Ability["vampire_invis"] and Bot.Ability["vampire_invis"]:IsFullyCastable() then
			Bot:UseAbilityTarget(Bot.Ability["vampire_invis"],Bot.Hero)
		end
		Bot:BacktoFountain()
		Bot.Agressive = false
	end
end

function Bot:BacktoFountain()
	Bot.Hero:MoveToPosition(Vector(-32,736,148))
end
function Bot:Move(pos)
	Bot.Hero:MoveToPositionAggressive(pos)
end
function Bot:UseAbility(abil,pos)
	Bot.Hero:CastAbilityOnPosition(pos,abil,Bot.ID)
end
function Bot:UseAbilityTarget(abil,target)
	Bot.Hero:CastAbilityOnTarget(target,abil,Bot.ID)
end
function Bot:GetBasePositions()
	return Bot.Settings["BasePos"]
end
function Bot:GetWallPositions()
	return Bot.Settings["WallPos"]
end
function Bot:GetSkillBuild()
	return Bot.Settings["Build"]
end
function Bot:GetPathLenght(BasePos)
	return GridNav:FindPathLength(Bot.Hero:GetAbsOrigin(),BasePos)
end
function Bot:BaseNumberRandom()
	local number = tostring(RandomInt(1,42))
	local bValid = true

	if not Bot.AreaCheked then
			table.insert(Bot.AreaCheked,number)
		return number
	end

	-- while bValid do
		number =  tostring(RandomInt(1,42))
			bValid = false
		for k,v in pairs(Bot.AreaCheked) do
			if v==number then
				bValid = true
				break
			end
		end
	-- end
	
	table.insert(Bot.AreaCheked,number)
	return number
end
function Bot:print( msg )
	if Bot.Test then
	print("[Bot]:"..msg)

	end
end

function Bot:CheatWherePlayers()
	local BasePos = Bot.GetBasePositions()
	for i=1,42 do
		local enemyarr = FindUnitsInRadius(DOTA_TEAM_BADGUYS, BasePos[tostring(i)], nil, 2000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE+DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		--Bot.LocationTable = {}
		if #enemyarr >10 then
			Bot.LocationTable[#Bot.LocationTable] = {BaseNumber=i,EnemyCount=#enemyarr}
		end
	end
	PrintTable(Bot.LocationTable)
end

function Bot:BasePosRewrite()
	local BasePos = Bot.GetBasePositions()
	local WallPos = Bot.GetWallPositions()
	for i=1,42 do
		BasePos[tostring(i)] = Vector(BasePos[tostring(i)].x,BasePos[tostring(i)].y,BasePos[tostring(i)].z)
		WallPos[tostring(i)] = Vector(WallPos[tostring(i)].x,WallPos[tostring(i)].y,WallPos[tostring(i)].z)
	end
	Bot.Settings["BasePos"] = BasePos
	Bot.Settings["WallPos"] = WallPos
end

if not Bot.ID then  Bot:Init() end