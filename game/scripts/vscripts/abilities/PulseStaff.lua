function PulseStaff ( keys )
	local caster = keys.caster
	local target = keys.target
	local player = caster:GetOwner() 
	local pID = player:GetPlayerID()

	local abil = caster:AddAbility("pulse_staff_bolt")
	abil:SetLevel(1)
	abil:SetHidden(true)
		  		if abil then
			   		if abil:IsFullyCastable() then
			      		Timers:CreateTimer(0.1, function() 
			      			 caster:CastAbilityOnTarget(target,abil,pID)
			      			end)
			      	end
			     end
			     Timers:CreateTimer(3.5, function() 
			     caster:RemoveAbility("pulse_staff_bolt")
			     end)
end