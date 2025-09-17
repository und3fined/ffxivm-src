---
--- Author: anypkvcai
--- DateTime: 2021-04-29 17:15
--- Description:
---

local ProtoCommon = require("Protocol/ProtoCommon")
local ActorUtil = require("Utils/ActorUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local RaceCfg = require("TableCfg/RaceCfg")
local ProfUtil = require("Game/Profession/ProfUtil")
local ProtoRes = require("Protocol/ProtoRes")

local ActorMgr
local UActorManager
local UMajorUtil

---@class MajorUtil
local MajorUtil = {

}

function MajorUtil.Init()
	ActorMgr = _G.ActorMgr
	UActorManager = _G.UE.UActorManager:Get()
	UMajorUtil = _G.UE.UMajorUtil
end

---GetMajor
---@return AMajorCharacter
function MajorUtil.GetMajor()
	return UMajorUtil.GetMajor()
end

---GetMajorController
---@return AMajorController
function MajorUtil.GetMajorController()
	return UMajorUtil.GetMajorController()
end

---GetMajorAttributeComponent
---@return UAttributeComponent
function MajorUtil.GetMajorAttributeComponent()
	return UMajorUtil.GetMajorAttributeComponent()
	-- local EntityID = UMajorUtil.GetMajorEntityID()
	-- return ActorUtil.GetActorAttributeComponent(EntityID)
end

---GetMajorStateComponent
---@return UStateComponent
function MajorUtil.GetMajorStateComponent()
	return UMajorUtil.GetMajorStateComponent()
	-- local EntityID = UMajorUtil.GetMajorEntityID()
	-- return ActorUtil.GetActorStateComponent(EntityID)
end

---GetMajorAvatarComponent
---@return UAvatarComponent
function MajorUtil.GetMajorAvatarComponent()
	return UMajorUtil.GetMajorAvatarComponent()
	-- local EntityID = UMajorUtil.GetMajorEntityID()
	-- return ActorUtil.GetActorAvatarComponent(EntityID)
end

---GetMajorAnimationComponent
---@return UAnimationComponent
function MajorUtil.GetMajorAnimationComponent()
	return UMajorUtil.GetMajorAnimationComponent()
	-- local EntityID = UMajorUtil.GetMajorEntityID()
	-- return ActorUtil.GetActorAnimationComponent(EntityID)
end

---GetMajorCameraControlComponent
---@return UStateComponent
function MajorUtil.GetMajorCameraControlComponent()
	return UMajorUtil.GetMajorCameraControlComponent()
end

function MajorUtil.GetMajorCombatComponent()
	return UMajorUtil.GetMajorCombatComponent()
	-- local EntityID = UMajorUtil.GetMajorEntityID()
	-- return ActorUtil.GetActorCombatComponent(EntityID)
end

function MajorUtil.GetMajorBuffComponent()
	return UMajorUtil.GetMajorBuffComponent()
	-- local EntityID = UMajorUtil.GetMajorEntityID()
	-- return ActorUtil.GetActorBuffComponent(EntityID)
end

function MajorUtil.GetMajorRideComponent()
	return UMajorUtil.GetMajorRideComponent()
end

---GetMajorEntityID
function MajorUtil.GetMajorEntityID()
	return UMajorUtil.GetMajorEntityID()
end

---IsMajor
---@param EntityID number
---@return boolean
function MajorUtil.IsMajor(EntityID)
	return MajorUtil.GetMajorEntityID() == EntityID
end

---IsMajorByRoleID
---@param RoleID number
---@return boolean
function MajorUtil.IsMajorByRoleID(RoleID)
	return MajorUtil.GetMajorRoleID() == RoleID
end

--这个接口装备列表，局内的话，simple里是没更新的
--得用MajorUtil.GetMajorRoleDetail()  的 RoleDetail.Equip.EquipList
---GetMajorRoleSimple
---@return RoleSimple
function MajorUtil.GetMajorRoleSimple()
	local RoleVM = MajorUtil.GetMajorRoleVM()
	if RoleVM then
		return RoleVM.RoleSimple
	end
end

---GetMajorRoleDetail
---@return RoleDetail
function MajorUtil.GetMajorRoleDetail()
	local RoleDetail = ActorMgr.MajorRoleDetail
	if nil == RoleDetail then
		return
	end

	return RoleDetail
end

---GetMajorRoleID
---@return number
function MajorUtil.GetMajorRoleID()
	return ActorMgr.MajorRoleID
end

---GetMajorWorldID
---@return number
function MajorUtil.GetMajorWorldID()
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if nil == RoleSimple then
		return
	end

	return RoleSimple.WorldID
end

---GetMajorOpenID
---@return number
function MajorUtil.GetMajorOpenID()
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if nil == RoleSimple then
		return
	end

	return RoleSimple.OpenID

end

---GetMajorActorName
---@return string
function MajorUtil.GetMajorName()
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if nil == RoleSimple then
		return
	end

	return "G Mys7ery"-- RoleSimple.Name
end

function MajorUtil.GetMajorPortrait()
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if nil == RoleSimple or nil == RoleSimple.HeadData then
		return
	end

	return RoleSimple.HeadData.HeadUrl
end

---GetMajorProfID
---@return number
function MajorUtil.GetMajorProfID()
	local ProfID = UMajorUtil.GetMajorProfID()
	if ProfID > 0 then
		return ProfID
	end

	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if nil == RoleSimple then
		return
	end

	return RoleSimple.Prof
end

--是不是基职
function MajorUtil.IsProfBase()
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if RoleSimple then
		local ProfID = RoleSimple.Prof
		local ProfLevel = RoleInitCfg:FindProfLevel(ProfID)
		if ProfLevel == ProtoRes.prof_level.PROF_LEVEL_BASE then
			return true
		end
	end

	return false
end

--是不是特职
function MajorUtil.IsProfAdvance()
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if RoleSimple then
		local ProfID = RoleSimple.Prof
		local ProfLevel = RoleInitCfg:FindProfLevel(ProfID)
		if ProfLevel == ProtoRes.prof_level.PROF_LEVEL_ADVANCED then
			return true
		end
	end

	return false
end

---获取Major的职业类
---@return ProtoCommon.class_type
function MajorUtil.GetMajorProfClass()
	local ProfID = MajorUtil.GetMajorProfID()
	if nil == ProfID then
		return
	end
	return RoleInitCfg:FindProfClass(ProfID)
end

function MajorUtil.GetMajorProfFunc()
	local ProfID = MajorUtil.GetMajorProfID()
	if ProfID then
		return RoleInitCfg:FindFunction(ProfID)
	end
end

---GetMajorProfSpecialization 获取Major的职业性质
---@return ProtoCommon.specialization_type
function MajorUtil.GetMajorProfSpecialization()
	return RoleInitCfg:FindProfSpecialization(MajorUtil.GetMajorProfID())
end

---GetMajorLevel
---@return number
function MajorUtil.GetMajorLevel()
	local RoleVM = MajorUtil.GetMajorRoleVM()
	if RoleVM then
		return RoleVM.PWorldLevel
	end

	return 1
end

---获取真实等级
---@return number
function MajorUtil.GetTrueMajorLevel()
	local RoleVM = MajorUtil.GetMajorRoleVM()
	if RoleVM then
		return RoleVM.Level
	end
end

---GetMajorLevelByProf
---@return number
function MajorUtil.GetMajorLevelByProf(Prof)
	local RoleVM = MajorUtil.GetMajorRoleVM()
	if RoleVM then
		return RoleVM:GetProfLevel(Prof)
	end

	return 1
end

---GetMajorGender
---@return number
function MajorUtil.GetMajorGender()
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if nil == RoleSimple then
		return
	end

	return RoleSimple.Gender
end

---GetMajorResID
---@return number
function MajorUtil.GetMajorResID()
	return UMajorUtil.GetMajorResID()
	-- local EntityID = UMajorUtil.GetMajorEntityID()
	-- return ActorUtil.GetActorResID(EntityID)
end

---GetMajorRaceName
---@return string
function MajorUtil.GetMajorRaceName()
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if nil == RoleSimple then
		return
	end
	local RaceName = RaceCfg:GetRaceName(RoleSimple.Race)

	return RaceName or ""
end

---GetMajorRaceID
---@return number
function MajorUtil.GetMajorRaceID()
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if nil == RoleSimple then
		return
	end

	return RoleSimple.Race
end

---GetMajorCurHp
---@return number
function MajorUtil.GetMajorCurHp()
	return UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_hp)
