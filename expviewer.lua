_G["EXPERIENCE_VIEWER"] = _G["EXPERIENCE_VIEWER"] or {};
_G["EXPERIENCE_VIEWER"]["baseExperienceData"] = _G["EXPERIENCE_VIEWER"]["baseExperienceData"] or ExperienceData();
_G["EXPERIENCE_VIEWER"]["classExperienceData"] = _G["EXPERIENCE_VIEWER"]["classExperienceData"] or ExperienceData();
_G["EXPERIENCE_VIEWER"]["startTime"] = _G["EXPERIENCE_VIEWER"]["startTime"] or os.clock();
_G["EXPERIENCE_VIEWER"]["elapsedTime"] = _G["EXPERIENCE_VIEWER"]["elapsedTime"] or os.difftime(os.clock(), _G["EXPERIENCE_VIEWER"]["startTime"]);
_G["EXPERIENCE_VIEWER"]["SECONDS_IN_HOUR"] = _G["EXPERIENCE_VIEWER"]["SECONDS_IN_HOUR"] or 3600;
_G["EXPERIENCE_VIEWER"]["headerTablePositions"] = _G["EXPERIENCE_VIEWER"]["headerTablePositions"] or { 0, 0, 0, 0, 0, 0 };
_G["EXPERIENCE_VIEWER"]["baseTablePositions"] = _G["EXPERIENCE_VIEWER"]["baseTablePositions"] or { 0, 0, 0, 0, 0, 0 };
_G["EXPERIENCE_VIEWER"]["classTablePositions"] = _G["EXPERIENCE_VIEWER"]["classTablePositions"] or { 0, 0, 0, 0, 0, 0 };
_G["EXPERIENCE_VIEWER"]["frameWidths"] = _G["EXPERIENCE_VIEWER"]["frameWidths"] or { 0, 0, 0, 0, 0, 0 };
_G["EXPERIENCE_VIEWER"]["padding"] = _G["EXPERIENCE_VIEWER"]["padding"] or 5;

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


-- local firstSilverUpdate = true;
-- local currentSilver = 0;
-- local previousSilver = 0;
-- local lastSilverGain = 0;
-- local silverGained = 0;
-- local silverPerHour = 0;

function UPDATE_WINDOW_POSITION()
	local expFrame = ui.GetFrame("expviewer");

	if expFrame ~= nil then
		_G["EXPERIENCE_VIEWER"]["POSITION_X"] = expFrame:GetX();
		_G["EXPERIENCE_VIEWER"]["POSITION_Y"] = expFrame:GetY();
	end
end

function SET_WINDOW_POSITION()
	local expFrame = ui.GetFrame("expviewer");

	if expFrame ~= nil then
		expFrame:Move(0, 0);
		expFrame:SetOffset(_G["EXPERIENCE_VIEWER"]["POSITION_X"], _G["EXPERIENCE_VIEWER"]["POSITION_Y"]);
	end
end

function INIT()
	UPDATE_WINDOW_POSITION();
	UPDATE_UI("baseExperience", _G["EXPERIENCE_VIEWER"]["baseExperienceData"]);
	UPDATE_UI("classExperience", _G["EXPERIENCE_VIEWER"]["classExperienceData"]);
end

function HEADSUPDISPLAY_ON_MSG_HOOKED(frame, msg, argStr, argNum)
	SET_WINDOW_POSITION();
	INIT();

	local oldf = _G["HEADSUPDISPLAY_ON_MSG_OLD"];
	return oldf(frame, msg, argStr, argNum);
end

function CHARBASEINFO_ON_MSG_HOOKED(frame, msg, argStr, argNum)
	if msg == 'EXP_UPDATE' then
		_G["EXPERIENCE_VIEWER"]["elapsedTime"] = os.difftime(os.clock(), _G["EXPERIENCE_VIEWER"]["startTime"]);

		--SET BASE CURRENT/REQUIRED EXPERIENCE
		_G["EXPERIENCE_VIEWER"]["baseExperienceData"].previousRequiredExperience = _G["EXPERIENCE_VIEWER"]["baseExperienceData"].requiredExperience;
		_G["EXPERIENCE_VIEWER"]["baseExperienceData"].currentExperience = session.GetEXP();
		_G["EXPERIENCE_VIEWER"]["baseExperienceData"].requiredExperience = session.GetMaxEXP();

		--CALCULATE EXPERIENCE
		CALCULATE_EXPERIENCE_DATA(_G["EXPERIENCE_VIEWER"]["baseExperienceData"], _G["EXPERIENCE_VIEWER"]["elapsedTime"]);

		UPDATE_UI("baseExperience", _G["EXPERIENCE_VIEWER"]["baseExperienceData"]);
	end

	local oldf = _G["CHARBASEINFO_ON_MSG_OLD"];
	return oldf(frame, msg, str, exp, tableinfo);
