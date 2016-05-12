local filterEnabled = true;

function BETTERQUEST_CREATE_FILTER_CHECKBOX()
	local frame = ui.GetFrame('quest');
	local ctrl = frame:CreateOrGetControl('checkbox', 'BETTERQUEST_FILTER', 0, 0, 150, 30);
	tolua.cast(ctrl, 'ui::CCheckBox');
	ctrl:SetMargin(30, 60, 0, 70);
	ctrl:SetGravity(ui.LEFT, ui.TOP);
	ctrl:SetText('{@st42b}Show All Eligible Quests{/}');
	ctrl:SetClickSound('button_click_big');
	ctrl:SetOverSound('button_over');
	ctrl:SetEventScript(ui.LBUTTONUP, 'BETTERQUEST_TOGGLE_FILTER');
	ctrl:SetCheck(filterEnabled == true and 0 or 1);
end

function BETTERQUEST_ON_INIT()
	BETTERQUEST_CREATE_FILTER_CHECKBOX();
	SETUP_HOOK(BETTERQUEST_POSSIBLE_UI_OPEN_CHECK, "SCR_POSSIBLE_UI_OPEN_CHECK");
	SETUP_HOOK(BETTERQUEST_UPDATE_ALLQUEST, "UPDATE_ALLQUEST");
end

local refreshQuestFrame = function()
	local topFrame = ui.GetFrame('quest');
	local questbox = GET_CHILD(topFrame, 'questbox', 'ui::CTabControl');
	local currentTabIndex = questbox:GetSelectItemIndex();
	if currentTabIndex == 0 then
		UPDATE_ALLQUEST(topFrame);
	elseif currentTabIndex == 1 then
		UPDATE_ALLQUEST_ABANDONLIST(topFrame);
	end
end

local refreshQuestInfoFrame = function()
	local frame = ui.GetFrame('questinfo');
	UPDATE_QUESTMARK(frame, '', '', 0);
end

local refreshQuestInfoSet2Frame = function()
	local frame = ui.GetFrame('questinfoset_2');
	UPDATE_QUESTINFOSET_2(frame);
end

function BETTERQUEST_TOGGLE_FILTER(frame, ctrl)
	filterEnabled = ctrl:IsChecked() ~= 1;
	refreshQuestFrame();
	refreshQuestInfoFrame();
	refreshQuestInfoSet2Frame();
end

function BETTERQUEST_POSSIBLE_UI_OPEN_CHECK(pc, questIES)
	if filterEnabled == false then
		return 'OPEN';
	end

	if questIES.PossibleUI_Notify == 'NO' then
		return 'HIDE';
	end

	if questIES.QuestMode ~= 'MAIN' and questIES.Check_QuestCount > 0 then
		local sObj = GetSessionObject(pc, 'ssn_klapeda');
		local result1 = SCR_QUEST_CHECK_MODULE_QUEST(pc, questIES, sObj);
		if result1 == 'YES' then
			return 'OPEN';
		end
	elseif questIES.QuestMode == 'MAIN' or questIES.PossibleUI_Notify == 'UNCOND' then
		return 'OPEN';
	end

	return 'HIDE';
end

