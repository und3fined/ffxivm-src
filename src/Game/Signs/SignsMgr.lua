--
--Author: ds_tianjiateng
--Date: 2024-03-15 15:16
--Description:
--
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local ProtoCS = require ("Protocol/ProtoCS")
local Json = require("Core/Json")
local TimeUtil = require("Utils/TimeUtil")
local MajorUtil = require("Utils/MajorUtil")
local ScenemarkCfg = require("TableCfg/ScenemarkCfg")
local ActorUtil = require("Utils/ActorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

local ClientSetupID = require("Game/ClientSetup/ClientSetupID")

local CS_CMD = ProtoCS.CS_CMD
local MarkingCmd = ProtoCS.MarkingCmd

--[[
--- 弃用
local function SignsMgr_Func_String_To_Table(Str)
	Str = Str:gsub('"', "'")
    Str = Str:gsub(":", "=")
    Str = Str:gsub("%[", "{")
    Str = Str:gsub("%]", "}")
	Str = Str:gsub("'", "")
    local Func, Err = load("return " .. Str)
    if not Func then
        error("Failed to load string: " .. Err)
    end

    local Success, Result = pcall(Func)
    if not Success then
        error("Failed to execute string: " .. Result)
    end

    return Result
end
]]

---@class SignsMgr : MgrBase
local SignsMgr = LuaClass(MgrBase)

function SignsMgr:OnInit()
	self.TargetList = {}
	self.SceneMarkersSaveList = {}
	self.IsEnableSceneMarker = false
	self.IsEnableTargetMarker = false
	self.IsEnableCountDown = false
	self.IsDuringCountDown = false
	self.IsMarkUsed = false
	self.TargetID = 0
	self.LastClickedCDTimeMS = 0
	self.IsDuringTargetMarking = false
	self.IsDuringSceneMarking = false

	--- 当前使用的场景标记方案
	self.CurrentUseSceneMarkers = {}
	self.CurrentUseSceneMarkerEffects = {}
	self.IsNeedPostEvent = true
	self.SceneMarkersMainPanelView = nil
	self.TargetSignsMainPanelIsShowing = false
	self.SceneMarkersMainPanelIsShowing = false

	self.IsCombatState = false
	self.IgnoreActors = {}
end

--- 读取存在服务器的json
function SignsMgr:OnGetServerSaveList()
	local RoleID = MajorUtil:GetMajorRoleID()
	for i = 1, 30 do
		local JsonStr = _G.ClientSetupMgr:GetSetupValue(RoleID, ClientSetupID.CSSceneMarkersSaveList + i - 1)
		local SceneMarkersSaveList = string.isnilorempty(JsonStr) and {} or Json.decode(JsonStr)
		-- local SceneMarkersSaveList = string.isnilorempty(JsonStr) and {} or SignsMgr_Func_String_To_Table(JsonStr)
		self.SceneMarkersSaveList[i] = SceneMarkersSaveList
	end
end

function SignsMgr:SetSceneMarkersMainPanelView(View)
	self.SceneMarkersMainPanelView = View
end

function SignsMgr:GetSceneMarkersMainPanelView()
	return self.SceneMarkersMainPanelView
end

function SignsMgr:OnBegin()
end

function SignsMgr:OnEnd()
end

function SignsMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKING, MarkingCmd.MarkingCmdInfo, 			self.OnTargetInfoNotify)		--- 标记变更推送
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKING, MarkingCmd.MarkingCmdTarget, 		self.OnTargetMarkingRsp)		--- 目标标记
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKING, MarkingCmd.MarkingCmdGround, 		self.OnSceneMarkingRsp)			--- 种下单个场景标记
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MARKING, MarkingCmd.MarkingCmdGroundClear, 	self.OnSceneMarkingClearRsp)	--- 删除单个场景标记(0全部)
end

function SignsMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.TargetChangeMajor, self.OnGameEventTargetChangeMajor)
	self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventPWorldExit)
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldEnter)
    self:RegisterGameEvent(EventID.TeamLeave, self.OnGameEventTeamLeave)
    self:RegisterGameEvent(EventID.TeamSceneMarkConfirmEvent, self.OnGameEventTeamSceneMarkConfirm)
	self:RegisterGameEvent(EventID.WorldPreLoad, self.OnGameEventWorldPreLoad)
	self:RegisterGameEvent(EventID.UpdateInDialogOrSeq,self.OnGameUpdateInDialogOrSeq)
	-- self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventPWorldExit) 	--- 清除标记状态
	self:RegisterGameEvent(EventID.NetStateUpdate, 				self.OnCombatStateUpdate)
end

function SignsMgr:OnCombatStateUpdate(Params)
	self.IsCombatState =  MajorUtil.IsMajor(Params.ULongParam1) and Params.IntParam1 == ProtoCommon.CommStatID.COMM_STAT_COMBAT
end

--------------------------------------------发送协议包相关代码Start----------------------------

function SignsMgr:SendTargetMarkingReq(TargetID, Index)
	local SubMsgID = MarkingCmd.MarkingCmdTarget
	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Target = {
		Index = Index,
		EntityID = TargetID
	}

    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_MARKING, SubMsgID, MsgBody)
end

--- 种下单个标记上报
function SignsMgr:SendSceneMarkingReq(Index, Position)
	local SubMsgID = MarkingCmd.MarkingCmdGround
	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Ground = {
		Index = Index,
		Pos = {X = Position.X, Y = Position.Y, Z = Position.Z}
	}

    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_MARKING, SubMsgID, MsgBody)
end

--- 批量种下标记上报
function SignsMgr:SendSceneMarkingBatchReq(ParamGrounds)
	local SubMsgID = MarkingCmd.MarkingCmdGround
	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Ground = {
		Grounds = ParamGrounds
	}

    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_MARKING, SubMsgID, MsgBody)
end

--- 删除单个标记上报(0)全部
function SignsMgr:SendSceneMarkingClearReq(Index)
	local SubMsgID = MarkingCmd.MarkingCmdGroundClear
	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.GroundClear = {
		Index = Index,
	}

    _G.GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_MARKING, SubMsgID, MsgBody)
end

--------------------------------------------发送协议包相关代码End----------------------------

--------------------------------------------协议回包相关代码Start----------------------------

--- 进队伍时下发的所有标记列表在这里，所以选择在这里存储数据
function SignsMgr:OnTargetInfoNotify(MsgBody)
	local Msg = MsgBody
	if nil == Msg then
		return
	end
	--- 所有目标标记列表
	local MsgTargets = Msg.Info.Targets
	self.IsDuringTargetMarking = MsgTargets ~= nil and #MsgTargets ~= 0
	local selfTargetList = self.TargetList
	for index, _ in pairs(selfTargetList) do
		local IsNeedSendEvent = true
		for i = 1, #MsgTargets do
			local EntityID = MsgTargets[i].EntityID
			if index == EntityID then
				IsNeedSendEvent = false
				break
			end
		end
		--- 后台下发新列表里没有原来的EntityID，证明原来EntityID的标记已被顶替
		if IsNeedSendEvent then
			_G.EventMgr:SendEvent(EventID.TeamTargetMarkStateChanged, {EntityID = index, IconID = 0})
			FLOG_INFO("SignsMgr:OnTargetInfoNotify  The original marker was replaced Event")
		end
	end
	_G.SignsMainVM:ClearAllItemUsed()
	FLOG_INFO("SignsMgr - ClearAllItemUsed !")
	selfTargetList = {}
	for i = 1, #MsgTargets do
		local EntityID = MsgTargets[i].EntityID
		local TempEntityID = ActorUtil.GetEntityIDByRoleID(EntityID)
		if TempEntityID == 0 then
			TempEntityID = EntityID
		end
		local Index = MsgTargets[i].Index
		if selfTargetList[EntityID] == nil or selfTargetList[EntityID] ~= Index then
			--- 目前列表没有当前EntityID或者相同EntityID的Index不相同，事件通知变更状态
			if self.TargetSignsMainPanelIsShowing then
				_G.EventMgr:SendEvent(EventID.TeamTargetMarkBtnUseStateChanged, Index)
			end
			_G.EventMgr:SendEvent(EventID.TeamTargetMarkStateChanged, {EntityID = TempEntityID, IconID = Index})
			FLOG_INFO("SignsMgr:OnTargetInfoNotify  Tag Changed Event         " .. Index)
		end
		selfTargetList[EntityID] = Index
	end
	self.TargetList = selfTargetList

	--- 所有场景标记列表
	-- _G.SceneMarkersMainVM:ClearAllItemUsed()
	local Grounds = Msg.Info.Grounds
	self.IsDuringSceneMarking = Grounds ~= nil and #Grounds ~= 0
    _G.EventMgr:SendEvent(EventID.TeamBtnStateChanged)
	if Grounds == nil or not next(Grounds) then
		_G.EventMgr:SendEvent(EventID.TeamSceneMarkRemoveEvent)
	end
	if self.CurrentUseSceneMarkers == nil then
		self.CurrentUseSceneMarkers = {}
	end
	self:OnSynSeverSigns(Grounds)
	if self.IsNeedPostEvent and _G.TeamMgr:IsInTeam() then
		if self.CurrentUseSceneMarkers ~= nil and self.CurrentUseSceneMarkers.Items ~= nil then
			local Items = self.CurrentUseSceneMarkers.Items
			for _, value in pairs(Items) do
				local param = {
					Index = value.Index,
					Pos = value.Position
				}
				self:OnTeamSceneMarkAdd(param)
			end
		end
		self.IsNeedPostEvent = false
	end
	self:CheckSceneMarkingState()
