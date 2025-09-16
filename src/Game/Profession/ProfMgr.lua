--
-- Author: lydianwang
-- Date: 2021-08-12
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIViewMgr = require("UI/UIViewMgr")
local ActorMgr = require("Game/Actor/ActorMgr")
local MajorUtil = require("Utils/MajorUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")
local EffectUtil = require("Utils/EffectUtil")
local TeamDefine = require("Game/Team/TeamDefine")
local ActorUtil = require("Utils/ActorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProfDefine = require("Game/Profession/ProfDefine")
local ChatMgr = require("Game/Chat/ChatMgr")
local ProfUtil = require("Game/Profession/ProfUtil")
local AudioUtil = require("Utils/AudioUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local ProtoRes = require("Protocol/ProtoRes")

local RoleInitCfg = require("TableCfg/RoleInitCfg")
local PworldCfg = require("TableCfg/PworldCfg")
local ProfClassCfg = require("TableCfg/ProfClassCfg")
local LevelExpCfg = require("TableCfg/LevelExpCfg")
local EquipmentDefine = require("Game/Equipment/EquipmentDefine")
local SkillLogicMgr = require("Game/Skill/SkillLogicMgr")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local SkillObjectMgr = require("Game/Skill/SkillAction/SkillObjectMgr")

local CS_CMD = ProtoCS.CS_CMD
local ProfSubMsg = ProtoCS.ProfSubMsg
local LSTR = _G.LSTR
local LevelUpAudioPath = "AkAudioEvent'/Game/WwiseAudio/Events/sound/zingle/Zingle_LvUP_CountStop/Play_Zingle_LvUP_CountStop.Play_Zingle_LvUP_CountStop'"

---@class ProfMgr : MgrBase
local ProfMgr = LuaClass(MgrBase)

function ProfMgr:OnInit()
	self.LevelUpNetMsg = {}
	self.Blur = false
end

function ProfMgr:OnBegin()
	self.LastOtherCharacterSwitchTime = 0
	self.LastProfSwitchReason = nil
	self.btProfSwitchByActice = false
end

function ProfMgr:OnEnd()
end

function ProfMgr:OnShutdown()

end

function ProfMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PROF, ProfSubMsg.ProfSubMsgActive, self.OnNetMsgProfActivate)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PROF, ProfSubMsg.ProfSubMsgSwitch, self.OnNetMsgProfSwitch)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PROF, ProfSubMsg.ProfSubMsgLevelUp, self.OnNetMsgLevelUpPre)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUERY_ROLEDETAIL, 0, self.OnNetMsgQueryRoleDetail)
end

function ProfMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OtherCharacterSwitch, self.OnOtherCharacterSwitch)
	self:RegisterGameEvent(_G.EventID.VisionLevelChange, self.OnOtherCharacterLevelChange)
	self:RegisterGameEvent(_G.EventID.MajorExpUpdate, self.OnMajorExpUpdate)
	self:RegisterGameEvent(_G.EventID.LeveQuestExpUpdate, self.OnMajorOhterExpUpdate) -- 经验变动
	self:RegisterGameEvent(_G.EventID.OnEmotionPanelClose, self.OnEmotionPanelClose)
end

function ProfMgr:SetCurUIActor(UIActor)
	self.CurUIActor = UIActor
end

function ProfMgr:OnOtherCharacterSwitch(Params)
	local CurTime = _G.TimeUtil:GetLocalTimeMS()
	--保证只有1个在表现
	if CurTime - self.LastOtherCharacterSwitchTime <= 1000 then
		return
	end

	self.LastOtherCharacterSwitchTime = CurTime
	--队友才有音效
	local EntityID = Params.ULongParam1
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if _G.TeamMgr:IsTeamMemberByEntityID(EntityID) then
		if Actor then
			--播放转职音效
			_G.SingBarMgr:PlaySound(EntityID, TeamDefine.ProfChgSound)
		end
	end

	if Actor then
		local VfxParameter = _G.UE.FVfxParameter()
		VfxParameter.VfxRequireData.VfxTransform = Actor:GetTransform()
		VfxParameter.VfxRequireData.EffectPath = TeamDefine.ProfChgEffect
		VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_ProfMgr
		local AttachPointType_Body = _G.UE.EVFXAttachPointType.PlaySourceType_Equip
		VfxParameter:SetCaster(Actor, 0, AttachPointType_Body, 0)
		self.ProfChgEffectID = EffectUtil.PlayVfx(VfxParameter)
	end
end

function ProfMgr:OnOtherCharacterLevelChange(Params)
	if nil == Params or nil == Params.ULongParam1 or nil == Params.ULongParam2 then
		return
	end

	local Reason = Params.ULongParam2
	if Reason == ProtoCS.LevelUpReason.LevelUpReasonProf then
		local EntityID = Params.ULongParam1
		local AttrCom = ActorUtil.GetActorAttributeComponent(EntityID)
		if nil ~= AttrCom then
			local ProfID = Params.ULongParam3 ~= AttrCom.ProfID and Params.ULongParam3 or nil
			local OldLevel = Params.ULongParam4
			self:AddLevelUpSysChatMsg(EntityID, OldLevel, AttrCom.Level, ProfID)
		end

		if not _G.StoryMgr:SequenceIsPlaying() then
			local Actor = ActorUtil.GetActorByEntityID(EntityID)
			self:PlayLevelUpEffects(Actor)
		end
	end
