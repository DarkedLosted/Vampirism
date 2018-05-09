if not Tutorial then
    Tutorial = class({})
end

function Tutorial:Init()
	 CustomGameEventManager:RegisterListener( "tutorial_start", Dynamic_Wrap(Tutorial, "Start"))
   	 CustomGameEventManager:RegisterListener( "tutorial_end", Dynamic_Wrap(Tutorial, "End"))

   	 Tutorial.Player = {}
   	 
end

