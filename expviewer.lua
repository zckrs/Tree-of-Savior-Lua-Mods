if _G["EXPERIENCE_VIEWER"] == nil then
	_G["EXPERIENCE_VIEWER"] = {};
end

--[[START EXPERIENCE DATA]]
local ExperienceData = {}
ExperienceData.__index = ExperienceData

setmetatable(ExperienceData, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function ExperienceData.new()
	local self = setmetatable({}, ExperienceData)

	self.firstUpdate = true;
	self.currentExperience = 0;
	self.requiredExperience = 0;
	self.previousCurrentExperience = 0;
	self.previousRequiredExperience = 0;
	self.currentPercent = 0;
	self.lastExperienceGain = 0;
	self.killsTilNextLevel = 0;
	self.experiencePerHour = 0;
	self.experienceGained = 0;
	self.timeTilLevel = 0;

	-- self.reset();

	return self
end

function ExperienceData:reset()
	self.firstUpdate = true;
	self.currentExperience = 0;
	self.requiredExperience = 0;
	self.previousCurrentExperience = 0;
	self.previousRequiredExperience = 0;
	self.currentPercent = 0;
	self.lastExperienceGain = 0;
	self.killsTilNextLevel = 0;
	self.experiencePerHour = 0;
	self.experienceGained = 0;
	self.timeTilLevel = 0;
end
--[[END EXPERIENCE DATA]]

if _G["EXPERIENCE_VIEWER"]["baseExperienceData"] == nil then
	_G["EXPERIENCE_VIEWER"]["baseExperienceData"] = ExperienceData();
end

if _G["EXPERIENCE_VIEWER"]["classExperienceData"] == nil then
	_G["EXPERIENCE_VIEWER"]["classExperienceData"] = ExperienceData();
end

-- local firstSilverUpdate = true;
-- local currentSilver = 0;
-- local previousSilver = 0;
-- local lastSilverGain = 0;
-- local silverGained = 0;
-- local silverPerHour = 0;

if _G["EXPERIENCE_VIEWER"]["startTime"] == nil then
	_G["EXPERIENCE_VIEWER"]["startTime"] = os.clock();
end

if _G["EXPERIENCE_VIEWER"]["elapsedTime"] == nil then
	_G["EXPERIENCE_VIEWER"]["elapsedTime"] = os.difftime(os.clock(), _G["EXPERIENCE_VIEWER"]["startTime"]);
end

if _G["EXPERIENCE_VIEWER"]["SECONDS_IN_HOUR"] == nil then
	_G["EXPERIENCE_VIEWER"]["SECONDS_IN_HOUR"] = 3600;
end

function CHARBASEINFO_ON_MSG_HOOKED(frame, msg, argStr, argNum)
	_G["EXPERIENCE_VIEWER"]["elapsedTime"] = os.difftime(os.clock(), _G["EXPERIENCE_VIEWER"]["startTime"]);

	--SET BASE CURRENT/REQUIRED EXPERIENCE
	_G["EXPERIENCE_VIEWER"]["baseExperienceData"].previousRequiredExperience = _G["EXPERIENCE_VIEWER"]["baseExperienceData"].requiredExperience;
	_G["EXPERIENCE_VIEWER"]["baseExperienceData"].currentExperience = session.GetEXP();
	_G["EXPERIENCE_VIEWER"]["baseExperienceData"].requiredExperience = session.GetMaxEXP();

	--CALCULATE EXPERIENCE
	CALCULATE_EXPERIENCE_DATA(_G["EXPERIENCE_VIEWER"]["baseExperienceData"], _G["EXPERIENCE_VIEWER"]["elapsedTime"]);

	UPDATE_UI("baseExperience", _G["EXPERIENCE_VIEWER"]["baseExperienceData"]);

	local oldf = _G["CHARBASEINFO_ON_MSG_OLD"];
	return oldf(frame, msg, str, exp, tableinfo);
end

function ON_JOB_EXP_UPDATE_HOOKED(frame, msg, str, exp, tableinfo)
	_G["EXPERIENCE_VIEWER"]["elapsedTime"] = os.difftime(os.clock(), _G["EXPERIENCE_VIEWER"]["startTime"]);

	--CALCULATE EXPERIENCE
	local currentTotalClassExperience = exp;
	local currentClassLevel = tableinfo.level;

	--SET BASE CURRENT/REQUIRED EXPERIENCE
	_G["EXPERIENCE_VIEWER"]["classExperienceData"].previousRequiredExperience = _G["EXPERIENCE_VIEWER"]["classExperienceData"].requiredExperience;

	--SET CLASS CURRENT/REQUIRED EXPERIENCE
	_G["EXPERIENCE_VIEWER"]["classExperienceData"].currentExperience = exp - tableinfo.startExp;
	_G["EXPERIENCE_VIEWER"]["classExperienceData"].requiredExperience = tableinfo.endExp - tableinfo.startExp;

	--CALCULATE EXPERIENCE
	CALCULATE_EXPERIENCE_DATA(_G["EXPERIENCE_VIEWER"]["classExperienceData"], _G["EXPERIENCE_VIEWER"]["elapsedTime"]);

	UPDATE_UI("classExperience", _G["EXPERIENCE_VIEWER"]["classExperienceData"]);

	local oldf = _G["ON_JOB_EXP_UPDATE_OLD"];
	return oldf(frame, msg, str, exp, tableinfo);
end

function CALCULATE_EXPERIENCE_DATA(experienceData, elapsedTime)
	if experienceData.firstUpdate == true then
		experienceData.previousCurrentExperience = experienceData.currentExperience;
		experienceData.firstUpdate = false;
		return;
	end

	--[[PERFORM CALCULATIONS]]
	--if we leveled up...
	if experienceData.requiredExperience > experienceData.previousRequiredExperience then
		experienceData.lastExperienceGain = (experienceData.previousRequiredExperience - experienceData.previousCurrentExperience) + experienceData.currentExperience;
	else
		experienceData.lastExperienceGain = experienceData.currentExperience - experienceData.previousCurrentExperience;
	end

	experienceData.experienceGained = experienceData.experienceGained + experienceData.lastExperienceGain;
	experienceData.currentPercent = experienceData.currentExperience / experienceData.requiredExperience * 100;

	if experienceData.lastExperienceGain == 0 then
		experienceData.killsTilNextLevel = "INF";
	else
		experienceData.killsTilNextLevel = math.ceil((experienceData.requiredExperience - experienceData.currentExperience) / experienceData.lastExperienceGain);
	end

	experienceData.experiencePerHour = (experienceData.experienceGained * (_G["EXPERIENCE_VIEWER"]["SECONDS_IN_HOUR"] / _G["EXPERIENCE_VIEWER"]["elapsedTime"]));

	local experienceRemaining = experienceData.requiredExperience - experienceData.currentExperience;
	local experiencePerSecond = experienceData.experienceGained / _G["EXPERIENCE_VIEWER"]["elapsedTime"];

	experienceData.timeTilLevel = os.date("!%X", experienceRemaining / experiencePerSecond);

	--[[END OF UPDATES, SET PREVIOUS]]
	experienceData.previousCurrentExperience = experienceData.currentExperience;
end

function UPDATE_UI(experienceTextName, experienceData)
	if ui ~= nil then
		local expFrame = ui.GetFrame("expviewer");

		if expFrame ~= nil then
			local columnHeadersRichText = expFrame:GetChild("columnHeaders");
			if columnHeadersRichText ~= nil then
				columnHeadersRichText:SetText("{@sti7}{s16} Current | Required | % | Gained | TNL | Exp/Hr | Time TNL");
			end

			--SET EXPERIENCE TEXT
			local experienceRichText = expFrame:GetChild(experienceTextName);
			if experienceRichText ~= nil then
				SET_EXPERIENCE_TEXT(experienceRichText, experienceData);
			end

			expFrame:Resize(experienceRichText:GetWidth() + 75, 108);

			UPDATE_BUTTONS(expFrame);
		end
	end
end

function SET_EXPERIENCE_TEXT(experienceText, experienceData)
	experienceText:SetText(
		'{@sti7}{s16}' ..
		ADD_THOUSANDS_SEPARATOR(experienceData.currentExperience) .." / " .. ADD_THOUSANDS_SEPARATOR(experienceData.requiredExperience) .. "   " ..
		string.format("%.2f", experienceData.currentPercent) .. "%    " ..
		ADD_THOUSANDS_SEPARATOR(experienceData.lastExperienceGain) .. "    " ..
		ADD_THOUSANDS_SEPARATOR(experienceData.killsTilNextLevel) .. "    " ..
		ADD_THOUSANDS_SEPARATOR(string.format("%i", experienceData.experiencePerHour)) .. "    " ..
		experienceData.timeTilLevel
	);
end

function UPDATE_BUTTONS(expFrame)
	--MOVE RESET BUTTON TO TOPRIGHT CORNER
	local resetButton = expFrame:GetChild("resetButton");
	if resetButton ~= nil then
		resetButton:Move(0, 0);
		resetButton:SetOffset(expFrame:GetWidth() - 35, 5);
		resetButton:SetText("{@sti7}{s16}R");
		resetButton:Resize(30, 30);
	end

	--MOVE INIT BUTTON TO TOPRIGHT CORNER
	local startButton = expFrame:GetChild("startButton");
	if startButton ~= nil then
		startButton:Move(0, 0);
		startButton:SetOffset(5, 5);
		startButton:SetText("{@sti7}{s16}S");
		startButton:Resize(30, 30);
		startButton:ShowWindow(0);
	end
end

function PRINT_EXPERIENCE_DATA(experienceData)
	ui.SysMsg(experienceData.currentExperience .. " / " .. experienceData.requiredExperience .. "   " .. experienceData.lastExperienceGain .. " gained   " .. experienceData.currentPercent .. "%" .. "   " .. experienceData.killsTilNextLevel .. " tnl   " .. experienceData.experiencePerHour .. " exp/hr");
end

function RESET()
	ui.SysMsg("resetting experience session!");

	_G["EXPERIENCE_VIEWER"]["startTime"] = os.clock();
	_G["EXPERIENCE_VIEWER"]["elapsedTime"] = 0;

	firstSilverUpdate = true;
	currentSilver = 0;
	previousSilver = 0;
	lastSilverGain = 0;
	silverGained = 0;
	silverPerHour = 0;

	_G["EXPERIENCE_VIEWER"]["baseExperienceData"]:reset();
	_G["EXPERIENCE_VIEWER"]["classExperienceData"]:reset();
end

function ADD_THOUSANDS_SEPARATOR(amount)
	local formatted = amount

	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k == 0) then
			break
		end
	end

	return formatted
