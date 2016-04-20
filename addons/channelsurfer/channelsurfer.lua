local settings = {
	maxNumberOfChannelsToShow = 30;
};

function SELECT_ZONE_MOVE_CHANNEL_HOOKED(index, channelID)
	local mapName = session.GetMapName();
	local mapCls = GetClass("Map", mapName);
	local zoneInsts = session.serverState.GetMap(mapCls.ClassID);
	if zoneInsts.pcCount == -1 then
		ui.SysMsg(ClMsg("ChannelIsClosed"));
		return;
	end

	app.ChangeChannel(channelID);
end

function POPUP_CHANNEL_LIST_HOOKED(parent)
    if parent:GetUserValue("ISOPENDROPCHANNELLIST") == "YES" then
        parent:SetUserValue("ISOPENDROPCHANNELLIST", "NO");
        return;
    end

    parent:SetUserValue("ISOPENDROPCHANNELLIST", "YES");

    local frame = parent:GetTopParentFrame();
    local ctrl = frame:GetChild("btn");
    local curchannel = frame:GetChild("curchannel");
    local mapName = session.GetMapName();
    local mapCls = GetClass("Map", mapName);

    local channel = session.loginInfo.GetChannel();

	local zoneInsts = session.serverState.GetMap(mapCls.ClassID);

	local NUMBER_OF_CHANNELS = zoneInsts:GetZoneInstCount();
	local numberOfChannelsToShow = NUMBER_OF_CHANNELS;

	if numberOfChannelsToShow >= settings.maxNumberOfChannelsToShow then
		numberOfChannelsToShow = settings.maxNumberOfChannelsToShow;
	end

    local dropListFrame = ui.MakeDropListFrame(ctrl, -270, 0, 300, 600, numberOfChannelsToShow, ui.LEFT, "SELECT_ZONE_MOVE_CHANNEL");

    if zoneInsts == nil then
        app.RequestChannelTraffics(mapCls.ClassID);
    else
        if zoneInsts:NeedToCheckUpdate() == true then
            app.RequestChannelTraffics(mapCls.ClassID);
        end

        for i = 0, NUMBER_OF_CHANNELS - 1 do
            local zoneInst = zoneInsts:GetZoneInstByIndex(i);
            local str, gaugeString = GET_CHANNEL_STRING(zoneInst);
            ui.AddDropListItem(str, gaugeString, zoneInst.channel);
        end
    end
end

local selectZoneMoveChannelHook = "SELECT_ZONE_MOVE_CHANNEL";

if _G["SELECT_ZONE_MOVE_CHANNEL_OLD"] == nil then
    _G["SELECT_ZONE_MOVE_CHANNEL_OLD"] = _G[selectZoneMoveChannelHook];
    _G[selectZoneMoveChannelHook] = SELECT_ZONE_MOVE_CHANNEL_HOOKED;
else
    _G[selectZoneMoveChannelHook] = SELECT_ZONE_MOVE_CHANNEL_HOOKED;
end

local popupChannelListHook = "POPUP_CHANNEL_LIST";

if _G["POPUP_CHANNEL_LIST_OLD"] == nil then
    _G["POPUP_CHANNEL_LIST_OLD"] = _G[popupChannelListHook];
    _G[popupChannelListHook] = POPUP_CHANNEL_LIST_HOOKED;
else
    _G[popupChannelListHook] = POPUP_CHANNEL_LIST_HOOKED;
end

ui.SysMsg("Channel Surfer loaded!");
