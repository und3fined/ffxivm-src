---
--- Author: anypkvcai
--- DateTime: 2021-11-22 19:41
--- Description:
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local RoleVM = require("Game/Role/RoleVM")
local TimeUtil = require("Utils/TimeUtil")
local EventID = require("Define/EventID")
local ItemDefine = require("Game/Item/ItemDefine")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")

local FLOG_WARNING = _G.FLOG_WARNING
local CS_CMD = ProtoCS.CS_CMD
local QueryRoleItemType = ItemDefine.QueryRoleItemType

-- 日志堆栈打印开关
-- local ENABLE_PRINT_TRACEBACK = false 

-- 角色信息缓存时间 单位：秒
local RoleInfoCacheTime = 10 * 60

-- 查询发包超时时间 弱网络等情况要重新发包 单位：秒
local QueryOverTime = 3

-- 一次发包最大查询数量
local QueryMaxNum = 30

-- 查询回调函数等待时间
local QueryWaitTime = 10

---@class RoleInfoMgr : MgrBase
local RoleInfoMgr = LuaClass(MgrBase)

---OnInit
---@field QueryPendingInfo table
---@field QueryCallbackInfo table
---@field RoleViewModels table<number,RoleVM>
function RoleInfoMgr:OnInit()
	self:Reset()
end

function RoleInfoMgr:OnBegin()
end

function RoleInfoMgr:OnEnd()
end

function RoleInfoMgr:OnShutdown()
	self:Reset()
end

function RoleInfoMgr:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 0.1, 0)
end

function RoleInfoMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.VisionLevelChange, 	self.OnOtherCharacterLevelChange)
	self:RegisterGameEvent(_G.EventID.OtherCharacterSwitch, self.OnOtherCharacterProfChange)
end

function RoleInfoMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUERY_ROLESIMPLE, 0, self.OnNetMsgQueryRoleSimpleByRoleIDs)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ROLE_INFO, 0, self.OnNetMsgQueryMajorInfo)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUERY_ROLE_ITEM_INFO, 0, self.OnNetMsgQueryRoleItemInfo) -- 查询角色物品信息
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_ENTER, self.OnVisionEnter) --进入视野同步
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_QUERY, self.OnVisionEnter) --进入视野同步
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_RENAME, ProtoCS.RenameCmd.RenameCmdRename, self.OnRenameRsp) -- 改名回包
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_RENAME, ProtoCS.RenameCmd.RenameCmdNotify, self.OnRenameNotify) -- 改名推送
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUERY_HISTORY_NAME, 0, self.OnNetMsgHistoryNameData)
end

function RoleInfoMgr:Reset()
	self.QueryPendingInfo = {} -- { RoleID, Time }
	self.QueryCallbackInfo = {}
	self.RoleViewModels = {}
	self.MajorHistoryName = nil
end

function RoleInfoMgr:OnTimer( )
	local CurTime = nil  
	local QueryCallbackInfo = self.QueryCallbackInfo
	if QueryCallbackInfo ~= nil and next(QueryCallbackInfo) ~= nil then
		CurTime = TimeUtil.GetServerTime()

		for i = #QueryCallbackInfo, 1, -1 do
			local Info = QueryCallbackInfo[i]
			if Info ~= nil then
				local Time = Info.Time
				if nil == Time then
					table.remove(QueryCallbackInfo, i)
					FLOG_WARNING("[RoleInfoMgr] querycallbackinfo, time is nil")

				elseif CurTime - Time > QueryWaitTime then -- 检测数据查询是否超时
					table.remove(QueryCallbackInfo, i)
					FLOG_WARNING("[RoleInfoMgr] querycallbackinfo, query role simple info time out, roleids: %s", table.concat(Info.RoleIDList or {}, ","))
				end
			end
		end
	end

	local QueryPendingInfo = self.QueryPendingInfo
	if QueryPendingInfo ~= nil and next(QueryPendingInfo) ~= nil then
		local SimpleQueryRoleIDList = {}
		CurTime = CurTime or TimeUtil.GetServerTime()

		for k, v in pairs(QueryPendingInfo) do
			local Time = v.Time
			if Time == 0 then
				table.insert(SimpleQueryRoleIDList, k)
				v.Time = CurTime

			elseif nil == Time then
				QueryPendingInfo[k] = nil
				FLOG_WARNING("[RoleInfoMgr] querypendinginfo, time is nil")

			elseif CurTime - Time > QueryWaitTime then -- 检测数据查询是否超时
				QueryPendingInfo[k] = nil
				FLOG_WARNING("[RoleInfoMgr] querypendinginfo, query role simple info time out, roleid: %s", k)
			end
		end

		if next(SimpleQueryRoleIDList) ~= nil then
			self:QueryRoleSimpleByRoleIDListInternal(SimpleQueryRoleIDList)
		end
	end
