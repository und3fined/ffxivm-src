--
--Author: anypkvcai
--Date: 2022-09-19 14:47
--Description:
--

--全局Mgr需要在GameMgrConfig中配置, 具体说明参考下面wiki
--https://iwiki.woa.com/pages/viewpage.action?pageId=991668849

--避免滥用全局变量或全局函数。尽量用local定义变量，以免被误操作为全局变量，污染命名空间。
--Lua不加local修饰默认是global的全局变量，每次调用是通过传入的变量名作为key去全局表中获取。而local变量是直接通过Lua的堆栈访问，访问效率较高。
--全局变量也尽量在当前文件存为local变量, 直接访问全局变量时要以“_G”开头, 例如: _G.LSTR

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

--local ProtoCS = require("Protocol/ProtoCS")
--local EventID = require("Define/EventID")
--local UIViewID = require("Define/UIViewID")

--local LSTR
--local GameNetworkMgr
--local EventMgr
--local UIViewMgr

--local CS_CMD = ProtoCS.CS_CMD
--local SUB_MSG_ID = ProtoCS.CS_CHAT_CMD

---@class SampleMgr : MgrBase
local SampleMgr = LuaClass(MgrBase)

---OnInit
function SampleMgr:OnInit()
	--只初始化自身模块的数据，不能引用其他的同级模块
end

---OnBegin
function SampleMgr:OnBegin()
	--可以引用其他同级模块的数据，这里初始化的数据，同级模块的OnInit中是不能访问的（相当于模块的私有数据）
	--其他Mgr、全局对象 建议在OnBegin函数里初始化
	--LSTR = _G.LSTR
	--GameNetworkMgr = _G.GameNetworkMgr
	--EventMgr = _G.EventMgr
	--UIViewMgr = _G.UIViewMgr
end

function SampleMgr:OnEnd()
	--和OnBegin对应 在OnBegin中初始化的数据（相当于模块的私有数据），需要在这里清除
end

function SampleMgr:OnShutdown()
	--和OnInit对应 在OnInit中模块自身的数据，需要在这里清除
end

function SampleMgr:OnRegisterNetMsg()
	--示例代码先注释 以免影响正常逻辑
	--self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_MSG_PUSH, self.OnNetMsgChatMsgPush)
end

function SampleMgr:OnRegisterGameEvent()
	--示例代码先注释 以免影响正常逻辑
	--self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
end

---OnGameEventLoginRes
---@param Params any
function SampleMgr:OnGameEventLoginRes(Params)
	--C++侧发送的事件 Params类型为 FEventParams
	--Lua侧发送的事件 Params类型由SendEvent时指定
end

function SampleMgr:OnNetMsgChatMsgPush(MsgBody)
	--Lua用的协议更新了，要更新Content仓库
	--MsgBody类型为csproto.ChatsRsp
	local Msg = MsgBody.Push
	if nil == Msg then
		return
	end

	--网络协议proto文件定义在Designer/Protocol文件夹下，例如聊天协议路径：Designer/Protocol/csproto/cschatc.proto
	--MsgBody对应Designer/Protocol/csproto/packet.proto中cmd_res_name对应的结构

	--packet.proto中CS_CMD_CHATC相关定义
	--[[
		CS_CMD_CHATC = 39 [
		(cmd_req_name) = "csproto.ChatsReq",
		(cmd_res_name) = "csproto.ChatsRsp",
		(server_name) = "chat",
		(method_name) = "/rpc.fgame.chatc.Chat/Chat"
		];
	--]]

	--cschatc.proto中聊天回包定义
	--[[
		message ChatsRsp{
			CS_CHAT_CMD SubCmd = 1;
			oneof data
			{
				PushMessageRsp Push = 2;//发送消息
				PullMessageRsp Pull = 3;//拉取消息
			}
		 }
	-]]
end

---SendChatMsgPushMessage
---@param ChannelType number @CHANNEL_TYPE_DEFINE
---@param ChannelID number
---@param Content string
---@param Facade number
---@param ParamList table
function SampleMgr:SendChatMsgPushMessage(ChannelType, ChannelID, Content, Facade, ParamList)
	--[[
	local MsgID = CS_CMD.CS_CMD_CHATC
	local SubMsgID = SUB_MSG_ID.CS_CHAT_CMD_MSG_PUSH

	local Channel = { Type = ChannelType, ChannelID = ChannelID }
	local Msg = { Content = Content, Facade = Facade, ParamList = ParamList }

	--MsgBody类型为csproto.ChatsReq
	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.Push = { Channel = Channel, Msg = Msg }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
	--]]
end

--尽量都加上文档注释，调用时可以智能提示，也方便他人查看
---GetXXX
---@param ID number
---@return table
function SampleMgr:GetXXX(ID)
end

---InitTableViewData
function SampleMgr:InitTableViewData()
	local TableViewData = {}

	for Type = 1, 5 do
		local Num = 1
		local List = {}
		for i = 1, 100 do
			List[Num] = { ID = Type * 1000 + i, Name = string.format("Name_%d_%d", Type, i) }
			Num = Num + 1
		end

		TableViewData[Type] = List
	end

	self.TableViewData = TableViewData
end

---GetTableViewDataByType
---@param Type number
function SampleMgr:GetTableViewDataByType(Type)
	return self.TableViewData[Type]
end

--要返回当前类
return SampleMgr
