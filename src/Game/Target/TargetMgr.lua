--
-- Author: anypkvcai
-- Date: 2020-12-10 10:17:10
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local AudioUtil = require("Utils/AudioUtil")
local EffectUtil = require("Utils/EffectUtil")
local CommonUtil = require("Utils/CommonUtil")
local CommonDefine = require("Define/CommonDefine")
local EnmityCfg = require("TableCfg/EnmityCfg")
local MonsterCfg = require("TableCfg/MonsterCfg")

local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local EventMgr = require("Event/EventMgr")
local ObjectMgr = require("Object/ObjectMgr")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")
local ActorUIUtil = require("Utils/ActorUIUtil")

local GetEnmityListReason = CommonDefine.GetEnmityListReason
local entity_type = ProtoRes.entity_type
local CS_CMD = ProtoCS.CS_CMD
local CS_TARGET_CMD = ProtoCS.CS_TARGET_CMD
local EActorType = _G.UE.EActorType
local FLOG_ERROR = _G.FLOG_ERROR

local HardLockEffectZOrder <const> = -1

local TargetLineEffectPathA = "VfxBlueprint'/Game/BluePrint/Skill/SkillEffect/BP_Common_HatredArrow_1.BP_Common_HatredArrow_1_C'"
local TargetLineEffectPathB = "VfxBlueprint'/Game/BluePrint/Skill/SkillEffect/BP_Common_HatredArrow_2.BP_Common_HatredArrow_2_C'"
local SoundEvent_Select    = "/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_click_tape_1.Play_UI_click_tape_1"
local SoundEvent_Miss      = "/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_click_miss.Play_UI_click_miss"
local SoundEvent_TargetLine = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Mini_Cactpot/Play_SE_UI_gumbit.Play_SE_UI_gumbit'"

---@class TargetMgr : MgrBase
local TargetMgr = LuaClass(MgrBase)

function TargetMgr:OnInit()
	-- 仇恨相关
	self.FirstTargetOfMonsters = {} -- 视野内怪物的一仇目标
	self.FirstTargetOfMajor = nil
	self.MajorEnmityCount = 0

	-- 主目标相关
	self.MajorSelectedTarget = 0 	-- 主角选中的目标，用于本地逻辑
	self.MajorMainTarget = 0 		-- 主角的主目标主要用于向其他玩家同步
	self.MainTargetMapping = {} 	-- 保存视野内玩家和怪物的主目标，对于玩家，其主目标即其选中的目标，对于怪物，其主目标由关卡配置，需要与一仇相区分

	-- 目标线相关
	self.TargetLineMapping = {}  	-- 怪物有时会临时攻击非目标对象，故需要单独管理怪物的目标线

	-- 强锁效果相关
	self.HardLockEffectBitMask = 0
end

function TargetMgr:OnBegin()
	local Hold = _G.UE.EObjectGC.Hold
	ObjectMgr:PreLoadObject(SoundEvent_Select, Hold)
	ObjectMgr:PreLoadObject(SoundEvent_Miss, Hold)
	self:InitHardLockEffectView()
end

function TargetMgr:OnEnd()
	if nil ~= self.HardLockEffectView then
		self.HardLockEffectView:RemoveFromViewport()
		self.HardLockEffectView = nil
	end
end

function TargetMgr:OnShutdown()

end

function TargetMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TARGET, CS_TARGET_CMD.CS_TARGET_CMD_SET, self.OnNetMsgTargetSetRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TARGET, CS_TARGET_CMD.CS_TARGET_CMD_GET, self.OnNetMsgTargetGetRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TARGET, CS_TARGET_CMD.CS_TARGET_CMD_NOTIFY, self.OnNetMsgTargetGetRsp)

	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_ENTER, self.OnNetMsgVisionEnter) --进入视野
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_QUERY, self.OnNetMsgVisionEnter) --进入视野同步
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_LEAVE, self.OnNetMsgVisionLeave) --离开视野
end

