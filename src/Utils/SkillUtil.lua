--
-- Author: anypkvcai
-- Date: 2020-11-17 19:54:04
-- Description: 主界面技能相关临时代码
--

local EventID = _G.EventID
local UActorManager = _G.UE.UActorManager:Get()
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local SkillSubCfg = require("TableCfg/SkillSubCfg")
local MajorUtil = require("Utils/MajorUtil")
local LifeSkillConfig = require("Game/Skill/LifeSkillConfig")
local ActorUtil = require("Utils/ActorUtil")
local ProtoCS = require ("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local SkillCastType = SkillCommonDefine.SkillCastType
local RoleSkillInitCfg = require("TableCfg/RoleSkillInitCfg")
local SkillLearnedCfg = require("TableCfg/SkillLearnedCfg")
local SameSkillGroupCfg = require("TableCfg/SameSkillGroupCfg")
local GlobalCfg = require("TableCfg/GlobalCfg")
local SkillSubCfg = require("TableCfg/SkillSubCfg")
local MsgTipsID = require("Define/MsgTipsID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local TimeUtil = require("Utils/TimeUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local CommonUtil = require("Utils/CommonUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local ProtoCommon = require("Protocol/ProtoCommon")

---@class SkillUtil
local SkillUtil = {

}

SkillUtil.MapType = {
    PVE = 1,
    PVP = 2,
}
    --生产技能打点用
SkillUtil.ProductionSkillFlowData = {}
-- 技能系统内置CD
local SkillCDForSkillSystem = 500
local SkillFlowReportInterval = 1000  --毫秒
local SkillFlowLastReportTime = 0
local SkillFlowLastSkillID = 0
SkillUtil.ProductionSkillFlowDataLen = 0 

SkillUtil.SkillSystemRenderActor = "Blueprint'/Game/UI/Render2D/SkillSystem/BP_Render2DSkillSystemActor.BP_Render2DSkillSystemActor_C'"

local CachedMaxLevel = nil

function SkillUtil.GetGlobalConfigMaxLevel()
	if not CachedMaxLevel then
		local Cfg = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_MAX_LEVEL)
		CachedMaxLevel = Cfg.Value[1]
	end
	return CachedMaxLevel
end

--将FVector转换为服务器所用Position
--这么通用的功能有公共接口么？
function SkillUtil.ConvertVector2Position(Vec)
	return {X = math.floor(Vec.X), Y = math.floor(Vec.Y), Z = math.floor(Vec.Z)}
end

function SkillUtil.ConvertVector2CSPosition(Vec)
	return {x = math.floor(Vec.X), y = math.floor(Vec.Y), z = math.floor(Vec.Z)}
end

---@param Type number
--Type 1PVE 2PVP
function SkillUtil.FindProfInitSkill(ProfID, Type, bLifeIgnorePVP)
	local Cfg = RoleInitCfg:FindCfgByKey(ProfID)
	if Cfg then
		local ClassTypeDefine = ProtoCommon.class_type
		local ClassType = Cfg.Class
		local SkillGroupID
		--能工巧匠或大地使者在PVP副本也要用Group1
		if bLifeIgnorePVP and (ClassType == ClassTypeDefine.CLASS_TYPE_CARPENTER or ClassType == ClassTypeDefine.CLASS_TYPE_EARTHMESSENGER) then
			SkillGroupID = Cfg.SkillGroup[1]
		else
			SkillGroupID = Cfg.SkillGroup[Type]
		end
		if SkillGroupID then
			return RoleSkillInitCfg:GetDuplicatedCfgByKey(SkillGroupID)
		end
	end
	return nil
end
---PrepareCastSkill
---@param Index number
---@param X number
---@param Y number
function SkillUtil.PrepareCastSkill(EntityID, Index)
	local LogicData = _G.SkillLogicMgr:GetSkillLogicData(EntityID)
	if LogicData == nil then
		FLOG_WARNING(string.format("[SkillUtil]%s SkillData not found", tostring(EntityID or -1)))
		return
	end
	local SkillID = LogicData:GetBtnSkillID(Index)
	if nil == SkillID or SkillID == 0 then
		print("SkillUtil.PrepareCastSkill SkillID is nil")
		return
	end

	if _G.SkillGuideMgr:PrepareCastSkill(SkillID, Index) then
		return
	end

	local SkillStorageMgr = _G.SkillStorageMgr
	SkillStorageMgr:PrepareCastSkill(EntityID, SkillID, Index)
end

--执行到此函数，意味着技能应当被成功释放
function SkillUtil.CastSkillSuccess(SkillID, Index, Params)
	local SkillSeriesMgr = _G.SkillSeriesMgr
	local Result = SkillSeriesMgr:CastSkill(SkillID, Index, Params)
	if Result then return SkillCastType.ComboType end
	
	return SkillUtil.SendCastSkillEvent(SkillCastType.NormalType, SkillID, 0, 0, 0, Index, Params)
end

local EffectID = 0

---CastSkill
---@param Index number
function SkillUtil.CastSkill(EntityID, Index, SkillID, SkillCD, Params)
	if nil == SkillID then
		print("SkillUtil.CastSkill SkillID is nil")
		return
	end

	local _ <close> = CommonUtil.MakeProfileTag("SkillUtil.CastSkill " .. tostring(SkillID))

	local SkillStorageMgr = _G.SkillStorageMgr
	-- 当角色处于攀爬过程中，取消放技能
	if ActorUtil.IsClimbingState(EntityID) then
		_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.SkillCannotUse)
		SkillStorageMgr:BreakCurStorageSkill()
		return
	end

	--当角色死亡时，应直接结束蓄力(如果有)并返回
	--TODO[chaooren]此处应当不用判断，因为角色死亡时应直接通过蓄力模块结束蓄力
	if MajorUtil.IsMajorDead() then
		SkillStorageMgr:BreakCurStorageSkill()
		return
	end
	if nil == SkillCD then
		SkillCD = 0
	end

	if _G.SkillGuideMgr:CastSkill(SkillID, Index) then
		return SkillCastType.GuideType
	end

	--先执行蓄力技能，该技能不作为预输入;蓄力技能要求技能剩余CD为0
	if SkillCD == 0 and SkillStorageMgr:CastSkill(EntityID, SkillID, Index, Params) then
		return SkillCastType.StorageType
	end
	--技能预输入，true则直接释放技能，false则返回，并通过定时器根据预输入技能信息进行释放
	local PreInput, PreInputRetParams = _G.SkillPreInputMgr:OnPreInputCastSkill(SkillID, Index, SkillCD, Params)
	if PreInput == false then 
		return SkillCastType.PreInputType, PreInputRetParams 
	end
	
	return SkillUtil.CastSkillSuccess(SkillID, Index, Params)
end

--生活类技能简化协议与流程
--详细内容与参数规范参考 https://iwiki.woa.com/pages/viewpage.action?pageId=1162475628
function SkillUtil.CastLifeSkill(Index, SkillID, ExtraParams)
	if MajorUtil.IsGatherProf() and not _G.GatherMgr.IsGathering then
		local ConditionStr = SkillMainCfg:FindValue(SkillID, "LifeSkillCondition")
		if ConditionStr and not _G.GatherMgr:IsDiscoverSkill(SkillID) then--and tonumber(ConditionStr) then
			_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherNotInState)
			return false
		end
	end
	
    local CurSkillWeight = _G.SkillPreInputMgr:GetCurrentSkillWeight()
    if CurSkillWeight then
        local SubSkillID = _G.SkillLogicMgr:GetMultiSkillReplaceResult(SkillID, MajorUtil.GetMajorEntityID())
        local ToCastSkillWeight = _G.SkillPreInputMgr:GetInputSkillWeight(SubSkillID)
        if ToCastSkillWeight and ToCastSkillWeight <= CurSkillWeight then
			MsgTipsUtil.ShowTipsByID(MsgTipsID.LifeSkillCDing)
            FLOG_INFO("SkillUtil.CastLifeSkill CurSkillWeight: %d ToCastSkillWeight: %d", CurSkillWeight, ToCastSkillWeight)
            return false
        end
    end

	local Target = ActorUtil.GetActorByEntityID(GatherMgr.CurActiveEntityID)
	local Major = MajorUtil:GetMajor()

	if not Target or not Major then
		return SkillUtil.DoCastLifeSkill(Index, SkillID, ExtraParams)
	end

	local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
	local TargetPos = Target:FGetLocation(_G.UE.EXLocationType.ServerLoc)

    local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
    if not LogicData then
		return false
	end

	local BtnSkillID = LogicData:GetBtnSkillID(Index)
	local MaxCastSkillDistance = 0
	if BtnSkillID then
		MaxCastSkillDistance = SkillMainCfg:FindValue(BtnSkillID, "MaxCastSkillDistance")
	end

	local Distance = _G.UE.FVector.Dist(MajorPos, TargetPos)

	if MaxCastSkillDistance == 0 or not MaxCastSkillDistance
		or MaxCastSkillDistance > 0 and Distance <= MaxCastSkillDistance then
		SkillUtil.DoCastLifeSkill(Index, SkillID)
	else
		local UMoveSyncMgr = _G.UE.UMoveSyncMgr:Get()
		UMoveSyncMgr.OnSimulateMoveFinish:Clear()
		UMoveSyncMgr.OnSimulateMoveFinish:Add(UMoveSyncMgr, function(seqID, StopType)
			if StopType == _G.UE.ESimulateMoveStop.Finished then
				print("Interactive NavComplete " .. TimeUtil.GetLocalTimeMS())
				SkillUtil.DoCastLifeSkill(Index, SkillID)
				UMoveSyncMgr.OnSimulateMoveFinish:Clear()
			else
				print("Interactive Nav cancel")
			end
		end)

		FLOG_INFO("Interactive begin Nav %d ", MaxCastSkillDistance)
	   UMoveSyncMgr:StartSimulateMove(MajorPos, TargetPos, MaxCastSkillDistance)
	end
	return true
