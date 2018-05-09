function Vision (keys)
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", ability_level) 
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability_level) 


	local dummy = CreateUnitByName("dummy_vision"..vision_radius, target, false, caster, caster, caster:GetTeamNumber())
	local particle = ParticleManager:CreateParticle("particles/econ/items/bane/slumbering_terror/bane_slumber_blob.vpcf", PATTACH_WORLDORIGIN, dummy)
	local circle = ParticleManager:CreateParticle("particles/econ/items/bounty_hunter/bounty_hunter_hunters_hoard/bounty_hunter_hoard_track_trail_circle.vpcf", PATTACH_WORLDORIGIN, dummy)
	local pos = dummy:GetAbsOrigin()
	pos[3]=pos[3]+500
	ParticleManager:SetParticleControl(particle, 0, pos)
	ParticleManager:SetParticleControl(circle, 0, pos)

	EmitSoundOnLocationWithCaster(target,"DOTA_Item.DustOfAppearance.Activate",dummy)
	--AddFOWViewer(caster:GetTeamNumber(),pos,vision_radius,vision_duration+15,true)
	local enemyarr = FindUnitsInRadius(2, pos, nil, vision_radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	        	
		            for key,enemy in pairs(enemyarr) do
		            	 if not enemy:IsHero() and enemy:GetUnitLabel() ~="gatherunit" and enemy:GetUnitLabel() ~="Builder"  then
		            	 enemy:SetVision(true)
		            	end
		            	if not enemy.alert then
		            		enemy.alert=GameRules:GetDOTATime(false,false)-60
		            	end
		            	if enemy:GetUnitName() == "npc_dota_hero_kunkka" and (GameRules:GetDOTATime(false,false)-enemy.alert)>60 then
		            		print("enemy:"..enemy.alert)
		            		print("now time:"..GameRules:GetDOTATime(false,false))
		            		enemy.alert=GameRules:GetDOTATime(false,false)
		            		Vampire_msg(enemy:GetOwner(),"Night comes for you","night_stalker_nstalk_kill_07",7,"one")
		            	end
		            end
		      
	Timers:CreateTimer(vision_duration, function()
		dummy:RemoveSelf()
		ParticleManager:DestroyParticle(particle,false)
		ParticleManager:DestroyParticle(circle,false)
	end)
end

function CDOTA_BaseNPC:SetVision(bAble)
		    if bAble then
		        self:AddNewModifier(self, nil, "modifier_fow_vision", {})
		         -- self:AddNewModifier(self, nil, "modifier_FORCE_DRAW_MINIMAP", {})
		         -- Timers:CreateTimer(15,function ()
		         -- 	 self:RemoveModifierByName("modifier_fow_vision")
		         -- 	end)
		    else
		        self:RemoveModifierByName("modifier_fow_vision")
		    end
		end