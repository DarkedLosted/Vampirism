modifier_fountain_aura_lua = class({})

--------------------------------------------------------------------------------

function modifier_fountain_aura_lua:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_fountain_aura_lua:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_fountain_aura_lua:GetModifierAura()
	return "modifier_fountain_aura_effect_lua"
end

--------------------------------------------------------------------------------

function modifier_fountain_aura_lua:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

--------------------------------------------------------------------------------

function modifier_fountain_aura_lua:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_fountain_aura_lua:GetAuraDuration()
	return 0.1
end

--------------------------------------------------------------------------------

function modifier_fountain_aura_lua:GetAuraRadius()
	return 675
end
