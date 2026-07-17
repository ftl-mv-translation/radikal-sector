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


-- WORKS. NEVER TRUST LUA CALLS THAT SHOULD RETURN A VALUE! ALWAYS SAVE IN A LOCAL (int or whatever) INSTEAD!
script.on_internal_event(Defines.InternalEvents.GET_DODGE_FACTOR, function(ship, value)
    
    if value == 0 then
        --print('Boon S value 0')
        return Defines.Chain.CONTINUE, value
    end

    -- With addon Judge Boon Ultimate, all Evasion boons can stack! WORKS
    local tempEvasion = value
    --print('GET_DODGE_FACTOR tempEvasion =' .. tempEvasion)
    
    local tempBoonCount = 0

    if ship:HasAugmentation("JUDGE_BOON_RK_SCORCH_EQUIPMENT") then
        tempBoonCount = ship:HasAugmentation("JUDGE_BOON_RK_SCORCH_EQUIPMENT")
    end
    --print('GET_DODGE_FACTOR tempBoonCount S =' .. tempBoonCount)
    
    if ship.ship.iShipId == 0 then    
        -- return Defines.Chain.CONTINUE, value + 8
        tempEvasion = tempEvasion + 8 * tempBoonCount
        --print('GDF +8, Boon S value:' .. tempEvasion)
    end

    tempBoonCount = 0

    if ship:HasAugmentation("JUDGE_BOON_RK_BPS_EQUIPMENT") then
        tempBoonCount = ship:HasAugmentation("JUDGE_BOON_RK_BPS_EQUIPMENT")
    end
    --print('GET_DODGE_FACTOR tempBoonCount BPS =' .. tempBoonCount)

    if ship.ship.iShipId == 0 then    
        -- return Defines.Chain.CONTINUE, value + 8
        tempEvasion = tempEvasion + 4 * tempBoonCount
        --print('GDF +4, Boon BPS value:' .. tempEvasion)
    end
    
    --print('GET_DODGE_FACTOR end')
    return Defines.Chain.CONTINUE, tempEvasion
end)
--[[ REFS: Lily's Beam Emporium for MV v5.5.1:
local vter = mods.multiverse.vter
local INT_MAX = 2147483647
local userdata_table = mods.multiverse.userdata_table
local time_increment = mods.multiverse.time_increment

script.on_internal_event(Defines.InternalEvents.JUMP_LEAVE, function(ship)
    if ship.ship.iShipId == 0 then
        Hyperspace.playerVariables.lily_afterburner_active = 0
    end
end)

script.on_internal_event(Defines.InternalEvents.GET_DODGE_FACTOR, function(ship, value)
    if ship.ship.iShipId == 0 and ship:HasAugmentation("LILY_COMBAT_AFTERBURNER") then
        if value == 0 then
            return Defines.Chain.CONTINUE, value
        end
        return Defines.Chain.CONTINUE, value + Hyperspace.playerVariables.lily_afterburner_active * 20
    end
    return Defines.Chain.CONTINUE, value
end) ]]

-- Enhance Mind Heater with "remove MC in fire on top of gaining immunity" effect. - by Fajdek. WORKS with just MV+RK.
script.on_internal_event(Defines.InternalEvents.CREW_LOOP,function(crew)
    local shipManager = Hyperspace.ships(crew.iShipId)
    -- print(shipManager)
    local currentShipManager = Hyperspace.ships(crew.currentShipId)
    if shipManager and currentShipManager then
        if shipManager:HasAugmentation("INTERNAL_DJMOD_MC_IMMUNE_FROM_FIRE") > 0 then
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

    -- No need to make it work for enemies too, if someone jumps away it's a new fight.
    local stackAugCount = Hyperspace.ships.player:HasAugmentation(stackAugName)
    --print('stacks for removal:'..stackAugCount)

    if stackAugCount > 0 then
        local shipManager = Hyperspace.ships.player
        for i = 1, stackAugCount, 1 do
            --print('removed stack on jump')

            --Arc technique: pure Lua.
            shipManager:RemoveAugmentation("HIDDEN " .. stackAugName)
        end
    end
end)

-- TODO: W.I.P. internal RK Scorch "Backup Engine": charge jump drive slowly even with Piloting/Engines down. 
-- Code by Arc - fill in the gaps, might need to find out how to manually activate the Jump button when fully charged.
--[[ local time_increment = mods.multiverse.time_increment
local engines_charge_speed = 1
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
    if shipManager:HasAugmentation("YOUR_AUG") > 0 and shipManager:HasSystem(1) and shipManager:HasSystem(6) then
        local engines_status = shipManager:GetSystem(1):GetEffectivePower() <= 0
        local pilot_status = shipManager:GetSystem(6):GetEffectivePower() <= 0 or not shipManager:GetSystem(6).bManned
        if engines_status or pilot_status then
            shipManager.jump_timer.first = shipManager.jump_timer.first + engines_charge_speed * time_increment(true)
        end
    end
end) ]]