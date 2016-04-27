settings = {
	showCurrentRequiredExperience = true;
	showCurrentPercent = true;
	showLastGainedExperience = true;
	showKillsTilNextLevel = true;
	showExperiencePerHour = true;
	showTimeTilLevel = true;
};

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

_G["EXPERIENCE_VIEWER"] = {};
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

function SET_WINDOW_POSITION_GLOBAL()
	local expFrame = ui.GetFrame("expviewer");

	if expFrame ~= nil then
		_G["EXPERIENCE_VIEWER"]["POSITION_X"] = expFrame:GetX();
		_G["EXPERIENCE_VIEWER"]["POSITION_Y"] = expFrame:GetY();
	end

	SAVE_POSITION_TO_FILE(expFrame:GetX(), expFrame:GetY());
end

function MOVE_WINDOW_TO_STORED_POSITION()
	local expFrame = ui.GetFrame("expviewer");

	if expFrame ~= nil then
		expFrame:Move(0, 0);
		expFrame:SetOffset(_G["EXPERIENCE_VIEWER"]["POSITION_X"], _G["EXPERIENCE_VIEWER"]["POSITION_Y"]);
	end
end

function INIT()
	LOAD_POSITION_FROM_FILE();
	local expFrame = ui.GetFrame("expviewer");
	expFrame:ShowWindow(1);
	UPDATE_BUTTONS(expFrame);
	UPDATE_UI("baseExperience", _G["EXPERIENCE_VIEWER"]["baseExperienceData"]);
	UPDATE_UI("classExperience", _G["EXPERIENCE_VIEWER"]["classExperienceData"]);
end

function HEADSUPDISPLAY_ON_MSG_HOOKED(frame, msg, argStr, argNum)
	local oldf = _G["HEADSUPDISPLAY_ON_MSG_OLD"];
	oldf(frame, msg, argStr, argNum);

	MOVE_WINDOW_TO_STORED_POSITION();
	INIT();
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

		if expFrame ~= nil then
			UPDATE_BUTTONS(expFrame);

			--this might be the worst code I've ever written, but who cares? it works!

			--SET EXPERIENCE TEXT
			if experienceTextName == "baseExperience" or experienceTextName == "classExperience" then
				local xPosition = 15;
				local yPosition = 14;

				for i=0,5 do
					local columnKey = "headerTablePositions";
					local richText = expFrame:GetChild("header_"..i);

					richText:Resize(0, 20);

					if i == 0 then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s18}Current / Required",
							settings.showCurrentRequiredExperience,
							xPosition,
							yPosition,
							columnKey
						);
					elseif i == 1  then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s18}%",
							settings.showCurrentPercent,
							xPosition,
							yPosition,
							columnKey
						);
					elseif i == 2 then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s18}Gain",
							settings.showLastGainedExperience,
							xPosition,
							yPosition,
							columnKey
						);
					elseif i == 3 then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s18}TNL",
							settings.showKillsTilNextLevel,
							xPosition,
							yPosition,
							columnKey
						);
					elseif i == 4 then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s18}Exp/Hr",
							settings.showExperiencePerHour,
							xPosition,
							yPosition,
							columnKey
						);
					elseif i == 5 then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s18}ETA",
							settings.showTimeTilLevel,
							xPosition,
							yPosition,
							columnKey
						);
					end
				end
			end

			if experienceTextName == "baseExperience" then
				local xPosition = 15;
				local yPosition = 49;

				for i=0,5 do
					local columnKey = "baseTablePositions";
					local richText = expFrame:GetChild("base_"..i);

					richText:Resize(0, 20);

					if i == 0 then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(experienceData.currentExperience) .." / " .. ADD_THOUSANDS_SEPARATOR(experienceData.requiredExperience),
							settings.showCurrentRequiredExperience,
							xPosition,
							yPosition,
							columnKey
						);
					elseif i == 1  then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s16}" .. string.format("%.2f", experienceData.currentPercent) .. "%",
							settings.showCurrentPercent,
							xPosition,
							yPosition,
							columnKey
						);
					elseif i == 2 then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(experienceData.lastExperienceGain),
							settings.showLastGainedExperience,
							xPosition,
							yPosition,
							columnKey
						);
					elseif i == 3 then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(experienceData.killsTilNextLevel),
							settings.showKillsTilNextLevel,
							xPosition,
							yPosition,
							columnKey
						);
					elseif i == 4 then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(string.format("%i", experienceData.experiencePerHour)),
							settings.showExperiencePerHour,
							xPosition,
							yPosition,
							columnKey
						);
					elseif i == 5 then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s16}" .. experienceData.timeTilLevel,
							settings.showTimeTilLevel,
							xPosition,
							yPosition,
							columnKey
						);
					end
				end
			end

			if experienceTextName == "classExperience" then
				local xPosition = 15;
				local yPosition = 74;

				for i=0,5 do
					local columnKey = "classTablePositions";
					local richText = expFrame:GetChild("class_"..i);

					richText:Resize(0, 20);

					if i == 0 then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(experienceData.currentExperience) .." / " .. ADD_THOUSANDS_SEPARATOR(experienceData.requiredExperience),
							settings.showCurrentRequiredExperience,
							xPosition,
							yPosition,
							columnKey
						);
					elseif i == 1  then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s16}" .. string.format("%.2f", experienceData.currentPercent) .. "%",
							settings.showCurrentPercent,
							xPosition,
							yPosition,
							columnKey
						);
					elseif i == 2 then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(experienceData.lastExperienceGain),
							settings.showLastGainedExperience,
							xPosition,
							yPosition,
							columnKey
						);
					elseif i == 3 then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(experienceData.killsTilNextLevel),
							settings.showKillsTilNextLevel,
							xPosition,
							yPosition,
							columnKey
						);
					elseif i == 4 then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s16}" .. ADD_THOUSANDS_SEPARATOR(string.format("%i", experienceData.experiencePerHour)),
							settings.showExperiencePerHour,
							xPosition,
							yPosition,
							columnKey
						);
					elseif i == 5 then
						xPosition = UPDATE_CELL(
							i,
							richText,
							"{@st41}{s16}" .. experienceData.timeTilLevel,
							settings.showTimeTilLevel,
							xPosition,
							yPosition,
							columnKey
						);
					end
				end
			end

			local size = CALCULATE_FRAME_SIZE() + 20; --extra 20 for reset button
			expFrame:Resize(size, 108);
		end
	end
