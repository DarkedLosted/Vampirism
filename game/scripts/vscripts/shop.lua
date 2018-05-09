
function vampirism:OnShopBuy( keys )
  local pID = keys.pID
  local hero= EntIndexToHScript(keys.Eindex)
  local iname = keys.itemname
  local player = hero:GetPlayerOwner()
  local iIndex = keys.ItemIndex
  if  iname   then
    local item = CreateItem(iname, hero, hero)
    local gold_cost = item:GetSpecialValueFor("gold")
    local lumber_cost = item:GetSpecialValueFor("lumber")
    if PlayerHasEnoughGold(hero:GetPlayerOwner(),gold_cost) and PlayerHasEnoughLumber(hero:GetPlayerOwner(),lumber_cost) then
          
      if hero:GetUnitName() == "npc_dota_hero_night_stalker" then
        for k,vamp in pairs(vampires) do
          
          CustomGameEventManager:Send_ServerToPlayer(vamp:GetPlayerOwner(), "item_stock", {iIndex=iIndex,timeRestock=GetItemKV(uname,"TimeRestock") or 120,shop=2})
        end
      hero:AddItem(item)
        if iname=="item_demonic_remains" then
        Vampire_msg(player,"<font color='#ad0c0c'>Demonic Remains</font> , now for some Me time","night_stalker_nstalk_ability_dark_07",6,"all")
        end
        if iname=="item_sphere_of_doom" then
        Vampire_msg(player,"<font color='#ad0c0c'>Sphere of Doom</font> , Quick as a blink","night_stalker_nstalk_blink_02",6,"all")
        end
      end
      print(hero:GetUnitName())
      if hero:GetUnitName() == "npc_dota_hero_kunkka" then
        for k,human in pairs(players) do
          if human:GetTeamNumber() == 2 then
            CustomGameEventManager:Send_ServerToPlayer(human, "item_stock", {iIndex=iIndex,timeRestock=GetItemKV(uname,"TimeRestock") or 120,shop=1})
          end
        end
        player.slayer:AddItem(item)
      end
    hero:ModifyGold(-gold_cost,false,0)
    CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "player_gold_changed", {})
    ModifyLumber(hero:GetPlayerOwner(),-lumber_cost)
    end
  end
end

function vampirism:OnHire( keys )
  local pID = keys.pID
  local hero= EntIndexToHScript(keys.Eindex)
  
  local uname = keys.unitname
  local position = hero:GetAbsOrigin()
  local gold_cost = GetUnitKV(uname,"GoldCost") or 0
  local food_cost = GetUnitKV(uname,"FoodCost") or 0
  local lumber_cost = GetUnitKV(uname,"LumberCost") or 0
  local player = hero:GetPlayerOwner()
    
  if PlayerHasEnoughFood(player,food_cost) and PlayerHasEnoughLumber(player,lumber_cost) and PlayerHasEnoughGold(player,gold_cost) then 
    hero:ModifyGold(-gold_cost,false,0)
    CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "player_gold_changed", {})

    ModifyLumber(player,-lumber_cost)
    ModifyFood(player,food_cost)
    local new_unit = CreateUnitByName(uname, position, true, hero, hero, 3)
        new_unit:SetOwner(hero)
        new_unit:SetControllableByPlayer(pID, true)
        new_unit:SetAbsOrigin(position)
        --new_unit:SetHealth(health)
        if uname ~= "Shade" and uname ~= "French_Man" then
        new_unit:SetHullRadius(35)
        end
        FindClearSpaceForUnit(new_unit, position, true)
  end     
end