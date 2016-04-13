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

    local eSpaceV = 0;
    local eSpaceH = 0;
    if targetinfo.isElite == 1 then
        if eSpaceV == 0 then
            eSpaceV = 5;
            eSpaceH = 20;
        end
    else
        if eSpaceV == 5 then
            eSpaceV = 0;
            eSpaceH = 0;
        end
    end

    -- hp
    local numhp = frame:CreateOrGetControl("richtext", "numhp", (-17 + eSpaceH), (0 - eSpaceV), 176, 115);
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
        attribute:SetOffset((100 + eSpaceH), (9 - eSpaceV));
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
        armorType:SetOffset((135 + eSpaceH), (9 - eSpaceV));
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
        raceType:SetOffset((170 + eSpaceH), (9 - eSpaceV));
    else
        raceType:ShowWindow(0);
    end


    --[[            Text might be easier to understand than the official icon...
    -- size
    local targetSizeText = frame:CreateOrGetControl("richtext", "targetSizeText", 0, 0, 100, 40);
    tolua.cast(targetSizeText, "ui::CRichText");
    if targetinfo.size ~= nil then
        targetSizeText:ShowWindow(1);
        targetSize:SetOffset((205 + eSpaceH), (9 - eSpaceV));
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
        targetSize:SetOffset((205 + eSpaceH), (9 - eSpaceV));
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
        moveType:SetOffset((240 + eSpaceH), (9 - eSpaceV));
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

        local eSpaceV = 0;
        local eSpaceH = 0;
        if targetinfo.isElite == 1 then
            if eSpaceV == 0 then
                eSpaceV = 5;
                eSpaceH = 20;
            end
        else
            if eSpaceV == 5 then
                eSpaceV = 0;
                eSpaceH = 0;
            end
        end

        local numhp = frame:CreateOrGetControl("richtext", "numhp", (-17 + eSpaceH), (0 - eSpaceV), 176, 115);
        tolua.cast(numhp, "ui::CRichText");
        numhp:ShowWindow(1);
        numhp:SetGravity(ui.CENTER_HORZ, ui.TOP);
        numhp:SetTextAlign("center", "center");
        numhp:SetText(ADD_THOUSANDS_SEPARATOR(stat.HP) .. "/" .. ADD_THOUSANDS_SEPARATOR(stat.maxHP));
        numhp:SetFontName("white_16_ol");
    end
end

--[[
This was taken from addon.ipf/mobinfobyskill/mobinfobyskill.lua
--]]
function GET_MON_PROPICON_BY_PROPNAME(paramname, monclass)

    if paramname == "RaceType" then

        local paramvalue = monclass[paramname];

        if paramvalue == "Forester" then
            return 'mon_info_forester';
        elseif paramvalue == "Widling" then
            return 'mon_info_widling';
        elseif paramvalue == "Paramune" then
            return 'mon_info_paramune';
        elseif paramvalue == "Klaida" then
            return 'mon_info_klaida';
        elseif paramvalue == "Velnias" then
            return 'mon_info_velnias';
        end

    elseif paramname == "Size" then

        local paramvalue = monclass[paramname];

        if paramvalue == "S" then
            return 'mon_info_s';
        elseif paramvalue == "M" then
            return 'mon_info_m';
        elseif paramvalue == "L" then
            return 'mon_info_l';
        elseif paramvalue == "XL" then
            return 'mon_info_xl';
        end

    elseif paramname == "MonRank" then

        local paramvalue = monclass[paramname];

        if paramvalue == "Normal" then
            return 'mon_info_mon';
        elseif paramvalue == "Elite" then
            return 'mon_info_elite';
        elseif paramvalue == "Boss" then
            return 'mon_info_boss';
        end

    elseif paramname == "ArmorMaterial" then

        local paramvalue = monclass[paramname];

        if paramvalue == "Cloth" then
            return 'mon_info_cloth';
        elseif paramvalue == "Leather" then
            return 'mon_info_leather';
        elseif paramvalue == "Iron" then
            return 'mon_info_iron';
        elseif paramvalue == "Ghost" then
            return 'mon_info_ghost';
        elseif paramvalue == "None" then
            return 'mon_info_none';
        end

    elseif paramname == "Attribute" then

        local paramvalue = monclass[paramname];

        if paramvalue == "Fire" then
            return 'mon_info_fire';
        elseif paramvalue == "Ice" then
            return 'mon_info_ice';
        elseif paramvalue == "Lightning" then
            return 'mon_info_lightning';
        elseif paramvalue == "Poison" then
            return 'mon_info_poison';
        elseif paramvalue == "Dark" then
            return 'mon_info_dark';
        elseif paramvalue == "Holy" then
            return 'mon_info_holy';
        elseif paramvalue == "Earth" then
            return 'mon_info_earth';
        elseif paramvalue == "Melee" then
            return 'mon_info_none';
        end

    elseif paramname == "MoveType" then

        local paramvalue = monclass[paramname];

        if paramvalue == "Holding" then
            return 'mon_info_holding';
        elseif paramvalue == "Normal" then
            return 'mon_info_normal';
        elseif paramvalue == "Flying" then
            return 'mon_info_flying';
        end

    end

    print('error : ['..paramname..'] ['..paramvalue..']');

    return '';
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