end

--- 同步服务器标记
function SignsMgr:OnSynSeverSigns(Grounds)
	FLOG_INFO("SignsMgr - OnSynSeverSigns !")		--- 临时日志
	if Grounds == nil then Grounds = {} end
	local CurrentUseSceneMarkers = self.CurrentUseSceneMarkers.Items or {}
	-- 构建索引映射
	local GroundsIndexMap = {}
	for _, ground in pairs(Grounds) do
		GroundsIndexMap[ground.Index] = ground
	end
	local toRemove = {}
	local toAdd = {}
	-- 遍历本地数据，进行同步
	for _, marker in pairs(CurrentUseSceneMarkers) do
		if not GroundsIndexMap[marker.Index] then
			-- 服务器上不存在，标记为待删除
			FLOG_INFO("SignsMgr - toRemove insert !")	--- 临时日志
			table.insert(toRemove, marker)
		else
			-- 服务器上存在，但可能需要更新Pos
			local Index = GroundsIndexMap[marker.Index].Index
			local Pos = GroundsIndexMap[marker.Index].Pos
			FLOG_INFO("SignsMgr - ChangePos !")	--- 临时日志
			self:OnSaveSceneMarkersItemPos(Index, Pos)
		end
	end
	-- 移除标记的数据
	for _, marker in pairs(toRemove) do
		for _, value in pairs(CurrentUseSceneMarkers) do
			if value.Index == marker.Index then
				FLOG_INFO("SignsMgr - Remove !")	--- 临时日志
				self:RemoveSceneMarkEffect(marker.Index)
				_G.SceneMarkersMainVM:OnSetItemUsedState(marker.Index, false)
				break
			end
		end
	end
	-- 遍历服务器数据，添加本地缺少的
	for _, ground in pairs(Grounds) do
		if not self:contains(CurrentUseSceneMarkers, ground, function(a, b) return a.Index == b.Index end) then
			-- 本地不存在，添加到待添加列表
			table.insert(toAdd, ground)
		end
	end
	-- 添加新数据
	for _, ground in pairs(toAdd) do
		if self.SceneMarkersMainPanelIsShowing then
			_G.SceneMarkersMainVM:OnSetItemUsedState(ground.Index, true)
		end
		FLOG_INFO("SignsMgr - Add !")	--- 临时日志
		self:OnSaveSceneMarkersItemPos(ground.Index, ground.Pos)
	end
end

