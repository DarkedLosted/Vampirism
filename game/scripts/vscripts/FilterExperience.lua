

function vampirism:FilterExperience( filterTable )
    local experience = filterTable["experience"]
    local playerID = filterTable["player_id_const"]
    local reason = filterTable["reason_const"]
    -- Disable all hero kill experience
    if reason == DOTA_ModifyXP_HeroKill then
    	local hero = PlayerResource:GetPlayer(playerID):GetAssignedHero()
    	if hero:GetUnitName() == "npc_dota_hero_night_stalker" then
    		return true
    	end
        return false
    end

    return true
end