end

function ON_JOB_EXP_UPDATE_HOOKED(frame, msg, str, exp, tableinfo)
	_G["EXPERIENCE_VIEWER"]["elapsedTime"] = os.difftime(os.clock(), _G["EXPERIENCE_VIEWER"]["startTime"]);

	--CALCULATE EXPERIENCE
	local currentTotalClassExperience = exp;
	local currentClassLevel = tableinfo.level;

	--SET CLASS CURRENT/REQUIRED EXPERIENCE
	_G["EXPERIENCE_VIEWER"]["classExperienceData"].previousRequiredExperience = _G["EXPERIENCE_VIEWER"]["classExperienceData"].requiredExperience;
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

		--old header text {@st41}
		--{@st41}{s16}
		--{@sti7}{s16}

		if expFrame ~= nil then
			UPDATE_BUTTONS(expFrame);
			UPDATE_WINDOW_POSITION();

			--SET EXPERIENCE TEXT
			if experienceTextName == "baseExperience" then
				local xPosition = 15;
				local yPosition = 14;

				for i=0,5 do
					local richText = expFrame:GetChild("header_"..i);

					if i == 0 then
						richText:SetText("{@st41}{s18}Current / Required");
					elseif i == 1 then
						richText:SetText("{@st41}{s18}%");
					elseif i == 2 then
						richText:SetText("{@st41}{s18}Gain");
					elseif i == 3 then
						richText:SetText("{@st41}{s18}TNL");
					elseif i == 4 then
						richText:SetText("{@st41}{s18}Exp/Hr");
					elseif i == 5 then
						richText:SetText("{@st41}{s18}ETA");
					end

					_G["EXPERIENCE_VIEWER"]["headerTablePositions"][i+1] = richText:GetWidth();

					richText:Resize(richText:GetWidth(), 20);
					richText:Move(0, 0);
					richText:SetOffset(xPosition, yPosition);

					local maxColumnWidth = CALCULATE_MAX_COLUMN_WIDTH(i);

					xPosition = xPosition + maxColumnWidth + _G["EXPERIENCE_VIEWER"]["padding"];
				end
			end

			if experienceTextName == "baseExperience" then
				local xPosition = 15;
				local yPosition = 49;
				for i=0,5 do
					local richText = expFrame:GetChild("base_"..i);

					if i == 0 then
						richText:SetText("{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(experienceData.currentExperience) .." / " .. ADD_THOUSANDS_SEPARATOR(experienceData.requiredExperience));
					elseif i == 1 then
						richText:SetText("{@st41}{s16}" .. string.format("%.2f", experienceData.currentPercent) .. "%");
					elseif i == 2 then
						richText:SetText("{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(experienceData.lastExperienceGain));
					elseif i == 3 then
						richText:SetText("{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(experienceData.killsTilNextLevel));
					elseif i == 4 then
						richText:SetText("{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(string.format("%i", experienceData.experiencePerHour)));
					elseif i == 5 then
						richText:SetText("{@st41}{s16}" .. experienceData.timeTilLevel);
					end

					_G["EXPERIENCE_VIEWER"]["baseTablePositions"][i+1] = richText:GetWidth();

					richText:Resize(richText:GetWidth(), 20);
					richText:Move(0, 0);
					richText:SetOffset(xPosition, yPosition);

					local maxColumnWidth = CALCULATE_MAX_COLUMN_WIDTH(i);

					xPosition = xPosition + maxColumnWidth + _G["EXPERIENCE_VIEWER"]["padding"];
				end
			end


			if experienceTextName == "classExperience" then
				local xPosition = 15;
				local yPosition = 74;

				for i=0,5 do
					local richText = expFrame:GetChild("class_"..i);

					if i == 0 then
						richText:SetText("{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(experienceData.currentExperience) .." / " .. ADD_THOUSANDS_SEPARATOR(experienceData.requiredExperience));
					elseif i == 1 then
						richText:SetText("{@st41}{s16}" .. string.format("%.2f", experienceData.currentPercent) .. "%");
					elseif i == 2 then
						richText:SetText("{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(experienceData.lastExperienceGain));
					elseif i == 3 then
						richText:SetText("{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(experienceData.killsTilNextLevel));
					elseif i == 4 then
						richText:SetText("{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(string.format("%i", experienceData.experiencePerHour)));
					elseif i == 5 then
						richText:SetText("{@st41}{s16}" .. experienceData.timeTilLevel);
					end

					_G["EXPERIENCE_VIEWER"]["classTablePositions"][i+1] = richText:GetWidth();

					richText:Resize(richText:GetWidth(), 20);
					richText:Move(0, 0);
					richText:SetOffset(xPosition, yPosition);

					local maxColumnWidth = CALCULATE_MAX_COLUMN_WIDTH(i);

					xPosition = xPosition + maxColumnWidth + _G["EXPERIENCE_VIEWER"]["padding"];
				end
			end

			local size = CALCULATE_FRAME_SIZE() + 20; --extra 20 for reset button
			expFrame:Resize(size, 108);
		end
	end
end

function CALCULATE_MAX_COLUMN_WIDTH(tableIndex)
	return math.max(_G["EXPERIENCE_VIEWER"]["headerTablePositions"][tableIndex+1], _G["EXPERIENCE_VIEWER"]["baseTablePositions"][tableIndex+1], _G["EXPERIENCE_VIEWER"]["classTablePositions"][tableIndex+1]);
end

function CALCULATE_FRAME_SIZE()
	local frameWidth = 0;

	for i = 1,6 do
		local max = math.max(_G["EXPERIENCE_VIEWER"]["headerTablePositions"][i], _G["EXPERIENCE_VIEWER"]["baseTablePositions"][i], _G["EXPERIENCE_VIEWER"]["classTablePositions"][i]);
		frameWidth = frameWidth + max + _G["EXPERIENCE_VIEWER"]["padding"];
	end

	frameWidth = frameWidth + (_G["EXPERIENCE_VIEWER"]["padding"] * 2);

	return frameWidth;
end

function SET_EXPERIENCE_TEXT(experienceText, experienceData)
	--{@sti7}{s16}
	experienceText:SetText(
		'{@st41}{s16}' ..
		ADD_THOUSANDS_SEPARATOR(experienceData.currentExperience) .." / " .. ADD_THOUSANDS_SEPARATOR(experienceData.requiredExperience) .. "   " ..
		string.format("%.2f", experienceData.currentPercent) .. "%    " ..
		ADD_THOUSANDS_SEPARATOR(experienceData.lastExperienceGain) .. "    " ..
		ADD_THOUSANDS_SEPARATOR(experienceData.killsTilNextLevel) .. "    " ..
		ADD_THOUSANDS_SEPARATOR(string.format("%i", experienceData.experiencePerHour)) .. "    " ..
		experienceData.timeTilLevel
	);

	experienceText:SetText("");
	experienceText:ShowWindow(0);
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

	--MOVE START BUTTON TO TOPLEFT CORNER
	local startButton = expFrame:GetChild("startButton");
	if startButton ~= nil then
		startButton:Move(0, 0);
		startButton:SetOffset(5, 5);
		startButton:SetText("{@sti7}{s16}S");
		startButton:Resize(30, 30);
		startButton:ShowWindow(1);
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

	UPDATE_WINDOW_POSITION();
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

local hudHook = "HEADSUPDISPLAY_ON_MSG";

if _G["HEADSUPDISPLAY_ON_MSG_OLD"] == nil then
	_G["HEADSUPDISPLAY_ON_MSG_OLD"] = _G[hudHook];
	_G[hudHook] = HEADSUPDISPLAY_ON_MSG_HOOKED;
else
	_G[hudHook] = HEADSUPDISPLAY_ON_MSG_HOOKED;
end

--ON_JOB_EXP_UPDATE
--DRAW_TOTAL_VIS
--UPDATE_MINIMAP
--EVENT_UPDATE_TIME
--PUB_CHARFRAME_UPDATE

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

INIT();

ui.SysMsg("Excrulon's expviewer loaded!");