-- 检查表中是否包含某个元素
function SignsMgr:contains(tbl, elem, key)
    for _, v in pairs(tbl) do
        if key(v, elem) then return true end
    end
    return false
end

function SignsMgr:OnTargetMarkingRsp(MsgBody)
	-- local Msg = MsgBody
	-- if nil == Msg then
	-- 	return
	-- end
	-- local Target = Msg.Target
	-- self.TargetList[Target.EntityID] = Target.Index
end

function SignsMgr:OnSceneMarkingRsp(MsgBody)
	-- local Msg = MsgBody
	-- if nil == Msg then
	-- 	return
	-- end
	-- local Ground = Msg.Ground
	-- if nil == Ground then
	-- 	return
	-- end
	-- local Grounds = Ground.Grounds
	-- if table.is_nil_empty(Grounds) then
	-- 	self:OnSaveSceneMarkersItemPos(Ground.Index, Ground.Pos)
	-- else
	-- 	self:OnSynSeverSigns(Grounds)
	-- end
end

function SignsMgr:OnSceneMarkingClearRsp(MsgBody)
	local Msg = MsgBody
	if nil == Msg then
		return
	end
	local GroundClear = Msg.GroundClear
	local Index = GroundClear.Index
	if self.CurrentUseSceneMarkers == nil then
		self.CurrentUseSceneMarkers = {}
	end
	if Index == 0 then
		for i = 1, 8 do
			self:RemoveSceneMarkEffect(i)
		end
	elseif self.CurrentUseSceneMarkers.Items ~= nil then
		self.CurrentUseSceneMarkers.Items[tostring(Index)] = nil
		self:RemoveSceneMarkEffect(Index)
	end
end
--------------------------------------------协议回包相关代码End----------------------------

--- 通过EntityID获取标记状态 没有标记时为0
---@return number
function SignsMgr:GetMarkingByEntityID(EntityID)
	--- 先用EntityID查  如果没有再用RoleID再查一遍
	local TargetSignState = self.TargetList[EntityID] or 0
	local RoleID = ActorUtil.GetRoleIDByEntityID(EntityID)
	if RoleID ~= 0 and TargetSignState == 0 then
		TargetSignState = self.TargetList[RoleID] or 0
	end
	return TargetSignState
end

--IsEnableSceneMarker 场景标记状态设置  开启/禁用
function SignsMgr:SetIsEnableSceneMarker(NewValue)
	self.IsEnableSceneMarker = NewValue
    _G.EventMgr:SendEvent(EventID.TeamBtnStateChanged)
end

function SignsMgr:GetIsEnableSceneMarker()
	return self.IsEnableSceneMarker
end

--IsEnableTargetMarker 场景标记状态设置  开启/禁用
function SignsMgr:SetIsEnableTargetMarker(NewValue)
	self.IsEnableTargetMarker = NewValue
    _G.EventMgr:SendEvent(EventID.TeamBtnStateChanged)
end

function SignsMgr:GetIsEnableTargetMarker()
	return self.IsEnableTargetMarker
end

--IsEnableCountDown 场景标记状态设置  开启/禁用
function SignsMgr:SetIsEnableCountDown(NewValue)
	self.IsEnableCountDown = NewValue
    _G.EventMgr:SendEvent(EventID.TeamBtnStateChanged)
end

function SignsMgr:GetIsEnableCountDown()
	return self.IsEnableCountDown
end

--------- 目标标记接口
function SignsMgr:OnGameEventTargetChangeMajor(TargetID)
	self.TargetID = TargetID
end

function SignsMgr:OnCheckIsUsedByID(ID)
	for _, value in pairs(self.TargetList) do
		if value == ID then
			return true
		end
	end
	return false
end
--------- 目标标记接口end

