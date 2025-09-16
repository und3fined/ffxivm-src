--
-- Author: chaooren
-- Date: 2021-09-17
-- Description:
--
local CommonDefine = require("Define/CommonDefine")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local CommonUtil = require("Utils/CommonUtil")
local EActorType = _G.UE.EActorType
local SelectTargetBase = require("Game/Skill/SelectTarget/SelectTargetBase")
local ProtoRes = require("Protocol/ProtoRes")
local CommonVfxCfg = require("TableCfg/CommonVfxCfg") 
local VfxswitchBlockeffectCfg = require("TableCfg/VfxswitchBlockeffectCfg") 
local UE = _G.UE

---@class EffectUtil
local EffectUtil = {

}

local EffectLODSlover = _G.UE.EffectLODSlover
function EffectUtil.GetMajorEffectLOD(Rule)
	return EffectLODSlover.GetMajorEffectLOD(Rule or UE.ELODRuleType.DefaultRule)
end

function EffectUtil.GetPlayerEffectLOD(Rule)
	return EffectLODSlover.GetPlayerEffectLOD(Rule or UE.ELODRuleType.DefaultRule)
end

function EffectUtil.GetTeammateEffectLOD(Rule)
	return EffectLODSlover.GetTeammateEffectLOD(Rule or UE.ELODRuleType.DefaultRule)
end

function EffectUtil.GetEnemyPlayerEffectLOD(Rule)
	return EffectLODSlover.GetEnemyPlayerEffectLOD(Rule or UE.ELODRuleType.DefaultRule)
end

function EffectUtil.GetBOSSEffectLOD(Rule)
	return EffectLODSlover.GetBOSSEffectLOD(Rule or UE.ELODRuleType.DefaultRule)
end

--return bValid, LOD
function EffectUtil.GetEntityEffectLOD(EntityID, Rule)
	return EffectUtil.GetEntityEffectLODInternal(EntityID, Rule)
end

function EffectUtil.LoadVfx(VfxParameter)
	return _G.UE.UFGameFXManager.Get():LoadVfx(VfxParameter)
end

function EffectUtil.UnloadVfx(ID)
	return _G.UE.UFGameFXManager.Get():UnloadVfx(ID)
end

function EffectUtil.PlayVfxByID(ID, FadeInTime)
	return _G.UE.UFGameFXManager.Get():PlayVfxByID(ID, FadeInTime or 0)
end

function EffectUtil.PlayDiscard(ID)
	return _G.UE.UFGameFXManager.Get():PlayDiscard(ID)
end

function EffectUtil.PlayVfxQuick(Path, Location, Rotation)
	if Path == nil then
		FLOG_WARNING("[EffectUtil] PlayVfxQuick Path is nil")
		return 0
	end
	Location = Location or UE.FVector()
	Rotation = Rotation or UE.FQuat()
	local VfxParameter = _G.UE.FVfxParameter()
	VfxParameter.VfxRequireData.EffectPath = Path
	VfxParameter.VfxRequireData.VfxTransform = _G.UE.FTransform(Rotation, Location)

	return _G.UE.UFGameFXManager.Get():PlayVfxByParam(VfxParameter, 0)
end

function EffectUtil.PlayVfx(VfxParameter, FadeInTime)
	return _G.UE.UFGameFXManager.Get():PlayVfxByParam(VfxParameter, FadeInTime or 0)
end

function EffectUtil.StopVfx(VfxID, FadeOutTime, BreakTime)
	_G.UE.UFGameFXManager.Get():StopVfx(VfxID, FadeOutTime or 0, BreakTime or 0)
end

function EffectUtil.KickTriggerByID(VfxID, TriggerID)
	return _G.UE.UFGameFXManager.Get():KickTriggerByID(VfxID, TriggerID)
end

function EffectUtil.KickTrigger(VfxParameter, TriggerID)
	return _G.UE.UFGameFXManager.Get():KickTriggerByParam(VfxParameter, TriggerID)
end

function EffectUtil.SetVfxColor(VfxID, Color)
	return _G.UE.UFGameFXManager.Get():SetColor(VfxID, Color)
end


local USkillDecalMgr = _G.UE.USkillDecalMgr
function EffectUtil.PlaySkillDecal(SkillDecalInfo, SkillDecalCompleteCallback)
	if not SkillDecalCompleteCallback then
		return USkillDecalMgr.Get():PlaySkillDecal(SkillDecalInfo, nil)
	end

	local CallBack = nil
	if SkillDecalCompleteCallback then
		CallBack = function(_, ID)
			if SkillDecalCompleteCallback then
				SkillDecalCompleteCallback(ID)
			end
		end
	end
	return USkillDecalMgr.Get():PlaySkillDecal(SkillDecalInfo, CommonUtil.GetDelegatePair(CallBack, true))
