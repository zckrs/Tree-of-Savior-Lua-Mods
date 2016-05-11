function MAKE_ABILITYSHOP_ICON_HOOKED(frame, pc, grid, abilityClass, groupClass, posY)
	local onlyShowLearnable = GET_CHILD_RECURSIVELY(frame, "onlyShowLearnable")
	local abilityLevel = 0;
	local isMax = false;

	local ability = GetAbilityIESObject(pc, abilityClass.ClassName);
	if ability ~= nil then
		abilityLevel = ability.Level;
	end

	local maxLevel = tonumber(groupClass.MaxLevel)
	if abilityLevel >= maxLevel then
		isMax = true;
	end

	if onlyShowLearnable:IsChecked() == 1 then

		if isMax == true then
			return posY
		end

	end

	return _G["MAKE_ABILITYSHOP_ICON_OLD"](frame, pc, grid, abilityClass, groupClass, posY);
end

SETUP_HOOK(MAKE_ABILITYSHOP_ICON_HOOKED, "MAKE_ABILITYSHOP_ICON");

ui.SysMsg("Hide Max Level Attributes loaded!");
