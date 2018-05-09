function Dispell( keys )
  local caster=keys.caster
	  caster:Kill(nil,nil) 

	  local KillIndex = ParticleManager:CreateParticle("particles/econ/items/riki/riki_immortal_ti6/riki_immortal_ti6_blinkstrike_r_backstab_hit_blood.vpcf", PATTACH_ABSORIGIN, caster)
	  Timers:CreateTimer( 0.5, function()
		ParticleManager:DestroyParticle( KillIndex, false )
		return nil
		end
	)

end