end

function SkillUtil.DoCastLifeSkill(Index, SkillID, ExtraParams)
	local LifeSkillType = SkillMainCfg:FindValue(SkillID, "Prof")

	local Params = _G.EventMgr:GetEventParams()
	Params.IntParam1 = SkillID
	Params.IntParam2 = LifeSkillType
	Params.ULongParam1 = Index
	--Params.ULongParam2 = TargetEntityID	--目标EntityID，如挖矿技能采集物ID

	-- 暂时只有锻铁用到了ExtraParams
	if ExtraParams then
		-- BoolParam1用于区分锻铁的捶打
		if ExtraParams.bIsHammerSkill then
			Params.BoolParam1 = true

			Params.ULongParam3 = ExtraParams.X
			Params.ULongParam4 = ExtraParams.Y
		end

		-- BoolParam2用于区分烹饪的秘技
		if ExtraParams.CulinarySecretIndex then
			Params.BoolParam2 = true
			Params.ULongParam3 = ExtraParams.CulinarySecretIndex
		end
	end
	

	local Result = LifeSkillConfig.InvokeCastSkillCallback(LifeSkillType, Params)
	if Result or Result == nil then
		--采集职业的勘探技能（其他技能都不会配置这个空中潜水游泳可以使用的）乘骑下都可以释放
		local bValidSwimmingOrDivingOrFlying = 
			SkillMainCfg:FindValue(SkillID, "ValidSwimmingOrDivingOrFlying") == 1
		if bValidSwimmingOrDivingOrFlying and MajorUtil.IsGatherProf() then
			_G.EventMgr:SendCppEvent(EventID.LifeSkillCast, Params)
			return true
		end

		local function MountCancelCallback(bSync)
			_G.EventMgr:SendCppEvent(EventID.LifeSkillCast, Params)
		end
	
		local MountMgr = _G.MountMgr
		if MountMgr:IsInRide() then
			MountMgr:SendMountCancelCall(MountCancelCallback, false)
		else
			MountCancelCallback(true)
		end
	end
	return Result or true
