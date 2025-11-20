---
--- Author: muyanli
--- DateTime: 2025-06-21 14:17
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemUtil = require("Utils/ItemUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")


---@class HouseStyleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm96Slot CommBackpack96SlotView
---@field ImgSelect UFImage
---@field TextSlot UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseStyleItemView = LuaClass(UIView, true)

function HouseStyleItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.Comm96Slot = nil
    -- self.ImgSelect = nil
    -- self.TextSlot = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseStyleItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.Comm96Slot)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseStyleItemView:OnInit()
    UIUtil.SetIsVisible(self.Comm96Slot.IconChoose, false)
    UIUtil.SetIsVisible(self.Comm96Slot.IconReceived, false)
    UIUtil.SetIsVisible(self.Comm96Slot.RichTextQuantity, true)
	UIUtil.SetIsVisible(self.Comm96Slot.RichTextLevel, false)
end

function HouseStyleItemView:OnDestroy()

end

function HouseStyleItemView:OnShow()
    if nil == self.Params then
        return
    end
    UIUtil.SetIsVisible(self.ImgSelect, self.ParentView and self.ParentView.ParentView and self.ParentView.ParentView.ViewModel.CurSelectIndex == self.Params.Index)
end


function HouseStyleItemView:OnHide()

end

function HouseStyleItemView:OnRegisterUIEvent()

end

function HouseStyleItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.BuildHouseResSelected, self.OnSelcetChange)
end

function HouseStyleItemView:OnRegisterBinder()
    if nil == self.Params or nil == self.Params.Data then
        return
    end
    self.ViewModel = self.Params.Data
	local  ItemId =  tonumber(self.ViewModel.ItemIds)
    local Cfg = ItemCfg:FindCfgByKey(ItemId)
    if nil ~= Cfg then
        local Path = UIUtil.GetIconPath(Cfg.IconID)
        self.Comm96Slot:SetIconImg(Path)
        self.TextSlot:SetText(ItemUtil.GetItemName(ItemId))
		local ItemNum = _G.BagMgr:GetItemNum(ItemId)
        self.Comm96Slot.RichTextQuantity:SetText(ItemUtil.GetNumProgressFormat(ItemNum, HouseLocalDef.BuildHouseItemCostNum))
        self.Comm96Slot:SetClickButtonCallback(self, function()
            ItemTipsUtil.ShowTipsByResID(ItemId, self.Comm96Slot)
        end)
    end
end
function HouseStyleItemView:OnSelcetChange(Index)
	UIUtil.SetIsVisible(self.ImgSelect, self.Params and self.Params.Index == Index)
end

return HouseStyleItemView
