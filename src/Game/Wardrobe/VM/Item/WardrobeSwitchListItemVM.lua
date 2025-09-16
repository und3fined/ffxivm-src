--
-- Author: ZhengJanChuan
-- Date: 2024-02-28 16:38
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")

---@class WardrobeSwitchListItemVM : UIViewModel
local WardrobeSwitchListItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeSwitchListItemVM:Ctor()
    self.Name = ""
    self.IsRecommend = false
    self.BagSlotVM = BagSlotVM.New()
    self.ID = 0
    self.GID = 0
    self.IsSelected = nil
end

function WardrobeSwitchListItemVM:OnInit()
end

function WardrobeSwitchListItemVM:OnBegin()
end

function WardrobeSwitchListItemVM:OnEnd()
end

function WardrobeSwitchListItemVM:OnShutdown()
end

function WardrobeSwitchListItemVM:UpdateVM(Value)
    self.Name = Value.Name
    self.IsRecommend = Value.IsRecommend
    self.ID = Value.ID
    self.GID = Value.GID
    local Item = ItemUtil.CreateItem(Value.Item, 0)
    self.BagSlotVM:UpdateVM(Item, {PanelBagVisible = true})
    self.BagSlotVM.IsMask = false
    self.BagSlotVM.LeftCornerFlagImgVisible = false
end

function WardrobeSwitchListItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end

--要返回当前类
return WardrobeSwitchListItemVM