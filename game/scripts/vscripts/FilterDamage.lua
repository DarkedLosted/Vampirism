
function vampirism:FilterDamage( filterTable )

    local victim_index = filterTable["entindex_victim_const"]
    local attacker_index = filterTable["entindex_attacker_const"]
   
    if not victim_index or not attacker_index then
        return true
    end

    local victim = EntIndexToHScript( victim_index )
    local attacker = EntIndexToHScript( attacker_index )

    if attacker:GetTeamNumber() == 3 then
    MapAlert(victim)
    end
    
    if  victim:GetUnitLabel() ~= "gatherunit" and attacker:GetUnitName() == "Assasin" then
        return false
    end

    if   attacker:GetUnitName() ~="npc_dota_hero_kunkka" then
        return true
    end

        PrintTable(filterTable)                
    if attacker:GetPlayerOwner() == victim:GetPlayerOwner() then
    	if victim:IsDeniable() then
    		 filterTable["damage"] = 100000
             PrintTable(filterTable)  
    		return true
    	end
    end
end