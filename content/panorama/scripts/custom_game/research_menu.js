"use strict";
var Root = $.GetContextPanel()
var LocalPlayerID = Game.GetLocalPlayerID()
var hidden = false;
var research = true
var prevResearch;
var progressBarCancel = false
var timers = []
var ColumnContainer
var PlayerTeam = Players.GetTeam(LocalPlayerID);
var Container = $("#ResearchContainer")

var center = [ { name: "research_lumber", lvl: "3" ,Rname:"Lumber Harvest",time:"45",Buildingname:"research_center"},
     { name: "research_rifles", lvl: "1",Rname:"Rifles",time:"20" },
      { name: "research_worker_motivation", lvl: "1",Rname:"Worker Motivation" ,time:"40"},
        { name: "research_mana_regeneration", lvl: "1",Rname:"Mana Regeneration" ,time:"20"},
     { name: "research_infrastructure", lvl: "1",Rname:"Infrastructure",time:"20" },
       { name: "research_wall_quality", lvl: "3",Rname:"Wall Quality",time:"30" },
     { name: "research_slayer_adept", lvl: "1",Rname:"Slayer Adept" ,time:"20"},
 ]
var ultra = [ 
     { name: "research_tower_quality", lvl: "5",Rname:"Tower" ,time:"20" ,Buildingname:"ultra_research_center"},
     { name: "research_human_training", lvl: "1",Rname:"Human Training",time:"20"},
      { name: "research_glissenning_powder", lvl: "1",Rname:"Glissenning Powder",time:"20" },
      { name: "research_iron_plate", lvl: "4",Rname:"Iron Plate" ,time:"50"},
       { name: "research_tower_of_health", lvl: "1",Rname:"Towers Health",time:"120"},
     { name: "research_human_teleport", lvl: "1",Rname:"Human Teleport",time:"120" },
     { name: "research_tower_defence", lvl: "1",Rname:"Tower Defence",time:"120" },
      { name: "research_engineers_health", lvl: "1",Rname:"Engineers",time:"120" },
     
 ]
 var vault = [ 
    { name: "research_blink_extansion", lvl: "1",Rname:"Blink Extansion",time:"60",Buildingname:"slayers_vault" },
     { name: "research_human_damage_upgrade", lvl: "8",Rname:"Human Damage Upg",time:"30" },
     { name: "research_human_survival_hp", lvl: "1",Rname:"Human Survival HP",time:"30" }
 ]
