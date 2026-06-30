
script.on_game_event("RKS_UPGRADE_REACTOR_BY_5", false, function()
	local powerManager = Hyperspace.PowerManager.GetPowerManager(0)
	powerManager.currentPower.second = powerManager.currentPower.second + 5
end)
--[[ REF: The Outer Expansion v7.1.10 for MV v5.5.1:

script.on_game_event("INSTALL_AEA_OLD_REACTOR", false, function()
	local powerManager = Hyperspace.PowerManager.GetPowerManager(0)
	powerManager.currentPower.second = powerManager.currentPower.second + 1
end) ]]