function TargetMgr:OnRegisterGameEvent()
	-- 本地玩家选中（取消选中）目标，由Selected相关模块维护
	self:RegisterGameEvent(EventID.SelectTarget, self.OnGameEventSelectTarget)
	self:RegisterGameEvent(EventID.UnSelectTarget, self.OnGameEventUnSelectTarget)

	-- 获取仇恨列表
	self:RegisterGameEvent(EventID.CombatGetEnmityList, self.OnGameEventCombatGetEnmityList)
    self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)

	-- 切图清理所有目标
	self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)

	-- 技能目标变更
	self:RegisterGameEvent(EventID.Attr_Change_Target, self.OnGameEventAttrTargetChanged)

	-- 切图重新把强锁UI显示出来
	self:RegisterGameEvent(EventID.WorldPostLoad, self.OnWorldPostLoad)

	-- self:RegisterGameEvent(EventID.PreEnterInteractionRange, self.OnGameEventPreEnterInteractionRange)
end

---OnNetMsgVisionEnter 进入玩家视野，订阅仇恨列表，拉取主目标
---@param MsgBody table                @TargetRsp
function TargetMgr:OnNetMsgVisionEnter(MsgBody)
	local VisionRsp = MsgBody.Enter or MsgBody.Query
	local Entities = (VisionRsp or {}).Entities
	if nil == Entities then return end

	local EntitiesToSubscribe = {}

	for _, Entity in ipairs(Entities) do
		local EntityID = Entity.ID
		-- loiafeng：暂时只考虑Monster类型的仇恨，别的类型有需要再加
		if Entity.Type == entity_type.ENTITY_TYPE_BNPC then
			local ResID = (Entity.BNpc or {}).ResID or 0
			local Cfg = MonsterCfg:FindCfgByKey(ResID)
			if Cfg and Cfg.BeAttackedNoEnmity ~= 1 then
				table.insert(EntitiesToSubscribe, EntityID)
				-- FLOG_INFO("TargetMgr.OnNetMsgVisionEnter(): Subscribe %d(%s).", EntityID, tostring(ActorUtil.GetActorName(EntityID)))
			end
		end

		self:UpdateActorMainTarget(EntityID, Entity.Target)
	end

	-- FLOG_INFO("TargetMgr.OnNetMsgVisionEnter(): Subscribe %d Entities.", #EntitiesToSubscribe)
	if #EntitiesToSubscribe > 0 then
		_G.CombatMgr:SubscribeEnmityListReq(EntitiesToSubscribe)

		for _, EntityID in ipairs(EntitiesToSubscribe) do
			-- 手动拉取一次仇恨
			_G.CombatMgr:SendGetEnmityListReq(EntityID, 0, GetEnmityListReason.Target)
		end
	end
end

---OnNetMsgVisionLeave 离开玩家视野，取消订阅仇恨列表
---@param MsgBody table                @TargetRsp
function TargetMgr:OnNetMsgVisionLeave(MsgBody)
	local Leave = MsgBody.Leave
	local Entities = (Leave or {}).Entities
	if nil == Entities then return end

	local EntitiesToCancel = {}
	for _, EntityID in ipairs(Entities) do
		table.insert(EntitiesToCancel,EntityID)
		-- _G.FLOG_INFO("TargetMgr.OnNetMsgVisionLeave(): Cancel Subscribe %d.", EntityID)
		-- FLOG_INFO("TargetMgr.OnNetMsgVisionLeave(): Cancel Subscribe %d(%s).", EntityID, tostring(ActorUtil.GetActorName(EntityID)))
	end
	-- FLOG_INFO("TargetMgr.OnNetMsgVisionLeave(): Cancel Subscribe %d Entities.", #EntitiesToCancel)

	if #EntitiesToCancel > 0 then
		_G.CombatMgr:CancelSubscribeEnmityListReq(EntitiesToCancel)
	end
end

---OnGameEventSelectTarget
---@param Params FEventParams
function TargetMgr:OnGameEventSelectTarget(Params)
	if nil ~= Params then
		self:SetMajorTarget(Params.ULongParam1)
	end
end

---OnGameEventUnSelectTarget
---@param Params FEventParams
function TargetMgr:OnGameEventUnSelectTarget(Params)
	self:SetMajorTarget(0)
end

function TargetMgr:OnGameEventCombatGetEnmityList(Params)
	local EntityID = Params.EntityID

	-- 主角仇恨列表
	if EntityID == MajorUtil.GetMajorEntityID() then
		-- 模糊判断
		if self.MajorEnmityCount ~= #Params.List or (#Params.List > 0 and self.FirstTargetOfMajor ~= Params.List[1].ID) then
			self.MajorEnmityCount = #Params.List
			self.FirstTargetOfMajor = #Params.List > 0 and Params.List[1].ID or nil
			local EventParams = EventMgr:GetEventParams()
			EventParams.ULongParam1 = self.FirstTargetOfMajor or 0
			EventParams.IntParam1 = #Params.List
			EventMgr:SendCppEvent(EventID.MajorEnmityListUpdate, EventParams)
		end
		return
	end

	local NewFirstTarget = (Params.List or {})[1]
	local NewFirstTargetID = (NewFirstTarget or {}).ID or 0
	local OldFirstTargetID = self.FirstTargetOfMonsters[EntityID] or 0

	if OldFirstTargetID == NewFirstTargetID then return end

	self.FirstTargetOfMonsters[EntityID] = (NewFirstTargetID > 0) and NewFirstTargetID or nil

	-- _G.FLOG_INFO("TargetMgr.OnGameEventCombatGetEnmityList(): GetEnmityList of %s(%d), which has %d enmities. The FirstTarget is %s(%d).",
	--	ActorUtil.GetActorName(Params.EntityID), Params.EntityID, #(Params.List or {}), ActorUtil.GetActorName(NewFirstTargetID), NewFirstTargetID)

	-- 主目标未设置的情况下，怪物目标由仇恨决定
	if nil == self.MainTargetMapping[EntityID] then
		self.SendTargetChangeActorEvent(EntityID, NewFirstTargetID, OldFirstTargetID == 0 or NewFirstTargetID == 0)
		self:UpdateTargetLine(EntityID, NewFirstTargetID)
	end
end

function TargetMgr:OnGameEventPWorldExit(Params)
	self.FirstTargetOfMonsters = {}
	self.MainTargetMapping = {}
	self.SubscribeEnmityListCache = {}
	self.TargetLineMapping = {}
	self.FirstTargetOfMajor = nil
	self.MajorEnmityCount = 0
	self:SetMajorTarget(0)
	self:EndHardLockEffect()
end

---OnNetMsgTargetSetRsp
---@param MsgBody table                @TargetRsp
function TargetMgr:OnNetMsgTargetSetRsp(MsgBody)
	-- Nothing to do
end

---OnNetMsgTargetGetRsp
---@param MsgBody table                @TargetRsp
function TargetMgr:OnNetMsgTargetGetRsp(MsgBody)
	local Msg = MsgBody.Get or MsgBody.Notify
	if Msg then
		self:UpdateActorMainTarget(Msg.EntityID, Msg.TargetID)
	end
end

function TargetMgr:OnGameEventMajorCreate(Params)
	local EntityID = Params.ULongParam1
	-- 订阅主角自己的仇恨列表
	_G.CombatMgr:SubscribeEnmityListReq({EntityID})
	-- 主动拉取一次
	_G.CombatMgr:SendGetEnmityListReq(EntityID, 0, GetEnmityListReason.Target)
end

-- 在主城选取其他玩家时 将选中周围的其他玩家也展示出来
function TargetMgr:OnGameEventPreEnterInteractionRange(Params)
	-- 该功能后续需要优化 提审版本先屏蔽
	-- if Params.IntParam1 ~= _G.UE.EActorType.Player or not PWorldMgr:CurrIsInMainCity() then
	-- 	return
	-- end

	-- local EntityID = Params.ULongParam1
	-- local SelectedPlayer = ActorUtil.GetActorByEntityID(EntityID)
	-- if SelectedPlayer == nil then
	-- 	return
	-- end
	-- InteractiveMgr:ClearEntranceByType(_G.UE.EActorType.Player, true)

	-- local SelectedLocation = SelectedPlayer:FGetActorLocation()
	-- local Players = _G.UE.UActorManager:Get():GetAllPlayers()
	-- local SelectRange = CommonDefine.SelectPlayerRange
	-- local PlayersInRange = {}

	-- -- 获取到所有范围内Player的EntityID
	-- for Index = 1, Players:Length() do
	-- 	local Player = Players:GetRef(Index)
	-- 	if Player then
	-- 		local Distance = (SelectedLocation - Player:FGetActorLocation()):Size()
	-- 		if Distance <= SelectRange and Player:GetAttributeComponent() then
	-- 			local AttributeComp = Player:GetAttributeComponent()
	-- 			local PlayerEntityID = AttributeComp.EntityID
	-- 			if ActorUtil.IsInCanPlayerSelectedState(PlayerEntityID) and not _G.UE.USelectEffectMgr:TargetIsOutLockRange(PlayerEntityID) then
	-- 				table.insert(PlayersInRange, PlayerEntityID)
	-- 			end
	-- 		end
	-- 	end
	-- end

	-- -- 如果范围内的Player超过一个 则使用交互面板来进行显示
	-- if #PlayersInRange > 1 then
	-- 	for k, v in ipairs(PlayersInRange) do
	-- 		local PlayerParams = _G.EventMgr:GetEventParams()
	-- 		PlayerParams.IntParam1 = _G.UE.EActorType.Player
	-- 		PlayerParams.ULongParam1 = v
	-- 		EventMgr:SendEvent(EventID.EnterInteractionRange, PlayerParams)
	-- 	end
	-- end
end

---OnGameEventAttrTargetChanged 技能目标变化时，播放目标线
function TargetMgr:OnGameEventAttrTargetChanged(Params)
	if nil == Params then return end

	local EntityID = Params.ULongParam1
	local NewTargetID = Params.ULongParam2
	--local OldTargetID = Params.ULongParam3

	self:UpdateTargetLine(EntityID, NewTargetID)
end

---SendTargetSetReq
---@param TargetID number
function TargetMgr:SendTargetSetReq(TargetID)
	local MsgID = CS_CMD.CS_CMD_TARGET
	local SubMsgID = CS_TARGET_CMD.CS_TARGET_CMD_SET

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Set = { TargetID = TargetID }

	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---SendTargetGetReq
---@param EntityID number
function TargetMgr:SendTargetGetReq(EntityID)
	local MsgID = CS_CMD.CS_CMD_TARGET
	local SubMsgID = CS_TARGET_CMD.CS_TARGET_CMD_GET

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Get = { EntityID = EntityID }

	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---SendTargetGetReq
---@param EntityID number
---@param TargetID number
---@param IsStateChange boolean 是否为有无目标的转变
function TargetMgr.SendTargetChangeActorEvent(EntityID, TargetID, IsStateChange)
	local _ <close> = CommonUtil.MakeProfileTag("TargetChangeActor")
	EventMgr:SendEvent(EventID.TargetChangeActor, {EntityID = EntityID, TargetID = TargetID, IsStateChange = IsStateChange})
	local CppParams = _G.EventMgr:GetEventParams()
	CppParams.ULongParam1 = EntityID
	CppParams.ULongParam2 = TargetID
	EventMgr:SendCppEvent(EventID.TargetChangeActorCpp, CppParams)
end

---SetMajorTarget 更新Major的SelectedTarget和MainTarget
---@param SelectedTargetID number
function TargetMgr:SetMajorTarget(SelectedTargetID)
	SelectedTargetID = SelectedTargetID or 0

	if SelectedTargetID ~= self.MajorSelectedTarget then
		self.MajorSelectedTarget = SelectedTargetID

		local function DelaySendEvent()
			do
				local _ <close> = CommonUtil.MakeProfileTag("EventTargetChangeMajor")
				EventMgr:SendEvent(EventID.TargetChangeMajor, SelectedTargetID)
			end

			local _ <close> = CommonUtil.MakeProfileTag("Play2DSound")
			if SelectedTargetID > 0 then
				AudioUtil.LoadAndPlayUISound(SoundEvent_Select)
			else
				AudioUtil.LoadAndPlayUISound(SoundEvent_Miss)
			end
		end

		_G.TimerMgr:AddTimer(nil, DelaySendEvent, 0, 1, 1)

		--_G.FLOG_INFO("TargetMgr.SetMajorTarget(): MajorSelectedTarget change to %s(%d).", ActorUtil.GetActorName(self.MajorSelectedTarget), self.MajorSelectedTarget)
	end

	local MainTargetID = SelectedTargetID
	
	if MainTargetID ~= 0 then 
		-- 有一些对象不能不能作为MainTarget同步给其他玩家，如主角自己、客户端对象等
		if MainTargetID == MajorUtil.GetMajorEntityID() 
		or ActorUtil.IsClientActor(MainTargetID)
		or (not ActorUtil.IsGather(MainTargetID) and not ActorUtil.IsInCanPlayerSelectedState(MainTargetID)) then
			MainTargetID = 0
		end
	end

	if MainTargetID ~= self.MajorMainTarget then
		self.MajorMainTarget = MainTargetID
		self:SendTargetSetReq(MainTargetID)
		--_G.FLOG_INFO("TargetMgr.SetMajorTarget(): MajorMainTarget change to %s(%d).", ActorUtil.GetActorName(self.MajorMainTarget), self.MajorMainTarget)
	end
end

---UpdateActorMainTarget 更新非主角Actor的MainTarget
---@param EntityID number
---@param TargetID number
function TargetMgr:UpdateActorMainTarget(EntityID, MainTargetID)
	if not EntityID or MajorUtil.IsMajor(EntityID) then
		return
	end

	local NewMainTargetID = MainTargetID or 0
	if NewMainTargetID == -1 then NewMainTargetID = 0 end

	local OldMainTarget = self.MainTargetMapping[EntityID] or 0
	if NewMainTargetID == OldMainTarget then return end

	--_G.FLOG_INFO("TargetMgr.UpdateActorMainTarget(): The main target of %s(%d) is %s(%d).",
	--	ActorUtil.GetActorName(EntityID), EntityID, ActorUtil.GetActorName(NewMainTargetID), NewMainTargetID)

	-- MainTarget转变，实际的Target必然会发生变化

	local OldTargetID = self:GetTarget(EntityID)  -- 怪物有特殊逻辑，故实际Target必须通过这个接口获取
	self.MainTargetMapping[EntityID] = (NewMainTargetID > 0) and NewMainTargetID or nil
	local NewTargetID = self:GetTarget(EntityID)

	self.SendTargetChangeActorEvent(EntityID, NewTargetID, OldTargetID == 0 or NewTargetID == 0)
	self:UpdateTargetLine(EntityID, NewTargetID)
end

---UpdateTargetLine 更新目标线
---@param EntityID number
---@param TargetID number
function TargetMgr:UpdateTargetLine(EntityID, TargetID)
	-- 非怪物不处理仇恨线
	if not ActorUtil.IsMonster(EntityID) then
		return
	end

	-- 屏蔽怪物对其自身放技能的情况
	if EntityID == TargetID then
		return
	end

	--怪物脱战 或者变更目标 目标缓存清空
	if not MajorUtil.IsMajor(TargetID) then
		self.TargetLineMapping[EntityID] = nil
		return
	end

	if self.TargetLineMapping[EntityID] ~= TargetID then
		self.TargetLineMapping[EntityID] = (0 ~= TargetID) and TargetID or nil
		self:PlayTargetLineEffect(EntityID, TargetID)
	end
end

function TargetMgr:PlayTargetLineEffect(EntityID, TargetID)
	if _G.SettingsMgr:GetValueBySaveKey("ShowTargetLine") == 2 then
		return
	end

	if nil == TargetID or TargetID == 0 then
		return
	end

	local EnmityID = ActorUtil.GetMonsterEnmityID(EntityID)
	--当该列读不到时，屏蔽仇恨箭头。
	if (EnmityID == nil or EnmityID == 0) then
		return
	end
	--不显示目标仇恨线
	local NotShowTargetLine = EnmityCfg:FindValue(EnmityID, "NotShowTargetLine")
	if (NotShowTargetLine == nil or NotShowTargetLine == 1) then
		return
	end

	local StartActor = ActorUtil.GetActorByEntityID(EntityID)
	local EndActor = ActorUtil.GetActorByEntityID(TargetID)
	local ActorUIType = ActorUIUtil.GetActorUIType(EntityID)
	local AttachPointType_Body = _G.UE.EVFXAttachPointType.AttachPointType_Body

	local TargetLineEffectPath = TargetLineEffectPathB
	if (ProtoRes.ActorUIType.ActorUITypeMonster2 == ActorUIType) then
		TargetLineEffectPath = TargetLineEffectPathA
	end

	local VfxParameter = _G.UE.FVfxParameter()
	VfxParameter.VfxRequireData.EffectPath = TargetLineEffectPath
	VfxParameter:SetCaster(StartActor, _G.UE.EVFXEID.EID_HEAD_CENTER, AttachPointType_Body, 0)
	VfxParameter:AddTarget(EndActor, _G.UE.EVFXEID.EID_CHEST, AttachPointType_Body, 0)
	EffectUtil.PlayVfx(VfxParameter)

	local AudioMgr = _G.UE.UAudioMgr:Get()
	AudioMgr:AsyncLoadAndPostEvent(SoundEvent_TargetLine, StartActor)
end

---GetTargetOfMonsters @获取怪物第一仇恨
---@param EntityID number
---@return number
function TargetMgr:GetFirstTargetOfMonster(EntityID)
	return self.FirstTargetOfMonsters[EntityID] or 0
end

---GetTargetOfMonster @获取怪物主要目标，如果有主目标则返回主目标，没有则返回第一仇恨目标
---@param EntityID number
---@return number
function TargetMgr:GetTargetOfMonster(EntityID)
	return self.MainTargetMapping[EntityID] or self:GetFirstTargetOfMonster(EntityID)
end

---GetTarget @获取目标，对于主角，会获取MajorSelectedTarget；对于怪物类，会调用GetTargetOfMonster
---@param EntityID number
---@return number
function TargetMgr:GetTarget(EntityID)
	if MajorUtil.IsMajor(EntityID) then
		return self.MajorSelectedTarget
	elseif ActorUtil.IsMonster(EntityID) then
		return self:GetTargetOfMonster(EntityID)
	else
		return self.MainTargetMapping[EntityID] or 0
	end
end

---GetMajorSelectedTarget
function TargetMgr:GetMajorSelectedTarget()
	return self.MajorSelectedTarget
end

function TargetMgr:EnableHardLockEffect()
	_G.UE.USelectEffectMgr.Get():SetEnableHardLockEffect(true)
end

function TargetMgr:DisableHardLockEffect()
	_G.UE.USelectEffectMgr.Get():SetEnableHardLockEffect(false)
end

function TargetMgr:InitHardLockEffectView()
	local View = self.HardLockEffectView

	if nil == View then
		View = WidgetPoolMgr:CreateWidgetSyncByViewID(UIViewID.HardLockEffect, true, true)
		if nil == View then
			FLOG_ERROR("TargetMgr:InitHardLockEffectView Error")
			return
		end

		self.HardLockEffectView = View
	end

	if not View:IsInViewport() then
		View:AddToViewport(HardLockEffectZOrder)
	end
end

function TargetMgr:OnWorldPostLoad()
	-- # TODO - 主城中屏蔽强锁特效
	self:EnableHardLockEffect()
	-- if _G.PWorldMgr:CurrIsInMainCity() then
	-- 	self:DisableHardLockEffect()
	-- else
	-- 	self:EnableHardLockEffect()
	-- end

	self:InitHardLockEffectView()
end

function TargetMgr:StartHardLockEffect()
	local View = self.HardLockEffectView
	if View then
		return View:StartHardLockEffect()
	end
end

function TargetMgr:EndHardLockEffect()
	local View = self.HardLockEffectView
	if View then
		return View:EndHardLockEffect()
	end
end

function TargetMgr:UpdateHardLockEffectColor(Color)
	local View = self.HardLockEffectView
	if View then
		return View:SetColor(Color)
	end
end

function TargetMgr:UpdateHardLockEffectMask(NewBitMask)
	local bLastMask = self.HardLockEffectBitMask > 0
	local bCurrentMask = NewBitMask > 0
	local View = self.HardLockEffectView
	if bLastMask ~= bCurrentMask and View then
		View:UpdateMask(bCurrentMask)
	end
	self.HardLockEffectBitMask = NewBitMask
end

--- 设置强锁特效的Mask
---@param MaskType number - Mask类型, 对应CommonDefine中的枚举HardLockEffectMaskType
---@param bHasMask boolean - Mask状态
function TargetMgr:SetHardLockEffectMask(MaskType, bHasMask)
	if bHasMask then
		self:UpdateHardLockEffectMask(self.HardLockEffectBitMask | (1 << MaskType))
	else
		self:UpdateHardLockEffectMask(self.HardLockEffectBitMask & ~(1 << MaskType))
	end
end

return TargetMgr