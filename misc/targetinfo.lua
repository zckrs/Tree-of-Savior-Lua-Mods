function TARGET_INFO_SECURITY_RISK()

	SETUP_HOOK(TGTINFO_TARGET_SET_HOOKED, "TARGETINFO_ON_MSG");
	SETUP_HOOK(TARGETINFO_ON_MSG_HOOKED, "TGTINFO_TARGET_SET");
	
end

function TGTINFO_TARGET_SET_HOOKED(frame, msg, argStr, argNum)
	if argStr == "None" then
		return;
	end

	local stat = info.GetStat(session.GetTargetHandle());
	if stat == nil then
		return;
	end

	local targetinfo = info.GetTargetInfo( session.GetTargetHandle() );

	if nil == targetinfo then
		return
	end

	-- local ifp = info.GetIFP(session.GetTargetHandle());
	-- local mifp = info.GetMIFP(session.GetTargetHandle());
	-- ui.SysMsg(ifp .. " " .. mifp);

	-- local wiki = session.GetWikiByName(session.GetTargetHandle());

	-- dumpTable(session);

	local numhp = frame:CreateOrGetControl("richtext", "numhp", -17, 0, 176, 115);
	tolua.cast(numhp, "ui::CRichText");
	numhp:ShowWindow(1);
	numhp:SetGravity(ui.CENTER_HORZ, ui.TOP);
	numhp:SetTextAlign("center", "center");
	numhp:SetText(stat.HP .. "/" .. stat.maxHP);
	numhp:SetFontName("white_16_ol");

	frame:Resize(480, frame:GetHeight())
	frame:SetGravity(ui.CENTER_HORZ, ui.TOP);
	TARGET_INFO_OFFSET_X = 710
	frame:SetMargin(0,196,0,0);
	local nametext = GET_CHILD(frame, "name", "ui::CRichText");
	nametext:SetGravity(ui.CENTER_HORZ, ui.TOP);
	nametext:SetMargin(0, 80, 0, 0)

	if targetinfo.attribute ~= nil then
		local attribute = frame:CreateOrGetControl("picture", "attribute", 0, 0, 100, 40);
		tolua.cast(attribute, "ui::CPicture");
		attribute:ShowWindow(1);
		attribute:SetGravity(ui.LEFT, ui.TOP);
		attribute:SetImage('Attri_' .. targetinfo.attribute);
		attribute:SetMargin(350, 9, 0, 0);
		attribute:SetTextAlign("right", "center");
		attribute:SetText(targetinfo.attribute);
		attribute:SetFontName("white_16_ol");
	end

	if targetinfo.armorType ~= nil then
		local armorType = frame:CreateOrGetControl("picture", "armorType", 0, 0, 100, 40);
		tolua.cast(armorType, "ui::CPicture");
		armorType:ShowWindow(1);
		armorType:SetGravity(ui.LEFT, ui.TOP);
		armorType:SetImage('Armor_' .. targetinfo.armorType);
		armorType:SetMargin(350, 40, 0, 0);
		armorType:SetTextAlign("right", "center");
		armorType:SetText(targetinfo.armorType);
		armorType:SetFontName("white_16_ol");
	end

	if targetinfo.raceType ~= nil then
		local raceType = frame:CreateOrGetControl("picture", "raceType", 0, 0, 100, 40);
		tolua.cast(raceType, "ui::CPicture");
		raceType:ShowWindow(1);
		raceType:SetGravity(ui.LEFT, ui.TOP);
		raceType:SetMargin(350, 71, 0, 0);
		raceType:SetImage('Tribe_' .. targetinfo.raceType);
		-- dumpTable(raceType);
		raceType:SetTextAlign("right", "center");
		raceType:SetText(targetinfo.raceType);
		raceType:SetFontName("white_16_ol");

		-- local raceTypeText = frame:CreateOrGetControl("richtext", "raceTypeText", 40, 0, 176, 50);
		-- tolua.cast(raceTypeText, "ui::CRichText");
		-- raceTypeText:ShowWindow(1);
		-- raceTypeText:SetGravity(ui.CENTER_HORZ, ui.TOP);
		-- raceTypeText:SetTextAlign("center", "center");
		-- raceTypeText:SetText("");
		-- raceTypeText:SetFontName("white_16_ol");
	end

	if targetinfo.size ~= nil then
		local targetSizeText = frame:CreateOrGetControl("richtext", "targetSizeText", 0, 0, 60, 50);
		tolua.cast(targetSizeText, "ui::CRichText");
		targetSizeText:ShowWindow(1);
		targetSizeText:SetGravity(ui.CENTER_HORZ, ui.TOP);
		targetSizeText:SetMargin(90, 65, 0 , 0);
		targetSizeText:SetTextAlign("center", "center");
		targetSizeText:SetText('{@st43}'.. targetinfo.size .. '{@st53} ');
	end

	local oldf = _G["TGTINFO_TARGET_SET_OLD"];
    return oldf(frame, msg, str, exp, tableinfo)
end

function TARGETINFO_ON_MSG_HOOKED(frame, msg, argStr, argNum)
	if frame == nil then
		return
	end

	if msg == 'TARGET_UPDATE' then
		local stat = info.GetStat(session.GetTargetHandle());
		if stat == nil then
			return;
		end

		local targetinfo = info.GetTargetInfo( session.GetTargetHandle() );

		local numhp = frame:CreateOrGetControl("richtext", "numhp", -17, 0, 176, 115);
		tolua.cast(numhp, "ui::CRichText");
		numhp:ShowWindow(1);
		numhp:SetGravity(ui.CENTER_HORZ, ui.TOP);
		numhp:SetTextAlign("center", "center");
		numhp:SetText(stat.HP .. "/" .. stat.maxHP);
		numhp:SetFontName("white_16_ol");
	end
	local oldf = _G["TARGETINFO_ON_MSG_OLD"];
    return oldf(frame, msg, str, exp, tableinfo)
end

function dumpTable(table)
	file = io.open("test-script3.txt", "w")
	local status, err = pcall(function () file:write(DataDumper(getmetatable(table))); end);
    

    if err ~= nil then
    	ui.SysMsg(err);
     	file:write(err);
 	end
 	file:close()
end

TARGET_INFO_SECURITY_RISK()