end

function UPDATE_CELL(i, richTextComponent, label, showField, xPosition, yPosition, columnKey)
	if showField then
		richTextComponent:SetText(label);

		_G["EXPERIENCE_VIEWER"][columnKey][i+1] = richTextComponent:GetWidth();

		richTextComponent:Resize(richTextComponent:GetWidth(), 20);
		richTextComponent:Move(0, 0);
		richTextComponent:SetOffset(xPosition, yPosition);
		richTextComponent:ShowWindow(1);

		xPosition = xPosition + CALCULATE_MAX_COLUMN_WIDTH(i)  + _G["EXPERIENCE_VIEWER"]["padding"];
	else
		_G["EXPERIENCE_VIEWER"][columnKey][i+1] = 0;
		richTextComponent:SetText("");
		richTextComponent:Move(0, 0);
		richTextComponent:SetOffset(xPosition, yPosition);
		richTextComponent:ShowWindow(0);
	end

	return xPosition;
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
		startButton:ShowWindow(0);
	end
end

function PRINT_EXPERIENCE_DATA(experienceData)
	ui.SysMsg(experienceData.currentExperience .. " / " .. experienceData.requiredExperience .. "   " .. experienceData.lastExperienceGain .. " gained   " .. experienceData.currentPercent .. "%" .. "   " .. experienceData.killsTilNextLevel .. " tnl   " .. experienceData.experiencePerHour .. " exp/hr");
end

function RESET()
	ui.SysMsg("Resetting experience session!");

	_G["EXPERIENCE_VIEWER"]["startTime"] = os.clock();
	_G["EXPERIENCE_VIEWER"]["elapsedTime"] = 0;
	_G["EXPERIENCE_VIEWER"]["baseExperienceData"]:reset();
	_G["EXPERIENCE_VIEWER"]["classExperienceData"]:reset();

	SET_WINDOW_POSITION_GLOBAL();
end

function LOAD_POSITION_FROM_FILE()
	local file, error = io.open("../addons/expviewer/settings.txt", "r");

	if error then
		return;
	end

	_G["EXPERIENCE_VIEWER"]["POSITION_X"] = file:read();
	_G["EXPERIENCE_VIEWER"]["POSITION_Y"] = file:read();

	MOVE_WINDOW_TO_STORED_POSITION();
end

function SAVE_POSITION_TO_FILE(xPosition, yPosition)
	local file, error = io.open("../addons/expviewer/settings.txt", "w");

	if error then
		return;
	end

	file:write(xPosition .. "\n" .. yPosition);
	file:flush();
	file:close();
end

--LOAD HOOKS - this must go at the end of the script so that the methods are defined
SETUP_HOOK(CHARBASEINFO_ON_MSG_HOOKED, "CHARBASEINFO_ON_MSG");
SETUP_HOOK(ON_JOB_EXP_UPDATE_HOOKED, "ON_JOB_EXP_UPDATE");
SETUP_HOOK(HEADSUPDISPLAY_ON_MSG_HOOKED, "HEADSUPDISPLAY_ON_MSG_OLD");

INIT();

ui.SysMsg("Experience Viewer loaded!");
