---
--- Author: jamiyang
--- DateTime: 2024-02-02 11:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local LSTR = _G.LSTR


--@Binder
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")

--@ViewModel
local HaircutWinVM = require("Game/Haircut/VM/HaircutWinVM")

---@class HaircutWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackSlot CommBackpackSlotView
---@field BtnItem UFButton
---@field BtnNormal CommBtnLView
---@field BtnRecommend CommBtnLView
---@field Comm2FrameS_UIBP Comm2FrameSView
---@field CommCheckBox_UIBP CommCheckBoxView
---@field Icon UFImage
---@field Icon1 UFImage
---@field PanelConsume UFHorizontalBox
---@field PanelCost UFHorizontalBox
---@field Text UFTextBlock
---@field TextQuantity URichTextBox
---@field TextQuantity2 URichTextBox
---@field Textconsume UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY

---@field Params table @通过外部参数传入
---@field Params.WinType integer @类型 HaircutWinType
---@field Params.ItemID integer @消耗道具ID
---@field Params.SureCallback function @点击确认按钮的回调函数
---@field Params.CancleCallback function @点击取消按钮的回调函数

local HaircutWinView = LuaClass(UIView, true)

function HaircutWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackSlot = nil
	--self.BtnItem = nil
	--self.BtnNormal = nil
	--self.BtnRecommend = nil
	--self.Comm2FrameS_UIBP = nil
	--self.CommCheckBox_UIBP = nil
	--self.Icon = nil
	--self.Icon1 = nil
	--self.PanelConsume = nil
	--self.PanelCost = nil
	--self.Text = nil
	--self.TextQuantity = nil
	--self.TextQuantity2 = nil
	--self.Textconsume = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HaircutWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackSlot)
	self:AddSubView(self.BtnNormal)
	self:AddSubView(self.BtnRecommend)
	self:AddSubView(self.Comm2FrameS_UIBP)
	self:AddSubView(self.CommCheckBox_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HaircutWinView:OnInit()
	self.ViewModel = HaircutWinVM.New()
	UIUtil.SetIsVisible(self.BackpackSlot.FImg_Icon, true)
end

function HaircutWinView:OnDestroy()

end

function HaircutWinView:OnShow()
	if nil == self.Params then
		return
	end
	self.ViewModel.WinType = self.Params.WinType
	self.ViewModel:InitViewData(self.Params.WinType, self.Params.ItemID)

	-- 按钮文本
	local CancleText = LSTR(1250020) --"取消"
	local SureText = LSTR(1250021) --"确认"
	-- if self.ViewModel.WinType == HaircutWinType.Save then
	-- 	CancleText = LSTR("直接退出")
	-- 	SureText = LSTR("保存并退出")
	-- end
	self.BtnNormal:SetButtonText(CancleText)
	self.BtnRecommend:SetButtonText(SureText)

	-- 勾选状态
	if self.ViewModel.bShowMoney then
		self.CommCheckBox_UIBP:SetChecked(true)
		self.ViewModel:OnCheckBoxChange(true)
		self.CommCheckBox_UIBP:SetText(self.ViewModel.CheckBoxText)
	end
end

function HaircutWinView:OnHide()

end

function HaircutWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRecommend.Button, self.OnSureBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnNormal.Button, self.OnCancelBtnClick)
	UIUtil.AddOnStateChangedEvent(self, self.CommCheckBox_UIBP, self.OnCheckBoxClick)
	UIUtil.AddOnClickedEvent(self, self.BackpackSlot.FBtn_Item, self.OnBtnItemClick)
end

function HaircutWinView:OnRegisterGameEvent()

end

function HaircutWinView:OnRegisterBinder()
	local Binders = {
		{ "TileText", UIBinderSetText.New(self, self.Comm2FrameS_UIBP.FText_Title)},
		{ "SubText", UIBinderSetText.New(self, self.Text)},
		{ "bShowItem", UIBinderSetIsVisible.New(self, self.PanelConsume)},
		{ "ItemText", UIBinderSetText.New(self, self.TextQuantity)},
		{ "bShowMoney", UIBinderSetIsVisible.New(self, self.PanelCost)},
		{ "MoneyText", UIBinderSetText.New(self, self.TextQuantity2)},
		{ "bCheckMoney", UIBinderSetIsVisible.New(self, self.Icon1)},
		{ "bCheckMoney", UIBinderSetIsVisible.New(self, self.TextQuantity2)},
		{ "ConsumeText",  UIBinderSetText.New(self, self.Textconsume)},

		{ "ItemIcon", UIBinderSetBrushFromAssetPath.New(self, self.BackpackSlot.FImg_Icon, true) }, -- 消耗物品图标
		{ "MoneyIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon1, true) }, -- 消耗货币图标

		{ "bShowCancleBtn", UIBinderSetIsVisible.New(self, self.BtnNormal) },
		{ "bEnableSureBtn", UIBinderSetIsEnabled.New(self, self.BtnRecommend.Button)}, -- 解锁按钮

	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function HaircutWinView:OnBtnItemClick()
	ItemTipsUtil.ShowTipsByResID(self.ViewModel.ItemID, self.BackpackSlot)
end

function HaircutWinView:OnCheckBoxClick(_, ButtonState)
	local bChecked = UIUtil.IsToggleButtonChecked(ButtonState)
	self.ViewModel:OnCheckBoxChange(bChecked)
	self.CommCheckBox_UIBP:SetText(self.ViewModel.CheckBoxText)
end

function HaircutWinView:OnCancelBtnClick()
	if self.Params.CancleCallback ~= nil then
		self.Params.CancleCallback()
	end
	UIViewMgr:HideView(UIViewID.HaircutWin)
end

function HaircutWinView:OnSureBtnClick()
	if self.Params.SureCallback ~= nil then
		self.Params.SureCallback()
	end
	UIViewMgr:HideView(UIViewID.HaircutWin)
end

return HaircutWinView