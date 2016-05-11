function BLOCK_AND_REPORT(targetName)

	local msgBoxString = string.format("Report %s and Block new messages?", targetName);
	local blockAndReportScp = string.format("BLOCK_AND_REPORT_FUNC('%s')", targetName);
	ui.MsgBox(msgBoxString, blockAndReportScp, "None");

end

function BLOCK_AND_REPORT_FUNC(targetName)

	REPORT_AUTOBOT(targetName);
	friends.RequestBlock(targetName);

end

function CHAT_RBTN_POPUP_HOOKED(frame, chatCtrl)

	local targetName = chatCtrl:GetUserValue("TARGET_NAME");

	if session.world.IsIntegrateServer() == true then
		ui.SysMsg(ScpArgMsg("CantUseThisInIntegrateServer"));
		return;
	end

	if targetName == GETMYFAMILYNAME() then
		return;
	end
	
	local friendsListType = session.friends.GetFriendListTypeByFamilyName(targetName);
	
	local groupBoxName = chatCtrl:GetParent():GetName();
	local chatCtrlName = chatCtrl:GetName();
	
	local context = ui.CreateContextMenu("CONTEXT_CHAT_RBTN", targetName, 0, 0, 170, 100);

	ui.AddContextMenuItem(context, "Whisper", string.format("ui.WhisperTo('%s')", targetName));
	ui.AddContextMenuItem(context, "Character Info", string.format("OPEN_PARTY_MEMBER_INFO('%s')", targetName));
	ui.AddContextMenuItem(context, "Party Request", string.format("PARTY_INVITE('%s')", targetName));
	
	if AM_I_LEADER(PARTY_GUILD) == 1 then
		ui.AddContextMenuItem(context, ClMsg("GUILD_INVITE"), string.format("GUILD_INVITE('%s')", targetName));
	end
	
	if FRIEND_LIST_COMPLETE == friendsListType then
		ui.AddContextMenuItem(context, "Remove Friend", string.format("FRIEND_REMOVE('%s', 'friends list')", targetName));
		ui.AddContextMenuItem(context, "Remove Message", string.format("REMOVE_CHAT_CLUSTER('%s', '%s')", chatCtrlName, groupBoxName));
		ui.AddContextMenuItem(context, "Block", string.format("CHAT_BLOCK_MSG('%s')", targetName));
	elseif FRIEND_LIST_BLOCKED == friendsListType then
		ui.AddContextMenuItem(context, "Remove Message", string.format("REMOVE_CHAT_CLUSTER('%s', '%s')", chatCtrlName, groupBoxName));
		ui.AddContextMenuItem(context, "Report Bot", string.format("REPORT_AUTOBOT_MSGBOX('%s')", targetName));
		ui.AddContextMenuItem(context, "Unblock", string.format("FRIEND_REMOVE('%s', 'block list')", targetName));
	else
		ui.AddContextMenuItem(context, "Friend Request", string.format("friends.RequestRegister('%s')", targetName));
		ui.AddContextMenuItem(context, "Remove Message", string.format("REMOVE_CHAT_CLUSTER('%s', '%s')", chatCtrlName, groupBoxName));
		ui.AddContextMenuItem(context, "Report Bot & Block", string.format("BLOCK_AND_REPORT('%s')", targetName));
		ui.AddContextMenuItem(context, "Report Bot", string.format("REPORT_AUTOBOT_MSGBOX('%s')", targetName));
		ui.AddContextMenuItem(context, "Block", string.format("CHAT_BLOCK_MSG('%s')", targetName));
	end
	
	ui.AddContextMenuItem(context, "Cancel", "None");
	ui.OpenContextMenu(context);

end

function FRIEND_REMOVE(targetName, listname)
	local friendsListType = session.friends.GetFriendListTypeByFamilyName(targetName);
	local cnt = session.friends.GetFriendCount(friendsListType);
	
	for i = 0 , cnt - 1 do
		local f = session.friends.GetFriendByIndex(friendsListType, i);
		if targetName == f:GetInfo():GetFamilyName() then
			local msgBoxString = string.format("Do you want to remove %s from your %s?", targetName, listname);
			local unblockScp = string.format("friends.RequestDelete('%s')", f:GetInfo():GetACCID());
			ui.MsgBox(msgBoxString, unblockScp, "None");
			return;
		end
	end
end

function OPEN_PARTY_MEMBER_INFO_HOOKED(targetName)
	pcCompareFirstPass = true;
	party.ReqMemberDetailInfo(targetName);
end

function REQUEST_LIKE_STATE_HOOKED(familyName)
	if pcCompareFirstPass == true then
		pcCompareFirstPass = false;
		return;
	end
	_G['REQUEST_LIKE_STATE_OLD'](familyName);
end