---记录Item坐标
---@param number Index
---@param Position _G.UE.FVector
function SignsMgr:OnSaveSceneMarkersItemPos(Index, Position)
	if self.CurrentUseSceneMarkers == nil then
		self.CurrentUseSceneMarkers = {}
	end
	if self.CurrentUseSceneMarkers.Items == nil then
		self.CurrentUseSceneMarkers.Items = {}
	end
	local TempItem = {}
	TempItem.Index = Index
	TempItem.Position = {
		X = Position.X,
		Y = Position.Y,
		Z = Position.Z
	}
	self.CurrentUseSceneMarkers.Items[tostring(Index)] = TempItem
	_G.SceneMarkersMainVM:OnSetItemUsedState(Index, true)
	self:OnTeamSceneMarkAdd({Index = TempItem.Index, Pos = _G.UE.FVector(TempItem.Position.X, TempItem.Position.Y, TempItem.Position.Z)})
	self:CheckSceneMarkingState()
end

--- 把当前方案保存到服务器
function SignsMgr:OnSaveSceneMarkersListByIndex(Index)
	if self.CurrentUseSceneMarkers == nil then
		self.SceneMarkersSaveList[Index] = nil
		--- 点删除按钮->关闭二次弹窗内选择保存会保存空表，视为删除当前保存Item
		FLOG_INFO("SignsMgr  SaveSceneMarkersList   CurrentUseSceneMarkers == nil   Delete Current Index Item")
	else
		self.SceneMarkersSaveList[Index] = {
			PworldID = _G.PWorldMgr:GetCurrPWorldResID(),
			UTCTime = TimeUtil.GetServerTime(),
			Items = _G.TableTools.deepcopy(self.CurrentUseSceneMarkers.Items),
		}
	end
	local SaveListNewTable = Json.encode(self.SceneMarkersSaveList[Index])
	-- local SaveListNewTable = _G.TableTools.table_to_string(self.SceneMarkersSaveList[Index])
	_G.ClientSetupMgr:SendSetReq(ClientSetupID.CSSceneMarkersSaveList + Index - 1, SaveListNewTable)
end

--- 清空单个存档
function SignsMgr:OnClearSaveListItem(Index)
	self.SceneMarkersSaveList[Index] = nil
	local SaveListNewTable = Json.encode(self.SceneMarkersSaveList[Index])
	-- local SaveListNewTable = _G.TableTools.table_to_string(self.SceneMarkersSaveList[Index])
	_G.ClientSetupMgr:SendSetReq(ClientSetupID.CSSceneMarkersSaveList + Index - 1, SaveListNewTable)
	_G.SceneMarkersMainVM:OnResetSaveItemByIndex(Index)
end

--- 读档
function SignsMgr:OnGetSeverDataByIndex(Index)
	return _G.TableTools.deepcopy(self.SceneMarkersSaveList[Index])
end

---Sequence中显隐SignMarker
function SignsMgr:OnGameUpdateInDialogOrSeq(Params)
	for k,v in pairs(self.CurrentUseSceneMarkerEffects) do
		local SignEffectActor = v
		if SignEffectActor ~= nil then
			SignEffectActor:ShowEffect(Params)
		end
	end
end

--- 刷新刷本（断线重连等）
function SignsMgr:OnGameEventWorldPreLoad(Params)
	if Params.bRelay then
		return
	end
	for key, _ in pairs(self.TargetList) do
        _G.EventMgr:SendEvent(EventID.TeamTargetMarkStateChanged, {EntityID = key, Index = 0})
        self.TargetList[key] = nil
    end
	if self.CurrentUseSceneMarkers == nil then
		return
	end

	local Items = self.CurrentUseSceneMarkers.Items
	if Items ~= nil then
		for i = 1, #Items do
			self:RemoveSceneMarkEffect(i)
		end
		for i = 1, #Items do
			local TempItem = self.CurrentUseSceneMarkers.Items[i]
			if TempItem ~= nil then
				local Params = {
					X = TempItem.X,
					Y = TempItem.Y,
					Z = TempItem.Z,
					Index = TempItem.Index,
				}
				self:OnTeamSceneMarkAdd(Params)
			end
		end
	end
	local Effects =  self.CurrentUseSceneMarkerEffects
	if Effects ~= nil then
		for Index, _ in pairs(Effects) do
			self:RemoveSceneMarkEffect(Index)
		end
	end
	self.CurrentUseSceneMarkerEffects = {}