end

function RoleInfoMgr:OnVisionEnter(MsgBody)
	local Resp = MsgBody.Enter or MsgBody.Query or {}
	for _, VEntity in pairs(Resp.Entities or {}) do
		if VEntity.Role then
			local Level = VEntity.Role.Level
			local RoleID = VEntity.Role.RoleID
			local VM = self:FindRoleVM(RoleID)
			if VM then
				VM:SetPWorldLevel(Level)
			end
		end
	end
end

function RoleInfoMgr:UpdateNameByRoleID(RoleID, Name)
	if RoleID and Name then
		local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID)
		local VM = self:FindRoleVM(RoleID)
		if VM then
			VM:SetName(Name)
		end

		self:SetActorHudNameByEntityID(EntityID, Name)
		_G.EventMgr:SendEvent(EventID.ChaneNameNotify, RoleID, EntityID, Name)
	end
end

function RoleInfoMgr:SetActorHudNameByEntityID(EntityID, Name)
	if EntityID and Name then
		local AttrComponent = ActorUtil.GetActorAttributeComponent(EntityID)
		if AttrComponent and AttrComponent.ActorName ~= Name then
			AttrComponent.ActorName = Name
			_G.HUDMgr:UpdateNameInfo(EntityID)
		end

		local TargetCharactor = ActorUtil.GetActorByEntityID(EntityID)
		if not TargetCharactor then return end
			
		local TargetCompanion = TargetCharactor:GetCompanionComponent():GetCompanion()
		if TargetCompanion then
			local CompanionAttrComp = TargetCompanion:GetAttributeComponent()
			if CompanionAttrComp then
				local ActorVM = _G.HUDMgr:GetActorVM(CompanionAttrComp.EntityID)
				ActorVM:UpdateTitleInfo()
			end
		end
	end
end

function RoleInfoMgr:OnRenameRsp(MsgBody)
	if MsgBody.Rename then
		local Data = MsgBody.Rename
		if Data.Code and Data.Code ~= 0 then 
			_G.MsgTipsUtil.ShowTipsByID(Data.Code)
			EventMgr:SendEvent(EventID.RenameCardCheckRepeat, Data.Code)
			return
		end

		local NewName = Data.Name
		local MajorRoleID = MajorUtil.GetMajorRoleID()
		local OldName = MajorUtil.GetMajorName()
		local HistoryNameData = self.MajorHistoryName or {}
		for i, v in ipairs(HistoryNameData) do
			if NewName == v then
				table.remove(HistoryNameData, i)
				break
			end
		end

		table.insert(HistoryNameData, OldName)
		self.MajorHistoryName = HistoryNameData
		local ItemCfg = require("TableCfg/ItemCfg")
		local ResID = PersonInfoDefine.RenameCardID
		local Cfg = ItemCfg:FindCfgByKey(ResID)
		_G.BagMgr:SendMsgBagItemCDInfo(Cfg and Cfg.FreezeGroup or 0)
		_G.MsgTipsUtil.ShowTips(_G.LSTR(620104)) --修改成功
		self:UpdateNameByRoleID(MajorRoleID, NewName)
	end
end

function RoleInfoMgr:OnRenameNotify(MsgBody)
	local Data = MsgBody.Notify or {}
	if not next(Data) then return end
	local RoleID = Data.RoleID
	local Name = Data.Name
	if RoleID and Name then
		self:UpdateNameByRoleID(RoleID, Name)
	end
end

function RoleInfoMgr:OnNetMsgHistoryNameData(MsgBody)
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	if MsgBody.RoleID and MajorRoleID == MsgBody.RoleID then
		self.MajorHistoryName = MsgBody.Name or {}
	end

	_G.EventMgr:SendEvent(EventID.GetHistoryNameSuccess, MsgBody.Name or {})
end

