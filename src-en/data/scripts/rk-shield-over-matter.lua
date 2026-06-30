-- mods.rk = {}
-- WORKS with mods.rk = {} defined here, and in a separate core.lua .

local function get_room_at_location(shipManager, location, includeWalls)
    return Hyperspace.ShipGraph.GetShipInfo(shipManager.iShipId):GetSelectedRoom(location.x, location.y, includeWalls)
end

-- RK BPS Shield Over Matter augment.

local userdata_table = mods.rk.userdata_table
local create_damage_message = mods.rk.create_damage_message
local damageMessages = mods.rk.damageMessages
local function bp_list_search(listName, element)
    if not (listName and element) then return nil end
    local list = Hyperspace.Blueprints:GetBlueprintList(listName)
    for i = 0, list:size() - 1 do
        if element == list[i] then
            return i
        end
    end
    return nil
end

-- Define auto-reshield augments. This contains reshieldData for each of these augments.
mods.rk.autoReshieldAugs = {
    --[[
    ARMOR_MISSILES = {
        amount = 1, -- The CHANCE to auto-reshield? Should be the value in the aug instead i guess.
        weapons = "LIST_WEAPONS_MISSILES" -- Blueprint list of weapons the augment applies to (leave undefined to apply to all weapons)
    },
    --]]
    RK_BPS_SHIELD_OVER_MATTER = {
        amount = 1
    }
}
local autoReshieldAugs = mods.rk.autoReshieldAugs

-- Regen supershields for relevant augments
local function handle_auto_reshield(shipManager, projectile, location, damage, immediateDmgMsg)
    -- Check for auto-reshield augments
    -- print("Handle Auto-reshield")

    for augName, reshieldData in pairs(autoReshieldAugs) do
        -- print("Auto-reshield: loop")
        if shipManager:HasAugmentation(augName) > 0 then
            -- Check if weapon is on the list of things to trigger auto-reshield
            if not reshieldData.weapons or bp_list_search(reshieldData.weapons, projectile and projectile.extend and projectile.extend.name) then
                
                -- print("Auto-reshield: affected weapons: pass")
                if reshieldData.amount > 0 then
                    --[[ -- Check if incoming damage is greater than the reduction amount
                    if damage.iDamage > reshieldData.amount then
                        -- Reduce damage
                        damage.iDamage = damage.iDamage - reshieldData.amount
                    elseif damage.iDamage > 0 then ]]
                    if damage.iDamage > 0 then
                        -- Roll the chance to reshield.
                        local reshieldChance = shipManager:GetAugmentationValue(augName)
                        -- if math.random() < shipManager:GetAugmentationValue(augName) then
                        if math.random() < reshieldChance then

                            -- damage.iDamage = 0

                            --[[ REF The Outer Expansion's aea_super_shields aka Auxiliary Shields
                            local aea_super_shields_system = shipManager:GetSystem(Hyperspace.ShipSystem.NameToSystemId("aea_super_shields"))
                            local layersLeft = 2 + math.ceil(aea_super_shields_system:GetEffectivePower()/2) - shipManager.shieldSystem.shields.power.super.first
                            if layersLeft > 0 then
                                for i = 1, layersLeft do
                                    shipManager.shieldSystem:AddSuperShield(shipManager.shieldSystem.superUpLoc)
                                end
                                aea_super_shields_system:LockSystem(cooldownValue)
                            end
                            ]]
                            
                            local superShieldsToAdd = shipManager.shieldSystem.shields.power.super.second - shipManager.shieldSystem.shields.power.super.first
                            -- print("superShieldsToAdd: " .. superShieldsToAdd)
                            if superShieldsToAdd > 0 then
                                -- Just 1 layer. WORKS
                                shipManager.shieldSystem:AddSuperShield(shipManager.shieldSystem.superUpLoc)
                                --[[ for i = 1, superShieldsToAdd do
                                    shipManager.shieldSystem:AddSuperShield(shipManager.shieldSystem.superUpLoc)
                                end ]]
                            end

                            -- Guaranteed fire to the hit room. WORKS
                            local hitRoomId = get_room_at_location(shipManager, location, false)
                            -- print("Auto-reshield 100fire")
                            if hitRoomId then
                                -- print("Auto-reshield 100fire at: "..hitRoomId)
                                shipManager:StartFire(hitRoomId)
                            end
                                

                            -- Random fire chance to all systems. Untested!
                            -- for room in vter(shipManager.ship.vRoomList) do
                            --[[ for system in vter(shipManager.vSystemList) do

                                -- Random self-Fire. WORKS?
                                print("Auto-reshield: self-fire loop")

                                -- local roomId = room.iRoomId
                                local roomId = shipManager:GetSystemRoom(system:GetId())
                                -- local location = shipManager:GetRoomCenter(roomId)
                                local reshieldFireChance = reshieldChance * 0.5     -- intended: * 0.05
                                
                                print("reshieldFireChance: "..reshieldFireChance)
                                if math.random() < reshieldFireChance then
                                    shipManager:StartFire(roomId)
                                end
                            end ]]
                            

                            -- Seems unneeded
                            if immediateDmgMsg == true then
                                create_damage_message(shipManager.iShipId, damageMessages.NEGATED, location.x, location.y)
                            else
                                userdata_table(projectile, "mods.rk.autoReshieldAugs").showMsg = true
                            end
                        end
                    end
                --[[ elseif damage.iDamage > 0 then
                    -- Increase damage for negative values
                    damage.iDamage = damage.iDamage - reshieldData.amount ]]
                end
            end
        end
    end