end

---GetMajorMaxHp
---@return number
function MajorUtil.GetMajorMaxHp()
	return UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_hp_max)
end

---GetMajorCurMp
---@return number
function MajorUtil.GetMajorCurMp()
	return UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_mp)
end

---GetMajorMaxMp
---@return number
function MajorUtil.GetMajorMaxMp()
	return UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_mp_max)
end

---GetMajorCurGp
---@return number
function MajorUtil.GetMajorCurGp()
	return UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_gp)
end

---GetMajorMaxGp
---@return number
function MajorUtil.GetMajorMaxGp()
	return UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_gp_max)
end

---GetMajorCurMk
---@return number
function MajorUtil.GetMajorCurMk()
	return UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_mk)
end

---GetMajorMaxMk
---@return number
function MajorUtil.GetMajorMaxMk()
	return UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_mk_max)
end

---SetCanControlCamera
---@param CanControlCamera boolean
function MajorUtil.SetCanControlCamera(CanControlCamera)
	local Component = MajorUtil.GetMajorCameraControlComponent()
	if nil == Component then
		return
	end

	Component:SetCanControlCamera(CanControlCamera)
end

function MajorUtil.IsMajorCombat()
	return UMajorUtil.IsMajorCombat()
end

--是否生活职业(在策划眼里都是生产职业中的采集职业)
function MajorUtil.IsGpProf()
	local MajorProfID = MajorUtil.GetMajorProfID()
	return ProfUtil.IsGpProf(MajorProfID)
