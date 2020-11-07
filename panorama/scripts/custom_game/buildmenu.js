var Container = $("#Container");
var Root = $.GetContextPanel();
var hidden = true;
var building = {};
var hovering = $("#BuildingContainer");
var tooltip_name = "build_tower_pearl";
var LocalPlayerID = Game.GetLocalPlayerID();
var PlayerTeam = Players.GetTeam(LocalPlayerID);

building['Carnelian_wall']= ['build_house'];
building['tower_pearl']= ['build_house'];
building['wall_of_health']= ['build_house'];
building['slayer_tavern']= ['build_house'];
building['research_center']= ['build_house'];
building['human_surplus']= ['research_center'];
building['gold_mine']= ['slayers_vault','lumber_house'];
building['slayers_vault']= ['build_house','slayer_tavern'];
building['feeding_block']= ['slayer_tavern','slayers_vault'];
building['Tower_Of_Mana_Energy']= ['ultra_research_center'];
building['ultra_research_center']= ['gold_mine','lumber_house'];
building['Tower_Of_Opal_Spire']= ['build_house'];
building['wall_tower']= ['lumber_house'];
building['Wall_Of_Amethyst']= ['research_center'];
building['super_gold_mine']= ['citadel_of_faith'];
building['comet_tower']= ['citadel_of_faith'];
building['Wall_Of_Ruby']= ['citadel_of_faith'];
building['lightning_oracle']= ['command_center'];
building['vampire_spire']= ['command_center'];
building['blood_box']= ['deforestation_house'];
building['deforestation_house']= ['gold_mine','slayers_vault'];
building['command_center']= ['citadel_of_faith'];
building['base_of_operations']= ['command_center'];
building['holy_blood_tower']= ['base_of_operations'];
building['elite_gold_mine']= ['base_of_operations'];
building['armageddon_tower']= ['base_of_operations'];
building['Wall_Of_Diamond']= ['command_center'];
building['ultra_lightning_oracle']= ['base_of_operations'];
building['ultra_vampire_spire']= ['base_of_operations'];
building['super_wall_tower']= ['command_center'];
building['super_wall_of_health']= ['ultra_research_center'];

