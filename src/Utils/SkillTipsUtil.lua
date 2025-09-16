local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local UIUtil = require("Utils/UIUtil")
local SkillTagCfg = require("TableCfg/SkillTagCfg")
local AttrDefCfg = require("TableCfg/AttrDefCfg")
local SkillCdGroupCfg = require("TableCfg/SkillCdGroupCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local AttrType = require("Protocol/ProtoCommon").attr_type

local LSTR <const> = _G.LSTR
local FLOG_ERROR <const> = _G.FLOG_ERROR
local ESkillTagType <const> = ProtoRes.ESkillTagType
local table_find_item <const> = table.find_item
local table_insert <const> = table.insert
local skill_cost_type <const> = ProtoRes.skill_cost_type
local SkillTipsType <const> = SkillCommonDefine.SkillTipsType
local LocalStrID <const> = require("Game/Skill/SkillSystem/SkillSystemConfig").LocalStrID
local FVector2D <const> = UE.FVector2D

local LocalStrID_CD   <const> = 150071           -- 冷却
local LocalStrID_Cost <const> = 150072           -- 消耗
local LocalStrID_None <const> = LocalStrID.None  -- 无

local ECDType = {
	Sec  = 1,  -- 秒
	Step = 2   -- 工次
}



---@class SkillTipsUtil
local SkillTipsUtil = {
}



local function InsertUnique(List, Element)
	if not Element then
		return
	end

	if table_find_item(List, Element) == nil then
		table_insert(List, Element)
	end
end

--- 获取技能Tag列表
---@param Params table 参数列表, 因为需要的参数比较多, 整合进了一个table:
---@param Params.ProfFlags.bMakeProf boolean
---@param Params.ProfFlags.bProductionProf boolean
---@param Params.ProfFlags.bFisherProf boolean
---@param Params.CurrentLabel SkillSystemConfig.LocalStrID Label类型
---@param Params.ActionType number 生产职业的LifeskillActionType, 非生产职业不需要
---@param Params.bPassiveSkill boolean
---@param Params.bLimitSkill boolean 是否极限技
---@param Params.Class ProtoRes.skill_class
---@param Params.Tag ProtoRes.skill_tag
function SkillTipsUtil.GetSkillTagList(Params)
    local ProfFlags = Params.ProfFlags
	local Tags = {}
	if ProfFlags.bMakeProf or ProfFlags.bProductionProf or ProfFlags.bFisherProf then
		InsertUnique(Tags, SkillTagCfg.GetTagTypeByLabel(Params.CurrentLabel))

		local ActionType = Params.ActionType
		if ActionType and ActionType > 0 and ActionType < ProtoRes.LIFESKILL_ACTION_TYPE.LIFESKILL_ACTION_TYPE_CATALYST then
			InsertUnique(Tags, SkillTagCfg.GetTagTypeByLifeskillActionType(ActionType))
		end
	else
		-- # TODO - 极限技合入之后, 和生产职业的主被动判定方式统一
		if Params.bPassiveSkill then
			InsertUnique(Tags, ESkillTagType.SKILL_TAG_PASSIVE)
		else
			InsertUnique(Tags, ESkillTagType.SKILL_TAG_ACTIVE)
		end

		if Params.bLimitSkill then
			InsertUnique(Tags, ESkillTagType.SKILL_TAG_LIMIT)
		end

		if not Params.Class or not Params.Tag then
			FLOG_ERROR("Cannot find class or tag of skill %d!", Params.SkillID or 0)
			return
		end

		local Class = Params.Class
		local ESkillClassType = ProtoRes.skill_class
		for _, EnumValue in pairs(ESkillClassType) do
			if EnumValue > 0 and (Class & EnumValue) > 0 then
				InsertUnique(Tags, SkillTagCfg.GetTagTypeBySkillClass(EnumValue))
			end
		end

		local Tag = Params.Tag
		local ESkillTagType = ProtoRes.skill_tag
		for _, EnumValue in pairs(ESkillTagType) do
			if EnumValue > 0 and (Tag & (1 << EnumValue)) > 0 then
				InsertUnique(Tags, SkillTagCfg.GetTagTypeBySkillTag(EnumValue))
			end
		end
	end

	for Key, Value in pairs(Tags) do
		Tags[Key] = { Value }
	end

	return Tags
end

local function GetSkillCDDesc(Cfg, CDType)
	if CDType == ECDType.Step then
		return {
            Title = LSTR(LocalStrID_CD),                 -- 冷却
            Text = string.format(LSTR(150069), Cfg.CD),  -- %d工次
        }
	end

	local NormalCD = Cfg.CD
    local CD = 0
	local LSTR_None = LSTR(LocalStrID_None)

    if NormalCD > 0 then
        CD = NormalCD
    elseif Cfg.CDGroup > 0 then
        local GroupCDCfg = SkillCdGroupCfg:FindCfgByKey(Cfg.CDGroup)
        if GroupCDCfg then
            CD = GroupCDCfg.Time
        end
    end

	local TextCD
    if CD > 0 then
        TextCD = string.format(LSTR(170058), CD / 1000)  -- %.0f秒
    else
        TextCD = LSTR_None
    end

	return {
		Title = LSTR(LocalStrID_CD),
		Text = TextCD,
	}
end


local AttrAliasMap = {
    -- 主要作用是把"当前"两个字去掉
    [AttrType.attr_gp] = AttrType.attr_gp_max,  -- 当前采集力 -> 采集力
    [AttrType.attr_mk] = AttrType.attr_mk_max,  -- 当前制作力 -> 制作力
}

local function GetSkillAttrList_Crafter(Cfg, CDType)
    local CostUnit, AttrName
    local CostList = { GetSkillCDDesc(Cfg, CDType) }
    for index = 1, #Cfg.CostList do
        CostUnit = Cfg.CostList[index]
        local Cost = CostUnit.AssetCost
        if not Cost then
            FLOG_ERROR("AssetCost Attr is nil")
            Cost = 0
        end
        if CostUnit.AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_ATTR then  -- 属性
            local AssetId = CostUnit.AssetId
            AssetId = AttrAliasMap[AssetId] or AssetId
            AttrName = AttrDefCfg:GetAttrNameByID(AssetId)
            table.insert(CostList, {
				Title = LSTR(LocalStrID_Cost),
				Text = string.format("%d%s", Cost, AttrName)
			})  -- 消耗
        elseif CostUnit.AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_DURABILITY then  --耐久
            table.insert(CostList, {
				Title = LSTR(LocalStrID_Cost),
				Text = string.format(LSTR(150073), Cost)
			})  -- 消耗, %d耐久
        end
    end

    return CostList
end


local function GetMPCost(CostList)
	if not CostList then
		-- 固定值1, 0
		return 1, 0
	end
    for _, value in pairs(CostList) do
		if value.AssetType == skill_cost_type.SKILL_COST_TYPE_ATTR then
			local AssetID = value.AssetId
			local ValueType = value.ValueType
			local AdditionAssetID = value.AdditionAssetId
			if AdditionAssetID == 0 then
				AdditionAssetID = AssetID
			end
			if AdditionAssetID == ProtoCommon.attr_type.attr_mp then
				return ValueType, value.AssetCost
			end
		elseif value.AssetType == skill_cost_type.SKILL_COST_TYPE_LIMIT_BREAK then
			return ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_NULL, value.Min, true
		end
	end
    return 1, 0
end

local function GetSkillAttrList_Combat(Cfg)
	local LSTR_None = LSTR(LocalStrID_None)
	local TextCost
    local CostType, Value, bIsLimit = GetMPCost(Cfg.CostList)
    if CostType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_FIX then
        if Value == 0 then
            TextCost = LSTR_None
        else
            TextCost = string.format("%d", Value)
        end
    elseif CostType == ProtoRes.skill_cost_value_type.SKILL_COST_VALUE_TYPE_RATE then
        TextCost = string.format("%.0f%%", Value / 100)
    elseif bIsLimit then
        TextCost = string.format(LSTR(170062), math.floor(Value / 10000))  -- 极限槽%d段
    else
        TextCost = LSTR_None
    end

	local RangeStr = string.gsub(Cfg.RangeDesc or "", "%D", "")
	local Range = tonumber(RangeStr) or 0

	local CostList = {}
	if not bIsLimit then
		table.insert(CostList, GetSkillCDDesc(Cfg, ECDType.Sec))
	end
	table.insert(CostList, {
		Title = LSTR(LocalStrID_Cost),
		Text = TextCost,
	})
	table.insert(CostList, {
		Title = LSTR(170053),  -- 射程
		Text = string.format(LSTR(170060), Range)  -- %d米
	})

	return CostList
end

--- 获取技能属性列表(用于展示在技能Tips中)
---@param Cfg table - 技能主表
---@param Type number - Tips的类型, 定义在SkillCommonDefine.SkillTipsType
---@return table - 属性描述组成的数组, 属性描述的格式为 { Title = "", Text = "" } 
function SkillTipsUtil.GetSkillAttrList(Cfg, Type)
	if Type == SkillTipsType.Crafter then
		return GetSkillAttrList_Crafter(Cfg, ECDType.Step)
	elseif Type == SkillTipsType.Gather then
		return GetSkillAttrList_Crafter(Cfg, ECDType.Sec)
	elseif Type == SkillTipsType.Combat then
		return GetSkillAttrList_Combat(Cfg)
	end
end

local EAnchorType = {
	TopLeft = 1,
	TopRight = 2,
	BottomLeft = 3,
	BottomRight = 4,
}
SkillTipsUtil.EAnchorType = EAnchorType

--- 获取控件某个锚点的位置
---@param Widget UWidget - 控件
---@param AnchorType number - 锚点类型, 对应枚举EAnchorType
---@return FVector2D - 锚点的位置
function SkillTipsUtil.GetWidgetAnchorPos(Widget, AnchorType)
	if not Widget or not AnchorType then
		return
	end

	local Scale = UIUtil.GetViewportScale()
	local WidgetSize = UIUtil.GetWidgetSize(Widget)
	local AbsoPos = UIUtil.GetWidgetAbsolutePosition(Widget)
	local AnchorPos = UIUtil.AbsoluteToViewport(AbsoPos) / Scale

	if AnchorType == EAnchorType.TopRight or AnchorType == EAnchorType.BottomRight then
		AnchorPos.X = AnchorPos.X + WidgetSize.X
	end
	if AnchorType == EAnchorType.BottomLeft or AnchorType == EAnchorType.BottomRight then
		AnchorPos.Y = AnchorPos.Y + WidgetSize.Y
	end

	return AnchorPos
end

return SkillTipsUtil