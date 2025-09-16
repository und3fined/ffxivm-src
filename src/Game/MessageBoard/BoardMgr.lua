
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
--local ProtoBuff = require("Network/ProtoBuff")
--local GlobalCfg = require("TableCfg/GlobalCfg")
--local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")
--local ServerDirCfg = require("TableCfg/ServerDirCfg")
local BoardVM = require("Game/MessageBoard/VM/BoardVM")
local GameNetworkMgr
--local RoleInfoMgr = _G.RoleInfoMgr
local EventMgr

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.MESSAGE_BOARD_ID



---@class BoardMgr : MgrBase
local BoardMgr = LuaClass(MgrBase)

function BoardMgr:OnInit()
end

function BoardMgr:OnBegin()
	GameNetworkMgr = _G.GameNetworkMgr
	EventMgr = _G.EventMgr
end

function BoardMgr:OnEnd()
end

function BoardMgr:OnShutdown()

end

function BoardMgr:OnRegisterNetMsg()
	--self:RegisterGameNetMsg(CS_CMD.CS_CMD_LOGIN, 0, self.OnNetMsgLogin)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MESSAGE_BOARD, SUB_MSG_ID.MESSAGE_BOARD_ID_QUERY, self.OnNetMsgBoardQuery) -- 查询留言板消息的请求返回
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MESSAGE_BOARD, SUB_MSG_ID.MESSAGE_BOARD_ID_CREATE, self.OnNetMsgBoardCreate) -- 新增留言的请求返回
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MESSAGE_BOARD, SUB_MSG_ID.MESSAGE_BOARD_ID_DEL, self.OnNetMsgBoardDel) -- 删除留言的请求返回
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MESSAGE_BOARD, SUB_MSG_ID.MESSAGE_BOARD_ID_LIKE, self.OnNetMsgBoardLike) -- 点赞留言的请求返回
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MESSAGE_BOARD, SUB_MSG_ID.MESSAGE_BOARD_ID_UNLIKE, self.OnNetMsgBoardUnLike) -- 取消点赞的请求返回
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MESSAGE_BOARD, SUB_MSG_ID.MESSAGE_BOARD_ID_REPORT, self.OnNetMsgBoardReport) -- 举报的请求返回
	-- TODO 监听错误码ID
	--self:RegisterGameNetMsg(CS_CMD.CS_CMD_ERR, 0, self.OnNetMsgError)
end



function BoardMgr:OnRegisterGameEvent()

end

function BoardMgr:OnGameEventLoginRes(Params)

end

-- 协议文件参考 .proto
-----------------------------------------------Rsp start-----------------------------------------------
-- 查询返回的数据结构
-- message Post {
--    string Namespace = 1; // 留言类型_图鉴ID组成的一个字符串
--    uint64 PostID = 2;
--    string Content = 3;
--    bool IsAnoymour = 4;
--    int32 Likes = 5;
--    bool SelfLike = 6;
--    OtherInfo Other = 7;
--
-- }
function BoardMgr:OnNetMsgBoardQuery(MsgBody)
	BoardVM.BoardList = MsgBody.Query.Posts
	EventMgr:SendEvent(EventID.BoardRefreshList, true)
end

function BoardMgr:OnNetMsgBoardCreate(MsgBody)
	local BoardRsp = MsgBody.Create
	local Board = {Namespace = BoardRsp.Namespace, PostID = MajorUtil.GetMajorRoleID(), Other = BoardRsp.Other,
	              Content = BoardRsp.Content, IsAnoymour = BoardRsp.IsAnoymour, Likes = 0, SelfLike = false}
	table.insert(BoardVM.BoardList, 1, Board)
	EventMgr:SendEvent(EventID.BoardRefreshList, true)
end

function BoardMgr:OnNetMsgBoardDel(MsgBody)
	table.remove(BoardVM.BoardList, 1)
	EventMgr:SendEvent(EventID.BoardRefreshList, true)
end

function BoardMgr:OnNetMsgBoardLike(MsgBody)
	local BoardRsp = MsgBody.Like
	for _,v in ipairs(BoardVM.BoardList) do
        if v.Namespace == BoardRsp.Namespace and v.PostID == BoardRsp.PostID then
			v.Likes = v.Likes + 1
			v.SelfLike = true
        end
    end
	EventMgr:SendEvent(EventID.BoardRefreshList, false)
end

function BoardMgr:OnNetMsgBoardUnLike(MsgBody)
	local BoardRsp = MsgBody.Unlike
	for _,v in ipairs(BoardVM.BoardList) do
        if v.Namespace == BoardRsp.Namespace and v.PostID == BoardRsp.PostID then
			v.Likes = v.Likes - 1
			v.SelfLike = false
        end
    end
	EventMgr:SendEvent(EventID.BoardRefreshList, false)
end

function BoardMgr:OnNetMsgBoardReport(MsgBody)
	-- TODO 接入举报系统
end
-----------------------------------------------Rsp end-----------------------------------------------

