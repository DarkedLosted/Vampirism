require('vampirism')

function vampirism:ResearchStart( keys )
    local pID = keys.pID
    local hero= EntIndexToHScript(keys.Eindex)
    local player = hero:GetOwner()
    local Rname= keys.ResearchName
    local Buildingname=keys.Buildingname
    local casted = false

    for key,value in pairs(player.structures) do
        
        if not value:IsNull() then
           
           
            print(Buildingname)
            print(value:GetUnitName())
            if value:GetUnitName() == Buildingname then
                if value then
                 local ResearchName = value:FindAbilityByName(Rname)
                    if ResearchName then
                        ResearchName:SetHidden(false)
                        if ResearchName:IsFullyCastable() then
                            Timers:CreateTimer(0.3, function() 
                                 value:CastAbilityNoTarget(ResearchName,value:GetPlayerOwnerID())
                                 casted=true
                                end)
                            return
                        end
                    end
                end
            end
        end
    end
    if not casted then
        CustomGameEventManager:Send_ServerToPlayer( player, "ResearchStop" ,player)
        SendErrorMessage(pID, "#Need "..Buildingname)
    end
end

function vampirism:ResearchCancel( keys )
    local pID = keys.pID
    local hero= EntIndexToHScript(keys.Eindex)
    local player = hero:GetOwner()
    local Rname= keys.ResearchName
    local itemname = "item_"..Rname
    local Buildingname=keys.Buildingname

    for key,value in pairs(player.structures) do
        if value:GetUnitName() == Buildingname then
            if value then
                if value:HasItemInInventory(itemname) then
                    local item = value:GetItemInSlot(DOTA_ITEM_SLOT_1)
                    Timers:CreateTimer(0.1, function() 
                        ExecuteOrderFromTable({ UnitIndex = value:entindex(), AbilityIndex = item:entindex() , OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET, Queue = false})
                        end)
                end
            end
        end
    end

end

XP_PER_LEVEL_TABLE = {
  0, -- 1
  200, -- 2
  500, -- 3
  900, -- 4
  1400, -- 5
 2000, -- 6
 2700, -- 7
 3500, -- 8
 4400, -- 9
 5400, -- 10
 6500, -- 11
 7700, -- 12
 9000, -- 13
 10400, -- 14
 11900, -- 15
 13500, -- 16
 15200, -- 17
 17000, -- 18
 18900, -- 19
 20900, -- 20
23000, -- 21
25200, -- 22
27500, -- 23
29900, -- 24
32400,  -- 25
35000, -- 26
 37700, -- 27
 40500, -- 28
 43400, -- 29
 46400, -- 30
49500, -- 31
52700, -- 32
56000, -- 33
59400, -- 34
62900,  -- 35
 66500, -- 36
 70200, -- 37
 74000, -- 38
 77900, -- 39
 81900, -- 40
 86000, -- 41
 90200, -- 42
 94500, -- 43
 98900, -- 44
 103400, -- 45
 108000, -- 46
 112700, -- 47
 117500, -- 48
 122400, -- 49
 127400, -- 50
 132400, -- 51
}
for i=52,200 do
  XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i - 1] + (i * 90)
end