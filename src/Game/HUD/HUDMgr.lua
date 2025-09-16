--
-- Author: anypkvcai
-- Date: 2020-10-13 19:40:15
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")
local HUDType = require("Define/HUDType")
local HUDConfig = require("Define/HUDConfig")
local HurtDescriptionCfg = require("TableCfg/HurtDescriptionCfg")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local BuffCfg = require("TableCfg/BuffCfg")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
 local CommonUtil = require("Utils/CommonUtil")
local MonsterCfg = require("TableCfg/MonsterCfg")
local HUDActorView = require("Game/HUD/HUDActorView")
local HUDActorVM = require("Game/HUD/HUDActorVM")
local LifeskillEffectCfg = require("TableCfg/LifeskillEffectCfg")
local UIViewID = require("Define/UIViewID")
-- local GCType = require("Define/GCType")
local TimeUtil = require("Utils/TimeUtil")
-- local EObjCfg = require("TableCfg/EobjCfg")
local NpcCfg = require("TableCfg/NpcCfg")
local ProtoCS = require("Protocol/ProtoCS")
local ActorUIUtil = require("Utils/ActorUIUtil")
local SelectTargetBase = require("Game/Skill/SelectTarget/SelectTargetBase")
local TeamHelper = require("Game/Team/TeamHelper")

local CS_CMD = ProtoCS.CS_CMD

local FHUDFlyText
local UHUDMgr
local USelectEffectMgr
local UTestMgr
local FriendMgr ---@type FriendMgr
local TeamMgr ---@type TeamMgr
local PWorldTeamMgr ---@type PWorldTeamMgr
local PWorldEntourageTeamMgr ---@type PWorldEntourageTeamMgr
local UIViewMgr
local ObjectPoolMgr
local ChocoboRaceMgr
local SkillLogicMgr ---@type SkillLogicMgr
local TargetMgr

local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_WARNING = _G.FLOG_WARNING
local EActorType = _G.UE.EActorType
local EHUDItemType = _G.UE.EHUDItemType
local ECameraFadeTargetWhite = _G.UE.ECameraFadeTarget.White
local ECameraFadeTargetBlack = _G.UE.ECameraFadeTarget.Black
local HUDDrawFlagAll = 0xff
local HUDDrawFlagFlyText = (1 << EHUDItemType.FlyText)

local LSTR = _G.LSTR
-- local TimerRegister = require("Register/TimerRegister")

---@class HUDMgr : MgrBase
---@field FlyTexts table<number,HUDObject> @伤害等飘字 沿用自由幻想的名字
---@field ActorInfos table<number,HUDObject> @角色头顶名字、血量等
---@field TargetEntityID number
---@field TimerID number    @计时器ID
---@field LastAddTime number @上次伤害等飘字的时间
---@field Interval number @伤害等飘字的间隔 单位：毫秒
local HUDMgr = LuaClass(MgrBase)

local EasyUID = {
	N = 0
}

local EasyUIDMod = (2 << 31) - 1
function EasyUID:GetUID()
	self.N = (self.N + 1) & EasyUIDMod
	-- print("== ZHG N = " .. self.N)

	return self.N
end


local GetTimeMs = TimeUtil.GetServerTimeMS
local DealyInvMs = 100 --飘字最小时间间隔MS

local DeferedHUDComp = {}

local DeferedHUDCompTimerDestoryDelay = 60 * 2 * 1000
function DeferedHUDComp:OnBegin()
	self.CmdDict = {}
	self.TimerHandler = nil
	self.TimerDestroyTimeStamp = 0
	self.CmdNum = 0
end

function DeferedHUDComp:OnEnd()
	if self.TimerHandler then
		self.TimerHandler()
	end
end

function DeferedHUDComp:MakeCmd(TimeInv, CallBack)
	local Ret = {}
	Ret.TimeStamp = GetTimeMs() + TimeInv
	Ret.CallBack = CallBack

	return Ret
end

function DeferedHUDComp:AddCmd(TimeInv, CallBack)
	if nil == TimeInv or nil == CallBack then
		return
	end

	if TimeInv < DealyInvMs/2 then
		CallBack()
		return
	end

	self:PreAddCmd()
	local Cmd = self:MakeCmd(TimeInv, CallBack)
	local UID = EasyUID:GetUID()
	self.CmdDict[UID] = Cmd
	self.CmdNum = self.CmdNum + 1
end

function DeferedHUDComp:PreAddCmd()
	if self.CmdNum == 0 then
		if nil == self.TimerHandler then
			local TimerID = _G.TimerMgr:AddTimer(self, self.Tick, 0, DealyInvMs/1000, 0)
			self.TimerHandler = function()
				_G.TimerMgr:CancelTimer(TimerID)
			end

			-- print("== ZHG ADD TIMER")
		end
	end
end

function DeferedHUDComp:ResetTimerDestroyCountDown()
	local Now = GetTimeMs()
	self.TimerDestroyTimeStamp = Now + DeferedHUDCompTimerDestoryDelay
end

function DeferedHUDComp:Tick()
	if self.CmdNum == 0 and nil ~= self.TimerHandler then
		-- print("== TICK 1")

		local Now = GetTimeMs()
		if Now > self.TimerDestroyTimeStamp then
			self.TimerHandler()
			self.TimerHandler = nil
			-- print("== ZHG REMOVE TIMER")
		end
	else
		-- print("== TICK 2")

		for UID, Cmd in pairs(self.CmdDict) do
			local Now = GetTimeMs()
			if Now + DealyInvMs/2 > Cmd.TimeStamp then -- 舍入
				Cmd.CallBack()
				self.CmdDict[UID] = nil
				self.CmdNum = self.CmdNum - 1
				-- print("== ZHG BACK")
			end
		end

		if self.CmdNum == 0 then
			self:ResetTimerDestroyCountDown()
			-- print("== ZHG BEGIN REMOVE TIMER")
		end
	end
end

local EPlayerVisibility = {
	ShowAll = 1, -- 可见
	HideAll = 2, -- 隐藏所有
	HideOther = 3, -- 除了自己都隐藏
}

local ENpcVisibility = {
	ShowAll = 1, -- 可见
	HideAll = 2, -- 隐藏所有
	ShowTargetOnly = 3, -- 只显示目标
}

local EActorVisibility = {
	None = 0,
	ShowAll = 1, -- 可见
	HideAll = 2, -- 隐藏所有
}

function HUDMgr:OnInit()
	self.FlyTexts = {}
	self.ActorInfos = {}
	self.TargetEntityID = nil
	self.TimerID = 0
	self.LastAddTime = 0
	self.Interval = 300
	self.PlayerVisibility = EPlayerVisibility.ShowAll
	self.NpcVisibility = ENpcVisibility.ShowAll
	self.TargetNpcEntityID = 0
	self.AllActorVisibility = EActorVisibility.None
	self.InteractiveTargetEntityID = 0  -- 当前交互目标的EntityID
	self.IsDrawFlags = HUDConfig.IsDrawFlag.All
	self.bMemberFlyTextVisible = false
end

function HUDMgr:OnBegin()
	FHUDFlyText = _G.UE.FHUDFlyText
	UHUDMgr = _G.UE.UHUDMgr:Get()
	USelectEffectMgr = _G.UE.USelectEffectMgr:Get()
	UTestMgr = _G.UE.UTestMgr:Get()
	FriendMgr = _G.FriendMgr
	TeamMgr = _G.TeamMgr
	PWorldTeamMgr = _G.PWorldTeamMgr
	PWorldEntourageTeamMgr = _G.PWorldEntourageTeamMgr
	UIViewMgr = _G.UIViewMgr
	ObjectPoolMgr = _G.ObjectPoolMgr
	ChocoboRaceMgr = _G.ChocoboRaceMgr
	SkillLogicMgr = _G.SkillLogicMgr
	TargetMgr = _G.TargetMgr

	self.DeferedHUDComp = DeferedHUDComp
	self.DeferedHUDComp:OnBegin()

	--UHUDMgr:SetIsSyncLoad(true)

	--UHUDMgr:SetGCType(ObjectGCType.Map)

	if CommonUtil.IsWithEditor() then
		CommonUtil.ConsoleCommand("r.HudZtest.Enable 0")
	end
end

function HUDMgr:OnEnd()
	self.DeferedHUDComp:OnEnd()
	self:ReleaseAll()
end

function HUDMgr:OnShutdown()

end

function HUDMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.Attr_Change_HP, self.OnGameEventAttrChangeHP)
	self:RegisterGameEvent(EventID.VisionLevelChange, self.OnGameEventOtherLevelUpdate)
	self:RegisterGameEvent(EventID.AttackEffectChange, self.OnGameEventAttackEffectChange)
	self:RegisterGameEvent(EventID.VisionAvatarDataSync, self.OnGameEventVisionAvatarDataSync)
	self:RegisterGameEvent(EventID.VisionChocoboChange, self.OnGameEventVisionChocoboChange)
	self:RegisterGameEvent(EventID.BuddyQueryInfo, self.OnGameEventBuddyQueryInfo)

	self:RegisterGameEvent(EventID.UpdateBuff, self.OnGameEventUpdateBuffer)
	self:RegisterGameEvent(EventID.RemoveBuff, self.OnGameEventRemoveBuffer)

	self:RegisterGameEvent(EventID.MajorAddBuffLife, self.OnMajorAddBuffLife)
	self:RegisterGameEvent(EventID.MajorUpdateBuffLife, self.OnMajorAddBuffLife)
	self:RegisterGameEvent(EventID.MajorRemoveBuffLife, self.OnMajorRemoveBuffLife)

	self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
	self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
	self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)

	self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead)
	self:RegisterGameEvent(EventID.OtherCharacterDead, self.OnGameEventCharacterDead)
	self:RegisterGameEvent(EventID.ActorReviveNotify, self.OnGameEventActorRevive)

	self:RegisterGameEvent(EventID.WorldPreLoad, self.OnGameEventWorldPreLoad)
	self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)

	self:RegisterGameEvent(EventID.SelectTarget, self.OnGameEventSelectTarget)
	self:RegisterGameEvent(EventID.UnSelectTarget, self.OnGameEventUnSelectTarget)

	self:RegisterGameEvent(EventID.CameraPostEffect_Fade_Start, self.OnGameEventCameraPostEffectFadeStart)
	self:RegisterGameEvent(EventID.CameraPostEffect_Fade_End, self.OnGameEventCameraPostEffectFadeEnd)

	self:RegisterGameEvent(EventID.TargetChangeActor, self.OnGameEventTargetChangeActor)

	self:RegisterGameEvent(EventID.VisionUpdateFirstAttacker, self.OnGameEventVisionUpdateFirstAttacker)

	self:RegisterGameEvent(EventID.TrivialCombatStateUpdate, self.OnGameEventComBatStateUpdate)
	--self:RegisterGameEvent(EventID.ControlStatUpdate, self.OnGameEventControlStatUpdate)

	--self:RegisterGameEvent(EventID.VisionUpdateTeamFlag, self.OnGameEventVisionUpdateTeamFlag)

	-- self:RegisterGameEvent(EventID.ActiveGatherItemView, self.OnActiveGatherItemView)
	-- self:RegisterGameEvent(EventID.DeActiveGatherItemView, self.OnDeActiveGatherItemView)
	self:RegisterGameEvent(EventID.GatherAttrChange, self.OnGatherAttrChange)

	self:RegisterGameEvent(EventID.UpdateQuest, self.OnQuestUpdate)
	self:RegisterGameEvent(EventID.UpdateQuestTrack, self.OnUpdateQuestTrack)
	self:RegisterGameEvent(EventID.UpdateTrackQuestTarget, self.OnUpdateTrackQuestTarget)
    self:RegisterGameEvent(EventID.ClientNpcMoveStart, self.OnGameEventClientNpcMoveStart)
    self:RegisterGameEvent(EventID.ClientNpcMoveEnd, self.OnGameEventClientNpcMoveEnd)
	self:RegisterGameEvent(EventID.GateOppoNpcTaskIconUpdate, self.OnGateOppoTaskUpdate)
	self:RegisterGameEvent(EventID.GoldActivityIconUpdate, self.OnGoldActivityUpdate)

	self:RegisterGameEvent(EventID.MagicCardUpdateNPCHudIcon, self.OnGameEventMagicCardUpdate)
	self:RegisterGameEvent(EventID.LeveQuestUpdateNPCHudIcon, self.OnGameEventLeveQuestUpdate)

	self:RegisterGameEvent(EventID.MysteryMerchantUpdateNPCHudIcon, self.OnGameEventMysteryMerchantUpdate)
	self:RegisterGameEvent(EventID.OnlineStatusChangedInVision, self.OnGameEventOnlineStatusChangedInVision)
	self:RegisterGameEvent(EventID.OnlineStatusMajorChanged, self.OnMajorPlayerOnlineStatusChanged)

	self:RegisterGameEvent(EventID.FriendAdd, self.OnGameEventRoleIdentityChanged)
	self:RegisterGameEvent(EventID.FriendRemoved, self.OnGameEventRoleIdentityChanged)
    self:RegisterGameEvent(EventID.TeamIdentityChanged, self.OnGameEventRoleIdentityChanged)

	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)

	self:RegisterGameEvent(EventID.ChocoboRaceHUDUpdate, self.OnGameEventChocoboRaceHUDUpdate)
	self:RegisterGameEvent(EventID.ChocoboRaceStaminaChange, self.OnGameEventChocoboRaceStaminaChange)

	--self:RegisterGameEvent(EventID.MagicCardTourneyRankUpdate, self.OnGameEventMagicCardTourneyRankUpdate)

	self:RegisterGameEvent(EventID.TitleChange, self.OnGameEventTitleChange)

	self:RegisterGameEvent(EventID.ActorUIColorConfigChanged, self.OnGameEventActorUIColorConfigChanged)

	-- 生活职业技能数值飘字
	self:RegisterGameEvent(EventID.GatheringJobCollectionScour, self.OnGameEventCollectionScour)  -- 采集收藏品提纯
	self:RegisterGameEvent(EventID.CrafterSkillRsp, self.OnGameEventCrafterSkillRsp)  -- 能工巧匠制作品质和进度飘字
	self:RegisterGameEvent(EventID.CrafterOnNormalMakeStart, self.OnGameEventOnNormalMakeStart)  -- 能工巧匠常规制作开始

	self:RegisterGameEvent(EventID.MountCall, self.OnGameEventMountCall)  -- 骑上坐骑后需要改变UI挂点
	self:RegisterGameEvent(EventID.MountBack, self.OnGameEventMountBack)  -- 下坐骑后需要恢复UI挂点

	self:RegisterGameEvent(EventID.TeamTargetMarkStateChanged, self.OnGameEventTeamTargetMarkStateChanged)
	self:RegisterGameEvent(EventID.TouringBandTargetMarkIconChanged, self.OnGameEventTouringBandTargetMarkIconChanged)
	
	self:RegisterGameEvent(EventID.ShowSpeechBubble, self.OnGameEventShowSpeechBubble)
	self:RegisterGameEvent(EventID.HideSpeechBubble, self.OnGameEventHideSpeechBubble)

	self:RegisterGameEvent(EventID.ArmySelfArmyAliasUpdate, self.OnGameEventArmySelfArmyAliasUpdate)
	self:RegisterGameEvent(EventID.ArmySelfArmyIDUpdate, 	self.OnGameEventSelfArmyIDUpdate) 	-- 玩家公会ID更新(进入、退出、被踢等)
	self:RegisterGameEvent(EventID.TriggerObjInteractive, self.OnGameEventTriggerObjInteractive)

    self:RegisterGameEvent(EventID.Camp_Change, self.OnCampChange)

	self:RegisterGameEvent(EventID.BuddyCreate, self.OnGameEventBuddyCreate)
end

--function HUDMgr:OnRegisterTimer()
--	self:RegisterTimer(self.OnTimer, 0, 0.3, 0)
--end

function HUDMgr:OnTimer()
	local Time = TimeUtil.GetLocalTimeMS()
	if Time - self.LastAddTime >= self.Interval then
		self.LastAddTime = Time
		self:AddObjectToHUD()
	end
end

function HUDMgr:AddObjectToHUD()
	if nil == self.FlyTexts then
		return
	end

	local IsNeedToUnRegister = true

	for _, v in pairs(self.FlyTexts) do
		if nil ~= v and #v > 0 then
			local Object = table.remove(v, 1)
			if #v > 0 then
				IsNeedToUnRegister = false
			end
			if nil ~= Object then
				Object:SetIsActive(true)
			end
		end
	end

	if IsNeedToUnRegister then
		self:UnRegisterTimer(self.TimerID)
		self.TimerID = 0
	end
end

function HUDMgr:AddFlyText(EntityID, Object)
	if nil == self.FlyTexts[EntityID] then
		self.FlyTexts[EntityID] = {}
	end

	local FlyText = self.FlyTexts[EntityID]
	table.insert(FlyText, Object)

	self:UpdateFlyTextTime()

	if 0 >= self.TimerID then
		self.TimerID = self:RegisterTimer(self.OnTimer, 0, 0.05, 0)
	end
end

---UpdateFlyTextTime @体验优化需求 要按照数量调整速度
function HUDMgr:UpdateFlyTextTime()
	local MaxNum = 0

	local FlyTexts = self.FlyTexts
	for _, v in pairs(FlyTexts) do
		local Num = #v
		if Num > MaxNum then
			MaxNum = Num
		end
	end

	if MaxNum < 4 then
		self.Interval = 180
		FHUDFlyText.SetTimeScale(1.0)
	elseif MaxNum < 8 then
		self.Interval = 120
		FHUDFlyText.SetTimeScale(1.6)
	elseif MaxNum < 12 then
		self.Interval = 60
		FHUDFlyText.SetTimeScale(2.8)
	else
		self.Interval = 30
		FHUDFlyText.SetTimeScale(4.0)
	end
end

function HUDMgr:GetActorInfo(EntityID)
	return (self.ActorInfos or {})[EntityID]
end

---@return HUDActorVM
function HUDMgr:GetActorVM(EntityID)
	local ActorInfo = (self.ActorInfos or {})[EntityID]
	if nil == ActorInfo then
		return
	end

	return ActorInfo.ActorVM
end

---获取ActorInfoView
function HUDMgr:GetActorView(EntityID)
	local ActorInfo = self:GetActorInfo(EntityID)
	return ActorInfo and ActorInfo.ActorView
end

---获取FHUDActorInfo对象
function HUDMgr:GetActorInfoObject(EntityID)
	local ActorView = self:GetActorView(EntityID)
	return ActorView and ActorView.Object
end

function HUDMgr:ReleaseAll()
	--UHUDMgr:ReleaseAllObject()
	FLOG_INFO("HUDMgr:ReleaseAll()")

	--所有的Hud要在UHUDMgr:ReleaseAll之前清理下，比如BuoyMgr的浮标
	_G.BuoyMgr:ClearAllBuoys()
	UHUDMgr:ReleaseAll()

	for _, v in pairs(self.ActorInfos) do
		v.ActorView:DestroyView()
		ObjectPoolMgr:FreeObject(HUDActorView, v.ActorView)
		ObjectPoolMgr:FreeObject(HUDActorVM, v.ActorVM)
	end

	self.ActorInfos = {}
	self.FlyTexts = {}
end

function HUDMgr:OnGameEventAttrChangeHP(Params)
	if nil == Params then
		return
	end
	--print("HUDMgr:OnGameEventAttrChangeHP", Params.ULongParam2, Params.ULongParam3)

	local EntityID = Params.ULongParam1
	local CurHP = Params.ULongParam3
	local MaxHP = Params.ULongParam4

	local ActorVM = self:GetActorVM(EntityID)
	if nil == ActorVM then
		return
	end

	ActorVM:UpdateHP(CurHP, MaxHP)
end

function HUDMgr:OnGameEventOtherLevelUpdate(Params)
	if nil == Params or nil == Params.ULongParam1 then
		return
	end

	local EntityID = Params.ULongParam1
	local ActorVM = self:GetActorVM(EntityID)
	if nil == ActorVM then
		return
	end

	ActorVM:UpdateNameInfo()
end

---IsFriendlyEntity 判断是否为需要显示伤害飘字的友方
local function IsFriendlyEntity(EntityID)
	if TeamHelper.GetTeamMgr():IsTeamMemberByEntityID(EntityID) then
		return true
	end

	-- 单人本中剧情NPC视为友方
	if _G.PWorldMgr:CurrIsInSingleDungeon() then
		local ActorType = ActorUtil.GetActorType(EntityID)
		if EActorType.Monster == ActorType then
			local Relation = SelectTargetBase:GetCampRelationByEntityID(EntityID)
			if ProtoRes.camp_relation.camp_relation_enemy ~= Relation then
				return true
			end
		end
	end

	return false
end

local function IsMajorBuddy(EntityID)
	if ActorUtil.IsBuddy(EntityID) then
		local OwnerEntityID = ActorUtil.GetActorOwner(EntityID)
		if MajorUtil.IsMajor(OwnerEntityID) then
			return true
		end
	end
	return false
end

