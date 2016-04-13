
-- this is slightly modified channel.lua.
-- it allows you to skip confirmation message on selecting channels
-- as a bonus - makes the list longer

function REFRESH_ON_INIT()
	local frame = ui.GetFrame("refresh")
	frame:ShowWindow(1)

    

	local luaFolderDir = "../"
	local allFileNames = scandir(luaFolderDir)

	for _,fileName in pairs(allFileNames) do 
		ui.SysMsg("Updating: " .. luaFolderDir .. fileName);
    	dofile(luaFolderDir .. fileName);
	end


	ui.SysMsg("All Lua Files Refreshed")

end

-- Lua implementation of PHP scandir function
function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    for filename in popen('dir "'..directory..'" /b'):lines() do
    	if string.find(filename, ".lua") ~= nil and filename ~= "refresh_action.lua" then
	        t[i] = filename
	        i = i + 1
    	end
    end
    return t
end

REFRESH_ON_INIT()