end

---SendCastSkillEvent
---@param SkillType number                    @技能类型
---@param SkillID number                    @初始技能ID
---@param CfgID number                        @c_skill_series_cfg或c_storage_skill_cfg配置的ID
---@param QueueIndex number                    @技能队列索引
---@param QueueSkillID number                @技能队列中的技能ID
function SkillUtil.SendCastSkillEvent(SkillType, SkillID, CfgID, QueueIndex, QueueSkillID, Index, JoyStickParams)
	local Params = { SkillType = SkillType, SkillID = SkillID, CfgID = CfgID, QueueIndex = QueueIndex, QueueSkillID = QueueSkillID, Index = Index }
	--连招蓄力使用QueueSkillID作为吟唱技能，普通技能使用SkillID
	local SingUseSkill = QueueSkillID
	if SkillType == 0 then
		SingUseSkill = SkillID
	end
	local Result = _G.SkillSingEffectMgr:PlayerSingBegin(MajorUtil.GetMajorEntityID(), SingUseSkill, Params, JoyStickParams)
	if Result == true then
		return SkillCastType.SingType
	end

	if not SkillUtil.MajorCastSkill(Params, JoyStickParams) then
		_G.EventMgr:SendEvent(EventID.MajorSkillCastFailed, Index)
	end
	
	return SkillType
end

---改变技能图标
---@param SkillID number                    @技能ID
---@param IconWidget UImage                    @Image组件
function SkillUtil.ChangeSkillIcon(SkillID, IconWidget)
	if SkillID == nil or IconWidget == nil then
		return
	end

	local IconPath = SkillMainCfg:FindValue(SkillID, "Icon")
	-- local UIUtil = require("Utils/UIUtil")
	if IconPath == nil or IconPath == "None" then
		FLOG_WARNING(string.format("[SkillUtil]%d not find icon in mainskilltable", SkillID))
		return
	end
	UIUtil.ImageSetBrushFromAssetPath(IconWidget, IconPath, true)
	UIUtil.SetIsVisible(IconWidget, true)
end

--将时间戳转变为秒用于UI显示
function SkillUtil.StampToTime(TimeStamp)
	return (TimeStamp - TimeUtil.GetServerTimeMS()) / 1000
end

function SkillUtil.MainSkill2SubSkill(MainSkillID)
	if MainSkillID == nil then return nil end
	local IDList = SkillMainCfg:GetSkillIdList(MainSkillID)
	if IDList and #IDList > 0 then
		local SubSkillID = IDList[1].ID
		return SubSkillID
	end
	return 0
end

--当技能条件为衍生技能时，获取策划配置的技能, 否则使用第一个子技能
--演示技能专用
function SkillUtil.GetSubSkillIDForSkillSystem(SkillID)
	local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
	if Cfg and Cfg.IdList[1] then
		local SubSkillID = Cfg.SubSkillIDForSkillSystem
		if SubSkillID and SubSkillID > 0 then
			return SubSkillID
		end
		return Cfg.IdList[1].ID
	end
	return 0
end

local function GetSkillTargetForSkillSystem(SkillID, CasterEntityID, TargetEntityID)
	local Cfg = SkillMainCfg:FindCfgByKey(SkillID) or {}
	local skill_class = ProtoRes.skill_class
	local SkillClass = Cfg.Class or 0
	if (SkillClass & skill_class.SKILL_CLASS_ASSIST) > 0 or
	   (SkillClass & skill_class.SKILL_CLASS_HEAL) > 0 then
		return CasterEntityID
	end
	return TargetEntityID
end

