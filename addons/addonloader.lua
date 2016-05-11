--[[
in the future, this will just iterate all folders to load every addon. for now,
just load them one at a time. to disable one, just delete or comment out the
line.
--]]

dofile("../addons/utility.lua"); --do not remove this one as it's a dependency for others.

--[[ADDONS]]
dofile("../addons/betterquest/betterquest.lua");
dofile("../addons/blockandreport/blockandreport.lua");
dofile("../addons/channelsurfer/channelsurfer.lua");
dofile("../addons/expcardcalculator/expcardcalculator.lua");
dofile("../addons/expviewer/expviewer.lua");
dofile("../addons/guildmates/guildmates.lua");
dofile("../addons/hidemaxedattributes/hidemaxedattributes.lua");
dofile("../addons/mapfogviewer/mapfogviewer.lua");
dofile("../addons/monsterframes/monsterframes.lua");
dofile("../addons/monstertracker/monstertracker.lua");
dofile("../addons/showinvestedstatpoints/showinvestedstatpoints.lua");

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

function SYSMENU_CHECK_HIDE_VAR_ICONS_HOOKED(frame)
	if false == VARICON_VISIBLE_STATE_CHANTED(frame, "necronomicon", "necronomicon")
	and false == VARICON_VISIBLE_STATE_CHANTED(frame, "grimoire", "grimoire")
	and false == VARICON_VISIBLE_STATE_CHANTED(frame, "guild", "guild")
	and false == VARICON_VISIBLE_STATE_CHANTED(frame, "poisonpot", "poisonpot")
	then
		return;
	end

	DESTROY_CHILD_BY_USERVALUE(frame, "IS_VAR_ICON", "YES");

	local status = frame:GetChild("status");
	local inven = frame:GetChild("inven");
	local offsetX = inven:GetX() - status:GetX();
	local startX = status:GetMargin().left - offsetX;

	startX = SYSMENU_CREATE_VARICON(frame, status, "guild", "guild", "sysmenu_guild", startX, offsetX, "Guild");
	startX = SYSMENU_CREATE_VARICON(frame, status, "necronomicon", "necronomicon", "sysmenu_card", startX, offsetX);
	startX = SYSMENU_CREATE_VARICON(frame, status, "grimoire", "grimoire", "sysmenu_neacro", startX, offsetX);
	startX = SYSMENU_CREATE_VARICON(frame, status, "poisonpot", "poisonpot", "sysmenu_wugushi", startX, offsetX);
	startX = SYSMENU_CREATE_VARICON(frame, status, "expcardcalculator", "expcardcalculator", "sysmenu_jem", startX, offsetX, "Addons");

	local expcardcalculatorButton = GET_CHILD(frame, "expcardcalculator", "ui::CButton");
	expcardcalculatorButton:SetTextTooltip("{@st59}Experience Card Calculator");
end

SETUP_HOOK(MAP_ON_INIT_HOOKED, "MAP_ON_INIT");
SETUP_HOOK(SYSMENU_CHECK_HIDE_VAR_ICONS_HOOKED, "SYSMENU_CHECK_HIDE_VAR_ICONS");

local sysmenuFrame = ui.GetFrame("sysmenu");
SYSMENU_CHECK_HIDE_VAR_ICONS(sysmenuFrame);

ui.SysMsg("Excrulon's addons loaded! (v1.9)");