function BETTERQUEST_UPDATE_ALLQUEST(frame, msg, isNew, questID, isNewQuest)
	local pc = GetMyPCObject();
	local mylevel = info.GetLevel(session.GetMyHandle());
	local posY = 60;

	local sobjIES = GET_MAIN_SOBJ();
	local questGbox = frame:GetChild('questGbox');

	local newCtrlAdded = false;
	if questID ~= nil and questID > 0 then
		local questIES = GetClassByType("QuestProgressCheck", questID);
		local result = SCR_QUEST_CHECK_C(pc, questIES.ClassName);
		local ctrlName = "_Q_" .. questIES.ClassID;


		-- ???? ????? ?????????? ???? ?????????? ui???? ???? ????.
		if isNewQuest == 0 and isNew == 1 then
			questGbox:RemoveChild(ctrlName);
		elseif QUEST_ABANDON_RESTARTLIST_CHECK(questIES, sobjIES) == 'NOTABANDON' then
			local newY = SET_QUEST_LIST_SET(frame, questGbox, posY, ctrlName, questIES, result, isNew, questID);
			if newY ~= posY then
				newCtrlAdded = true;
			end
			posY = newY;
		end

	else
		-- Update All
		local clsList, cnt = GetClassList("QuestProgressCheck");

		--Sort Init
		local quests = {}
		for i = 0, cnt -1 do
			quests[i] = GetClassByIndexFromList(clsList, i);
		end
		table.sort(quests,questSort);
		--Sort End

		for i = 0, cnt -1 do
			--local questIES = GetClassByIndexFromList(clsList, i);
			local questIES = quests[i]; --
			local questAutoIES = GetClass('QuestProgressCheck_Auto',questIES.ClassName)

			if questIES.ClassName ~= "None" then
				local ctrlName = "_Q_" .. questIES.ClassID;
				local abandonCheck = QUEST_ABANDON_RESTARTLIST_CHECK(questIES, sobjIES)
				if abandonCheck == 'NOTABANDON' or abandonCheck == 'ABANDON/NOTLIST' then

					local result = SCR_QUEST_CHECK_C(pc, questIES.ClassName);
					if IS_ABOUT_JOB(questIES) == true then
						if result ~= 'IMPOSSIBLE' and result ~= 'None' then
							posY = SET_QUEST_LIST_SET(frame, questGbox, posY, ctrlName, questIES, result, isNew, questID);
						end
					else
						posY = SET_QUEST_LIST_SET(frame, questGbox, posY, ctrlName, questIES, result, isNew, questID);
					end
				else
					questGbox:RemoveChild(ctrlName);
				end
			end
		end
	end

	ALIGN_QUEST_CTRLS(questGbox);
	if isNewQuest == nil then
		UPDATE_QUEST_DETAIL(frame, questID);
	elseif questID ~= nil and isNewQuest > 0 then
		local questIES = GetClassByType("QuestProgressCheck", questID);
		if newCtrlAdded == true then
			UPDATE_QUEST_DETAIL(frame, questID);
		end
	end
	updateQuestName()
	frame:Invalidate();
end

function updateQuestName()

	local frame = ui.GetFrame('quest');
	local questGbox = frame:GetChild('questGbox');

	local clsList, cnt = GetClassList("QuestProgressCheck");
	for i = 0, cnt -1 do

		local questIES = GetClassByIndexFromList(clsList, i);
		local ctrlName = "_Q_" .. questIES.ClassID;

		local Quest_Ctrl = GET_CHILD(questGbox, ctrlName, "ui::CControlSet");
		if Quest_Ctrl ~= nil then
			local nametxt = GET_CHILD(Quest_Ctrl, "name", "ui::CRichText");

			if questIES.QuestMode == 'REPEAT' then
				local pc = GetMyPCObject();
				local sObj = GetSessionObject(pc, 'ssn_klapeda')
				if sObj ~= nil then
					if questIES.Repeat_Count ~= 0 then
						questname = "[" .. questIES.Level .. "] " .. questIES.Name..ScpArgMsg("Auto__-_BanBog({Auto_1}/{Auto_2})","Auto_1", sObj[questIES.QuestPropertyName..'_R'] + 1, "Auto_2",questIES.Repeat_Count)
					else
						questname = "[" .. questIES.Level .. "] " .. questIES.Name..ScpArgMsg("Auto__-_BanBog({Auto_1}/MuHan)","Auto_1", sObj[questIES.QuestPropertyName..'_R'])
					end
			end
			elseif questIES.QuestMode == 'PARTY' then
				local pc = GetMyPCObject();
					local sObj = GetSessionObject(pc, 'ssn_klapeda')
				if sObj ~= nil then
					questname = "[" .. questIES.Level .. "] " .. questIES.Name..ScpArgMsg("Auto__-_BanBog({Auto_1}/{Auto_2})","Auto_1", sObj.PARTY_Q_COUNT1 + 1, "Auto_2",CON_PARTYQUEST_DAYMAX1)
				end
			end
			questname = "[" .. questIES.Level .. "] " .. questIES.Name;

			if questIES.QuestMode == 'MAIN' then
				nametxt:SetText(QUEST_TITLE_FONT..'{#FF6600}'..questname)
			else
				nametxt:SetText(QUEST_TITLE_FONT..questname)
			end
			nametxt:SetText(questname);
		end
	end
end

function questSort(a, b)
	return a.Level < b.Level
end

function QUEST_ON_INIT_HOOKED(addon, frame)
	_G["QUEST_ON_INIT_OLD"](addon, frame);
	BETTERQUEST_CREATE_FILTER_CHECKBOX();
end

SETUP_HOOK(QUEST_ON_INIT_HOOKED, "QUEST_ON_INIT");

BETTERQUEST_ON_INIT();

ui.SysMsg("Better Quest loaded!");
