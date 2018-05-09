FORCE_DRAW_MINIMAP = class({})
--------------------------------------------------------------------------------

function FORCE_DRAW_MINIMAP:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function FORCE_DRAW_MINIMAP:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function FORCE_DRAW_MINIMAP:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_FORCE_DRAW_MINIMAP,
		
	}
	return funcs
end

function FORCE_DRAW_MINIMAP:GetForceDrawOnMinimap()
	return 1
end
--------------------------------------------------------------------------------
