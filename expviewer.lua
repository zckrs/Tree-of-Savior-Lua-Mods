if _G["ON_JOB_EXP_UPDATE_OLD"] == nil then
	_G["ON_JOB_EXP_UPDATE_OLD"] = _G["ON_JOB_EXP_UPDATE"];
	_G["ON_JOB_EXP_UPDATE"] = ON_JOB_EXP_UPDATE_HOOKED;
else
	_G["ON_JOB_EXP_UPDATE"] = ON_JOB_EXP_UPDATE_HOOKED;
end

--[[
UPDATE_EXPCARD_USE_TUTORIAL
GET_ITEM_LEVEL_EXP
XAC_EVENTEXPUP
SCR_EVENTEXPUP
--]]

--_G["EXPERIENCE_VIEWER"] = { asdf, asdf2, asdf3 = function() end, asdf4}

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
--[[END EXPERIENCE DATA]]

local baseExperienceData = ExperienceData();
local classExperienceData = ExperienceData();

startTime = os.clock();
SECONDS_IN_HOUR = 3600;

local labels = {
	"Current Xp",
	"Required Xp",
	"TNL",
	"%",
	"Xp/Hr",
	"Last",
	"Gained"
}

function ON_JOB_EXP_UPDATE_HOOKED(frame, msg, str, exp, tableinfo)

	ui.SysMsg("card used?");

	local frame = ui.GetFrame("expviewer");

	frame:ShowWindow(1);
	frame:ShowTitleBar(0);

	local elapsedTime = os.difftime(os.clock(), startTime);
	local currentTotalClassExperience = exp;
	local currentClassLevel = tableinfo.level;

	--[[SET BASE CURRENT/REQUIRED EXPERIENCE]]
	baseExperienceData.previousRequiredExperience = baseExperienceData.requiredExperience;
	classExperienceData.previousRequiredExperience = classExperienceData.requiredExperience;

	baseExperienceData.currentExperience = session.GetEXP();
	baseExperienceData.requiredExperience = session.GetMaxEXP();

	--[[SET CLASS CURRENT/REQUIRED EXPERIENCE]]
	classExperienceData.currentExperience = exp - tableinfo.startExp;
	classExperienceData.requiredExperience = tableinfo.endExp - tableinfo.startExp;

	--[[CALCULATE EXPERIENCE]]
	CALCULATE_EXPERIENCE_DATA(baseExperienceData, elapsedTime);
	CALCULATE_EXPERIENCE_DATA(classExperienceData, elapsedTime);

	--frame:Resize(600, 100);

	--[[SET TITLE TEXT]]
	--[[
	local titleRichTextObject = frame:GetChild("title");
	local titleRichText = tolua.cast(titleRichTextObject, "ui::CRichText");
	titleRichText:SetText("{@sti7}{s16}Experience Viewer");
	--titleRichText:SetOffset(230, 15);
	--titleRichText:Move(50, 50);
	--]]

	local columnHeadersRichText = frame:GetChild("columnHeaders");
	columnHeadersRichText:SetText("{@st41} Current / Required % Last TNL Hr");

	--[[SET EXPERIENCE TEXT]]
	local baseExperienceRichText = frame:GetChild("baseExperience");
	SET_EXPERIENCE_TEXT(baseExperienceRichText, baseExperienceData);

	local classExperienceRichText = frame:GetChild("classExperience");
	SET_EXPERIENCE_TEXT(classExperienceRichText, classExperienceData);

	--[[
	--file = io.open("C:/pcall-error.txt", "w");
    local status, err = pcall(function () experienceMainGroupBox:GetChild("currentRequiredBaseExperience"); end);
    if err ~= nil then
        ui.SysMsg(err);
    	--file:write(err);
    end

	local status, err = pcall(function () experienceMainGroupBox:CreateOrGetControl("richtext", "currentRequiredBaseExperience", 15, 15, 0, 24); end);
	if err ~= nil then
		ui.SysMsg(err);
		--file:write(err);
	end
	--]]

	--PRINT_EXPERIENCE_DATA(baseExperienceData);
	--PRINT_EXPERIENCE_DATA(classExperienceData);

	local oldf = _G["ON_JOB_EXP_UPDATE_OLD"];
	return oldf(frame, msg, str, exp, tableinfo)
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

	experienceData.experiencePerHour = (experienceData.experienceGained * (SECONDS_IN_HOUR / elapsedTime));

	local experienceRemaining = experienceData.requiredExperience - experienceData.currentExperience;
	local experiencePerSecond = experienceData.experienceGained / elapsedTime;

	experienceData.timeTilLevel = os.date("!%X", experienceRemaining / experiencePerSecond);

	--[[END OF UPDATES, SET PREVIOUS]]
	experienceData.previousCurrentExperience = experienceData.currentExperience;
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

