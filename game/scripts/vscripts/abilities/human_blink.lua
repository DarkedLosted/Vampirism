function Blink (keys)
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	print('hello')
	if IsBlocked(point) then
		ability:RefundManaCost()
		caster:Stop()
		SendErrorMessage(caster:GetPlayerID(), "Target position is off the map")
	end
end