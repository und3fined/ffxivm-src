---
--- Author: Administrator
--- DateTime: 2025-02-26 16:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local OpsHalloweenGamePanelVM = require("Game/Ops/VM/OpsHalloween/OpsHalloweenGamePanelVM")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local EToggleButtonState = _G.UE.EToggleButtonState

---@class OpsHalloweenGamePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnJack UFButton
---@field BtnLittleDevil UFButton
---@field BtnMagicCircle UFButton
---@field BtnPumpkinHead UFButton
---@field BtnTreasury UFButton
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field IconFindCookiesComplete UFImage
---@field IconJackComplete UFImage
---@field IconLittleDevilComplete UFImage
---@field IconMagicBoxComplete UFImage
---@field IconMagicCircleComplete UFImage
---@field IconPumpkinHeadComplete UFImage
---@field IconTreasuryComplete UFImage
---@field TextFindCookies UFTextBlock
---@field TextFindCookiesNotUnlock UFTextBlock
---@field TextJack UFTextBlock
---@field TextLittleDevil UFTextBlock
---@field TextMagicBox UFTextBlock
---@field TextMagicBoxNotUnlock UFTextBlock
---@field TextMagicCircle UFTextBlock
---@field TextPumpkinHead UFTextBlock
---@field TextTitle UFTextBlock
---@field TextTreasury UFTextBlock
---@field ToggleBtnFindCookies UToggleButton
---@field ToggleBtnMagicBox UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsHalloweenGamePanelView = LuaClass(UIView, true)

function OpsHalloweenGamePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnJack = nil
	--self.BtnLittleDevil = nil
	--self.BtnMagicCircle = nil
	--self.BtnPumpkinHead = nil
	--self.BtnTreasury = nil
	--self.CloseBtn = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.IconFindCookiesComplete = nil
	--self.IconJackComplete = nil
	--self.IconLittleDevilComplete = nil
	--self.IconMagicBoxComplete = nil
	--self.IconMagicCircleComplete = nil
	--self.IconPumpkinHeadComplete = nil
	--self.IconTreasuryComplete = nil
	--self.TextFindCookies = nil
	--self.TextFindCookiesNotUnlock = nil
	--self.TextJack = nil
	--self.TextLittleDevil = nil
	--self.TextMagicBox = nil
	--self.TextMagicBoxNotUnlock = nil
	--self.TextMagicCircle = nil
	--self.TextPumpkinHead = nil
	--self.TextTitle = nil
	--self.TextTreasury = nil
	--self.ToggleBtnFindCookies = nil
	--self.ToggleBtnMagicBox = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsHalloweenGamePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsHalloweenGamePanelView:OnInit()
	self.ViewModel = OpsHalloweenGamePanelVM.New()
	self.Binders = {
       	{"PumpkinHeadText", UIBinderSetText.New(self, self.TextPumpkinHead)},
		{"PumpkinHeadCompleteVisible", UIBinderSetIsVisible.New(self, self.IconPumpkinHeadComplete)},
		{"TreasuryText", UIBinderSetText.New(self, self.TextTreasury)},
		{"TreasuryCompleteVisible", UIBinderSetIsVisible.New(self, self.IconTreasuryComplete)},
		{"LittleDevilText", UIBinderSetText.New(self, self.TextLittleDevil)},
		{"LittleDevilCompleteVisible", UIBinderSetIsVisible.New(self, self.IconLittleDevilComplete)},
		{"JackText", UIBinderSetText.New(self, self.TextJack)},
		{"JackCompleteVisible", UIBinderSetIsVisible.New(self, self.IconJackComplete)},
		{"MagicCircleText", UIBinderSetText.New(self, self.TextMagicCircle)},
		{"MagicCircleCompleteVisible", UIBinderSetIsVisible.New(self, self.IconMagicCircleComplete)},


		{"MagicBoxText", UIBinderSetText.New(self, self.TextMagicBox)},
		{"MagicBoxLockText", UIBinderSetText.New(self, self.TextMagicBoxNotUnlock)},
		{"MagicBoxCompleteVisible", UIBinderSetIsVisible.New(self, self.IconMagicBoxComplete)},
		{"MagicBoxBtnState", UIBinderSetCheckedState.New(self, self.ToggleBtnMagicBox) },

		{"FindCookiesText", UIBinderSetText.New(self, self.TextFindCookies)},
		{"FindCookiesLockText", UIBinderSetText.New(self, self.TextFindCookiesNotUnlock)},
		{"FindCookiesCompleteVisible", UIBinderSetIsVisible.New(self, self.IconFindCookiesComplete)},
		{"FindCookiesBtnState", UIBinderSetCheckedState.New(self, self.ToggleBtnFindCookies) },
		
    }
	
