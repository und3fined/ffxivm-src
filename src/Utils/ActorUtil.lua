---
--- Author: anypkvcai
--- DateTime: 2021-03-05 17:01
--- Description:
---
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoBuff = require("Network/ProtoBuff")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local MonsterCfg = require("TableCfg/MonsterCfg")
local NpcCfg = require("TableCfg/NpcCfg")
local CompanionCfg = require("TableCfg/CompanionCfg")
local GatherPointCfg = require("TableCfg/GatherPointCfg")
local EobjCfg = require("TableCfg/EobjCfg")
local UserDataConfig = require("Define/UserDataConfig")
local ChangeRoleCfg = require("TableCfg/ChangeRoleCfg")
local ClosetCfg = require("TableCfg/ClosetCfg")
local ObjectGCType = require("Define/ObjectGCType")
local SaveKey = require("Define/SaveKey")

local CombatActionID = ProtoCommon.CombatActionID

local EActorType
local UActorManager
local UActorUtil
local LocalizationCfg = {}

local LookAtCameraParams = _G.UE.FLookAtParams()
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")

---@class ActorUtil
local ActorUtil = {

}

--要不要打开技能阻挡判定
ActorUtil.SkillBlockEnable = true

ActorUtil.ShadowType = {
	Role = "Role", --人形
	Mount = "Mount", --坐骑
	PreviewMount = "PreviewMount", --坐骑预览
	Wardrobe = "Wardrobe",-- 衣橱
	Chocobo = "Chocobo",  --陆行鸟
	StoreRole = "StoreRole", --商城——人物
	StoreMount = "StoreMount", --商城——坐骑
	Companion = "Companion", --宠物图鉴
	StoreCompanion = "StoreCompanion", --商城——宠物
	ChocoboArmor = "ChocoboArmor", --鸟甲图鉴
	ChocoboList = "ChocoboList", --陆行鸟一览
	ChocoboRental = "ChocoboRental", --陆行鸟租借
	Partner = "Partner", --搭档外观
	Barbershop = "Barbershop", --理发屋
	OtherEquipment = "OtherEquipment", --查看他人装备
	LoginRole = "LoginRole", --角色背景创角
	LoginStarry = "LoginStarry" --星空背景创角
}

function ActorUtil.Init()
	EActorType = _G.UE.EActorType
	UActorManager = _G.UE.UActorManager.Get()
	UActorUtil = _G.UE.UActorUtil

	LocalizationCfg = {
		[EActorType.Monster] 	= MonsterCfg,
		[EActorType.Npc] 	 	= NpcCfg,
		[EActorType.Companion] 	= CompanionCfg,
		[EActorType.Gather] 	= GatherPointCfg,
		[EActorType.EObj] 	 	= EobjCfg,
	}
end

---GetActorAttributeComponent
---@return UAttributeComponent
function ActorUtil.GetActorAttributeComponent(EntityID)
	return UActorUtil.GetActorAttributeComponent(EntityID)
end

function ActorUtil.GetActorProfID(EntityID)
	local AttributeComponent = UActorUtil.GetActorAttributeComponent(EntityID)
	if nil ~= AttributeComponent then
		return AttributeComponent.ProfID
	end

	return 0
end

--现在只对eobj和npc生效
function ActorUtil.GetActorCreateTime(EntityID)
	local AttributeComponent = UActorUtil.GetActorAttributeComponent(EntityID)
	if nil ~= AttributeComponent then
		return AttributeComponent.CreateTime
	end

	return 0
end

---GetActorStateComponent
---@return UStateComponent
function ActorUtil.GetActorStateComponent(EntityID)
	return UActorUtil.GetActorStateComponent(EntityID)
end

function ActorUtil.IsCombatState(EntityID)
	return UActorUtil.IsCombatState(EntityID)
end

---GetActorAvatarComponent
---@return UAvatarComponent
function ActorUtil.GetActorAvatarComponent(EntityID)
	return UActorUtil.GetActorAvatarComponent(EntityID)
end

---获取Actor的职业类
---@return ProtoCommon.class_type
function ActorUtil.GetActorProfClass(EntityID)
	local AttrComp = ActorUtil.GetActorAttributeComponent(EntityID)
	if AttrComp == nil then
		return
	end
	local Prof = AttrComp.ProfID
	return RoleInitCfg:FindProfClass(Prof)
end

---GetActorAnimationComponent
---@return UAnimationComponent
function ActorUtil.GetActorAnimationComponent(EntityID)
	return UActorUtil.GetActorAnimationComponent(EntityID)
end

---GetActorBuffComponent
---@return UBuffComponent
function ActorUtil.GetActorBuffComponent(EntityID)
	return UActorUtil.GetActorBuffComponent(EntityID)
