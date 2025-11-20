--
-- Author: ZhengJanChuan
-- Date: 2025-09-01 16:22
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local ItemCfg = require("TableCfg/ItemCfg")

---@class WardrobeSuitWinListVM : UIViewModel
local WardrobeSuitWinListVM = LuaClass(UIViewModel)

---Ctor
function WardrobeSuitWinListVM:Ctor()
    self.IsSelected = nil
    self.EquipID = nil
    self.EquipName = ""
    self.EquipNum = ""
    self.ItemVM = ItemVM.New()  
end

function WardrobeSuitWinListVM:OnInit()
end

function WardrobeSuitWinListVM:OnBegin()
end

function WardrobeSuitWinListVM:OnEnd()
end

function WardrobeSuitWinListVM:OnShutdown()
end

function WardrobeSuitWinListVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end

function WardrobeSuitWinListVM:UpdateVM(Value)
    self.EquipID = Value.EquipID
    local Cfg = ItemCfg:FindCfgByKey(self.EquipID)
    if Cfg ~= nil then
        self.EquipName = Cfg.ItemName
        self.EquipNum = string.format(_G.LSTR("背包数量：%d"), _G.BagMgr:GetItemNum(self.EquipID)) --背包数量：%d
    end
    local Item = ItemUtil.CreateItem(self.EquipID, 1)
    if Item ~= nil then
        self.ItemVM:UpdateVM(Item, {PanelBagVisible = true, IsShowNum = false, IsShowLeftCornerFlag = false})
    end
end

function WardrobeSuitWinListVM:IsEqualVM(Value)
    return self.EquipID ~= Value.EquipID
end


--要返回当前类
return WardrobeSuitWinListVM