---OnGameEventAttackEffectChange
---@param Params table @EffectParam
function HUDMgr:OnGameEventAttackEffectChange(Params)
	if nil == Params then
		return
	end

	local BehitObjID = Params.BehitObjID
	local AttackObjID = Params.AttackObjID
	local EffectType = Params.EffectType or 0

	-- skillsystem don't show attack hud
	if SkillLogicMgr:IsSkillSystem(BehitObjID) == true or SkillLogicMgr:IsSkillSystem(AttackObjID) == true then
		return
	end

	local IsFromMajor = MajorUtil.IsMajor(AttackObjID)
	local IsToMajor = MajorUtil.IsMajor(BehitObjID)
	local IsDamage = EffectType == ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_HP_DAMAGE or EffectType == ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_SHIELD_COST

	local bShouldShow = false
	
	-- 仅在以下情况显示飘字：
	-- 1. 伤害或治疗的发起方或接受方为Major
	if IsToMajor or IsFromMajor then 
		bShouldShow = true
	end

	-- 2. 伤害的发起方为友方。支持在设置界面关闭友方飘字
	if not bShouldShow and self.bMemberFlyTextVisible and IsDamage and IsFriendlyEntity(AttackObjID) then
		bShouldShow = true
	end

	-- 3. 主角搭档的伤害
	if not bShouldShow and IsDamage and IsMajorBuddy(AttackObjID) then
		bShouldShow = true
	end

	if not bShouldShow then
		return
	end

	local BuffID = Params.BuffID or 0
	local SkillID = Params.MainSkillID or 0
	local SkillType = SkillMainCfg:GetSkillType(SkillID)
	-- local PassiveSkillID = Params.PassiveSkillID or 0

	local IsFromSkill = SkillID > 0
	local IsFromBuff = BuffID > 0
	if (not IsFromSkill and not IsFromBuff)
	or (IsFromSkill and (nil == SkillType)) then
		return
	end

	local Value = Params.Value or 0

	local Desc = ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_MP_HEAL == EffectType and LSTR(510002) or ""  -- 510002-魔力
	-- 护盾特殊处理
	if ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_SHIELD_COST == EffectType then
		-- by v_hggzhang 22.07.05 没有护盾时，服务器也会下发护盾效果，其值 = 0，故屏蔽掉
		if Value == 0 then return end
		Desc = string.format(LSTR(510003), Value)  -- 510003-(%d 点伤害被吸收！)
		Value = 0
	elseif ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_DODGE == EffectType then
		Desc = LSTR(510004)  -- 510004-回避
	elseif ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_SUPERMAN == EffectType then
		Desc = LSTR(510005)  -- 510005-无敌
	elseif ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_ATTACK_INVALID == EffectType then
		Desc = LSTR(510007)  -- 510007-无效
	elseif ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_HP_DAMAGE == EffectType then
		-- Dot伤害为零，不显示飘字。护盾吸收的伤害会单独有个事件
		if IsFromBuff and Value == 0 then return end
	end

	local Name = ""
	-- 只有发起方或接受方为Major时，才显示技能名称
	if IsToMajor or IsFromMajor then
		Name = self:GetFlyTextName(SkillType, SkillID, Params.TipsId or 0)
	end

	local HUDTypeOffset = 0
	if Params.BDirectAtk then HUDTypeOffset = 1 end
	if Params.BRage then HUDTypeOffset = HUDTypeOffset + 2 end
	local FlyTextHUDType = self:GetFlyTextHUDType(EffectType, IsToMajor, IsFromSkill, SkillType, HUDTypeOffset)
	if FlyTextHUDType == HUDType.None then
		return
	end

	local OffsetX, OffsetY = self:GetEffectFlyTextOffset(BehitObjID, IsToMajor, IsFromSkill)
	-- 回复药临时方案，需求单ID: 884071563
	if ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_ATTR_HP == EffectType then
		OffsetX = self:GetHUDRandomOffset()
		OffsetX = OffsetX + 340
		OffsetY = 50
	elseif ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_ATTR_MP == EffectType then
		OffsetX, OffsetY = self:GetHUDRandomOffset()
		OffsetY = OffsetY - 20
	end

	local TimeInv = Params.DelayTime or 0
	-- 附加伤害延时0.1s
	if ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_ATTACH_HP_DAMAGE == EffectType then
		TimeInv = 100
	end

	local Color = nil
	local OutlineColor = nil

	local CallBack = function()
		self:ShowAttackEffect(BehitObjID, FlyTextHUDType, Value, Name, Desc, OffsetX, OffsetY, Color, OutlineColor)
	end

	self.DeferedHUDComp:AddCmd(TimeInv, CallBack) -- 延迟飘字 TimeInv 小于 Tick时间间隔/2 立即飘
end

function HUDMgr:OnGameEventUpdateBuffer(Params)
	self:OnGameEventUpdateBufferActorInfo(Params)
	self:OnGameEventUpdateBufferFlyText(Params)
end

function HUDMgr:OnGameEventUpdateBufferActorInfo(Params)
	local BuffID = Params.IntParam1
	local DisplayCombatStatID = tonumber(BuffCfg:FindValue(BuffID, "DisplayCombatStatID") or "")
	if nil ~= DisplayCombatStatID then
		local EntityID = Params.ULongParam1
		self:UpdateActorInfoCombatState(EntityID)
	end
end

function HUDMgr:OnGameEventUpdateBufferFlyText(Params)
	if nil == Params then
		return
	end

	local IsUpdate = Params.BoolParam3
	if not IsUpdate then
		-- 通过sync协议同步的数据，不展示飘字
		return
	end

	local IsHasBuff = Params.BoolParam1
	local IsMorePile = Params.BoolParam2
	
	local Pile = Params.IntParam2
	local MaxPile = Params.IntParam4

	if IsHasBuff and not IsMorePile and Pile < MaxPile then
		-- buff层数减少的情况，不播放飘字
		return
	end

	local BufferID = Params.IntParam1
	local Cfg = BuffCfg:FindCfgByKey(BufferID)
	if nil == Cfg then
		return
	end

	if 1 == Cfg.NoAddFlyText or ProtoRes.BuffDisplayType.BUFF_DISPLAY_TYPE_NULL == Cfg.DisplayType then
		return
	end

	-- 重复添加buff时，根据配置判断是否飘字
	if IsHasBuff and Cfg.ShowRepeatAddFlyText == 0 then
		return
	end

	local EntityID = Params.ULongParam1
	local GiverID = Params.ULongParam2

	--print(string.format("HUDMgr:OnGameEventUpdateBuffer BufferID=%d EntityID=%d GiverID=%d", BufferID, EntityID, GiverID))

	local Offset = self:GetFlyTextOffset(EntityID)

	if MajorUtil.IsMajor(EntityID) then
		if ProtoRes.BuffDisplayType.BUFF_DISPLAY_TYPE_POSITIVE == Cfg.DisplayType then
			self:ShowBufferEffect(EntityID, BufferID, HUDType.MajorBufferAdd, 0, Offset)
		else
			self:ShowBufferEffect(EntityID, BufferID, HUDType.MajorDBufferAdd, 0, Offset)
		end
		return
	end

	if not MajorUtil.IsMajor(GiverID) then
		return
	end

	if ActorUIUtil.IsTeamMember(EntityID) then
		self:ShowBufferEffect(EntityID, BufferID, HUDType.ActorBufferAdd, 0, Offset)
		return
	end

	local ActorType = ActorUtil.GetActorType(EntityID)
	if EActorType.Monster == ActorType then
		self:ShowBufferEffect(EntityID, BufferID, HUDType.MonsterBufferAdd, 0, Offset)
	end
end

function HUDMgr:OnGameEventRemoveBuffer(Params)
	HUDMgr:OnGameEventRemoveBufferActorInfo(Params)
	HUDMgr:OnGameEventRemoveBufferFlyText(Params)
end

function HUDMgr:OnGameEventRemoveBufferActorInfo(Params)
	local BuffID = Params.IntParam1
	local DisplayCombatStatID = tonumber(BuffCfg:FindValue(BuffID, "DisplayCombatStatID") or "")
	if nil ~= DisplayCombatStatID then
		local EntityID = Params.ULongParam1
		self:UpdateActorInfoCombatState(EntityID)
	end
end

function HUDMgr:OnGameEventRemoveBufferFlyText(Params)
	if nil == Params then
		return
	end
	--print("HUDMgr:OnGameEventRemoveBuffer",Params.IntParam1,Params.ULongParam1,Params.ULongParam2)

	local BufferID = Params.IntParam1
	local EntityID = Params.ULongParam1
	local GiverID = Params.ULongParam2

	local Cfg = BuffCfg:FindCfgByKey(BufferID)
	if nil == Cfg then
		return
	end

	if 1 == Cfg.NoRemoveFlyText or ProtoRes.BuffDisplayType.BUFF_DISPLAY_TYPE_NULL == Cfg.DisplayType then
		return
	end

	local Offset = self:GetFlyTextOffset(EntityID)

	if MajorUtil.IsMajor(EntityID) then
		self:ShowBufferEffect(EntityID, BufferID, HUDType.MajorBufferRemove, 0, Offset)
		return
	end

	if not MajorUtil.IsMajor(GiverID) then
		return
	end

	if ActorUIUtil.IsTeamMember(EntityID) then
		local OffsetX, OffsetY = self:GetHUDRandomOffset()
		self:ShowBufferEffect(EntityID, BufferID, HUDType.ActorBufferRemove, OffsetX, OffsetY + Offset)
		return
	end

	local ActorType = ActorUtil.GetActorType(EntityID)
	if EActorType.Monster == ActorType then
		local OffsetX, OffsetY = self:GetHUDRandomOffset()
		self:ShowBufferEffect(EntityID, BufferID, HUDType.MonsterBufferRemove, OffsetX, OffsetY + Offset)
	end
end

function HUDMgr:OnMajorAddBuffLife(BuffInfo, AddBuffAnimDelay)
	if BuffInfo.IsAlreadyHas and
	   (BuffInfo.bIsPileIncreased ~= true or BuffInfo.bShowFlyTextWhenPileIncreased ~= true) then
		return
	end

	local BufferID = BuffInfo.BuffID
	local EntityID = MajorUtil.GetMajorEntityID()

	local Cfg = LifeskillEffectCfg:FindCfgByKey(BufferID)
	if nil == Cfg then
		return
	end

	if 1 == Cfg.NoAddFlyText or ProtoRes.BuffDisplayType.BUFF_DISPLAY_TYPE_NULL == Cfg.DisplayType then
		return
	end

	local Offset = self:GetFlyTextOffset(EntityID)

	AddBuffAnimDelay = AddBuffAnimDelay or 0
	_G.TimerMgr:AddTimer(self, function()
		if ProtoRes.BuffDisplayType.BUFF_DISPLAY_TYPE_POSITIVE == Cfg.DisplayType then
			self:ShowBufferEffect(EntityID, BufferID, HUDType.MajorBufferAdd, 0, Offset, true)
		else
			self:ShowBufferEffect(EntityID, BufferID, HUDType.MajorDBufferAdd, 0, Offset, true)
		end
	end, AddBuffAnimDelay, 0, 1)