end

function OpsHalloweenGamePanelView:OnDestroy()

end

function OpsHalloweenGamePanelView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ChildrenActivitys == nil then
		return
	end

	self.ViewModel:Update(self.Params)
end

function OpsHalloweenGamePanelView:OnHide()

end

function OpsHalloweenGamePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnJack, self.OnClickedJackBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnLittleDevil, self.OnClickedLittleDevilBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnMagicCircle, self.OnClickedMagicCircleBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnPumpkinHead, self.OnClickPumpkinHeadBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnTreasury, self.OnClickTreasuryBtn)

	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMagicBox, self.OnClickMagicBoxBtn)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnFindCookies, self.OnClickFindCookiesBtn)
end

function OpsHalloweenGamePanelView:OnRegisterGameEvent()

end

function OpsHalloweenGamePanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
	self.TextTitle:SetText(_G.LSTR(1560010))
end

function OpsHalloweenGamePanelView:OnClickedJackBtn()
	if self.ViewModel == nil then
		return
	end
	self:ShowGameTips(self.ViewModel.JackNodeCfg)
end

function OpsHalloweenGamePanelView:OnClickedLittleDevilBtn()
	if self.ViewModel == nil then
		return
	end
	self:ShowGameTips(self.ViewModel.LittleDevilNodeCfg)
end

function OpsHalloweenGamePanelView:OnClickedMagicCircleBtn()
	if self.ViewModel == nil then
		return
	end
	self:ShowGameTips(self.ViewModel.MagicCircleNodeCfg)
end

function OpsHalloweenGamePanelView:OnClickPumpkinHeadBtn()
	if self.ViewModel == nil then
		return
	end
	self:ShowGameTips(self.ViewModel.PumpkinHeadNodeCfg)
end

function OpsHalloweenGamePanelView:OnClickTreasuryBtn()
	if self.ViewModel == nil then
		return
	end
	self:ShowGameTips(self.ViewModel.TreasuryNodeCfg)
end

function OpsHalloweenGamePanelView:OnClickMagicBoxBtn()
	if self.ViewModel == nil then
		return
	end

	if self.ViewModel.MagicBoxBtnState == EToggleButtonState.Checked then
		self:ShowGameTips(self.ViewModel.MagicBoxNodeCfg)
	else
		self.ToggleBtnMagicBox:SetChecked(false)
		if self.ViewModel.MagicBoxLockText then
			_G.MsgTipsUtil.ShowTips(_G.LSTR(1560024)..self.ViewModel.MagicBoxLockText)
		else
			_G.MsgTipsUtil.ShowTips(_G.LSTR(1560024))
		end
	end
end

function OpsHalloweenGamePanelView:OnClickFindCookiesBtn()
	if self.ViewModel == nil then
		return
	end

	if self.ViewModel.FindCookiesBtnState == EToggleButtonState.Checked then
		self:ShowGameTips(self.ViewModel.FindCookiesNodeCfg)
	else
		self.ToggleBtnFindCookies:SetChecked(false)
		_G.MsgTipsUtil.ShowTips(_G.LSTR(1560024)..self.ViewModel.FindCookiesLockText)
	end
end

function OpsHalloweenGamePanelView:ShowGameTips(NodeCfg)
	if NodeCfg == nil then
		return
	end
	_G.UIViewMgr:ShowView(_G.UIViewID.OpsHalloweenGameWin, {Title = NodeCfg.NodeTitle, Content = NodeCfg.NodeDesc})
end

return OpsHalloweenGamePanelView