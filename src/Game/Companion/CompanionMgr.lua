
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local BitUtil = require("Utils/BitUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local SaveKey = require("Define/SaveKey")
local ItemCfg = require("TableCfg/ItemCfg")
local FuncCfg = require("TableCfg/FuncCfg")
local CompanionCfg = require ("TableCfg/CompanionCfg")
local CompanionMergeGroupCfg = require ("TableCfg/CompanionMergeGroupCfg")
local CompanionGlobalCfg = require("TableCfg/CompanionGlobalCfg")
local CompanionVM = require ("Game/Companion/VM/CompanionVM")

local COMPANION_CMD = ProtoCS.CompanionCmd
local COMPANION_FLAG = ProtoCS.CompanionFlag
local COMPANION_AUTO = ProtoCS.CompanionAuto
local COMPANION_OPS = ProtoCS.CompanionOps

local GameNetworkMgr = nil
local EventMgr = nil
local MountMgr = nil
local PWorldMgr = nil
local ChatMgr = nil
local UIViewMgr = nil
local ModuleOpenMgr = nil
local CompanySealMgr = nil
local LoginMgr = nil
local LSTR = nil
local FLOG_ERROR = nil
local FLOG_INFO = nil
local CS_CMD = ProtoCS.CS_CMD
local EventID = _G.EventID
local UIViewID = _G.UIViewID

local CompanionMgr = LuaClass(MgrBase)

function CompanionMgr:OnInit()
	-- [分组ID] = 获取ID的函数
	self.MergeGroupFunctionMap = {
		[1] = self._GetCompanionFromRandom,
		[2] = self.GetCompanionFromGrandCompany,
	}

	self:ResetData()
end

function CompanionMgr:OnBegin()
    GameNetworkMgr = _G.GameNetworkMgr
    EventMgr = _G.EventMgr
    MountMgr = _G.MountMgr
    PWorldMgr = _G.PWorldMgr
    ChatMgr = _G.ChatMgr
    UIViewMgr = _G.UIViewMgr
    ModuleOpenMgr = _G.ModuleOpenMgr
    CompanySealMgr = _G.CompanySealMgr
	LoginMgr = _G.LoginMgr
    LSTR = _G.LSTR
    FLOG_ERROR = _G.FLOG_ERROR
    FLOG_INFO = _G.FLOG_INFO

    -- 快捷使用系统接入，判断此道具宠物是否已解锁过
	local function CheckItemUsed(ItemResID)
		local FindItemCfg = ItemCfg:FindCfgByKey(ItemResID)
		if FindItemCfg == nil then return false end
		local FindFuncCfg = FuncCfg:FindCfgByKey(FindItemCfg.UseFunc)
		if FindFuncCfg == nil then return false end

		return self:IsOwnCompanion(FindFuncCfg.Func[1].Value[1])
	end
    _G.BagMgr:RegisterItemUsedFun(ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_MINION, CheckItemUsed)

	self.bPauseShowCompanions = false
end

function CompanionMgr:OnEnd()
    GameNetworkMgr = nil
    EventMgr = nil
    MountMgr = nil
    PWorldMgr = nil
    ChatMgr = nil
    UIViewMgr = nil
    ModuleOpenMgr = nil
    CompanySealMgr = nil
	LoginMgr = nil
    LSTR = nil
    FLOG_ERROR = nil
    FLOG_INFO = nil
end

function CompanionMgr:OnShutdown()
	self:ResetData()
end

function CompanionMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.NetStateUpdate, self.OnActorNetStateChanged)
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnRoleLoginRes)

	self:RegisterGameEvent(EventID.CompanionCreate, self.OnCompanionCreate)
	self:RegisterGameEvent(EventID.CompanionPassiveRecalled, self.OnCompanionPassiveRecalled)

	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldMapEnter)
	self:RegisterGameEvent(EventID.PWorldReady, self.OnPWorldReady)
	self:RegisterGameEvent(EventID.VisionEnterShowPaused, self.OnVisionEnterShowPaused)
	self:RegisterGameEvent(EventID.VisionEnterShowResumed, self.OnVisionEnterShowResumed)
end

function CompanionMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMPANION, COMPANION_CMD.CompanionCmdQuery, self.OnNetRspCompanionCmdQuery)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMPANION, COMPANION_CMD.CompanionCmdCall, self.OnNetRspCompanionCmdCall)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMPANION, COMPANION_CMD.CompanionCmdOps, self.OnNetRspCompanionCmdOps)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMPANION, COMPANION_CMD.CompanionCmdActivateNotify, self.OnNetNotifyCompanionCmdActivate)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMPANION, COMPANION_CMD.CompanionCmdActionNotify, self.OnNetNotifyCompanionCmdAction)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMPANION, COMPANION_CMD.CompanionCmdCallNotify, self.OnNetNotifyCompanionCmdCall)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_COMPANION, COMPANION_CMD.CompanionCmdExpNotify, self.OnNetNotifyCompanionCmdExp)
end

function CompanionMgr:ResetData()
	self.LoginWaitAutoCalling = false
end

local function ShowMsgTips(tips)
	MsgTipsUtil.ShowTips(tips)
end

function CompanionMgr:HideAllCompanion(bHideAll)
	_G.FLOG_INFO("[CompanionMgr] HideAllCompanion: %s", tostring(bHideAll))

    local Companions = _G.UE.UActorManager.Get():GetAllCompanions()
    for _, Companion in pairs(Companions) do
        Companion:SetActorVisibility(not bHideAll, _G.UE.EHideReason.Common)
    end
end

function CompanionMgr:ShowLikeOpsMsg(CompanionID, IsLike)
	local CompanionCfg = self:GetCompanionExternalCfg(CompanionID)
	local FavouriteMaximumCfg = CompanionGlobalCfg:FindCfgByKey(ProtoRes.CompanionParamCfgID.CompanionParamCfgIDCompanionLikeTopCount)
	if CompanionCfg == nil or FavouriteMaximumCfg == nil then
		FLOG_ERROR("[CompanionMgr][ShowLikeOpsMsg] Cfg is nil")
		return
	end

	local TipsFormat = nil
	if IsLike then
		TipsFormat = LSTR(120001)
	else
		TipsFormat = LSTR(120002)
	end

	local Tips = string.format(TipsFormat, CompanionCfg.Name, CompanionVM:GetCompanionFavouriteCount(), FavouriteMaximumCfg.Value[1])
	ShowMsgTips(Tips)
end

-- region NetMsgReq

--- 设置上线自动召唤类型
---@param CallingType ProtoCS.CompanionAuto 枚举类型
function CompanionMgr:SetOnlineAutoCallingType(AutoCallingType)
	self:SendCompanionOpsMsg(COMPANION_OPS.CompanionOpsAuto, AutoCallingType)
end

function CompanionMgr:SendReadNewCompanionMsg(CompanionID)
	if CompanionVM:IsCompanionNew(CompanionID) then
		self:SendCompanionOpsMsg(COMPANION_OPS.CompanionOpsRead, CompanionID)
	end
end

function CompanionMgr:SendReadArchiveNewCompanionMsg(CompanionID)
	if CompanionVM:IsCompanionArchiveNew(CompanionID) then
		self:SendCompanionOpsMsg(COMPANION_OPS.CompanionOpsArchiveRead, CompanionID)
	end
end

--- 设置是否收藏宠物
---@param CompanionID uint32 宠物ID
---@param IsFavourite boolean 是否收藏
function CompanionMgr:SetCompanionFavourite(CompanionID, IsFavourite)
	if IsFavourite then	-- 添加收藏才需要判断
		local FavouriteMaximumCfg = CompanionGlobalCfg:FindCfgByKey(ProtoRes.CompanionParamCfgID.CompanionParamCfgIDCompanionLikeTopCount)
		if FavouriteMaximumCfg == nil then
			FLOG_ERROR("[CompanionMgr][SetCompanionFavourite] Cfg is nil")
			return
		end

		local FavouriteMaximum = FavouriteMaximumCfg.Value[1]
		if CompanionVM:GetCompanionFavouriteCount() >= FavouriteMaximum then
			ShowMsgTips(LSTR(120003))
			return
		end
	end

	local OpsType = IsFavourite and COMPANION_OPS.CompanionOpsLike or COMPANION_OPS.CompanionOpsUnlike
	self:SendCompanionOpsMsg(OpsType, CompanionID)