end

function HUDMgr:OnMajorRemoveBuffLife(BuffInfo, AddBuffAnimDelay)
	AddBuffAnimDelay = AddBuffAnimDelay or 0
	local BufferID = BuffInfo.BuffID
	local EntityID = MajorUtil.GetMajorEntityID()

	local Cfg = LifeskillEffectCfg:FindCfgByKey(BufferID)
	if nil == Cfg then
		return
	end

	if 1 == Cfg.NoRemoveFlyText or ProtoRes.BuffDisplayType.BUFF_DISPLAY_TYPE_NULL == Cfg.DisplayType then
		return
	end

	local Offset = self:GetFlyTextOffset(EntityID)

	_G.TimerMgr:AddTimer(self, function()
		self:ShowBufferEffect(EntityID, BufferID, HUDType.MajorBufferRemove, 0, Offset, true)
	end, AddBuffAnimDelay, 0, 1)
end

function HUDMgr:OnGameEventMajorCreate(Params)
	if nil == Params then
		return
	end
	--print("HUDMgr:OnGameEventMajorCreate", Params.ULongParam1)
	local EntityID = Params.ULongParam1

	self:ShowActorInfo(EntityID)

	-- 量谱缓存处理
	if nil ~= self.MajorSpectrumParams then
		_G.FLOG_INFO("HUDMgr.OnGameEventMajorCreate(): Use cached SpectrumParams")
		self:SetSpectrumParams(EntityID, table.unpack(self.MajorSpectrumParams))
		self.MajorSpectrumParams = nil
	end
end

function HUDMgr:OnGameEventVisionEnter(Params)
	--print("HUDMgr:OnGameEventVisionEnter", ActorUtil.GetActorName(Params.ULongParam1))
	if nil == Params then
		return
	end

	local EntityID = Params.ULongParam1
	self:ShowActorInfo(EntityID)

	self:OnFateUpdate({ EntityID = EntityID })

	local BuddyEntityID = _G.BuddyMgr:GetBuddyByMaster(EntityID)
	local BuddyVM = self:GetActorVM(BuddyEntityID)
	if nil ~= BuddyVM then
		BuddyVM:UpdateNameInfo()
		BuddyVM:UpdateNameVisible()
		BuddyVM:UpdateTitleInfo()
	end
end

function HUDMgr:OnGameEventVisionLeave(Params)
	--print("HUDMgr:OnGameEventVisionLeave")
	if nil == Params then
		return
	end

	self:HideActorInfo(Params.ULongParam1)
end

function HUDMgr:OnGameEventMajorDead(Params)
	--print("HUDMgr:OnGameEventMajorDead")

	local EntityID = MajorUtil.GetMajorEntityID()

	self:OnActorDead(EntityID)
end

function HUDMgr:OnGameEventCharacterDead(Params)
	-- print("HUDMgr:OnGameEventCharacterDead", Params.ULongParam1)
	if nil == Params then
		return
	end

	local EntityID = Params.ULongParam1

	self:OnActorDead(EntityID)
end

function HUDMgr:OnGameEventActorRevive(Params)
	--print("HUDMgr:OnGameEventActorRevive", Params.ULongParam1)
	if nil == Params then
		return
	end

	local EntityID = Params.ULongParam1

	self:UpdateActorUIColor(EntityID)
end

function HUDMgr:OnGameEventWorldPreLoad(Params)
	FLOG_INFO("HUDMgr:OnGameEventWorldPreLoad()")

	if _G.PWorldMgr:IsChangeLine() then
		local MajorEntityID = MajorUtil.GetMajorEntityID()
		for EntityID in pairs(self.ActorInfos) do
			if EntityID ~= MajorEntityID then
				self:HideActorInfo(EntityID)
			end
		end
	else
		self:ReleaseAll()
	end

	self.AllActorVisibility = EActorVisibility.None
	self.PlayerVisibility = EPlayerVisibility.ShowAll
	self.NpcVisibility = ENpcVisibility.ShowAll
	self.TargetNpcEntityID = 0
end

function HUDMgr:OnGameEventPWorldExit(Params)
end

function HUDMgr:OnGameEventSelectTarget(Params)

	local EntityID = Params.ULongParam1
	if self.TargetEntityID == EntityID then
		return
	end

	local _ <close> = CommonUtil.MakeProfileTag("HUDMgrSelectTarget")
	self:UpdateSelectTarget(self.TargetEntityID, false)

	self:UpdateSelectTarget(EntityID, true)

	self.TargetEntityID = EntityID
end

function HUDMgr:OnGameEventUnSelectTarget(Params)
	local EntityID = Params.ULongParam1
	if self.TargetEntityID == EntityID then
		self.TargetEntityID = nil
	end

	self:UpdateSelectTarget(EntityID, false)
end

---OnGameEventCameraPostEffectFadeStart
---@param Params FEventParams
function HUDMgr:OnGameEventCameraPostEffectFadeStart(Params)
	--print("OnGameEventCameraPostEffectFadeStart",Params.IntParam1)

	local FadeTarget = Params.IntParam1

	if FadeTarget == ECameraFadeTargetWhite then
		UHUDMgr:SetDrawFlag(HUDDrawFlagFlyText)
	elseif FadeTarget == ECameraFadeTargetBlack then
		--UIViewMgr:HideAllLayer()
		--self:SetIsDrawHUD(false)
		--CommonUtil.HideJoyStick()
	end

	UIViewMgr:ShowView(UIViewID.CommonMaskPanel)
end

---OnGameEventCameraPostEffectFadeEnd
---@param Params FEventParams
function HUDMgr:OnGameEventCameraPostEffectFadeEnd(Params)
	--print("OnGameEventCameraPostEffectFadeEnd",Params.IntParam1)

	UIViewMgr:HideView(UIViewID.CommonMaskPanel)

	local FadeTarget = Params.IntParam1

	if FadeTarget == ECameraFadeTargetWhite then
		UHUDMgr:SetDrawFlag(HUDDrawFlagAll)
	elseif FadeTarget == ECameraFadeTargetBlack then
		--UIViewMgr:ShowAll()
		--self:SetIsDrawHUD(true)
		--CommonUtil.ShowJoyStick()
	end
end

---OnGameEventTargetChangeActor
function HUDMgr:OnGameEventTargetChangeActor(Params)
	--print(" HUDMgr:OnGameEventTargetChangeActor", Params.EntityID, Params.TargetID)

	local IsStateChange = Params.IsStateChange
	if not IsStateChange then return end

	local EntityID = Params.EntityID
	local TargetID = Params.TargetID

	local ActorInfo = self:GetActorInfo(EntityID)
	if ActorInfo and ActorInfo.HUDType == HUDType.MonsterInfo then
		local ActorVM = ActorInfo.ActorVM
		if ActorVM then
			ActorVM:UpdateUIColor()
		end
	end
end

---OnGameEventVisionUpdateFirstAttacker
---@param Params FEventParams
function HUDMgr:OnGameEventVisionUpdateFirstAttacker(Params)
	--print(" HUDMgr:OnGameEventVisionUpdateFirstAttacker", Params.ULongParam1, Params.ULongParam2)

	local EntityID = Params.ULongParam1

	local ActorInfo = self:GetActorInfo(EntityID)
	if ActorInfo and ActorInfo.HUDType == HUDType.MonsterInfo then
		self:UpdateActorUIColor(EntityID)
	end
end

---OnGameEventComBatStateUpdate
---@param Params FEventParams
function HUDMgr:OnGameEventComBatStateUpdate(Params)
	--print("HUDMgr:OnGameEventComBatStateUpdate", Params.ULongParam1)
	local EntityID = Params.ULongParam1

	--玩家不可选中，才会unselect；  技能不可选中，不影响这里
	local CanSelect = ActorUtil.IsInCanPlayerSelectedState(EntityID)

	if not CanSelect then
		USelectEffectMgr:UnSelectActor(EntityID)
	end

	local ActorVM = self:GetActorVM(EntityID)
	if nil == ActorVM then
		return
	end

	ActorVM:UpdateIsDraw()
end

-- function HUDMgr:OnActiveGatherItemView(EntityID)
-- 	local ActorVM = self:GetActorVM(EntityID)
-- 	if nil == ActorVM then
-- 		return
-- 	end

-- 	ActorVM:UpdateIsDraw(true)

-- 	local Actor = ActorUtil.GetActorByEntityID(EntityID)
-- 	if nil == Actor then
-- 		FLOG_ERROR("OnActiveGatherItemView Actor is nil")
-- 		return
-- 	end

-- 	local AttributeComponent = Actor:GetAttributeComponent()
-- 	if nil == AttributeComponent then
-- 		FLOG_ERROR("OnActiveGatherItemView AttributeComponent is nil")
-- 		return
-- 	end

-- 	local MaxHp = _G.GatherMgr:GetMaxGatherCount(AttributeComponent.ResID)
-- 	ActorVM:UpdateHP(AttributeComponent.PickTimesLeft, MaxHp)

-- 	ActorVM:UpdateNameInfo()
-- end

-- function HUDMgr:OnDeActiveGatherItemView(EntityID)
-- 	local ActorVM = self:GetActorVM(EntityID)
-- 	if nil == ActorVM then
-- 		return
-- 	end

-- 	ActorVM:SetHPBarVisible(false)
-- 	-- ActorVM:UpdateIsDraw(false)
-- end

function HUDMgr:OnGatherAttrChange(Params)
	local EntityID = Params.ULongParam1
	if ActorUtil.GetActorType(EntityID) ~= EActorType.Gather then
		return
	end

	local ActorVM = self:GetActorVM(EntityID)
	if nil == ActorVM then
		return
	end

	ActorVM:OnGatherAttrChange(Params)
end

function HUDMgr:OnQuestUpdate(Params)
	for _, v in pairs(self.ActorInfos) do
		if (v.HUDType == HUDType.NPCInfo)
		or (v.HUDType == HUDType.MonsterInfo)
		or (v.HUDType == HUDType.InteractObjInfo) then
			v.ActorVM:UpdateStateIcon()
		end
	end
end

function HUDMgr:OnUpdateQuestTrack(Params)
	for _, v in pairs(self.ActorInfos) do
		-- 追踪任务会影响图标排序，假设只有npc身上可能有多个任务
		if (v.HUDType == HUDType.NPCInfo) then
			v.ActorVM:UpdateStateIcon()
		end
	end
end

