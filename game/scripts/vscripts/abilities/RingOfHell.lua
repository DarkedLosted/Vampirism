function RingGhostsStart( event  )
	 local caster = event.caster
    local ability = event.ability
    local playerID = caster:GetPlayerID()
    local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
    local damage = ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 )
    local ghost = ability:GetLevelSpecialValueFor( "ghost", ability:GetLevel() - 1 )
    local speed = ability:GetLevelSpecialValueFor( "speed", ability:GetLevel() - 1 )
    local cooldown = ability:GetLevelSpecialValueFor( "cooldown", ability:GetLevel() - 1 )
    local interval = ability:GetLevelSpecialValueFor( "interval", ability:GetLevel() - 1 )
    local unit_name = "ring_hell_ghost"
    local iscooldown = false 
    caster.count=0
    Timers:CreateTimer(function ()
    	if not caster then
    		return nil
    	end
    	if not caster:HasItemInInventory("item_ring_hell_lords") then
    		return nil
    	end
	        	local enemyarr = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	        	
		            for key,enemy in pairs(enemyarr) do
		            	if enemy:GetTeam() ~= caster:GetTeam() and enemy:GetUnitName() ~= unit_name and not enemy:IsInvulnerable() then
		            		--ability:ApplyDataDrivenModifier(caster, enemy, "modifier_ghost", {})
		            			caster.target  = enemy
		            			if  iscooldown == false then
			            			RingGhostsPhysics(caster,ability)
			            			caster.count = caster.count +1
			            		end
			            		
			            		if caster.count == ghost then
			            			caster.count =0
			            			iscooldown=true
			            			 Timers:CreateTimer( cooldown, function()
			            			  iscooldown = false  
			            			   end)
		            			end
		            	end
		            end
	    return 0.2
    end)
end



function RingGhostsPhysics( caster ,ability)
    local damage = ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 )
    local speed = ability:GetLevelSpecialValueFor( "speed", ability:GetLevel() - 1 )
    local particlename= "particles/units/heroes/hero_arc_warden/arc_warden_wraith_prj_burst.vpcf"

     local unit = CreateUnitByName("ring_hell_ghost", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())

     --ability:ApplyDataDrivenModifier(unit, "modifier_ghost", {})
     unit.current_target = caster.target
	    -- Make the spirit a physics unit
	Physics:Unit(unit)

	-- General properties
	unit:PreventDI(true)
	unit:SetAutoUnstuck(false)
	unit:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	unit:FollowNavMesh(false)
	unit:SetPhysicsVelocityMax(speed)
	unit:SetPhysicsVelocity(caster.target:GetAbsOrigin() )
	unit:SetPhysicsFriction(0)
	unit:Hibernate(false)
	unit:SetGroundBehavior(PHYSICS_GROUND_LOCK)


 	local point = caster.target:GetAbsOrigin()
	--point.z = GetGroundHeight(point,nil)

	-- This is set to repeat on each frame
	unit:OnPhysicsFrame(function(unit)

    -- Move the unit orientation to adjust the particle
    unit:SetForwardVector( ( unit:GetPhysicsVelocity() ):Normalized() )

    -- Movement and Collision detection are state independent
    -- Current positions
	local source = caster:GetAbsOrigin()
	local current_position = unit:GetAbsOrigin()
	local enemies = nil
    -- MOVEMENT 
    -- Get the direction
    local diff = point - unit:GetAbsOrigin()
    diff.z = 0
    local direction = diff:Normalized()

    -- Calculate the angle difference
    local angle_difference = RotationDelta(VectorToAngles(unit:GetPhysicsVelocity():Normalized()), VectorToAngles(direction)).y
        
    -- Set the new velocity
    if math.abs(angle_difference) < 5 then
    -- CLAMP
    local newVel = unit:GetPhysicsVelocity():Length() * direction
    unit:SetPhysicsVelocity(newVel)
    elseif angle_difference > 0 then
    local newVel = RotatePosition(Vector(0,0,0), QAngle(0,10,0), unit:GetPhysicsVelocity())
    unit:SetPhysicsVelocity(newVel)
    else        
    local newVel = RotatePosition(Vector(0,0,0), QAngle(0,-10,0), unit:GetPhysicsVelocity())
    unit:SetPhysicsVelocity(newVel)
    end

    -- COLLISION CHECK
    local distance = (point - current_position):Length()
    local collision = distance < 10

    -- STATE DEPENDENT LOGIC
    -- Damage, Healing and Targeting are state dependent.
    -- Check the full script on SpellLibrary
  	-- MAX DISTANCE CHECK
		if collision then

				-- If the target was an enemy and not a point, the unit collided with it
				if unit.current_target ~= nil then
					
					-- Damage, units will still try to collide with attack immune targets but the damage wont be applied
					if not unit.current_target:IsAttackImmune() then
						local damage_table = {}

						local spirit_damage = damage
						damage_table.victim = unit.current_target
						damage_table.attacker = caster					
						damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
						damage_table.damage = damage

						ApplyDamage(damage_table)

					local particle = ParticleManager:CreateParticle(particlename, PATTACH_ABSORIGIN, unit.current_target)
					ParticleManager:SetParticleControl(particle, 0, unit.current_target:GetAbsOrigin())
					ParticleManager:SetParticleControlEnt(particle, 3, unit.current_target, PATTACH_POINT_FOLLOW, "attach_hitloc", unit.current_target:GetAbsOrigin(), true)

						unit:ForceKill(false)
						UTIL_Remove(unit) 

					end
	
			end
			
		end

	end)

end