function RoleInfoMgr:OnOtherCharacterLevelChange(Params)
	if nil == Params or nil == Params.ULongParam1 or nil == Params.ULongParam2 then
		return
	end

	local Reason = Params.ULongParam2
	if Reason == ProtoCS.LevelUpReason.LevelUpReasonProf then
		local EntityID = Params.ULongParam1
		local AttrCom = ActorUtil.GetActorAttributeComponent(EntityID)
		if nil ~= AttrCom then
			local Level = AttrCom.Level
			local RoleViewModel = ActorUtil.GetRoleVMByEntityID(EntityID)
			if RoleViewModel then
				RoleViewModel:SetPWorldLevel(Level)
			else
				_G.FLOG_ERROR("RoleInfoMgr:OnOtherCharacterLevelChange RoleVM = nil EntityID = " .. tostring(EntityID))
			end
		end
	end
end

function RoleInfoMgr:OnOtherCharacterProfChange(Params)
	if nil == Params or nil == Params.ULongParam1 or nil == Params.ULongParam2 then
		return
	end

	local EntityID = Params.ULongParam1
	local Prof = Params.IntParam1
	local Level = Params.IntParam2

	local RoleViewModel = ActorUtil.GetRoleVMByEntityID(EntityID)
	if RoleViewModel then
		RoleViewModel:SetLevel(Level)
		RoleViewModel:SetProf(Prof)
	end
end

---查询角色信息
---@param RoleIDList table @RoleID列表
---@private
function RoleInfoMgr:SendQueryRoleSimpleByRoleIDListReq(RoleIDList)
	local MsgID = CS_CMD.CS_CMD_QUERY_ROLESIMPLE
	local SubMsgID = 0
	local MsgBody = { RoleIDList = RoleIDList }

	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---OnNetMsgQueryRoleSimpleByRoleIDs
---@param MsgBody table @login.QueryRoleListByIDListRes
function RoleInfoMgr:OnNetMsgQueryRoleSimpleByRoleIDs(MsgBody)
	local RoleList = MsgBody.RoleList
	if nil == RoleList then
		return
	end

	for _, v in ipairs(RoleList) do
		local RoleID = v.RoleID
		self.QueryPendingInfo[RoleID] = nil

		local ViewModel = self:FindRoleVMInternal(RoleID)
		if nil == ViewModel then
			_G.FLOG_ERROR("RoleInfoMgr:OnNetMsgQueryRoleSimpleByRoleIDListRes ViewModel is nil, RoleID=%d", RoleID)

		else
			ViewModel:UpdateVM(v)
		end

		self:ProcessQueryCallback(RoleID)
	end
end

---查询主角实时角色信息
function RoleInfoMgr:SendQueryMajorInfo()
	self:SendQueryInfoByRoleID(0)
end

---查询他人实时角色信息
function RoleInfoMgr:SendQueryInfoByRoleID(RoleID)
	local MsgBody = {
		RoleID = RoleID
	}
	_G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_ROLE_INFO, 0, MsgBody)
end

---角色改名卡改名
function RoleInfoMgr:SendRenameReq(ItemGID, Name)
	local CMD = CS_CMD.CS_CMD_RENAME
	local SubCMD = ProtoCS.RenameCmd.RenameCmdRename
	local MsgBody = {
		Cmd = SubCMD,
		Rename = {
			ItemGID = ItemGID,
			Name = Name
		}
	}

	_G.GameNetworkMgr:SendMsg(CMD, SubCMD, MsgBody)
end

--- 历史名查询
function RoleInfoMgr:SendQueryHistoryNameReq(RoleID)
	local CMD = CS_CMD.CS_CMD_QUERY_HISTORY_NAME
	local MsgBody = {
		RoleID = RoleID
	}
	_G.GameNetworkMgr:SendMsg(CMD, 0, MsgBody)
end

--- 获取用户历史名
function RoleInfoMgr:GetPersonHistoryNameByRoleID(RoleID)
	if not RoleID then return end
		
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	if RoleID == MajorRoleID and self.MajorHistoryName then
		_G.EventMgr:SendEvent(EventID.GetHistoryNameSuccess, self.MajorHistoryName)
	else
		self:SendQueryHistoryNameReq(RoleID)
	end
end

