 "use strict";
// var timers = []
var hidden = true,
	teamColors=[
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
	];

function Toggle() {
	hidden =! hidden;
	$("#MenuContainer").SetHasClass("Hidden", hidden);

	if (hidden === false) {
		GameEvents.SendCustomGameEventToServer( "Player_Inf_Upd", { "Playerid" : Players.GetLocalPlayer()} );
	}
}

function Init(playerID)
{
	playerID = parseInt(playerID);
	var PlayerInfo = Game.GetPlayerInfo( playerID ),
		team;

	if (PlayerInfo.player_team_id === 2) {
	 	var fed = $.CreatePanel("Label", $("#HumanFed"), "Fed" + playerID);

	 	fed.AddClass("Text");
	 	fed.text = "0";
	 	team = "Human";
	} else {
	 	var Leaked = $.CreatePanel("Label", $("#VampireLeaked"), "Leaked" + playerID);

	 	Leaked.AddClass("Text");
	 	Leaked.text = "0";
	 	team = "Vampire";
	}
	var Player = $.CreatePanel("Label", $("#" + team + "Player"), "Player" + playerID);
	var Gold = $.CreatePanel("Label", $("#" + team + "Gold"), "Gold" + playerID);
	var Lumber = $.CreatePanel("Label", $("#" + team + "Lumber"), "Lumber" + playerID);
	var Rank = $.CreatePanel("Label", $("#" + team + "Rank"), "Rank" + playerID);

	Player.AddClass("Text");
	Gold.AddClass("Text");
	Lumber.AddClass("Text");
	Rank.AddClass("Text");

	Player.text = Players.GetPlayerName(playerID );
	Player.style.color = teamColors[playerID];
	Gold.text = PlayerInfo.player_gold;
	Gold.style.color = "gold";
	Lumber.style.color = "green";
	Lumber.text = "0";
	Rank.text = 'Best!';

	//var Leaked = $.CreatePanel("Label",$.("#HumanPlayer"),"Player "+Game.GetLocalPlayerID())
}

function Update(args)
{
	// $.Msg(args)
	for (var playerID in Game.GetAllPlayerIDs()) {
		playerID++;

		var Player = args[(playerID).toString()];
		var PlayerInfo = Game.GetPlayerInfo(playerID - 1);

		if(PlayerInfo.player_team_id === 3) {
			$("#Leaked" + (playerID - 1)).text = Player.leaked;
		} else {
			$("#Fed" + (playerID - 1)).text = Player.fed;
		}
		$("#Gold" + (playerID - 1)).text = Players.GetGold(playerID - 1);
		$("#Lumber" + (playerID - 1)).text = Player.lumber;
	}
}

(function(){
	GameEvents.Subscribe( "Player_Inf_Upd_response", Update );
	$("#MenuContainer").SetHasClass("Hidden", true);

	for (var playerID in Game.GetAllPlayerIDs()) {
         if(Players.GetTeam(Game.GetLocalPlayerID()) === Players.GetTeam(parseInt(playerID))) {
            Init(playerID);
         }
    }
})();