function SHOW_PC_CONTEXT_MENU_HOOKED(handle)

	local pcObj = world.GetActor(handle);
	local targetName = pcObj:GetPCApc():GetFamilyName();

	if world.IsPVPMap() == true then
		return;
	end

	if pcObj == nil then
		return;
	end

	if pcObj:IsMyPC() == 0 and info.IsPC(pcObj:GetHandleVal()) == 1 then
	
		local friendsListType = session.friends.GetFriendListTypeByFamilyName(targetName);

		local context = ui.CreateContextMenu("PC_CONTEXT_MENU", targetName, 0, 0, 170, 100);

		ui.AddContextMenuItem(context, "Trade", string.format("exchange.RequestChange(%d)", pcObj:GetHandleVal()));

		if session.world.IsIntegrateServer() == false then

			ui.AddContextMenuItem(context, "Whisper", string.format("ui.WhisperTo('%s')", targetName));
			ui.AddContextMenuItem(context, "Character Info", string.format("PROPERTY_COMPARE(%d)", handle));
			ui.AddContextMenuItem(context, "Party Request", string.format("PARTY_INVITE('%s')", targetName));
			
			if FRIEND_LIST_COMPLETE == friendsListType then
				ui.AddContextMenuItem(context, "Remove Friend", string.format("FRIEND_REMOVE('%s', 'friends list')", targetName));
			else
				ui.AddContextMenuItem(context, "Friend Request", string.format("friends.RequestRegister('%s')", targetName));
			end

			if AM_I_LEADER(PARTY_GUILD) == 1 then
				ui.AddContextMenuItem(context, ClMsg("GUILD_INVITE"), string.format("GUILD_INVITE('%s')", targetName));
			end

			ui.AddContextMenuItem(context, "Visit Lodge", string.format("barrackNormal.Visit(%d)", handle));

		end
		
		ui.AddContextMenuItem(context, "Friendly Duel Request", string.format("REQUEST_FIGHT(\"%d\")", pcObj:GetHandleVal()));
		
		if FRIEND_LIST_BLOCKED == friendsListType then
			ui.AddContextMenuItem(context, "Report Bot", string.format("REPORT_AUTOBOT_MSGBOX('%s')", targetName));
			ui.AddContextMenuItem(context, "Unblock", string.format("FRIEND_REMOVE('%s', 'block list')", targetName));
		else
			ui.AddContextMenuItem(context, "Report Bot & Block", string.format("BLOCK_AND_REPORT('%s')", targetName));
			ui.AddContextMenuItem(context, "Report Bot", string.format("REPORT_AUTOBOT_MSGBOX('%s')", targetName));
			ui.AddContextMenuItem(context, "Block", string.format("CHAT_BLOCK_MSG('%s')", targetName));
		end
		if session.world.IsIntegrateServer() == false then
			if session.likeit.AmILikeYou(targetName) == true then
				ui.AddContextMenuItem(context, "Cancel Like", string.format("SEND_PC_INFO(%d)", handle));
			else
				ui.AddContextMenuItem(context, "Like!", string.format("SEND_PC_INFO(%d)", handle));
			end
		end

		ui.AddContextMenuItem(context, "Cancel", "None");
		ui.OpenContextMenu(context);

		return context;

	end

end

function REMOVE_CHAT_CLUSTER(clusterName, groupBoxName)
	removedClusterNames[clusterName] = true;
	local chatFrame = ui.GetFrame("chatframe");
	if chatFrame == nil then
		return;
	end
	local groupBox = GET_CHILD(chatFrame, groupBoxName, "ui::CGroupBox");
	local chatCtrl = GET_CHILD(groupBox, clusterName);
	
	chatCtrl:Resize(0, 0);
	chatCtrl:ShowWindow(0);
	GBOX_AUTO_ALIGN(groupBox, 0, 0, 0, true, false);
	groupBox:UpdateData();

	chatFrame:Invalidate();
end


function RESIZE_CHAT_CTRL_HOOKED(chatCtrl, label, txt, timeBox)
	if removedClusterNames[chatCtrl:GetName()] == true then 
		local groupBox = chatCtrl:GetParent();
		chatCtrl:Resize(1, 0);
		chatCtrl:ShowWindow(0);
		GBOX_AUTO_ALIGN(groupBox, 0, 0, 0, true, false);
		groupBox:UpdateData();
		return;
	end
	_G['RESIZE_CHAT_CTRL_OLD'](chatCtrl, label, txt, timeBox);
end

if not removedClusterNames then
	removedClusterNames = {};
end

SETUP_HOOK(RESIZE_CHAT_CTRL_HOOKED, "RESIZE_CHAT_CTRL");
SETUP_HOOK(SHOW_PC_CONTEXT_MENU_HOOKED, "SHOW_PC_CONTEXT_MENU");
SETUP_HOOK(CHAT_RBTN_POPUP_HOOKED, "CHAT_RBTN_POPUP");
SETUP_HOOK(OPEN_PARTY_MEMBER_INFO_HOOKED, "OPEN_PARTY_MEMBER_INFO");
SETUP_HOOK(REQUEST_LIKE_STATE_HOOKED, "REQUEST_LIKE_STATE");

ui.SysMsg("Block and Report loaded!");
