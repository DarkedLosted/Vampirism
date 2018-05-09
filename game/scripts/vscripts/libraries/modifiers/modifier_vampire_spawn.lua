modifier_vampire_spawn = class({})

--------------------------------------------------------------------------------

function modifier_vampire_spawn:IsHidden()
	return true
end
function modifier_vampire_spawn:OnCreated( kv )
	if IsServer() then
		--self:GetParent():AddEffects( EF_NODRAW )
		self.vPos = self:GetParent():GetOrigin()
		self.bTPFinished = false
		local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "follow_origin", self:GetCaster():GetOrigin(), true )
		self:AddParticle( nFXIndex, false, false, -1, false, true )
--particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7buff_flash.vpcf
	end

end





function modifier_vampire_spawn:CheckState()
	local state = 
	{
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_TEAM_MOVE_TO] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_DISARMED] = true,
		
	}
	
	return state
end

function modifier_vampire_spawn:OnTeleported( params )
	if IsServer() then
		if params.unit == self:GetParent() and self.bTPFinished == false then
			self.bTPFinished = true
			--FindClearSpaceForUnit( self:GetParent(), self.vPos, true )
			self:GetParent():RemoveEffects( EF_NODRAW )
			self:Destroy()

		end	
	end
end

function modifier_vampire_spawn:IsDebuff()
	return false
end

function modifier_vampire_spawn:GetTexture()
	return "rune_regen"
end

function modifier_vampire_spawn:GetEffectName()

	return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom_ring.vpcf"
end

