function vampirism:FilterGold( filterTable )
    local gold = filterTable["gold"]
    local playerID = filterTable["player_id_const"]
    local reason = filterTable["reason_const"]
   -- CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "player_gold_changed", {})
  -- DeepPrintTable(filterTable)
    -- print("gold "..PlayerResource:GetGold(playerID))
    -- -- Disable all hero kill gold
    if reason == DOTA_ModifyGold_HeroKill then
    -- 	-- local hero = PlayerResource:GetPlayer(playerID):GetAssignedHero()
    -- 	-- if hero:GetUnitName() == "npc_dota_hero_night_stalker" then
    -- 	--  filterTable["gold"]=15
    -- 	--  CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "player_gold_changed", {})
    -- 	--  return true
   	-- 	-- end
   		gold=0
        return false
    end
    --  print("reason gold fonter:"..reason)
    --print ("this message must be see every whereeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee")
    return true
end