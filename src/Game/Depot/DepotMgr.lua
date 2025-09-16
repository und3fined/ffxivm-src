--
-- Author: anypkvcai
-- Date: 2022-03-02 15:55
-- Description:仓库
--


local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoCS = require("Protocol/ProtoCS")
local DepotVM = require("Game/Depot/DepotVM")
local EventID = require("Define/EventID")
local PworldCfg = require("TableCfg/PworldCfg")

local UpdateType = ProtoCS.update_type

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_DEPOT_CMD
local LSTR = _G.LSTR
local EventMgr = _G.EventMgr

local PWorldMgr
local GameNetworkMgr

---@class DepotMgr : MgrBase
local DepotMgr = LuaClass(MgrBase)

function DepotMgr:OnInit()

end

function DepotMgr:OnBegin()
	GameNetworkMgr = _G.GameNetworkMgr
	PWorldMgr = _G.PWorldMgr
end

function DepotMgr:OnEnd()
end

function DepotMgr:OnShutdown()

end

function DepotMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_DEPOT, SUB_MSG_ID.CS_DEPOT_CMD_SIMPLE_INFO, self.OnNetMsgDepotSimpleInfo)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_DEPOT, SUB_MSG_ID.CS_DEPOT_CMD_DETAIL_INFO, self.OnNetMsgDepotDetailInfo)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_DEPOT, SUB_MSG_ID.CS_DEPOT_CMD_TRANSFER, self.OnNetMsgDepotTransfer)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_DEPOT, SUB_MSG_ID.CS_DEPOT_CMD_MOVE, self.OnNetMsgDepotMove)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_DEPOT, SUB_MSG_ID.CS_DEPOT_CMD_RENAME, self.OnNetMsgDepotRename)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_DEPOT, SUB_MSG_ID.CS_DEPOT_CMD_ENLARGE, self.OnNetMsgDepotEnlarge)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_DEPOT, SUB_MSG_ID.CS_DEPOT_CMD_TRIM, self.OnNetMsgDepotTrim)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_DEPOT, SUB_MSG_ID.CS_DEPOT_CMD_UPDATE, self.OnNetMsgDepotUpdate)
end

function DepotMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)

end
function DepotMgr:OnGameEventLoginRes(Params)
	print("DepotMgr:OnGameEventLoginRes")

	self:SendMsgDepotSimpleInfo()
end

function DepotMgr:OnNetMsgDepotSimpleInfo(MsgBody)
	local Msg = MsgBody.Simple
	if nil == Msg then
		return
	end
	DepotVM.Enlarge = Msg.Enlarge
	for _, Depot in ipairs(Msg.DepotList) do
		Depot.DepotName = DepotMgr:GetDepotLocalLanguageName(Depot.DepotName, Depot.Index)
		self:SendMsgDepotDetailInfo(Depot.Index)
	end
	DepotVM:UpdateDepotPageVM(Msg.DepotList)
end

function DepotMgr:OnNetMsgDepotDetailInfo(MsgBody)
	local Msg = MsgBody.Detail
	if nil == Msg then
		return
	end

	DepotVM:SetDepotItems(Msg.Index, Msg.CurrentDepot)

	DepotVM:OnItemUpdate()

	EventMgr:SendEvent(EventID.DepotDataRefresh)
end

function DepotMgr:OnNetMsgDepotTransfer(MsgBody)

end

function DepotMgr:OnNetMsgDepotMove(MsgBody)

end

function DepotMgr:OnNetMsgDepotRename(MsgBody)
	local Msg = MsgBody.Rename
	if nil == Msg then
		return
	end

	local ViewModel = DepotVM:FindDepotPageVM(Msg.Index)
	if nil == ViewModel then
		return
	end
	local DepotName = DepotMgr:GetDepotLocalLanguageName(Msg.DepotName, Msg.Index)
	ViewModel:UpdateInfo(Msg.Type, DepotName)

	DepotVM:OnNameChanged(Msg.Index, Msg.Type, DepotName)

	MsgTipsUtil.ShowTips(LSTR(990058))
end

function DepotMgr:OnNetMsgDepotEnlarge(MsgBody)
	local Msg = MsgBody.Enlarge.Simple
	if nil == Msg then
		return
	end
	MsgTipsUtil.ShowTips(LSTR(990059))

	DepotVM.Enlarge = DepotVM.Enlarge + 1

	local DepotMsg = {}
	DepotMsg.ItemNum = Msg.ItemNum
	DepotMsg.DepotName = DepotMgr:GetDepotLocalLanguageName(Msg.DepotName, Msg.Index)
	DepotMsg.Index = Msg.Index
	DepotMsg.Type = Msg.Type
	DepotVM:DepotEnlarge(DepotMsg)
end