var mainBuilder = [{name:"build_house",gold:"0",lumber:"10",available:"true",image:"file://{images}/custom_game/house.png"},
{name:"tent_1",gold:"0",lumber:"20",available:"true",image:"file://{images}/custom_game/human_building_house.png"},
{name:"slayer_tavern",gold:"0",lumber:"400",available:"true",image:"file://{images}/custom_game/human_building_slayer_tavern.png"},
{name:"human_surplus",gold:"3",lumber:"1000",available:"true",image:"file://{images}/custom_game/human_building_human_surplus.png"},
{name:"tower_pearl",gold:"0",lumber:"50",available:"true",image:"file://{images}/custom_game/build_tower.png"},
{name:"Carnelian_wall",gold:"0",lumber:"50",available:"true",image:"file://{images}/custom_game/carnelian_wall.png"},
{name:"research_center",gold:"0",lumber:"150",available:"true",image:"file://{images}/custom_game/research_center.png"},
{name:"wall_of_health",gold:"0",lumber:"2000",available:"true",image:"file://{images}/custom_game/wall_of_health.png"},
{name:"gold_mine",gold:"0",lumber:"20000",available:"true",image:"file://{images}/custom_game/human_building_gold_mine.png"},
{name:"slayers_vault",gold:"1",lumber:"150",available:"true",image:"file://{images}/custom_game/slayers_vault.png"}
];
var towerBuilder =  [{name:"build_house",gold:"0",lumber:"10",available:"true",image:"file://{images}/custom_game/house.png"},
{name:"Tower_Of_Mana_Energy",gold:"1",lumber:"3500",available:"true",image:"file://{images}/custom_game/human_building_house.png"},
{name:"feeding_block",gold:"0",lumber:"50",available:"true",image:"file://{images}/custom_game/feed_box.png"},
{name:"human_surplus",gold:"3",lumber:"1000",available:"true",image:"file://{images}/custom_game/human_building_human_surplus.png"},
{name:"ultra_research_center",gold:"10",lumber:"5000",available:"true",image:"file://{images}/custom_game/ultra_research_center.png"},
{name:"Tower_Of_Opal_Spire",gold:"0",lumber:"800",available:"true",image:"file://{images}/custom_game/opal.png"},
{name:"Tower_Of_Frost",gold:"0",lumber:"15000",available:"true",image:"file://{images}/custom_game/frost.png"},
{name:"Wall_Of_Amethyst",gold:"0",lumber:"1000",available:"true",image:"file://{images}/custom_game/amethys.png"},
{name:"wall_of_health",gold:"0",lumber:"2000",available:"true",image:"file://{images}/custom_game/wall_of_health.png"},
{name:"gold_mine",gold:"0",lumber:"20000",available:"true",image:"file://{images}/custom_game/human_building_gold_mine.png"},
{name:"wall_tower",gold:"0",lumber:"2000",available:"true",image:"file://{images}/custom_game/tower_wall.png"}
];
var SuperTowerBuilder =  [{name:"Tower_Of_Mana_Energy",gold:"1",lumber:"3500",available:"true",image:"file://{images}/custom_game/human_building_house.png"},
{name:"super_gold_mine",gold:"0",lumber:"50000",available:"true",image:"file://{images}/custom_game/human_building_gold_mine.png"},
{name:"wall_tower",gold:"0",lumber:"2000",available:"true",image:"file://{images}/custom_game/tower_wall.png"},
{name:"human_surplus",gold:"3",lumber:"1000",available:"true",image:"file://{images}/custom_game/human_building_human_surplus.png"},
{name:"comet_tower",gold:"40",lumber:"125000",available:"true",image:"file://{images}/custom_game/comet.png"},
{name:"Wall_Of_Ruby",gold:"100",lumber:"150000",available:"true",image:"file://{images}/custom_game/ruby.png"},
{name:"lightning_oracle",gold:"250",lumber:"750000",available:"true",image:"file://{images}/custom_game/light.png"},
{name:"vampire_spire",gold:"30",lumber:"75000",available:"true",image:"file://{images}/custom_game/vampire_spire.png"},
{name:"blood_box",gold:"0",lumber:"1000",available:"true",image:"file://{images}/custom_game/blood_box.png"},
{name:"command_center",gold:"400",lumber:"100000",available:"true",image:"file://{images}/custom_game/command_center.png"},
{name:"base_of_operations",gold:"1300",lumber:"0",available:"true",image:"file://{images}/custom_game/build_tech_center.png"}
];
var GoblinBuilder =  [{name:"deforestation_house",gold:"1",lumber:"10000",available:"true",image:"file://{images}/custom_game/human_building_house.png"},
{name:"holy_blood_tower",gold:"2000",lumber:"1000000",available:"true",image:"file://{images}/custom_game/human_building_house.png"},
{name:"elite_gold_mine",gold:"0",lumber:"80000",available:"true",image:"file://{images}/custom_game/human_building_gold_mine.png"},
{name:"armageddon_tower",gold:"1000",lumber:"200000",available:"true",image:"file://{images}/custom_game/armagedon.png"},
{name:"Wall_Of_Diamond",gold:"200",lumber:"250000",available:"true",image:"file://{images}/custom_game/diamond.png"},
{name:"Tower_Of_Pink_Diamond",gold:"0",lumber:"4000",available:"true",image:"file://{images}/custom_game/pink_diamond.png"},
{name:"ultra_lightning_oracle",gold:"1600",lumber:"1000000",available:"true",image:"file://{images}/custom_game/ultra_light.png"},
{name:"ultra_vampire_spire",gold:"100",lumber:"100000",available:"true",image:"file://{images}/custom_game/ultra_spire_vampire.png"},
{name:"super_wall_tower",gold:"10",lumber:"50000",available:"true",image:"file://{images}/custom_game/super_tower_wall.png"},
{name:"super_wall_of_health",gold:"0",lumber:"10000",available:"true",image:"file://{images}/custom_game/super_wall_of_health.png"},
];

function buildui(name,event){
    $.DispatchEvent("SetInputFocus", $.GetContextPanel().GetParent().GetParent());
    hidden = true;
    Container.SetHasClass("Hidden", hidden);
 //    $.Msg("buildui_command")

    // $.Msg("buildui_command name ability:"+name)
    var plyID = Game.GetLocalPlayerID();
    //var localHeroIndex = Players.GetPlayerHeroEntityIndex( Game.GetLocalPlayerID() );
    var localHeroIndex = Players.GetLocalPlayerPortraitUnit();
    var data = {
        playerID: plyID,
        heroent: localHeroIndex,
        buildingname: name,
        msg: event
    };

    GameEvents.SendCustomGameEventToServer("buildui_command", data);

}

function MenuHide()
{
    if(PlayerTeam==2&&IsBuilder(Players.GetLocalPlayerPortraitUnit()))
    {
        Root.SetHasClass("Hidden", false)
        BuilderRefresh()
    }
    else
    {
        Root.SetHasClass("Hidden", true)
    }
    $.Schedule(0.1, MenuHide);
}

