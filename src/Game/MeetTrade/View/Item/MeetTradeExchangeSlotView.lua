---
--- Author: usakizhang
--- DateTime: 2024-12-26 20:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetOpacity = require("Binder/UIBinderSetOpacity")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewID = require("Define/UIViewID")
local LSTR = _G.LSTR
local UIViewMgr = _G.UIViewMgr
---@class MeetTradeExchangeSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd UFButton
---@field Comm96Slot CommBackpack96SlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MeetTradeExchangeSlotView = LuaClass(UIView, true)

function MeetTradeExchangeSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdd = nil
	--self.Comm96Slot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MeetTradeExchangeSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MeetTradeExchangeSlotView:OnInit()
	self.Binders = {
		{ "ItemVisible", UIBinderSetIsVisible.New(self, self.Comm96Slot) },
		{ "MeetTradeItemQualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.Comm96Slot.ImgQuanlity) },
		{ "MeetTradeIcon", UIBinderSetBrushFromAssetPath.New(self, self.Comm96Slot.Icon) },
		{ "NumText", UIBinderSetText.New(self, self.Comm96Slot.RichTextQuantity) },
		{ "NumTextVisible", UIBinderSetIsVisible.New(self, self.Comm96Slot.RichTextQuantity) },
		{ "IsMask", UIBinderSetIsVisible.New(self, self.Comm96Slot.ImgMask) },
		{ "ItemVisible", UIBinderSetIsVisible.New(self, self.Comm96Slot.PanelInfo)
		},
		--BagSlot已经绑定了
		-- { "IsSelect", UIBinderSetIsVisible.New(self, self.Comm96Slot.ImgSelect) },
		{ "IsRecieived", UIBinderSetIsVisible.New(self, self.Comm96Slot.IconReceived) },
		{ "IsChosen", UIBinderSetIsVisible.New(self, self.Comm96Slot.IconChoose) },
		{ "LevelVisible", UIBinderSetIsVisible.New(self, self.Comm96Slot.RichTextLevel) },
		{ "ImgAddOpacity", UIBinderSetOpacity.New(self, self.BtnAdd) },
		{ "BtnAddVisible", UIBinderSetIsVisible.New(self, self.BtnAdd, false, true) },
		{ "OtherInfomation", UIBinderSetIsVisible.New(self, self.Comm96Slot.Btn, false, true) },
	}
end

function MeetTradeExchangeSlotView:OnDestroy()

end

function MeetTradeExchangeSlotView:OnShow()
	self.Comm96Slot:SetClickButtonCallback(self, self.OnClickBtn)
end

function MeetTradeExchangeSlotView:OnHide()

end

function MeetTradeExchangeSlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.OnClickButtonAdd) --拉起选择物品的面板
end

function MeetTradeExchangeSlotView:OnRegisterGameEvent()

end

function MeetTradeExchangeSlotView:OnRegisterBinder()
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


--- 拉起选择物品的面板，不需要上报TableView
function MeetTradeExchangeSlotView:OnClickButtonAdd()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	--- VM为空或者该格子不是空格子
	if nil == ViewModel then
		return
	end
	--TODO 多语言接入
	if  _G.MeetTradeVM:GetIsLock() then
		MsgTipsUtil.ShowTips(LSTR(1490037)) --"提出条件后不可再进行交易物品的修改"
		return
	end
	---选择物品面板未被拉起
	if not UIViewMgr:IsViewVisible(UIViewID.MeetTradeExchangeChoosePanel) then
		local ShowViewParams = {ItemGID = ViewModel.GID}
		UIViewMgr:ShowView(UIViewID.MeetTradeExchangeChoosePanel, ShowViewParams)
	end

end

function MeetTradeExchangeSlotView:OnClickBtn()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	--- VM为空或者该格子不是空格子
	if nil == ViewModel then
		return
	end
	if ViewModel.ResID ~= nil then
		ItemTipsUtil.ShowTipsByResID(ViewModel.ResID, self)
	end
end
return MeetTradeExchangeSlotView