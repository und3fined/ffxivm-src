local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local BagMgr = require("Game/Bag/BagMgr")
local AttrDefCfg = require("TableCfg/AttrDefCfg")
local AttrParamCfg = require("TableCfg/AttrParamCfg")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local FuncCfg = require("TableCfg/FuncCfg")
local EquipmentMgr = _G.EquipmentMgr

---@class MagicsparInlayRecomItemVM : UIViewModel
local MagicsparInlayRecomItemVM = LuaClass(UIViewModel)

function MagicsparInlayRecomItemVM:Ctor()
    self.ResID = nil
    self.bInlayed = false
    self.bRecommend = false
    self.bSelect = false
    self.bUse = false

    self.IconPath = nil
    self.Name = nil
    self.Desc = nil
    self.iCount = 0
end

function MagicsparInlayRecomItemVM:InitItem(InResID)
    self.ResID = InResID
    self.ItemCfg = ItemCfg:FindCfgByKey(self.ResID)
    if self.ItemCfg == nil then
        return
    end
    
    self.IconPath = ItemCfg.GetIconPath(self.ItemCfg.IconID)
    self.Name = ItemCfg:GetItemName(self.ResID)
    self.Desc = ItemCfg:GetItemEffectDesc(self.ResID)
    self.iCount = BagMgr:GetItemNum(InResID)
end

function MagicsparInlayRecomItemVM:CalculateRecommend()
    local bRecommend = true

    local AttrKey = EquipmentMgr:GetMagicsparsAttrKey(self.ResID)

    if AttrKey == ProtoCommon.attr_type.attr_critical or
        AttrKey == ProtoCommon.attr_type.attr_direct_atk or
        AttrKey == ProtoCommon.attr_type.attr_belief or
        AttrKey == ProtoCommon.attr_type.attr_quick then
        ---暴击 直击 信念 急速
        local AttributeComponent = MajorUtil.GetMajorAttributeComponent()
        local AttrValue = AttributeComponent:GetAttrValue(AttrKey)
        local c_attr_param_cfg = AttrParamCfg:FindCfgByID(AttributeComponent.Level)
        
        local _, Raito, MaxRaito = EquipmentMgr:CalculateAttrProfit(AttrKey, AttrValue, c_attr_param_cfg)
        if Raito ~= nil and MaxRaito ~= nil and Raito > MaxRaito then
            bRecommend = false
        end
    end

    self.bRecommend = bRecommend
end

return MagicsparInlayRecomItemVM