end

function EffectUtil.BreakSkillDecal(ID)
	_G.UE.USkillDecalMgr:Get():BreakSkillDecal(ID)
end

function EffectUtil.SetSkillDecalLocation(ID, Location)
	_G.UE.USkillDecalMgr:Get():SetLocation(ID, Location)
end

function EffectUtil.SetSkillDecalRotation(ID, Rotation)
	_G.UE.USkillDecalMgr:Get():SetRotation(ID, Rotation)
end

function EffectUtil.SetSkillDecalState(ID, State)
	_G.UE.USkillDecalMgr:Get():SetDecalState(ID, State)
end

function EffectUtil.SetWorldEffectMaxCount(MaxCount)
	_G.UE.UFGameFXManager:Get():SetWorldEffectMaxCount(MaxCount)
end

function EffectUtil.SetWorldTransform(ID,WorldTransform)
	_G.UE.UFGameFXManager:Get():SetWorldTransform(ID,WorldTransform)
end

local function Clamp(Value, Min, Max)
	if Value < Min then
		return Min
	end
	if Value > Max then
		return Max
	end
	return Value
end

function EffectUtil.SetQualityLevelFXLOD(Level)
	Level = Clamp(Level, 0, 4)
	local LODOffset = CommonDefine.QualityLevelFXLOD[Level]

	local QualityLevelLOD = EffectLODSlover.QualityLevelLOD
	QualityLevelLOD.MajorEffectLOD = LODOffset.Major
	QualityLevelLOD.TeammateEffectLOD = LODOffset.Player
	QualityLevelLOD.PlayerEffectLOD = LODOffset.Player
	QualityLevelLOD.EnemyPlayerEffectLOD = LODOffset.Player
	QualityLevelLOD.BOSSEffectLOD = LODOffset.Boss
end

function EffectUtil.SetQualityLevelFXMaxCount(Level)
	Level = Clamp(Level, 0, 4)
	local MaxCount = CommonDefine.QualityLevelFXMaxCount[Level]
	EffectUtil.SetWorldEffectMaxCount(MaxCount)
end

function EffectUtil.SetCombatFXLOD(Index, Type)
	FLOG_WARNING("Deprecated function EffectUtil.SetCombatFXLOD")
	-- local LODValue = CommonDefine.CombatFXLOD[Index]

	-- local CombatLOD = EffectLODSlover.CombatLOD
	-- if Type == 0 then
	-- 	CombatLOD.MajorEffectLOD = LODValue
	-- elseif Type == 1 then
	-- 	CombatLOD.TeammateEffectLOD = LODValue
	-- elseif Type == 2 then
	-- 	CombatLOD.PlayerEffectLOD = LODValue
	-- elseif Type == 3 then
	-- 	CombatLOD.EnemyPlayerEffectLOD = LODValue
	-- end
end

function EffectUtil.GetEntityEffectLODInternal(EntityID, Rule)
	local bValid = false
	local OutLOD = 0
	local BaseCharacter = ActorUtil.GetActorByEntityID(EntityID)
	if BaseCharacter == nil then
		return bValid, OutLOD
	end
	local ActorType = BaseCharacter:GetActorType()
	if ActorType == EActorType.Major then
		OutLOD = EffectUtil.GetMajorEffectLOD(Rule)
		bValid = true
	elseif ActorType == EActorType.Monster then
		--怪物都先视为boss，后续区分
		OutLOD = EffectUtil.GetBOSSEffectLOD(Rule)
		bValid = true
	elseif ActorType == EActorType.Player then
		if _G.TeamMgr:IsTeamMemberByEntityID(EntityID) then
			OutLOD = EffectUtil.GetTeammateEffectLOD(Rule)
			bValid = true
		else
			local CampRelation = SelectTargetBase:GetCampRelationByMajor(MajorUtil.GetMajor(), BaseCharacter)
			if CampRelation == ProtoRes.camp_relation.camp_relation_ally then
				OutLOD = EffectUtil.GetPlayerEffectLOD(Rule)
			elseif CampRelation == ProtoRes.camp_relation.camp_relation_enemy then
				OutLOD = EffectUtil.GetEnemyPlayerEffectLOD(Rule)
			end
			bValid = true
		end
	end
	return bValid, OutLOD
end

