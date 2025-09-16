local CommonUtil = require("Utils/CommonUtil")
local ChatVM = require("Game/Chat/ChatVM")
local ChatDefine = require("Game/Chat/ChatDefine")
local ChatUtil = require("Game/Chat/ChatUtil")
local PathMgr = require("Path/PathMgr")

local ChatChannel = ChatDefine.ChatChannel
local ServerMsgSortFunc = ChatDefine.ServerMsgSortFunc

local escapeList = {
    ['"'] = '\\"',
	['\''] = '\\\'',
    ['\\'] = '\\\\',
    ['\b'] = '\\b',
    ['\f'] = '\\f',
    ['\n'] = '\\n',
    ['\r'] = '\\r',
    ['\t'] = '\\t'
}

local function encodeString(s)
	local str = tostring(s)
	return str:gsub(".", function(c) return escapeList[c] end)
end

local function ToStringEx(value)
	if type(value) =='table' then
		return _G.TableToString(value)
	elseif type(value) =='string' then
		return "\'" .. encodeString(value) .. "\'"
	end

	return tostring(value)
end

function _G.TableToString(t)
	if not t then 
		return "" 
	end

	local ret = "{"
	local i = 1

	for k, v in pairs(t) do
		local signal = ","
		if 1 == i then
			signal = ""
		end

		if k == i then
			ret = ret .. signal .. ToStringEx(v)
		else
			if type(k) == 'number' or type(k) == 'string' then
				ret = ret .. signal .. '[' .. ToStringEx(k) .. ']=' .. ToStringEx(v)
			else
				if type(k) == 'userdata' then
					ret = ret .. signal .. "*s" .. _G.TableToString(getmetatable(k)) .. "*e" .. "=" ..ToStringEx(v)
				else
					ret = ret .. signal .. k .. "=" .. ToStringEx(v)
				end
			end
		end

		i = i + 1
	end

	ret = ret .. "}"
	return ret
end

local function StringToTable(str)
	if not str or type(str) ~= "string" then
		return
	end

	local flag, result = xpcall(load("return " .. str), CommonUtil.XPCallLog)
	if flag then
		return result
	else
		return
	end
end

local Class = {}

function Class.SavePrivateChat( ChannelVM )
	if nil == ChannelVM  then
		return
	end

	local T = {}  

	local ChannelID = ChannelVM:GetChannelID()
	if nil == ChannelID or ChannelID <= 0 then
		return
	end

	local ListMsg = ChannelVM.BindableListMsg
	if ListMsg ~= nil then
		-- local CurMsgID =  ChannelVM:GetCurrentMsgID() or 0

		for _, ItemVM in ipairs(ListMsg:GetItems() or {}) do
			-- local MsgID = ItemVM.ID or 0
			-- if MsgID <= 0 or MsgID <= CurMsgID then -- 已读消息
				local Info = Class.GetPrivateMsgItemSaveInfo(ItemVM, ChannelID)
				if Info ~= nil then
					table.insert(T, Info)
				end
			-- end
		end
	end

	if #T < 0 then
		return
	end

	local Text = _G.TableToString(T)
	local Path = ChatUtil.GetPrivateLogFilePath(ChannelID)
	local File = io.open(Path, "wb")
	if File then
		if not File:write(Text) then
			File:close()
			os.remove(Path)

			return
		end

		File:flush()
		File:close()
	end	
end

function Class.GetPrivateMsgItemSaveInfo(MsgItemVM, ChannelID)
	if not MsgItemVM then
		return
	end

	local MsgChannelID = MsgItemVM.ChannelID
	if MsgChannelID ~= ChannelID or nil == MsgChannelID or MsgChannelID <= 0 then
		return
	end

	local MsgID = MsgItemVM.ID
	if not MsgID or MsgID <= 0 then
		return
	end

	local MsgData = MsgItemVM.MsgData or {}

	local ret = {
		MsgID,     			 -- ID
		MsgItemVM.Time or 0,     -- Time
		MsgItemVM.Sender or 0,   -- Sender 

		MsgData.SysMsgID or 0,   -- SysMsgID
		MsgData.Content or "",   -- Content
		MsgData.Facade or 0,     -- Facade
	}

	-- ParamList
	local ParamList = MsgData.ParamList
	if ParamList ~= nil and #ParamList > 0 then
		local List = {}

		for _, v in ipairs(ParamList) do
			table.insert(List, { 
				v.ID or 0,
				v.Type or 0,
				v.Param or "",
				v.Direct or false
			 })
		end

		table.insert(ret, List)

	else
		table.insert(ret, {})
	end

	return ret
