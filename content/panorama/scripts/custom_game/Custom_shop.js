"use strict";
var Container = $("#ShopContainer")
var Root = $.GetContextPanel()
var LocalPlayerID = Game.GetLocalPlayerID()
var hidden = false;
var buttons = {}
var stock = {}
var timers = []
var units = [
    "Shade",
    "Abomination",
    "Fel_Beast",
    "Assasin",
    "French_Man",
    "Infernal",
    "Doom_Guard",
    "Meat_Carrier",
    ""
]
var HumanItems = [
    "item_pendant_mana",
    "item_pendant_vitality",
    "item_orb_venom",
    "item_summon_engineers",
    "item_Master_Slayer",
    "item_Circlet_Slayer",
    "item_Divinity_Jewel",
    "item_gold_convert"
]
var items = [
    "item_vampiric_boots",
    "item_sphere_of_doom",
    "item_vamp_invul",
    "item_dracula_helm",
    "item_ring_hell_lords",
    "item_pulse_staff",
    "item_immunity_shield",
    "item_urn_dracula",
    "item_demonic_remains",
    "item_rod_of_teleportation",
    "item_burst_gem",
    "item_build_massive_grave",
    "item_cloak_of_shadows",
    "item_windwalk_potion",
    "item_silent_whisper",
    "item_refresh_potion",
    "item_claws_dreadlord",
    "item_gaunthlets_underworld",
    "item_gaunthlets_hellfire",
    "item_replenishment_potion",
    "item_scroll_of_beast",
    "item_shop_ring_regen",
    "item_shop_att",
    "item_shop_ring_protection",
    "item_sentry_wards",
    "item_wand_cyclone",
    "item_wand_shadowsight",
    "item_pendant_mana",
    "item_pendant_vitality",
    "item_orb_venom",
    "item_summon_engineers",
    "item_Master_Slayer",
    "item_Circlet_Slayer",
    "item_Divinity_Jewel",
    "item_gold_convert"
]

function Toggle() {


    if (hidden) {
        hidden = false;
        Container.SetHasClass("Hidden", true)
        $.Msg("Hidden - true")
        Game.EmitSound("Shop.PanelDown");

    } else {
        hidden = true;
        Container.SetHasClass("Hidden", false)
        $.Msg("Hidden - false")
        Game.EmitSound("Shop.PanelUp");

    }
}

function ToggleTab(name) {
    $("#BasicItemsTab").hittest = true;
    // $("#SummContainerTab").RemoveAndDeleteChildren();
    // $("#ItemsContainerTab").RemoveAndDeleteChildren();
    // $("#GuideContainerTab").RemoveAndDeleteChildren();
    var Items = $("#ItemsContainerTab")
    var Summons = $("#SummContainerTab")
    var Guide = $("#GuideContainerTab")
    // if(name=="item"){ Items.SetHasClass("Hidden",false); Summons.SetHasClass("Hidden",true); Guide.SetHasClass("Hidden",true)
    // ItemPanelInitial();
    //  }
    // if(name=="summ"){ Items.SetHasClass("Hidden",true); Summons.SetHasClass("Hidden",false); Guide.SetHasClass("Hidden",true) 
    // Items.RemoveClass("item");
    //  SummPanelInitial();
    // }
    // if(name=="guide"){ Items.SetHasClass("Hidden",true); Summons.SetHasClass("Hidden",true); Guide.SetHasClass("Hidden",false) 

    // }
    if (name == "item") {
        Items.SetHasClass("Hidden", false);
        Summons.SetHasClass("Hidden", true);
        Guide.SetHasClass("Hidden", true)
        $("#SummContainerTab").SetHasClass("Hidden", true)
        $("#ItemsContainerTab").SetHasClass("Hidden", false)
    }
    if (name == "summ") {
        Items.SetHasClass("Hidden", true);
        Summons.SetHasClass("Hidden", false);
        Guide.SetHasClass("Hidden", true)
        $("#SummContainerTab").SetHasClass("Hidden", false)
        $("#ItemsContainerTab").SetHasClass("Hidden", true)
    }
    if (name == "guide") {
        Items.SetHasClass("Hidden", true);
        Summons.SetHasClass("Hidden", true);
        Guide.SetHasClass("Hidden", false)

    }
}


