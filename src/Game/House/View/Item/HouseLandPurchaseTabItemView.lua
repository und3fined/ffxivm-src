---
--- Author: muyanli
--- DateTime: 2025-05-30 20:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")

---@class HouseLandPurchaseTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RedDot1 CommonRedDotView
---@field RedDot2 CommonRedDotView
---@field TextTab1 UFTextBlock
---@field TextTab2 UFTextBlock
---@field ToggleBtnTab1 UToggleButton
---@field ToggleBtnTab2 UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseLandPurchaseTabItemView = LuaClass(UIView, true)

function HouseLandPurchaseTabItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RedDot1 = nil
	--self.RedDot2 = nil
	--self.TextTab1 = nil
	--self.TextTab2 = nil
	--self.ToggleBtnTab1 = nil
	--self.ToggleBtnTab2 = nil
	--self.AnimIn = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseLandPurchaseTabItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot1)
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseLandPurchaseTabItemView:OnInit()
    for i, v in ipairs(HouseLocalDef.HouseTabData) do
        self["TextTab" .. i]:SetText(v.Name)
        self["RedDot" .. i]:SetRedDotIDByID(v.RedDot)
    end
end

function HouseLandPurchaseTabItemView:OnDestroy()

end

function HouseLandPurchaseTabItemView:OnShow()

end

function HouseLandPurchaseTabItemView:OnHide()

end

function HouseLandPurchaseTabItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.ToggleBtnTab1, self.OnToggleBtnMyHouseClicked)
    UIUtil.AddOnClickedEvent(self, self.ToggleBtnTab2, self.OnToggleBtnLandPurchaseClicked)
end

function HouseLandPurchaseTabItemView:OnRegisterGameEvent()

end

function HouseLandPurchaseTabItemView:OnRegisterBinder()

end

function HouseLandPurchaseTabItemView:SelectTabItem(Index)
    self:SetSelectedIndex(Index)
    _G.EventMgr:SendEvent(_G.EventID.HouseLandBuyTabSwitch, Index)
    self:PlayAnimation(self.AnimSelect)
end

function HouseLandPurchaseTabItemView:SetDefaultSelected(JumpTab)
    -- self.AdpTableSelection:SetSelectedIndex(JumpTab)
    -- if JumpTab ~= 1 then
    --     SelectTabItem(JumpTab)
    -- end
end

function HouseLandPurchaseTabItemView:OnToggleBtnMyHouseClicked()
    self:SelectTabItem(1)
end

function HouseLandPurchaseTabItemView:OnToggleBtnLandPurchaseClicked()
    self:SelectTabItem(2)
end

function HouseLandPurchaseTabItemView:SetSelectedIndex(Index)
    self.ToggleBtnTab1:SetIsChecked(Index == 1)
    self.ToggleBtnTab2:SetIsChecked(Index == 2)
end

return HouseLandPurchaseTabItemView
