local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local AttributeDetailDescItemVM = require("Game/Attribute/VM/AttributeDetailDescItemVM")
local AttributeMainPageVM = require("Game/Attribute/VM/AttributeMainPageVM")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local AttrSortShowCfg = require("TableCfg/AttrSortShowCfg")
local ProtoRes = require("Protocol/ProtoRes")
local EquipmentMgr = _G.EquipmentMgr
local AttrDefCfg = require("TableCfg/AttrDefCfg")
local AttrParamCfg = require("TableCfg/AttrParamCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")

local SpecialDescAttr = 
{
    [ProtoCommon.attr_type.attr_critical] = 1,
    [ProtoCommon.attr_type.attr_direct_atk] = 1,
    [ProtoCommon.attr_type.attr_belief] = 1,
    [ProtoCommon.attr_type.attr_quick] = 1,
    [ProtoCommon.attr_type.attr_ductility] = 1,
    [ProtoCommon.attr_type.attr_puncture] = 1,
    [ProtoCommon.attr_type.attr_physic_def] = 1,
    [ProtoCommon.attr_type.attr_magic_def] = 1,
}

---@class AttributeDetailPanelVM : UIViewModel
local AttributeDetailPanelVM = LuaClass(UIViewModel)

function AttributeDetailPanelVM:Ctor()
    self.EntityID = nil
    self.AttrIndexMap = nil
    self.lstAttributeDetailDescItemVM = nil
	self.TitleDescItemVMList = nil
end

function AttributeDetailPanelVM:GenDetailAttribute(EntityID)
    self.EntityID = EntityID
    local AttributeComponent = ActorUtil.GetActorAttributeComponent(self.EntityID)
    if AttributeComponent == nil then
        return
    end

    local ShowType = AttributeMainPageVM.GenClassShowType(AttributeComponent.ProfID)
    --根据属性排序显示表填充ListAttrKey
    local MainList = AttrSortShowCfg:GetAttrSortList(ShowType, nil, ProtoRes.AttrShowTag.BASE)
    local SubList = AttrSortShowCfg:GetAttrSortList(ShowType, nil, ProtoRes.AttrShowTag.SUB)

    self.AttrIndexMap = {}
	self.TitleDescItemVMList = {}
    local lstAttributeDetailDescItemVM = {}
    local Index = 1
    local RealAttrKey

    lstAttributeDetailDescItemVM[Index] = self:GenTitleItemVM(_G.LSTR(1050187))
    lstAttributeDetailDescItemVM[Index].Index = Index
	self.TitleDescItemVMList[Index] = lstAttributeDetailDescItemVM[Index]
    for _,v in ipairs(MainList) do
        Index = Index + 1
        lstAttributeDetailDescItemVM[Index], RealAttrKey = self:GenDescItemVM(AttributeComponent, v.AttrName)
        self.AttrIndexMap[RealAttrKey] = Index
    end
	lstAttributeDetailDescItemVM[Index].bIsLastItem = true

    Index = Index + 1
    lstAttributeDetailDescItemVM[Index] = self:GenTitleItemVM(_G.LSTR(1050188))
    lstAttributeDetailDescItemVM[Index].Index = Index
	self.TitleDescItemVMList[Index] = lstAttributeDetailDescItemVM[Index]
    for _,v in ipairs(SubList) do
        Index = Index + 1
        lstAttributeDetailDescItemVM[Index], RealAttrKey = self:GenDescItemVM(AttributeComponent, v.AttrName)
        self.AttrIndexMap[RealAttrKey] = Index
    end
	lstAttributeDetailDescItemVM[Index].bIsLastItem = true

    self.lstAttributeDetailDescItemVM = lstAttributeDetailDescItemVM
	self:UpdateLevelSyncState()
end

function AttributeDetailPanelVM:GenTitleItemVM(Title)
    local ViewModel = AttributeDetailDescItemVM.New()
    ViewModel.ItemType = 0
    ViewModel.bOpen = false
    ViewModel.LeftText = Title
    return ViewModel
end

function AttributeDetailPanelVM:GenDescItemVM(AttributeComponent, AttrKey)
    local bIsMainAttr = AttrKey == ProtoCommon.attr_type.attr_prof_main_attr
    local RealAttrKey = EquipmentMgr:GetAttributeRealType(AttrKey, AttributeComponent.ProfID)
    
    local AttrName = AttrDefCfg:GetAttrNameByID(RealAttrKey)

    local ViewModel = AttributeDetailDescItemVM.New()
    ViewModel.ItemType = 1
    ViewModel.bOpen = true
    ViewModel.LeftText = AttrName
    ViewModel.LeftSubText = bIsMainAttr and _G.LSTR(1050189) or ""
    ViewModel.RightText, ViewModel.RightSubText, ViewModel.RightSubTextColor = self:SetRightAttr(RealAttrKey, AttributeComponent)
    ViewModel.DescText = self:GenAttrDesc(AttributeComponent, RealAttrKey)
    return ViewModel, RealAttrKey
