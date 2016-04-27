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

SETUP_HOOK(SELECT_ZONE_MOVE_CHANNEL_HOOKED, "SELECT_ZONE_MOVE_CHANNEL");
SETUP_HOOK(POPUP_CHANNEL_LIST_HOOKED, "POPUP_CHANNEL_LIST");


ui.SysMsg("Channel Surfer loaded!");