end

function ProfMgr:OnMajorExpUpdate()
	local MajorAttrCmp = MajorUtil.GetMajorAttributeComponent()
	if nil == MajorAttrCmp then
		return
	end

	local MajorRoleDetail = ActorMgr:GetMajorRoleDetail()
	if nil == MajorRoleDetail then
		return
	end

	local ProfInfo = MajorRoleDetail.Prof.ProfList[MajorAttrCmp.ProfID]
	if nil == ProfInfo then
		return
	end

	ProfInfo.Exp = ScoreMgr:GetExpScoreValue()
	ProfInfo.Level = MajorUtil.GetMajorLevelByProf(MajorAttrCmp.ProfID)
end

function ProfMgr:OnMajorOhterExpUpdate(Params)
	local Prof
	local Exp
	if Params and next(Params) then
		if Params.ULongParam4 and Params.ULongParam4 ~= 0 then
			Prof = tonumber(Params.ULongParam4)
			Exp = tonumber(Params.ULongParam3)
		end
	end

	local MajorRoleDetail = ActorMgr:GetMajorRoleDetail()
	if nil == MajorRoleDetail or not Prof then
		return
	end

	local ProfInfo = MajorRoleDetail.Prof.ProfList[Prof]
	if nil == ProfInfo then
		return
	end

	--只更新经验，升级有单独事件
	ProfInfo.Exp = Exp
end

function ProfMgr:OnEmotionPanelClose(TargetID)
	self.TargetQuestEmotionID = TargetID
end
--------------- 网络：接收消息 ---------------

---收到职业激活消息（未完成）
---@param MsgBody table
function ProfMgr:OnNetMsgProfActivate(MsgBody)
	-- 对应职业图标被点亮等等
	local ActiveProf = MsgBody.Active.ActiveProf
	local ProfID = ActiveProf.ProfID

	FLOG_INFO("Equipment ProfMgr:OnNetMsgProfActivate  profID:%d", ProfID)

	ActorMgr:ActiveMajorProf(ActiveProf)
	--_G.EventMgr:SendEvent(EventID.MajorLevelUpdate, {RoleDetail = MajorRoleDetail})
	_G.EventMgr:SendEvent(EventID.MajorProfActivate, {ActiveProf = ActiveProf})
	self.btProfSwitchByActice = true
end

---收到职业切换消息（未完成）
---@param MsgBody table
function ProfMgr:OnNetMsgProfSwitch(MsgBody)
	-- 重置切换原因
	local ProfSwitchReason = self.LastProfSwitchReason
	self.LastProfSwitchReason = nil

	if MsgBody.ErrorCode then
		_G.ClientVisionMgr:EnableTick(true)
		return
	end

	local RoleDetail = MsgBody.Switch.Detail
	if not RoleDetail then
		_G.ClientVisionMgr:EnableTick(true)
		return
	end

	-- 更新技能列表
	local ProfID = RoleDetail.Simple.Prof
	if not ProfID then
		_G.ClientVisionMgr:EnableTick(true)
		return
	end

	local Name = RoleInitCfg:FindRoleInitProfName(ProfID)
	if Name then
		MsgTipsUtil.ShowTips(string.format(LSTR(1050191), Name))
	end

	-- 同步MajorRoleVM 职业Level
	self:SyncMajorLevel(RoleDetail.Simple.Level, RoleDetail.Simple.Level)

	FLOG_INFO("Equipment ProfMgr:OnNetMsgProfSwitch  profID:%d", ProfID)

	-- self:OnReceiveNetMsgProf(RoleDetail)
	ActorMgr:SetMajorRoleDetail(RoleDetail, true)

	local MajorAttrCmp = MajorUtil.GetMajorAttributeComponent()
	if MajorAttrCmp then
		MajorAttrCmp.ProfID = ProfID
	end

	local MajorVM = MajorUtil.GetMajorRoleVM()
	if MajorVM then
		MajorVM:SetProf(ProfID)
	end

	--更新装备
	_G.EquipmentMgr:ResetStrongestEquipInfos()
	_G.EquipmentMgr:OnEquipInfo(RoleDetail.Equip)

	--更新proflist
	_G.EquipmentMgr:OnProfListDetail(RoleDetail.Prof.ProfList)

	ScoreMgr:SetExpByRoleDetail(RoleDetail)

	-- 切职业特效，可参考SingCellUtil.PlayEffect和SkillSingEffectMgr:PlaySingEffect
	-- FXPath和AttachedComponent是必填参数
	local Me = MajorUtil.GetMajor()
	if Me == nil then
		_G.FLOG_WARNING("ProfMgr: Failed to get major character")
		return
	end
	-- 如果界面打开，则界面中的模型播放特效；界面没打开的话，就是场景中播放特效
	if not _G.UIViewMgr:IsViewVisible(UIViewID.EquipmentMainPanel) then
		local VfxParameter = _G.UE.FVfxParameter()
		VfxParameter.VfxRequireData.VfxTransform = Me:GetTransform()
		VfxParameter.VfxRequireData.EffectPath = TeamDefine.ProfChgEffect
		VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_ProfMgr
		local AttachPointType_Body = _G.UE.EVFXAttachPointType.PlaySourceType_Equip
		VfxParameter:SetCaster(Me, 0, AttachPointType_Body, 0)
		self.ProfChgEffectID = EffectUtil.PlayVfx(VfxParameter)
	end

	--播放转职音效
	_G.SingBarMgr:PlaySound(MajorUtil.GetMajorEntityID(), TeamDefine.ProfChgSound)
	if self.CurUIActor then
		_G.SingBarMgr:PlayActorSound(self.CurUIActor, TeamDefine.ProfChgSound)
	end

	_G.EventMgr:SendEvent(EventID.MajorLevelUpdate, {RoleDetail = RoleDetail, ProfID = ProfID})

	_G.EventMgr:SendEvent(EventID.MajorProfSwitch, {ProfID = ProfID, Reason = ProfSwitchReason})

	_G.EventMgr:SendEvent(EventID.MajorExpUpdate)

	local Params = _G.EventMgr:GetEventParams()
	Params.IntParam1 = ProfID
	_G.EventMgr:SendCppEvent(EventID.MajorProfSwitch, Params)
	_G.EquipmentMgr:CheckTipsForEndureDeg()

	if self.btProfSwitchByActice then
		self.btProfSwitchByActice = false
		self:ProfUnlockBehaviaor(ProfID)
	end

	--转职后也gc一波
	_G.ObjectMgr:CollectGarbage(false)