end

local PRIVATE_MSG_KEYS = { 
	"ID", 
	"Time", 
	"Sender",  
	"SysMsgID",
	"Content",
	"Facade",
	"ParamList"
}

local EXTRA_PARAMS_KEYS = {
	"ID",
	"Type",
	"Param",
	"Direct"
}

function Class.ParseAllPrivateChats( )
	local Dir = ChatUtil.GetPrivateChatDir()
	local FileList = PathMgr.GetFileList(Dir, ".log", false)

	for _, v in pairs(FileList) do
		Class.ParsePrivateChat(v)
	end
end

function Class.ParsePrivateChat(Path)
	local ChannelID = tonumber(PathMgr.GetBaseFilename(Path, true))
	if nil == ChannelID then
		return
	end

	local File = io.open(Path, "rb")
	if not File then
		return
	end

	local Text = File:read("*a")
	if not Text or "" == Text then
		File:close()
		return
	end

	local T = StringToTable(Text)
	if not T then
		File:close()
		os.remove(Path)
		return
	end

	local ChatMsgList = {} 

	local Channel = ChatChannel.Person 
	local KeyNum = #PRIVATE_MSG_KEYS
	local ParamKeyNum = #EXTRA_PARAMS_KEYS 

	for _, v in ipairs(T) do
		if #v == KeyNum then
			local Temp = {}
			Temp.ID 	= v[1]
			Temp.Time 	= v[2]
			Temp.Sender = v[3]

			local Data = {}
			Data.SysMsgID 	= v[4]
			Data.Content 	= v[5]
			Data.Facade		= v[6]

			local List = v[7]
			if List ~= nil and #List > 0 then
				local ParamList = {}

				for _, e in ipairs(List) do
					if #e == ParamKeyNum then
						local extraParams = {}
						extraParams.ID 		= e[1]
						extraParams.Type 	= e[2]
						extraParams.Param 	= e[3]
						extraParams.Direct 	= e[4]

						table.insert(ParamList, extraParams)
					end
				end

				Data.ParamList = ParamList

			else
				Data.ParamList = {} 
			end

			Temp.Data = Data

			table.insert(ChatMsgList, Temp)
		end
	end

	if #ChatMsgList > 0 then
		table.sort(ChatMsgList, ServerMsgSortFunc)
		_G.ChatMgr:AddMsgListToBuffer(Channel, ChannelID, ChatMsgList)
	end

	File:close()
end

function Class.DeletePrivateChat(ChannelID)
	if nil == ChannelID then
		return
	end

	local Path = ChatUtil.GetPrivateLogFilePath(ChannelID)
	os.remove(Path)
end

function Class.LoadPrivateSessions()
	local Ret = {}

	local Path = ChatUtil.GetPrivateSessionFilePath()
	local File = io.open(Path, "r")
	if not File then
		return Ret
	end

	local Text = File:read("*a")
	if not Text or "" == Text then
		File:close()
		return Ret
	end

	local T = StringToTable(Text)
	if not T then
		File:close()
		os.remove(Path)
		return Ret
	end

	for _, v in ipairs(T) do
		if #v > 0 then
			table.insert(Ret, {RoleID = v[1], CreateTime = v[2]})
		end
	end

	File:close()
	return Ret
end

function Class.SavePrivateSessions()
	local VMList = ChatVM.PrivateItemVMList
	if not VMList then
		return
	end

	local T = { }

	for _, v in ipairs(VMList:GetItems() or {}) do
		local RoleID = v.RoleID 
		if RoleID ~= nil then
			table.insert(T, { RoleID, v.CreateTime })
		end
	end

	if #T < 0 then
		return
	end

	local Text = _G.TableToString(T)
	local Path = ChatUtil.GetPrivateSessionFilePath()
	local File = io.open(Path, "w")
	if File then
		if not File:write(Text) then
			File:close()
			os.remove(Path)

			return
		end

		File:flush()
		File:close()
	end
end

return Class