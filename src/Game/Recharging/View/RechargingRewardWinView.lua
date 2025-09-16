---
--- Author: zimuyi
--- DateTime: 2023-03-23 19:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")

local RechargingMgr = require("Game/Recharging/RechargingMgr")
local RechargingRewardVM = require("Game/Recharging/VM/RechargingRewardVM")
local RechargingRewardItemVM = require("Game/Recharging/VM/RechargingRewardItemVM")

---@class RechargingRewardWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EquipSlot EquipmentSlotItemView
---@field ItemSlot CommBackpackSlotView
---@field PopUpBG CommonPopUpBGView
---@field TextNum UFTextBlock
---@field TextReward UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RechargingRewardWinView = LuaClass(UIView, true)

function RechargingRewardWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EquipSlot = nil
	--self.ItemSlot = nil
	--self.PopUpBG = nil
	--self.TextNum = nil
	--self.TextReward = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RechargingRewardWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.EquipSlot)
	self:AddSubView(self.ItemSlot)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RechargingRewardWinView:OnInit()
end

function RechargingRewardWinView:OnDestroy()

end

function RechargingRewardWinView:OnShow()
	self.ItemSlot:SetParams({ Data = RechargingRewardVM.ItemVM })
end

function RechargingRewardWinView:OnHide()
	RechargingMgr:OnRewardWinHide()
end

function RechargingRewardWinView:OnRegisterUIEvent()

end

function RechargingRewardWinView:OnRegisterGameEvent()

end

function RechargingRewardWinView:OnRegisterBinder()
	local Binders = {
		{ "Title", UIBinderSetText.New(self, self.TextTitle) },
		{ "RewardTypeStr", UIBinderSetTextFormat.New(self, self.TextReward, "%s") },
		{ "IsQuantity", UIBinderSetIsVisible.New(self, self.TextNum) },
		{ "Quantity", UIBinderSetTextFormat.New(self, self.TextNum, "X%d") },
	}

	self:RegisterBinders(RechargingRewardVM, Binders)
end

return RechargingRewardWinView