modifier_fow_vision = class({})
--------------------------------------------------------------------------------

function modifier_fow_vision:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_fow_vision:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_fow_vision:DeclareFunctions()
	local funcs = 
	{
		
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
	}
	return funcs
end


--------------------------------------------------------------------------------

function modifier_fow_vision:GetModifierProvidesFOWVision( params )
	return 1
end