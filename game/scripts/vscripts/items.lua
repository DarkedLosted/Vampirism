function CheckLumber( keys )
	PrintTable(keys)
end

-- Adds gold based on the coin picked up.
function CoinUsed(keys)
	local caster = keys.caster
	local coin = keys.ability
	local playerID = caster:GetMainControllingPlayer()

	if caster:IsRealHero() then
		if keys.Type == "small" then
			ChangeGold(playerID, 1)
		end
		if keys.Type == "large" then
			ChangeGold(playerID, 2)
		end
	end
end

function ItemMoveSpeed( keys )
	--do this later hehe
end

-- Caster blinks a small distance if space is available.
function SphereDoom( keys )
	PrintTable(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local gooddist = keys.MaxBlink
	if ability.stacks == nil then
		ability.stacks = 2
	end

	if ability.stacks > 0 then
		local dist_vec =  point - caster:GetAbsOrigin()

		if dist_vec:Length2D() > keys.MaxBlink then
			point = caster:GetAbsOrigin() + (point - caster:GetAbsOrigin()):Normalized() * keys.MaxBlink
		end

		local newSpace = FindGoodSpaceForUnit(caster, point, 200, nil)
  		if newSpace ~= false then
  		  caster:SetAbsOrigin(newSpace)
  		end
		
		ability.stacks = ability.stacks - 1
		if ability.stacks > 0 then
			ability:EndCooldown()
		end

		Timers:CreateTimer(30, function()
			ability.stacks = ability.stacks + 1
			ability:EndCooldown()
			return nil
		end)
	else
		FireGameEvent("custom_error_show", {player_ID = caster:GetMainControllingPlayer(), _error = "Sphere cooling down!"})
	end
end

-- Spawns four engineers by the caster.
function SpawnEngineers( keys )
	local caster = keys.caster
	local playerID = caster:GetMainControllingPlayer()
	local ability = keys.ability

	for i = 1, 4 do
		local engi = CreateUnitByName("toolkit_engineer", caster:GetAbsOrigin(), true, nil, nil, 0)
		engi:SetControllableByPlayer(playerID, true)
		if TechTree:HasTech(playerID, 'research_engineer_vitality') then
			Timers:CreateTimer(.03, function ()
				engi:SetMaxHealth(2000)
				engi:Heal(1000, engi)
				return nil
			end)
		end
	end
end

-- Adds a regular BH ability to the caster, then casts that.
function AddBuildingToCaster( keys )
	local caster = keys.caster
	local ability = keys.ability
	local abilityToAdd = keys.AbilityToAdd

	caster:AddAbility(abilityToAdd)
	local added = caster:FindAbilityByName(abilityToAdd)
	added:SetLevel(1)
	caster:CastAbilityNoTarget(added, caster:GetMainControllingPlayer())
end

-- Ring of hell lords passive. Ghosts attack nearby enemy units.
function GhostRing( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ghostRange = ability:GetLevelSpecialValueFor('range', 1)
	local ghostDamage = ability:GetLevelSpecialValueFor('damage', 1)
	local maxGhosts = ability:GetLevelSpecialValueFor('max_ghosts', 1) 
	local ghostSpeed = ability:GetLevelSpecialValueFor('ghost_speed', 1)
	local ringCD = ability:GetLevelSpecialValueFor('ring_cd', 1) 
	local ghostInterval = ability:GetLevelSpecialValueFor('ghost_interval', 1)
	local abilityDamageType = ability:GetAbilityDamageType()
	local ghostStock = maxGhosts
	local targetUnit = nil
	local interval = false
	local casterTeam = caster:GetTeamNumber()
	local particleDamageBuilding = "particles/units/heroes/hero_death_prophet/death_prophet_exorcism_attack_building_glows.vpcf"

	Timers:CreateTimer(function ()
		local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, ghostRange, ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
		for k, v in pairs(units) do
			--finds nearest enemy unit.
			if v:GetTeamNumber() ~= casterTeam and v:GetUnitName() ~= 'ring_ghost' and v:IsInvulnerable() ~= true and v:NotOnMinimap() ~= true then
				targetUnit = v
				if ghostStock > 0 and interval == false then
					newGhost(targetUnit)
					ghostStock = ghostStock - 1
					interval = true
					Timers:CreateTimer(ghostInterval, function ()
						interval = false
						return nil
					end)
				end
			end
		end
		return 0.03
	end)


	--Credit to Noya, BMD and anyone who worked on SpellLibrary for this.
	function newGhost(target)
		local ghost = CreateUnitByName('ring_ghost', caster:GetAbsOrigin(), false, nil, nil, 3)
		ghost:AddAbility('ghost_phasing')
		ghost:FindAbilityByName('ghost_phasing'):OnUpgrade()

		Physics:Unit(ghost)
		ghost:PreventDI(true)
		ghost:SetAutoUnstuck(false)
		ghost:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		ghost:FollowNavMesh(false)
		ghost:SetPhysicsVelocityMax(ghostSpeed)
		ghost:SetPhysicsVelocity(target:GetAbsOrigin())
		ghost:SetPhysicsFriction(0)
		ghost:Hibernate(false)

		local point = target:GetAbsOrigin()
		ghost:OnPhysicsFrame(function ( ghost )

			-- Move the unit orientation to adjust the particle
			ghost:SetForwardVector( ( ghost:GetPhysicsVelocity() ):Normalized() )
			ghost.current_target = target
			if ghost.current_target:IsNull() then
				ghost:SetPhysicsVelocity(Vector(0,0,0))
				ghost:OnPhysicsFrame(nil)
				ghost:ForceKill(false)
				UTIL_Remove(ghost)
				Timers:CreateTimer(2, function ()
					ghostStock = ghostStock + 1
				end)
			end

			if ghost.current_target == nil or ghost.current_target:IsInvulnerable() == true then
				ghost:SetPhysicsVelocity(Vector(0,0,0))
				ghost:OnPhysicsFrame(nil)
				ghost:ForceKill(false)
				UTIL_Remove(ghost)
				Timers:CreateTimer(2, function ()
					ghostStock = ghostStock + 1
				end)
			end

			local source = caster:GetAbsOrigin()
			local current_position = ghost:GetAbsOrigin()
			local diff = point - ghost:GetAbsOrigin()
			--diff.z = 0
			local direction = diff:Normalized()

			-- Calculate the angle difference
			local angle_difference = RotationDelta(VectorToAngles(ghost:GetPhysicsVelocity():Normalized()), VectorToAngles(direction)).y
			
			-- Set the new velocity
			if math.abs(angle_difference) < 5 then
				-- CLAMP
				local newVel = ghost:GetPhysicsVelocity():Length() * direction
				ghost:SetPhysicsVelocity(newVel)
			elseif angle_difference > 0 then
				local newVel = RotatePosition(Vector(0,0,0), QAngle(0,10,0), ghost:GetPhysicsVelocity())
				ghost:SetPhysicsVelocity(newVel)
			else		
				local newVel = RotatePosition(Vector(0,0,0), QAngle(0,-10,0), ghost:GetPhysicsVelocity())
				ghost:SetPhysicsVelocity(newVel)
			end

			local distance = (point - current_position):Length()
			local collision = distance < 50
			if ghost.current_target then
				point = ghost.current_target:GetAbsOrigin()
			end

			if collision then
				if ghost.current_target ~= nil and ghost.current_target:IsInvulnerable() ~= true then

					local playerID = caster:GetMainControllingPlayer()
					local owner = caster:GetOwner()
					local damage_table = {
						victim = ghost.current_target,
						attacker = owner,
						damage_type = DAMAGE_TYPE_MAGICAL,
						damage = 50
					}
	
					ApplyDamage(damage_table)
					local particle = ParticleManager:CreateParticle(particleDamageBuilding, PATTACH_ABSORIGIN, ghost.current_target)
					ParticleManager:SetParticleControl(particle, 0, ghost.current_target:GetAbsOrigin())
					ParticleManager:SetParticleControlEnt(particle, 1, ghost.current_target, PATTACH_POINT_FOLLOW, "attach_hitloc", ghost.current_target:GetAbsOrigin(), true)
					ghost:SetPhysicsVelocity(Vector(0,0,0))
					ghost:OnPhysicsFrame(nil)
					ghost:ForceKill(false)
					UTIL_Remove(ghost)
					Timers:CreateTimer(2, function ()
						ghostStock = ghostStock + 1
					end)
				end
			end
		end)
	end
end

-- Handles all unit hiring behavior
function HireUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local foodCost = ITEM_KV[ability:GetAbilityName()]['FoodCost']
	local mercName = keys.Mercenary
	local playerID = caster:GetMainControllingPlayer()

	local merc = CreateUnitByName(mercName, caster:GetAbsOrigin(), true, caster, PlayerResource:GetPlayer(playerID), caster:GetTeam())
	merc:SetControllableByPlayer(playerID, true)

	-- initialize specific mercenary abilities
	if mercName == 'merc_shade' then
		merc:AddNewModifier(caster, nil, "modifier_invisible", {})
	end
	if mercName == 'merc_avernal' then
		merc:FindAbilityByName('avernal_hp_growth'):OnUpgrade()
	end
	if UNIT_KV[playerID][mercName]['ProvidesFood'] ~= nil then
		TOTAL_FOOD[playerID] = TOTAL_FOOD[playerID] + UNIT_KV[playerID][mercName]['ProvidesFood']
		FireGameEvent("vamp_food_cap_changed", { player_ID = playerID, food_cap = TOTAL_FOOD[playerID]})
	end
end

-- Stops from casting on non-slayers.
function PulseStaffCheck( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:GetUnitName() ~= 'npc_dota_hero_invoker' then
		target:Stop()
		FireGameEvent('custom_error_show', {player_ID = playerID, _error = 'Can only be cast on Slayers!'})
		ability:EndCooldown()
		ability:RefundManaCost()
	else
		PulseStaff(keys)
	end
end

-- Targets a slayer, and jumps to the next nearest.
function PulseStaff( keys )
	local caster = keys.caster
	local target = keys.target
	local targetPos = target:GetAbsOrigin()
	local ability = keys.ability
	local targetTeam = ability:GetAbilityTargetTeam()
	local targetType = ability:GetAbilityTargetType()
	local abilityDamage = ability:GetSpecialValueFor('damage')
	local damageType = ability:GetAbilityDamageType()
	local playerID = caster:GetMainControllingPlayer()
	local owner = VAMPIRES[playerID]

	local chainP = ParticleManager:CreateParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(chainP, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(chainP, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ApplyDamage({victim = target, attacker = owner, damage = abilityDamage, damage_type = damageType})

	local newUnit = FindUnitsInRadius(caster:GetTeam(), targetPos, nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)

	for k, v in pairs(newUnit) do
		if v:GetUnitName() == 'npc_dota_hero_invoker' then
			newUnit = v
		end
	end
	if newUnit ~= nil then
		Timers:CreateTimer(0.15, function ()
			ParticleManager:SetParticleControlEnt(chainP, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(chainP, 1, newUnit, PATTACH_POINT_FOLLOW, "attach_hitloc", newUnit:GetAbsOrigin(), true)
			ApplyDamage({victim = newUnit, attacker = owner, damage = abilityDamage * 0.85, damage_type = damageType})
		end)
	end
end

-- Particles for immunity shield
function ShieldParticle(keys)
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	particle = ParticleManager:CreateParticle("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, Vector(100,0,100))
	ParticleManager:SetParticleControl(particle, 2, Vector(100,0,100))
	ParticleManager:SetParticleControl(particle, 4, Vector(100,0,100))
	ParticleManager:SetParticleControl(particle, 5, Vector(100,0,10))
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", casterPos, true)

	Timers:CreateTimer(10, function() 
		ParticleManager:DestroyParticle(particle,false)
	end)
end

-- Urn of dracula active, gold gain is in vampirism.lua
function UrnReveal( keys )
	local caster = keys.caster
	local playerID = caster:GetMainControllingPlayer()
	local target = keys.target_points[1]

	local urnSight = CreateUnitByName('vampire_vision_dummy_urn', target, false, caster, PlayerResource:GetPlayer(playerID), caster:GetTeam())

	Timers:CreateTimer(30, function ()
		urnSight:Destroy()
	end)
end

-- Rod of teleport area check and particles.
function RodTeleportation( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local playerID = caster:GetMainControllingPlayer()

	local detectRange = 32

	local checkUnits = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, detectRange, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	local isBlocked = false

	for k, v in pairs(checkUnits) do
		if v:GetTeam() == DOTA_TEAM_GOODGUYS then
			isBlocked = true
		end
	end

	if target:GetUnitName() == 'merc_assassin' then
		ability:EndCooldown()
		ability:RefundManaCost()
		caster:Stop()
		FireGameEvent('custom_error_show', {player_ID = playerID, _error = "Can't teleport to Assassins!"})
		return
	end

	if target:GetUnitName() == 'observer_ward' then
		ability:EndCooldown()
		ability:RefundManaCost()
		caster:Stop()
		FireGameEvent('custom_error_show', {player_ID = playerID, _error = "Can't teleport to Wards!"})
		return
	end

	if target:GetUnitName() == 'merc_fallen_hound' then
		ability:EndCooldown()
		ability:RefundManaCost()
		caster:Stop()
		FireGameEvent('custom_error_show', {player_ID = playerID, _error = "Can't teleport to fallen hounds!"})
		return
	end

	if target:IsHero() then
		if target:GetUnitName() ~= "research_center_vampire" then
			ability:EndCooldown()
			ability:RefundManaCost()
			caster:Stop()
			FireGameEvent('custom_error_show', {player_ID = playerID, _error = "Can't teleport to heroes!"})
			return
		end
	end

	if target:GetUnitName() == 'merc_avernal_meteor' then
		ability:EndCooldown()
		ability:RefundManaCost()
		caster:Stop()
		FireGameEvent('custom_error_show', {player_ID = playerID, _error = "Can't teleport to Avernal Meteors!"})
		return
	end

	if isBlocked then
		ability:EndCooldown()
		ability:RefundManaCost()
		caster:Stop()
		FireGameEvent('custom_error_show', {player_ID = playerID, _error = 'Need more space to teleport!'})
	else
		local pStart = ParticleManager:CreateParticle("particles/items2_fx/teleport_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		local casterPos = caster:GetAbsOrigin()
		ParticleManager:SetParticleControl(pStart, 0, casterPos)
		ParticleManager:SetParticleControl(pStart, 1, Vector(255,0,0))
		ParticleManager:SetParticleControl(pStart, 2, casterPos)
		ParticleManager:SetParticleControl(pStart, 3, casterPos)
		ParticleManager:SetParticleControl(pStart, 4, casterPos)
		ParticleManager:SetParticleControl(pStart, 5, casterPos)
		ParticleManager:SetParticleControl(pStart, 6, casterPos)

		local pEnd = ParticleManager:CreateParticle("particles/items2_fx/teleport_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(pEnd, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(pEnd, 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(pEnd, 2, Vector(255,0,0))
		Timers:CreateTimer(3, function (  )
			ParticleManager:DestroyParticle(pStart, false)
			ParticleManager:DestroyParticle(pEnd, false)
		end)
	end
end

-- Rod of teleport actual teleport.
function RodFinish( keys )
	local caster = keys.caster
	local target = keys.target

	local newSpace = FindGoodSpaceForUnit(caster, target:GetAbsOrigin(), 200, 128)
    if newSpace ~= false then
      caster:SetAbsOrigin(newSpace)
    end
end

-- Fel founds may only attack Engineers.
function FelHoundAttack( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local targetName = target:GetUnitName()

	if targetName ~= 'toolkit_engineer' then
		caster:AddNewModifier(caster, ability, 'modifier_disarmed', {duration = 0.1})
		FireGameEvent('custom_error_show', {player_ID = caster:GetMainControllingPlayer(), _error = 'Unit may only attack engineers!'})
	end
end

-- Trades 8000 wood for 1 gold.
function TradeWood( keys )
	local caster = keys.caster
	local target = keys.target
	local playerID = caster:GetMainControllingPlayer()

	GOLD[playerID] = GOLD[playerID] + 1
end

-- Targets a building, deals damage.
function BurstGem( keys )
	local caster = keys.caster
	local target = keys.target
	local targetPos = target:GetAbsOrigin()
	local ability = keys.ability
	local targetTeam = ability:GetAbilityTargetTeam()
	local targetType = ability:GetAbilityTargetType()
	local abilityDamage = ability:GetSpecialValueFor('damage')
	local damageType = ability:GetAbilityDamageType()

	if target:HasAbility('is_a_building') then
		local burst_projectile = {
			Target = target,
			Source = caster,
			Ability = ability,	
			EffectName = "particles/items_fx/ethereal_blade.vpcf",
			vSpawnOrigin = caster:GetAbsOrigin(),
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = targetTeam,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
			bDeleteOnHit = true,
			iMoveSpeed = 600,
			bProvidesVision = false,
			bDodgeable = false,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
		}
		projectile = ProjectileManager:CreateTrackingProjectile(burst_projectile)

	else
		ability:EndCooldown()
		ability:RefundManaCost()
		caster:Stop() 
		FireGameEvent('custom_error_show', {player_ID = playerID, _error = 'Can only target buildings!'})
	end
	
end

-- Fires when the projectile connects.
function BurstHit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local abilityDamage = ability:GetSpecialValueFor('damage')
	local damageType = ability:GetAbilityDamageType()
	local playerID = caster:GetMainControllingPlayer()
	local owner = VAMPIRES[playerID]

	local damage_table = {
		victim = target,
		attacker = caster,
		damage = abilityDamage,
		damage_type = damageType
	}

	ApplyDamage(damage_table)
end

-- Applies the damage to a unit entering a grave area.
function GraveDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local playerID = caster:GetMainControllingPlayer()
	-- Retrieve correct vampire owner.
	local owner = VAMPIRES[playerID]

	--change atacker to caster

	if not target:HasAbility('is_a_building') then
		local dmg = ApplyDamage({victim = target, attacker = caster, damage = 35, damage_type = DAMAGE_TYPE_MAGICAL})
		ability:ApplyDataDrivenModifier(owner, target, 'modifier_grave_apply_damage', {})
		if dmg >= target:GetHealth() then
			target.gravekilled = true
		end
	end
end

-- Continually applies damage to unit if they are still within the grave radius.
function ReApplyGraveDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target:HasModifier('modifier_grave_damage_aura') then
		GraveDamage(keys)
	end
end

-- Applies damage to nearby buildings.
function RainOfAvernus( keys )
	local caster = keys.caster
	local target = keys.target
	local playerID = caster:GetMainControllingPlayer()
	local owner = VAMPIRES[playerID]

	local nearBuildings = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)

	for k, v in pairs(nearBuildings) do
		if v:HasAbility('is_a_building') then
			ApplyDamage({victim = v, attacker = owner, damage = 1500, damage_type = DAMAGE_TYPE_MAGICAL})
		end
	end
end

-- Silences enemy units in a radius.
function SilentWhisper( keys )
	local caster = keys.caster
	local radius = 500
	local ability = keys.ability

	local nearUnits = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)

	for k, v in pairs(nearUnits) do
		if not v:HasAbility('is_a_building') then
			v:AddNewModifier(caster, nil, "modifier_silence", {duration = 30})
		end
	end
end

-- Removes negative debuffs, adds mana.
function RefreshPotion( keys )
	local caster = keys.caster
	caster:Purge(false, true, false, false, false)
	caster:GiveMana(25000)
end

-- Grants vision of a unit
function ShadowSight( keys )
	local caster = keys.caster
	local playerID = caster:GetMainControllingPlayer()
	local casterTeam = caster:GetTeam()
	local target = keys.target

	if target:HasAbility('is_a_building') == false then
		if target:IsHero() and target:IsConsideredHero() then
			target:AddNewModifier(caster, nil, 'modifier_bloodseeker_thirst_vision', {duration = 30})
		else
			target:AddNewModifier(caster, nil, ' modifier_bloodseeker_thirst_vision', {duration = 120})
		end
	else
		FireGameEvent('custom_error_show', {player_ID = playerID, _error = 'Cannot target buildings!'})
	end
end

-- Cyclones an enemy.
function CycloneWand( keys )
	local caster = keys.caster
	local target = keys.target

	target:AddNewModifier(caster, nil, "modifier_cyclone", {duration = 5})
end

-- Creates an observer ward, sets invisible.
function SpawnWard( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]

	local ward = CreateUnitByName("observer_ward", point, false, caster, caster, caster:GetTeam())
	ward:AddNewModifier(caster, nil, "modifier_invisible", {duration = 450})
	ability:ApplyDataDrivenModifier(ward, ward, "modifier_ward_time", {duration = 10})
end

-- Credit to kritth from SpellLibrary for this.
function HellfireGauntlets( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifierName = "modifier_hellfire_gauntlets_target_datadriven"
	local damageType = ability:GetAbilityDamageType()
	local exceptionName = "put_your_exception_unit_here"
	
	-- Necessary value from KV
	local duration = ability:GetLevelSpecialValueFor( "bonus_reset_time", ability:GetLevel() - 1 )
	local damage_per_stack = ability:GetLevelSpecialValueFor( "damage_per_stack", ability:GetLevel() - 1 )

	-- Check if unit already have stack
	if target:HasModifier( modifierName ) then
		local current_stack = target:GetModifierStackCount( modifierName, ability )
		
		-- Deal damage
		local damage_table = {
			victim = target,
			attacker = caster,
			damage = damage_per_stack * current_stack,
			damage_type = damageType
		}
		ApplyDamage( damage_table )
		
		ability:ApplyDataDrivenModifier( caster, target, modifierName, { Duration = duration } )
		target:SetModifierStackCount( modifierName, ability, current_stack + 1 )
	else
		ability:ApplyDataDrivenModifier( caster, target, modifierName, { Duration = duration } )
		target:SetModifierStackCount( modifierName, ability, 1 )
	end
end

-- Once again based heavily from SpellLibrary.
function RicochetGem( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local targetTeam = ability:GetAbilityTargetTeam()
	local targetType = ability:GetAbilityTargetType()
	local target_location = target:GetAbsOrigin()
	local abilityDamage = ability:GetSpecialValueFor('damage')
	local damageType = ability:GetAbilityDamageType()
	local playerID = caster:GetMainControllingPlayer()
	local owner = VAMPIRES[playerID]
	local jumps = 2
	local ricochetParticle = "particles/units/heroes/hero_rubick/rubick_fade_bolt.vpcf"
	local bounce_radius = 500
	local s_damage = 1500

	-- Setting up the hit table
	local hit_table = {}

	local count = 0

	if not target:HasAbility('is_a_building') then
		FireGameEvent('custom_error_show', {player_ID = playerID, _error = 'Can only target buildings!'})
		caster:Stop()
		ability:EndCooldown()
		ability:RefundManaCost()
		return
	end
	
	--No priority unlike in heal beam, just find nearest
	Timers:CreateTimer(function ()
	if count <= jumps then
		count = count + 1

		if count == 1 then
			local particle = ParticleManager:CreateParticle(ricochetParticle, PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			local damageTable = {
				victim = target,
				attacker = caster,
				damage = s_damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
			}
			ApplyDamage(damageTable)
			s_damage = s_damage * 0.85
			table.insert(hit_table, target)
			return 0.15
		end
		
		-- Helper variable to keep track if we damaged a unit already
		unit_damaged = false
	
		-- Find all the units in bounce radius
		local units = FindUnitsInRadius(caster:GetTeam(), target_location, nil, bounce_radius, targetTeam, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)

		for k, v in pairs(units) do
			if not v:HasAbility("is_a_building") or v:NotOnMinimap() == true then
				units[k] = nil
			end
		end

	  	for _,unit in pairs(units) do
		if unit ~= caster then
			local check_unit = 0  -- Helper variable to determine if a unit has been hit or not
	
			-- Checking the hit table to see if the unit is hit
			for c = 0, #hit_table do
				if hit_table[c] == unit then
					check_unit = 1
				end
			end
	
			-- If its not hit then check if the unit has been hit
			if check_unit == 0 then
	
				table.insert(hit_table, unit)
				local unit_location = unit:GetAbsOrigin()
		
				-- Create the particle for the visual effect
				local particle = ParticleManager:CreateParticle(ricochetParticle, PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
				ParticleManager:SetParticleControlEnt(particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit_location, true)
		
				-- Set the unit as the new target
				target = unit
				target_location = unit_location
		
				local damageTable = {
					victim = unit,
					attacker = caster,
					damage = s_damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
				}
				ApplyDamage(damageTable)
  	
				-- Set the helper variable to true
				unit_damaged = true
				s_damage = s_damage * 0.85
			break
			end
		end
	  end
	end
  return .15
  end)
end

-- Manages invis for assassins.
function AssassinInvis( keys )
	local caster = keys.caster
	local delay = keys.delay
	if delay ~= nil then
		Timers:CreateTimer(delay, function ()
			caster:AddNewModifier(caster, nil, 'modifier_invisible', {})
			return nil
		end)
	else
		caster:AddNewModifier(caster, nil, 'modifier_invisible', {})
	end
end

-- Sells the item in the first slot.
function VampireSell( keys )
	local caster = keys.caster
	local playerID = caster:GetMainControllingPlayer()

	if caster:GetItemInSlot(0) ~= nil then
		local item = caster:GetItemInSlot(0)
		local itemName = item:GetName()
		local woodCost = 0
		local goldCost = 0
		if ITEM_KV[itemName]['LumberCost'] ~= nil then
			woodCost = ITEM_KV[itemName]['LumberCost']
			ChangeWood(playerID, (woodCost / 2))
		end
		if ITEM_KV[itemName]['GoldCost'] ~= nil then
			goldCost = ITEM_KV[itemName]['GoldCost']
			ChangeGold(playerID, (goldCost / 2))
		end
		caster:RemoveItem(item)
	end
end