function CreateTimer(time, name) {
    time = time + Game.Time()
    timers[timers.length] = {
        time: time,
        function: name
    }
}

function update() {
    var CurrentTime = Game.Time()
    for (var i = 0; i < timers.length; i++) {
        if (timers[i].time <= CurrentTime) {

            var callback = timers[i]["function"]();
            if (callback == null) {
                timers.splice(i, 1)
            } else {
                timers[i].time = CurrentTime + callback
            }

        }
    }
    $.Schedule(0.01, update);
}

function stocking(event) {
    var panel = event.iIndex
    var time = event.timeRestock
    var store = event.shop
    if (stock[items[panel]] == "out" || stock[HumanItems[panel]] == "out") {
        return
    }
    if (store == 2) {
        stock[items[panel]] = "out"
    }
    if (store == 1) {
        stock[HumanItems[panel - 27]] = "out"
    }
    //UpdateTimer(30.0)

    //var time=3
    var timeStart = Game.Time()


    CreateTimer(1, function() {

        var timerValue = Math.max(0, Math.floor(Game.Time()) - Math.floor(timeStart));
        var spintime = Game.Time() - timeStart
        var deg = 360 - ((360 / time)) * spintime
        if ($("#Item" + panel)) {
            $("#ItemStock" + panel).style.clip = "radial(50% 50%, 0deg, " + deg + "deg)";
            $("#ItemStock" + panel).style.backgroundColor = "black"
            $("#ItemStock" + panel).style.opacity = "0.90";
        }
        if (timerValue == time || timerValue > time - 1) {
            if (store == 2) {
                stock[items[panel]] = ""
            }
            if (store == 1) {
                stock[HumanItems[panel - 27]] = ""
            }
            return null;
        }
        return 1
        //$("#Item"+panel).SetHasClass("OutStock",true)
    })

    //$.DispatchEvent("UIShowCustomLayoutParametersTooltip", panel, "ItemTooltip", "file://{resources}/layout/custom_game/ShopToolTip.xml","teststring="+panel.id);
}

function GameStart() {
    var event = {};
    event.iIndex = 17;
    event.timeRestock = 2100;
    event.shop = 2;
    stocking(17, 2100, 2);
    event.iIndex = 18;
    stocking(18, 2100, 2);
    event.iIndex = 7;
    event.timeRestock = 940;
    stocking(7, 940, 2);
}

function SummPanelInitial() {
    var Summons = $("#SummContainerTab")
    var uindex = 0;
    for (var i = 0; i < 3; i++) {
        var SummItem = $.CreatePanel("Panel", Summons, 'SummItem' + i)
        SummItem.AddClass("SummItem")
        for (var j = 0; j < 3; j++) {
            (function() {

                var table = CustomNetTables.GetTableValue("upgrades", "UnitHire");
                if (units[uindex] != "") {
                    var gold = table[units[uindex]].gold
                    var lumber = table[units[uindex]].lumber

                    var Portret = SummItem.BCreateChildren("<DOTAScenePanel id='SceneP" + uindex + "' class='HeroPreviewScene' style='width:166px; height:228px;' unit='" + units[uindex] + "'  drawbackground='0' onmouseover='UIShowCustomLayoutParametersTooltip( HireTooltip,  file://{resources}/layout/custom_game/ShopToolTip.xml,teststring=" + units[uindex] + "&amp;gold=" + gold + "&amp;lumber=" + lumber + ")' onmouseout='UIHideCustomLayoutTooltip(HireTooltip)' allowrotation='true' map='maps/backgrounds/tower_showcase_radiant'  camera='default_camera'  always-cache-composition-layer='true'  antialias='true' particleonly='false' />");

                    var Button = $.CreatePanel("Button", SummItem, "Btnid" + uindex)

                    Button.unumber = uindex
                    Button.AddClass("HireBtn")
                    var Label = $.CreatePanel("Label", Button, "Labelid" + uindex)
                    Label.AddClass("HireBtnLabel")
                    buttons[uindex] = Button
                    $("#Labelid" + uindex).text = "Hire"
                    Button.SetPanelEvent('onactivate', function() {
                        Hire(Button.unumber)
                        //test(Button)
                    })
                }
            })();
            uindex++;
        }
    }

}