---OnNetMsgQueryMajorInfo
---@param MsgBody table @simple.SimpleRsp 查询他人时只返回Scene,Online,TravelWorld 3个字段
function RoleInfoMgr:OnNetMsgQueryMajorInfo(MsgBody)
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	local IsMajorUpdate = MsgBody.RoleID == MajorRoleID
	if IsMajorUpdate then
		local ViewModel = self:FindRoleVMInternal(MajorRoleID)
		self.QueryPendingInfo[MajorRoleID] = nil
		if nil == ViewModel then
			_G.FLOG_ERROR("[RoleInfoMgr] OnNetMsgQueryMajorInfo ViewModel is nil, RoleID=%d", MsgBody.RoleID)

		else
			ViewModel:UpdateVMBySimple(MsgBody)
		end

		self:ProcessQueryCallback(MajorRoleID)
	else
		local OtherRoleVM = self:FindRoleVM(MsgBody.RoleID)
		if OtherRoleVM then
			OtherRoleVM:SetCrossZoneWorldID(MsgBody.TravelWorld)
			OtherRoleVM:SetIsOnline(MsgBody.Online)
		end
	end

	_G.EventMgr:SendEvent(EventID.QueryRoleInfo, MsgBody.RoleID)
end

function RoleInfoMgr:SendQueryRoleItemInfo(GID, RoleID, Data)
	local MsgID = CS_CMD.CS_CMD_QUERY_ROLE_ITEM_INFO
	local SubMsgID = 0

	local MsgBody = {
		RoleID = RoleID,
		GID = GID,
		Data = Data
	}

	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function RoleInfoMgr:OnNetMsgQueryRoleItemInfo(MsgBody)
	if nil == MsgBody.Data or #MsgBody.Data <= 0 then
		return
	end

	local Type = MsgBody.Data[1]
	if Type == QueryRoleItemType.ChatHyperlink then
		-- 聊天超链接
		_G.EventMgr:SendEvent(EventID.ChatQueryRoleItemInfo, MsgBody.Data[2], MsgBody.Item)
	end
end

---QueryRoleSimpleByRoleIDListInternal
---@param RoleIDList table
---@private
function RoleInfoMgr:QueryRoleSimpleByRoleIDListInternal(RoleIDList)
	--主角需要实时查询
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	if table.find_item(RoleIDList, MajorRoleID) then
		self:SendQueryMajorInfo()
	end

	local List = {}

	for _, v in ipairs(RoleIDList) do
		if nil == table.find_item(List, v) and v ~= MajorRoleID then
			table.insert(List, v)

			if #List >= QueryMaxNum then
				self:SendQueryRoleSimpleByRoleIDListReq(List)
				List = {}
			end
		end
	end

	if #List > 0 then
		self:SendQueryRoleSimpleByRoleIDListReq(List)
	end	
end

---QueryRoleSimple
---@param RoleID number
---@param Callback function
---@param Params any
---@param IsUseCache boolean @ 是否使用客户端缓存，False:主角部分信息(详见SimpleRsp)为实时信息，其他玩家信息为服务器缓存服信息）
function RoleInfoMgr:QueryRoleSimple(RoleID, Callback, Params, IsUseCache)
	local ViewModel, IsValid = self:FindRoleVM(RoleID, IsUseCache)

	if nil == Callback then
		return
	end

	if IsValid then
		Callback(Params, ViewModel)
	else
		local Info = { RoleIDList = { RoleID }, Callback = Callback, Time = TimeUtil.GetServerTime(), Params = Params, ViewModel = ViewModel }
		table.insert(self.QueryCallbackInfo, Info)
	end
end

---QueryRoleSimples
---@param RoleIDList table
---@param Callback function
---@param Params any
---@param IsUseCache boolean @ 是否使用客户端缓存，False:主角部分信息(详见SimpleRsp)为实时信息，其他玩家信息为服务器缓存服信息）
function RoleInfoMgr:QueryRoleSimples(RoleIDList, Callback, Params, IsUseCache)
	local List = {}

	for _, v in ipairs(RoleIDList) do
		if nil ~= v and 0 ~= v then
			local _, IsValid = self:FindRoleVM(v, IsUseCache)
			if not IsValid and nil == table.find_item(List, v) then
				table.insert(List, v)
			end
		end
	end

	if nil == Callback then
		return
	end

	if #List > 0 then
		local Info = { RoleIDList = List, Callback = Callback, Time = TimeUtil.GetServerTime(), Params = Params }
		table.insert(self.QueryCallbackInfo, Info)
	else
		Callback(Params)
	end
end