end

---GetActorCombatComponent
---@return UCombatComponent
function ActorUtil.GetActorCombatComponent(EntityID)
	return UActorUtil.GetActorCombatComponent(EntityID)
end

---GetActorResID
---@param EntityID number
---@return number
function ActorUtil.GetActorResID(EntityID)
	--第二个参数true意思是允许使用异步创建Actor时缓存下来的信息，这样可以避免查询操作将Actor立刻创建出来
	return UActorUtil.GetActorResID(EntityID, true)
end

---GetActorType
---@param EntityID number
---@return number                 @EActorType
function ActorUtil.GetActorType(EntityID)
	--第二个参数true意思是允许使用异步创建Actor时缓存下来的信息，这样可以避免查询操作将Actor立刻创建出来
	return UActorUtil.GetActorType(EntityID, true)
end

---GetActorSubType
---@param EntityID number
---@return number                 @EActorSubType
function ActorUtil.GetActorSubType(EntityID)
	--第二个参数true意思是允许使用异步创建Actor时缓存下来的信息，这样可以避免查询操作将Actor立刻创建出来
	return UActorUtil.GetActorSubType(EntityID, true)
end

---GetActorTargetID
---@param EntityID number
---@return number                @EntityID
function ActorUtil.GetActorTargetID(EntityID)
	return UActorUtil.GetActorTargetID(EntityID)
end

---GetActorOwner
---@param EntityID number
---@return number                @EntityID
function ActorUtil.GetActorOwner(EntityID)
	return UActorUtil.GetActorOwner(EntityID)
end

---GetActorName
---@param EntityID number
---@return string
function ActorUtil.GetActorName(EntityID)
	local ActorType = ActorUtil.GetActorType(EntityID)
	local Cfg = LocalizationCfg[ActorType]
	if nil == Cfg then -- 非LocalizationCfg配置的Actor，仍然从属性组件拿ActorName
		local AttrComponent = ActorUtil.GetActorAttributeComponent(EntityID)
		if nil == AttrComponent then
			return ""
		end

		return AttrComponent.ActorName or ""
	end

	local ResID = ActorUtil.GetActorResID(EntityID)
	local Data = Cfg:FindCfgByKey(ResID) or {}
	return Data.Name or ""
end

---GetChangeRoleNameOrNil
---@param EntityID number
---@return string
function ActorUtil.GetChangeRoleNameOrNil(EntityID)
	local ChangeRoleName = nil
	local AttrComponent = ActorUtil.GetActorAttributeComponent(EntityID)
	if nil ~= AttrComponent then
		local ChangeRoleID = AttrComponent:GetChangeRoleID()
		if 0 ~= ChangeRoleID then
			local Data = ChangeRoleCfg:FindCfgByKey(ChangeRoleID)
			if nil ~= Data then
				if Data.Name ~= nil and Data.Name ~= "" then
					ChangeRoleName = Data.Name
				end
			end
		end
	end
	return ChangeRoleName
end

---GetActorHP
---@param EntityID number
---@return number
function ActorUtil.GetActorHP(EntityID)
	return UActorUtil.GetActorAttrValue(EntityID, ProtoCommon.attr_type.attr_hp)
end

---GetActorMaxHP
---@param EntityID number
---@return number
function ActorUtil.GetActorMaxHP(EntityID)
	return UActorUtil.GetActorAttrValue(EntityID, ProtoCommon.attr_type.attr_hp_max)
end

---GetActorMP
---@param EntityID number
---@return number
function ActorUtil.GetActorMP(EntityID)
	return UActorUtil.GetActorAttrValue(EntityID, ProtoCommon.attr_type.attr_mp)
end

---GetActorMaxMP
---@param EntityID number
---@return number
function ActorUtil.GetActorMaxMP(EntityID)
	return UActorUtil.GetActorAttrValue(EntityID, ProtoCommon.attr_type.attr_mp_max)
end

---GetActorGP
---@param EntityID number
---@return number
function ActorUtil.GetActorGP(EntityID)
	return UActorUtil.GetActorAttrValue(EntityID, ProtoCommon.attr_type.attr_gp)
end

---GetActorMaxGP
---@param EntityID number
---@return number
function ActorUtil.GetActorMaxGP(EntityID)
	return UActorUtil.GetActorAttrValue(EntityID, ProtoCommon.attr_type.attr_gp_max)
end

---IsInComBatState
---@param CombatStatID number            @ProtoCommon.CombatStatID
---@return number
function ActorUtil.IsInComBatState(EntityID, CombatStatID)
	return UActorUtil.IsInComBatState(EntityID, CombatStatID)
