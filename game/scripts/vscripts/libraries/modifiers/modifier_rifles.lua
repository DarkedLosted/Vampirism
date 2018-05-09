modifier_rifles = class({})


function modifier_rifles:GetModifierAttackRangeBonus(params)
   if IsServer() then
       return 600;
       end
    
end

function modifier_rifles:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end


function modifier_rifles:IsHidden()
  return true
end

function modifier_rifles:IsDebuff() 
  return false
end

function modifier_rifles:IsPurgable() 
  return false
end