var array = [center,ultra,vault]
var complete = {}
function ResearchCenter()
{
    var t = CustomNetTables.GetTableValue( "buildings" ,Game.GetLocalPlayerID());
    var temp = t[1]
	    //var buildtable = temp[Game.GetLocalPlayerID()];
	  if(temp["research_center"]>0||temp["ultra_research_center"]>0||temp["slayers_vault"]>0)
	  {
	  	$("#ResearchToogle").SetHasClass("Hidden",false)
	  	$("#ResearchToogle").SetHasClass("ResearchToggleEnabled",true)
	  }
	  else
	  {
	  	$("#ResearchToogle").SetHasClass("Hidden",true)
	  	$("#ResearchToogle").SetHasClass("ResearchToggleEnabled",false)
	  }
	 
	   if(temp["research_center"]>0)
	  {
	  	$("#Rbutton_0").SetHasClass("Hidden",false)

	  }
	  else
	  {
	  	$("#Rbutton_0").SetHasClass("Hidden",true)

	  }
	   if(temp["ultra_research_center"]>0)
	  {
	  	$("#Rbutton_1").SetHasClass("Hidden",false)
	  
	  }
	  else
	  {
	  	$("#Rbutton_1").SetHasClass("Hidden",true)
	  }
	   if(temp["slayers_vault"]>0)
	  {
	  	$("#Rbutton_2").SetHasClass("Hidden",false)

	  
	  }
	  else
	  {
	  	$("#Rbutton_2").SetHasClass("Hidden",true)

	  }
	  
}
function Toggle()
{ 
	
	if(hidden&&PlayerTeam==2)
	{4
		hidden=false;
		Container.SetHasClass("Hidden",true)
		//$.Msg("Hidden - true")
		Game.EmitSound( "Shop.PanelDown" );
	}
	else
	{
		hidden=true;
		Container.SetHasClass("Hidden",false)
		//$.Msg("Hidden - false")
		Game.EmitSound( "Shop.PanelUp" );
		//Container.RemoveAndDeleteChildren();
		// InitialResearchUI();
		ResearchCenter();
	}
}
function InitialResearchUI()
{
	var ContainerHeader = $.CreatePanel("Label",Container,"ContainerHeader")
	ContainerHeader.AddClass("ContainerHeader")
	ContainerHeader.text="Researches"
	var ButtonsContainer = $.CreatePanel("Panel",Container,"ButtonsContainer")
	ButtonsContainer.AddClass("ButtonsContainer")
		 
	for(var k =0; k<3;k++)
	{
		(function() {
			var ColumnContainer = $.CreatePanel("Panel",Container,"ColumnContainer"+k)
		ColumnContainer.AddClass("ColumnContainer")
		var Rbutton = $.CreatePanel("RadioButton",ButtonsContainer,"Rbutton_"+k)
		Rbutton.AddClass("Rbutton")
		Rbutton.AddClass("Hidden",true)
		Rbutton.array = array[k]
		Rbutton.index=k
		var RbuttonLabel = $.CreatePanel("Label",Rbutton,"RbuttonLabel_"+k) 
		if(k==0)
		{
			RbuttonLabel.text="Research Center"
		}
		if(k==1)
		{
			RbuttonLabel.text="Ultra Research Center"
		}
		if(k==2)
		{
			RbuttonLabel.text="Slayer's Vault"
		}
		RbuttonLabel.AddClass("RbuttonLabel")
		Rbutton.SetPanelEvent('onactivate', function(){
			//ColumnContainer.RemoveAndDeleteChildren();
		 //InitialContainer(Rbutton.array,ColumnContainer,Rbutton.index) 
		 		utilhide()
		 		ColumnContainer.SetHasClass("Hidden",false)
				})
	
		})(); 
		
	}

	// var researchCompleteLable = $.CreatePanel("Label",$.GetContextPanel(),"researchCompleteLable")
	// researchCompleteLable.SetHasClass("Hidden", true)
	// researchCompleteLable.SetHasClass("researchCompleteLable", true)
	ResearchDraw()

	
}
function utilhide()
{
$("#ColumnContainer0").SetHasClass("Hidden",true)
$("#ColumnContainer1").SetHasClass("Hidden",true)
$("#ColumnContainer2").SetHasClass("Hidden",true)
}
function ResearchDraw()
{
	InitialContainer(center,$("#ColumnContainer0"),0) 
	InitialContainer(ultra,$("#ColumnContainer1"),1) 
	InitialContainer(vault,$("#ColumnContainer2"),2) 
}