end

function ActorUtil.IsDeadState(EntityID)
	return UActorUtil.IsDeadState(EntityID)
end

---GetActorControlState
---@param EntityID number
---@param State number            @ProtoCommon.CombatActionID
---@return boolean
function ActorUtil.GetActorControlState(EntityID, State)
	return UActorUtil.GetActorControlState(EntityID, State)
end

---IsInShowHeadUIState
---@param EntityID number
---@return boolean
function ActorUtil.IsInShowHeadUIState(EntityID)
	return ActorUtil.GetActorControlState(EntityID, CombatActionID.COMBAT_ACTION_SHOW_HEAD_UI)
end

---@param EntityID number
---@return boolean
function ActorUtil.IsInCanSkillSelectedState(EntityID)
	return ActorUtil.GetActorControlState(EntityID, CombatActionID.COMBAT_STAT_SKILL_SELECTED)
end

---@param EntityID number
---@return boolean
function ActorUtil.IsInCanPlayerSelectedState(EntityID)
	return ActorUtil.GetActorControlState(EntityID, CombatActionID.COMBAT_STAT_PLAYER_SELECTED)
end

---@param EntityID number
---@return boolean
function ActorUtil.IsCanUseSkill(EntityID)
	return ActorUtil.GetActorControlState(EntityID, CombatActionID.COMBAT_ACTION_USESKILL)
end

---GetEntityIDByRoleID
---@param RoleID number
function ActorUtil.GetEntityIDByRoleID(RoleID)
	return UActorUtil.GetEntityIDByRoleID(RoleID)
end

---GetRoleIDByEntityID @找不到时可能会同步创建角色
---@param EntityID number
function ActorUtil.GetRoleIDByEntityID(EntityID)
	return UActorUtil.GetRoleIDByEntityID(EntityID)
end

---GetExistActorByEntityID @只查找已经创建的角色
---@param EntityID number
function ActorUtil.GetExistActorByEntityID(EntityID)
	return UActorUtil.GetExistActorByEntityID(EntityID)
end

---GetRoleIDByEntityID
---@param EntityID number
function ActorUtil.GetRoleVMByEntityID(EntityID)
	local RoleID = UActorUtil.GetRoleIDByEntityID(EntityID)
	if RoleID then
		return _G.RoleInfoMgr:FindRoleVM(RoleID)
	end
end

---若想获取指定actor，尽量避免使用此接口。换用(EntityID)最准确，或(ResID+ListID)相对安全
function ActorUtil.GetActorByResID(ResID)
	return UActorUtil.GetActorByResID(ResID)
end

function ActorUtil.GetActorByResIDAndListID(ResID, ListID)
	return UActorUtil.GetActorByResIDAndListID(ResID, ListID)
end

function ActorUtil.GetActorEntityIDByResID(ResID)
	local Actor = UActorUtil.GetActorByResID(ResID)
	if Actor then
		local AttrComp = Actor:GetAttributeComponent()
        if AttrComp then return AttrComp.EntityID end
	end

	return nil
end

function ActorUtil.GetActorEntityID(Actor)
	if Actor then
		local AttrComp = Actor:GetAttributeComponent()
        if AttrComp then return AttrComp.EntityID end
	end

	return 0
end

---GetActorByEntityID
---@param EntityID table
---@return ABaseCharacter
function ActorUtil.GetActorByEntityID(EntityID)
	return UActorUtil.GetActorByEntityID(EntityID)
end

---GetActorByRoleID
---@param RoleID number
---@return ABaseCharacter
function ActorUtil.GetActorByRoleID(RoleID)
	return UActorUtil.GetActorByRoleID(RoleID)
end

--老接口，最好不要用，不同类型的Actor类ListID可能相同，应该用GetActorByTypeAndListID
---GetActorByListID
---@param ListID number
---@return ABaseCharacter
function ActorUtil.GetActorByListID(ListID)
	return UActorUtil.GetActorByListID(ListID)
end

---GetActorByTypeAndListID
---@param ListID number
---@return ABaseCharacter
function ActorUtil.GetActorByTypeAndListID(ActorType, ListID)
	return UActorUtil.GetActorByTypeAndListID(ActorType, ListID)
end

---IsNpc
---@param EntityID number
---@return boolean
function ActorUtil.IsNpc(EntityID)
	local ActorType = ActorUtil.GetActorType(EntityID)

	return ActorType == EActorType.Npc
end

---IsMonster
---@param EntityID number
---@return boolean
function ActorUtil.IsMonster(EntityID)
	local ActorType = ActorUtil.GetActorType(EntityID)

	return ActorType == EActorType.Monster
