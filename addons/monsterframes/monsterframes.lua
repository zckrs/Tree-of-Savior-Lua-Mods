function SHOW_PROPERTY_WINDOW(frame, monCls, targetInfoProperty, monsterPropertyIcon, x, y, spacingX, spacingY)
	local propertyType = frame:CreateOrGetControl("picture", monsterPropertyIcon .. "_icon", 0, 0, 100, 40);
	tolua.cast(propertyType, "ui::CPicture");
	if (targetInfoProperty == nil and monsterPropertyIcon == "EffectiveAtkType") or (targetInfoProperty ~= nil) then
		propertyType:SetGravity(ui.LEFT, ui.TOP);
		propertyType:SetImage(GET_MON_PROPICON_BY_PROPNAME(monsterPropertyIcon, monCls));
		propertyType:SetOffset((x + spacingX), (y - spacingY));
		propertyType:ShowWindow(1);
	else
		propertyType:ShowWindow(0);
	end
end

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
        return;
    end

	local monactor = world.GetActor(session.GetTargetHandle());
	local montype = monactor:GetType();
	local monCls = GetClassByType("Monster", montype);

	if monCls == nil then
		return;
	end

    -- hp
    local numhp = nil;
    if targetinfo.isElite == 1 then
        numhp = frame:CreateOrGetControl("richtext", "numhp", 3, -5, 176, 115);
    else
        numhp = frame:CreateOrGetControl("richtext", "numhp", -17, 0, 176, 115);
    end
    if numhp ~= nil then
        tolua.cast(numhp, "ui::CRichText");
        numhp:ShowWindow(1);
        numhp:SetGravity(ui.CENTER_HORZ, ui.TOP);
        numhp:SetTextAlign("center", "center");
        numhp:SetText(ADD_THOUSANDS_SEPARATOR(stat.HP) .. "/" .. ADD_THOUSANDS_SEPARATOR(stat.maxHP));
        numhp:SetFontName("white_16_ol");
    end

	local xPosition = 100;
	local yPosition = 17;
	local propertyWidth = 35;

	if targetinfo.isElite == 1 then
		xPosition = 117;
		yPosition = 12;
	end
	
	SHOW_PROPERTY_WINDOW(frame, monCls, targetinfo.raceType, "RaceType", xPosition + (0 * propertyWidth), yPosition, 10, 10);
	SHOW_PROPERTY_WINDOW(frame, monCls, targetinfo.attribute, "Attribute", xPosition + (1 * propertyWidth), yPosition, 10, 10);
	SHOW_PROPERTY_WINDOW(frame, monCls, targetinfo.armorType, "ArmorMaterial", xPosition + (2 * propertyWidth), yPosition, 10, 10);
	SHOW_PROPERTY_WINDOW(frame, monCls, monCls["MoveType"], "MoveType", xPosition + (3 * propertyWidth), yPosition, 10, 10);
	SHOW_PROPERTY_WINDOW(frame, monCls, nil, "EffectiveAtkType", xPosition + (4 * propertyWidth), yPosition, 10, 10);

	local targetSizeText = frame:CreateOrGetControl("richtext", "targetSizeText", 0, 0, 100, 40);
	tolua.cast(targetSizeText, "ui::CRichText");
	if targetinfo.size ~= nil then
		targetSizeText:SetOffset(xPosition + (5 * propertyWidth) + 10, yPosition - 8);
		targetSizeText:SetText("{@st41}{s28}" .. targetinfo.size);
		targetSizeText:ShowWindow(1);
	else
		targetSizeText:ShowWindow(0);
	end

	local wiki = GetWikiByName(monCls.Journal);

	if wiki ~= nil then
		local killCount = GetWikiIntProp(wiki, "KillCount");
		local killsRequired = GetClass('Journal_monkill_reward', monCls.Journal).Count1;

		local killCountText = frame:CreateOrGetControl("richtext", "killCountText", 0, 0, 100, 40);
		tolua.cast(killCountText, "ui::CRichText");
		if targetinfo.size ~= nil then
			killCountText:SetOffset(0, 0);
			killCountText:SetFontName("white_16_ol");
			killCountText:SetText(ADD_THOUSANDS_SEPARATOR(killCount) .. " / " .. ADD_THOUSANDS_SEPARATOR(killsRequired));
			killCountText:ShowWindow(1);
		else
			killCountText:ShowWindow(0);
		end
	end
end