end

function CompanionMgr:SendCompanionOpsMsg(OperationType, Param)
	local CompanionOpsReq = {
		Op = OperationType,
		Param = Param
	}
	self:SendCompanionMsg(COMPANION_CMD.CompanionCmdOps, "Update", CompanionOpsReq)
end

--- 请求召唤宠物
---@param CompanionID uint32 宠物ID(0为召回)
function CompanionMgr:CallOutCompanion(CompanionID)
	-- 操作宠物前要先检查是否可操作
	if self:CanCallCompanion() == false then
		MsgTipsUtil.ShowTips(LSTR(120004))
		return
	end

	local CompanionCallReq = {
		ID = CompanionID
	}
	self:SendCompanionMsg(COMPANION_CMD.CompanionCmdCall, "Call", CompanionCallReq)
end

function CompanionMgr:CallBackCompanion()
	self:CallOutCompanion(0)
end

--- 请求宠物数据
---@param NoNeedCheckModule boolean 是否跳过模块检查，默认会检查
function CompanionMgr:SendCompanionQuery(NoNeedCheckModule)
	if not NoNeedCheckModule then
		local IsModuleOpen = ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDCompanion)
		if not IsModuleOpen then
			FLOG_INFO("[CompanionMgr]Module not open")
			self:ResetData()
			return
		end
	end

	self:SendCompanionMsg(COMPANION_CMD.CompanionCmdQuery)
end

function CompanionMgr:SendCompanionMsg(SubMsgID, DataKey, Data)
	local CsReq = {Cmd = SubMsgID}
    if DataKey ~= nil then
        CsReq[DataKey] = Data
    end
	GameNetworkMgr:SendMsg(CS_CMD.CS_CMD_COMPANION, SubMsgID, CsReq)
end

-- endregion NetMsgReq

function CompanionMgr:OnActorNetStateChanged(Params)
	if MajorUtil.IsMajor(Params.ULongParam1) and Params.IntParam1 == ProtoCommon.CommStatID.COMM_STAT_COMBAT then
		local bInCombat = Params.BoolParam1
		local Companions = _G.UE.UActorManager.Get():GetAllCompanions()
		for _, Companion in pairs(Companions) do
			Companion:SetCanSelect(not bInCombat)
		end
	end
end

function CompanionMgr:OnRoleLoginRes(Params)
	if Params == nil or Params.bReconnect == nil then return end

	local IsReconnect = Params.bReconnect

	if not IsReconnect then
		self.LoginWaitAutoCalling = true
		_G.UE.ACompanionCharacter.ResetStoredStates()
	end
end

function CompanionMgr:OnPWorldReady(Params)
	FLOG_INFO("[CompanionMgr]PWorld ready - Send query")
	self:SendCompanionQuery()
end

function CompanionMgr:OnCompanionCreate(Params)
	local CompanionEntityID = Params.ULongParam1
	local AttributeComponent = ActorUtil.GetActorAttributeComponent(CompanionEntityID)
	local OwnerEntityID = AttributeComponent.Owner
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	if OwnerEntityID and OwnerEntityID == MajorEntityID then
		-- 记录召唤出来的宠物EntityID，用于固定不动的宠物消失后取消召唤，平常用不上
		self.CallingOutCompanionEntityID = CompanionEntityID

		local CurLoginMapType = _G.LoginMapMgr:GetCurLoginMapType()
		if CurLoginMapType == _G.LoginMapType.HairCut or CurLoginMapType == _G.LoginMapType.Fantasia then
			_G.LoginMapMgr:HideOtherActors()
		end
	end
	local Companion = ActorUtil.GetActorByEntityID(CompanionEntityID)
	if nil ~= Companion then
		local bShowHUD = _G.UE.USaveMgr.GetInt(SaveKey.ShowCompanionNameplate, 1, true) == 1
		Companion:SetHUDVisibility(bShowHUD, _G.UE.EHideReason.Settings)
	end

	if self.bPauseShowCompanions then
		_G.UE.UActorManager.Get():HideActor(CompanionEntityID, true)
	end
end

function CompanionMgr:OnCompanionPassiveRecalled(Params)
	local CompanionEntityID = Params.ULongParam1
	if CompanionEntityID == self.CallingOutCompanionEntityID then
		-- 固定不动的宠物距离太远消失后被动取消召唤
		self:CallBackCompanion()
	end
