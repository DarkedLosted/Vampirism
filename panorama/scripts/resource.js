"use strict";

function OnPlayerLumberChanged ( args ) {
    var iPlayerID = Players.GetLocalPlayer()
    var lumber = args.lumber
//    $.Msg("Player "+iPlayerID+" Lumber: "+lumber)
    $('#LumberText').text = lumber
}
function OnPlayerFoodChanged(args)
{
    var iPlayerID = Players.GetLocalPlayer()
    var food = args.food
    var maxfood = args.maxfood
//    $.Msg("Player "+iPlayerID+" Food: "+food)
    $('#FoodText').text = food+"/"
}
function OnPlayerMaxFoodChanged(args)
{
    var iPlayerID = Players.GetLocalPlayer()
    var maxfood = args.maxfood
    //$.Msg("Player "+iPlayerID+" MaxFood: "+maxfood)
    $('#MaxFoodText').text = maxfood
}
function OnPlayerGoldChanged(args)
{    
    var iPlayerID = Players.GetLocalPlayer()
    $('#GoldText').text = Players.GetGold(iPlayerID)
}

(function () {
    GameEvents.Subscribe( "player_lumber_changed", OnPlayerLumberChanged );
    GameEvents.Subscribe( "player_maxfood_changed", OnPlayerMaxFoodChanged );
    GameEvents.Subscribe( "player_food_changed", OnPlayerFoodChanged );
    GameEvents.Subscribe( "player_gold_changed", OnPlayerGoldChanged );
})();