function ItemPanelInitialHuman() {
    $("#SummonsTab").SetHasClass("Hidden", true);
    $("#ItemsContainerTab").RemoveAndDeleteChildren();
    $("#BasicItemsTab").hittest = false;
    $("#GuideTab").SetHasClass("Hidden", true);
    $("#Shop_btn").SetHasClass("Hidden", false)
    var Items = $("#ItemsContainerTab")
    var itemtindex = 0;
    var tempvar = 27

    var ItemHeaderRow = $.CreatePanel("Panel", Items, 'itItemHeadRows' + i)
    ItemHeaderRow.AddClass("ItemHeadRow")
    for (var i = 0; i < 8; i++) {
        var table = CustomNetTables.GetTableValue("upgrades", "ItemBuyHuman");
        var gold = table[HumanItems[itemtindex]].gold
        var lumber = table[HumanItems[itemtindex]].lumber
        var timeRestock = table[HumanItems[itemtindex]].time
        var storetype = 1
        var Item = ItemHeaderRow.BCreateChildren("<DOTAItemImage id='Item" + itemtindex + "' class='item' onfocus='' oncontextmenu='Buy(" + tempvar + ")' scaling='stretch-to-fit-y-preserve-aspect' itemname='" + HumanItems[itemtindex] + "'  onmouseover='UIShowCustomLayoutParametersTooltip(	ItemTooltip,  file://{resources}/layout/custom_game/ShopToolTip.xml,teststring=" + HumanItems[itemtindex] + "&amp;gold=" + gold + "&amp;lumber=" + lumber + "&amp;time=" + timeRestock + ")'  onmouseout='UIHideCustomLayoutTooltip(ItemTooltip)'  />");
        var itemStock = $.CreatePanel("Panel", ItemHeaderRow.FindChild('Item' + itemtindex), 'ItemStock' + tempvar)
        itemStock.AddClass("itemStock")
        itemtindex++;
        tempvar++;
        //&amp;stocking("+itemtindex+","+timeRestock+","+storetype+")
    }
}

function ItemPanelInitial() {
    var Items = $("#ItemsContainerTab")
    var tindex = 0;
    for (var i = 0; i < 4; i++) {
        var ItemHeaderRow = $.CreatePanel("Panel", Items, 'itItemHeadRows' + i)
        ItemHeaderRow.AddClass("ItemHeadRow")
        for (var j = 0; j < 11; j++) {

            var table = CustomNetTables.GetTableValue("upgrades", "ItemBuy");
            if (table[items[tindex]]) {
                var gold = table[items[tindex]].gold
                var lumber = table[items[tindex]].lumber
                var timeRestock = table[items[tindex]].time
                var storetype = 2
                var Item = ItemHeaderRow.BCreateChildren("<DOTAItemImage id='Item" + tindex + "' class='item' onfocus='' oncontextmenu='Buy(" + tindex + ")' scaling='stretch-to-fit-y-preserve-aspect' itemname='" + items[tindex] + "'  onmouseover='UIShowCustomLayoutParametersTooltip(	ItemTooltip,  file://{resources}/layout/custom_game/ShopToolTip.xml,teststring=" + items[tindex] + "&amp;gold=" + gold + "&amp;lumber=" + lumber + "&amp;time=" + timeRestock + ")'  onmouseout='UIHideCustomLayoutTooltip(ItemTooltip)'  />");
                var itemStock = $.CreatePanel("Panel", ItemHeaderRow.FindChild('Item' + tindex), 'ItemStock' + tindex)
                itemStock.AddClass("itemStock")
            }
            //&amp;stocking("+tindex+","+timeRestock+","+storetype+")
            //(function() {

            //})(); 
            tindex++;
        }
    }
}