function EffectUtil.SetIsInDialog(bInDialog)
    _G.UE.UFGameFXManager.Get():SetIsInDialog(bInDialog)
	EffectUtil.UpdateInDialogOrSeq()
end

function EffectUtil.SetIsInMiniGame(bInMiniGame)
    _G.UE.UFGameFXManager.Get():SetIsInMiniGame(bInMiniGame)
	EffectUtil.UpdateInDialogOrSeq()
end



function EffectUtil.UpdateInDialogOrSeq()
	local bShow =  not _G.UE.UFGameFXManager.Get():GetNeedSheildEff()
	_G.EventMgr:SendEvent(EventID.UpdateInDialogOrSeq, bShow)
end

--- 通用特效表特效播放调用接口
---@param CommonID number@通用特效表ID
---@param PlaySourceType _G.UE.EVFXPlaySourceType@Vfx所属资源类型
---@param CasterOrTarget boolean@Vfx资源属于施法者还是目标判断
---@param AttachPointType _G.UE.EVFXAttachPointType@Vfx资源挂点类型
---@return int64
function EffectUtil.PlayVfxByCommonID(CommonID, PlaySourceType, CasterOrTarget, AttachPointType)
	if not CommonID or CommonID == 0 then
		return 0
	end

	local SearchCond = string.format("ID = %d", CommonID)
	local VfxCfg = CommonVfxCfg:FindCfg(SearchCond)
	if not VfxCfg then
		return 0
	end

	local VfxPath = VfxCfg.Path
	if not VfxPath then
		return 0
	end

	local FrontPart = string.sub(VfxPath, 1, #VfxPath - 1)
	local BehindPart = string.sub(VfxPath, #VfxPath)
	local VfxParameter = _G.UE.FVfxParameter()
    local Major = MajorUtil.GetMajor()
	local BeUsedPath = string.format("%s_C%s", FrontPart, BehindPart)
    VfxParameter.VfxRequireData.EffectPath = BeUsedPath
    VfxParameter.PlaySourceType = PlaySourceType
	VfxParameter.VfxRequireData.VfxTransform = Major:GetTransform()
	VfxParameter.VfxRequireData.bAlwaysSpawn = Major:GetActorType() == EActorType.Major
	if CasterOrTarget then
		VfxParameter:SetCaster(Major, 0, AttachPointType, 0)
	else
		VfxParameter:AddTarget(Major, 0, AttachPointType, 0)
	end
	return _G.UE.UFGameFXManager.Get():PlayVfxByParam(VfxParameter, 0)
end

function EffectUtil.SetForceLOD(LodLevel)
	_G.UE.UFGameFXManager.Get():SetForceLOD(LodLevel)
end

function EffectUtil.InVfxEffectBlockeList(SubSkillID)
	local Cfg = VfxswitchBlockeffectCfg:FindCfgByKey(SubSkillID)
	return Cfg ~= nil
end

function EffectUtil.SetForceDisableCache(bDisable)
	_G.UE.UFGameFXManager.Get():SetForceDisableCache(bDisable)
end

--这是个test func，别用
function EffectUtil.PlayVfxDebug(Path, Location, Rotation, Scale, CasterEntityID, ...)
	-- if bShipping then
	-- 	CRASH!!!!!!!!!!!!!
	-- end
	Location = Location or UE.FVector()
	Rotation = Rotation or UE.FQuat()
	Scale = Scale or UE.FVector(1, 1, 1)
	local VfxParameter = _G.UE.FVfxParameter()
	VfxParameter.VfxRequireData.EffectPath = Path
	VfxParameter.VfxRequireData.VfxTransform = _G.UE.FTransform(Rotation, Location, Scale)
	if CasterEntityID and CasterEntityID > 0 then
		VfxParameter:SetCaster(ActorUtil.GetActorByEntityID(CasterEntityID), 0, 0, 0)
	end
	local Params = table.pack(...)
	for key, value in pairs(Params) do
		if value > 0 then
			VfxParameter:AddTarget(ActorUtil.GetActorByEntityID(value), 0, 0, 0)
		end
	end
	return _G.UE.UFGameFXManager.Get():PlayVfxByParam(VfxParameter, 0)
end

_G.PlayVfxDebug = EffectUtil.PlayVfxDebug

--同样的test func
function EffectUtil.GetVfxInfoDebug()
	return _G.UE.UFGameFXManager.Get():GetVfxInfoDebug()
end

function EffectUtil.LogVfxInfoDebug()
	return _G.UE.UFGameFXManager.Get():GetVfxInfoDebug()
end

return EffectUtil