end

--- 进入副本
function SignsMgr:OnGameEventPWorldEnter(Params)
	FLOG_INFO("SignsMgr - OnGameEventPWorldEnter ")
	if not Params.bReconnect then
		--- 清除客户端目标标记
		for key, _ in pairs(self.TargetList) do
			_G.EventMgr:SendEvent(EventID.TeamTargetMarkStateChanged, {EntityID = key, Index = 0})
			self.TargetList[key] = nil
		end
		self.TargetList = {}
		_G.SignsMainVM:ClearAllItemUsed()
		self.IsDuringTargetMarking = false
	end
	--- 刷新存档Item
	_G.SceneMarkersMainVM:OnUpdateSaveListEnable(Params.CurrMapResID)
end

--- 退出副本
function SignsMgr:OnGameEventPWorldExit()
	FLOG_INFO("SignsMgr - Clear Signs Data!")
	--[[
	if not Params.bReconnect then
		--- 清除客户端目标标记
		for key, _ in pairs(self.TargetList) do
			_G.EventMgr:SendEvent(EventID.TeamTargetMarkStateChanged, {EntityID = key, Index = 0})
			self.TargetList[key] = nil
		end
		self.TargetList = {}
		_G.SignsMainVM:ClearAllItemUsed()
		self.IsDuringTargetMarking = false
	end
	]]--
	--- 清除场景标记
	_G.SceneMarkersMainVM:ClearAllItemUsed()
	--- 刷新存档Item
	--_G.SceneMarkersMainVM:OnUpdateSaveListEnable(Params.CurrMapResID)
	if self.CurrentUseSceneMarkers == nil then
		return
	end
	for i = 1, 8 do
		self:RemoveSceneMarkEffect(i)
	end
	self.IsNeedPostEvent = true
	self.CurrentUseSceneMarkers = {}
	self.CurrentUseSceneMarkerEffects = {}
	self.IsDuringSceneMarking = false
end

--- 当前使用方案+items长度判断是否使用标记
function SignsMgr:CheckSceneMarkingState()
	if self.CurrentUseSceneMarkers == nil or self.CurrentUseSceneMarkers.Items == nil then
		self.IsDuringSceneMarking = false
		return
	end
	local Conds = self.CurrentUseSceneMarkers ~= nil  and self.CurrentUseSceneMarkers.Items ~= nil and not table.is_nil_empty(self.CurrentUseSceneMarkers.Items)
	if self.IsDuringSceneMarking ~= Conds then
		self.IsDuringSceneMarking = Conds
		_G.EventMgr:SendEvent(EventID.TeamBtnStateChanged)
	end
end

--- 当前使用方案
function SignsMgr:GetCurrentUseSceneMarkers()
	return self.CurrentUseSceneMarkers
end

function SignsMgr:GetTargetList()
	return self.TargetList
end

function SignsMgr:OnGameEventTeamLeave()
	self.IsNeedPostEvent = true
end

function SignsMgr:CreateEffect()
	local ActorResPath = "Blueprint'/Game/Assets/Effect/Particles/Sence/Common/SignMarker/BP_SignMarker.BP_SignMarker_C'"
	return _G.ObjectMgr:LoadClassSync(ActorResPath)
end

function SignsMgr:GetEffectResPath(ID)
	local ScenemarkCfg = ScenemarkCfg:FindCfgByKey(ID)
	if ScenemarkCfg ~= nil then
		return ScenemarkCfg.ResPath
	end

	return nil
end