function HUDMgr:OnUpdateTrackQuestTarget()
	local FindTargetNpc = false
	local CurrNavPath = _G.QuestTrackMgr:GetCurrNavPath()
	if CurrNavPath then
		local ResID = CurrNavPath.EndPosActorResID
		if ResID then
			local Actor = ActorUtil.GetActorByResID(ResID)
			if Actor then
				local AttrComp = Actor:GetAttributeComponent()
				if AttrComp then
					local ActorVM = self:GetActorVM(AttrComp.EntityID)
					if ActorVM then
						ActorVM:UpdateStateIcon()
						FindTargetNpc = true
					end
				end
			end
		end
	end
	if not FindTargetNpc then
		for _, v in pairs(self.ActorInfos) do
			if v.HUDType == HUDType.NPCInfo then
				v.ActorVM:UpdateStateIcon()
			end
		end
	end
end

function HUDMgr:OnGameEventClientNpcMoveStart(Params)
    _G.QuestMgr:SetClientNpcMoving(Params.ResID)
	local ActorVM = self:GetActorVM(Params.EntityID)
	if ActorVM then
		ActorVM:UpdateStateIcon()
	end
end

function HUDMgr:OnGameEventClientNpcMoveEnd(Params)
    _G.QuestMgr:SetClientNpcMoving(Params.ResID, false)
	local ActorVM = self:GetActorVM(Params.EntityID)
	if ActorVM then
		ActorVM:UpdateStateIcon()
	end
end

function HUDMgr:OnGameEventMagicCardUpdate(Params)
	local ListEntityIDs = Params
	if nil == ListEntityIDs then
		return
	end

	for i = 1, #ListEntityIDs do
		local EntityID = ListEntityIDs[i]
		local ActorVM = self:GetActorVM(EntityID)
		if ActorVM then
			ActorVM:UpdateStateIcon()
		end
	end
end

function HUDMgr:OnGameEventLeveQuestUpdate(Params)
	local ListEntityIDs = Params
	if nil == ListEntityIDs then
		return
	end

	for i = 1, #ListEntityIDs do
		local NpcID = ListEntityIDs[i].NpcID
		local EntityID = ActorUtil.GetActorEntityIDByResID(NpcID)
		local ActorVM = self:GetActorVM(EntityID)
		if ActorVM then
			ActorVM:UpdateStateIcon()
		end
	end

end

function HUDMgr:OnGameEventMysteryMerchantUpdate(EntityID)
	if EntityID == nil then
		return
	end
	local ActorVM = self:GetActorVM(EntityID)
	if ActorVM then
		ActorVM:UpdateStateIcon()
	end
end

function HUDMgr:OnFateUpdate(Params)
	local ActorVM = self:GetActorVM(Params.EntityID)
	if ActorVM then
		ActorVM:UpdateStateIcon()
	end
end

function HUDMgr:OnGateOppoTaskUpdate(Params)
	local ActorVM = self:GetActorVM(Params.EntityID)
	if ActorVM then
		ActorVM:UpdateStateIcon()
	end
end

function HUDMgr:OnGoldActivityUpdate(Params)
	local ActorVM = self:GetActorVM(Params.EntityID)
	if ActorVM then
		ActorVM:UpdateStateIcon()
	end
end

------ OnlineStatus Begin ------
function HUDMgr:OnMajorPlayerOnlineStatusChanged(Status, OldStatus)
	local _majorEntityID = MajorUtil.GetMajorEntityID()
	local ActorVM = self:GetActorVM(_majorEntityID)
	if nil == ActorVM then
		return
	end
	ActorVM:UpdateOnlineStatus()
end

function HUDMgr:OnGameEventOnlineStatusChangedInVision(Params)
	local ActorVM = self:GetActorVM(Params.EntityID)
	if nil == ActorVM then
		return
	end
	ActorVM:UpdateOnlineStatus()
end

function HUDMgr:UpdateAllActorOnlineStatusVisibility()
	for _, v in pairs(self.ActorInfos) do
		if v.HUDType == HUDType.PlayerInfo and v.ActorVM ~= nil then
			v.ActorVM:UpdateOnlineStatus()
		end
	end
end

------ OnlineStatus End ------


function HUDMgr:OnGameEventRoleIdentityChanged(RoleIDs)
	for _, RoleID in ipairs(RoleIDs) do
		local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID) or 0
		local ActorVM = self:GetActorVM(EntityID)
		if nil ~= ActorVM then
			ActorVM:UpdateUIColor()
			ActorVM:UpdateTitleInfo()
			ActorVM:UpdateOnlineStatus()
			ActorVM:UpdateNameVisible()
		end
		local BuddyEntityID = _G.BuddyMgr:GetBuddyByMaster(EntityID)
		local BuddyVM = self:GetActorVM(BuddyEntityID)
		if nil ~= BuddyVM then
			BuddyVM:UpdateNameVisible()
		end
	end
end

function HUDMgr:OnGameEventRoleLoginRes(Params)
	if Params.bReconnect then
		-- 更新交互目标
		self:SetInteractiveTarget(_G.InteractiveMgr.LastInteractiveObjEntityID or 0)

		if not _G.StoryMgr:SequenceIsPlaying() then
			-- 恢复HUD显示
			self:SetIsDrawHUD(true, HUDConfig.IsDrawFlag.All)
		end
    end
end

function HUDMgr:OnGameEventChocoboRaceHUDUpdate(Params)
	if nil == Params then
		return
	end
	--print("HUDMgr:OnGameEventChocoboRaceStaminaChange", Params.ULongParam2, Params.ULongParam3)

	local EntityID = Params.ULongParam1
	
	local ActorVM = self:GetActorVM(EntityID)
	if nil == ActorVM then
		return
	end

	if _G.ChocoboRaceMgr:IsShowChocoboRacerHUD(EntityID) then
		ActorVM:UpdateChocoboRacerInfo()
	end
end

function HUDMgr:OnGameEventChocoboRaceStaminaChange(Params)
	if nil == Params then
		return
	end
	--print("HUDMgr:OnGameEventChocoboRaceStaminaChange", Params.ULongParam2, Params.ULongParam3)

	local Index = Params.ULongParam1
	local CurStamina = Params.ULongParam2
	local MaxStamina = ChocoboRaceMgr:GetRacerMaxStamina()

	local EntityID = ChocoboRaceMgr:GetEntityIDByIndex(Index)
	local ActorVM = self:GetActorVM(EntityID)
	if nil == ActorVM then
		return
	end

	ActorVM:UpdateHP(CurStamina, MaxStamina)
end

function HUDMgr:OnGameEventMagicCardTourneyRankUpdate(Params)
	if nil == Params then
		return
	end
	
	local EntityIDList = Params.EntityIDList
	for _, EntityID in ipairs(EntityIDList) do
		local ActorVM = self:GetActorVM(EntityID)
		if nil ~= ActorVM then
			--ActorVM:UpdateVM(EntityID, HUDType.PlayerInfo)
			ActorVM:UpdateMagicCardTourneyInfo(Params.IsVisible)
		end
	end
end

---ShowAttackEffect
---@param EntityID number
---@param Value number
---@param Type HUDType
function HUDMgr:ShowAttackEffect(EntityID, Type, Value, Name, Desc, OffsetX, OffsetY, Color, OutlineColor)
	--print("HUDMgr:ShowAttackEffect", EntityID, Type, Value, Name, Desc, OffsetX, OffsetY)

	local Path = HUDConfig:GetPath(Type)
	if nil == Path then
		return
	end

	-- print(string.format("HUDMgr:ShowAttackEffect Path=%s,Type=%s", Path,tostring(Type)))
	local Object = UHUDMgr:CreateFlyText(Type, Path, EntityID, true, true, false)
	if nil == Object then
		return
	end

	local Text = HUDConfig:GetText(Type)
	if nil ~= Text then
		local TextValue = Object:FindWidget("TextValue")
		if nil ~= TextValue then
			UHUDMgr:SetText(TextValue, string.format(Text, Value))
			if nil ~= Color then UHUDMgr:SetColorHex(TextValue, Color) end
			if nil ~= OutlineColor then UHUDMgr:SetTextOutlineColorHex(TextValue, OutlineColor) end
		else
			FLOG_ERROR("HUDMgr:ShowAttackEffect TextValue is nil")
		end
	end

	local TextName = Object:FindWidget("TextName")
	if nil ~= TextName then
		UHUDMgr:SetText(TextName, Name)
		if nil ~= Color then UHUDMgr:SetColorHex(TextName, Color) end
		if nil ~= OutlineColor then UHUDMgr:SetTextOutlineColorHex(TextName, OutlineColor) end
	end

	local TextDesc = Object:FindWidget("TextDesc")
	if nil ~= TextDesc then
		UHUDMgr:SetText(TextDesc, Desc)
		if nil ~= Color then UHUDMgr:SetColorHex(TextDesc, Color) end
		if nil ~= OutlineColor then UHUDMgr:SetTextOutlineColorHex(TextDesc, OutlineColor) end
	end

	if nil ~= OffsetX and nil ~= OffsetY then
		Object:SetOffset(OffsetX, OffsetY)
	end

	Object:UpdateLayout()

	self:AddFlyText(EntityID, Object)
end

function HUDMgr:ShowBufferEffect(EntityID, BufferID, Type, OffsetX, OffsetY, bLifeSkillBuff)
	--print("HUDMgr:ShowBufferEffect", EntityID, BufferID, Type)

	local Path = HUDConfig:GetPath(Type)
	if nil == Path then
		return
	end

	local Object = UHUDMgr:CreateFlyText(Type, Path, EntityID, true, true, false)
	if nil == Object then
		return
	end

	local Cfg
	local IconPath
	local BuffName

	if bLifeSkillBuff then
		Cfg = LifeskillEffectCfg:FindCfgByKey(BufferID)
		if nil == Cfg then
			return
		end

		IconPath = Cfg.Icon or ""
		BuffName = Cfg.Name or ""
	else
		Cfg = BuffCfg:FindCfgByKey(BufferID)
		if nil == Cfg then
			return
		end

		IconPath = Cfg.BuffIcon or ""
		BuffName = Cfg.BuffName or ""
	end

	--print(string.format("HUDMgr:ShowBufferEffect BuffIcon=%s BuffName=%s", IconPath, BuffName))

	local TextureIcon = Object:FindWidget("TextureIcon")
	if nil == TextureIcon then
		FLOG_ERROR("HUDMgr:ShowBufferEffect TextureIcon is nil")
	else
		if string.len(IconPath) <= 0 then
			FLOG_ERROR("HUDMgr:ShowBufferEffect BuffIcon is empty, ID=%d", BufferID)
		else
			UHUDMgr:SetTextureFromAssetPath(TextureIcon, IconPath)
		end
	end

	local TextValue = Object:FindWidget("TextValue")
	if nil == TextureIcon then
		FLOG_ERROR("HUDMgr:ShowBufferEffect TextValue is nil")
	else
		local Text = HUDConfig:GetText(Type)
		UHUDMgr:SetText(TextValue, string.format(Text, BuffName))
	end

	if nil ~= OffsetX and nil ~= OffsetY then
		Object:SetOffset(OffsetX, OffsetY)
	end

	Object:UpdateLayout()

	self:AddFlyText(EntityID, Object)