--- PlayerCastSkillFinal
--- # TODO - 后面整理下接口参数, 有些已经废弃了, 有些实现的方式可以优化一下
function SkillUtil.PlayerCastSkillFinal(EntityID, _, BaseSkillID, SkillID, Index, bJoyStick, bNotDoPostUseSkill)
	print(string.format("PlayerCastSkill %d  %d", Index, BaseSkillID))
	if BaseSkillID == 2061 then
		--在技能系统中无法使用药品
		MsgTipsUtil.ShowTips(LSTR("在技能系统中无法使用药品"))
		return
	end
	if not SkillSystemMgr.bCasterAssembleEnd then
		-- 组装未完成时, 技能系统禁用技能
		return
	end
	if not bNotDoPostUseSkill then
		_G.EventMgr:SendEvent(EventID.SkillSystemPostUseSkill, {SkillID = BaseSkillID, Index = Index})
	end

	-- 策划希望放其他技能重置Skill的下标
	if Index ~= 0 then
		_G.SkillLogicMgr:ResetPlayerSkillSeriesIndex(EntityID, 0)
	end

	-- 红点处理
	_G.SkillSystemMgr:UpdateSkillRedDotCheckState(BaseSkillID)

	--send skill
	--_G.GMMgr:ReqGM("cell skill monster " .. tostring(SkillID))
	local TargetEntityID = GetSkillTargetForSkillSystem(SkillID, EntityID, SkillUtil.TargetEntityID or 0)
	local TargetActor = ActorUtil.GetActorByEntityID(TargetEntityID)
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if Actor == nil or TargetActor == nil then
		FLOG_WARNING("[SkillUtil] " .. tostring(EntityID or 0) .. " Actor is nil")
		return
	end

	local ActorLocation = Actor:FGetActorLocation()
	local MsgID = ProtoCS.CS_CMD.CS_CMD_COMBAT
	local MsgBody = {}
	local SubMsgID = ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_CAST_PERFORM_ACTION
	MsgBody.Cmd = SubMsgID
	local SelectPos = TargetActor:FGetActorLocation()
	if bJoyStick then
		SelectPos = SelectPos - _G.UE.FVector(0, 0, TargetActor:GetCapsuleHalfHeight())
	end
	SelectPos = SkillUtil.ConvertVector2CSPosition(SelectPos)

	local TargetList = { TargetEntityID }
	if TargetEntityID ~= EntityID then
		table.insert(TargetList, EntityID)
	end

	local SkillSelectC = {
		ObjID = EntityID, SkillID = SkillID,
		SelectPos = SelectPos,
		DirPos = SkillUtil.ConvertVector2CSPosition(TargetActor:FGetActorLocation() - ActorLocation),
		TargetList = TargetList
	}

	local SubSkillID = SkillUtil.GetSubSkillIDForSkillSystem(SkillID)
	if SubSkillID > 0 then
		SkillSelectC.DerivedSkillID = SubSkillID
	end
	local PerformAction = {select = SkillSelectC}
	MsgBody.PerformAction = PerformAction
	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--bDisplaySimulateReplace是否显示模拟替换动画
--显示模拟替换动画时不走技能流程，只做技能系统表现
function SkillUtil.PlayerPrepareCastSkill(EntityID, Index, SkillID, bEnterSimulateReplace)
	if SkillID == 0 then
		return
	end
	EventMgr:SendEvent(EventID.PlayerPrepareCastSkill, {EntityID = EntityID, Index = Index, SkillID = SkillID})
	if not bEnterSimulateReplace then
		_G.SkillSystemMgr:ClearAllSkillSystemEffectWithoutFade()  -- 技能系统里面, 蓄力技能需要强制打断上一个技能
		local SkillStorageMgr = _G.SkillStorageMgr
		local Type, MaxTime = SkillStorageMgr:PrepareCastSkill(EntityID, SkillID, Index)
		return Type, MaxTime
	end
end

function SkillUtil.PlayerCastSkill(EntityID, Index, SkillID, bJoyStick)
	local SkillStorageMgr = _G.SkillStorageMgr
	if SkillStorageMgr:CastSkill(EntityID, SkillID, Index) then
		return
	end
	local Params = { SkillType = SkillCastType.NormalType, SkillID = SkillID, Index = Index }
	local Result = _G.SkillSingEffectMgr:PlayerSingBegin(EntityID, SkillID, Params)
	if Result == true then
		Params.bShouldSing = true
		_G.EventMgr:SendEvent(EventID.SkillSystemPostUseSkill, Params)
		return
	end

	SkillUtil.PlayerCastSkillFinal(EntityID, SkillCastType.NormalType, SkillID, SkillID, Index, bJoyStick)
end

--这接口用的地方有点多，先不动了
--判断技能可用性用这个比较好SkillUtil.GetSkillLearnValid
function SkillUtil.GetSkillLearnLevel(SkillID, ProfID)
	if SkillID == nil or SkillID == 0 or ProfID == nil or ProfID == 0 then
		return 0
	end
	local AdvancedProf = ProfUtil.GetAdvancedProf(ProfID)
	local Cfg = SkillLearnedCfg:FindCfgByParam(SkillID, AdvancedProf)
    if Cfg then
        return Cfg.LearnedLevel
    end
	return 0
end

SkillUtil.SkillLearnStatus = {
	Learned = 0,
	UnLockLevel = 1,
	UnLockAdvancedProf = 2,
	Unknown = 3,
	NotLockLevel = 4, --量谱用
}

function SkillUtil.IsMajorSkillLearned(SkillID)
	
	local ProfID = MajorUtil.GetMajorProfID()
	local Valid = SkillUtil.GetSkillLearnValid(SkillID, ProfID, MajorUtil.GetMajorLevel())
	return Valid == SkillUtil.SkillLearnStatus.Learned
end

function SkillUtil.GetSkillLearnValid(SkillID, ProfID, Level)
	if not SkillID or not ProfID or not Level then
		return SkillUtil.SkillLearnStatus.Unknown, 0, false
	end
	local AdvancedProf = ProfUtil.GetAdvancedProf(ProfID)
	local Cfg = SkillLearnedCfg:FindCfgByParam(SkillID, AdvancedProf)
	local LearnedLevel = 0
	local bAdvancedProfUse = false
	if Cfg then
		LearnedLevel = Cfg.LearnedLevel
		bAdvancedProfUse = Cfg.bAdvancedProfUse == ProtoRes.prof_level.PROF_LEVEL_ADVANCED
    end

	local bAdvancedProf = ProfID == AdvancedProf	--ProfUtil获取的特职和传入值相同时
	if bAdvancedProfUse and not bAdvancedProf then
		return SkillUtil.SkillLearnStatus.UnLockAdvancedProf, LearnedLevel, bAdvancedProfUse
	elseif Level < LearnedLevel then
		return SkillUtil.SkillLearnStatus.UnLockLevel, LearnedLevel, bAdvancedProfUse
	end
	return SkillUtil.SkillLearnStatus.Learned, LearnedLevel, bAdvancedProfUse
end