function Toggle() {
    Game.EmitSound("ui_generic_button_click");
    hidden = !hidden
    Container.SetHasClass("Hidden", hidden)
    BuilderRefresh()
     if (hidden)
     $.DispatchEvent("DropInputFocus")

   // $.DispatchEvent("SetInputFocus", $.GetContextPanel().FindChildTraverse("Container").FindChildTraverse("Container1"))
}

function InitialPanel(buildingTable,int)
{

    //Container.RemoveAndDeleteChildren()
     var ContainerN =  $("#Container"+int)
     var bindex=0
    for(var i=0;i<2;i++)
    {
        var ContainerRow = $.CreatePanel("Panel",ContainerN,"ContainerRow_"+i)
        ContainerRow.AddClass("ContainerRow")
        for(var j=0;j<6;j++)
        {
            (function(){
               // $.Msg(buildingTable[bindex].image)
               if(buildingTable[bindex])
               {
                var bHolderPanel = $.CreatePanel("Panel",ContainerRow,buildingTable[bindex].name)
                bHolderPanel.hittest=false
                 bHolderPanel.SetPanelEvent("onmouseover",function(){
                    Hover(bHolderPanel.id)
                })
                  bHolderPanel.SetPanelEvent("onmouseout",function(){
                   OnMouseOut(bHolderPanel.id)
                })
                bHolderPanel.AddClass("BuildingContainer")
                var bImage = $.CreatePanel("Image",bHolderPanel,"Image_"+i+"_"+j)
                bImage.SetImage(buildingTable[bindex].image)
                bImage.AddClass("BuildingImage")
                bImage.n = buildingTable[bindex].name
                bImage.SetPanelEvent("onactivate",function(){
                    buildui(bImage.n)
                })
                var bName = $.CreatePanel("Label",bHolderPanel,"Image_"+i+"_"+j)
                bName.html=true
                bName.text= $.Localize("#"+buildingTable[bindex].name)
                bName.AddClass("Buildname")
                var bLumber = $.CreatePanel("Label",bHolderPanel,"Image_"+i+"_"+j)
                bLumber.text=buildingTable[bindex].lumber
                bLumber.AddClass("Lumber_Cost")
                var bGold = $.CreatePanel("Label",bHolderPanel,"Image_"+i+"_"+j)
                bGold.text=buildingTable[bindex].gold
                bGold.AddClass("Gold_Cost")
                bindex++;
                // var KeyBindInput = $.CreatePanel("TextEntry",bHolderPanel,"KeyBindInput_"+i+"_"+j)
                //  KeyBindInput.maxchars=1
                //  var KeyBindButton = $.CreatePanel("Button",bHolderPanel,"KeyBindButton_"+i+"_"+j)
                //  KeyBindButton.AddClass("KeyBind")
                //  KeyBindButton.SetPanelEvent("onactivate",function(){
                //     KeyBindSet(KeyBindButton.id,KeyBindInput.id)
                // })
                //  KeyBindInput.SetPanelEvent("oninputsubmit",function(){
                //    $.Msg(KeyBindInput.text)
                // })

            }
            })();
        }

    }
    OnBuildingPlayer();
}


function Hover(name){
     hovering = $("#"+name)
    var tooltip_name = "build_"+name
    if (hovering.BHasClass("DisabledAbility"))
        tooltip_name = tooltip_name+"_disabled"
    $.DispatchEvent( "DOTAShowAbilityTooltip", hovering, tooltip_name);
}


function OnMouseOut(name){
     hovering = $("#"+name)
    var tooltip_name = "build_"+name
    if (hovering.BHasClass("DisabledAbility"))
        tooltip_name = tooltip_name+"_disabled"
    $.DispatchEvent( "DOTAHideAbilityTooltip", hovering);
}

function OnBuildingPlayer()
{
    var table = CustomNetTables.GetTableValue( "buildings" ,"");
    var t = CustomNetTables.GetTableValue( "buildings" ,Game.GetLocalPlayerID());
    var temp = t[1]
   // $.Msg(temp)
    //var buildtable = temp[Game.GetLocalPlayerID()];
       for (var towerName in building)
    {
      CheckRequirements(towerName, building[towerName], temp)
    }
}


function CheckRequirements(BuildingName, requirements, eventdata) {
    var panel = $("#" + BuildingName);

    if (panel) {
        var bRequirementFailed = false;
        for (var i in requirements)
        {
            if (eventdata[requirements[i]] == 0) {
                bRequirementFailed = true;

                break;
            }
        }

        panel.SetHasClass("DisabledAbility", bRequirementFailed)
    }
}

function IsBuilder( entIndex ) {
    return (Entities.GetUnitLabel( entIndex ) == "builder")
}