end

---IsMajor
---@param EntityID table
---@return boolean
function ActorUtil.IsMajor(EntityID)
	local ActorType = ActorUtil.GetActorType(EntityID)

	return ActorType == EActorType.Major
end

---IsPlayer
---@param EntityID table
---@return boolean
function ActorUtil.IsPlayer(EntityID)
	local ActorType = ActorUtil.GetActorType(EntityID)

	return ActorType == EActorType.Player
end

--- 检查Character是否是EObj类型
---@param EntityID any
function ActorUtil.IsEObj(EntityID)
	local ActorType = ActorUtil.GetActorType(EntityID)
	return ActorType == EActorType.EObj
end

---IsMajor
---@param EntityID table
---@return boolean
function ActorUtil.IsPlayerOrMajor(EntityID)
	local ActorType = ActorUtil.GetActorType(EntityID)

	return ActorType == EActorType.Major or ActorType == EActorType.Player
end

---IsGather
---@param EntityID table
---@return boolean
function ActorUtil.IsGather(EntityID)
	local ActorType = ActorUtil.GetActorType(EntityID)

	return ActorType == EActorType.Gather
end

---IsBuddy
---@param EntityID number
---@return boolean
function ActorUtil.IsBuddy(EntityID)
	local SubType = ActorUtil.GetActorSubType(EntityID)
	return SubType == _G.UE.EActorSubType.Buddy
end

---GetOwnerRoleID
---@param EntityID number
---@return number
function ActorUtil.GetOwnerRoleID(EntityID)
	local OwnerID = ActorUtil.GetActorOwner(EntityID) or 0
	return ActorUtil.GetRoleIDByEntityID(OwnerID)
end

---怪物子类型
function ActorUtil.GetMonsterSubType(EntityID)
	if not ActorUtil.IsMonster(EntityID) then
		return 0
	end

	return UActorUtil.GetMonsterSubType(EntityID)

	--[[ 老的配表方式，已废弃
	local MonsterResID = ActorUtil.GetActorResID(EntityID)
	local MonsterTableCfg = MonsterCfg:FindCfgByKey(MonsterResID)
	if (MonsterTableCfg == nil) then
		return 0
	end

	return MonsterTableCfg.SubType
	--]]
end

function ActorUtil.GetMonsterEnmityID(EntityID)
	if not ActorUtil.IsMonster(EntityID) then
		return
	end
	local ResID = ActorUtil.GetActorResID(EntityID)
	return MonsterCfg:FindValue(ResID, "EnmityID")
end

function ActorUtil.IsBossMonster(EntityID)
	local SubType = ActorUtil.GetMonsterSubType(EntityID)
	return SubType == ProtoRes.monster_sub_type.MONSTER_SUB_TYPE_BOSS
end

---IsTeamCaption @怪物来源
---@param EntityID number
---@return number @VMonster.Source.Type
function ActorUtil.GetMonsterSourceType(EntityID)
	return UActorUtil.GetMonsterSourceType(EntityID)
end

---GetTeamFlag @获取视野玩家队伍标志
---@param EntityID number
---@return number @VROLE_TEAM_FLAG
function ActorUtil.GetTeamFlag(EntityID)
	return UActorUtil.GetTeamFlag(EntityID)
end

---IsTeamCaption @视野玩家是否队长
---@param EntityID number
---@return boolean
function ActorUtil.IsTeamCaption(EntityID)
	local TeamFlag = ActorUtil.GetTeamFlag(EntityID)
	return TeamFlag == ProtoCS.VROLE_TEAM_FLAG.VROLE_FLAG_TEAM_CAPTAIN
end

---IsTeamCaption @视野玩家是否在进行招募
---@param EntityID number
---@return boolean
function ActorUtil.IsTeamRecruiting(EntityID)
	local TeamRecruitID = UActorUtil.GetTeamRecruitID(EntityID)
	return TeamRecruitID > 0
end

---IsTeamMember
---@param EntityID number
---@return boolean @视野玩家是否队队员
function ActorUtil.IsTeamMember(EntityID)
	local TeamFlag = ActorUtil.GetTeamFlag(EntityID)
	return TeamFlag == ProtoCS.VROLE_TEAM_FLAG.VROLE_FLAG_TEAM_MEMBER
end

---HasTeam
---@param EntityID number
---@return boolean @视野玩家是否有组队
function ActorUtil.HasTeam(EntityID)
	local TeamFlag = ActorUtil.GetTeamFlag(EntityID)
	return TeamFlag == ProtoCS.VROLE_TEAM_FLAG.VROLE_FLAG_TEAM_MEMBER or TeamFlag == ProtoCS.VROLE_TEAM_FLAG.VROLE_FLAG_TEAM_CAPTAIN
