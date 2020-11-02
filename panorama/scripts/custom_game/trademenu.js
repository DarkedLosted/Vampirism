var Container = $("#Container")
var Root = $.GetContextPanel()
var hidden = true
var color = $("#PlayerColor")
var textEntry = $("#goldamount")
var timers=[]
var lastTrade =[]
var teamcolors=[
    "#ff0000",
    "#0000ff",
    "#00ffff",
    "#663399",
    "#ffff00",
    "#ffa500",
    "#32cd32",
    "#ff69b4",
    "#a9a9a9",
    "#89cff0",
    "#006a4e",
    "#4b3621"
]
GameUI.GetPlayerSteamID = function (playerID) {
    var playerInfo = Game.GetPlayerInfo(parseInt(playerID))
    return playerInfo ? playerInfo.player_steamid : -1
}
function CreateErrorMessage(msg)
{
    var reason = msg.reason || 80;
    if (msg.message){
        GameEvents.SendEventClientSide("dota_hud_error_message", {"splitscreenplayer":0,"reason":reason ,"message":msg.message} );
    }
    else{
        GameEvents.SendEventClientSide("dota_hud_error_message", {"splitscreenplayer":0,"reason":reason} );
    }
}
function OnSubmitted(event,types)
{
    //  $.Msg("Enter was enabled!"+$.GetContextPanel().toString());
    // $.Msg("Player SteamID on Subbmit "+GameUI.GetPlayerSteamID(event.pID));
    //var playercontainer = Container.FindChildTraverse("Player_a"+$("#Player_a" ).steamid)
     // $.Msg("PlayerID on Subbmit "+event.pID) ;
     var amount = event.text;
     if (amount==0)
        return
    var plyID = Game.GetLocalPlayerID()
    if(!lastTrade[plyID])
    {
        lastTrade[plyID]=Game.GetGameTime()
     // Message(plyID,parseInt(event.pID),types,amount)
    }
     else if ( (Game.GetGameTime()-lastTrade[plyID])<5 )
    {
        CreateErrorMessage({message:"Not so fast, wait "+Math.round(5-(Game.GetGameTime()-lastTrade[plyID]))+"s"})
        return
    }
    //var localHeroIndex = Players.GetPlayerHeroEntityIndex( plyID )
   // var reciverHI = Players.GetPlayerHeroEntityIndex( parseInt(event.pID) );
    lastTrade[plyID]=Game.GetGameTime()
    var data = {
        playerID: plyID,
       // heroent: localHeroIndex,
      //  reciverHI:reciverHI,
        reciverid:parseInt(event.pID),
        Amount: amount,
        type:types,
        msg: event
    }
    GameEvents.SendCustomGameEventToServer(  "tradeui_send", data );
}

function Toggle() {
    Game.EmitSound("ui_generic_button_click");
    hidden = !hidden
    Container.SetHasClass("Hidden", hidden)
    BoxEmpty()

}

function BoxEmpty() {
    for (var i = 0; i < 10; i++) {
        if($("#Player_ga"+i))
            $("#Player_ga"+i).text=""
        if($("#Player_la"+i))
            $("#Player_la"+i).text=""
    }
}

