modifier_client_convars = class({})

function modifier_client_convars:OnCreated()
    if IsClient() then
        local hUnit = self:GetParent()
        local hName = hUnit:GetUnitName()
        -- if hName == "npc_dota_hero_kunkka" then
        SendToConsole("dota_player_units_auto_attack_mode 0") 
        -- print("Human Client")
        --  end
        --  if hName == "npc_dota_hero_night_stalker" then
        --  SendToConsole("dota_player_units_auto_attack_mode 2") --Always
        --  print("Vampire Client")
        --  end
        SendToConsole("dota_player_add_summoned_to_selection 0")


        SendToConsole("dota_summoned_units_auto_attack_mode -1") --Same as hero
        SendToConsole("dota_force_right_click_attack 0")
        SendToConsole("dota_player_multipler_orders 0")
    end
end

function modifier_client_convars:IsHidden()
    return true
end

function modifier_client_convars:IsPurgable()
    return false
end