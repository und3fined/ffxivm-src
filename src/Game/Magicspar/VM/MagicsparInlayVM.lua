local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EquipmentMgr = _G.EquipmentMgr

local EquipmentCfg = require("TableCfg/EquipmentCfg")
local MagicsparRuleCfg = require("TableCfg/MagicsparRuleCfg")

local ItemCfg = require("TableCfg/ItemCfg")
local MagicsparInlayCfg = require("TableCfg/MagicsparInlayCfg")
local MagicsparInlayStatusItemVM = require("Game/Magicspar/VM/MagicsparInlayStatusItemVM")
local MagicsparInlayRecomItemVM = require("Game/Magicspar/VM/MagicsparInlayRecomItemVM")
local ProtoCommon = require("Protocol/ProtoCommon")
local FuncCfg = require("TableCfg/FuncCfg")

---@class MagicsparInlayVM : UIViewModel
local MagicsparInlayVM = LuaClass(UIViewModel)

function MagicsparInlayVM:Ctor()
    self.GID = nil
    self.Title = _G.LSTR(1060002)--"魔晶石一览"
    self.IconPath = nil
    self.EquipmentName = nil
    self.EquipmentLevel = nil
    self.EquipmentIconPath = nil
    self.CurSelect = nil
    self.bSelect = false
    self.bSelectNomal = false
    self.CurRatio = 0
    self.bMagicsparItemEmpty = false
    self.EquipmentInUse = false
    self.bListSelectUse = false --魔晶石列表是否选中已镶嵌的魔晶石

    self.lstMagicsparInlayStatusItemVM = nil
    self.lstMagicsparInlayRecomItemVM = nil
end

function MagicsparInlayVM:InitMagicsparByGID(InGID, Item)
    self.GID = InGID
    if Item == nil then
        Item = EquipmentMgr:GetItemByGID(InGID)
    end
    self.GemInfo = Item.Attr.Equip.GemInfo.CarryList
    self.EquipmentPart = Item.Attr.Equip.Part

    local EquipedItemInPart = EquipmentMgr:GetEquipedItemByPart(self.EquipmentPart)
    self.EquipmentInUse = EquipedItemInPart ~= nil and (EquipedItemInPart.GID == Item.GID) or false

    self.EquipmentCfg = EquipmentCfg:FindCfgByEquipID(Item.ResID)
    self.ItemCfg = ItemCfg:FindCfgByKey(Item.ResID)

    self.MagicsparInlayCfg = MagicsparInlayCfg:FindCfgByPart(Item.Attr.Equip.Part)
    self.EquipmentName = self.EquipmentCfg.Name
    self.EquipmentLevel = self.ItemCfg.ItemLevel
    self.NomalCount = self.MagicsparInlayCfg.NomalCount
    self.BanCount = self.MagicsparInlayCfg.BanCount

    self:InitInlayList()
end