end

---GetTeamFlag @获取视野玩家阵营
---@param EntityID number
---@return number
function ActorUtil.GetActorCamp(EntityID)
	return UActorUtil.GetActorCamp(EntityID)
end

---IsClientActor
---@param EntityID number
function ActorUtil.IsClientActor(EntityID)
	return UActorUtil.IsClientActor(EntityID)
end

function ActorUtil.LookAtActor(FromActor, TargetActor)
	if TargetActor and FromActor then
		UActorUtil.LookAtActor(FromActor, TargetActor)
		-- local TargetRotation = _G.UE.UKismetMathLibrary.FindLookAtRotation(FromActor:FGetLocation(), TargetActor:FGetLocation())
		-- TargetRotation.Pitch = 0
		-- FromActor:FSetRotationForServer(TargetRotation)
	end
end

function ActorUtil.LookAtPos(FromActor, TargetPos)
	if TargetPos and FromActor then
		UActorUtil.LookAtPos(FromActor, TargetPos)
		-- local TargetRotation = _G.UE.UKismetMathLibrary.FindLookAtRotation(FromActor:FGetLocation(), TargetPos)
		-- TargetRotation.Pitch = 0
		-- FromActor:FSetRotationForServer(TargetRotation)
	end
end

function ActorUtil.GetMonsterAnimations(ResID)
	local Paths = _G.UE.UActorManager:Get():GetMonsterAnimations(ResID)
	local Table = Paths:ToTable()
	return Table
end

--Owner朝向Target并同步旋转
function ActorUtil.InitSelectPosAndDirInfo(Owner, Target)
	_G.UE.UCombatComponent.InitSelectPosAndDirInfo(Owner, Target)
end

--false:有技能阻挡 true：没有技能阻挡，可以正常释放技能
function ActorUtil.CheckBlock(Caster, Target)
	if ActorUtil.SkillBlockEnable then
		if (_G.GMMgr:IsShowDebugTips()) then
			local StartPos = Caster:FGetActorLocation()
			local EndPos = Target:FGetActorLocation()
			_G.UE.UCommonUtil.DrawLine(StartPos, EndPos)
		end

		--	EyeLineTrace中会统一加高施法者和目标的z坐标
		return not UActorUtil.EyeLineTrace(Caster, Target)
	end

	return true
end

--false:有技能阻挡 true：没有技能阻挡，可以正常释放技能
--ActionPos都是服务器坐标（EXLocationType.ServerLoc），z算是贴地面的
--	EyeLineTraceByActor中会统一加高
function ActorUtil.CheckBlockByActionPos(ActionPos, Target)
	if ActorUtil.SkillBlockEnable then
		if (_G.GMMgr:IsShowDebugTips()) then
			local EndPos = Target:FGetActorLocation()
			--ActionPos的z在EyeLineTraceByActor中会被加高
			_G.UE.UCommonUtil.DrawLine(ActionPos, EndPos)
		end

		return not UActorUtil.EyeLineTraceByActor(ActionPos, Target)
	end

	return true
end

function ActorUtil.CheckPawnBlockByPos(StartPos, TargetPos)
	return not UActorUtil.PawnTraceByPos(StartPos, TargetPos)
end


---UpdateAnimClass
---@param Character UE.ABaseCharacter
---@param RoleSimple common.RoleSimple
function ActorUtil.UpdateAnimClass(Character, AnimClass)
	if nil == Character or nil == AnimClass then
		return
	end
	local MeshComp = Character:GetMeshComponent()
	if nil == MeshComp then
		return
	end
	MeshComp:SetAnimClass(AnimClass)
end

---UpdateAvatar
---@param Character UE.ABaseCharacter
---@param RoleSimple common.RoleSimple
function ActorUtil.UpdateAvatar(Character, RoleSimple)
	if nil == Character or RoleSimple == nil then
		return
	end
	local AvatarComp = Character:GetAvatarComponent()
	if nil == AvatarComp then
		return
	end

	local RoleAvatar = RoleSimple.Avatar
	ActorUtil.UpdateNakedBody(Character, RoleSimple)
	ActorUtil.UpdateEquips(Character, RoleAvatar)
	if RoleAvatar then
		ActorUtil.SetCustomizeAvatarFace(Character, RoleAvatar.Face)
	end
	AvatarComp:StartLoad(true)
end