end

function ProfMgr:DoNetMsgLevelUpPreSaved(ProfID)
	if self.LevelUpNetMsg then
		local MsgBody = self.LevelUpNetMsg[ProfID]
		if MsgBody then
			self:OnNetMsgLevelUp(MsgBody)
			self.LevelUpNetMsg[ProfID] = nil
		end
	end
end

function ProfMgr:OnNetMsgLevelUpPre(MsgBody)
	--如果是能工巧匠职业，等技能结束后再执行
	if MajorUtil.IsCrafterProf() and _G.CrafterMgr.IsMaking then
		local ProfID = MsgBody.LevelUp.ProfID
		self.LevelUpNetMsg[ProfID] = MsgBody
		return
	end

	if _G.PWorldMgr:CurrIsInPVPColosseum() then
		-- 水晶冲突副本里，结算时先弹胜负提示，再弹角色升级、系列赛升级等提示
		self:RegisterTimer(function()
            self:OnNetMsgLevelUp(MsgBody)
        end, 2)
	else
		self:OnNetMsgLevelUp(MsgBody)
	end
end

---收到升级消息（未完成）
---@param MsgBody table
function ProfMgr:OnNetMsgLevelUp(MsgBody)
	-- 满级判断
	local NewLevel = MsgBody.LevelUp.NewLevel
	local AttrLevel = MsgBody.LevelUp.AttrLevel
	local LevelUpReason = MsgBody.LevelUp.Reason
	local ProfID = MsgBody.LevelUp.ProfID
	local OldLevel = NewLevel - 1
	FLOG_INFO("Equipment ProfMgr:OnNetMsgLevelUp  NewLevel:%d, AttrLevel:%d Reason:%d", NewLevel, AttrLevel, LevelUpReason)

	-- 同步MajorRoleVM Level
	local MajorVM = MajorUtil.GetMajorRoleVM()
	if MajorVM and MajorVM.Prof == ProfID then
		self:SyncMajorLevel(NewLevel, AttrLevel)
	end

	local MajorRoleDetail = ActorMgr:GetMajorRoleDetail()
	if MajorRoleDetail then
		MajorRoleDetail.Prof.Sync = MsgBody.LevelUp.Sync
		_G.EventMgr:SendEvent(EventID.MajorLevelSyncSwitch)
		local MajorAttrCmp = MajorUtil.GetMajorAttributeComponent()
		if MajorAttrCmp then
			MajorAttrCmp.Level = AttrLevel

			ProfID = nil == ProfID and MajorUtil.GetMajorProfID() or ProfID
			local ProfData = MajorRoleDetail.Prof.ProfList[ProfID]
			if ProfData then
				OldLevel = ProfData.Level
				ProfData.Level = NewLevel
			end
			--使用这个事件的，换成响应MajorLevelUpdate
			-- local Params = _G.EventMgr:GetEventParams()
			-- Params.ULongParam1 = MajorAttrCmp.EntityID
			-- _G.EventMgr:SendEvent(_G.EventID.VisionLevelChange, Params)
		end

		MajorRoleDetail.Simple.Level = AttrLevel
		_G.EventMgr:SendEvent(EventID.MajorLevelUpdate, {RoleDetail = MajorRoleDetail, OldLevel = OldLevel, ProfID = ProfID, Reason = LevelUpReason})

		local Params = _G.EventMgr:GetEventParams()
		Params.IntParam1 = ProfID
		_G.EventMgr:SendCppEvent(EventID.MajorLevelUp, Params)
	end

	-- 升级提示与特效
	if LevelUpReason == ProtoCS.LevelUpReason.LevelUpReasonProf then
		if _G.UpgradeMgr.IsOnDirectUpState then
			_G.UpgradeMgr:GetLevelUpdateInfo(ProfID, OldLevel, NewLevel)
		else
			local NewProfID = nil == ProfID and MajorUtil.GetMajorProfID() or ProfID
			self:AddLevelUpSysChatMsg(MajorUtil.GetMajorEntityID(), OldLevel, NewLevel, NewProfID)
			self.NewProf = ProfID
			self.NewLevel = NewLevel
			local function PlayLevelUpEffects()
				local Major = MajorUtil.GetMajor()
				self:PlayLevelUpEffects(Major)
				-- 播放屏幕特效与升级tips
				self.StartTime = _G.TimeUtil:GetLocalTimeMS()

				-- 播放升级特效的时候中断
				self.Blur = true

				-- 音效
				_G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Music, 0)
				local CallBack = function()
					_G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Music, 1)
				end
				AudioUtil.LoadAndPlayUISound(LevelUpAudioPath, CallBack)
			end
			MsgTipsUtil.ShowLevelUpTips(self.NewProf, self.NewLevel, PlayLevelUpEffects)
		end
	end

	_G.EquipmentMgr:UpdateRoleRedDot()
