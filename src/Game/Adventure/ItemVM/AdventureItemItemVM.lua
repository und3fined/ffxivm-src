---
--- Author: sammrli
--- DateTime: 2023-05-12 15:46
--- Description:冒险系统Item的Item ViewMode
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ItemUtil = require("Utils/ItemUtil")

---@see AdventureItemsItemView

---@class AdventureItemItemVM : UIViewModel
---@field DateText string
---@field NumText stirng
---@field IconPath stirng
---@field IsVisible boolean
---@field IsMaskVisible boolean
---@field ResID number
local AdventureItemItemVM = LuaClass(UIViewModel)

function AdventureItemItemVM:Ctor()
    self.DateText = ""
    self.PanelJobVisible = false
    self.IconJob = ""
    self.NumText = ""
    self.IconPath = nil
    self.IsMaskVisible = false
    self.TextLevelVisible = false
    self.ResID = 0
    self.QualityPath = ""
    self.IsShowProgressPoint = false
    self.ShowItemReward = false
end

function AdventureItemItemVM:UpdateVM(Params)
    self.QualityPath = ""
    self.NumText = ""

    if Params.ResID then
        self.ResID = Params.ResID
        self.QualityPath = ItemUtil.GetItemColorIcon(Params.ResID)
    end

    if Params.Num then
        local ItemCfg = require("TableCfg/ItemCfg")
        local cfg = ItemCfg:FindCfgByKey(self.ResID)
        if cfg and cfg.MaxPile and cfg.MaxPile > 1 then
            self.NumText = Params.NumText or ""
        else
            self.NumText = ""
        end
    else
        self.NumText = Params.NumText or ""
    end

    self.IsMaskVisible = Params.IsMaskVisible or false
    self.DateText = Params.DateText or ""
    self.IconPath = Params.IconPath or ""
    self.PanelJobVisible = Params.IsJobVisible or false
    self.IconJob = Params.JobIconPath or ""
    self.IsShowProgressPoint = Params.IsShowProgressPoint
    self.ShowItemReward = not Params.IsShowProgressPoint
end

function AdventureItemItemVM:IsEqualVM(Value)
	return self.ResID == Value.ResID
end

return AdventureItemItemVM


