--[[ Use it to check for ship death before repeat ramming. In fact also when normal ramming finishes charging. 
TODO:
-ReTEST with both disabled to see if this is truly even the cause.
-TEST Pepper code.
-Improvise.
 ]]

--[[ ==================================================================
Pepper code - on loading event with ram,
if enemy is destroyed then immediately go to other event where you just say that you can't ram - NOT TESTED YET 
    
script.on_game_event("RK_RAM_EVENT", false, function()
    local ship = Hyperspace.ships.enemy
    local destr = ship.bDestroyed
    if destr == true then
        Hyperspace.CustomEventsParser.GetInstance():LoadEvent(Hyperspace.App.world, "RK_RAM_NUH_UH", true, Hyperspace.Global.currentSeed)
    end
end) ]]

--[[ script.on_game_event("RK_RAM_EVENT", false, function()
    local ship = Hyperspace.ships.enemy
    local destr = ship.bDestroyed
    if destr == true then
        Hyperspace.CustomEventsParser.GetInstance():LoadEvent(Hyperspace.App.world, "DJMOD_COMBAT_SHIPVORE_CANT_REPEAT_ENEMY_DEAD", true, Hyperspace.Global.currentSeed)
    end
end) ]]

--[[ ==================================================================
Chooseche code - 
check for enemy death, if not: do choice event - WEIRD BUG: ALWAYS SAME OWN SHIP OUTCOME 

script.on_game_event("RK_RAM_CHECK", false, function()
    local ship = Hyperspace.ships.enemy
    local destr = ship.bDestroyed
    if destr == false then
        Hyperspace.CustomEventsParser.GetInstance():LoadEvent(Hyperspace.App.world, "RK_RAM_EVENT", true, Hyperspace.Global.currentSeed)
    end
end)]]

--[[ script.on_game_event("RK_RAM_CHECK", false, function()
    local ship = Hyperspace.ships.enemy
    local destr = ship.bDestroyed
    if destr == false then
        Hyperspace.CustomEventsParser.GetInstance():LoadEvent(Hyperspace.App.world, "DJMOD_COMBAT_SHIPVORE_RAM_REPEAT", true, Hyperspace.Global.currentSeed)
    end
end) ]]