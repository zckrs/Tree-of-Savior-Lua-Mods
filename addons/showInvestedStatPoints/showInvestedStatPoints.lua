function STATUS_INFO_HOOKED(frame)
    _G["STATUS_INFO_OLD"](frame);
    
    local Status_gboxctrl = frame:GetChild('statusGbox');
    local Status_internal_gboxctrl = GET_CHILD(Status_gboxctrl,'internalstatusBox');
    
    local pc = GetMyPCObject();
    
    local stats = {};
    stats["statPC"] = {};           -- this is how many points you've allocated to it

    local y = 23 + 10; -- 23 to pad for the hight of the last CRichText, 10 for spacer
    -- the last control that STATUS_INFO adds; use this to place ours at the end of the list
    local controlSet = Status_internal_gboxctrl:GetChild("Velnias_Atk");
    if controlSet:GetY() > 0 then
        y = y + controlSet:GetY();
    else
        -- if we can't find the last entry in the status box, pick a high arbitrary number
        y = 1500; -- should be far enough down to not obstruct other values
    end
    
    -- for each type of STAT (excludes hidden stat LUCK)
    for i = 0 , STAT_COUNT - 1 do
        local statStr = GetStatTypeStr(i);
        stats["statPC"][statStr] = GET_STAT_PROPERTY_FROM_PC("STAT", statStr, pc);
        
        -- display the points we have allocated on the end of the list
        y = ADD_TO_STATUS(Status_internal_gboxctrl, statStr, stats["statPC"][statStr], y);
    end
    
    Status_internal_gboxctrl:SetScrollPos(0);
    frame:Invalidate();
    
end

function ADD_TO_STATUS(gboxctrl, attibuteName, value, y)
    local controlSet = gboxctrl:CreateOrGetControlSet('status_stat', attibuteName, 0, y);
    
    tolua.cast(controlSet, "ui::CControlSet");
    local title = GET_CHILD(controlSet, "title", "ui::CRichText");
    if attibuteName == "MNA" then
        title:SetText("Points invested in SPR");
    else
        title:SetText("Points invested in "..attibuteName);
    end

    local stat = GET_CHILD(controlSet, "stat", "ui::CRichText");
    title:SetUseOrifaceRect(true);
    stat:SetUseOrifaceRect(true);
    stat:SetText(value);

    controlSet:Resize(controlSet:GetWidth(), stat:GetHeight());
    
    return y + controlSet:GetHeight();
end

local STATUS_INFOHook = "STATUS_INFO";

if _G["STATUS_INFO_OLD"] == nil then
    _G["STATUS_INFO_OLD"] = _G[STATUS_INFOHook];
    _G[STATUS_INFOHook] = STATUS_INFO_HOOKED;
else
    _G[STATUS_INFOHook] = STATUS_INFO_HOOKED;
end

ui.SysMsg("Show Invested Stat Points loaded!");