function InitialContainer(skill,ColumnContainer,ColumnNumber)
{	
	

	for(var m =0 ;m<skill.length;m++)
	{
		var ResearchColumn = $.CreatePanel("Panel",ColumnContainer,"ResColumn")
		ResearchColumn.AddClass("ResearchColumn")
		var ResearchHeader = $.CreatePanel("Label",ResearchColumn,"ResHeader_")
		ResearchHeader.AddClass("ResearchHeader")
		ResearchHeader.text=skill[m].Rname
		//ResearchHeader.text='Research'
		var ResearchHeaderLine = $.CreatePanel("Panel",ResearchColumn,"ResHeaderLine_")
		ResearchHeaderLine.AddClass("ResearchHeaderLine")
		var prevAbility
			for(var i=0;i<skill[m].lvl;i++)
			{
				(function(){
				var AbilityImage = $.CreatePanel("DOTAAbilityImage",ResearchColumn,"AbilityImage_"+m+"_"+i+"_"+ColumnNumber)
				prevAbility="AbilityImage_"+m+"_"+(i+1)+"_"+ColumnNumber
				AbilityImage.next = prevAbility
				AbilityImage.AddClass("AbilityImage")
				AbilityImage.abilityname=skill[m].name
				
				  var research = CustomNetTables.GetTableValue("upgrades",skill[m].name)
				  var towername
				 if (research){ towername  = research["abilitylevel"].lvl}
				 	

				if(i>0&&i!=towername)
				{	

					AbilityImage.AddClass("AbilityImageDisabled")
					if (complete[AbilityImage.id] !="finish")
					complete[AbilityImage.id]="require"
			
				}
				if(i==towername)
				{
					complete[AbilityImage.id]=""
				}
			
				AbilityImage.SetPanelEvent('onmouseover', function(){
                 OnMouseOn(AbilityImage.abilityname,AbilityImage.id)
             	 })
				
				AbilityImage.SetPanelEvent('onmouseout', function(){
                 OnMouseOut(AbilityImage.abilityname,AbilityImage.id)
             	 })
				AbilityImage.SetPanelEvent('onactivate', function(){
                 ResearchStart(AbilityImage.abilityname,AbilityImage.id,skill[0].Buildingname)
             	 })
			
				if (complete[AbilityImage.id]) {
					if(complete[AbilityImage.id]=="progress")
					{
						AbilityImage.SetHasClass("ResearchinProgress",true)
					}
					if(complete[AbilityImage.id]=="finish")
					{
						AbilityImage.SetHasClass("ResearchComplete",true)

					}
				}
				if( i!=skill[m].lvl-1)
				{
				var lineheight = 100/skill[m].lvl;
				var ResearchLine = $.CreatePanel("Panel",ResearchColumn,"ResLine"+m+"_"+i)
				ResearchLine.AddClass("ResearchLine")
				ResearchLine.style.height=(lineheight-(skill[m].lvl *1.4))+"%";
				//ResearchLine.AddClass('ResearchLineComplete')
				if(complete[AbilityImage.id]=="finish")
				{
					ResearchLine.SetHasClass("ResearchLineComplete",true)
				}
				complete[AbilityImage.id+"l"]=ResearchLine.id
				}
				})();
			}
			ColumnContainer.SetHasClass("Hidden",true)
	}
}

function OnMouseOn(abilName,Pname){
	
	var Ability = $("#"+Pname)
    var tooltip_name = abilName
    if (Ability.BHasClass("DisabledAbility"))
        tooltip_name = tooltip_name+"_disabled"
    $.DispatchEvent( "DOTAShowAbilityTooltip", Ability, tooltip_name);
  //ProgressBarinc();
//$.Msg(Ability.id)
	
}