--初始化已镶嵌信息列表
function MagicsparInlayVM:InitInlayList()
    local GemInfo = self.GemInfo
    local lst = {}
    for i = 1, self.NomalCount do
        lst[#lst + 1] = self:GenMagicsparInlayStatusItemVM(GemInfo[i], i, true)
    end
    for i = 1, self.BanCount do
        lst[#lst + 1] = self:GenMagicsparInlayStatusItemVM(GemInfo[i + self.NomalCount], i + self.NomalCount, false)
    end
    self.lstMagicsparInlayStatusItemVM = lst
end

function MagicsparInlayVM:GenMagicsparInlayStatusItemVM(InResID, Index, bNomal)
    local ViewModel = MagicsparInlayStatusItemVM.New()
    ViewModel:InitItem(InResID, Index, bNomal)
    return ViewModel
end

function MagicsparInlayVM:SelectSlot(Index)
    self.CurSelect = Index
    self.Title = _G.LSTR(1060001)--"魔晶石镶嵌"
	self.bSelect = true
    self.bSelectNomal = self.MagicsparInlayCfg.Hole[Index].Type == ProtoCommon.hole_type.HOLE_TYPE_NORMAL
    self.CurRatio = self.MagicsparInlayCfg.Hole[Index].Ratio/100
    self:GenItemList(Index)
end

function MagicsparInlayVM:UpSelectSlot()
    self.bSelect = false
    self.Title = _G.LSTR(1060002)--"魔晶石一览"
	self.CurSelect = nil
	self.bMagicsparItemEmpty = false
    self.bListSelectUse = false
end

-- 1.PVE战职装备可镶嵌的魔晶石类型：暴击，直击，信念，急速	　	　	　	　	　	　	　	　
-- 　	2.PVP战职装备-防具可镶嵌的魔晶石类型：暴击，直击，信念，急速，韧性	　	　	　	　	　	　	　
-- 　	3.PVP战职装备-武器\饰品可镶嵌的魔晶石类型：暴击，直击，信念，急速，穿刺	　	　	　	　	　	　
-- 　	4.采集职业装备可镶嵌的魔晶石类型：获得力，鉴别力，采集力	　	　	　	　	　	　	　	　
-- 　	5.制造职业装备可镶嵌的魔晶石类型：作业精度，加工精度，制造力
function MagicsparInlayVM:FilterMagicspar(ResID, RuleCfg, EquipProperty)
    if EquipProperty == ProtoCommon.equip_property.EQUIP_PROPERTY_BATTLE then
        return true
    end

    if RuleCfg == nil then 
        return false 
    end

    if RuleCfg.ClassLimit > 0 and RuleCfg.ClassLimit ~= self.ItemCfg.ClassLimit then
        return false
    end
    
    local ItemCfg = ItemCfg:FindCfgByKey(ResID)
    if ItemCfg == nil then 
        return false 
    end

    local GemAttr = EquipmentMgr:GetMagicsparsAttrKey(ResID)
    if GemAttr == nil or tonumber(GemAttr) == 0 then 
        return false
    end

    local lstAttr = RuleCfg.Attr
    for i = 1, #lstAttr do
        if tonumber(lstAttr[i]) == tonumber(GemAttr) then
            return true
        end
    end
    return false
end

-- 优先级	排序方式	　	　	　	　	　	　	　	　	　	　
-- 　	　	1	是否可用，可用的在前	　	　	　	　	　	　	　	　
-- 　	　	2	魔晶石等级，按照高等级→低等级排列	　	　	　	　	　	　	　
-- 　	　	3	魔晶石类型，战职PVE装备按照：暴击>直击>急速>信念的顺序排列	　	　	　	　
-- 　	　	3	魔晶石类型，战职PVP装备按照：韧性=穿刺>暴击>直击>急速>信念的顺序排列	　	　	　
-- 　	　	3	魔晶石类型，采集装备按照：获得力>鉴别力>采集力的顺序排列	　	　	　	　
-- 　	　	3	魔晶石类型，制造装备按照：作业精度>加工精度>制造力的顺序排列
-- 韧性=穿刺>暴击>直击>急速>信念>获得力>鉴别力>采集力上限>作业精度>加工精度>制造力上限
local MagicsparAttrWeight = 
{
    [ProtoCommon.attr_type.attr_ductility] = 1000,
    [ProtoCommon.attr_type.attr_puncture] = 1000,
    [ProtoCommon.attr_type.attr_critical] = 999,
    [ProtoCommon.attr_type.attr_direct_atk] = 998,
    [ProtoCommon.attr_type.attr_quick] = 997,
    [ProtoCommon.attr_type.attr_belief] = 996,
    [ProtoCommon.attr_type.attr_gathering] = 995,
    [ProtoCommon.attr_type.attr_perception] = 994,
    [ProtoCommon.attr_type.attr_gp_max] = 993,
    [ProtoCommon.attr_type.attr_work_precision] = 992,
    [ProtoCommon.attr_type.attr_produce_precision] = 991,
    [ProtoCommon.attr_type.attr_mk_max] = 990,
}
local function MagicsparSort(Left, Right)
    local LeftCfg = ItemCfg:FindCfgByKey(Left.ResID)
    local RightCfg = ItemCfg:FindCfgByKey(Right.ResID)

    --魔晶石等级
    if LeftCfg.ItemLevel ~= RightCfg.ItemLevel then
        return LeftCfg.ItemLevel > RightCfg.ItemLevel
    end

    local LeftCfgFunc = FuncCfg:FindCfgByKey(LeftCfg.UseFunc) -- 物品功能
    local RightCfgFunc = FuncCfg:FindCfgByKey(RightCfg.UseFunc) -- 物品功能
    ---属性权重
    local LeftAttrWeight = MagicsparAttrWeight[EquipmentMgr:GetMagicsparsAttrKey(Left.ResID)]
    local RightAttrWeight = MagicsparAttrWeight[EquipmentMgr:GetMagicsparsAttrKey(Right.ResID)]
    if LeftAttrWeight ~= nil and RightAttrWeight ~= nil and RightAttrWeight ~= LeftAttrWeight then
        return LeftAttrWeight > RightAttrWeight
    end

    return Left.ResID < Right.ResID
end

function MagicsparInlayVM:GenItemList(Index)
    local lst = {}

    local ResID = self.GemInfo[Index]   --已装备的魔晶石id
    local lstItem = EquipmentMgr:GetMagicsparsFromBag(self.bSelectNomal)
    local RuleCfg = MagicsparRuleCfg:FindRuleCfg(self.EquipmentCfg.EquipProperty, self.EquipmentCfg.ItemMainType)

    for i = 1, #lstItem do
        local Item = lstItem[i]
        if (ResID == nil or ResID == 0 or ResID ~= Item.ResID) and self:FilterMagicspar(Item.ResID, RuleCfg, self.EquipmentCfg.EquipProperty) then
            local ViewModel = MagicsparInlayRecomItemVM.New()
            ViewModel:InitItem(Item.ResID)
            lst[#lst + 1] = ViewModel
        end
    end

    ---排序
	table.sort(lst, MagicsparSort)

    --计算第一个的推荐
    if #lst > 0 then   
        lst[1]:CalculateRecommend()
    end

    if ResID ~= nil and ResID > 0 then
        --如果已镶嵌，第一个用已镶嵌的
        local ViewModel = MagicsparInlayRecomItemVM.New()
        ViewModel:InitItem(ResID)
        ViewModel.bInlayed = true
        ViewModel.bUse = true
        table.insert(lst, 1, ViewModel)
    end

    self.bMagicsparItemEmpty = #lst == 0
    self.lstMagicsparInlayRecomItemVM = lst
end

return MagicsparInlayVM