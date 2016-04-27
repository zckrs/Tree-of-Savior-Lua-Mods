local filterEnabled = true;

function INIT(addon, frame)
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

	_G['OLD_POSSIBLE_UI_OPEN_CHECK'] = _G['SCR_POSSIBLE_UI_OPEN_CHECK'];
	_G['SCR_POSSIBLE_UI_OPEN_CHECK'] = BETTERQUEST_POSSIBLE_UI_OPEN_CHECK;
	_G['OLD_UPDATE_ALLQUEST'] = _G['UPDATE_ALLQUEST'];
	_G['UPDATE_ALLQUEST'] = BETTERQUEST_UPDATE_ALLQUEST;
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

			if string.sub(questIES.Name, 1, 1) ~= "[" then
				questIES.Name = "[" .. questIES.Level .. "] " .. questIES.Name;
			end

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

	frame:Invalidate();
end


INIT();
ui.SysMsg("BetterQuest loaded!");

function questSort(a, b)
	return a.Level < b.Level
end