function SkillUtil.GetSkillUnlockValid(SkillID, ProfID, Level)
	if not SkillID or not ProfID or not Level then
		return SkillUtil.SkillLearnStatus.Unknown, 0, false
	end
	local AdvancedProf = ProfUtil.GetAdvancedProf(ProfID)
	local Cfg = SkillLearnedCfg:FindCfgByParam(SkillID, AdvancedProf)
	local LearnedLevel = 0
	local bAdvancedProfUse = false
	if Cfg then
		LearnedLevel = Cfg.LearnedLevel
		bAdvancedProfUse = Cfg.bAdvancedProfUse == ProtoRes.prof_level.PROF_LEVEL_ADVANCED
		--召唤师、黑魔和武僧拳意量谱特殊处理
		if not LearnedLevel or LearnedLevel <= 1 or SkillID == ProSkillDefine.SpectrumIDMap.MONK_FIST
			 or SkillID == ProSkillDefine.SpectrumIDMap.BLACKMAGE_SLOT then
			return SkillUtil.SkillLearnStatus.NotLockLevel, LearnedLevel, bAdvancedProfUse
		end
    end

	local bAdvancedProf = ProfID == AdvancedProf	--ProfUtil获取的特职和传入值相同时
	if bAdvancedProfUse and not bAdvancedProf then
		return SkillUtil.SkillLearnStatus.UnLockAdvancedProf, LearnedLevel, bAdvancedProfUse
	elseif Level < LearnedLevel then
		return SkillUtil.SkillLearnStatus.UnLockLevel, LearnedLevel, bAdvancedProfUse
	end
	return SkillUtil.SkillLearnStatus.Learned, LearnedLevel, bAdvancedProfUse
end

function SkillUtil.GetSkillIDByGroupID(GroupID, ProfID, Level)
	if GroupID == nil or GroupID == 0 then
		return 0
	end
	local Cfg = SameSkillGroupCfg:FindCfgByKey(GroupID)
	if Cfg then
		local SameSkills = Cfg.SameSkills
		for i = #SameSkills, 1, -1 do
			local SkillID = SameSkills[i]
			if SkillUtil.GetSkillLearnValid(SkillID, ProfID, Level) == SkillUtil.SkillLearnStatus.Learned then
				return SkillID
			end
		end
	end
	return 0
end

function SkillUtil.GetSkillIDBySameSkill(SkillID, ProfID, Level)
	local RetID = SkillID
	local AdvancedProf = ProfUtil.GetAdvancedProf(ProfID)
	local Cfg = SkillLearnedCfg:FindCfgByParam(SkillID, AdvancedProf)
	if Cfg == nil then
		FLOG_WARNING(string.format("[SkillUtil] SkillID %d not in SkillLearned Table", SkillID or 0))
		return RetID
	end
	local ID = SkillUtil.GetSkillIDByGroupID(Cfg.GroupID, ProfID, Level)
	if ID > 0 then
		RetID = ID
	end
	return RetID
end

--[MinLearnedLevel, MaxLearnedLevel)
function SkillUtil.GetSkillLearnLevelRange(SkillID, ProfID)
	local MinLearnedLevel = 1
	local MaxLearnedLevel = 99999
	if SkillID == nil or SkillID == 0 then
		return MinLearnedLevel, MaxLearnedLevel
	end
	local AdvancedProf = ProfUtil.GetAdvancedProf(ProfID)
	local Cfg = SkillLearnedCfg:FindCfgByParam(SkillID, AdvancedProf)
    if Cfg then
        MinLearnedLevel = Cfg.LearnedLevel
		local GroupID = Cfg.GroupID
		if GroupID > 0 then
			local GroupCfg = SameSkillGroupCfg:FindCfgByKey(GroupID)
			if GroupCfg then
				local bNext = false
				for _, value in ipairs(GroupCfg.SameSkills) do
					if bNext == true then
						MaxLearnedLevel = SkillUtil.GetSkillLearnLevel(value, ProfID)
						break
					end
					if value == SkillID then
						bNext = true
					end
				end
			end
		end
    end
    return MinLearnedLevel, MaxLearnedLevel
end

--这个接口没地方用，不清楚是干啥的，先不改了
--该接口技能学习判断规则可能有错(没有考虑基、特职)
function SkillUtil.GetSkillLearnedList(ProfID, Level)
	local LearnedSkillList = {}
	local LearnedSpectrumList = {}
	if ProfID == nil or Level == nil then
		return LearnedSkillList, LearnedSpectrumList
	end
	local CfgList = SkillLearnedCfg:FindAllCfg(string.format("Prof = %d and LearnedLevel >= %d", ProfID, Level))
	for _, value in ipairs(CfgList) do
		local GroupID = value.GroupID
		local NeedIgnore = false
		--位于相同技能组表，且被高等级覆盖
		if GroupID > 0 and SkillUtil.GetSkillIDByGroupID(GroupID, ProfID, Level) ~= value.SkillID then
			NeedIgnore = true
		end

		if NeedIgnore == false then
			if value.IsSpectrum == 0 then
				table.insert(LearnedSkillList, value.SkillID)
			elseif value.IsSpectrum == 1 then
				table.insert(LearnedSpectrumList, value.SkillID)
			end
		end
	end
	return LearnedSkillList, LearnedSpectrumList
end

--Type 1PVE  2PVP
function SkillUtil.GetSkillList(Type, ProfID, bLifeIgnorePVP)
    if ProfID == nil then return nil end
    if ProfID > 0 then
        --职业技能
        return SkillUtil.FindProfInitSkill(ProfID, Type, bLifeIgnorePVP)
    else
        --变身之类的？
    end
    return nil
end

