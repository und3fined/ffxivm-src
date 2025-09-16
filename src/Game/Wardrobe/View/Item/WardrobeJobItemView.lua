---
--- Author: Administrator
--- DateTime: 2024-02-22 15:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class WardrobeJobItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInfo2 CommInforBtnView
---@field FHorizontalLevel UFHorizontalBox
---@field FVerticalJob UFVerticalBox
---@field ImgArrow1 UFImage
---@field ImgArrow2 UFImage
---@field SizeBoxX USizeBox
---@field SizeBoxX2 USizeBox
---@field SizeBoxX3 USizeBox
---@field SizeBoxX4 USizeBox
---@field SizeBoxX5 USizeBox
---@field TextGender URichTextBox
---@field TextJob URichTextBox
---@field TextJobLevel URichTextBox
---@field TextRace URichTextBox
---@field TextUnlock URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeJobItemView = LuaClass(UIView, true)

function WardrobeJobItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInfo2 = nil
	--self.FHorizontalLevel = nil
	--self.FVerticalJob = nil
	--self.ImgArrow1 = nil
	--self.ImgArrow2 = nil
	--self.SizeBoxX = nil
	--self.SizeBoxX2 = nil
	--self.SizeBoxX3 = nil
	--self.SizeBoxX4 = nil
	--self.SizeBoxX5 = nil
	--self.TextGender = nil
	--self.TextJob = nil
	--self.TextJobLevel = nil
	--self.TextRace = nil
	--self.TextUnlock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeJobItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnInfo2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeJobItemView:OnInit()
	self.Binders = {
		{ "GenderCond", UIBinderSetText.New(self, self.TextGender) },
		{ "ProfCond", UIBinderSetText.New(self, self.TextJob) },
		{ "ProfLevel", UIBinderSetText.New(self, self.TextJobLevel) },
		{ "RaceCond", UIBinderSetText.New(self, self.TextRace) },
		{ "UnlockVisible", UIBinderSetIsVisible.New(self, self.TextUnlock)},
		{ "JobBoxVisible", UIBinderSetIsVisible.New(self, self.FVerticalJob)},
	}
end

function WardrobeJobItemView:OnDestroy()

end

function WardrobeJobItemView:OnShow()
	self.BtnInfo2:SetCallback(self, self.OnClickedBtnInfo2)
end

function WardrobeJobItemView:OnHide()
end

function WardrobeJobItemView:OnRegisterUIEvent()
end

function WardrobeJobItemView:OnRegisterGameEvent()
end

function WardrobeJobItemView:OnRegisterBinder()
	-- local Params = self.Params
	-- if Params == nil then
	-- 	return
	-- end

	-- local ViewModel = Params.Data
	-- if ViewModel == nil then
	-- 	return
	-- end

	-- self:RegisterBinders(ViewModel, self.Binders)
end

function WardrobeJobItemView:OnClickedBtnInfo2()
	if nil ~= self.Callback then
		self.Callback(self.View)
	end
end

function WardrobeJobItemView:SetCallback(View, Callback)
	self.View = View
	self.Callback = Callback
end

function WardrobeJobItemView:SetButtonStyle(StyleType)
	self.BtnInfo2:SetButtonStyle(StyleType)
end

return WardrobeJobItemView