---ProcessQueryCallback
---@param RoleID number
---@private
function RoleInfoMgr:ProcessQueryCallback(RoleID)
	for i = #self.QueryCallbackInfo, 1, -1 do
		local Info = self.QueryCallbackInfo[i]
		table.remove_item(Info.RoleIDList, RoleID)
		if #Info.RoleIDList <= 0 then
			if nil ~= Info.Callback then
				Info.Callback(Info.Params, Info.ViewModel)
			end
			table.remove(self.QueryCallbackInfo, i)
		end
	end
end

---FindRoleVMInternal
---@param RoleID table
---@private
function RoleInfoMgr:FindRoleVMInternal(RoleID)
	return self.RoleViewModels[RoleID]
end

---FindRoleVM
---@param RoleID number
---@param IsUseCache boolean @是否使用缓存
---@return RoleVM @如果没有缓存也会返回一个数据为默认值的RoleVM
function RoleInfoMgr:FindRoleVM(RoleID, IsUseCache)
	if nil == RoleID or RoleID <= 0 then
        -- FLOG_WARNING(string.format("[RoleInfoMgr] FindRoleVM: failed to find data, RoleID=%s", tostring(RoleID)))

		-- if ENABLE_PRINT_TRACEBACK then
		-- 	local CommonUtil = require("Utils/CommonUtil")
		-- 	FLOG_WARNING(CommonUtil.GetLuaTraceback())
		-- end

		return
	end

	-- local Digits = #tostring(RoleID) 
	-- if Digits < 10 then
	-- 	-- TODO 临时定位bug 后面要删掉
	-- 	local Msg = string.format("[RoleInfoMgr] FindRoleVM: RoleID is Invalid, RoleID=%s", RoleID)
	-- 	FLOG_WARNING(Msg)
	-- 	local CommonUtil = require("Utils/CommonUtil")
	-- 	CommonUtil.ReportCustomError(Msg, debug.traceback(), debug.traceback(), true)
	-- end

	local ViewModel = self:FindRoleVMInternal(RoleID)
	if nil == ViewModel then
		ViewModel = RoleVM.New()
		ViewModel.RoleID = RoleID
		self.RoleViewModels[RoleID] = ViewModel
	end

	IsUseCache = IsUseCache ~= false and true or false

	local IsValid = true
	local Time = TimeUtil.GetServerTime()

	if not IsUseCache or (Time - ViewModel.CacheTime > RoleInfoCacheTime) then
		IsValid = false

		local Item = self.QueryPendingInfo[RoleID]
		if nil == Item or Time - Item.Time > QueryOverTime then
			self.QueryPendingInfo[RoleID] = { Time = 0 }
		end
	end

	return ViewModel, IsValid
end

--- 通过角色详情更新RoleVM
---@param RoleDetail common.RoleDetail 
function RoleInfoMgr:UpdateRoleVMByRoleDetail(RoleDetail)
	if nil == RoleDetail then
		return
	end

	local Simple = RoleDetail.Simple
	if nil == Simple then
		return
	end

	local RoleID = Simple.RoleID
	if nil == RoleID then
		return
	end

	local ViewModel = self:FindRoleVMInternal(RoleID)
	if nil == ViewModel then
		ViewModel = RoleVM.New()
		ViewModel.RoleID = RoleID
		self.RoleViewModels[RoleID] = ViewModel
	end

	ViewModel:UpdateVM(Simple)

	local MajorRoleID = MajorUtil.GetMajorRoleID()
	if RoleID == MajorRoleID then
		local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID)
		self:SetActorHudNameByEntityID(EntityID, Simple.Name)
	end
end

function RoleInfoMgr:ShowFormerNameTips(InTargetWidget, Alignment, NameData)
	local ViewID = _G.UIViewID.PersonFormerName
	local Params = {}
	Params.InTargetWidget = InTargetWidget
	Params.Alignment = Alignment
	Params.NameData = NameData

    _G.UIViewMgr:ShowView(ViewID, Params)
end

local function EmptyQueryCallcak()
end

function RoleInfoMgr:GetOnlineRolesAndUpdate(RoleIDs, bUpdate, Callback)
	local RetRoleIDs = {}
	for _, v in ipairs(RoleIDs) do
		local VM = self:FindRoleVMInternal(v)
		if  VM and VM.IsOnline then
			table.insert(RetRoleIDs, v)
		end
	end

	if  bUpdate and #RoleIDs > 0 then
		self:QueryRoleSimples(RoleIDs, Callback or EmptyQueryCallcak, nil, true)
	end

	return RetRoleIDs
end

return RoleInfoMgr
