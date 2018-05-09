modifier_pre_build = class({})

function modifier_pre_build:CheckState() 
  local state = {
      [MODIFIER_STATE_SILENCED] = true,
  }

  return state
end

function modifier_pre_build:IsHidden()
    return true
end