end
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, handle_auto_reshield)
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(shipManager, projectile, location)
    if projectile and userdata_table(projectile, "mods.rk.autoReshieldAugs").showMsg then
        create_damage_message(shipManager.ishipManagerId, damageMessages.NEGATED, location.x, location.y)
    end
end)
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(shipManager, projectile, location, damage, realNewTile, beamHitType)
    if beamHitType == Defines.BeamHit.NEW_ROOM then
        handle_auto_reshield(shipManager, projectile, location, damage, true)
    end
end)


--[[ REF: MV's damage-reduction-armor
local userdata_table = mods.multiverse.userdata_table
local create_damage_message = mods.multiverse.create_damage_message
local damageMessages = mods.multiverse.damageMessages
local function bp_list_search(listName, element)
    if not (listName and element) then return nil end
    local list = Hyperspace.Blueprints:GetBlueprintList(listName)
    for i = 0, list:size() - 1 do
        if element == list[i] then
            return i
        end
    end
    return nil
end

-- Define damage reduction armor augments
mods.multiverse.reductionArmor = {
    
    -- MV SAYS:
    ARMOR_MISSILES = {
        amount = 1, -- The amount of damage the augment protects against
        weapons = "LIST_WEAPONS_MISSILES" -- Blueprint list of weapons the augment applies to (leave undefined to apply to all weapons)
    },
    --
    
    PALADIN_ARMOR = {
        amount = 1
    },
    LOCKED_PALADIN_ARMOR = {
        amount = 1
    },
    PALADIN_ARMOR_PLAYER = {
        amount = 2
    },
    CRYSTAL_ARMOR_100 = {
        amount = -1
    }
}
local reductionArmor = mods.multiverse.reductionArmor

-- Reduce damage for reduction armor
local function handle_reduction_armor(ship, projectile, location, damage, immediateDmgMsg)
    -- Check for damage reduction augments
    for augName, reductionData in pairs(reductionArmor) do
        if ship:HasAugmentation(augName) > 0 then
            -- Check if weapon is on the list of things to resist
            if not reductionData.weapons or bp_list_search(reductionData.weapons, projectile and projectile.extend and projectile.extend.name) then
                if reductionData.amount > 0 then
                    -- Check if incoming damage is greater than the reduction amount
                    if damage.iDamage > reductionData.amount then
                        -- Reduce damage
                        damage.iDamage = damage.iDamage - reductionData.amount
                    elseif damage.iDamage > 0 then
                        -- Otherwise roll a chance to negate the damage entirely based on the augment value
                        if math.random() < ship:GetAugmentationValue(augName) then
                            damage.iDamage = 0
                            if immediateDmgMsg == true then
                                create_damage_message(ship.iShipId, damageMessages.NEGATED, location.x, location.y)
                            else
                                userdata_table(projectile, "mods.mv.reductionArmor").showMsg = true
                            end
                        end
                    end
                elseif damage.iDamage > 0 then
                    -- Increase damage for negative values
                    damage.iDamage = damage.iDamage - reductionData.amount
                end
            end
        end
    end
end
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, handle_reduction_armor)
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location)
    if projectile and userdata_table(projectile, "mods.mv.reductionArmor").showMsg then
        create_damage_message(ship.iShipId, damageMessages.NEGATED, location.x, location.y)
    end
end)
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(ship, projectile, location, damage, realNewTile, beamHitType)
    if beamHitType == Defines.BeamHit.NEW_ROOM then
        handle_reduction_armor(ship, projectile, location, damage, true)
    end
end)
 ]]