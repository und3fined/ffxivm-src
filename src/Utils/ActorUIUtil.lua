--
-- Author: loiafeng
-- Date : 2024-03-12 20:35:58
-- Description: ActorUI显示工具，ActorUI目前包括HUD中Actor头顶UI以及主界面选中Actor后上方信息栏
--

local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local ClientSetupMgr = require("Game/ClientSetup/ClientSetupMgr")
local SelectTargetBase = require("Game/Skill/SelectTarget/SelectTargetBase")

local ProtoRes = require("Protocol/ProtoRes")
local ActorUIColorCfg = require("TableCfg/ActorUiColorCfg")
local DefaultActorUIColorSettingsCfg = require("TableCfg/DefaultActorUiColorSettingsCfg")
local NpcCfg = require("TableCfg/NpcCfg")
local CombatStatCfg = require("TableCfg/CombatStatCfg")

local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local TeamHelper = require("Game/Team/TeamHelper")

local EActorType = _G.UE.EActorType
local ACTOR_UI_TYPE = ProtoRes.ActorUIType
local NPC_TYPE = ProtoRes.NPC_TYPE

local ActorUIUtil = {}

---获取ColorID
---@param ActorUIType number ProtoRes.ACTOR_UI_TYPE
---@return number ColorID
function ActorUIUtil.GetUIColorID(ActorUIType)
    if type(ActorUIType) ~= "number" then return -1 end

	-- 提审红色变紫色
	-- if _G.LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_VERIFY) then
	-- 	if ActorUIType == ACTOR_UI_TYPE.ActorUITypeEnemy or ActorUIType == ACTOR_UI_TYPE.ActorUITypeMonster3 then
	-- 		ActorUIType = ACTOR_UI_TYPE.ActorUITypeMonster4
	-- 	end
	-- end

    -- 优先使用玩家在ClientSetup中配置的ColorID，暂时只支持Major、TeamMember、Friend和Player
    local SetupKey = nil
    if ActorUIType == ACTOR_UI_TYPE.ActorUITypeMajor then
        SetupKey = ClientSetupID.ActorUIColorMajor
    elseif ActorUIType == ACTOR_UI_TYPE.ActorUITypeTeamMember then
        SetupKey = ClientSetupID.ActorUIColorTeamMember
    elseif ActorUIType == ACTOR_UI_TYPE.ActorUITypeFriend then
        SetupKey = ClientSetupID.ActorUIColorFriend
	elseif ActorUIType == ACTOR_UI_TYPE.ActorUITypePlayer then
		SetupKey = ClientSetupID.ActorUIColorPlayer
    end

    local SetupValue = SetupKey and ClientSetupMgr:GetSetupValue(MajorUtil.GetMajorRoleID(), SetupKey)
    local Result = tonumber(SetupValue)

    -- 玩家没有配置则使用表格中配置的默认ColorID
    if nil == Result then
        local Cfg = DefaultActorUIColorSettingsCfg:FindCfgByKey(ActorUIType)
        Result = Cfg and Cfg.ColorID or -1
    end

    return Result
end

---@class ActorUIColorConfig
---@field Palette string
---@field Text string
---@field TextOutline string
---@field HPBarFill string
---@field HPBarBackground string
---@field HPBarOutline string
---@field HPBarShadow string
---@field SelectArrow string
---@field ActorDecal string

---@type table HUD颜色查询较为频繁，这里加一级缓存
local UIColorCache = {}

local ErrorColor = {
    Palette = "000000ff",
    Text = "000000ff",
    TextOutline = "000000ff",
    HPBarFill = "000000ff",
    HPBarBackground = "000000ff",
    HPBarOutline = "000000ff",
    HPBarShadow = "000000ff",
    SelectArrow = "000000ff",
    ActorDecal = "000000ff",
}

---获取Color配置
---@param ColorID number
---@return ActorUIColorConfig
function ActorUIUtil.GetUIColorFromColorID(ColorID)
    local Cfg = ActorUIColorCfg:FindCfgByKey(ColorID)
    return Cfg or ErrorColor
end

---获取Color配置
---@param ActorUIType number ProtoRes.ACTOR_UI_TYPE
---@return ActorUIColorConfig
function ActorUIUtil.GetUIColorFromUIType(ActorUIType)
    local ColorID = ActorUIUtil.GetUIColorID(ActorUIType)
    return ActorUIUtil.GetUIColorFromColorID(ColorID)
end

---获取Color配置
---@param EntityID number
---@return ActorUIColorConfig
function ActorUIUtil.GetUIColor(EntityID)
    local ActorUIType = ActorUIUtil.GetActorUIType(EntityID)
    return ActorUIUtil.GetUIColorFromUIType(ActorUIType)
end

---在ActorUI中，副本匹配的玩家也视为队友
function ActorUIUtil.IsTeamMember(EntityID)
	return TeamHelper.GetTeamMgr():IsTeamMemberByEntityID(EntityID) or TeamHelper.GetTeamMgr():IsTeamMemberByRoleID(ActorUtil.GetRoleIDByEntityID(EntityID))
end