function SkillUtil.GetBaseSkillList(Type, ProfID, Level, bLifeIgnorePVP)
	local ProfSkillList = SkillUtil.GetSkillList(Type, ProfID, bLifeIgnorePVP)
	if ProfSkillList == nil then
		FLOG_ERROR(string.format("[SkillUtil] GetBaseSkillList falid, MapType: %d, ProfID: %d", Type or 0, ProfID or 0))
		return
	end

	local GlobalMaxLevel = SkillUtil.GetGlobalConfigMaxLevel()
	local SkillList = ProfSkillList.SkillList
	for _, value in ipairs(SkillList) do
		local SkillID = value.ID
		if SkillID > 0 then
			local LearnLevel = SkillUtil.GetSkillLearnLevel(SkillID, ProfID)
			if LearnLevel > GlobalMaxLevel then
				value.ID = 0
			end
		end
	end

	local SpectrumList = ProfSkillList.Spectrum
	for index, SpectrumID in ipairs(SpectrumList) do
		if SpectrumID > 0 then
			local LearnLevel = SkillUtil.GetSkillLearnLevel(SpectrumID, ProfID)
			if LearnLevel > GlobalMaxLevel then
				SpectrumList[index] = 0
			end
		end
	end

	local PassiveList = ProfSkillList.PassiveList
	for index, value in ipairs(PassiveList) do
		local SkillID = value
		if SkillID > 0 then
			local LearnLevel = SkillUtil.GetSkillLearnLevel(SkillID, ProfID)
			if LearnLevel > GlobalMaxLevel then
				PassiveList[index] = 0
			end
		end
	end
	--SkillUtil.SkillListBaseCache[SkillHash] = ProfSkillList
	--end

	ProfSkillList.Level = Level
	ProfSkillList.MapType = Type
	ProfSkillList.ProfID = ProfID
	return ProfSkillList
end

local SkillLearnStatus_Learned = SkillUtil.SkillLearnStatus.Learned

function SkillUtil.GetBaseSkillListForInit(Type, ProfID, Level, bLifeIgnorePVP)
	local ProfSkillList = SkillUtil.GetBaseSkillList(Type, ProfID, Level, bLifeIgnorePVP)
	if ProfSkillList == nil then
		return
	end
	--ProfSkillList = table.deepcopy(ProfSkillList)
	local SkillList = ProfSkillList.SkillList
	for _, value in ipairs(SkillList) do
		local SkillID = value.ID
		if SkillID > 0 then
			local ReplaceID = SkillUtil.GetSkillIDBySameSkill(SkillID, ProfID, Level)
			value.ID = ReplaceID
		end
	end

	local ExistSpectrums = {}
	local SpectrumList = ProfSkillList.Spectrum
	for index, SpectrumID in ipairs(SpectrumList) do
		if SpectrumID > 0 then
			local ReplaceID = SkillUtil.GetSkillIDBySameSkill(SpectrumID, ProfID, Level)
			local LearnStatus = SkillUtil.GetSkillLearnValid(ReplaceID, ProfID, Level)
			--量谱未解锁
			if LearnStatus ~= SkillLearnStatus_Learned then
				ReplaceID = 0
			end
			if ReplaceID == 0 or ExistSpectrums[ReplaceID] == nil then
				SpectrumList[index] = ReplaceID
				ExistSpectrums[ReplaceID] = 1
			end
		end
	end
	return ProfSkillList
end

--当升级时，获取新解锁的技能
--新解锁的技能解锁等级应>Min Level，<=Max Level
function SkillUtil.GetUnLockSkillList(ProfID, MinLevel, MaxLevel, IsAdvanceProf)
	local SkillList = {}
	if nil == ProfID or MinLevel >= MaxLevel then
		--
		return SkillList
	end
	local AdvancedProf = ProfUtil.GetAdvancedProf(ProfID)
	local SearchConditions
	--是基职
	if AdvancedProf ~= ProfID then
		SearchConditions = string.format("Prof = %d and LearnedLevel > %d and LearnedLevel <= %d and IsSpectrum = 0 and bAdvancedProfUse = %d", AdvancedProf, MinLevel, MaxLevel, ProtoRes.prof_level.PROF_LEVEL_BASE)
	else
		if IsAdvanceProf then
			SearchConditions = string.format("Prof = %d and LearnedLevel > %d and LearnedLevel <= %d and IsSpectrum = 0 and bAdvancedProfUse != %d", AdvancedProf, 1, MaxLevel, ProtoRes.prof_level.PROF_LEVEL_BASE)
		else
			SearchConditions = string.format("Prof = %d and LearnedLevel > %d and LearnedLevel <= %d and IsSpectrum = 0", AdvancedProf, MinLevel, MaxLevel)
		end
	end
	local Cfg = SkillLearnedCfg:FindAllCfg(SearchConditions)
	local  IconJob= RoleInitCfg:FindRoleInitProfIconSimple2nd(ProfID)
	for _, value in ipairs(Cfg) do
		local SkillID = value.SkillID
		local SameGroupSkillID = SkillUtil.GetSkillIDByGroupID(value.GroupID, ProfID, MaxLevel)
		if SameGroupSkillID == 0 or SameGroupSkillID == SkillID then
			table.insert(SkillList, {SkillID = SkillID, bHideLearnTips	= value.bHideLearnTips, IconJob = IconJob})
		end
	end
	return SkillList
end