---UpdateNakedBody
---@param Character UE.ABaseCharacter
---@param RoleSimple common.RoleSimple
function ActorUtil.UpdateNakedBody(Character, RoleSimple)
	if nil == Character or RoleSimple == nil then
		return
	end
	local AttributeComp = Character:GetAttributeComponent()
	if nil == AttributeComp then
		return
	end
	AttributeComp.RaceID = RoleSimple.Race
	AttributeComp.Gender = RoleSimple.Gender
	AttributeComp.ProfID = RoleSimple.Prof
	AttributeComp:SetTribeID(RoleSimple.Tribe)
	local AvatarComp = Character:GetAvatarComponent()
	if nil == AvatarComp then
		return
	end

	AvatarComp:UpdateDefaultBody()
	AvatarComp:AddAllNakedBody()
end

---UpdateEquips
---@param Character UE.ABaseCharacter
---@param RoleAvatar common.RoleAvatar
function ActorUtil.UpdateEquips(Character, RoleAvatar)
	local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")

	if nil == Character or RoleAvatar == nil then
		return
	end
	local AvatarComp = Character:GetAvatarComponent()
	if nil == AvatarComp then
		return
	end
	local Assembler = AvatarComp:GetAssembler()

	local EquipList = RoleAvatar.EquipList

	local bSetPreviewSectionStain = false;
	for _, Equip in pairs(EquipList) do
		local EquipID = WardrobeUtil.GetEquipID(Equip.EquipID, Equip.ResID, Equip.RandomID)
		AvatarComp:HandleAvatarEquip(EquipID, Equip.Part, -1, false, Equip.ColorID, true)
		if Assembler then
			local AppID = Equip.ResID
			local AvatarPartType = WardrobeDefine.StainPartType[Equip.Part]

			--先将该部位原来的染色数据清空，这个部位有外观、且有染色数据的情况下会重新设置
			Assembler:ClearPartSectionStain(AvatarPartType)
			
			for _, RegionDye in ipairs(Equip.RegionDyes or {}) do
				local SectionList = WardrobeUtil.ParseSectionIDList(AppID, RegionDye.ID)
				for _, SectionID in ipairs(SectionList) do
					if bSetPreviewSectionStain == false then
						bSetPreviewSectionStain = true
						AvatarComp:SetPreviewSectionStain(true)
					end
					Assembler:StainPartForSection(AvatarPartType, tonumber(SectionID) - 1, RegionDye.ColorID)
				end
			end
		end
	end
end

function ActorUtil.GetActorRegionDyesInfo(EntityID)
	local RoleSimple = nil
	local MajorUtil = require("Utils/MajorUtil")
	if EntityID == MajorUtil.GetMajorEntityID() then
		RoleSimple = MajorUtil.GetMajorRoleSimple()
	else
		local RoleVM = ActorUtil.GetRoleVMByEntityID(EntityID)
		RoleSimple = RoleVM and RoleVM.RoleSimple or nil
	end
	if RoleSimple and RoleSimple.Avatar then
		return RoleSimple.Avatar.EquipList or {}
	end
	return {}
end

function ActorUtil.UpdateEquipRegionDyes(Character, PartID, EquipList)
	if nil == Character or nil == PartID then
		return
	end
	local AvatarComp = Character:GetAvatarComponent()
	if nil == AvatarComp then
		return
	end
	local Assembler = AvatarComp:GetAssembler()
	if nil == Assembler then
		return
	end

	local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
	local AvatarPartType = WardrobeDefine.StainPartType[PartID]
	--先将该部位原来的染色数据清空，这个部位有外观、且有染色数据的情况下会重新设置
	Assembler:ClearPartSectionStain(AvatarPartType)

	if nil == EquipList then
		return
	end

	local EquipAvatar = table.find_by_predicate(EquipList, function(e) return e.Part == PartID end)
	if not EquipAvatar then
		return
	end

	local AppID = EquipAvatar.ResID or 0
	local RegionDyes = EquipAvatar.RegionDyes or {}
	if AppID == 0 or table.size(RegionDyes) == 0 then
		return
	end

	local bSetPreviewSectionStain = false;
	for _, RegionDye in ipairs(RegionDyes ) do
		local SectionList = WardrobeUtil.ParseSectionIDList(AppID, RegionDye.ID)
		for _, SectionID in ipairs(SectionList) do
			if bSetPreviewSectionStain == false then
				bSetPreviewSectionStain = true
				AvatarComp:SetPreviewSectionStain(true)
			end
			Assembler:StainPartForSection(AvatarPartType, tonumber(SectionID) - 1, RegionDye.ColorID)
		end
	end
end