end

function LEFT_PAD(str, len, char)
	if char == nil then
		char = ' '
	end

	return string.rep(char, len - #str) .. str
end

function RIGHT_PAD(str, len, char)
	if char == nil then
		char = ' '
	end

	return str .. string.rep(char, len - #str)
end

--LOAD HOOKS - this must go at the end of the script so that the methods are defined
local characterExperienceUpdateHook = "CHARBASEINFO_ON_MSG";

if _G["CHARBASEINFO_ON_MSG_OLD"] == nil then
	_G["CHARBASEINFO_ON_MSG_OLD"] = _G[characterExperienceUpdateHook];
	_G[characterExperienceUpdateHook] = CHARBASEINFO_ON_MSG_HOOKED;
else
	_G[characterExperienceUpdateHook] = CHARBASEINFO_ON_MSG_HOOKED;
end

local jobExperienceUpdateHook = "ON_JOB_EXP_UPDATE";

if _G["ON_JOB_EXP_UPDATE_OLD"] == nil then
	_G["ON_JOB_EXP_UPDATE_OLD"] = _G[jobExperienceUpdateHook];
	_G[jobExperienceUpdateHook] = ON_JOB_EXP_UPDATE_HOOKED;
else
	_G[jobExperienceUpdateHook] = ON_JOB_EXP_UPDATE_HOOKED;
end

--ON_JOB_EXP_UPDATE
--DRAW_TOTAL_VIS

--CALCULATE SILVER
--[[
if firstSilverUpdate == true then
	previousSilver = GET_TOTAL_MONEY();
	currentSilver = previousSilver;
	firstSilverUpdate = false;
else
	previousSilver = currentSilver;
	currentSilver = GET_TOTAL_MONEY();

	lastSilverGain = currentSilver - previousSilver;
	silverGained = silverGained + lastSilverGain;
	silverPerHour = (silverGained * (SECONDS_IN_HOUR / _G["EXPERIENCE_VIEWER"]["elapsedTime"]));

	--ui.SysMsg("Silver/Hour: " .. silverPerHour .. "    Gained: " .. silverGained .. "    LastGain: " .. lastSilverGain);
end
--]]

ui.SysMsg("Excrulon's expviewer loaded!");