end

-- ---职业相关消息共用逻辑
-- function ProfMgr:OnReceiveNetMsgProf(RoleDetail)
-- 	ActorMgr:SetMajorRoleDetail(RoleDetail)
-- 	_G.EventMgr:SendEvent(EventID.MajorLevelUpdate, {RoleDetail = RoleDetail})
-- end

function ProfMgr:OnNetMsgQueryRoleDetail(MsgBody)
	local RoleList = MsgBody.RoleList
	for _, value in ipairs(RoleList) do
		local RoleID = value.Simple.RoleID
		if MajorUtil.IsMajorByRoleID(RoleID) then
			local bIsInLevelSyncBefore = MajorUtil.IsInLevelSync()
			ActorMgr:SetMajorRoleDetail(value, true)
			if bIsInLevelSyncBefore ~= MajorUtil.IsInLevelSync() then
				_G.EventMgr:SendEvent(EventID.MajorLevelSyncSwitch)
			end
			break
		end
	end
end


--------------- 网络：发送请求 ---------------

---发送职业切换请求
---@param ProfID int
---@param ReplaceWeaponGID int
function ProfMgr:SendProfSwitchReq(ProfID, ReplaceWeaponGID)
	FLOG_INFO("ProfMgr:SendProfSwitchReq")
	_G.ClientVisionMgr:EnableTick(false)

	local MsgID = CS_CMD.CS_CMD_PROF
	local SubMsgID = ProfSubMsg.ProfSubMsgSwitch
	local MsgBody = {
		SubMsgID = SubMsgID,
		Switch = {
			NewProf = ProfID,
			Weapon = ReplaceWeaponGID
		}
	}
	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--------------- 功能接口 ---------------

--目前切换的话，服务器会立即切换，同时会同步给第三方玩家
--将来可以优化的部分：关闭界面再同步给第三方、服务器延迟2秒同步给第三方
---@param ProfID int
---@param ReplaceWeaponGID int
---@param ProfSwitchReason int 标识切换职业的原因
function ProfMgr:SwitchProfByID(ProfID, ReplaceWeaponGID, ProfSwitchReason)
	--从A切到C，再从C切到B；  如果转职C的回包来了的话Major就是C了
	--如果此时再切到C，则Major和ProfID相同，就被跳过了，会出现UI选择的是C，而实际是B的情况
	--因为上层在转职切换的时候做了延迟转职的处理
    -- if MajorUtil.GetMajorProfID() == ProfID then
	-- 	FLOG_INFO("Equipment ProfMgr:SwitchProfByID, Major ProfID = ProfID")
    --     return
    -- end

	FLOG_INFO("Equipment ProfMgr:SwitchProfByID  profID:%d", ProfID)
	self:SendProfSwitchReq(ProfID, ReplaceWeaponGID)

	EffectUtil.StopVfx(self.ProfChgEffectID)
	local MajorID = MajorUtil.GetMajorEntityID()
	_G.SingBarMgr:StopSound(MajorID)
	-- _G.UIViewMgr:HideView(UIViewID.EquipmentMainPanel, true)  --test

	_G.LifeSkillBuffMgr:RemoveAllBuff()
	-- _G.SkillBuffMgr:RemoveAllBuff(true)

	self.LastProfSwitchReason = ProfSwitchReason
end

local function ConditionalShowTips(FuncName, bNoTips, ...)
	if bNoTips then
		return
	end
	MsgTipsUtil[FuncName](...)
end

