-- This is not to be added in the hyperspace.xml, so it should do nothing.
-- Meant to keep a trace of code i could use in the future.

-- Lua Damage Types
damage.iDamage       = 0
damage.iSystemDamage = 0
damage.iIonDamage    = 0
damage.iPersDamage   = 0
damage.fireChance    = 0
damage.breachChance  = 0
damage.stunChance    = 0

function chal_jumped_away() -- The file this is in actually contains ALL of the addon's Lua.

    -- REF ARS+ challenges, challenge "Queen Bee to keep alive" aka "gusq".
    playerShip:AddCrewMemberFromString(Hyperspace.Text:GetText('lua_name_gusq'), "gusq", false, -1, false, false)
    if Hyperspace.metaVariables['challenge_nogus'] == 1 then
        if count_of_gusq_on_player_ship() == 0 then
            Hyperspace.metaVariables['challenge_nogus'] = 0
        elseif playerShip.currentScrap > 0 then
            playerShip:ModifyScrapCount(-1, false)
            -- Similar
            playerShip:ModifyDroneCount(-99999)
			playerShip:ModifyMissileCount(-99999)
        end
    end

    -- REF ARS+ challenges, challenge "crew loses all skills every jump".
    if Hyperspace.metaVariables['challenge_nobrain'] == 1 then
        --print('aa')
        for crew in vter(playerShip.vCrewList) do
            if crew.intruder == false then
                crew:SetSkillProgress(0, 0)
                crew:SetSkillProgress(1, 0)
                crew:SetSkillProgress(2, 0)
                crew:SetSkillProgress(3, 0)
                crew:SetSkillProgress(4, 0)
                crew:SetSkillProgress(5, 0)
            end
        end
    end

    -- This is already a bit RK edited, revert to source.
    if playerShip and playerShip.bJumping == true then
        if Hyperspace.metaVariables['challenge_nobuh'] == 1 then
            add_to_LaunchOrder("ADD_WOF_STACK_Q") --check
            print('add')
        end
    end
end
script.on_internal_event(Defines.InternalEvents.JUMP_LEAVE, chal_jumped_away)


--[[ REF: ARS+ challenges for MV v5.5.1
Lua defers to XML for adding/removing hidden augments!

<event name="ADD_DRUNK_CREWQ">
	<queueEvent>ADD_DRUNK_CREW</queueEvent>
</event>
<event name="ADD_DRUNK_CREW">
	<hiddenAug>DRUNK_CREW</hiddenAug>
	<!--<variable name="installed_DRUNK_CREW" op="set" val="1"/-->
</event>

<event name="UPDATE_CARGO_SLOT_Q"><!-- 1.35 --> <!-- for no cargo challenge -->
	<queueEvent>UPDATE_CARGO_SLOT1</queueEvent>
</event>
<event name="UPDATE_CARGO_SLOT1"><!-- 1.35 -->
	<remove name="HIDDEN CARGO_SLOT"/>
	<queueEvent>UPDATE_CARGO_SLOT2</queueEvent>
</event>
<event name="UPDATE_CARGO_SLOT2"><!-- 1.35 -->
	<remove name="HIDDEN CARGO_SLOT"/>
	<queueEvent>UPDATE_CARGO_SLOT3</queueEvent>
</event>
<event name="UPDATE_CARGO_SLOT3"><!-- 1.35 -->
	<hiddenAug>CARGO_SLOT</hiddenAug>
</event> ]]

    --[[ Aleev technique
    if stackAugCount > 0 then
        for key, value in pairs(t) do
            add_to_LaunchOrder("REMOVE_WOF_STACK_Q") --check
            print('removed stack on jump')    
        end
    end ]]

    --Aleev technique
    --Add_to_LaunchOrder("REMOVE_WOF_STACK_Q") -- Was happening even at 0 stacks. WORKS NOW?

-- REF: codyfun's InExAUg aka "Internalize any augment"
local extAugCount = player:GetAugmentationCount()
player:AddAugmentation("HIDDEN " .. augName)    -- Probably outdated. "HIDDEN " should now only be for removal.
player:RemoveAugmentation(augName)      -- ... and this should be: player:RemoveAugmentation("HIDDEN " .. augName)

-- -REF Pepper's NoConsole's augment_button
ship:AddAugmentation(augId)
notifyOperation("Augment " .. tostring(item.id) .. " was added")