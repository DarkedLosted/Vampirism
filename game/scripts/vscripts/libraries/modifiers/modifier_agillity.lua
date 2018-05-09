modifier_agillity = class({})


function modifier_agillity:GetModifierBonusStats_Agility(params)
   if IsServer() then
   
       return self:GetStackCount() *100;
       end
    
end

function modifier_agillity:DeclareFunctions()
    return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end


function modifier_agillity:IsHidden()
  return true
end

function modifier_agillity:IsDebuff() 
  return false
end

function modifier_agillity:IsPurgable() 
  return false
end