function ProfMgr:CanChangeProf(ProfID, CanPreview, bNoTips)
	local MajorRoleDetail = ActorMgr:GetMajorRoleDetail()
	local ProfIsUnlock = false
	if nil == MajorRoleDetail or nil == MajorRoleDetail.Prof.ProfList[ProfID] then
		ProfIsUnlock = true
		if not CanPreview then
			--该职业暂未解锁
			ConditionalShowTips("ShowTips", bNoTips, LSTR(1050192))
			return false
		end
	end

	--端游允许表情动作转职，经讨论以下bug单加了对表情动作拦截，备注
	--bug=135917357 【P4主干】【叙事】任务-恐怖的骑士，情感动作和lcut，间隔时间中玩家可以进行切职业的异常操作
	local EntityID = MajorUtil.GetMajorEntityID()
	local EmotionID = self.TargetQuestEmotionID
	local IsPlayEmo = _G.EmotionMgr:IsEmotionPlaying(EntityID, EmotionID)
	if IsPlayEmo then
		ConditionalShowTips("ShowTips", bNoTips, LSTR(1050220))
		return false
	end

	--副本准备中
	if MajorUtil.GetMajorProfID() ~= ProfID then
		if _G.PWorldVoteMgr:IsVoteEnterScenePending() and _G.PWorldVoteVM.IsMajorReady then
			ConditionalShowTips("ShowTipsByID", bNoTips, 146064)
			return false
		end
	end

	--Pvp区域
	local CurrPWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
    local bPVP = PworldCfg:FindValue(CurrPWorldResID, "CanPK")
	local IsAdvancedProf = ProfUtil.IsAdvancedProf(ProfID)
	local IsProductionProf = ProfUtil.IsProductionProf(ProfID)
	if bPVP ~= 0 and (not IsAdvancedProf or IsProductionProf) then
		ConditionalShowTips("ShowTips", bNoTips, LSTR(1050219))
        return false
	end

	--金蝶小游戏
	if _G.GoldSaucerMiniGameMgr:CheckIsInMiniGame() and not ProfIsUnlock then
		ConditionalShowTips("ShowTips", bNoTips, LSTR(1050198))
		return false
	end

	--技能释放中
	local Object = SkillObjectMgr:GetOrCreateEntityData(EntityID).CurrentSkillObject
	if Object then
		ConditionalShowTips("ShowTips", bNoTips, LSTR(1050207))
		return false
	end

	--未解锁不需要判断，背包栏位
	if _G.BagMgr:GetBagLeftNum() < 12 and not ProfIsUnlock then
        ConditionalShowTips("ShowTips", bNoTips, LSTR(1050199))
        return false
	end

    local CurTime = _G.TimeUtil.GetLocalTimeMS()
    if CurTime - _G.EquipmentMgr.LastJobBtnClickTime <= _G.EquipmentMgr.JobBtnClickInterval then
        ConditionalShowTips("ShowTips", bNoTips, LSTR(1050200))
        return false
    end

	--未解锁职业，死亡，战斗，钓鱼，副本，采集，制作，不用判断
	local IgnoreIDTable = {}
	if ProfIsUnlock then
		IgnoreIDTable = {ProtoCommon.CommStatID.COMM_STAT_DEAD, ProtoCommon.CommStatID.COMM_STAT_COMBAT,
		ProtoCommon.CommStatID.COMM_STAT_FISH, ProtoCommon.CommStatID.CommStatScene, ProtoCommon.CommStatID.CommStatCraft,
		ProtoCommon.CommStatID.COMM_STAT_PICKUP}
	end
	local BehaviorID = ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_CHANGE_PROF
	if not CommonStateUtil.CheckBehavior(BehaviorID, false, IgnoreIDTable) then
		local TmpStr = LSTR(1050225)
		ConditionalShowTips("ShowTips", bNoTips, string.format(LSTR(1050224), TmpStr))
		return
	end
	-- 职业装备完整性检查
	if ProfIsUnlock and CanPreview then
		--未解锁职业且可以预览的情况，不需要检查装备
		return true
	end
	local SuitIntegrityState = nil
	local RawWeaponItem = nil
	local ReplaceWeaponItem = nil
	SuitIntegrityState, RawWeaponItem, ReplaceWeaponItem = _G.EquipmentMgr:CheckSuitIntegrity(ProfID)
	local ProfName = RoleInitCfg:FindRoleInitProfName(ProfID)
	if SuitIntegrityState == EquipmentDefine.SuitIntegrityState.LackArmor then
		ConditionalShowTips("ShowTips", bNoTips, string.format(LSTR(1050201), ProfName))
	elseif SuitIntegrityState == EquipmentDefine.SuitIntegrityState.LackWeapon then
		if nil == ReplaceWeaponItem then
			ConditionalShowTips("ShowTips", bNoTips, string.format(LSTR(1050202), ProfName))
			return false
		end
	end

	return true
end

function ProfMgr:SyncMajorLevel(ProfLv, PWorldLv)
	if ProfLv then
		local MajorVM = MajorUtil.GetMajorRoleVM()
		if not MajorVM then return end
		MajorVM:SetLevel(ProfLv)
	end

	if PWorldLv then
		MajorUtil.SetPWorldLevel(PWorldLv)
	end
end

function ProfMgr:ProfUnlockBehaviaor(UnlockProfID)
	self:PlayProfUnlockLcut(UnlockProfID)
end

