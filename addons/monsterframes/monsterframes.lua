function TGTINFO_TARGET_SET_HOOKED(frame, msg, argStr, argNum)
	_G["TGTINFO_TARGET_SET_OLD"](frame, msg, argStr, argNum);

	local targetinfo = info.GetTargetInfo(session.GetTargetHandle());

	if argStr == "None" then
		return;
	end

	local stat = info.GetStat(session.GetTargetHandle());
	if stat == nil then
		return;
	end

	if nil == targetinfo then
		return
	end

	local numhp = frame:CreateOrGetControl("richtext", "numhp", -17, 0, 176, 115);
	tolua.cast(numhp, "ui::CRichText");
	numhp:ShowWindow(1);
	numhp:SetGravity(ui.CENTER_HORZ, ui.TOP);
	numhp:SetTextAlign("center", "center");
	numhp:SetText(ADD_THOUSANDS_SEPARATOR(stat.HP) .. "/" .. ADD_THOUSANDS_SEPARATOR(stat.maxHP));
	numhp:SetFontName("white_16_ol");

	local attribute = frame:CreateOrGetControl("picture", "attribute", 0, 0, 100, 40);
	tolua.cast(attribute, "ui::CPicture");

	if targetinfo.attribute ~= nil and targetinfo.attribute ~= "Melee" then
		attribute:ShowWindow(1);
		attribute:SetGravity(ui.LEFT, ui.TOP);
		attribute:SetImage('Attri_' .. targetinfo.attribute);
		attribute:SetOffset(110, 9);
	else
		attribute:ShowWindow(0);
	end

	local armorType = frame:CreateOrGetControl("picture", "armorType", 0, 0, 100, 40);
	tolua.cast(armorType, "ui::CPicture");

	if targetinfo.armorType ~= nil and targetinfo.armorType ~= "None" then
		armorType:ShowWindow(1);
		armorType:SetGravity(ui.LEFT, ui.TOP);
		armorType:SetImage("Armor_" .. targetinfo.armorType);
		armorType:SetOffset(145, 9);
	else
		armorType:ShowWindow(0);
	end

	local raceType = frame:CreateOrGetControl("picture", "raceType", 0, 0, 100, 40);
	tolua.cast(raceType, "ui::CPicture");

	if targetinfo.raceType ~= nil and targetinfo.raceType ~= "Item" then
		raceType:ShowWindow(1);
		raceType:SetGravity(ui.LEFT, ui.TOP);
		raceType:SetImage('Tribe_' .. targetinfo.raceType);
		raceType:SetOffset(180, 6);
	else
		raceType:ShowWindow(0);
	end

	local targetSizeText = frame:CreateOrGetControl("richtext", "targetSizeText", 0, 0, 100, 40);
	tolua.cast(targetSizeText, "ui::CRichText");

	if targetinfo.size ~= nil then
		targetSizeText:ShowWindow(1);
		targetSizeText:SetOffset(220, 3);
		targetSizeText:SetText("{@st41}{s36}" .. targetinfo.size);
	else
		targetSizeText:ShowWindow(0);
	end

	--may enable showing this later but it's ugly for now and not very useful
	--[[
	local monactor = world.GetActor(session.GetTargetHandle());
    local montype = monactor:GetType()
	local monCls = GetClassByType("Monster", montype);

	if monCls ~= nil then
		local wiki = GetWikiByName(monCls.ClassName);

		if wiki ~= nil then
			local exp = GetWikiIntProp(wiki, "Exp");
			local jobExpProp = GetWikiIntProp(wiki, "JobExp");
			local expProp = GetWikiIntProp(wiki, "Exp");
    		local jobExpProp = GetWikiIntProp(wiki, "JobExp");

			REFRESH_RANKING(monCls, false);

			local killCount = GetWikiIntProp(wiki, "KillCount");
			local journalMonsterKillReward = GetClass('Journal_monkill_reward', monCls.ClassName);

			local monsterTrackerText = frame:CreateOrGetControl("richtext", "monsterTrackerText", 300, 40, 100, 40);
			tolua.cast(monsterTrackerText, "ui::CRichText");
			monsterTrackerText:SetGravity(ui.LEFT, ui.TOP);
			monsterTrackerText:SetTextAlign("left", "center");
			monsterTrackerText:SetFontName("white_16_ol");

			if journalMonsterKillReward ~= nil then
				local killsRequired = journalMonsterKillReward.Count1;

				monsterTrackerText:SetText(killCount .. " / " .. killsRequired .. " kills");
				monsterTrackerText:ShowWindow(1);
			else
				monsterTrackerText:SetText("");
				monsterTrackerText:ShowWindow(0);
			end

			local experienceText = frame:CreateOrGetControl("richtext", "experienceText", 300, 20, 100, 40);
			tolua.cast(experienceText, "ui::CRichText");
			experienceText:SetGravity(ui.LEFT, ui.TOP);
			experienceText:SetTextAlign("left", "center");
			experienceText:SetFontName("white_16_ol");
			experienceText:SetText(expProp .. " / " .. jobExpProp .. " exp");
		end
	end
	--]]
end

function TARGETINFO_ON_MSG_HOOKED(frame, msg, argStr, argNum)
	local oldf = _G["TARGETINFO_ON_MSG_OLD"];
    oldf(frame, msg, str, exp, tableinfo);

	if frame == nil then
		return
	end

	if msg == 'TARGET_UPDATE' then
		local stat = info.GetStat(session.GetTargetHandle());
		if stat == nil then
			return;
		end

		local targetinfo = info.GetTargetInfo(session.GetTargetHandle());

		local numhp = frame:CreateOrGetControl("richtext", "numhp", -17, 0, 176, 115);
		tolua.cast(numhp, "ui::CRichText");
		numhp:ShowWindow(1);
		numhp:SetGravity(ui.CENTER_HORZ, ui.TOP);
		numhp:SetTextAlign("center", "center");
		numhp:SetText(ADD_THOUSANDS_SEPARATOR(stat.HP) .. "/" .. ADD_THOUSANDS_SEPARATOR(stat.maxHP));
		numhp:SetFontName("white_16_ol");
	end
end

local targetInfoHook = "TGTINFO_TARGET_SET";

if _G["TGTINFO_TARGET_SET_OLD"] == nil then
	_G["TGTINFO_TARGET_SET_OLD"] = _G[targetInfoHook];
	_G[targetInfoHook] = TGTINFO_TARGET_SET_HOOKED;
else
	_G[targetInfoHook] = TGTINFO_TARGET_SET_HOOKED;
end

local targetInfoOnMsgHooked = "TARGETINFO_ON_MSG";

if _G["TARGETINFO_ON_MSG_OLD"] == nil then
	_G["TARGETINFO_ON_MSG_OLD"] = _G[targetInfoOnMsgHooked];
	_G[targetInfoOnMsgHooked] = TARGETINFO_ON_MSG_HOOKED;
else
	_G[targetInfoOnMsgHooked] = TARGETINFO_ON_MSG_HOOKED;
end

ui.SysMsg("Monster Frames loaded!");
