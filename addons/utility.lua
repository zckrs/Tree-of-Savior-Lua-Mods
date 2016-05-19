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

function GET_STAT_PROPERTY_FROM_PC(typeStr, statStr, pc)
    local errorText = "Param was nil";
    
    if typeStr ~= nil and statStr ~= nil and pc ~= nil then

        if typeStr == "JOB" then
            if statStr == "STR" then
                return pc.STR_JOB;
            elseif statStr == "DEX" then
                return pc.DEX_JOB;
            elseif statStr == "CON" then
                return pc.CON_JOB;
            elseif statStr == "INT" then
                return pc.INT_JOB;
            elseif statStr == "MNA" then
                return pc.MNA_JOB;
            elseif statStr == "LUCK" then
                return pc.LUCK_JOB;
            else
                errorText = "Could not find stat "..statStr.." for type "..typeStr;
            end

        elseif typeStr == "STAT" then
            if statStr == "STR" then
                return pc.STR_STAT;
            elseif statStr == "DEX" then
                return pc.DEX_STAT;
            elseif statStr == "CON" then
                return pc.CON_STAT;
            elseif statStr == "INT" then
                return pc.INT_STAT;
            elseif statStr == "MNA" then
                return pc.MNA_STAT;
            elseif statStr == "LUCK" then
                return pc.LUCK_STAT;
            else
                errorText = "Could not find stat "..statStr.." for type "..typeStr;
            end
        
        elseif typeStr == "BONUS" then
            if statStr == "STR" then
                return pc.STR_Bonus;
            elseif statStr == "DEX" then
                return pc.DEX_Bonus;
            elseif statStr == "CON" then
                return pc.CON_Bonus;
            elseif statStr == "INT" then
                return pc.INT_Bonus;
            elseif statStr == "MNA" then
                return pc.MNA_Bonus;
            else
                errorText = "Could not find stat "..statStr.." for type "..typeStr;
            end
        
        elseif typeStr == "ADD" then
            if statStr == "STR" then
                return pc.STR_ADD;
            elseif statStr == "DEX" then
                return pc.DEX_ADD;
            elseif statStr == "CON" then
                return pc.CON_ADD;
            elseif statStr == "INT" then
                return pc.INT_ADD;
            elseif statStr == "MNA" then
                return pc.MNA_ADD;
            elseif statStr == "LUCK" then
                return pc.LUCK_ADD;
            else
                errorText = "Could not find stat "..statStr.." for type "..typeStr;
            end
        
        elseif typeStr == "BM" then
            if statStr == "STR" then
                return pc.STR_BM;
            elseif statStr == "DEX" then
                return pc.DEX_BM;
            elseif statStr == "CON" then
                return pc.CON_BM;
            elseif statStr == "INT" then
                return pc.INT_BM;
            elseif statStr == "MNA" then
                return pc.MNA_BM;
            elseif statStr == "LUCK" then
                return pc.LUCK_BM;
            else
                errorText = "Could not find stat "..statStr.." for type "..typeStr;
            end
        
        else
            errorText = "Could not find a property for type "..typeStr;
        end
    end
    
    ui.SysMsg(errorText);
    return 0;
end

function IS_VALID_STAT(statStr, includeLuck)
    if statStr == "LUCK" then
        return includeLuck;
    elseif statStr == "STR" or
           statStr == "DEX" or
           statStr == "CON" or
           statStr == "INT" or
           statStr == "MNA" then
        return true;
    end
    
    return false;
end

function TEXT_CONTROL_FACTORY(attributeName, isMainSection)
    local text = "";
    
    if attributeName == "MNA" then
        attributeName = "SPR"
    elseif attributeName == "MountDEF" then
        attributeName = "physical defense"
    elseif attributeName == "MountDR" then
        attributeName = "evasion"
    elseif attributeName == "MountMHP" then
        attributeName = "max HP"
    end
    
    if isMainSection then
        text = "Points invested in " .. attributeName;
    else
        text = "Mounted " .. attributeName .. " bonus";
    end
    return text;
end

function SETUP_HOOK(newFunction, hookedFunctionStr)
	local storeOldFunc = hookedFunctionStr .. "_OLD";
	if _G[storeOldFunc] == nil then
		_G[storeOldFunc] = _G[hookedFunctionStr];
		_G[hookedFunctionStr] = newFunction;
	else
		_G[hookedFunctionStr] = newFunction;
	end
end

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS']['EVENTS'] = _G['ADDONS']['EVENTS'] or {};
_G['ADDONS']['EVENTS']['ARGS'] = _G['ADDONS']['EVENTS']['ARGS'] or {};

function SETUP_EVENT(myAddon, functionName, myFunctionName)
	if _G['ADDONS']['EVENTS'][functionName .. "_OLD"] == nil then
		_G['ADDONS']['EVENTS'][functionName .. "_OLD"] =  _G[functionName];
	end

	local hookedFuncString = [[_G[']]..functionName..[['] = function(...)
		local thisFuncName = "]]..functionName..[[";
		pcall(_G['ADDONS']['EVENTS'][thisFuncName .. '_OLD'], ...);
		_G['ADDONS']['EVENTS']['ARGS'][thisFuncName] = {...};
		imcAddOn.BroadMsg(thisFuncName);
	end
	]];

	pcall(loadstring(hookedFuncString));
	myAddon:RegisterMsg(functionName, myFunctionName);
end

function GET_EVENT_ARGS(eventMsg)
	return unpack(_G['ADDONS']['EVENTS']['ARGS'][eventMsg]);
end
