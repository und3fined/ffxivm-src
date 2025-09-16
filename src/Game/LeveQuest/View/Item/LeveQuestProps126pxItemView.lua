---
--- Author: Administrator
--- DateTime: 2023-12-28 10:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

---@class LeveQuestProps126pxItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClosure UFButton
---@field Comm126Slot CommBackpack126SlotView
---@field TextPercentage URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LeveQuestProps126pxItemView = LuaClass(UIView, true)

function LeveQuestProps126pxItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClosure = nil
	--self.Comm126Slot = nil
	--self.TextPercentage = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LeveQuestProps126pxItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm126Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LeveQuestProps126pxItemView:OnInit()
	self.Binders = {
		{"TextPer", UIBinderSetText.New(self, self.TextPercentage)},
		{"TextPerVisible", UIBinderSetIsVisible.New(self, self.TextPercentage)},
		{"IsSelect", UIBinderSetIsVisible.New(self, self.Comm126Slot.ImgSelect)},
	}
end

function LeveQuestProps126pxItemView:OnDestroy()

end

function LeveQuestProps126pxItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
end

function LeveQuestProps126pxItemView:OnHide()

end

function LeveQuestProps126pxItemView:OnRegisterUIEvent()
	self.Comm126Slot:SetClickButtonCallback(self, self.OnLeveQuestItemClicked)
end

function LeveQuestProps126pxItemView:OnRegisterGameEvent()

end

function LeveQuestProps126pxItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.Comm126Slot:SetParams({Data = ViewModel.ItemVM})
end


function LeveQuestProps126pxItemView:OnSelectChanged(IsSelected)

	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	
    ViewModel:SetSelected(IsSelected)
end

function LeveQuestProps126pxItemView:OnLeveQuestItemClicked()
	local Params = self.Params
	if(Params and Params.Adapter) then
		Params.Adapter:OnItemClicked(self, Params.Index)
	end
end



return LeveQuestProps126pxItemView