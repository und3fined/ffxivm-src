---
--- Author: Administrator
--- DateTime: 2024-12-25 15:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetProfIconSimple = require("Binder/UIBinderSetProfIconSimple")
local UIBinderSetProfIconSimple2nd = require("Binder/UIBinderSetProfIconSimple2nd")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")



---@class SavageRankInfoPlayerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CurrentJobSlot CommPlayerSimpleJobSlotView
---@field SavageRankHeadSlot SavageRankHeadSlotView
---@field TextClass UFTextBlock
---@field TextName UFTextBlock
---@field TextName_1 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SavageRankInfoPlayerItemView = LuaClass(UIView, true)

function SavageRankInfoPlayerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CurrentJobSlot = nil
	--self.SavageRankHeadSlot = nil
	--self.TextClass = nil
	--self.TextName = nil
	--self.TextName_1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SavageRankInfoPlayerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CurrentJobSlot)
	self:AddSubView(self.SavageRankHeadSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SavageRankInfoPlayerItemView:OnInit()
	self.Binders = {
		{ "RoleName", UIBinderSetText.New(self, self.TextName) },
		{ "ServerName", UIBinderSetText.New(self, self.TextName_1) },
		{ "EquipLvText", UIBinderSetText.New(self, self.TextClass) },	
		{ "Lv", 		UIBinderSetText.New(self, self.CurrentJobSlot.TextLevel) },
		{ "Prof", 		UIBinderSetProfIcon.New(self, self.CurrentJobSlot.ImgJob) },
	}
end

function SavageRankInfoPlayerItemView:OnDestroy()

end

function SavageRankInfoPlayerItemView:OnShow()
	
end

function SavageRankInfoPlayerItemView:OnHide()

end

function SavageRankInfoPlayerItemView:OnRegisterUIEvent()

end

function SavageRankInfoPlayerItemView:OnRegisterGameEvent()

end

function SavageRankInfoPlayerItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
	self.SavageRankHeadSlot:SetParams({Data = ViewModel.SavageRankHeadSlotVM})
end

return SavageRankInfoPlayerItemView