function ProfMgr:PlayProfUnlockLcut(UnlockProfID)

	self.CurUnlockProfID =UnlockProfID
	if _G.UpgradeMgr.IsOnDirectUpState then
        if _G.UIViewMgr:IsViewVisible(_G.UIViewID.MainPanel) then
            _G.BusinessUIMgr:HideMainPanel(_G.UIViewID.MainPanel)
        end
		UIViewMgr:ShowView(_G.UIViewID.InfoJobNulockTipsView, {IsOnDirectUpState = true})
		return
	end
    local function SequenceCallBack()
		local Params = { ProfID = UnlockProfID }
		-- UIViewMgr:ShowView(UIViewID.InfoJobNulockTipsView,Params)
		--播放技能解锁动效
		SkillLogicMgr:PlayProfSkillUnlock()
    end

    local PlaybackSettings = {
        bDisableMovementInput = true,
        bDisableLookAtInput = true,
        bPauseAtEnd = false
    }
	local SequencePrePath = "LevelSequence'/Game/Assets/Cut/ffxiv_m/jobfin/"
	local ProfInfo = RoleInitCfg:FindCfgByKey(UnlockProfID)
	if nil == ProfInfo then
		FLOG_INFO("RoleInitCfg Serch fail,UnlockProfID:"..UnlockProfID)
		return
	end
	local Specialization="Sub_Battle/"
	if ProfInfo.Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
		Specialization="Sub_Craft/"
	end
	local ProfAssetAbbr=string.lower(ProfInfo.ProfAssetAbbr).."fin00000"
	local SequencePath=string.format("%s%s%s%s%s%s%s%s",SequencePrePath,Specialization,ProfAssetAbbr,"/",ProfAssetAbbr,".",ProfAssetAbbr,"'")
	_G.StoryMgr:PlaySequenceByPath(SequencePath, SequenceCallBack, nil, SequenceCallBack, PlaybackSettings)
end

function ProfMgr:GetCurUnlockProfID()
	return self.CurUnlockProfID
end
function ProfMgr:SetCurUnlockProfID(UnlockProfID)
	 self.CurUnlockProfID=UnlockProfID
end
---播放升级特效与音效
---@param Actor _G.UE.AActor
function ProfMgr:PlayLevelUpEffects(Actor)
	if nil == Actor then
		return
	end
	local VfxParameter = _G.UE.FVfxParameter()
	local VfxRequireData = VfxParameter.VfxRequireData
	VfxRequireData.EffectPath = ProfDefine.ProfLevelUpAssetPaths.FXPath
	VfxRequireData.VfxTransform = Actor:FGetActorTransform()
	VfxRequireData.bAlwaysSpawn = true
	VfxParameter.LODMethod = _G.UE.ParticleSystemLODMethod.PARTICLESYSTEMLODMETHOD_ActivateAutomatic
    VfxParameter.LODLevel = EffectUtil.GetMajorEffectLOD()
	VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_ProfMgr
    VfxParameter:SetCaster(Actor, 0, 0, 0)
	EffectUtil.PlayVfx(VfxParameter)

	local AudioMgr = _G.UE.UAudioMgr:Get()
    AudioMgr:AsyncLoadAndPostEvent(ProfDefine.ProfLevelUpAssetPaths.SoundPath, Actor)
end

function ProfMgr:AddLevelUpSysChatMsg(EntityID, OldLevel, NewLevel, ProfID)
	local ProfName = RoleInitCfg:FindValue(ProfID, "ProfName")
	for Level = OldLevel + 1, NewLevel do
		if nil ~= ProfID and nil ~= ProfName then
			ChatMgr:AddSysChatMsg(string.format(LSTR(930001), ActorUtil.GetActorName(EntityID),
			 ProfName, Level))
		else
			ChatMgr:AddSysChatMsg(string.format(LSTR(930002), ActorUtil.GetActorName(EntityID), Level))
		end
	end
end

function ProfMgr.ShowProfSwitchTab()
	UIViewMgr:ShowView(_G.UIViewID.ProfessionToggleJobTab)
end

function ProfMgr.HideProfSwitchTab()
	UIViewMgr:HideView(_G.UIViewID.ProfessionToggleJobTab)
end

---检查某职业是否属于某职业类
---@param ProfID int32
---@param ProfClass int32 | ProtoCommon.class_type
---@return boolean
function ProfMgr.CheckProfClass(ProfID, ProfClass)
    if (ProfID == nil) or (ProfClass == nil) then return false end

    if ProfClass == RoleInitCfg:FindValue(ProfID, "Class") then return true end

    local ProfList = ProfClassCfg:FindValue(ProfClass, "Prof")
    if not (ProfList and next(ProfList)) then return false end

    for _, SubProf in ipairs(ProfList) do
        if ProfID == SubProf then return true end
    end

    return false
end

---获取职业类名称
---@param ProfClass int32 | ProtoCommon.class_type
---@return string
function ProfMgr.GetProfClassName(ProfClass)
    if (ProfClass == nil) then return false end

    local ProfClassName = ProfDefine.ProfClassName[ProfClass]
		or ProfClassCfg:FindValue(ProfClass, "ProfClass")
		or LSTR(1050203)
	return ProfClassName
end

