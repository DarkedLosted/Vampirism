modifier_low_priority = class({})

function modifier_low_priority:CheckState() 
    return { [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true, }
end

function modifier_low_priority:IsHidden()
    return true
end

function modifier_low_priority:IsPurgable()
    return false
end