function Buy(itemindex) {
    if (stock[items[itemindex]] == "out") {
        CreateErrorMessage({
            message: "#error_out_of_stock"
        })
        return
    }
    Game.EmitSound('General.Buy');

    $.Msg("itemname:", items[itemindex])
    var Eindex = Players.GetPlayerHeroEntityIndex(LocalPlayerID);
    var data = {
        pID: LocalPlayerID,
        itemname: items[itemindex],
        Eindex: Eindex,
        ItemIndex: itemindex
    }
    GameEvents.SendCustomGameEventToServer("buy_command", data);
}

function Hire(unitname) {
    Game.EmitSound('General.Buy');


    //var pID=Game.GetLocalPlayerID();
    var Eindex = Players.GetPlayerHeroEntityIndex(LocalPlayerID);
    var data = {
        pID: LocalPlayerID,
        unitname: units[unitname],
        Eindex: Eindex
    }
    GameEvents.SendCustomGameEventToServer("hire_command", data);
}




function CreateErrorMessage(msg) {
    var reason = msg.reason || 80;
    if (msg.message) {
        GameEvents.SendEventClientSide("dota_hud_error_message", {
            "splitscreenplayer": 0,
            "reason": reason,
            "message": msg.message
        });
    } else {
        GameEvents.SendEventClientSide("dota_hud_error_message", {
            "splitscreenplayer": 0,
            "reason": reason
        });
    }
}

(function() {
    update();
    GameStart();
    GameEvents.Subscribe("ShopOnHuman", ItemPanelInitialHuman);
    GameEvents.Subscribe("ShopOn", function() {
        $("#Shop_btn").SetHasClass("Hidden", false)
    });
    GameEvents.Subscribe("ShopOff", function() {
        $("#Shop_btn").SetHasClass("Hidden", true)
        Container.SetHasClass("Hidden", true)
        Game.EmitSound("Shop.PanelDown");
        hidden = false;
    });
    $("#Shop_btn").SetHasClass("Hidden", true)
    Container.AddClass("Hidden")
    var Summons = $("#SummContainerTab")
    Summons.AddClass("Hidden")
    ItemPanelInitial();
    SummPanelInitial();
    GameEvents.Subscribe("item_stock", stocking)
    //ItemPanelInitialHuman();
    // DOTAHud Hud
    var hud = $.GetContextPanel().GetParent().GetParent().GetParent();
    //var tooltipbg = hud.FindChildTraverse("Tooltips").FindChildTraverse("TestTooltip").FindChildTraverse("Contents");
    //$.Msg(tooltipbg)
    //tooltipbg.style.backgroundColor = "#0b1215"
    var glyphScanContainer = hud.FindChildTraverse("HUDElements").FindChildTraverse("minimap_container").FindChildTraverse("GlyphScanContainer");
    glyphScanContainer.FindChildTraverse("RadarButton").style.visibility = "collapse";
    var StatPipContainer = hud.FindChildTraverse("HUDElements").FindChildTraverse("lower_hud").FindChildTraverse("center_with_stats").FindChildTraverse("center_block").FindChildTraverse("AbilitiesAndStatBranch").FindChildTraverse("StatBranch");
    StatPipContainer.style.visibility = "collapse";
    var StatPipContainerLvlUp = hud.FindChildTraverse("HUDElements").FindChildTraverse("lower_hud").FindChildTraverse("center_with_stats").FindChildTraverse("center_block").FindChildTraverse("level_stats_frame");
    StatPipContainerLvlUp.style.visibility = "collapse";
    var StatDrawer = hud.FindChildTraverse("HUDElements").FindChildTraverse("lower_hud").FindChildTraverse("StatBranchDrawer");
    StatDrawer.style.visibility = "collapse";
})()