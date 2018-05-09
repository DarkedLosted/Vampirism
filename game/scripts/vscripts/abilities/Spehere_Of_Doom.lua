function Blink( keys )
  local point = keys.target_points[1]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	--local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local ability = keys.ability
	local range = 190
	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	--caster:FindClearSpace(point)
	--ProjectileManager:ProjectileDodge(caster)

	local target = FindSpaceForUnit(caster,point,190, nil)
	if target  then
  	 caster:SetAbsOrigin(target)
  	end
	ResolveNPCPositions(caster:GetAbsOrigin(),caster:GetPaddedCollisionRadius())
--	print(FindClearSpaceForUnit(caster, point, false))
	local blinkIndexStart = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_phantom_strike_start.vpcf", PATTACH_ABSORIGIN, caster)
	Timers:CreateTimer( 0.2, function()
		local blinkIndex = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_phantom_strike_end.vpcf", PATTACH_ABSORIGIN, caster)
	
		end
	)
	Timers:CreateTimer( 1, function()
		
		ParticleManager:DestroyParticle( blinkIndexStart, false )
		--ParticleManager:DestroyParticle( blinkIndex, false )
		return nil
		end
	)
	
   
end

function human_blink( keys )

	local point = keys.target_points[1]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	--local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local ability = keys.ability
	local range = ability:GetSpecialValueFor("blink_range")
	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	--caster:FindClearSpace(point)
	--ProjectileManager:ProjectileDodge(caster)

	local target = FindSpaceForUnit(caster,point,190, nil)
	if  target  then
  	local abil= caster:FindAbilityByName("human_blink")
  	caster:CastAbilityOnPosition(point,abil,caster:GetPlayerID())
  	end
end
--[[ Find a clear space for a unit, depending on its HullSize. (Used to replace FindClearSpaceForUnit)
	 Author: space jam
	 Date: 31.07.2015 
	 unit 		 : The handle of the unit you are moving.
	 vTargetPos  : The target Vector you want to move this unit too.
	 searchLimit : The furthest we should look for a clear space.
	 initRadius  : Must be less than searchLimit, allows us to start further out from the initial vector. Can also be nil to not specify.]]
function FindSpaceForUnit( unit, vTargetPos, searchLimit, initRadius )
	local startPos = unit:GetAbsOrigin()
	local unitSize = unit:GetHullRadius()
	local gridSize = math.ceil(unitSize / 32)
	local x = vTargetPos.x
	local y = vTargetPos.y

	local goodSpace = {}

	local initBlocked = false
	if initRadius == nil then
		for i=1,360 do
			local rad = math.rad(i)
			local cx = x + unitSize * math.cos(rad)
			local cy = y + unitSize * math.sin(rad)
			local cz = GetGroundPosition(Vector(cx, cy, 1000), unit).z
			local pos = Vector(cx, cy, cz)
	
			-- Check first if the initial space is a good one.	
			local units = FindUnitsInRadius(unit:GetTeam(), pos, nil, unitSize, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			if #units > 0 then
				-- There was a unit other than the unit in that space. Its blocked.
				--DebugDrawCircle(pos, Vector(0,0,255), 1, unitSize, true, 5)
				initBlocked = true
			end
			if GridNav:IsBlocked(pos) or GridNav:IsTraversable(pos) == false then
				initBlocked = true
				--DebugDrawCircle(pos, Vector(255,0,0), 1, unitSize, true, 5)
			end
		end
		-- The inital space was good, return it.
		if initBlocked == false then
			--DebugDrawCircle(vTargetPos, Vector(255,0,0), 1, unitSize, true, 5)
			return vTargetPos
		end
		initRadius = unitSize
	end

	local radius = initRadius
	while radius < searchLimit do
		local isBlocked = false
		local pos = Vector(0, 0, 0)
		local spaceIndex = 1

		-- Draw a circle, find the LEAST blocked space in that circle.
		for i = 1, 360 do
			isBlocked = false
			local rad = math.rad(i)

			-- Start at target point, works its way out.
			local cx = x + radius * math.cos(rad)
			local cy = y + radius * math.sin(rad)

			local cz = GetGroundPosition(Vector(cx, cy, 1000), unit).z
			pos = Vector(cx, cy, cz)
			
			--DebugDrawCircle(Vector(cx, cy, cz), RandomVector(50), 1, unitSize, true, 5)
			if GridNav:IsBlocked(pos) or GridNav:IsTraversable(pos) == false then
				isBlocked = true
				--DebugDrawCircle(pos, Vector(255,0,0), 1, unitSize, true, 5)
			end
			-- We found an empty space, add to current candidate.
			if isBlocked == false then
				if goodSpace[spaceIndex] == nil then goodSpace[spaceIndex] = {} end
				table.insert(goodSpace[spaceIndex], pos) 
			else
				if goodSpace[spaceIndex] ~= nil then
					spaceIndex = spaceIndex + 1
				end
			end
		end

		-- Grab the best candidate.
		local candidate = {}
		for k,v in pairs(goodSpace) do
			-- The table with the most verticies represents the longest unbroken section of clear space in the search radius.
			if #v > #candidate then
				candidate = v
			end
		end

		-- Get the middle point on the candidate space, assume this to be the most likely point to find a clear unit space.
		local bestVec = candidate[math.floor(#candidate / 2)]
		if bestVec ~= nil then
			local validSpace = true
			-- Trace around that point a circle the size of the unit, if we find something the point is blocked.
			for i = 1, 360 do
				local rad = math.rad(i)
	
				local cx = bestVec.x + unitSize * math.cos(rad)
				local cy = bestVec.y + unitSize * math.sin(rad)
				local newVec = Vector(cx, cy, pos.z)
				-- If any point on this circle is blocked, we haven't found a good spot.
				if GridNav:IsBlocked(newVec) or GridNav:IsTraversable(newVec) == false then
					validSpace = false
					--DebugDrawCircle(newVec, Vector(0,255,255), 1, unitSize, true, 5)
				end
			end
	
			if validSpace == true then
				local units = FindUnitsInRadius(unit:GetTeam(), bestVec, nil, unitSize, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
				--DebugDrawCircle(bestVec, Vector(0,255,0), 1, unitSize, true, 5)
				if #units > 0 then
					validSpace = false
				end
				if validSpace == true then
					return bestVec
				end
			end
		end
		radius = radius + unitSize / 4
		--DebugDrawCircle(Vector(x, y, pos.z), Vector(255,255,255), 1, radius, true, 5)
	end
	return false			
end