function PRINT_EXPERIENCE_DATA(experienceData)
	ui.SysMsg(experienceData.currentExperience .. " / " .. experienceData.requiredExperience .. "   " .. experienceData.lastExperienceGain .. " gained   " .. experienceData.currentPercent .. "%" .. "   " .. experienceData.killsTilNextLevel .. " tnl   " .. experienceData.experiencePerHour .. " exp/hr");
end

function OPEN_EXP_VIEWER()
	ui.SysMsg("Opened exp viewer!");
end

function CLOSE_EXP_VIEWER()
	ui.SysMsg("Closed exp viewer!");
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

function isNil(object, name)
	if object == nil then
		ui.SysMsg(name .. " is nil");
	else
		ui.SysMsg(name .. " is not nil");
	end
end

function dumpTable(table, filename)
	file = io.open("C:/" .. filename .. ".txt", "w")
	local status, err = pcall(function () file:write(DataDumper(getmetatable(table))); end);


	if err ~= nil then
		ui.SysMsg(err);
		file:write(err);
	end
	file:close()
end

--DATA DUMP
function getArgs(fun, file)
	local args = {}
	local hook = debug.gethook()

	local argHook = function( ... )
		local info = debug.getinfo(3)
		if 'pcall' ~= info.name then return end

		for i = 1, math.huge do
			local name, value = debug.getlocal(2, i)
			if '(*temporary)' == name then
				debug.sethook(hook)
				file:write('_')
				return
			end
			table.insert(args,name)
		end
	end

	debug.sethook(argHook, "c")
	pcall(fun)

	return args
end