---SetCustomizeAvatar @设置角色捏脸数据
---@param Character ABaseCharacter
---@param AvatarFace common.RoleAvatar.Face
function ActorUtil.SetCustomizeAvatarFace(Character, AvatarFace)
	if nil == Character or AvatarFace == nil then
		return
	end
	local AvatarComp = Character:GetAvatarComponent()
	if nil == AvatarComp then
		return
	end
	local FaceMap = _G.UE.TMap(_G.UE.int32, _G.UE.int32)
	for key, value in pairs(AvatarFace) do
		FaceMap:Add(key, value)
	end
	AvatarComp:SetAvatarAllCustomize(FaceMap, true)
	local AttributeComp = Character:GetAttributeComponent()
    if not AttributeComp then
        return
    end

    if AttributeComp.ObjType == _G.UE.EActorType.UIActor then
		AvatarComp:SetForcedLODForAll(1)
	end
end

---SetUILookAt @设置UICharacter的LookAt（使用LoginAnimBlueprint的UI）
---@param Character ABaseCharacter
---@param bOpen bool
---@param LookAtType _G.UE.ELookAtType
---@param bOpen bool
---@param bUseLoginCamera bool
function ActorUtil.SetUILookAt(Character, bOpen, LookAtType, bUseLoginCamera)
	-- 旧版LoginLookAt
	--if Character then
		-- Character:UseAnimLookAt(bOpen)
		-- local AnimComp = Character:GetAnimationComponent()
		-- if AnimComp and bOpen and LookAtType ~= nil then
		-- 	local AnimInst = AnimComp:GetAnimInstance()
		-- 	if AnimInst then
		-- 		AnimInst:SetLookAtType(LookAtType)
		-- 		AnimInst:SetUseLoginCamera(bUseLoginCamera or false)
		-- 	end
		-- end
	--end
	if Character then
		Character:UpdateLookAtLayer(true)
		local SetLookAtType = bOpen and LookAtType or _G.UE.ELookAtType.None
		ActorUtil.SetCharacterLookAtCamera(Character, SetLookAtType)
	end
end

---SetUILookAt @设置场景内角色Character的LookAt全参数
---@param Character ABaseCharacter
---@param LookAtParams _G.UE.FLookAtParams
function ActorUtil.SetCharacterLookAtParams(Character, LookAtParams)
	if Character then
		local AnimComp = Character:GetAnimationComponent()
		if AnimComp and LookAtParams ~= nil then
			AnimComp:SetLookAtParam(LookAtParams)
		end
	end
end

---SetUILookAt @设置场景内角色Character的LookAt相机
---@param Character ABaseCharacter
---@param LookAtType _G.UE.ELookAtType
function ActorUtil.SetCharacterLookAtCamera(Character, LookAtType)
	LookAtCameraParams.LookAtType = LookAtType
	LookAtCameraParams.Target.Type = _G.UE.ELookAtTargetType.Camera
	ActorUtil.SetCharacterLookAtParams(Character, LookAtCameraParams)
end

---MarkComponentsRenderStateDirty @刷新actor组件渲染
---@param Actor UE.AActor
function ActorUtil.MarkComponentsRenderStateDirty(Actor)
	if Actor then
		UActorUtil.MarkComponentsRenderStateDirty(Actor)
	end
end

function ActorUtil.IsRunningState(EntityID)
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if Actor == nil then return false end
	return Actor:IsRunningState()
end

function ActorUtil.GetInteractionObjInfo(EntityID)
    local Actor = ActorUtil.GetActorByEntityID(EntityID)
    if not Actor then
        return nil, nil
    end

	local ObjID = EntityID
	local IsClientActor = false

	local ActorType = ActorUtil.GetActorType(EntityID)
    if Actor:IsClientActor() then
        local AttrCmp = Actor:GetAttributeComponent()
        if AttrCmp then
            ObjID = AttrCmp.ListID
        end

        IsClientActor = true
    end

    local ObjType = nil
    if ActorType == _G.UE.EActorType.EObj then
        if IsClientActor then
            ObjType = ProtoCS.InteractionObjType.InteractionObjTypeEobjListID
        else
            ObjType = ProtoCS.InteractionObjType.InteractionObjTypeEobj
        end
    elseif ActorType == _G.UE.EActorType.Npc then
        if IsClientActor then
            ObjType = ProtoCS.InteractionObjType.InteractionObjTypeNPCListID
        else
            ObjType = ProtoCS.InteractionObjType.InteractionObjTypeNPC
        end
    end

	return ObjType, ObjID
end