end

---ShowLifeSkillFlyText 生活职业数值飘字，包括制作时的进度、品质提升数值，采集收藏品提纯时的数值
---@param EntityID number
---@param Value number
---@param Type HUDType
function HUDMgr:ShowLifeSkillFlyText(EntityID, Type, Value)
	local Path = HUDConfig:GetPath(Type)
	if nil == Path then
		return
	end

	local Object = UHUDMgr:CreateFlyText(Type, Path, EntityID, true, true, false)
	if nil == Object then
		return
	end

	local Text = HUDConfig:GetText(Type)
	if nil ~= Text then
		local TextValue = Object:FindWidget("TextValue")
		if nil == TextValue then
			FLOG_ERROR("HUDMgr:ShowLifeSkillFlyText TextValue is nil")
		else
			UHUDMgr:SetText(TextValue, string.format(Text, Value))
		end
	end

	Object:UpdateLayout()

	self:AddFlyText(EntityID, Object)
end

local function ShouldCreateActorInfo(EntityID)
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if nil == Actor then
		return false
	end

	local AttrComp = Actor:GetAttributeComponent()
	local ActorType = AttrComp:GetActorType()

	if EActorType.NPC == ActorType then
		local Cfg = NpcCfg:FindCfgByKey(AttrComp.ResID)
		if nil == Cfg then
			return false
		end

		-- 如果是陆行鸟竞赛，AI是npc类型，需要显示HUD，目前这个场景不会有其他NPC，先这样处理
		if _G.ChocoboRaceMgr:IsChocoboRacePWorld() then
			return true
		end

		if #(Cfg.InteractiveIDList or {}) == 0 and string.isnilorempty(Cfg.Name) and string.isnilorempty(Cfg.Title) then
			return false
		end
	-- elseif EActorType.EObj == ActorType then
	-- 	if EObjCfg:FindValue(AttrComp.ResID, "IsShowNameBoard") == 0 then
	-- 		return false
	-- 	end
	elseif nil == ActorType then
		return false
	end

	return true
end

---ShowActorInfo
---@param EntityID number
---@return ActorInfo
function HUDMgr:ShowActorInfo(EntityID)
	--print("HUDMgr:ShowActorInfo")
	if nil ~= self:GetActorVM(EntityID) then
		FLOG_WARNING("HUDMgr:ShowActorInfo(): ActorInfo Already exist. EntityID: %s.", tostring(EntityID))
		--ActorVM:UpdateVM(EntityID)
		return
	end

	if not ShouldCreateActorInfo(EntityID) then
		return
	end

	local Type = self:GetActorInfoType(EntityID)
	if nil == Type then
		return
	end

	local Path = HUDConfig:GetPath(Type)
	if nil == Path then
		return
	end

	-- loiafeng: Debug Log
	-- _G.FLOG_WARNING("HUDMgr:ShowActorInfo Entity is %d, Major EntityID is %d", EntityID, MajorUtil.GetMajorEntityID())

	-- loiafeng: 主角的HUD有时候会出现多个重叠在一起的情况
	if MajorUtil.GetMajorEntityID() == EntityID and self.MajorEntityIDCache ~= EntityID then
		local MajorActorVM = self:GetActorVM(self.MajorEntityIDCache)
		if nil ~= MajorActorVM then
			FLOG_WARNING("HUDMgr:ShowActorInfo(): hide last MajorActorInfo. Last EntityID: %s. Curr EntityID: %s.", tostring(self.MajorEntityIDCache), tostring(EntityID))
			self:HideActorInfo(self.MajorEntityIDCache)
		end
		self.MajorEntityIDCache = EntityID
	end

	--这个创建的耗时很小，才0.06毫秒左右； 下面VM和View的new才是大头，后者更大
	local Object = UHUDMgr:CreateActorInfo(Type, Path, EntityID, false, false, true)

	-- added for performance tag, DO NOT REMOVE!
	local _ <close> = CommonUtil.MakeProfileTag("HUDMgr:ShowActorInfo")

	local ActorVM = ObjectPoolMgr:AllocObject(HUDActorVM)
	ActorVM:UpdateVM(EntityID, Type)

	local ActorView = ObjectPoolMgr:AllocObject(HUDActorView)
	ActorView:InitView(Object, ActorVM, EntityID)

	local ActorInfo = { ActorVM = ActorVM, ActorView = ActorView, HUDType = Type, TargetID = 0 }

	self.ActorInfos[EntityID] = ActorInfo

	-- added for performance tag, DO NOT REMOVE!
end

function HUDMgr:GetActorInfoType(EntityID)
	local AttributeComponent = ActorUtil.GetActorAttributeComponent(EntityID)
	if nil == AttributeComponent then
		return
	end

	local ActorType = AttributeComponent:GetActorType()
	--print("ActorType", ActorType)
	if EActorType.Major == ActorType then
		if UTestMgr.bHideMajorInfo == true then
			return
		end
		return HUDType.PlayerInfo
	elseif EActorType.Player == ActorType then
		return HUDType.PlayerInfo
	elseif EActorType.Monster == ActorType then
		if not self:IsNeedShowMonsterInfo(AttributeComponent.ResID) then
			return
		end
		return HUDType.MonsterInfo
	elseif EActorType.Companion == ActorType then
		return HUDType.CompanionInfo
	elseif EActorType.Gather == ActorType then
		return HUDType.GatherInfo
	elseif EActorType.EObj == ActorType then
		local EObj = ActorUtil.GetActorByEntityID(EntityID) or {}
		if EObj.EObjType == ProtoRes.ClientEObjType.ClientEObjTypeHousingOrnament then
			return HUDType.HouseObjInfo
		end
		return HUDType.InteractObjInfo
	else
		if _G.ChocoboRaceMgr:IsChocoboRacePWorld() then
			if AttributeComponent.RoleID == 0 then --陆行鸟AI
				return HUDType.PlayerInfo
			end
		end
		return HUDType.NPCInfo
	end
end

---HideActorInfo
---@param EntityID number
function HUDMgr:HideActorInfo(EntityID)
	local _ <close> = CommonUtil.MakeProfileTag("HUDMgr:HideActorInfo")

	local ActorInfo = self:GetActorInfo(EntityID)
	if nil == ActorInfo then
		return
	end

	local ActorView = ActorInfo.ActorView

	do
		local _ <close> = CommonUtil.MakeProfileTag("HUDMgr:HideActorInfo_ReleaseCppObject")
		UHUDMgr:ReleaseObject(ActorView.Object)
	end

	ActorView:DestroyView()

	self.ActorInfos[EntityID] = nil

	local _ <close> = CommonUtil.MakeProfileTag("HUDMgr:HideActorInfo_FreeLuaObject")

	ObjectPoolMgr:FreeObject(HUDActorView, ActorView)
	ObjectPoolMgr:FreeObject(HUDActorVM, ActorInfo.ActorVM)
	--print("HUDMgr:HideActorInfo length=", table.length(self.ActorInfos))
end

function HUDMgr:OnActorDead(EntityID)
	local ActorVM = self:GetActorVM(EntityID)
	if nil == ActorVM then
		return
	end

	ActorVM:UpdateSelectTarget(false)

	ActorVM:UpdateUIColor()
end

function HUDMgr:IsNeedShowMonsterInfo(ResID)
	local IsHideName = MonsterCfg:FindValue(ResID, "IsHideName")
	--print("HUDMgr:IsNeedShowMonsterInfo", ResID, IsHideName)
	if IsHideName ~= 0 then
		return false
	end

	return true
end

function HUDMgr:UpdateSelectTarget(EntityID, IsSelected)
	local ActorVM = self:GetActorVM(EntityID)
	if nil == ActorVM then
		return
	end

	ActorVM:UpdateSelectTarget(IsSelected)

	if IsSelected then
		TargetMgr:UpdateHardLockEffectColor(ActorVM.SelectArrowColor)
	end
end

function HUDMgr:GetHUDRandomOffset()
	local x = math.random(0, 80)
	local y = math.random(0, 60)

	return x, y
end

---GetFlyTextOffset
---@param EntityID number
---@return number
function HUDMgr:GetFlyTextOffset(EntityID)
	local ResID = ActorUtil.GetActorResID(EntityID)
	if ResID and ResID > 0 then
		return (MonsterCfg:FindValue(ResID, "FloatingCharacterSite") or 0)
	end
	return 0
end

---GetEffectFlyTextOffset
---@param EntityID number
---@param IsMajor boolean
---@param IsFromSkill boolean
---@return number, number
function HUDMgr:GetEffectFlyTextOffset(EntityID, IsMajor, IsFromSkill)
	local ResultX = 0
	local ResultY = self:GetFlyTextOffset(EntityID)

	-- 非主角的Buff效果，需要随机进行偏移
	if not IsMajor and not IsFromSkill then
		local RandomX, RandomY = self:GetHUDRandomOffset()
		ResultX = RandomX + ResultX
		ResultY = RandomY + ResultY
	end

	return ResultX, ResultY
end

---GetFlyTextName
---@param SkillType number
---@param SkillID number
---@param TipsID number
function HUDMgr:GetFlyTextName(SkillType, SkillID, TipsID)
	-- 优先显示TipsID对应的伤害描述
	if TipsID and TipsID ~= 0 then
		return HurtDescriptionCfg:FindValue(TipsID, "Desc")
	end

	if SkillID and SkillID ~= 0 then
		-- 普攻不显示技能名
		return (SkillType ~= ProtoRes.skill_type.SKILL_TYPE_NORMAL) and SkillMainCfg:GetSkillName(SkillID) or ""
	end

	return ""
end

