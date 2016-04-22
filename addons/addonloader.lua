--[[
in the future, this will just iterate all folders to load every addon. for now,
just load them one at a time. to disable one, just delete or comment out the
line.
--]]

dofile("../addons/utility.lua"); --do not remove this one as it's a dependency for others.

--[[ADDONS]]
dofile("../addons/expviewer/expviewer.lua");
dofile("../addons/mapfogviewer/mapfogviewer.lua");
dofile("../addons/monsterframes/monsterframes.lua");
dofile("../addons/monstertracker/monstertracker.lua");
dofile("../addons/channelsurfer/channelsurfer.lua");
dofile("../addons/showInvestedStatPoints/showInvestedStatPoints.lua");

--do not touch below here
local addonLoaderFrame = ui.GetFrame("addonloader");
addonLoaderFrame:ShowWindow(0);
_G["ADDON_LOADER"] = {};
_G["ADDON_LOADER"]["LOADED"] = true;

function MAP_ON_INIT_HOOKED(addon, frame)
	_G["MAP_ON_INIT_OLD"](addon, frame);

	if _G["ADDON_LOADER"]["LOADED"] then
		local addonLoaderFrame = ui.GetFrame("addonloader");
		addonLoaderFrame:ShowWindow(0);
	end
end

local mapOnInitHook = "MAP_ON_INIT";

if _G["MAP_ON_INIT_OLD"] == nil then
	_G["MAP_ON_INIT_OLD"] = _G[mapOnInitHook];
	_G[mapOnInitHook] = MAP_ON_INIT_HOOKED;
else
	_G[mapOnInitHook] = MAP_ON_INIT_HOOKED;
end

ui.SysMsg("Excrulon's addons loaded! (v1.6)");