-----------------------------------------------Req start-----------------------------------------------

--- 留言列表查询请求
--- @param ItemParams table 查询参数集{TypeID, ObjectID}
function BoardMgr:SendMsgBoardQuery(ItemParams)
	local SubMsgID = SUB_MSG_ID.MESSAGE_BOARD_ID_QUERY
	local MessageReq = { Namespace = string.format("%d_%d", ItemParams.TypeID, ItemParams.ObjectID)}
	self:SendCommonBoardData(SubMsgID, "Query", MessageReq)

end

--- 新增留言请求
--- @param ItemParams table 新增留言参数集{ServerID, TypeID, ObjectID, Content, IsAnoymour}
function BoardMgr:SendMsgBoardCreate(ItemParams)
	local SubMsgID = SUB_MSG_ID.MESSAGE_BOARD_ID_CREATE
	local OtherParam = { ZoneID = ItemParams.ServerID }
	local MessageReq = { Namespace = string.format("%d_%d", ItemParams.TypeID, ItemParams.ObjectID),
					   Content = ItemParams.Content,  IsAnoymour = ItemParams.IsAnoymour, Other = OtherParam }
	self:SendCommonBoardData(SubMsgID, "Create", MessageReq)
	-- 测试start
	--local Board1 = {Namespace = string.format("%d_%d", ItemParams.TypeID, ItemParams.ObjectID), PostID = 543232942453,
	--			  Content = "测试2",  IsAnoymour = true, Likes = 1, SelfLike = false, Other = OtherParam }
	--table.insert(BoardVM.BoardList, 1, Board1)
	--local Board2 = {Namespace = string.format("%d_%d", ItemParams.TypeID, ItemParams.ObjectID), PostID = 543232942455,
	--			  Content = "测试3",  IsAnoymour = true, Likes = 2, SelfLike = true, Other = OtherParam }
	--table.insert(BoardVM.BoardList, 1, Board2)
	--local Board = {Namespace = string.format("%d_%d", ItemParams.TypeID, ItemParams.ObjectID), PostID = MajorUtil.GetMajorRoleID(),
	--			  Content = ItemParams.Content,  IsAnoymour = ItemParams.IsAnoymour, Likes = 0, SelfLike = false, Other = OtherParam }
	--table.insert(BoardVM.BoardList, 1, Board)
	--EventMgr:SendEvent(EventID.BoardRefreshList)
    -- 测试end
end

--- 删除留言请求
--- @param ItemParams table 参数集{TypeID, ObjectID, PlayerID}
function BoardMgr:SendMsgBoardDel(ItemParams)
	local SubMsgID = SUB_MSG_ID.MESSAGE_BOARD_ID_DEL
	local MessageReq = { Namespace = string.format("%d_%d", ItemParams.TypeID, ItemParams.ObjectID) }
	self:SendCommonBoardData(SubMsgID, "Del", MessageReq)
end

--- 点赞留言请求
--- @param ItemParams table 参数集{TypeID, ObjectID, PlayerID}
function BoardMgr:SendMsgBoardLike(ItemParams)
	local SubMsgID = SUB_MSG_ID.MESSAGE_BOARD_ID_LIKE
	local MessageReq = { Namespace = string.format("%d_%d", ItemParams.TypeID, ItemParams.ObjectID), PostID = ItemParams.PlayerID}
	self:SendCommonBoardData(SubMsgID, "Like", MessageReq)
end

--- 取消点赞留言请求
--- @param ItemParams table 参数集{TypeID, ObjectID, PlayerID}
function BoardMgr:SendMsgBoardUnLike(ItemParams)
	local SubMsgID = SUB_MSG_ID.MESSAGE_BOARD_ID_UNLIKE
	local MessageReq = { Namespace = string.format("%d_%d", ItemParams.TypeID, ItemParams.ObjectID), PostID = ItemParams.PlayerID}
	self:SendCommonBoardData(SubMsgID, "Unlike", MessageReq)
end

--- 举报留言请求
--- @param ItemParams table 参数集{TypeID, ObjectID, PlayerID}
function BoardMgr:SendMsgBoardReport(ItemParams)
	local SubMsgID = SUB_MSG_ID.MESSAGE_BOARD_ID_REPORT
	local MessageReq = { Namespace = string.format("%d_%d", ItemParams.TypeID, ItemParams.ObjectID), PostID = ItemParams.PlayerID}
	self:SendCommonBoardData(SubMsgID, "Report", MessageReq)
end

--- 操作留言通用请求
function BoardMgr:SendCommonBoardData(SubMsgID, DataKey, DataReq)
	local MsgID = CS_CMD.CS_CMD_MESSAGE_BOARD
	local CsReq = {SubMsgID = SubMsgID}
    if DataKey ~= nil then
        CsReq[DataKey] = DataReq
    end
	-- TODO
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, CsReq)
end
-----------------------------------------------Req end-----------------------------------------------

--------------------------------------------- 不同模块的数据更新 -----------------------------------------
---

return BoardMgr