---GetFlyTextName
---@param EffectType ProtoCS.CS_ATTACK_EFFECT
---@param IsMajor boolean
---@param IsFromSkill boolean Skill or Buff
---@param SkillType ProtoCS.CS_ATTACK_EFFECT
---@param HUDTypeOffset number 普通 - 直击 - 暴击 - 直击暴击 的偏移
---@return HUDType|nil
function HUDMgr:GetFlyTextHUDType(EffectType, IsMajor, IsFromSkill, SkillType, HUDTypeOffset)
	HUDTypeOffset = HUDTypeOffset or 0

	if ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_HP_DAMAGE == EffectType 
	or ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_ATTACH_HP_DAMAGE == EffectType
	or ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_SHIELD_COST == EffectType then
		-- Buff效果和技能显示不同的样式
		if IsFromSkill then
			-- 普攻和技能显示不同的样式
			if SkillType ~= ProtoRes.skill_type.SKILL_TYPE_NORMAL then
				return (IsMajor and HUDType.MajorHPDamage1 or HUDType.MonsterHPDamage1) + HUDTypeOffset
			else
				return (IsMajor and HUDType.MajorHPDamage5 or HUDType.MonsterHPDamage5) + HUDTypeOffset
			end
		else
			return IsMajor and HUDType.MajorHPDamage1 or HUDType.MonsterHPDamage9
		end
	elseif ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_HP_HEAL == EffectType or
	ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_BLOOD_DRAIN == EffectType or
	ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_MP_HEAL == EffectType then
		if IsFromSkill then
			return (IsMajor and HUDType.MajorHPHeal1 or HUDType.ActorHPHeal1) + HUDTypeOffset
		else
			return IsMajor and HUDType.MajorHPHeal1 or HUDType.ActorHPHeal1
		end

	-- 霸体、躲避、无敌仅对技能有效，对Buff无效
	elseif ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_DODGE == EffectType and IsFromSkill then
		return IsMajor and HUDType.MajorDodge or HUDType.MonsterDodge
	elseif ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_SUPERMAN == EffectType and IsFromSkill then
		return IsMajor and HUDType.MajorSuperman or HUDType.MonsterSuperman
	elseif ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_ATTACK_INVALID == EffectType and IsFromSkill then
		return IsMajor and HUDType.MajorInvalid or HUDType.MonsterInvalid

	-- 回复药临时方案，需求单ID: 884071563
	elseif ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_ATTR_HP == EffectType then
		return HUDType.MajorHPHeal1
	elseif ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_ATTR_MP == EffectType then
		return HUDType.MajorHPDamage5

	else
		return HUDType.None
	end
end

function HUDMgr:SetSpectrumParams(EntityID, Amount, Visible, Color, Texture, BgTexture, TextureSize, Padding)
	-- by yuhang@lightpaw  陆行鸟的地图不需要显示
	if _G.ChocoboRaceMgr:IsChocoboRacePWorld() then
		return
	end
	
	local ActorVM = self:GetActorVM(EntityID)
	if nil == ActorVM then
		-- 角色创建现采用分帧处理，这里的时机有可能早于角色创建，故加入参数缓存机制，延迟到MajorCreate中处理（暂时仅处理Major）
		if MajorUtil.IsMajor(EntityID) then
			local NewParams = table.pack(Amount, Visible, Color, Texture, BgTexture, TextureSize, Padding)
			local CachedParams = self.MajorSpectrumParams
			if CachedParams ~= nil then
				for i = 1, 7 do
					NewParams[i] = NewParams[i] or CachedParams[i]
				end
			end
			self.MajorSpectrumParams = NewParams
		end
		return
	end

	if nil ~= Texture then
		ActorVM.SpectrumAsset = Texture
	end
	if nil ~= BgTexture then
		ActorVM.SpectrumBgAsset = BgTexture
	end
	if nil ~= Color then
		ActorVM.SpectrumColor = Color
	end
	if nil ~= Amount then
		ActorVM.SpectrumAmount = Amount
	end
	if nil ~= Visible then
		ActorVM.SpectrumVisible = Visible
	end
	if nil ~= TextureSize then
		ActorVM.SpectrumTextureSize = TextureSize
	end
	if nil ~= Padding then
		ActorVM.SpectrumPadding = Padding
	end
end

function HUDMgr:SetHPBarVisible(EntityID, bVisible)
	local ActorVM = self:GetActorVM(EntityID)
	if nil == ActorVM then
		return
	end
	ActorVM.HPBarVisible = bVisible
end

function HUDMgr:UpdateNameInfo(EntityID)
	local ActorVM = self:GetActorVM(EntityID)
	if nil ~= ActorVM then
		ActorVM:UpdateNameInfo()
	end
end

--region 显隐接口

---SetIsDrawHUD @设置所有HUD信息可见性，包括角色头顶UI、飘字和浮标
---@param IsDraw boolean
---@param Flag number @see HUDConfig.IsDrawFlag
function HUDMgr:SetIsDrawHUD(IsDraw, Flag)
	FLOG_INFO("HUDMgr:SetIsDrawHUD(%s, %s)", tostring(IsDraw), tostring(Flag))
	if nil ~= UHUDMgr then
		Flag = Flag or HUDConfig.IsDrawFlag.Common
		if IsDraw then
			self.IsDrawFlags = self.IsDrawFlags | Flag
		else
			self.IsDrawFlags = self.IsDrawFlags & (~Flag)
		end
		UHUDMgr:SetIsDrawHUD(self.IsDrawFlags == HUDConfig.IsDrawFlag.All)
	end
end

---SetActorInfoVisible    @设置所有角色（玩家、NPC、怪物等）头顶UI可见性，不包括飘字和浮标
---@param IsVisible boolean
function HUDMgr:SetActorInfoVisible(IsVisible)
	FLOG_INFO("HUDMgr:SetActorInfoVisible(%s)", tostring(IsVisible))
	UHUDMgr:SetItemVisible(EHUDItemType.ActorInfo, IsVisible)
end

function HUDMgr:IsShowActor(EntityID)
	if self.AllActorVisibility == EActorVisibility.HideAll then
		return false
	elseif self.AllActorVisibility == EActorVisibility.ShowAll then
		return true
	end

	local IsMajor = ActorUtil.IsMajor(EntityID)
	local IsPlayer = ActorUtil.IsPlayer(EntityID)

	if IsMajor or IsPlayer then
		local PlayerVisibility = self.PlayerVisibility

		if PlayerVisibility == EPlayerVisibility.ShowAll then
			return true
		elseif PlayerVisibility == EPlayerVisibility.HideAll then
			return false
		elseif PlayerVisibility == EPlayerVisibility.HideOther then
			return IsMajor
		end

		return true
	end

	local IsNpc = ActorUtil.IsNpc(EntityID)
	if IsNpc then
		local NpcVisibility = self.NpcVisibility

		if NpcVisibility == ENpcVisibility.ShowAll then
			return true
		elseif NpcVisibility == ENpcVisibility.HideAll then
			return false
		elseif NpcVisibility == ENpcVisibility.ShowTargetOnly then
			return self.TargetNpcEntityID == EntityID
		end

		return true
	end

	return true
end

function HUDMgr:OnPlayerVisibilityChanged()
	if nil == self.ActorInfos then
		return
	end

	for _, v in pairs(self.ActorInfos) do
		if v.HUDType == HUDType.PlayerInfo then
			v.ActorVM:UpdateIsDraw()
		end
	end
end

function HUDMgr:OnNpcVisibilityChanged()
	for _, v in pairs(self.ActorInfos) do
		if v.HUDType == HUDType.NPCInfo then
			v.ActorVM:UpdateIsDraw()
		end
	end
end

function HUDMgr:HideAllActors()
	FLOG_INFO("HUDMgr:HideAllActors()")
	self.AllActorVisibility = EActorVisibility.HideAll
	for _, v in pairs(self.ActorInfos) do
		v.ActorVM:UpdateIsDraw()
	end
end

function HUDMgr:ShowAllActors()
	FLOG_INFO("HUDMgr:ShowAllActors()")
	self.AllActorVisibility = EActorVisibility.ShowAll
	for _, v in pairs(self.ActorInfos) do
		v.ActorVM:UpdateIsDraw()
	end
	self.AllActorVisibility = EActorVisibility.None
end

---SetPlayerInfoVisible    @设置玩家头顶信息可见性
---@param IsVisible boolean
function HUDMgr:SetPlayerInfoVisible(IsVisible)
	if IsVisible then
		self:ShowAllPlayer()
	else
		self:HideAllPlayer()
	end
end

---ShowAllPlayer 显示所有玩家头顶信息 包含主角和其他玩家
function HUDMgr:ShowAllPlayer()
	FLOG_INFO("HUDMgr:ShowAllPlayer()")
	self.PlayerVisibility = EPlayerVisibility.ShowAll
	self:OnPlayerVisibilityChanged()
end

---HideAllPlayer 隐藏所有玩家头顶信息 包含主角和其他玩家
function HUDMgr:HideAllPlayer()
	FLOG_INFO("HUDMgr:HideAllPlayer()")
	self.PlayerVisibility = EPlayerVisibility.HideAll
	self:OnPlayerVisibilityChanged()
end

---HideOtherPlayer 隐藏除了主角外所有玩家头顶信息
function HUDMgr:HideOtherPlayer()
	FLOG_INFO("HUDMgr:HideOtherPlayer()")
	self.PlayerVisibility = EPlayerVisibility.HideOther
	self:OnPlayerVisibilityChanged()
end


---ShowAllNpc 显示所有Npc头顶信息
function HUDMgr:ShowAllNpc()
	FLOG_INFO("HUDMgr:ShowAllNpc()")
	self.NpcVisibility = ENpcVisibility.ShowAll
	self:OnNpcVisibilityChanged()
end

---ShowAllNpc 隐藏所有Npc头顶信息
function HUDMgr:HideAllNpc()
	FLOG_INFO("HUDMgr:HideAllNpc()")
	self.NpcVisibility = ENpcVisibility.HideAll
	self:OnNpcVisibilityChanged()
end

---HideAllPlayer 只显示目标Npc头顶信息
function HUDMgr:ShowTargetNpcOnly(EntityID)
	FLOG_INFO("HUDMgr:ShowTargetNpcOnly(%s)", tostring(EntityID))
	self.TargetNpcEntityID = EntityID
	self.NpcVisibility = ENpcVisibility.ShowTargetOnly
	self:OnNpcVisibilityChanged()
end

function HUDMgr:UpdateActorVisibility(EntityID, StateVisible, NameVisible)
	FLOG_INFO("HUDMgr:UpdateActorVisibility(%s, %s, %s)", tostring(EntityID), tostring(StateVisible), tostring(NameVisible))
	local ActorVM = self:GetActorVM(EntityID)
	if nil == ActorVM then
		return
	end

	if nil ~= StateVisible then
		ActorVM.StateVisible = StateVisible
	end

	if nil ~= NameVisible then
		ActorVM.NameVisible = NameVisible
	end
end

--regionend

---UpdateActorUIColor 更新UI颜色
function HUDMgr:UpdateActorUIColor(EntityID)
	local ActorVM = self:GetActorVM(EntityID)
	if nil ~= ActorVM then ActorVM:UpdateUIColor() end
end

function HUDMgr:OnCampChange(Params)
    local EntityID = Params.ULongParam1
    local bMajor = Params.BoolParam1
	if bMajor then
		for _, ActorInfo in pairs(self.ActorInfos) do
			ActorInfo.ActorVM:UpdateUIColor()
		end
	else
		self:UpdateActorUIColor(EntityID)
	end