function ProfMgr.SortComparisonLevel(Left, Right)
    local LeftProfLevel = Left.Data and Left.Data.Level or 0
    local RightProfLevel = Right.Data and Right.Data.Level or 0

    -- 职业等级
    if LeftProfLevel ~= RightProfLevel then
		return LeftProfLevel > RightProfLevel
    end

    return ProfMgr.SortComparisonType(Left, Right)
end

function ProfMgr.SortComparisonType(Left, Right)
    -- 职业展示顺序
	local function FindSortOrder(ProfID)
		local ProfCfgData = RoleInitCfg:FindCfgByKey(ProfID)
		if nil == ProfCfgData then
			return nil
		end
		local SortOrder = ProfCfgData.SortOrder
		if SortOrder == 0 then
			-- 当前职业为基职，查找特职顺序
			if ProfCfgData.AdvancedProf then
				local AdvanceProfCfgData = RoleInitCfg:FindCfgByKey(ProfCfgData.AdvancedProf)
				if nil ~= AdvanceProfCfgData then
					SortOrder = AdvanceProfCfgData.SortOrder
				end
			end
		end

		return SortOrder
	end
	local LeftOrder = FindSortOrder(Left.Prof)
	local RightOrder = FindSortOrder(Right.Prof)
    if nil ~= LeftOrder and nil ~= RightOrder and LeftOrder ~= RightOrder then
		return LeftOrder < RightOrder
    end

    -- 职业序号
    if Left.Prof ~= Right.Prof then
		return Left.Prof < Right.Prof
    end

    return false
end

function ProfMgr.GenProfTypeSortData(ProfDetailList, ProfSpecialization, bIsOnlyEabled)
    local ProfClassList =
    {
        ProtoCommon.class_type.CLASS_TYPE_TANK,
        ProtoCommon.class_type.CLASS_TYPE_HEALTH,
        ProtoCommon.class_type.CLASS_TYPE_NEAR,
        ProtoCommon.class_type.CLASS_TYPE_FAR,
        ProtoCommon.class_type.CLASS_TYPE_MAGIC,
        ProtoCommon.class_type.CLASS_TYPE_CARPENTER,
        ProtoCommon.class_type.CLASS_TYPE_EARTHMESSENGER,
    }

    local Ret = {}
    local EnabledProfMap = {}
	local ProfDataMap = {}
	---从已开启的职业中提取数据
	for _, ProfDetail in pairs(ProfDetailList) do
		EnabledProfMap[ProfDetail.ProfID] = 1
		if not ProfSpecialization or RoleInitCfg:FindProfSpecialization(ProfDetail.ProfID) == ProfSpecialization then
			local ProfClass = RoleInitCfg:FindProfClass(ProfDetail.ProfID)
			if nil ~= ProfClass then
				local AdvanceProf = RoleInitCfg:FindProfAdvanceProf(ProfDetail.ProfID) or 0
				if nil == ProfDataMap[ProfClass] then
					ProfDataMap[ProfClass] = {}
				end
				table.insert(ProfDataMap[ProfClass], {Prof = ProfDetail.ProfID, Data = ProfDetail, bActive = true, AdvancedProf = AdvanceProf})
			end
		end
	end

	---从未开启的职业中提取数据
	if nil == bIsOnlyEabled or not bIsOnlyEabled then
		for _, ProfID in pairs(ProtoCommon.prof_type) do
			local SpecialCondition = not ProfSpecialization or RoleInitCfg:FindProfSpecialization(ProfID) == ProfSpecialization
			if EnabledProfMap[ProfID] == nil and
				RoleInitCfg:IsProfOpen(ProfID) and
				SpecialCondition then
				local ProfClass = RoleInitCfg:FindProfClass(ProfID)
				if nil ~= ProfClass then
					local AdvanceProf = RoleInitCfg:FindProfAdvanceProf(ProfID) or 0
					if nil == ProfDataMap[ProfClass] then
						ProfDataMap[ProfClass] = {}
					end
					table.insert(ProfDataMap[ProfClass], {Prof = ProfID, Data = nil, bActive = false, AdvancedProf = AdvanceProf})
				end
			end
		end
	end

    for Index, ProfClass in ipairs(ProfClassList) do
		local ProfDataList = ProfDataMap[ProfClass]
		if nil ~= ProfDataList then
			table.sort(ProfDataList, ProfMgr.SortComparisonType)
		end
        local ProfClassIcon = ProfUtil.GetProfClassIcon(ProfClass)
        Ret[Index] =
        {
            Title = ProfMgr.GetProfClassName(ProfClass),
            IconPath = string.format("Texture2D'/Game/Assets/Icon/900000/%s.%s'", ProfClassIcon, ProfClassIcon),
			ProfClass = ProfClass,
            lst = ProfDataList
        }
    end

    return Ret
end