function OnMouseOut(abilName,Pname){
	var Ability = $("#"+Pname)
	var tooltip_name = "research_"+abilName
	if (Ability.BHasClass("DisabledAbility"))
        tooltip_name = tooltip_name+"_disabled"
	$.DispatchEvent( "DOTAHideAbilityTooltip", Ability);
}
function ProgressBarinc()
{	
	if(progressBarCancel)
	{
		return
	}
	if(Math.floor($("#ResearchBar").value)!=$("#ResearchBar").max && research)
	{
	$("#ResearchBar").value=$("#ResearchBar").value+0.5;
	$("#ResearchBarLabel").text= Math.floor($("#ResearchBar").value/($("#ResearchBar").max/100))+"%"
	//$.Schedule(0.1, ProgressBarinc);
	CreateTimer(0.5,ProgressBarinc)
	}
	else
	{
		
		$("#DisplayResearch").SetHasClass("Hidden",true)
		$("#"+$("#ResearchBar").aid).SetHasClass("ResearchComplete",true)
		$("#"+$("#ResearchBar").aid).SetHasClass("ResearchinProgress",false)
		$("#ResearchBar").value=0;
		complete[$("#ResearchBar").aid]="finish"
		if ($("#"+complete[$("#ResearchBar").aid+"l"]))
		$("#"+complete[$("#ResearchBar").aid+"l"]).SetHasClass("ResearchLineComplete",true)
		if($(("#"+$("#"+$("#ResearchBar").aid).next)))
		{
		$(("#"+$("#"+$("#ResearchBar").aid).next)).SetHasClass("AbilityImageDisabled",false)
		complete[$("#"+$("#ResearchBar").aid).next]=""
		}

		var researchCompleteLable = $("#researchCompleteLable")
		researchCompleteLable.SetHasClass("Hidden", false)
		researchCompleteLable.text = $.Localize($("#ResearchBar").resname)+" complete"
		CreateTimer(4,function() {researchCompleteLable.SetHasClass("Hidden", true) })
	}
}
function ResearchStop ()
{
	$("#"+prevResearch).SetHasClass("ResearchinProgress",false)
			$("#DisplayResearch").SetHasClass("Hidden",true)
			$("#ResearchBar").value=0;
			progressBarCancel=true
			complete[prevResearch]=null
			prevResearch=""
			return
}
function ResearchStart(ResearchName,id,Buildingname)
{		
		if(id==prevResearch&&complete[id]=="progress")
		{
			$("#"+id).SetHasClass("ResearchinProgress",false)
			$("#DisplayResearch").SetHasClass("Hidden",true)
			$("#ResearchBar").value=0;
			progressBarCancel=true
			prevResearch=""
			complete[id]=null
			var Eindex = Players.GetPlayerHeroEntityIndex( LocalPlayerID );
			var data=
			{
				pID:LocalPlayerID,
				ResearchName:ResearchName,
				Eindex:Eindex,
				Buildingname:Buildingname
			}
			GameEvents.SendCustomGameEventToServer("research_command_cancel",data );
		
			return
		}
		
		if(complete[id]=="finish"||complete[id]=="progress"||complete[prevResearch]=="progress"||complete[id]=="require")
		{
			
			return
		}	

			var Eindex = Players.GetPlayerHeroEntityIndex( LocalPlayerID );
			var data=
			{
				pID:LocalPlayerID,
				ResearchName:ResearchName,
				Eindex:Eindex,
				Buildingname:Buildingname
			}
			GameEvents.SendCustomGameEventToServer("research_command",data );
			progressBarCancel=false
			$("#Displayimage").abilityname=ResearchName;
			$("#DisplayResearch").SetHasClass("Hidden",false)

			var building  = Entities.GetAllEntities()
			for (var i = 0; i < building.length; i++) {

				if(Entities.IsControllableByPlayer(building[i],LocalPlayerID)&&	Entities.GetUnitName(building[i])==Buildingname)
				{
					$("#ResearchBar").max=Abilities.GetChannelTime(Entities.GetAbilityByName(building[i],ResearchName));
					break;
				}
			}
			
			$("#ResearchBar").aid = id
			$("#ResearchBar").resname = ResearchName
			$("#"+id).SetHasClass("ResearchinProgress",true)
			complete[id]="progress"
			prevResearch=id
			ProgressBarinc();	
}

function CreateTimer(time,name)
{
time=time+Game.Time()
timers[timers.length]={time:time,function:name}
}
function update() 
{
	var CurrentTime = Game.Time()
	for(var i =0 ; i<timers.length;i++)
	{
		if(timers[i].time <=CurrentTime)
		{

			var callback = timers[i]["function"]();
			if (callback == null)
			{
				timers.splice(i, 1)
			}
			else
			{
				timers[i].time = CurrentTime + callback
			}
			
		}
	}
  $.Schedule(0.01, update);
} 

(function(){
	update()
    Container.AddClass("Hidden")
  	$("#DisplayResearch").SetHasClass("Hidden",true)
  	$("#ResearchToogle").SetHasClass("Hidden",true)
  	 CustomNetTables.SubscribeNetTableListener("buildings",ResearchCenter);
  		GameEvents.Subscribe( "ResearchStop", ResearchStop);

  		InitialResearchUI();
})()