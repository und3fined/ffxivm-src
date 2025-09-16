---
--- Author: Michaelyang_lightpaw
--- DateTime: 2025-03-03 19:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class OpsCeremonyFateItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm152Slot CommBackpack152SlotView
---@field TextCompleteness UFTextBlock
---@field TextGet UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCeremonyFateItemView = LuaClass(UIView, true)

function OpsCeremonyFateItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.Comm152Slot = nil
    --self.TextCompleteness = nil
    --self.TextGet = nil
    --self.TextTitle = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsCeremonyFateItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.Comm152Slot)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCeremonyFateItemView:OnInit()
end

function OpsCeremonyFateItemView:OnDestroy()
end

function OpsCeremonyFateItemView:OnShow()
	--UIUtil.SetIsVisible(self.Comm152Slot.TextName, false)
    self.TextGet:SetText(LSTR(190131))
    UIUtil.SetIsVisible(self.Comm152Slot.RedDot2, false)
    self.Comm152Slot:SetLevelVisible(false)
    self.Comm152Slot:SetNumVisible(true)
    self.Comm152Slot:SetIconChooseVisible(false)
    self.Comm152Slot:SetClickButtonCallback(self, self.OnItemClickCallback)

    local Data = self.Params.Data
    self.ItemResID = Data.ItemResID
    self:SetInfo(Data.TitleText, Data.Num, Data.InfoText, Data.ItemResID)
end

function OpsCeremonyFateItemView:OnItemClickCallback(InItemView)
    ItemTipsUtil.ShowTipsByResID(self.ItemResID, self.Comm152Slot)
end

function OpsCeremonyFateItemView:OnHide()
end

function OpsCeremonyFateItemView:OnRegisterUIEvent()
end

function OpsCeremonyFateItemView:OnRegisterGameEvent()
end

function OpsCeremonyFateItemView:OnRegisterBinder()
end

function OpsCeremonyFateItemView:SetInfo(InTitleStr, InCoinCount, InContentStr, InItemResID)
    self.TextTitle:SetText(InTitleStr)
    self.TextCompleteness:SetText(InContentStr)
    self.Comm152Slot:SetNum(InCoinCount)

    local ItemIcon = ItemUtil.GetItemIcon(InItemResID or 0)
    if (ItemIcon ~= nil and ItemIcon > 0) then
        local IconPath = UIUtil.GetIconPath(ItemIcon)
        UIUtil.ImageSetBrushFromAssetPath(self.Comm152Slot.Icon, IconPath)
    end
    
end

return OpsCeremonyFateItemView