function ProfMgr.GenProfLevelSortData(ProfDetailList, ProfSpecialization, bIsOnlyEnabled)
	local MaxLevel = LevelExpCfg:GetMaxLevel()

    local Ret = {}

    Ret[1] =
    {
        Title = LSTR(1050204),
        IconPath = "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Icon_Job_LV_Full_png.UI_Icon_Job_LV_Full_png'",
        lst = nil
    }

    Ret[2] =
    {
        Title = LSTR(1050205),
        IconPath = "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Icon_Job_LV_NotFull_png.UI_Icon_Job_LV_NotFull_png'",
        lst = nil
    }

    local lstProfMaxLevel = {}
    local lstProfNotMaxLevel = {}
    local EnabledProfMap = {}

    -- 从已开启的职业中提取数据
    for _, ProfDetail in pairs(ProfDetailList) do
        EnabledProfMap[ProfDetail.ProfID] = 1
        if RoleInitCfg:FindProfSpecialization(ProfDetail.ProfID) == ProfSpecialization then
			local AdvanceProf = RoleInitCfg:FindProfAdvanceProf(ProfDetail.ProfID) or 0
            if ProfDetail.Level >= MaxLevel then
                lstProfMaxLevel[#lstProfMaxLevel + 1] = {Prof = ProfDetail.ProfID, Data = ProfDetail, bActive = true, AdvancedProf = AdvanceProf}
            else
                lstProfNotMaxLevel[#lstProfNotMaxLevel + 1] = {Prof = ProfDetail.ProfID, Data = ProfDetail, bActive = true, AdvancedProf = AdvanceProf}
            end
        end
    end

    -- 从未开启的职业中提取数据
    if nil == bIsOnlyEnabled or not bIsOnlyEnabled then
        for _, value in pairs(ProtoCommon.prof_type) do
			local AdvanceProf = RoleInitCfg:FindProfAdvanceProf(value) or 0
            if EnabledProfMap[value] == nil and RoleInitCfg:IsProfOpen(value) and RoleInitCfg:FindProfSpecialization(value) == ProfSpecialization then
				lstProfNotMaxLevel[#lstProfNotMaxLevel + 1] = {Prof = value, Data = nil, bActive = false, AdvancedProf = AdvanceProf}
            end
        end
    end

    table.sort(lstProfMaxLevel, ProfMgr.SortComparisonLevel)
    table.sort(lstProfNotMaxLevel, ProfMgr.SortComparisonLevel)

    Ret[1].lst = lstProfMaxLevel
    Ret[2].lst = lstProfNotMaxLevel

    return Ret
end

function ProfMgr:MajorHasNorMalProfNum()
	local HasNorMalProfNum = 0
	local MajorRoleDetail = ActorMgr:GetMajorRoleDetail()
	if nil == MajorRoleDetail then
		return HasNorMalProfNum
	end
	for _, ProfData in pairs(MajorRoleDetail.Prof.ProfList) do
		local IsAdvancedProf = ProfUtil.IsAdvancedProf(ProfData.ProfID)
		local IsCombatProf = ProfUtil.IsCombatProf(ProfData.ProfID)
		if not IsAdvancedProf and IsCombatProf then
			HasNorMalProfNum = HasNorMalProfNum + 1
		end
	end
	return HasNorMalProfNum
end

function ProfMgr:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 0.05, 0)
end

function ProfMgr:OnTimer()
	if not self.Blur then
		return
	end

	local Major = MajorUtil.GetMajor()
	if nil == Major then
		return
	end
    local MCamCtr = Major:GetCameraControllComponent()
	local Cam = MCamCtr:GetTopDownCameraComponent()
	local CurTime = _G.TimeUtil:GetLocalTimeMS()
	local Delta = CurTime - self.StartTime
	if Cam and Delta > 3000 then
		local PostProcessSettings = Cam.PostProcessSettings
		PostProcessSettings.bOverride_RadialBlurDst = false
		PostProcessSettings.bOverride_RadialBlurRadius = false
		PostProcessSettings.bOverride_RadialBlurStrength = false
		PostProcessSettings.bOverride_RadialBlurScenePos = false
		PostProcessSettings.RadialBlurStrength = 0.0

		-- 升级时触发新手引导
		local function OnTutorial(Params)
			local EventParams = _G.EventMgr:GetEventParams()
			EventParams.Type = TutorialDefine.TutorialConditionType.ProfLevel --新手引导触发类型
			EventParams.Param1 = Params.Prof
			EventParams.Param2 = Params.Level
			_G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
		end

		-- _G.TipsQueueMgr:Pause(false)

		local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = OnTutorial, Params = {Prof = self.NewProf, Level = self.NewLevel}}
		_G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)

		self.Blur = false
		return
	end
	if Cam and Delta > 2500 then
		local PostProcessSettings = Cam.PostProcessSettings
		PostProcessSettings.RadialBlurStrength = (3000 - Delta) / 500
		PostProcessSettings.bOverride_RadialBlurDst = true
		PostProcessSettings.bOverride_RadialBlurRadius = true
		PostProcessSettings.bOverride_RadialBlurStrength = true
		PostProcessSettings.bOverride_RadialBlurScenePos = true
		return
	end
	if Cam and Delta > 2000 then
		local PostProcessSettings = Cam.PostProcessSettings
		PostProcessSettings.RadialBlurStrength = (Delta - 2000) / 500
		PostProcessSettings.bOverride_RadialBlurDst = true
		PostProcessSettings.bOverride_RadialBlurRadius = true
		PostProcessSettings.bOverride_RadialBlurStrength = true
		PostProcessSettings.bOverride_RadialBlurScenePos = true
	end
end

return ProfMgr