---GetActorUIType 判断Actor的UI类型。注意，本函数依赖视野包的信息。
---ActorUIColorType根据以下规则决定：
--- 1. 玩家: 队友、阵营、好友、其他
--- 2. 怪物：阵营、首伤（归属）者、是否有仇恨、是否满血
--- 3. 主角、Npc、宠物、采集物、eobj等等
---@param EntityID number
---@return number ProtoRes.ACTOR_UI_TYPE
function ActorUIUtil.GetActorUIType(EntityID)
	local ActorType = ActorUtil.GetActorType(EntityID)

	if EActorType.Major == ActorType then
		return ACTOR_UI_TYPE.ActorUITypeMajor

	elseif EActorType.Player == ActorType then
		if ProtoRes.camp_relation.camp_relation_enemy == SelectTargetBase:GetCampRelationByEntityID(EntityID) then
			return ACTOR_UI_TYPE.ActorUITypeEnemy
		elseif TeamHelper.GetTeamMgr():IsTeamMemberByEntityID(EntityID) then
			return ACTOR_UI_TYPE.ActorUITypeTeamMember
		elseif _G.FriendMgr:IsFriend(ActorUtil.GetRoleIDByEntityID(EntityID)) then
			return ACTOR_UI_TYPE.ActorUITypeFriend
		else
			return ACTOR_UI_TYPE.ActorUITypePlayer
		end

	elseif EActorType.Monster == ActorType then
		local Relation = SelectTargetBase:GetCampRelationByEntityID(EntityID)
		--如果是友好、中立阵营的，则当成npc的样式
		--敌对阵营的才是怪物本来的样式
		if ProtoRes.camp_relation.camp_relation_enemy ~= Relation then
			return ACTOR_UI_TYPE.ActorUITypeNPC
		end

		local AttributeComponent = ActorUtil.GetActorAttributeComponent(EntityID)
		if nil == AttributeComponent then
			return  ACTOR_UI_TYPE.ActorUITypeMonster1
		end

		local CurHP = AttributeComponent:GetCurHp()
		local MaxHP = AttributeComponent:GetMaxHp()
		local EnmityTarget = _G.TargetMgr:GetTargetOfMonster(EntityID)  -- 是否有仇恨
		local FirstAttackerEntityID = AttributeComponent.FirstAttackerEntityID  -- 已经是溯源过的了
		local FirstAttackerRoleID = AttributeComponent.FirstAttackerRoleID  -- 已经是溯源过的了

		--print("ActorUIUtil.GetActorUIType", CurHP, MaxHP, Target, ActorUtil.GetActorName(Target))

		if EnmityTarget <= 0 then  -- 无仇恨
			return ACTOR_UI_TYPE.ActorUITypeMonster1
		else  -- 有仇恨
			if CurHP >= MaxHP then  -- 满血
				return ACTOR_UI_TYPE.ActorUITypeMonster2
			else  -- 损血
				local TeamMgr = TeamHelper.GetTeamMgr()
				local IsFriendlyAttacker = false
				if (FirstAttackerEntityID > 0 and (MajorUtil.IsMajor(FirstAttackerEntityID) or TeamMgr:IsTeamMemberByEntityID(FirstAttackerEntityID))) or
				   (FirstAttackerRoleID > 0 and (MajorUtil.IsMajorByRoleID(FirstAttackerRoleID) or TeamMgr:IsTeamMemberByRoleID(FirstAttackerRoleID))) then  -- 首伤者为己方
					return ACTOR_UI_TYPE.ActorUITypeMonster3
				else  -- 首伤者非己方
					return ACTOR_UI_TYPE.ActorUITypeMonster4
				end
			end
		end

	elseif EActorType.Npc == ActorType then
		local ResID = ActorUtil.GetActorResID(EntityID)
		local NpcType = NpcCfg:FindValue(ResID, "Type")
		if NPC_TYPE.NPC == NpcType then
			return ACTOR_UI_TYPE.ActorUITypeNPC
		else
			return ACTOR_UI_TYPE.ActorUITypeOther
		end

	elseif EActorType.Companion == ActorType then
		return ACTOR_UI_TYPE.ActorUITypeCompanion

	elseif EActorType.Gather == ActorType then
		return ACTOR_UI_TYPE.ActorUITypeInteractObj

	elseif EActorType.EObj == ActorType then
		return ACTOR_UI_TYPE.ActorUITypeInteractObj

	else
		return ACTOR_UI_TYPE.ActorUITypeOther
	end
end

function ActorUIUtil.GetHUDCombatStateConfig(CombatStateID)
	local Cfg = CombatStatCfg:FindCfgByKey(CombatStateID)
	if nil == Cfg then
		return nil
	end

	local IsPositive = (Cfg.IsDisplayPositive == 1)
	return {
		Icon = Cfg.DisplayIcon,
		Text = Cfg.Name, 
		TextColor = "FFFFFFFF",
		TextOutlineColor = IsPositive and "946C00B3" or "773396B3",
		TextureBgColor = IsPositive and "F8BC00FF" or "892BB4FF",
		ProBarBgColor = IsPositive and "443721BF" or "262144BF",
		ProBarColor = IsPositive and "FFFFC3FF" or "D2A1FFFF",
	}
end

return ActorUIUtil