function SkillUtil.IsUnLockSpectrums(Type, ProfID, MinLevel, MaxLevel, IsAdvanceProf)
	if nil == IsAdvanceProf then
		if nil == ProfID or MinLevel >= MaxLevel then
			--
			return 0
		end
	end
	local ProfSkillList = SkillUtil.GetBaseSkillList(Type, ProfID, MaxLevel, true)
	local SpectrumList = ProfSkillList.Spectrum
	for _, SpectrumID in ipairs(SpectrumList) do
		if SpectrumID > 0 then
			local MinLearnStatus = SkillUtil.GetSkillUnlockValid(SpectrumID, ProfID, MinLevel)
			local MaxLearnStatus = SkillUtil.GetSkillUnlockValid(SpectrumID, ProfID, MaxLevel)
			--量谱解锁
			if MaxLearnStatus ~= SkillUtil.SkillLearnStatus.NotLockLevel then
				if IsAdvanceProf and MaxLearnStatus == SkillLearnStatus_Learned then
					return SpectrumID
				elseif MinLearnStatus ~= SkillLearnStatus_Learned and MaxLearnStatus == SkillLearnStatus_Learned then
					return SpectrumID
				else
					return 0
				end
			end
		end
	end
	return 0
end

-- 导出技能展示系统中需要播放Sequence的技能列表
function SkillUtil.GetSkillListForSkillSystemSequence()
	local ProfID = MajorUtil.GetMajorProfID()
	local MapType = SkillUtil.MapType.PVE
	local SkillList = SkillUtil.GetSkillList(MapType, ProfID).SkillList
	local SkillIDList = {}
	local SkillSystemSeriesCfg = require("TableCfg/SkillSystemSeriesCfg")

	for _, SkillInfo in pairs(SkillList) do
		local SkillID = SkillInfo.ID
		local SeriesCfg = SkillSystemSeriesCfg:FindCfgByID(SkillID)
		local SeriesList
		if SeriesCfg then
			SeriesList = string.split(SeriesCfg.SkillQueue, ",")
			local NewSeriesList = {}
			for _, value in ipairs(SeriesList) do
				local SeriesID = tonumber(value)
				table.insert(NewSeriesList, SeriesID)
			end
			SeriesList = NewSeriesList
		end

		if SeriesList and next(SeriesList) then
			for _, SeriesID in pairs(SeriesList) do
				table.insert(SkillIDList, SeriesID)
			end
		elseif SkillID > 10000 then
			table.insert(SkillIDList, SkillID)
		end
	end

	return SkillIDList
end

local IterationState = {
	Continue = 0,
	Break = 1,
}

local function IterateSkillAction(SubSkillID, Func)
	local SkillSubCfg = require("TableCfg/SkillSubCfg")
	local Json = require("Core/Json")

	local CellDataList = _G.SkillActionMgr:GetCellDataList(SubSkillID)
	for _, CellData in pairs(CellDataList) do
		if Func(CellData) == IterationState.Break then
			break
		end
	end
end

function SkillUtil.GetSkillAnimationParams(SubSkillID)
	local StartTime, AnimationAsset, bIsMontage
	IterateSkillAction(SubSkillID, function(ActionInfo)
		if ActionInfo.ClassName == "SkillPlayAnimationAction" and ActionInfo.m_AnimationAsset ~= "None" then
			StartTime, AnimationAsset, bIsMontage =
				ActionInfo.m_StartTime, ActionInfo.m_AnimationAsset, ActionInfo.isMontage
			return IterationState.Break
		end
		return IterationState.Continue
	end)

	if StartTime then
		return StartTime, AnimationAsset, bIsMontage
	end
end

function SkillUtil.GetSkillMoveToTargetParams(SubSkillID)
	local StartTime, EndTime, CurveVectorPath
	IterateSkillAction(SubSkillID, function(ActionInfo)
		if ActionInfo.ClassName == "SkillMoveToAction" then
			StartTime, EndTime, CurveVectorPath =
				ActionInfo.m_StartTime, ActionInfo.m_EndTime, ActionInfo.curveEditorPanel
			return IterationState.Break
		end
		return IterationState.Continue
	end)

	if StartTime then
		return StartTime, EndTime, CurveVectorPath
	end
end

function SkillUtil.GetSkillResetToTargetParams(SubSkillID)
	local StartTime, EndTime
	IterateSkillAction(SubSkillID, function(ActionInfo)
		if ActionInfo.ClassName == "SkillResetToAction" then
			StartTime, EndTime =
				ActionInfo.m_StartTime, ActionInfo.m_EndTime
			return IterationState.Break
		end
		return IterationState.Continue
	end)

	if StartTime then
		return StartTime, EndTime
	end
end

--技能释放埋点
function SkillUtil.AddSkillFlowData(SkillID, SubSkillID)
	--1s内视为一次
	local CurServerTime = TimeUtil.GetServerTimeMS()
	if SubSkillID == SkillFlowLastSkillID and (CurServerTime - SkillFlowLastReportTime) < SkillFlowReportInterval  then
		return
	end
	SkillFlowLastSkillID = SubSkillID
	SkillFlowLastReportTime = CurServerTime
	local key = SkillID.."-"..SubSkillID
    if SkillUtil.ProductionSkillFlowData[key] then
		SkillUtil.ProductionSkillFlowData[key] = SkillUtil.ProductionSkillFlowData[key] + 1 
	else
		SkillUtil.ProductionSkillFlowData[key]= 1
		SkillUtil.ProductionSkillFlowDataLen = SkillUtil.ProductionSkillFlowDataLen + 1
	end
end

function SkillUtil.ReportProductionSkillFlowData()
	local SkillFlowData = ""
	local SkillFlowDataPos = 1
	for key, value in pairs(SkillUtil.ProductionSkillFlowData) do 
		local SkillFlowDataTmp = key.."-"..value
		if SkillFlowDataPos < SkillUtil.ProductionSkillFlowDataLen then
			SkillFlowDataTmp = SkillFlowDataTmp..","
		end
		SkillFlowData = SkillFlowData..SkillFlowDataTmp
		SkillFlowDataPos = SkillFlowDataPos + 1
	end
	--上报数据为空
    if SkillFlowDataPos <= 1 then
        return
    end
	DataReportUtil.ReportProductionSkillFlowData(SkillFlowData)
	SkillUtil.ProductionSkillFlowData = {}