end

function CompanionMgr:OnPWorldMapEnter(Params)
	-- 同地图切换要重新拉一次宠物数据
	if nil == Params or Params.bIsChangeMapLevel == true then
		return
	end

	FLOG_INFO("[CompanionMgr]PWorld map enter - Send query")
	self:SendCompanionQuery();
end

function CompanionMgr:OnVisionEnterShowPaused()
	self.bPauseShowCompanions = true
end

function CompanionMgr:OnVisionEnterShowResumed()
	self.bPauseShowCompanions = false
	self:HideAllCompanion(false)
end

--- 上线自动召唤触发
function CompanionMgr:OnlineAutoCallCompanion()
	local CallBack = nil
	-- 优先召唤本身召唤中的宠物
	if CompanionVM:GetCallingOutCompanion() ~= 0 then
		-- 本身在召唤中的宠物不需要请求召唤，可以直接召唤
		CallBack = function()
			local Actor = MajorUtil.GetMajor()
			local CompanionID = CompanionVM:GetCallingOutCompanion()
			self:CallOut(Actor, CompanionID)
		end
	elseif CompanionVM:GetOnlineAutoCalling() == true then -- 没有召唤中的宠物再判断自动召唤是否开启
		local CompanionID = 0
		local AutoCallingType = CompanionVM:GetOnlineAutoCallingType()
		if AutoCallingType == COMPANION_AUTO.CompanionAutoLast then
			-- 最近召唤，如果沒有召唤过宠物则召唤列表第一只宠物
			if CompanionVM:GetLastCallOutCompanion() ~= 0 then
				CompanionID = CompanionVM:GetLastCallOutCompanion()
			elseif CompanionVM:HasOwnCompanion() then
				CompanionID = CompanionVM:GetCompanionByIndex(1).ID
			end
		elseif AutoCallingType == COMPANION_AUTO.CompanionAutoLike then
			if CompanionVM:HasCompanionFavourite() then
				local FavouriteList = CompanionVM:GetCompanionFavouriteList()
				local Index = math.random(1, #FavouriteList)
				CompanionID = FavouriteList[Index]
			end
		elseif AutoCallingType == COMPANION_AUTO.CompanionAutoAll then
			if CompanionVM:HasOwnCompanion() then
				local OwnList = CompanionVM:GetOwnCompanionList()
				local Index = math.random(1, #OwnList)
				CompanionID = OwnList[Index]
			end
		end

		local IsInGroup, GroupID = self:IsCompanionInMergeGroup(CompanionID)
		if IsInGroup then
			-- 袖珍领袖需要先加入联军才能召唤
			if GroupID == 2 then
				local CompanySealInfo = CompanySealMgr:GetCompanySealInfo()
				if not CompanySealInfo or CompanySealInfo.GrandCompanyID == 0 then
					MsgTipsUtil.ShowTips(LSTR(120005))
					return
				end
			end
			CompanionID = self:GetCompanionFromGroup(GroupID)
		end

		CallBack = function()
			if CompanionID ~= 0 then
				self:CallOutCompanion(CompanionID)
			end
		end
	end

	if CallBack then
		local CallOutDelayTime = 3
		self:RegisterTimer(CallBack, CallOutDelayTime)
	end
end

function CompanionMgr:CallOut(Master, CompanionID)
	if nil ~= Master and nil ~= Master:GetCompanionComponent() then
		Master:GetCompanionComponent():CallOutCompanion(CompanionID, true)
	end
end

function CompanionMgr:CallBack(Master)
	if nil ~= Master and nil ~= Master:GetCompanionComponent() then
		Master:GetCompanionComponent():CallBackCompanion()
	end
end

function CompanionMgr:OnNetRspCompanionCmdQuery(MsgBody)
	if MsgBody == nil then return end

	local QueryRsp = MsgBody.Query

	-- 当前召唤宠物
	CompanionVM:SetCallingOutCompanion(QueryRsp.Out)
	-- 上次召唤宠物
	CompanionVM:SetLastCallOutCompanion(QueryRsp.LastCall)
	-- 自动召唤数据
	CompanionVM:SetOnlineAutoCallingType(QueryRsp.Auto)

	-- 先更新NewList和FavouriteList，ItemVM构造时需要这些数据
	CompanionVM:ClearCompanionNewMap()
	CompanionVM:ClearCompanionArchiveNewMap()
	CompanionVM:ClearCompanionFavouriteMap()
	CompanionVM:ClearCompanionOwnMap()
	for _, Companion in ipairs(QueryRsp.Companions) do
		-- 是否列表未读宠物，第1bit为0时是未读，为1时是已读
		if not BitUtil.IsBitSet(Companion.Flag, COMPANION_FLAG.CompanionFlagNew) then
			CompanionVM:AddCompanionNew(Companion.ID)
		end

		-- 是否收藏宠物，第2bit为0时是未收藏，为1时是收藏
		if BitUtil.IsBitSet(Companion.Flag, COMPANION_FLAG.CompanionFlagLike) then
			CompanionVM:AddCompanionFavourite(Companion.ID)
		end

		-- 是否图鉴未读宠物，第3bit为0时是未读，为1时是已读
		if not BitUtil.IsBitSet(Companion.Flag, COMPANION_FLAG.CompanionFlagArchiveNew) then
			CompanionVM:AddCompanionArchiveNew(Companion.ID)
		end

		-- 添加到Map方便查询
		CompanionVM:AddOwnCompanion(Companion.ID)
	end

	-- 最后更新CompanionList，ItemVM构造时才能读取上方数据
	local CompanionList = {}
	for _, Companion in ipairs(QueryRsp.Companions) do
		table.insert(CompanionList, Companion)
	end
	-- 排序函数
    local function SortFunction(Companion1, Companion2)
		local ID1 = Companion1.ID
		local ID2 = Companion2.ID

        local IsLike1 = CompanionVM:IsCompanionFavourite(ID1) and 1 or 0
        local IsLike2 = CompanionVM:IsCompanionFavourite(ID2) and 1 or 0

        local Cfg1 = CompanionCfg:FindCfgByKey(ID1)
        local Cfg2 = CompanionCfg:FindCfgByKey(ID2)

        -- 先排加了最爱，再排UI优先度，最后排ID
        if IsLike1 ~= IsLike2 then
            return IsLike1 > IsLike2
        elseif Cfg1.UISortPriority ~= Cfg2.UISortPriority then
            return Cfg1.UISortPriority < Cfg2.UISortPriority
        else
            return ID1 < ID2
        end
    end
    table.sort(CompanionList, SortFunction)
	CompanionVM:SetCompanionList(CompanionList)
	EventMgr:SendCppEvent(EventID.CompanionInfoQueried)

	if self.LoginWaitAutoCalling then
		FLOG_INFO("[CompanionMgr]Receive query - online auto call")
		self:ResetData()
		
		-- 收到回包后进行上线自动召唤
		self:OnlineAutoCallCompanion()
	end

	self:CheckCompanionSync()
end

function CompanionMgr:OnNetRspCompanionCmdCall(MsgBody)
	if MsgBody == nil then return end

	local CallRsp = MsgBody.Call

	local Actor = MajorUtil.GetMajor()

	if CallRsp.ID ~= 0 then
		if CompanionVM:GetCallingOutCompanion() ~= 0 then
			CompanionVM:SetLastCallOutCompanion(CompanionVM:GetCallingOutCompanion())
		end
		CompanionVM:SetCallingOutCompanion(CallRsp.ID)
		self:CallOut(Actor, CompanionVM:GetCallingOutCompanion())
	else
		CompanionVM:SetCallingOutCompanion(0)
		self:CallBack(Actor)
	end

	EventMgr:SendEvent(EventID.CompanionCallingOutUpdate, { ID = CallRsp.ID })
end

-- 重复的逻辑，抽象出一个函数调用更方便
local function DoVMAction(Action, ID, Param)
	local IsInGroup, MergeGroupID = CompanionMgr:IsCompanionInMergeGroup(ID)
	if not IsInGroup then
		Action(CompanionVM, ID, Param)
	else
		local CompanionList = CompanionMgr:GetCompanionListByGroupID(MergeGroupID)
		for _, CompanionID in ipairs(CompanionList) do
			Action(CompanionVM, CompanionID, Param)
		end
	end
end

function CompanionMgr:OnNetRspCompanionCmdOps(MsgBody)
	if MsgBody == nil then return end

	local OpsRsp = MsgBody.Update

	if OpsRsp.Op == COMPANION_OPS.CompanionOpsRead then
		DoVMAction(CompanionVM.RemoveCompanionNew, OpsRsp.Param)
		EventMgr:SendEvent(EventID.CompanionNewListUpdate)
	elseif OpsRsp.Op == COMPANION_OPS.CompanionOpsArchiveRead then
		DoVMAction(CompanionVM.RemoveCompanionArchiveNew, OpsRsp.Param)
		EventMgr:SendEvent(EventID.CompanionArchiveNewListUpdate)
	elseif OpsRsp.Op == COMPANION_OPS.CompanionOpsAuto then
		CompanionVM:SetOnlineAutoCallingType(OpsRsp.Param)
	elseif OpsRsp.Op == COMPANION_OPS.CompanionOpsLike then
		local CompanionID = OpsRsp.Param
		DoVMAction(CompanionVM.AddCompanionFavourite, CompanionID)
		self:ShowLikeOpsMsg(CompanionID, true)
		EventMgr:SendEvent(EventID.CompanionFavouriteListUpdate)
	elseif OpsRsp.Op == COMPANION_OPS.CompanionOpsUnlike then
		local CompanionID = OpsRsp.Param
		DoVMAction(CompanionVM.RemoveCompanionFavourite, CompanionID)
		self:ShowLikeOpsMsg(CompanionID, false)
		EventMgr:SendEvent(EventID.CompanionFavouriteListUpdate)

		-- 清空收藏宠物时判断一下上线自动召唤是否仍然适用
		if CompanionVM:HasCompanionFavourite() == false and CompanionVM:GetOnlineAutoCallingType() == COMPANION_AUTO.CompanionAutoLike then
			self:SetOnlineAutoCallingType(COMPANION_AUTO.CompanionAutoLast)
			ShowMsgTips(LSTR(120006))
		end
	end
end

function CompanionMgr:OnNetNotifyCompanionCmdActivate(MsgBody)
	if MsgBody == nil then return end

	local ActivateNotify = MsgBody.ActivateNotify
	if ActivateNotify == nil then return end

	local CompanionID = ActivateNotify.ID
	local Cfg = self:GetCompanionExternalCfg(CompanionID)
	if Cfg == nil then return end

	local Tips = string.format(LSTR(120007), Cfg.Name)
	ShowMsgTips(Tips)
	ChatMgr:AddSysChatMsg(Tips)

	-- 手动添加数据，用于背包刷新UI，其他情况尽量等下方请求数据回包
	DoVMAction(CompanionVM.AddOwnCompanion, CompanionID)

	-- 获得宠物后主动请求数据进行更新
	self:SendCompanionQuery(true)
end

function CompanionMgr:OnNetNotifyCompanionCmdAction(MsgBody)
	if MsgBody == nil then return end

	local ActionNotify = MsgBody.ActionNotify
	if ActionNotify == nil then return end

	local CompanionID = ActionNotify.CompanionID
	local ActionID = ActionNotify.ActionID
	DoVMAction(CompanionVM.AddCompanionAction, CompanionID, ActionID)

	-- 解锁动作后主动请求数据进行更新
	self:SendCompanionQuery(true)
end

function CompanionMgr:OnNetNotifyCompanionCmdCall(MsgBody)
	if MsgBody == nil then return end

	local CallNotify = MsgBody.CallNotify
	local EntityID = CallNotify.EntityID
	local SelfEntityID = MajorUtil.GetMajorEntityID()
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	local CompanionID = CallNotify.Out

	if EntityID == SelfEntityID then return end

	if CompanionID ~= 0 then
		self:CallOut(Actor, CompanionID)
	else
		self:CallBack(Actor)
	end
end

function CompanionMgr:OnNetNotifyCompanionCmdExp(MsgBody)
	if nil == MsgBody then
		return
	end

	local Master = ActorUtil.GetActorByEntityID(MsgBody.ExpNotify.EntityID)
	if nil == Master then
		return
	end

	local Companion = Master:GetCompanionComponent():GetCompanion()
	if nil == Companion then
		return
	end

	Companion:AddExp()
end

---	是否拥有某宠物
---@param CompanionID uint32 宠物ID
function CompanionMgr:IsOwnCompanion(CompanionID)
	return CompanionVM:IsOwnCompanion(CompanionID)
end

--- 获取某宠物已解锁动作
---@param CompanionID uint32 宠物ID
function CompanionMgr:GetCompanionAction(CompanionID)
	return CompanionVM:GetCompanionAction(CompanionID)
end

--- 宠物是否已解锁某动作
---@param CompanionID uint32 宠物ID
---@param ActionType ProtoRes.CompanionUnlockActionType 动作类型
---@return boolean 是否已解锁
function CompanionMgr:IsActionUnlock(CompanionID, ActionType)
	local ActionList = self:GetCompanionAction(CompanionID)
	if ActionList == nil then return false end

	for _, Action in ipairs(ActionList) do
		if Action == ActionType then
			return true
		end
	end

	return false
end

--- 检查是否可召唤宠物
---@return boolean 是否可召唤
function CompanionMgr:CanCallCompanion()
	local CanCall = true

	-- 非城镇和野外不能召唤
	if not PWorldMgr:CurrIsInMainCity() and not PWorldMgr:CurrIsInField() then
		CanCall = false
	end

	-- 坐骑状态无法召唤
	if MountMgr:IsInRide() then
		CanCall = false
	end

	-- 战斗或死亡无法召唤
	local MajorActor = MajorUtil.GetMajor()
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	local IsCombatState = ActorUtil.IsCombatState(MajorEntityID)
	local IsDeadtate = ActorUtil.IsDeadState(MajorEntityID)
	local IsSwimming = MajorActor ~= nil and MajorActor:IsSwimming() or false
	if IsCombatState or IsDeadtate or IsSwimming then
		CanCall = false
	end

	return CanCall
end

--- 打开宠物图鉴接口
---@param Params table UIViewParams
function CompanionMgr:OpenCompanionArchive(Params)
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_COMPANION_PREVIEW, true) then return end

	UIViewMgr:ShowView(UIViewID.CompanionArchivePanel, Params)
end

--- 宠物是否在分组里
---@param CompanionID uint32 宠物ID
---@return boolean 是否在分组
---@return number 分组ID
function CompanionMgr:IsCompanionInMergeGroup(CompanionID)
	local Cfg = CompanionCfg:FindCfgByKey(CompanionID)
	if Cfg == nil or Cfg.MergeGroupID == nil then return false, 0 end

	return Cfg.MergeGroupID ~= 0, Cfg.MergeGroupID
end

--- 获取某分组里的所有宠物ID
---@param GroupID number 分组ID
---@return table 宠物ID数组
function CompanionMgr:GetCompanionListByGroupID(GroupID)
	local Cfg = CompanionMergeGroupCfg:FindCfgByKey(GroupID)
	if Cfg == nil or Cfg.CompanionID == nil then return {} end

	return Cfg.CompanionID
end

--- 根据分组按特定逻辑获得宠物ID
---@return uint32 宠物ID
function CompanionMgr:GetCompanionFromGroup(GroupID)
	local GroupList = self:GetCompanionListByGroupID(GroupID)
	return self.MergeGroupFunctionMap[GroupID](self, GroupList)
end

--- 获取随机宠物ID
function CompanionMgr:_GetCompanionFromRandom(List)
	if List == nil or #List == 0 then return 0 end

	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
	local Index = math.random(#List)
	return List[Index]
end

--- 根据联军阵营获取宠物ID
function CompanionMgr:GetCompanionFromGrandCompany(List)
	if List == nil or #List == 0 then return 0 end

	local CompanyInfo = CompanySealMgr:GetCompanySealInfo()
	if not CompanyInfo then return 0 end

	local MajorCompany = CompanyInfo.GrandCompanyID

	for _, CompanionID in ipairs(List) do
		local Cfg = CompanionCfg:FindCfgByKey(CompanionID)
		if Cfg and Cfg.CompanyID == MajorCompany then
			return CompanionID
		end
	end

    return 0
end

--- 获取已拥有宠物列表
---@return table 宠物ID列表
function CompanionMgr:GetOwnedCompanions()
	return CompanionVM:GetCompanionList()
end

--- 获取上次召唤宠物
---@return uint 宠物ID
function CompanionMgr:GetLastCallOutCompanion()
	return CompanionVM:GetLastCallOutCompanion()
end

--- 获取宠物配置，如果是合并的宠物则返回合并的配置
---@param CompanionID uint32 宠物ID
function CompanionMgr:GetCompanionExternalCfg(CompanionID)
	local IsInGroup, GroupID = self:IsCompanionInMergeGroup(CompanionID)
	if not IsInGroup then
		return CompanionCfg:FindCfgByKey(CompanionID)
	else
		return CompanionMergeGroupCfg:FindCfgByKey(GroupID)
	end
end

--- 获取宠物的独立配置
---@param CompanionID uint32 宠物ID
function CompanionMgr:GetCompanionInternalCfg(CompanionID)
	return CompanionCfg:FindCfgByKey(CompanionID)
end

--- 获取召唤中的宠物ID，没有召唤则返回0
---@return uint 宠物ID
function CompanionMgr:GetCallingOutCompanion()
	return CompanionVM:GetCallingOutCompanion()
end

--- 宠物交互用，获取一个随机宠物
function CompanionMgr:GetCompanionFromRandom()
	local CompanionID = 0
	if CompanionVM:HasOwnCompanion() then
		local OwnList = CompanionVM:GetOwnCompanionList()
	
		-- 如果拥有不止一只则去掉正在召唤的宠物，只有一只就只能选这只，不需要去掉
		if CompanionVM:GetOwnCompanionCount() > 1 then
			TableTools.RemoveTableElement(OwnList, CompanionVM:GetCallingOutCompanion())
		end

		-- 未加入联军则去掉袖珍领袖
		local CompanySealInfo = CompanySealMgr:GetCompanySealInfo()
		if not CompanySealInfo or CompanySealInfo.GrandCompanyID == 0 then
			local CompanyIDList = self:GetCompanionListByGroupID(2)
			for _, ID in pairs(CompanyIDList) do
				TableTools.RemoveTableElement(OwnList, ID)
			end
		end

		CompanionID = self:_GetCompanionFromRandom(OwnList)

		local IsInGroup, GroupID = self:IsCompanionInMergeGroup(CompanionID)
		if IsInGroup then
			CompanionID = self:GetCompanionFromGroup(GroupID)
		end
	end
	return CompanionID
end

---@private
--- 防止弱网环境造成模型和数据不对应，判断是否要修正显示
function CompanionMgr:CheckCompanionSync()
	local Major = MajorUtil.GetMajor()
	if Major then
		local CompanionComponent = Major:GetCompanionComponent()
		if CompanionComponent then
			local CompanionIDOnActor = CompanionComponent:GetCompanionResID()
			local CompanionIDOnServer = CompanionVM:GetCallingOutCompanion()
			if CompanionIDOnActor ~= CompanionIDOnServer then
				FLOG_INFO(string.format("[CompanionMgr]Sync companion with true ID: %d", CompanionIDOnServer))
				if CompanionIDOnServer ~= 0 then
					self:CallOut(Major, CompanionIDOnServer)
				else
					self:CallBack(Major)
				end
			end
		end
	end
end

--GM打开宠物预览界面
function CompanionMgr:GMOpenPreviewCompanionView(CompanionId)
    UIViewMgr:ShowView(UIViewID.PreviewCompanionView, { CompanionId = CompanionId })
end

function CompanionMgr:SetHUDVisibilityOfAllCompanions(bVisible, Reason)
	local Companions = _G.UE.UActorManager.Get():GetAllCompanions()
	for _, Companion in pairs(Companions) do
		Companion:SetHUDVisibility(bVisible, Reason)
	end
end

--打开宠物界面(跳转表调用)
function CompanionMgr:OpenCompanionView()
	local SideBarDefine = require("Game/Common/Frame/Define/CommonSelectSideBarDefine")
	local CommSideBarUtil = require("Utils/CommSideBarUtil")
	CommSideBarUtil.ShowSideBarByType(SideBarDefine.PanelType.EasyToUse, SideBarDefine.EasyToUseTabType.Companion, {bOpen = true})
end

return CompanionMgr