end

function HUDMgr:UpdateAllActorNameVisibility()
	for _, ActorInfo in pairs(self.ActorInfos) do
		ActorInfo.ActorVM:UpdateNameVisible()
	end
end

function HUDMgr:UpdateAllActorTitleVisibility()
	for _, v in pairs(self.ActorInfos) do
		if v.HUDType == HUDType.PlayerInfo then
			v.ActorVM:UpdateTitleInfo()
		end
	end
end

function HUDMgr:UpdateTitleInfo(EntityID)
	local ActorVM = self:GetActorVM(EntityID)
	if nil == ActorVM then
		return
	end

	ActorVM:UpdateTitleInfo()
end

function HUDMgr:OnGameEventTitleChange(Params)
	self:UpdateTitleInfo(Params.EntityID)
end

function HUDMgr:OnGameEventActorUIColorConfigChanged(Params)
	local ActorUIType = Params and Params.ActorUIType

	if nil == ActorUIType then return end

	for _, ActorInfo in pairs(self.ActorInfos) do
		if ActorInfo.ActorVM.ActorUIType == ActorUIType then
			ActorInfo.ActorVM:UpdateUIColor()
		end
	end
end

function HUDMgr:OnGameEventCollectionScour(Params)
	if nil == Params then return end

	local Value = (Params.CurrentVal or 0) - (Params.LastVal or 0)
	if Value <= 0 then return end

	-- 需要根据是否暴击显示不同样式
	self:ShowLifeSkillFlyText(MajorUtil.GetMajorEntityID(), Params.ValueUp and HUDType.LifeSkillFlyText2 or HUDType.LifeSkillFlyText1, Value)
end

function HUDMgr:OnGameEventCrafterSkillRsp(Params, _, FlyTextDelay)
	if nil == Params then return end
	FlyTextDelay = FlyTextDelay or 0

	local Features = (Params.CrafterSkill or {}).Features
	if nil == Features then return end

	local Quality = Features[ProtoCS.FeatureType.FEATURE_TYPE_QUALITY] or 0
	local QualityDelta = Quality - (self.LastCrafterSkillQuality or 0)
	self.LastCrafterSkillQuality = Quality

	local Progress = Features[ProtoCS.FeatureType.FEATURE_TYPE_PROGRESS] or 0
	local ProgressDelta = Progress - (self.LastCrafterSkillProgress or 0)
	self.LastCrafterSkillProgress = Progress

	_G.TimerMgr:AddTimer(self, function()
		if QualityDelta > 0 then
			self:ShowLifeSkillFlyText(MajorUtil.GetMajorEntityID(), HUDType.LifeSkillFlyText3, QualityDelta)
		end

		if ProgressDelta > 0 then
			self:ShowLifeSkillFlyText(MajorUtil.GetMajorEntityID(), HUDType.LifeSkillFlyText1, ProgressDelta)
		end
	end, FlyTextDelay, 0, 1)
end

function HUDMgr:OnGameEventOnNormalMakeStart()
	-- 重置缓存的能工巧匠进度和品质
	self.LastCrafterSkillProgress = 0
	self.LastCrafterSkillQuality = 0
end

function HUDMgr:OnGameEventTouringBandTargetMarkIconChanged(Params)
	local EntityID = Params.EntityID
	local ActorInfo = self:GetActorInfo(EntityID)
	if ActorInfo == nil or ActorInfo.ActorVM == nil or ActorInfo.ActorView == nil then
		return
	end

	ActorInfo.ActorVM:UpdateStateIcon()
	ActorInfo.ActorView:PlayAnimTouringBandIn(Params.Rate or 1.0)
end

function HUDMgr:OnGameEventTeamTargetMarkStateChanged(Params)
	local EntityID = Params and Params.EntityID
	local ActorVM = self:GetActorVM(EntityID)
	if nil ~= ActorVM then
		ActorVM:UpdateTargetMarkState(Params.IconID)
		ActorVM:UpdateStateIcon()
	end
end

function HUDMgr:OnGameEventMountCall(Params)
	local EntityID = Params and Params.EntityID
	local Eid = Params.Pos == 0 and "EID_UI_NAME_MNT" or string.format("EID_UI_NAME_MNT%02d", Params.Pos + 1)
	self:SetEidMountPoint(EntityID, Eid)
end

function HUDMgr:OnGameEventMountBack(Params)
	local EntityID = Params and Params.EntityID
	if EntityID ~= 0 and ActorUtil.IsPlayerOrMajor(EntityID) then
		if _G.EmotionMgr:IsSitState(EntityID) then
			--若正在播放情感动作，在断线重连时应避免下面把现有的EID覆盖掉了
			return
		end
	end
	self:ResetEidMountPoint(EntityID)
end

function HUDMgr:OnGameEventShowSpeechBubble(Params)
	local EntityID = Params and Params.EntityID
	local ActorVM = self:GetActorVM(EntityID)
	if nil ~= ActorVM then
		ActorVM:UpdateTargetMarkStateVisible(false)
		ActorVM:UpdateStateIconVisbible(false)
	end
end

function HUDMgr:OnGameEventHideSpeechBubble(Params)
	local EntityID = Params and Params.EntityID
	local ActorVM = self:GetActorVM(EntityID)
	if nil ~= ActorVM then
		ActorVM:UpdateTargetMarkStateVisible(true)
		ActorVM:UpdateStateIconVisbible(true)
	end
end

function HUDMgr:OnGameEventVisionAvatarDataSync(Params)
	local EntityID = Params.ULongParam1
	local ActorVM = self:GetActorVM(EntityID)
	if nil ~= ActorVM then
		ActorVM:UpdateArmyShortName()
	end
end

function HUDMgr:OnGameEventVisionChocoboChange(Params)
	local MasterID = Params.ULongParam1
	local EntityID = _G.BuddyMgr:GetBuddyByMaster(MasterID)
	local ActorVM = self:GetActorVM(EntityID)
	if nil ~= ActorVM then
		ActorVM:UpdateNameInfo()
	end
end

function HUDMgr:OnGameEventBuddyQueryInfo()
	local EntityID = _G.BuddyMgr:GetBuddyByMaster(MajorUtil.GetMajorEntityID())
	local ActorVM = self:GetActorVM(EntityID)
	if nil ~= ActorVM then
		ActorVM:UpdateNameInfo()
	end
end

function HUDMgr:OnGameEventArmySelfArmyAliasUpdate(ArmyShortName)
	local ActorVM = self:GetActorVM(MajorUtil.GetMajorEntityID())
	if nil ~= ActorVM then
		ActorVM:UpdateArmyShortName(ArmyShortName)
	end
end

function HUDMgr:OnGameEventSelfArmyIDUpdate()
	for EntityID, ActorInfo in pairs(self.ActorInfos) do
		if ActorUtil.IsEObj(EntityID) then
			ActorInfo.ActorVM:UpdateIsDraw()
		end
	end
end

function HUDMgr:OnGameEventTriggerObjInteractive(Params)
	if Params.IsActive then
		self:SetInteractiveTarget(Params.EntityID)
	elseif self.InteractiveTargetEntityID == Params.EntityID then
		self:SetInteractiveTarget(0)
	end
end

function HUDMgr:OnGameEventBuddyCreate(Params)
	local EntityID = Params.ULongParam1
	local ActorVM = self:GetActorVM(EntityID)
	if nil ~= ActorVM then
		ActorVM:UpdateNameInfo()
		ActorVM:UpdateNameVisible()
		ActorVM:UpdateTitleInfo()
	end
end

function HUDMgr:SetInteractiveTarget(EntityID)
	local LastEntityID = self.InteractiveTargetEntityID
	self.InteractiveTargetEntityID = EntityID or 0

	local LastActorVM = self:GetActorVM(LastEntityID)
	if nil ~= LastActorVM then
		LastActorVM:UpdateIsInteractiveTarget()
	end

	local CurrActorVM = self:GetActorVM(self.InteractiveTargetEntityID)
	if nil ~= CurrActorVM then
		CurrActorVM:UpdateIsInteractiveTarget()
	end
end

function HUDMgr:SetEidMountPoint(EntityID, Eid)
	local VM = self:GetActorVM(EntityID)
	if nil ~= VM then
		VM:SetEidMountPoint(Eid)
	end
end

function HUDMgr:ResetEidMountPoint(EntityID)
	local VM = self:GetActorVM(EntityID)
	if nil ~= VM then
		VM:ResetEidMountPoint()
	end
end

function HUDMgr:SetOffsetY(EntityID, OffsetY)
	local VM = self:GetActorVM(EntityID)
	if nil ~= VM then
		VM:SetOffsetY(OffsetY)
	end
end

function HUDMgr:UpdateIsDraw(EntityID)
	local VM = self:GetActorVM(EntityID)
	if nil ~= VM then
		VM:UpdateIsDraw()
	end
end

function HUDMgr:UpdateMajorEntityID(NewEntityID)
	if self.MajorEntityIDCache == NewEntityID then
		return
	end

	self:ShowActorInfo(NewEntityID)
end

---内部使用，只做了开启接口，没有关闭接口，重启游戏即可恢复正常
function HUDMgr:SetAllHUDFontForAozy(bUseAozyFont)
	local Fun = UHUDMgr:SetAllHUDFontForAozy()
	if nil ~= Fun then
		Fun(self)
	end
end

function HUDMgr:UpdateActorInfoCombatState(EntityID)
	local ActorInfo = self:GetActorInfo(EntityID)
	if nil == ActorInfo or ActorInfo.HUDType ~= HUDType.PlayerInfo then
		return
	end

	local CurrTime = TimeUtil:GetServerTime() * 1000
	local ExpdTime = 0
	local CombatStateID = -1

	local CombatBuffInfos = _G.SkillBuffMgr:GetActorBuffInfos(EntityID)
	for _, BuffInfo in ipairs(CombatBuffInfos or {}) do
		if BuffInfo.ExpdTime > ExpdTime and BuffInfo.ExpdTime > CurrTime + 100 then
			-- 策划希望不配置时默认值不为0，故该字段为string类型
			local DisplayCombatStatID = tonumber(BuffCfg:FindValue(BuffInfo.BuffID, "DisplayCombatStatID") or "")
			if nil ~= DisplayCombatStatID then
				CombatStateID = DisplayCombatStatID
				ExpdTime = BuffInfo.ExpdTime
			end
		end
	end

	ActorInfo.ActorVM:SetCombatStateID(CombatStateID)
	ActorInfo.ActorView:PlayAnimCombatStateProBar(1000 / (ExpdTime - CurrTime))
end

function HUDMgr:SetMemberFlyTextVisible(bVisible)
	self.bMemberFlyTextVisible = bVisible
end

return HUDMgr
