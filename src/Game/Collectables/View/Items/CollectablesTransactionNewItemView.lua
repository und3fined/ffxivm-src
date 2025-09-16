---
--- Author: Administrator
--- DateTime: 2024-09-30 15:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class CollectablesTransactionNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgExp UFImage
---@field ImgTicket UFImage
---@field TextExpNum UFTextBlock
---@field TextTicketNum UFTextBlock
---@field TextValueNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CollectablesTransactionNewItemView = LuaClass(UIView, true)

function CollectablesTransactionNewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgExp = nil
	--self.ImgTicket = nil
	--self.TextExpNum = nil
	--self.TextTicketNum = nil
	--self.TextValueNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CollectablesTransactionNewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CollectablesTransactionNewItemView:OnInit()
	self.Binders = {
		{ "TicketReward", UIBinderSetTextFormatForMoney.New(self, self.TextTicketNum) },
		{ "ExperienceReward", UIBinderSetTextFormatForMoney.New(self, self.TextExpNum) },
		{ "CollectValue", UIBinderSetText.New(self, self.TextValueNum) },
		{ "TicketIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgTicket) },
	}
end

function CollectablesTransactionNewItemView:OnDestroy()

end

function CollectablesTransactionNewItemView:OnShow()

end

function CollectablesTransactionNewItemView:OnHide()

end

function CollectablesTransactionNewItemView:OnRegisterUIEvent()

end

function CollectablesTransactionNewItemView:OnRegisterGameEvent()

end

function CollectablesTransactionNewItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return CollectablesTransactionNewItemView