end

local OneVector2D = _G.UE.FVector2D(1, 1)
function SkillUtil.RegisterPressScaleEvent(View, InWidget, InScaleValue, DefaultScaleValue)
	local function ScaleFunc(_, Params)
		local Widget = Params[1]
		local Value = Params[2]
		Widget:SetRenderScale(OneVector2D * Value)
	end
	UIUtil.AddOnPressedEvent(View, InWidget, ScaleFunc, {InWidget, InScaleValue})
	UIUtil.AddOnReleasedEvent(View, InWidget, ScaleFunc, {InWidget, DefaultScaleValue or 1})
end



--无蓄力、连招、副摇杆等数据
function SkillUtil.CastNormalSkillDirect(SkillID, Index, bSendFailedEvent)
	local bCastSuccess = SkillUtil.MajorCastSkill({ SkillType = SkillCastType.NormalType, SkillID = SkillID, Index = Index })
	if not bCastSuccess and bSendFailedEvent then
		_G.EventMgr:SendEvent(EventID.MajorSkillCastFailed, Index)
	end
	return bCastSuccess
end

function SkillUtil.CastSkillDirect(MajorSkill, JoyStickParams, bSendFailedEvent)
	local bCastSuccess = SkillUtil.MajorCastSkill(MajorSkill, JoyStickParams)
	if not bCastSuccess and bSendFailedEvent then
		--TODO[chaooren]2501 该事件目前仅涉及失败后表现，可考虑延迟发送
		_G.EventMgr:SendEvent(EventID.MajorSkillCastFailed, MajorSkill.Index)
	end
	return bCastSuccess
end

local SelectTargetBase = require("Game/Skill/SelectTarget/SelectTargetBase")
local ETargetLockType = _G.UE.ETargetLockType
local ZeroVector = _G.UE.FVector(0, 0, 0)

function SkillUtil.MajorCastSkill(MajorSkill, JoyStickParams)
	local SkillID = MajorSkill.SkillID
	if MajorSkill.SkillType ~= SkillCastType.NormalType then
		SkillID = MajorSkill.QueueSkillID
	end

	local MainCfg = SkillMainCfg:FindCfgByKey(SkillID)
	if not MainCfg then
		FLOG_WARNING("[SkillUtil]no main skill %d", SkillID or 0)
		return false
	end

	local _ <close> = CommonUtil.MakeProfileTag("SkillUtil.MajorCastSkill " .. tostring(SkillID))
	local SubSkillID = _G.SkillLogicMgr:GetMultiSkillReplaceResult(SkillID, 0)

	local Cfg = SkillSubCfg:FindCfgByKey(SubSkillID)
	if not Cfg then
		FLOG_WARNING("[SkillUtil]no sub skill %d in main skill %d", SubSkillID or 0, SkillID)
		return false
	end

	local IsSwitchTargetWhenCastSkill = Cfg.IsSwitchTargetCastSkill
	local CanCastSkillWithoutTarget = Cfg.IsCastWithoutTarget

	local Major = MajorUtil.GetMajor()
	local MajorEntityID = MajorUtil.GetMajorEntityID()

	local Position = nil
	local Angle = nil
	local bJoyStick = false
	if JoyStickParams then
		Position = JoyStickParams.Position
		Angle = JoyStickParams.Angle
		bJoyStick = true
	end
	local SelectedTargetList, CanCastSkill = _G.SelectTargetMgr:CppCastSkillSelectTargets(SkillID, SubSkillID, 1, Major, false, IsSwitchTargetWhenCastSkill == 0, Position, Angle)

	if not CanCastSkill then
		return false
	end

	if not _G.SkillObjectMgr:CheckSkillWeight(MajorEntityID, MainCfg.SkillWeight) then
		return false
	end

	local function MountCancelCallback(bSync)
		local MajorController = MajorUtil.GetMajorController()
		if MajorController == nil then
			return false
		end
		--到这一步应当返回true,C++侧做了保护
		return MajorController:MajorCastSkill(SkillID, SubSkillID, MajorSkill.SkillType, MajorSkill.CfgID, MajorSkill.QueueIndex, MajorSkill.Index or -1, SelectedTargetList, bJoyStick, Position or ZeroVector, Angle or 0)
	end



	local MountMgr = _G.MountMgr
	if MountMgr:IsInRide() and not MountMgr:IsMountSkill(SkillID) then
		return MountMgr:SendMountCancelCall(MountCancelCallback, true)
	end

	return MountCancelCallback(true)
end

--- 获取模拟吟唱时间
---@param SkillID integer 主表ID
---@param SubSkillID integer 子表ID
---@param MainCfg table|nil 主表Cfg, 可为nil, 外部如果已经查过表, 可以把Cfg直接传进来避免再查一次
---@param SubCfg table|nil 子表Cfg, 设计同上
---@return integer 吟唱时间(ms)
function SkillUtil.GetSimulateSingTime(SkillID, SubSkillID, MainCfg, SubCfg)
	MainCfg = MainCfg or SkillMainCfg:FindCfgByKey(SkillID)
	SubCfg = SubCfg or SkillSubCfg:FindCfgByKey(SubSkillID)
	if not MainCfg then
		return 0
	end
	local SimulateSingTime = MainCfg.SimulateSingTime
	if SubCfg then
		local OverrideSimulateSingTime = SubCfg.OverrideSimulateSingTime
		if OverrideSimulateSingTime and OverrideSimulateSingTime > 0 then
			SimulateSingTime = OverrideSimulateSingTime
		end
	end
	return SimulateSingTime or 0
end

return SkillUtil