end

--是否采集职业(不包含钓鱼的采集职业)
function MajorUtil.IsGatherProf()
	local MajorProfID = MajorUtil.GetMajorProfID()
	if MajorProfID == ProtoCommon.prof_type.PROF_TYPE_MINER
			or MajorProfID == ProtoCommon.prof_type.PROF_TYPE_BOTANIST then
		return true
	end

	return false
end

--是否是捕鱼职业
function MajorUtil.IsFishingProf()
	local MajorProfID = MajorUtil.GetMajorProfID()
	if MajorProfID == ProtoCommon.prof_type.PROF_TYPE_FISHER then
		return true
	end
	return false
end

--是否制造职业
function MajorUtil.IsCrafterProf()
	local MajorProfID = MajorUtil.GetMajorProfID()
	return ProfUtil.IsCrafterProf(MajorProfID)
end

function MajorUtil.IsCrafterProfByProfID(ProfID)
	return ProfUtil.IsCrafterProf(ProfID)
end

--主角是否死亡，没有State组件也被视为主角死亡
function MajorUtil.IsMajorDead()
	return UMajorUtil.IsMajorDead()
end

function MajorUtil.IsMajorInsideWall()
    local MajorActor = MajorUtil.GetMajor()
    if not MajorActor then
        _G.FLOG_WARNING("[mount] SendMountCancelCall MajorActor Is nil!")
        return false
    end
    if MajorActor and MajorActor:GetMovementComponent() and MajorActor:GetMovementComponent():CheckIsInsideWall() then
        return true
    end
    return false
end

function MajorUtil.LookAtActor(TargetEntityID)
	if TargetEntityID and TargetEntityID > 0 then
		UMajorUtil.LookAtActor(TargetEntityID)
	end
end

--谨慎使用_主角Tick旋转插值（只会原地转身生效，移动中不生效）
function MajorUtil.LookAtActorByInterp(TargetEntityID, Speed)
	if TargetEntityID and TargetEntityID > 0 then
		UMajorUtil.LookAtActorByInterp(TargetEntityID, Speed)
	end
end


function MajorUtil.LookAtPos(TargetPos)
	if TargetPos then
		UMajorUtil.LookAtPos(TargetPos)
	end
end

---获取主角RoleVM数据
---@param IsUseCache boolean @是否使用缓存
-- @return RoleVM
function MajorUtil.GetMajorRoleVM(IsUseCache)
	local RoleInfoMgr = _G.RoleInfoMgr
	if nil == RoleInfoMgr then -- Fixed 未选角进入游戏前调用本函数导致的报错问题
		return
	end

	local MajorID = MajorUtil.GetMajorRoleID()
	local MajorVM = RoleInfoMgr:FindRoleVM(MajorID, IsUseCache ~= false)
	return MajorVM
