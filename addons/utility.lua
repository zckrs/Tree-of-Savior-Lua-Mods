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