---GetUserData @获取Actor通过视野下发的UserData字段
---@param EntityID EntityID
---@param UserDataID 在'Define/UserDataID'中定义，在'Define/UserDataConfig'中配置UserDataID对应的ModuleID、Key、Message名称
---@return table类型UserData数据
function ActorUtil.GetUserData(EntityID, UserDataID)
	local Config = UserDataConfig[UserDataID]
	if Config == nil then return end
	local AttrComp = ActorUtil.GetActorAttributeComponent(EntityID)
	if AttrComp == nil then return nil end
	local Bytes = AttrComp:GetRawUserData(Config.ModuleID, Config.Key)
	local UserData = ProtoBuff:Decode(Config.MessageName, Bytes)
	return UserData
end

---ActorUtil.SetUserData 填充Actor的UserData字段
---@param EntityID   EntityID
---@param UserDataID 在'Define/UserDataID'中定义，在'Define/UserDataConfig'中配置UserDataID对应的ModuleID、Key、Message名称
---@param Data       table类型，输入的UserData数据
function ActorUtil.SetUserData(EntityID, UserDataID, Data)
	local Config = UserDataConfig[UserDataID]
	if Config == nil then return end
	local AttrComp = ActorUtil.GetActorAttributeComponent(EntityID)
	if AttrComp == nil then return nil end
	local Bytes = ProtoBuff:Encode(Config.MessageName, Data)
	AttrComp:SetRawUserData(Config.ModuleID, Config.Key, Bytes)
end

function ActorUtil.IsClimbingState(EntityID)
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if Actor == nil then return false end
	return Actor:IsClimbingState()
end

---IsInRide @获取Actor是否乘坐坐骑
---@param EntityID   EntityID
function ActorUtil.IsInRide(EntityID)
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if Actor then
		local RideComp = Actor:GetRideComponent()
		if RideComp then
			return RideComp:IsInRide()
		end
	end
	return false
end

function ActorUtil.RemoveComponentOverlap(Actor, Target)
	if Actor and Target then
		UActorUtil.RemoveComponentOverlap(Actor, Target)
	end
end

---创建UI影子, 模块接入后需要和Release成对调用，
---@param WorldContextObject UObject 上下文对象，参考CommonRender2DView
---@param TargetActor AActor  需要影子的对象
---@param InImage UImage 目标图片
---@param Location FVector 坐标，默认(-50, 0, 100002)，根据模块自身调整
---@param SystemType string 系统类型，目前只有人形和坐骑类型
function ActorUtil.CreateUIActorShandow(WorldContextObject, TargetActor, InImage, Location, Type, IsComplexActor)
	if not WorldContextObject or not TargetActor or not InImage then
		FLOG_ERROR("[UIActorShandow] Param Is Nil! Please Check")
		return
	end

	--低，极低画质关闭阴影
	local QualityLevel = _G.UE.USaveMgr.GetInt(SaveKey.QualityLevel, _G.SettingsMgr.DefauleValueNotSave, false)
	if QualityLevel <= 2 then
		FLOG_INFO("[UIActorShandow] QualityLevel Low")
		return
	end

	local AllActor = _G.UE.TArray(_G.UE.AActor)
	if IsComplexActor then
		for key, value in pairs(TargetActor) do
			AllActor:Add(value)
		end
	else
		AllActor:Add(TargetActor)
	end
    local Path = "Class'/Game/MaterialLibrary/Blueprint/PlaneShadow/BP_Character_PlaneShadow.BP_Character_PlaneShadow_C'"
	local Class = ObjectMgr:LoadClassSync(Path, ObjectGCType.NoCache)
    Location = Location or _G.UE.FVector(-50, 0, 100002)
    local ShandowActor = CommonUtil.SpawnActor(Class, Location)
	if not ShandowActor then return end
	ShandowActor:UseSetting(Type or ActorUtil.ShadowType.Role)
	local RenderTexture = nil
	local Scale2D = nil
    local CaptureComp2D = ShandowActor.SceneCaptureComponent2D
	if CaptureComp2D then
		--默认256x256
		CaptureComp2D.bCaptureEveryFrame = true
		CaptureComp2D:ClearShowOnlyComponents()
		CaptureComp2D:SetVisibility(true)
		CaptureComp2D.ShowOnlyActors = AllActor
	end

	--持有的引用各个模块自行销毁
	return ShandowActor, RenderTexture
end

function ActorUtil.SetUIActorShandowType(ShandowActor, Type)
	if not ShandowActor then return end
	ShandowActor:UseSetting(Type or ActorUtil.ShadowType.Role)
end

--这里只会把Rt放回缓存池，各个模块持有的引用自行置为nil
function ActorUtil.RealseUIActorShandow(RT)
	if not RT or not _G.CommonUtil.IsObjectValid(RT) then
		FLOG_ERROR("[UIActorShandow] RT Is Nil! Please Check")
		return
	end
	_G.CommonModelToImageMgr:ReleaseRenderTarger2D(RT)
end

return ActorUtil