local dumplua_closure = [[
local closures = {}
local function closure(t)
	closures[#closures+1] = t
	t[1] = assert(loadstring(t[1]))
	return t[1]
end

for _,t in pairs(closures) do
	for i = 2,#t do
		debug.setupvalue(t[1], i-1, t[i])
	end
end
]]

local lua_reserved_keywords = {
	'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for',
	'function', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat',
		'return', 'then', 'true', 'until', 'while' }

			local function keys(t)
				local res = {}
				local oktypes = { stringstring = true, numbernumber = true }
				local function cmpfct(a,b)
					if oktypes[type(a)..type(b)] then
						return a < b
					else
						return type(a) < type(b)
					end
				end
				for k in pairs(t) do
					res[#res+1] = k
				end
				table.sort(res, cmpfct)
				return res
			end

			local c_functions = {}
			for _,lib in pairs{'_G', 'string', 'table', 'math',
			'io', 'os', 'coroutine', 'package', 'debug'} do
				local t = _G[lib] or {}
				lib = lib .. "."
				if lib == "_G." then lib = "" end
				for k,v in pairs(t) do
					if type(v) == 'function' and not pcall(string.dump, v) then
						c_functions[v] = lib..k
					end
				end
			end

			function DataDumper(value, varname, fastmode, ident)
				local defined, dumplua = {}
				-- Local variables for speed optimization
				local string_format, type, string_dump, string_rep =
				string.format, type, string.dump, string.rep
				local tostring, pairs, table_concat =
				tostring, pairs, table.concat
				local keycache, strvalcache, out, closure_cnt = {}, {}, {}, 0
				setmetatable(strvalcache, {__index = function(t,value)
					local res = string_format('%q', value)
					t[value] = res
					return res
				end})
				local fcts = {
					string = function(value) return strvalcache[value] end,
					number = function(value) return value end,
					boolean = function(value) return tostring(value) end,
					['nil'] = function(value) return 'nil' end,
					['function'] = function(value)
						return string_format("loadstring(%q)", string_dump(value))
					end,
					userdata = function() return "Cannot dump userdata" end,
					thread = function() return "Cannot dump threads" end,
				}
				local function test_defined(value, path)
					if defined[value] then
						if path:match("^getmetatable.*%)$") then
							out[#out+1] = string_format("s%s, %s)\n", path:sub(2,-2), defined[value])
						else
							out[#out+1] = path .. " = " .. defined[value] .. "\n"
						end
						return true
					end
					defined[value] = path
				end
				local function make_key(t, key)
					local s
					if type(key) == 'string' and key:match('^[_%a][_%w]*$') then
						s = key .. "="
					else
						s = "[" .. dumplua(key, 0) .. "]="
					end
					t[key] = s
					return s
				end
				for _,k in ipairs(lua_reserved_keywords) do
					keycache[k] = '["'..k..'"] = '
				end
				if fastmode then
					fcts.table = function (value)
						-- Table value
						local numidx = 1
						out[#out+1] = "{"
						for key,val in pairs(value) do
							if key == numidx then
								numidx = numidx + 1
							else
								out[#out+1] = keycache[key]
							end
							local str = dumplua(val)
							out[#out+1] = str..","
						end
						if string.sub(out[#out], -1) == "," then
							out[#out] = string.sub(out[#out], 1, -2);
						end
						out[#out+1] = "}"
						return ""
					end
				else
					fcts.table = function (value, ident, path)
						if test_defined(value, path) then return "nil" end
						-- Table value
						local sep, str, numidx, totallen = " ", {}, 1, 0
						local meta, metastr = (debug or getfenv()).getmetatable(value)
						if meta then
							ident = ident + 1
							metastr = dumplua(meta, ident, "getmetatable("..path..")")
							totallen = totallen + #metastr + 16
						end
						for _,key in pairs(keys(value)) do
							local val = value[key]
							local s = ""
							local subpath = path or ""
							if key == numidx then
								subpath = subpath .. "[" .. numidx .. "]"
								numidx = numidx + 1
							else
								s = keycache[key]
								if not s:match "^%[" then subpath = subpath .. "." end
								subpath = subpath .. s:gsub("%s*=%s*$","")
							end
							s = s .. dumplua(val, ident+1, subpath)
							str[#str+1] = s
							totallen = totallen + #s + 2
						end
						if totallen > 80 then
							sep = "\n" .. string_rep("  ", ident+1)
						end
						str = "{"..sep..table_concat(str, ","..sep).." "..sep:sub(1,-3).."}"
						if meta then
							sep = sep:sub(1,-3)
							return "setmetatable("..sep..str..","..sep..metastr..sep:sub(1,-3)..")"
						end
						return str
					end
					fcts['function'] = function (value, ident, path)
						if test_defined(value, path) then return "nil" end
						if c_functions[value] then
							return c_functions[value]
						elseif debug == nil or debug.getupvalue(value, 1) == nil then
							sstrs = ""
							local status, sts = pcall(function () sts = string_dump(value) end)
							if status then
								return string_format("loadstring(%q)", sts)
							else return "" end

						end
						closure_cnt = closure_cnt + 1
						local res = {string.dump(value)}
						for i = 1,math.huge do
							local name, v = debug.getupvalue(value,i)
							if name == nil then break end
							res[i+1] = v
						end
						return "closure " .. dumplua(res, ident, "closures["..closure_cnt.."]")
					end
				end
				function dumplua(value, ident, path)
					return fcts[type(value)](value, ident, path)
				end
				if varname == nil then
					varname = "return "
				elseif varname:match("^[%a_][%w_]*$") then
					varname = varname .. " = "
				end
				if fastmode then
					setmetatable(keycache, {__index = make_key })
					out[1] = varname
					table.insert(out,dumplua(value, 0))
					return table.concat(out)
				else
					setmetatable(keycache, {__index = make_key })
					local items = {}
					for i=1,10 do items[i] = '' end
					items[3] = dumplua(value, ident or 0, "t")
					if closure_cnt > 0 then
						items[1], items[6] = dumplua_closure:match("(.*\n)\n(.*)")
						out[#out+1] = ""
					end
					if #out > 0 then
						items[2], items[4] = "local t = ", "\n"
						items[5] = table.concat(out)
						items[7] = varname .. "t"
					else
						items[2] = varname
					end
					return table.concat(items)
				end
			end

			function getvarvalue (name)
				local value, found

				-- try local variables
				local i = 1
				while true do
					local n, v = debug.getlocal(2, i)
					if not n then break end
					if n == name then
						value = v
						found = true
					end
					i = i + 1
				end
				if found then return value end

				-- try upvalues
				local func = debug.getinfo(2).func
				i = 1
				while true do
					local n, v = debug.getupvalue(func, i)
					if not n then break end
					if n == name then return v end
					i = i + 1
				end

				-- not found; get global
				return getfenv(func)[name]
			end