-- 服务器不能确定仓库语言版本，当仓库名为空时由前台确认仓库对应语言名字
function DepotMgr:GetDepotLocalLanguageName(ServerDepotName, DepotIndex)
	if string.isnilorempty(ServerDepotName) then

		local DepotName = LSTR(990036)
		DepotName = string.format("%s%s", DepotName, tostring(DepotIndex))
		return DepotName
	else
		return ServerDepotName
	end
end

function DepotMgr:OnNetMsgDepotTrim(MsgBody)
	local Msg = MsgBody.Trim
	if nil == Msg then
		return
	end

	if nil == Msg.CurrentDepot or #Msg.CurrentDepot <= 0 then
		return
	end

	DepotVM:SetDepotItems(Msg.Index, Msg.CurrentDepot)

	DepotVM:OnItemUpdate()

	MsgTipsUtil.ShowTips(LSTR(990060))
	
end

function DepotMgr:OnNetMsgDepotUpdate(MsgBody)
	local Msg = MsgBody.Update
	if nil == Msg then
		return
	end

	local UpdateList = Msg.UpdateList
	for _, v in ipairs(UpdateList) do
		self:OnDepotUpdate(v)
	end

	DepotVM:OnItemUpdate()

	EventMgr:SendEvent(EventID.DepotDataRefresh)
end

function DepotMgr:SendMsgDepotSimpleInfo()
	local MsgID = CS_CMD.CS_CMD_DEPOT
	local SubMsgID = SUB_MSG_ID.CS_DEPOT_CMD_SIMPLE_INFO

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function DepotMgr:SendMsgDepotDetailInfo(Index)
	local MsgID = CS_CMD.CS_CMD_DEPOT
	local SubMsgID = SUB_MSG_ID.CS_DEPOT_CMD_DETAIL_INFO

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.Detail = { Index = Index }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function DepotMgr:SendMsgDepotTransfer(Index, Pos, GID, Num)
	local MsgID = CS_CMD.CS_CMD_DEPOT
	local SubMsgID = SUB_MSG_ID.CS_DEPOT_CMD_TRANSFER

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.Transfer = { Index = Index, Pos = Pos, GID = GID, Num = Num}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function DepotMgr:SendMsgDepotMove(Index, SourcePos, TargetPos)
	local MsgID = CS_CMD.CS_CMD_DEPOT
	local SubMsgID = SUB_MSG_ID.CS_DEPOT_CMD_MOVE

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.Move = { Index = Index, SourcePos = SourcePos, TargetPos = TargetPos }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function DepotMgr:SendMsgDepotRename(Index, Type, DepotName)
	local MsgID = CS_CMD.CS_CMD_DEPOT
	local SubMsgID = SUB_MSG_ID.CS_DEPOT_CMD_RENAME

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.Rename = { Index = Index, Type = Type, DepotName = DepotName }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function DepotMgr:SendMsgDepotEnlarge(Type, DepotName)
	local MsgID = CS_CMD.CS_CMD_DEPOT
	local SubMsgID = SUB_MSG_ID.CS_DEPOT_CMD_ENLARGE

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.Enlarge = {DepotName = DepotName, Type = Type - 1} -- 后台索引从0开始

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function DepotMgr:SendMsgDepotTrim(Index)
	local MsgID = CS_CMD.CS_CMD_DEPOT
	local SubMsgID = SUB_MSG_ID.CS_DEPOT_CMD_TRIM

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.Trim = { Index = Index }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---OnDepotUpdate
---@param DepotUpdate DepotUpdate
function DepotMgr:OnDepotUpdate(DepotUpdate)
	if nil == DepotUpdate then
		return
	end

	if UpdateType.UPDATE_TYPE_ADD == DepotUpdate.Type or UpdateType.UPDATE_TYPE_RENEW == DepotUpdate.Type then
		DepotVM:SetDepotItem(DepotUpdate.Index, DepotUpdate.Pos, DepotUpdate.Item)
	elseif UpdateType.UPDATE_TYPE_DELETE == DepotUpdate.Type then
		DepotVM:RemoveDepotItem(DepotUpdate.Index, DepotUpdate.Pos)
	end
end

function DepotMgr:QueryDepotDetailInfo(Index)
	local ViewModel = DepotVM:FindDepotPageVM(Index)
	if nil == ViewModel then
		return
	end

	self:SendMsgDepotDetailInfo(Index)
end

function DepotMgr:CheckCanOpDepot(ShowTips)
	local CurrPWorldResID = PWorldMgr:GetCurrPWorldResID()

	local Value = PworldCfg:FindValue(CurrPWorldResID, "CanOpDepot")
	local CanOpDepot = nil ~= Value and Value > 0

	if not CanOpDepot and ShowTips then
		MsgTipsUtil.ShowTips(LSTR(990061))
	end

	return CanOpDepot
end

return DepotMgr