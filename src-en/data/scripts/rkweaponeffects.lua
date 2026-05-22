local vter = mods.multiverse.vter

--[[ REF: ARS+ Challenges. "varr" is a GIGANTIFIC thing, i only pasted the one line needed.
function clear_LaunchOrder()
	--print('clean')
	for i = 0, 100 do
		varr.event_order_caller[i] = ""
	end
end
function add_to_LaunchOrder(ev_name_loc)
	for i = 0, 100 do
		if varr.event_order_caller[i] == "" then
			varr.event_order_caller[i] = ev_name_loc
			--print('added'..ev_name_loc)
			return
		end
	end
end
function try_zero_in_LaunchOrder()
	if varr.event_order_caller[0] ~= "" then
		--print('launch'..varr.event_order_caller[0])
		Hyperspace.CustomEventsParser.GetInstance():LoadEvent(Hyperspace.App.world, varr.event_order_caller[0], true, -1)
		varr.event_order_caller[0] = ""
		for i = 0, 99 do
			varr.event_order_caller[i] = varr.event_order_caller[i+1]
		end
		varr.event_order_caller[100] = ""
	end
end ]]
--[[ local event_order_caller = {[0]="",[1]=""}
function Add_to_LaunchOrder(ev_name_loc)
	for i = 0, 100 do
		if event_order_caller[i] == "" then
			event_order_caller[i] = ev_name_loc
			print('added event'..ev_name_loc)
			return
		end
	end
end ]]



script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)

    -- Gravespred beam.
    --[[ REF Lily's Beam Emporium:

    if weapon.blueprint and weapon.blueprint.name == "LILY_FOCUS_ION_PHASE" then

        local damage = projectile.damage
        damage.iShieldPiercing = damage.iIonDamage + 1
        damage.iIonDamage = 2 + (damage.iShieldPiercing > 10 and (damage.iShieldPiercing - 10) / 10 or 0)
        --print(projectile.damage.iIonDamage)
        --print(projectile.damage.iShieldPiercing)
    end ]]
    --[[ REF Lizzard's variety:
    if weaponName == "LV_MALF_RECOIL" then

        local shipId = projectile.ownerId
        local shipManager = Hyperspace.Global.GetInstance():GetShipManager(shipId)

        for system in vter(shipManager.vSystemList) do

            local roomId = shipManager:GetSystemRoom(system:GetId())

            local location = shipManager:GetRoomCenter(roomId)

            local crewDamage = Hyperspace.Damage()
            crewDamage.iPersDamage = 1
            shipManager:DamageArea(location, crewDamage, true)
        end

        userdata_table(weapon, "mods.modname.recoil").recoilGoodTime = 2

    end ]]
    local shipId = projectile.ownerId
    local shipManager = Hyperspace.Global.GetInstance():GetShipManager(shipId)

    if weapon.blueprint and weapon.blueprint.name == "RK_KILLALL_BEAM" then
        -- Scaling piercing
        local damage = projectile.damage
        -- damage.iShieldPiercing = damage.iPersDamage - 1     -- Somehow this is always 1 lower than expected.
        damage.iShieldPiercing = damage.iPersDamage
        -- print(projectile.damage.iShieldPiercing)
        -- print(projectile.damage.iPersDamage)

        -- Crew self-damage
        --[[ local shipId = projectile.ownerId
        local shipManager = Hyperspace.Global.GetInstance():GetShipManager(shipId) ]]

        for room in vter(shipManager.ship.vRoomList) do
            -- print("killall_beam: 1 vter loop")

            local roomId = room.iRoomId

            local location = shipManager:GetRoomCenter(roomId)

            local crewDamage = Hyperspace.Damage()
            -- If crew damage to other ship is at least 2, deal 1 damage in player ship. Untested!
            -- crewDamage.iPersDamage = math.maxinteger(0, math.mininteger(1, damage.iPersDamage))
            -- Scale with outwards damage. WORKS
            crewDamage.iPersDamage = math.max(0, damage.iPersDamage - 3)
            -- print(crewDamage.iPersDamage)
            if (crewDamage.iPersDamage > 0) then
                shipManager:DamageArea(location, crewDamage, true)
            end
        end
        --[[ WORKS but only does system rooms.
        for system in vter(shipManager.vSystemList) do
            -- print("killall_beam: 1 vter loop")

            local roomId = shipManager:GetSystemRoom(system:GetId())
            local location = shipManager:GetRoomCenter(roomId)
            local crewDamage = Hyperspace.Damage()
            -- Scale with outwards damage. WORKS
            crewDamage.iPersDamage = math.max(0, damage.iPersDamage - 3)
            print(crewDamage.iPersDamage)
            if (crewDamage.iPersDamage > 0) then
                shipManager:DamageArea(location, crewDamage, true)
            end
        end ]]
    end

    -- RK Scorch Pre-Igniter augment
    if shipManager:HasAugmentation("RK_SCORCH_PREIGNITER") > 0 then
        local roomId = shipManager.weaponSystem.roomId
        if roomId then
            -- REF: NoConsole by Pepper
            -- ship:StartFire(roomId)
            shipManager:StartFire(roomId)
        end
    end

    -- Weapons On Fire augment
    local augName = "RK_WEAPONS_ON_FIRE"
    local stackAugName = "RK_WEAPONS_ON_FIRE_TEMP"
    if shipManager:HasAugmentation(augName) > 0 then
        -- Chance fire - WORKS
        if math.random() < shipManager:GetAugmentationValue(augName) then
            local roomId = shipManager.weaponSystem.roomId
            if roomId then
                shipManager:StartFire(roomId)
            end
            -- Artilleries - WORKS
            for arti in vter(shipManager.artillerySystems) do
                if arti then
                    local artiRoomId = arti.roomId
                    shipManager:StartFire(artiRoomId)
                end
            end
        end

        -- Stack fire rate - clear on jump.
        local augCount = Hyperspace.ships.player:HasAugmentation(stackAugName)
        --print("aug count for adding:"..augCount)
        if augCount < 10 then
            -- Add temp aug

            -- Arc technique: pure Lua. WORKS
            shipManager:AddAugmentation("HIDDEN " .. stackAugName)
        end
    end
end)