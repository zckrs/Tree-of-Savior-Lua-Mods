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

    local eliteSpacerVertical = 0;
    local eliteSpacerHorizontal = 0;
    if targetinfo.isElite == 1 then
        if eliteSpacerVertical == 0 then
            eliteSpacerVertical = 5;
            eliteSpacerHorizontal = 20;
        end
    else
        if eliteSpacerVertical == 5 then
            eliteSpacerVertical = 0;
            eliteSpacerHorizontal = 0;
        end
    end

    -- hp
    local numhp = frame:CreateOrGetControl("richtext", "numhp", (-17 + eliteSpacerHorizontal), (0 - eliteSpacerVertical), 176, 115);
    tolua.cast(numhp, "ui::CRichText");
    numhp:ShowWindow(1);
    numhp:SetGravity(ui.CENTER_HORZ, ui.TOP);
    numhp:SetTextAlign("center", "center");
    numhp:SetText(ADD_THOUSANDS_SEPARATOR(stat.HP) .. "/" .. ADD_THOUSANDS_SEPARATOR(stat.maxHP));
    numhp:SetFontName("white_16_ol");


    -- attribute
    local attribute = frame:CreateOrGetControl("picture", "attribute", 0, 0, 100, 40);
    tolua.cast(attribute, "ui::CPicture");
    if targetinfo.attribute ~= nil and targetinfo.attribute ~= "Melee" then
        attribute:ShowWindow(1);
        attribute:SetGravity(ui.LEFT, ui.TOP);
        attribute:SetImage(GET_MON_PROPICON_BY_PROPNAME("Attribute", monCls));
        attribute:SetOffset((100 + eliteSpacerHorizontal), (9 - eliteSpacerVertical));
    else
        attribute:ShowWindow(0);
    end


    -- armor
    local armorType = frame:CreateOrGetControl("picture", "armorType", 0, 0, 100, 40);
    tolua.cast(armorType, "ui::CPicture");
    if targetinfo.armorType ~= nil and targetinfo.armorType ~= "None" then
        armorType:ShowWindow(1);
        armorType:SetGravity(ui.LEFT, ui.TOP);
        armorType:SetImage(GET_MON_PROPICON_BY_PROPNAME("ArmorMaterial", monCls));
        armorType:SetOffset((135 + eliteSpacerHorizontal), (9 - eliteSpacerVertical));
    else
        armorType:ShowWindow(0);
    end


    -- race
    local raceType = frame:CreateOrGetControl("picture", "raceType", 0, 0, 100, 40);
    tolua.cast(raceType, "ui::CPicture");
    if targetinfo.raceType ~= nil and targetinfo.raceType ~= "Item" then
        raceType:ShowWindow(1);
        raceType:SetGravity(ui.LEFT, ui.TOP);
        raceType:SetImage(GET_MON_PROPICON_BY_PROPNAME("RaceType", monCls));
        raceType:SetOffset((170 + eliteSpacerHorizontal), (9 - eliteSpacerVertical));
    else
        raceType:ShowWindow(0);
    end


    --[[            Text might be easier to understand than the official icon...
    -- size
    local targetSizeText = frame:CreateOrGetControl("richtext", "targetSizeText", 0, 0, 100, 40);
    tolua.cast(targetSizeText, "ui::CRichText");
    if targetinfo.size ~= nil then
        targetSizeText:ShowWindow(1);
        targetSize:SetOffset((205 + eliteSpacerHorizontal), (9 - eliteSpacerVertical));
        targetSizeText:SetText("{@st41}{s36}" .. targetinfo.size);
    else
        targetSizeText:ShowWindow(0);
    end
    --]]


    -- size
    local targetSize = frame:CreateOrGetControl("picture", "targetSize", 0, 0, 100, 40);
    tolua.cast(targetSize, "ui::CPicture");
    if targetinfo.size ~= nil then
        targetSize:ShowWindow(1);
        targetSize:SetGravity(ui.LEFT, ui.TOP);
        targetSize:SetImage(GET_MON_PROPICON_BY_PROPNAME("Size", monCls));
        targetSize:SetOffset((205 + eliteSpacerHorizontal), (9 - eliteSpacerVertical));
    else
        targetSize:ShowWindow(0);
    end


    -- move type
    local moveType = frame:CreateOrGetControl("picture", "moveType", 0, 0, 100, 40);
    tolua.cast(moveType, "ui::CPicture");
    if monCls["MoveType"] ~= nil then
        moveType:ShowWindow(1);
        moveType:SetGravity(ui.LEFT, ui.TOP);
        moveType:SetImage(GET_MON_PROPICON_BY_PROPNAME("MoveType", monCls));
        moveType:SetOffset((240 + eliteSpacerHorizontal), (9 - eliteSpacerVertical));
    else
        moveType:ShowWindow(0);
    end


    --exp
    --[[ not working correctly yet
    -- elite mobs seem to show normal mob xp...
    -- not sure why, classname reports properly with _Elite
    ui.SysMsg(monCls.ClassName);
    local wiki = GetWikiByName(monCls.ClassName);

    if wiki ~= nil then
        local expProp = GetWikiIntProp(wiki, "Exp");
        local jobExpProp = GetWikiIntProp(wiki, "JobExp");

        if expProp ~= 0 and jobExpProp ~= 0 then
            local experienceText = frame:CreateOrGetControl("richtext", "experienceText", 0, 0, 100, 40);
            tolua.cast(experienceText, "ui::CRichText");
            experienceText:SetGravity(ui.LEFT, ui.TOP);
            experienceText:SetTextAlign("left", "top");
            experienceText:SetOffset(260, 15);
            experienceText:SetText("{@st42}" .. expProp .. " / " .. jobExpProp .. " exp");
        end
    end
    --]]

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

        local targetinfo = info.GetTargetInfo(session.GetTargetHandle());

        local eliteSpacerVertical = 0;
        local eliteSpacerHorizontal = 0;
        if targetinfo.isElite == 1 then
            if eliteSpacerVertical == 0 then
                eliteSpacerVertical = 5;
                eliteSpacerHorizontal = 20;
            end
        else
            if eliteSpacerVertical == 5 then
                eliteSpacerVertical = 0;
                eliteSpacerHorizontal = 0;
            end
        end

        local numhp = frame:CreateOrGetControl("richtext", "numhp", (-17 + eliteSpacerHorizontal), (0 - eliteSpacerVertical), 176, 115);
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
