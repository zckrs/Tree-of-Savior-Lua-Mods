_G["MONSTER_TRACKER"] = {};

function FPS_ON_MSG_HOOKED(frame, msg, argStr, argNum)
	_G["FPS_ON_MSG_OLD"](frame, msg, argStr, argNum);

	local result = SCR_GET_ZONE_FACTION_OBJECT(session.GetMapName(), "Monster", "Normal/Material/Elite", 120000);

	for k,v in pairs(result) do
	    local mobName = v[1];
	    local totalSpawn = v[2];

		local monCls = GetClass("Monster", mobName);
		local wiki = GetWikiByName(monCls.Journal);

		local killCount = GetWikiIntProp(wiki, "KillCount") + 1;
		local killsRequired = GetClass('Journal_monkill_reward', monCls.Journal).Count1;

		if _G["MONSTER_TRACKER"][monCls.ClassID] == nil then
			_G["MONSTER_TRACKER"][monCls.ClassID] = killCount;
		end

		if killCount > _G["MONSTER_TRACKER"][monCls.ClassID] then

			local killNoticeFrame = ui.GetFrame("killnotice");
			killNoticeFrame:SetGravity(ui.RIGHT, ui.BOTTOM);

			local monsterImage = GET_CHILD(killNoticeFrame, "monsterImage");
			monsterImage:SetImage(GET_MON_ILLUST(monCls));
			monsterImage:SetGravity(ui.LEFT, ui.TOP);
			monsterImage:Resize(50, 50);
			monsterImage:Move(0, 0);
			monsterImage:SetOffset(0, 0);

			local killNoticeText = killNoticeFrame:GetChild("killNoticeText");
			tolua.cast(killNoticeText, "ui::CRichText");
			killNoticeText:SetText("{@st42}" .. ADD_THOUSANDS_SEPARATOR(killCount) .. " / " .. ADD_THOUSANDS_SEPARATOR(killsRequired) .. " " .. monCls.Name .. " killed{/}");
			killNoticeText:SetGravity(ui.LEFT, ui.TOP);
			killNoticeText:SetTextAlign("left", "top");
			killNoticeText:Move(0, 0);
			killNoticeText:SetOffset(55, 17);

			killNoticeFrame:ShowWindow(1);
			killNoticeFrame:SetDuration(5.0);
		end

		_G["MONSTER_TRACKER"][monCls.ClassID] = killCount;

		if killCount == killsRequired then
			ui.SysMsg("Congrats! You've completed the monster kill requirements for " .. monCls.Name .. "! Redeem your reward at Wings of Vibora in town!");
			imcSound.PlaySoundEvent("sys_levelup");
		end
	end
end

local FPS_ON_MSGHook = "FPS_ON_MSG";

if _G["FPS_ON_MSG_OLD"] == nil then
	_G["FPS_ON_MSG_OLD"] = _G[FPS_ON_MSGHook];
	_G[FPS_ON_MSGHook] = FPS_ON_MSG_HOOKED;
else
	_G[FPS_ON_MSGHook] = FPS_ON_MSG_HOOKED;
end

ui.SysMsg("Monster Tracker loaded!");
