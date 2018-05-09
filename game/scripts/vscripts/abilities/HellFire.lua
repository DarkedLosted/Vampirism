function HellFireEquip ( keys )
	local caster = keys.caster
	local target = keys.target
	local player = caster:GetOwner() 
	local pID = player:GetPlayerID()
	local state = keys.state
	if state == "equip" then
	local abil = caster:AddAbility("hellfire_stacks")
	abil:SetLevel(1)
	abil:SetHidden(true) 
	else
	 caster:RemoveAbility("hellfire_stacks")
	end
end