function SignsMgr:OnTeamSceneMarkAdd(param)
	if param ~= nil then
		if self.CurrentUseSceneMarkerEffects[param.Index] ~= nil and param.Pos ~= nil then
			self.CurrentUseSceneMarkerEffects[param.Index]:SetActorPosition(_G.UE.FVector(param.Pos.X, param.Pos.Y, param.Pos.Z))
			_G.EventMgr:SendEvent(_G.EventID.TeamSceneMarkPosChangedEvent, {Index = param.Index, Pos = param.Pos})
		else
			local ModelClass = self:CreateEffect()

			if (ModelClass ~= nil and param.Pos ~= nil) then
				local WorldPosition = _G.UE.FVector()
				WorldPosition.X = param.Pos.X
				WorldPosition.Y = param.Pos.Y
				WorldPosition.Z = param.Pos.Z
				self.CurrentUseSceneMarkerEffects[param.Index] = _G.CommonUtil.SpawnActor(ModelClass, WorldPosition)
				self.CurrentUseSceneMarkerEffects[param.Index]:SetInitFlag()

				local ResPath = self:GetEffectResPath(param.Index)

				if ResPath ~= nil then
					self.CurrentUseSceneMarkerEffects[param.Index]:SetEffect(ResPath)
					_G.EventMgr:SendEvent(_G.EventID.TeamSceneMarkAddEvent, {Index = param.Index, Pos = param.Pos})
				end
			end
		end
	end
end

function SignsMgr:AddSceneMarkEffect(Index, Effect, Pos)
	if Index == nil then
		FLOG_ERROR(" SignsMgr:AddSceneMarkEffect   Index is nil")
		return
	end
	if self.CurrentUseSceneMarkerEffects[Index] ~= nil then
		_G.CommonUtil.DestroyActor(self.CurrentUseSceneMarkerEffects[Index])
		self.CurrentUseSceneMarkerEffects[Index] = nil
	end
	self.CurrentUseSceneMarkerEffects[Index] = Effect
	self.CurrentUseSceneMarkerEffects[Index]:SetActorPosition(Pos)
end

function SignsMgr:RemoveSceneMarkEffect(Index)
	if self.CurrentUseSceneMarkerEffects[Index] ~= nil then
		_G.CommonUtil.DestroyActor(self.CurrentUseSceneMarkerEffects[Index])
		self.CurrentUseSceneMarkerEffects[Index] = nil
		-- _G.EventMgr:SendEvent(EventID.TeamTargetMarkBtnUseStateChanged, Index)
		if nil ~= self.CurrentUseSceneMarkers and nil ~= self.CurrentUseSceneMarkers.Items then
			self.CurrentUseSceneMarkers.Items[tostring(Index)] = nil
		end
		_G.EventMgr:SendEvent(EventID.TeamSceneMarkRemoveEvent, Index)
	end
end

function SignsMgr:SetEffectPosition(Index, Pos)
	if self.CurrentUseSceneMarkerEffects[Index] ~= nil then
		self.CurrentUseSceneMarkerEffects[Index]:SetActorPosition(Pos)
	end
end

function SignsMgr:OnGameEventTeamSceneMarkConfirm(Params)
	local Index = Params.Index
	local Position = Params.Position
	local Pos = {
		X = math.floor(Position.X),
		Y = math.floor(Position.Y),
		Z = math.floor(Position.Z),
	}
	self:SendSceneMarkingReq(Params.Index, Pos)
	_G.SceneMarkersMainVM:OnSetItemUsedState(Index, true)
end

function SignsMgr:ShowTargetSignsPanel()
	self.TargetSignsMainPanelIsShowing = true
	self.SceneMarkersMainPanelIsShowing = false
	_G.UIViewMgr:ShowView(_G.UIViewID.TeamSignsMainPanel)
	_G.InteractiveMgr:HideMainPanel()
end

function SignsMgr:ShowSceneMarkersPanel()
	self.TargetSignsMainPanelIsShowing = false
	self.SceneMarkersMainPanelIsShowing = true
	_G.UIViewMgr:ShowView(_G.UIViewID.SceneMarkersMainPanel)
	_G.InteractiveMgr:HideMainPanel()
end

function SignsMgr:ClearCurrentSceneMarkerData()
	self.CurrentUseSceneMarkers = {}
end

function SignsMgr:GetIgnoreActors()
	return self.IgnoreActors
end

function SignsMgr:AddIgnoreActor(Actor)
	table.insert(self.IgnoreActors,Actor)
end

function SignsMgr:ClearIgnoreActors()
	self.IgnoreActors = {}
end

return SignsMgr