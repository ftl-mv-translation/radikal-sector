--[[
MV's "breathable atmosphere hazard" with the O2 icon is actually pure Lua tied only to the background image.
No fitting background image exists, so we add one and set its atmosphere status to true here.
]]--

local atmo = mods.multiverse.atmoBackgrounds

atmo.BACK_DJMOD_OXYGENIZER_ACTIVATE = true