function TARGETINFO_ON_MSG_HOOKED(frame, msg, argStr, argNum)
    local oldf = _G["TARGETINFO_ON_MSG_OLD"];
    oldf(frame, msg, str, exp, tableinfo);

    if frame == nil then
        return;
    end

    if msg == 'TARGET_UPDATE' then
        local stat = info.GetStat(session.GetTargetHandle());
        if stat == nil then
            return;
        end

        local numhp = frame:CreateOrGetControl("richtext", "numhp", -17, 0, 176, 115);
        tolua.cast(numhp, "ui::CRichText");
        numhp:ShowWindow(1);
        numhp:SetGravity(ui.CENTER_HORZ, ui.TOP);
        numhp:SetTextAlign("center", "center");
        numhp:SetText(ADD_THOUSANDS_SEPARATOR(stat.HP) .. "/" .. ADD_THOUSANDS_SEPARATOR(stat.maxHP));
        numhp:SetFontName("white_16_ol");
    end
end

function TARGETINFOTOBOSS_TARGET_SET_HOOKED(frame, msg, argStr, argNum)
	_G["TARGETINFOTOBOSS_TARGET_SET_OLD"](frame, msg, argStr, argNum);

	if argStr == "None" or argNum == nil then
		return;
	end

	local stat = info.GetStat(session.GetTargetHandle());

	if stat == nil then
		return;
	end

	local targetinfo = info.GetTargetInfo(argNum);
	if nil == targetinfo then
		return;
	end

	local numhp = frame:CreateOrGetControl("richtext", "numhp", -10, 18, 176, 115);
	tolua.cast(numhp, "ui::CRichText");
	numhp:SetGravity(ui.CENTER_HORZ, ui.TOP);
	numhp:SetTextAlign("center", "center");
	numhp:SetText(ADD_THOUSANDS_SEPARATOR(stat.HP) .. " / " .. ADD_THOUSANDS_SEPARATOR(stat.maxHP));
	numhp:SetFontName("white_16_ol");
	numhp:ShowWindow(1);

	local monactor = world.GetActor(session.GetTargetHandle());
	local montype = monactor:GetType();
	local monCls = GetClassByType("Monster", montype);

	if monCls == nil then
		return;
	end

	local xPosition = 0;
	local yPosition = 20;
	local propertyWidth = 35;

	SHOW_PROPERTY_WINDOW(frame, monCls, targetinfo.raceType, "RaceType", xPosition + (0 * propertyWidth), yPosition, 10, 10);
	SHOW_PROPERTY_WINDOW(frame, monCls, targetinfo.attribute, "Attribute", xPosition + (1 * propertyWidth), yPosition, 10, 10);
	SHOW_PROPERTY_WINDOW(frame, monCls, targetinfo.armorType, "ArmorMaterial", xPosition + (2 * propertyWidth), yPosition, 10, 10);
	SHOW_PROPERTY_WINDOW(frame, monCls, monCls["MoveType"], "MoveType", xPosition + (3 * propertyWidth), yPosition, 10, 10);
	SHOW_PROPERTY_WINDOW(frame, monCls, nil, "EffectiveAtkType", xPosition + (4 * propertyWidth), yPosition, 10, 10);

	local targetSizeText = frame:CreateOrGetControl("richtext", "targetSizeText", 0, 0, 100, 40);
	tolua.cast(targetSizeText, "ui::CRichText");
	if targetinfo.size ~= nil then
		targetSizeText:SetOffset(xPosition + (5 * propertyWidth) + 10, yPosition - 8);
		targetSizeText:SetText("{@st41}{s28}" .. targetinfo.size);
		targetSizeText:ShowWindow(1);
	else
		targetSizeText:ShowWindow(0);
	end
end

function TARGETINFOTOBOSS_ON_MSG_HOOKED(frame, msg, argStr, argNum)
	_G["TARGETINFOTOBOSS_ON_MSG_OLD"](frame, msg, argStr, argNum);

	if msg == "TARGET_UPDATE" then
		local stat = info.GetStat(session.GetTargetHandle());

		if stat == nil then
			return;
		end

		local numhp = frame:CreateOrGetControl("richtext", "numhp", -10, 18, 176, 115);
		tolua.cast(numhp, "ui::CRichText");
		numhp:SetGravity(ui.CENTER_HORZ, ui.TOP);
		numhp:SetTextAlign("center", "center");
		numhp:SetText(ADD_THOUSANDS_SEPARATOR(stat.HP) .. " / " .. ADD_THOUSANDS_SEPARATOR(stat.maxHP));
		numhp:SetFontName("white_16_ol");
		numhp:ShowWindow(1);
	end
end

SETUP_HOOK(TGTINFO_TARGET_SET_HOOKED, "TGTINFO_TARGET_SET");
SETUP_HOOK(TARGETINFO_ON_MSG_HOOKED, "TARGETINFO_ON_MSG");
SETUP_HOOK(TARGETINFOTOBOSS_TARGET_SET_HOOKED, "TARGETINFOTOBOSS_TARGET_SET");
SETUP_HOOK(TARGETINFOTOBOSS_ON_MSG_HOOKED, "TARGETINFOTOBOSS_ON_MSG");

ui.SysMsg("Monster Frames loaded!");