end
-- [ProtoCommon.attr_type.attr_critical] = 1,
--     [ProtoCommon.attr_type.attr_direct_atk] = 1,
--     [ProtoCommon.attr_type.attr_belief] = 1,
--     [ProtoCommon.attr_type.attr_quick] = 1,
--     [ProtoCommon.attr_type.attr_ductility] = 1,
--     [ProtoCommon.attr_type.attr_puncture] = 1,
--     [ProtoCommon.attr_type.attr_physic_def] = 1,
--     [ProtoCommon.attr_type.attr_magic_def] = 1,
function AttributeDetailPanelVM:GenAttrDesc(AttributeComponent, AttrKey)
    local Desc = AttrDefCfg:GetAttrDescByID(AttrKey)
    if SpecialDescAttr[AttrKey] ~= nil then
        local AttrValue = AttributeComponent:GetAttrValue(AttrKey)
        local c_attr_param_cfg = AttrParamCfg:FindCfgByID(AttributeComponent.Level)
        local Percent, Raito, MaxRaito = EquipmentMgr:CalculateAttrProfit(AttrKey, AttrValue, c_attr_param_cfg)

        if AttrKey == ProtoCommon.attr_type.attr_critical then
            ---暴击
            Desc = string.format(Desc, AttrValue, math.min(Raito, 0.2)*100, math.min(Percent + 1.4, 2.0))

        elseif AttrKey == ProtoCommon.attr_type.attr_direct_atk then
            ---直击			
            Desc = string.format(Desc, AttrValue, math.min(Raito, MaxRaito)*100)
		
        elseif AttrKey == ProtoCommon.attr_type.attr_belief then
            -- 信念
            Desc = string.format(Desc, AttrValue, math.min(Percent, MaxRaito)*100)

        elseif AttrKey == ProtoCommon.attr_type.attr_quick then
            -- 急速
            Desc = string.format(Desc, AttrValue, math.min(Percent, MaxRaito)*100)

        elseif AttrKey == ProtoCommon.attr_type.attr_ductility then
            -- 韧性
            Desc = string.format(Desc, AttrValue, Percent*100)

        elseif AttrKey == ProtoCommon.attr_type.attr_puncture then
            -- 穿刺
            Desc = string.format(Desc, AttrValue, Percent*100)

        elseif AttrKey == ProtoCommon.attr_type.attr_physic_def or AttrKey == ProtoCommon.attr_type.attr_magic_def then
            -- 防御				
            Desc = string.format(Desc, AttrValue, Percent*100)

        end
    end
    return Desc
end

function AttributeDetailPanelVM:SetOpen(Index, bOpen)
    if self.lstAttributeDetailDescItemVM == nil then return end
    for i = Index, #self.lstAttributeDetailDescItemVM do
        local AttributeDetailDescItemVM = self.lstAttributeDetailDescItemVM[i]
        if AttributeDetailDescItemVM.Index ~= nil and AttributeDetailDescItemVM.Index ~= Index then
            break
        end
        AttributeDetailDescItemVM.bOpen = bOpen
    end

    local Temp = self.lstAttributeDetailDescItemVM
    self.lstAttributeDetailDescItemVM = nil
    self.lstAttributeDetailDescItemVM = Temp
end

function AttributeDetailPanelVM:UpdateAllAttr()
    if self.AttrIndexMap == nil then return end
    for AttrKey in pairs(self.AttrIndexMap) do
        self:UpdateAttr(AttrKey)
    end
end

function AttributeDetailPanelVM:UpdateAttr(AttrKey)
    if self.AttrIndexMap == nil then return end
    local Index = self.AttrIndexMap[AttrKey]
    if Index ~= nil and self.lstAttributeDetailDescItemVM ~= nil and self.lstAttributeDetailDescItemVM[Index] ~= nil then
        local AttributeComponent = ActorUtil.GetActorAttributeComponent(self.EntityID)
        if AttributeComponent == nil then
            return
        end

        local ViewModel = self.lstAttributeDetailDescItemVM[Index]
        ViewModel.RightText, ViewModel.RightSubText, ViewModel.RightSubTextColor = self:SetRightAttr(AttrKey, AttributeComponent)
    end
end

function AttributeDetailPanelVM:SetRightAttr(AttrKey, AttributeComponent)
    local AttrValue = AttributeComponent:GetAttrValue(AttrKey)
    local AddValue = 0
    if EquipmentVM ~= nil and EquipmentVM.UnSteadyMap ~= nil and EquipmentVM.UnSteadyMap[AttrKey] ~= nil then
        AddValue = EquipmentVM.UnSteadyMap[AttrKey]
    end
    local Ret
    -- local Ret, Ret1
    local NumShowType = AttrDefCfg:GetAttrNumShowTypeByID(AttrKey)
    if NumShowType == ProtoRes.AttrNumShowType.PERCENTAGE then
        Ret = string.format("%d%%", math.floor(AttrValue/100))
        -- Ret1 = string.format("%d%%", math.floor(AddValue/100))
    else
        Ret = tostring(AttrValue)
        -- Ret1 = tostring(AddValue)
    end
	-- Ret1 = AddValue < 0 and Ret1 or "+"..Ret1

	-- local SubText = AddValue == 0 and "" or Ret1
	local SubText = "" -- 当前不需要显示属性变动数值
    --绿色00FD2BFF --红色F80003FF
	local SubTextColor = AddValue > 0 and "00FD2BFF" or "F80003FF"
    return Ret, SubText, SubTextColor
end

function AttributeDetailPanelVM:UpdateLevelSyncState()
	for _, DescItemVM in pairs(self.TitleDescItemVMList) do
		DescItemVM.bInLevelSync = MajorUtil.IsInLevelSync()
	end
end

return AttributeDetailPanelVM