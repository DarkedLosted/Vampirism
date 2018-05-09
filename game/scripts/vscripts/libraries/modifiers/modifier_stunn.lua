modifier_stunn = class({})

function modifier_stunn:CheckState() 
  local state = {
      [MODIFIER_STATE_NIGHTMARED] = true,
  }

  return state
end
function modifier_stunn:GetEffectName()
    return 0
end
function modifier_stunn:OnSpellStart()
   
    	
    	print("olsdfolsoflsoglosdgo")
    
end
function modifier_stunn:IsHidden()
    return true
end