modifier_upgrade_building = class({})

function modifier_upgrade_building:IsHidden()
    return true
end

function modifier_upgrade_building:GetEffectName()
	return "particles/econ/items/lina/lina_ti6/lina_ti6_ambient_ground_dust.vpcf"
end
 
--------------------------------------------------------------------------------
 
function modifier_upgrade_building:GetEffectAttachType()
	return PATTACH_ABSORIGIN
end