function LoadProfile(steamID64,pID) {

          // if( Game.GetLocalPlayerID() !=pID)
          // {
            $.Msg("Loading profile of player "+steamID64)
            var PlayerContainer = $("#PlayerContainer");
             var Player = $.CreatePanel( "Panel", PlayerContainer, "Player_a"+pID );
            Player.AddClass("Player")
            Players[pID] = Player

            var Avatar = $.CreatePanel( "DOTAAvatarImage", Player, "Player_a"+pID );
            Avatar.AddClass("DAI")
            Avatar.steamid = steamID64
            Avatar.style.height="40px"
            Avatar.style.width="40px"
             var PlayerName = $.CreatePanel( "DOTAUserName", Player, "Player_n"+pID );
            PlayerName.AddClass("DUI")
            PlayerName.steamid = steamID64
             var PlayerColor = $.CreatePanel( "Label", Player, "Player_l"+pID );
            PlayerColor.AddClass("PlayerColor")
            PlayerColor.style.backgroundColor = teamcolors[pID];
             var ImgGold = $.CreatePanel( "Image", Player, "Player_ig"+pID );
            ImgGold.AddClass("imggold")
             var goldamount = $.CreatePanel( "TextEntry", Player, "Player_ga"+pID );
             // $.Msg(goldamount)
             // goldamount.textmode = 'numeric'
             // $.Msg(goldamount)
            goldamount.AddClass("TextBoxg")
             goldamount.pID = pID;
             goldamount.steamID64 = steamID64;
             goldamount.tabindex="auto"
            goldamount.SetPanelEvent("oninputsubmit",(function(){
              return function(){
                 OnSubmitted(goldamount,"gold")
              };})());
             var ImgLumber = $.CreatePanel( "Image", Player, "Player_il"+pID );
            ImgLumber.AddClass("imglumber")
             var lumberamount = $.CreatePanel( "TextEntry", Player, "Player_la"+pID );
            lumberamount.AddClass("TextBoxl")
               lumberamount.pID = pID;
               lumberamount.tabindex="auto"
             lumberamount.steamID64 = steamID64;
               lumberamount.SetPanelEvent("oninputsubmit",(function(){
              return function(){
                 OnSubmitted(lumberamount,"lumber")
              };})());
         //   }

}

function test(steamID64) {

 //  var g = Container.FindChildTraverse("Player_"+steamID64)
   //  $.Msg("Testplayerid "+g.pID)
}

function Message(data)
{
    var Player1 = data.Player1
    var Player2 = data.Player2
    var type = data.type
    var amount = data.amount

    var msgHolder = $.CreatePanel("Panel",$("#NotificationList"),"msgHolder")
    msgHolder.AddClass("NotificationMessageHolder")
    var msg = $.CreatePanel("Label",msgHolder,"msg")
    msg.AddClass("NotificationMessage")
    // var msg = msgHolder.BCreateChildren("<Label id='msg' class='NotificationMessage' html='true' text='sdfdsf' />");
    msg.html=true
    if(type == "gold")
    {
    msg.text= "<font color='" + teamcolors[Player1] + "' >" + Players.GetPlayerName(Player1) + "</font> " + "<img src='s2r://panorama/images/custom_game/tradeicon.png'>" +"send "+
    " <font color='" + teamcolors[Player2] + "' >" + Players.GetPlayerName(Player2) + "</font> "+"<font color='gold'>" + amount +"</font> " + "<img src='s2r://panorama/images/custom_game/gold.tga' style='vertical-align:bottom;'>"
    }
    else
    {
    msg.text= "<font color='" + teamcolors[Player1] + "' >" + Players.GetPlayerName(Player1) + "</font> " + "<img src='s2r://panorama/images/custom_game/tradeicon.png'>" +"send "+
    " <font color='" + teamcolors[Player2] + "' >" + Players.GetPlayerName(Player2) + "</font> "+"<font color='green'>" + amount +"</font> "+"  <img src='s2r://panorama/images/custom_game/lumber_icon.png'>"
    }
    CreateTimer(4,function(){msgHolder.DeleteAsync(5)})
}

;(function(){
GameEvents.Subscribe( "trade_succeful", Message);
update()
    Container.AddClass("Hidden")
            var plyID = Game.GetLocalPlayerID();
        for (var playerID in Game.GetAllPlayerIDs())
            {

                    if(Players.GetTeam(plyID)==Players.GetTeam(parseInt(playerID))&&playerID!=Game.GetLocalPlayerID())
                        {
                         LoadProfile(GameUI.GetPlayerSteamID(playerID),playerID)
                        }
                   //  if(Players.GetTeam(plyID)==Players.GetTeam(parseInt(playerID))&&playerID!=Game.GetLocalPlayerID())
                   //  {

                   //   LoadProfile(GameUI.GetPlayerSteamID(playerID),playerID)

                   // }
            }
})()

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
  $.Schedule(0.03, update);
}