end

---GetMajorTargetID
---@return number
function MajorUtil.GetMajorTargetID()
	return UMajorUtil.GetMajorTargetID()
end

---IsInLevelSync 是否处于等级同步状态
---@return boolean
function MajorUtil.IsInLevelSync()
	local RoleDetail = MajorUtil.GetMajorRoleDetail()
	if nil == RoleDetail then
		return false
	end
	return RoleDetail.Prof.Sync
end

function MajorUtil.SetPWorldLevel(Level)
	local AttrComp = MajorUtil.GetMajorAttributeComponent()
	if AttrComp then
		AttrComp.Level = Level
	end

	local RoleVM = MajorUtil.GetMajorRoleVM()
	if RoleVM then
		RoleVM:SetPWorldLevel(Level)
	end
end

function MajorUtil.SetEquipScore(EquipScore)
	local RoleVM = MajorUtil.GetMajorRoleVM()
	if nil ~= RoleVM then
		RoleVM:SetEquipScore(EquipScore)
	end
end

function MajorUtil.SetCameraControlEnabled(bEnabled)
	local MajorController = UMajorUtil.GetMajorController()
	if MajorController == nil then return end
	MajorController:SetEnableCameraControl(bEnabled)
end

function MajorUtil.UpdMvpTimes()
	local MVPCount = _G.CounterMgr:GetCounterCurrValue(19900)
    if MVPCount then
        MajorUtil.GetMajorRoleVM(true):SeMvpInfo(MVPCount)
    end
end

function MajorUtil.IsUsingSkill()
	return _G.SkillObjectMgr:GetOrCreateEntityData(MajorUtil.GetMajorEntityID()).CurrentSkillObject ~= nil
end

--- 已激活职业中最高等级
function MajorUtil.GetMaxProfLevel()
	local RoleVM = MajorUtil.GetMajorRoleVM()
	if RoleVM then
		return RoleVM:GetMaxProfLevel()
	end

	return 0
end

--- 战斗职业最高等级
function MajorUtil.GetMaxCombatProfLevel()
	local MaxLevel = 0
    for _, ProfID in pairs(ProtoCommon.prof_type) do
        if ProfID ~= 0 and ProfUtil.IsCombatProf(ProfID) then
            local ProfLevel = MajorUtil.GetMajorLevelByProf(ProfID)
            ProfLevel = ProfLevel or 0
            if ProfLevel > MaxLevel then
                MaxLevel = ProfLevel
            end
        end
    end

    return MaxLevel
end

-- 同步主角移动消息
---SyncSelfMoveReq
---@param bForceSend boolean @是否强制同步，不管cut、死亡等条件判定
function MajorUtil.SyncSelfMoveReq(bForceSend)
	local UMoveSyncMgr = _G.UE.UMoveSyncMgr:Get()
	UMoveSyncMgr:SyncSelf(bForceSend)
end


-- 是否在下落状态
function MajorUtil.IsFalling()
	local MajorActor = MajorUtil.GetMajor()
	if MajorActor then
		return MajorActor:IsFallingState()
	end
	return false
end

-- 是否有速度
function MajorUtil.IsMajorHaveVec()
	local MajorActor = MajorUtil.GetMajor()
	if not MajorActor then
		return false
	end
	local MajorCharacterMovementComp = MajorActor.CharacterMovement
	if not MajorCharacterMovementComp then
		return false
	end
	
	local MajorVelocity = MajorCharacterMovementComp.Velocity
	if not MajorVelocity then
		return false
	end

	local INF = 0.000000001
	return MajorVelocity:Size() > INF
end

-- 是否处于跨界状态
function MajorUtil.IsVisitWorld()
	local RoleVM = MajorUtil.GetMajorRoleVM()
    if RoleVM == nil then
        return false
    end

    local CurWorldID = RoleVM.CurWorldID
    if not CurWorldID or CurWorldID == 0 then
        return false -- 默认值默认为非跨服状态
    end

    return CurWorldID ~= RoleVM.WorldID
end

return MajorUtil