---
--- Author: Administrator
--- DateTime: 2025-03-04 15:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetText = require("Binder/UIBinderSetText")


---@class CollectablesTransactionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgExp UFImage
---@field ImgTicket UFImage
---@field TextExpNum UFTextBlock
---@field TextTicketNum UFTextBlock
---@field TextValueNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CollectablesTransactionItemView = LuaClass(UIView, true)

function CollectablesTransactionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgExp = nil
	--self.ImgTicket = nil
	--self.TextExpNum = nil
	--self.TextTicketNum = nil
	--self.TextValueNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CollectablesTransactionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CollectablesTransactionItemView:OnInit()
	self.Binders = {
		{ "TicketReward", UIBinderSetTextFormatForMoney.New(self, self.TextTicketNum) },
		{ "ExperienceReward", UIBinderSetTextFormatForMoney.New(self, self.TextExpNum) },
		{ "CollectValue", UIBinderSetText.New(self, self.TextValueNum) },
		{ "TicketIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgTicket) },
	}
end

function CollectablesTransactionItemView:OnDestroy()

end

function CollectablesTransactionItemView:OnShow()

end

function CollectablesTransactionItemView:OnHide()

end

function CollectablesTransactionItemView:OnRegisterUIEvent()

end

function CollectablesTransactionItemView:OnRegisterGameEvent()

end

function CollectablesTransactionItemView:OnRegisterBinder()
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

return CollectablesTransactionItemView