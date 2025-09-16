---
--- Author: usakizhang
--- DateTime: 2025-03-06 15:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local TipsUtil = require("Utils/TipsUtil")
---@class OpsConcertGetListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDetail UFButton
---@field BtnInfo UFButton
---@field Comm74Slot CommBackpack74SlotView
---@field ImgListBight UFImage
---@field ImgListDark UFImage
---@field RichText1 URichTextBox
---@field RichText2 URichTextBox
---@field TextGrandTotal UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsConcertGetListItemView = LuaClass(UIView, true)

function OpsConcertGetListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDetail = nil
	--self.BtnInfo = nil
	--self.Comm74Slot = nil
	--self.ImgListBight = nil
	--self.ImgListDark = nil
	--self.RichText1 = nil
	--self.RichText2 = nil
	--self.TextGrandTotal = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsConcertGetListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm74Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsConcertGetListItemView:OnInit()
	self.Binders = {
		{"TaskTitle", UIBinderSetText.New(self, self.RichText2)},
		{"RewardGetSituationDes", UIBinderSetText.New(self, self.TextGrandTotal)},
		{"BtnInfoVisible", UIBinderSetIsVisible.New(self, self.BtnInfo, false, true)},
		{"BtnDetailVisible", UIBinderSetIsVisible.New(self, self.BtnDetail, false, true)},
		{"ImgListBight", UIBinderSetIsVisible.New(self, self.ImgListBight)},
		{"ImgListDark", UIBinderSetIsVisible.New(self, self.ImgListDark)},
	}
end

function OpsConcertGetListItemView:OnDestroy()

end

function OpsConcertGetListItemView:OnShow()
	self.Comm74Slot:SetClickButtonCallback(self, self.OnClickItmBtn)

end

function OpsConcertGetListItemView:OnHide()

end

function OpsConcertGetListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnDetail, self.OnClickBtnDetail)
	UIUtil.AddOnClickedEvent(self,  self.BtnInfo, self.OnClickBtnInfo)
end

function OpsConcertGetListItemView:OnRegisterGameEvent()

end

function OpsConcertGetListItemView:OnRegisterBinder()
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

function OpsConcertGetListItemView:OnClickBtnInfo()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	local ItemViewSize = UIUtil.GetWidgetSize(self.BtnInfo)
	TipsUtil.ShowInfoTips(ViewModel.HelpInfoDes, self.BtnInfo, _G.UE.FVector2D(-ItemViewSize.X, -ItemViewSize.Y-70), _G.UE.FVector2D(0, 0), false)
end
function OpsConcertGetListItemView:OnClickBtnDetail()
	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	local View = self.Params.Adapter.View
	View:OnBtnRecallListClick()
end

function OpsConcertGetListItemView:OnClickItmBtn()
	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	ItemTipsUtil.ShowTipsByResID(ViewModel.ItemID, self.Comm74Slot)
end
return OpsConcertGetListItemView