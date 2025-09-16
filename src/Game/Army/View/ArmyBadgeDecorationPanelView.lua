---
--- Author: Administrator
--- DateTime: 2023-11-22 14:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ArmyBadgeDecorationPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChannel CommBtnLView
---@field BtnClose CommonCloseBtnView
---@field BtnEdit UFButton
---@field BtnHelp CommHelpBtnView
---@field BtnRecoveryOK CommBtnLView
---@field BtnRemove CommBtnLView
---@field BtnRetract UFButton
---@field BtnVisible UFButton
---@field CommMoneySlot CommMoneySlotView
---@field CommonBkg CommonBkg01View
---@field ImgCurrency UFImage
---@field ImgGold2 UFImage
---@field ImgRecoveryBg UFImage
---@field ImgRecoveryFrame UFImage
---@field ImgRecoveryRed UFImage
---@field ImgUnVisible UFImage
---@field ImgVisible UFImage
---@field NoneTips CommBackpackEmptyView
---@field PanelOrnamentBtn UFCanvasPanel
---@field PanelRemoveBtn UFCanvasPanel
---@field RecoveryListPanel UFCanvasPanel
---@field RecoveryPanel UFCanvasPanel
---@field RichTextNumber URichTextBox
---@field TableViewBagItem UTableView
---@field TableViewRecovery UTableView
---@field TextCount UFTextBlock
---@field TextGoldNumber2 UFTextBlock
---@field TextName UFTextBlock
---@field TextTitleName UFTextBlock
---@field ToggleButton UToggleButton
---@field VerIconTabs CommVerIconTabsView
---@field AnimCloseBag UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOpenBag UWidgetAnimation
---@field AnimRecoveryIn UWidgetAnimation
---@field AnimRecoveryListIn UWidgetAnimation
---@field AnimRecoveryListOut UWidgetAnimation
---@field AnimRecoveryOut UWidgetAnimation
---@field AnimSwitchTab UWidgetAnimation
---@field AnimTrim UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyBadgeDecorationPanelView = LuaClass(UIView, true)

function ArmyBadgeDecorationPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChannel = nil
	--self.BtnClose = nil
	--self.BtnEdit = nil
	--self.BtnHelp = nil
	--self.BtnRecoveryOK = nil
	--self.BtnRemove = nil
	--self.BtnRetract = nil
	--self.BtnVisible = nil
	--self.CommMoneySlot = nil
	--self.CommonBkg = nil
	--self.ImgCurrency = nil
	--self.ImgGold2 = nil
	--self.ImgRecoveryBg = nil
	--self.ImgRecoveryFrame = nil
	--self.ImgRecoveryRed = nil
	--self.ImgUnVisible = nil
	--self.ImgVisible = nil
	--self.NoneTips = nil
	--self.PanelOrnamentBtn = nil
	--self.PanelRemoveBtn = nil
	--self.RecoveryListPanel = nil
	--self.RecoveryPanel = nil
	--self.RichTextNumber = nil
	--self.TableViewBagItem = nil
	--self.TableViewRecovery = nil
	--self.TextCount = nil
	--self.TextGoldNumber2 = nil
	--self.TextName = nil
	--self.TextTitleName = nil
	--self.ToggleButton = nil
	--self.VerIconTabs = nil
	--self.AnimCloseBag = nil
	--self.AnimIn = nil
	--self.AnimOpenBag = nil
	--self.AnimRecoveryIn = nil
	--self.AnimRecoveryListIn = nil
	--self.AnimRecoveryListOut = nil
	--self.AnimRecoveryOut = nil
	--self.AnimSwitchTab = nil
	--self.AnimTrim = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyBadgeDecorationPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnChannel)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnHelp)
	self:AddSubView(self.BtnRecoveryOK)
	self:AddSubView(self.BtnRemove)
	self:AddSubView(self.CommMoneySlot)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.NoneTips)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyBadgeDecorationPanelView:OnInit()

end

function ArmyBadgeDecorationPanelView:OnDestroy()

end

function ArmyBadgeDecorationPanelView:OnShow()

end

function ArmyBadgeDecorationPanelView:OnHide()

end

function ArmyBadgeDecorationPanelView:OnRegisterUIEvent()

end

function ArmyBadgeDecorationPanelView:OnRegisterGameEvent()

end

function ArmyBadgeDecorationPanelView:OnRegisterBinder()

end

return ArmyBadgeDecorationPanelView