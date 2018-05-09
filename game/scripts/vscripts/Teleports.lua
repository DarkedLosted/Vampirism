function TeleportToBase_one ( event )

     local unit = event.activator
     
    		local player = PlayerResource:GetPlayer( unit:GetPlayerOwner():GetPlayerID() )
			local particleName = "particles/items2_fx/teleport_end_tube.vpcf" 
			local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, unit, player )
			ParticleManager:SetParticleControl( particle, 0, unit:GetAbsOrigin() )
			ParticleManager:SetParticleControl( particle, 1, unit:GetAbsOrigin() )

	     local  tp_point = "tp_base1_end"

	     local EntPoint = Entities:FindByName( nil, tp_point) 
	     local location = EntPoint:GetAbsOrigin() 
	     event.activator:SetAbsOrigin( location ) 
	     FindClearSpaceForUnit(event.activator, location, false) 
	     event.activator:Stop() 
		  EmitSoundOnClient("dota_vr.map_portal",unit:GetPlayerOwner())

			
end

function TeleportToBase_one_back ( event )

     local unit = event.activator
    	
    		local player = PlayerResource:GetPlayer( unit:GetPlayerOwner():GetPlayerID() )
			local particleName = "particles/items2_fx/teleport_end_tube.vpcf" 
			local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, unit, player )
			ParticleManager:SetParticleControl( particle, 0, unit:GetAbsOrigin() )
			ParticleManager:SetParticleControl( particle, 1, unit:GetAbsOrigin() )

	     local tp_point = "tp_outbase1_end" 

	     local EntPoint = Entities:FindByName( nil, tp_point) 
	     local location = EntPoint:GetAbsOrigin() 
	     event.activator:SetAbsOrigin( location )
	     FindClearSpaceForUnit(event.activator, location, false)
	     event.activator:Stop()
	     EmitSoundOnClient("dota_vr.map_portal",unit:GetPlayerOwner())
end

function TeleportToBase_second( event )

     local unit = event.activator
     	 
     		local player = PlayerResource:GetPlayer( unit:GetPlayerOwner():GetPlayerID() )
			local particleName = "particles/items2_fx/teleport_end_tube.vpcf" 
			local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, unit, player )
			ParticleManager:SetParticleControl( particle, 0, unit:GetAbsOrigin() )
			ParticleManager:SetParticleControl( particle, 1, unit:GetAbsOrigin() )

	     local  tp_point = "tp_base2_end"

	     local EntPoint = Entities:FindByName( nil, tp_point) 
	     local location = EntPoint:GetAbsOrigin() 
	     event.activator:SetAbsOrigin( location ) 
	     FindClearSpaceForUnit(event.activator, location, false) 
	     event.activator:Stop() 
		  EmitSoundOnClient("dota_vr.map_portal",unit:GetPlayerOwner())
end

function TeleportToBase_second_back ( event )

     local unit = event.activator
   			
   			 local player = PlayerResource:GetPlayer( unit:GetPlayerOwner():GetPlayerID() )
			local particleName = "particles/items2_fx/teleport_end_tube.vpcf" 
			local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, unit, player )
			ParticleManager:SetParticleControl( particle, 0, unit:GetAbsOrigin() )
			ParticleManager:SetParticleControl( particle, 1, unit:GetAbsOrigin() )
			
	     local tp_point = "tp_outbase2_end" 

	     local EntPoint = Entities:FindByName( nil, tp_point) 
	     local location = EntPoint:GetAbsOrigin() 
	     event.activator:SetAbsOrigin( location )
	     FindClearSpaceForUnit(event.activator, location, false)
	     event.activator:Stop()
	       EmitSoundOnClient("dota_vr.map_portal",unit:GetPlayerOwner())
end