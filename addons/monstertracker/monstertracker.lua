_G["MONSTER_TRACKER"] = {};

function MON_DEAD_CLIENT_HOOKED(actor)
	_G["MON_DEAD_CLIENT_OLD"](actor);

	local obj = actor;
	local monID = obj:GetType();
	if monID ~= 0 then
		local monCls = GetClassByType("Monster", monID);

		local wiki = GetWikiByName(monCls.Journal);
		local killCount = GetWikiIntProp(wiki, "KillCount") + 1;
		local killsRequired = GetClass('Journal_monkill_reward', monCls.Journal).Count1;

		if killCount == killsRequired then
			ui.SysMsg("Congrats! You've completed the monster kill requirements for " .. monCls.Name .. "! Redeem your reward at Wings of Vibora in town!");
			imcSound.PlaySoundEvent("sys_levelup");
		end

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
end

local deadMobHook = "MON_DEAD_CLIENT";

if _G["MON_DEAD_CLIENT_OLD"] == nil then
	_G["MON_DEAD_CLIENT_OLD"] = _G[deadMobHook];
	_G[deadMobHook] = MON_DEAD_CLIENT_HOOKED;
else
	_G[deadMobHook] = MON_DEAD_CLIENT_HOOKED;
end

ui.SysMsg("Monster Tracker loaded!");