function PanelSwitch(number) {
    if(number == 1)
   {
     $("#Container1").SetHasClass("Hidden",false)
     $("#Container2").SetHasClass("Hidden",true)
     $("#Container3").SetHasClass("Hidden",true)
     $("#Container4").SetHasClass("Hidden",true)
   }
   if(number == 2)
   {
     $("#Container1").SetHasClass("Hidden",true)
     $("#Container2").SetHasClass("Hidden",false)
     $("#Container3").SetHasClass("Hidden",true)
     $("#Container4").SetHasClass("Hidden",true)
   }
   if(number == 3)
   {
     $("#Container1").SetHasClass("Hidden",true)
     $("#Container2").SetHasClass("Hidden",true)
     $("#Container3").SetHasClass("Hidden",false)
     $("#Container4").SetHasClass("Hidden",true)
   }
   if(number == 4)
   {
     $("#Container1").SetHasClass("Hidden",true)
     $("#Container2").SetHasClass("Hidden",true)
     $("#Container3").SetHasClass("Hidden",true)
     $("#Container4").SetHasClass("Hidden",false)
   }
}

function BuilderRefresh() {
    var builder =  Entities.GetUnitName(     Players.GetLocalPlayerPortraitUnit())
   if(builder == "npc_dota_hero_kunkka")
   {
    PanelSwitch(1)
   }
   if(builder == "tower_builder")
   {
     PanelSwitch(2)
   }
   if(builder == "super_tower_builder")
   {
    PanelSwitch(3)
   }
   if(builder == "goblin_tower_builder")
   {
    PanelSwitch(4)
   }
}

// function KeyBindSet(Key_id,fake_input)
// {
// $.Msg("hello ",Key_id)
//  $.DispatchEvent("SetInputFocus", $("#"+fake_input))



//  //$.DispatchEvent("SetInputFocus", $.GetContextPanel().FindChildTraverse("Container").FindChildTraverse("Container1"))
// }

function InitKeybinds()
{
  var BuildMenu = $.GetContextPanel();

  $.RegisterKeyBind(BuildMenu, 'key_h', function()
  {
     if (!hidden)
         buildui("build_house")
  });

  $.RegisterKeyBind(BuildMenu, "key_t", function()
  {
     if (!hidden)
       buildui("tent_1")
  });

    $.RegisterKeyBind(BuildMenu, "key_c", function()
  {
     if (!hidden)
        buildui("Carnelian_wall")
  });
      $.RegisterKeyBind(BuildMenu, "key_p", function()
  {
      if (!hidden)
        buildui("tower_pearl")
  });
  $.RegisterKeyBind(BuildMenu, "key_b", function()
  {
         // Container.SetHasClass("Hidden", true)
   Toggle()
  });
    $.RegisterKeyBind(BuildMenu, "key_f1", function()
  {
        ForcePlayerCamera()
  });

}

function ForcePlayerCamera()
  {
    var EntIndex = Players.GetPlayerHeroEntityIndex(LocalPlayerID)
    GameUI.SetCameraTarget(EntIndex)
  $.Schedule(0.3,function(){GameUI.SetCameraTarget(-1)})

  }
function SlayerBind (event)
  {
     var hero = event.hero
    Game.CreateCustomKeyBind("F2", "SlayerSetCamera");
    Game.AddCommand( "SlayerSetCamera", function() {

       if(Players.GetLocalPlayerPortraitUnit()==hero)
       {
          GameUI.SetCameraTarget(hero)
          $.Schedule(0.3,function(){GameUI.SetCameraTarget(-1)})
       }
              GameUI.SelectUnit( hero, false )
    }, "", 0 );

  }
function CheckFocus()
  {
    if(hidden==false)
    {
      $.DispatchEvent("SetInputFocus", $.GetContextPanel().FindChildTraverse("Container").FindChildTraverse("Container1"))
      $.Schedule(0.2,CheckFocus)
    }

  }
$.Schedule(2, InitKeybinds);

(function(){

    GameEvents.Subscribe("SlayerSpawn", SlayerBind)
    MenuHide()
    CustomNetTables.SubscribeNetTableListener("buildings",OnBuildingPlayer);
    CustomNetTables.SubscribeNetTableListener("ply",OnBuildingPlayer);
    Container.AddClass("Hidden")
    Root.AddClass("Hidden")
    InitialPanel(mainBuilder,1)
     InitialPanel(towerBuilder,2)
     InitialPanel(SuperTowerBuilder,3)
     InitialPanel(GoblinBuilder,4)
     Game.CreateCustomKeyBind("b", "OnShowBuildMenu");
  Game.AddCommand( "OnShowBuildMenu", function() {
   Toggle()
   Toggle()
   $.DispatchEvent("SetInputFocus", $.GetContextPanel().FindChildTraverse("Container").FindChildTraverse("Container1"))
   $.Schedule(0.2, CheckFocus);
  }, "", 0 );
})()
