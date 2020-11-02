"use strict";
var timers = []

function Start() {
    Game.EmitSound("night_stalker_nstalk_respawn_07")
    var panel = $("#dlgVampire").style.visibility = "visible"
    var label = $("#dlgVampireLabel")
    label.text = "Tonight my enemies will pay , you expected daylight to protect you? You've seen your last sunrise"
    CreateTimer(10, function() {
        $("#dlgVampire").style.visibility = "collapse"
    })
}

function VampireMessage(data) {
    var panel = $("#dlgVampire").style.visibility = "visible"
    var label = $("#dlgVampireLabel")

    if (!data.delay) {
        data.delay = 5
    }
    if (data.soundName) {
        Game.EmitSound(data.soundName)
    }
    label.text = data.text
    CreateTimer(data.delay, function() {
        $("#dlgVampire").style.visibility = "collapse"
    })

}

function SystemMessage(data) {
    var panel = $("#dlgSystem").style.visibility = "visible"
    var label = $("#dlgSystemLabel")
    if (!data.delay) {
        data.delay = 5
    }
    label.text = data.text
    CreateTimer(data.delay, function() {
        $("#dlgSystem").style.visibility = "collapse"
    })
}


(function() {
    update()
    GameEvents.Subscribe("vampire_spawn", Start);
    GameEvents.Subscribe("system_msg", SystemMessage);
    GameEvents.Subscribe("vampire_msg", VampireMessage);
    $("#dlgVampire").style.visibility = "collapse"
    $("#dlgSystem").style.visibility = "collapse"
})();

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
    $.Schedule(0.03, update);
}
