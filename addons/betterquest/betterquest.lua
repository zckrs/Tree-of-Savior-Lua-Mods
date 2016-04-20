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
	_G['SCR_POSSIBLE_UI_OPEN_CHECK'] = BETTERQUEST_POSSIBLE_UI_OPEN_CHECK;
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

BETTERQUEST_ON_INIT();

function QUEST_ON_INIT_HOOKED(addon, frame)
    _G["QUEST_ON_INIT_OLD"](addon, frame);
    BETTERQUEST_ON_INIT();
end

local questOnInitHook = "QUEST_ON_INIT";

if _G["QUEST_ON_INIT_OLD"] == nil then
    _G["QUEST_ON_INIT_OLD"] = _G[questOnInitHook];
    _G[questOnInitHook] = QUEST_ON_INIT_HOOKED;
else
    _G[questOnInitHook] = QUEST_ON_INIT_HOOKED;
end

ui.SysMsg("Better Quest loaded!");
