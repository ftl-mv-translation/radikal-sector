mods.multiverse.reductionArmor["RK_BAM_DIVINE_ARMOR"] = {amount = 1}
--[[ REF from MV v5.5.1:
PALADIN_ARMOR = {
        amount = 1
    }, 
]]

--[[ REF: Aleev's ARS+ Challenges. Used for calling XML queueEvents
local event_order_caller = {[0]="",[1]=""}
function Add_to_LaunchOrder(ev_name_loc)
	for i = 0, 100 do
		if event_order_caller[i] == "" then
			event_order_caller[i] = ev_name_loc
			print('added event'..ev_name_loc)
			return
		end
	end
end ]]

-- local shipManager = Hyperspace.ships(crew.iShipId)

-- Enhance Mind Heater with "remove MC in fire on top of gaining immunity" effect. - by Fajdek. WORKS with just MV+RK.
script.on_internal_event(Defines.InternalEvents.CREW_LOOP,function(crew)
    local shipManager = Hyperspace.ships(crew.iShipId)
    -- print(shipManager)
    local currentShipManager = Hyperspace.ships(crew.currentShipId)
    -- print(currentShipManager)
    if shipManager and currentShipManager then
        -- print("ship managers exist")
        if shipManager:HasAugmentation("INTERNAL_DJMOD_MC_IMMUNE_FROM_FIRE") > 0 then
            -- print("aug detected")
            if crew.bMindControlled == true and currentShipManager:GetFireCount(crew.iRoomId) > 0 then
                crew:ForceMindControl(false)
                -- print("MC cleared")
            end
        end
    end
end)


-- script.on_internal_event(Defines.InternalEvents.CREW_LOOP,function(crew)
script.on_internal_event(Defines.InternalEvents.JUMP_LEAVE, function ()
    -- print('jump event')    -- WORKS
    -- Remove all Weapons On Fire stacks.
    local stackAugName = "RK_WEAPONS_ON_FIRE_TEMP"

    -- No need to make it work for enemies too, if they jump away it's a new fight, right?
    local stackAugCount = Hyperspace.ships.player:HasAugmentation(stackAugName)
    
    --print('stacks for removal:'..stackAugCount)

    
    if stackAugCount > 0 then
        -- No need to make it work for enemies too, if they jump away it's a new fight, right?
        local shipManager = Hyperspace.ships.player
        for i = 1, stackAugCount, 1 do
            --print('removed stack on jump')

            --Arc technique: pure Lua.
            shipManager:RemoveAugmentation("HIDDEN " .. stackAugName)
        end
    end
end)