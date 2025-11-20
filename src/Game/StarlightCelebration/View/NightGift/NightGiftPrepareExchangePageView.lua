---
--- Author: Administrator
--- DateTime: 2025-07-28 15:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local NightGiftPrepareExchangeVM = require("Game/StarlightCelebration/VM/NightGift/NightGiftPrepareExchangeVM")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local LocalizationUtil = require("Utils/LocalizationUtil")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

local LSTR = _G.LSTR
---@class NightGiftPrepareExchangePageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityTime OpsActivityTimeItemView
---@field BGPanel NightGiftBGPanelView
---@field BtnCopy UFButton
---@field CommBtn CommBtnLView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field Common_CloseBtn_UIBP CommonCloseBtnView
---@field FTextBlock_27 UFTextBlock
---@field ImgBtnLight UFImage
---@field NightGiftHorTab1 NightGiftHorTabItemView
---@field NightGiftHorTab2 NightGiftHorTabItemView
---@field PanelTitle UFCanvasPanel
---@field RichTextContent URichTextBox
---@field Text1 UFTextBlock
---@field Text2 UFTextBlock
---@field TextRemaining UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NightGiftPrepareExchangePageView = LuaClass(UIView, true)

function NightGiftPrepareExchangePageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityTime = nil
	--self.BGPanel = nil
	--self.BtnCopy = nil
	--self.CommBtn = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.Common_CloseBtn_UIBP = nil
	--self.FTextBlock_27 = nil
	--self.ImgBtnLight = nil
	--self.NightGiftHorTab1 = nil
	--self.NightGiftHorTab2 = nil
	--self.PanelTitle = nil
	--self.RichTextContent = nil
	--self.Text1 = nil
	--self.Text2 = nil
	--self.TextRemaining = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NightGiftPrepareExchangePageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActivityTime)
	self:AddSubView(self.BGPanel)
	self:AddSubView(self.CommBtn)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.Common_CloseBtn_UIBP)
	self:AddSubView(self.NightGiftHorTab1)
	self:AddSubView(self.NightGiftHorTab2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NightGiftPrepareExchangePageView:OnInit()
	self.ViewModel = NightGiftPrepareExchangeVM.New()
	self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.Text2, nil, nil, self.TimeOutCallback, self.TimeUpdateCallback)
	self.Binders = {
		{"TitleText", UIBinderSetText.New(self, self.FTextBlock_27)},
		{"PrepareDesc", UIBinderSetText.New(self, self.Text1)},
		{"ExchangeDesc", UIBinderUpdateCountDown.New(self, self.AdapterCountDownTime, 1, true, false) },
		{"DetailDesc", UIBinderSetText.New(self, self.RichTextContent)},
		{"ProgressDesc", UIBinderSetText.New(self, self.TextRemaining) },
		{"ButtonText", UIBinderSetText.New(self, self.CommBtn.TextContent) },
		{"BtnEnabled", UIBinderSetIsEnabled.New(self, self.CommBtn, false, true) },
		{"PutGiftLockVisible", UIBinderSetIsVisible.New(self, self.NightGiftHorTab1.ImgLock) },
		{"GetGiftLockVisible", UIBinderSetIsVisible.New(self, self.NightGiftHorTab2.ImgLock) },
		{"PutGiftButtonText", UIBinderSetText.New(self, self.NightGiftHorTab1.TextTabName)},
		{"GetGiftButtonText", UIBinderSetText.New(self, self.NightGiftHorTab2.TextTabName)},

		{"PutGiftButtonSelelcted", UIBinderSetIsVisible.New(self, self.NightGiftHorTab1.ImgBtnSelect)},
		{"GetGiftButtonSelelcted", UIBinderSetIsVisible.New(self, self.NightGiftHorTab2.ImgBtnSelect)},

		{"PutGiftTabColor", UIBinderSetColorAndOpacityHex.New(self, self.NightGiftHorTab1.TextTabName)},
		{"GetGiftTabColor", UIBinderSetColorAndOpacityHex.New(self, self.NightGiftHorTab2.TextTabName)},
	
	}

	self.ActivityTime.TextTime.Font.OutlineSettings.OutlineSize = 2
end

function NightGiftPrepareExchangePageView:OnDestroy()

end

function NightGiftPrepareExchangePageView:OnShow()
	if self.Params == nil then
		return
	end

	self.NightGiftHorTab2.RedDot:SetRedDotNameByString(_G.OpsSeasonActivityMgr:GetRedDotName(tostring(self.Params.ActivityID).."/NightGift"))
	self.ViewModel:SetNormalInfo(self.Params)
	self.ViewModel:ShowPutGift(self.Params)
end

function NightGiftPrepareExchangePageView:OnHide()

end

function NightGiftPrepareExchangePageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.NightGiftHorTab1.BtnItem, self.OnClickPutGiftButton)
	UIUtil.AddOnClickedEvent(self, self.NightGiftHorTab2.BtnItem, self.OnClickGetGiftButton)
	UIUtil.AddOnClickedEvent(self, self.CommBtn.Button, self.OnClickActionButton)
	UIUtil.AddOnClickedEvent(self, self.BtnCopy, self.OnClickRecordButton)
end

function NightGiftPrepareExchangePageView:OnRegisterGameEvent()

	self:RegisterGameEvent(_G.EventID.MapFollowAdd, self.Hide)
	self:RegisterGameEvent(_G.EventID.CrystalTransferReq, self.Hide)

end

function NightGiftPrepareExchangePageView:OnClickPutGiftButton()
	self.ViewModel:ShowPutGift(self.Params)
end

function NightGiftPrepareExchangePageView:OnClickGetGiftButton()
	if self.ViewModel.GetGiftLockVisible == true then
		local Desc = self.Text2:GetText()
		_G.MsgTipsUtil.ShowTips(Desc..LSTR(1700011))
		return
	end
	self.ViewModel:ShowGetGift(self.Params)
end

function NightGiftPrepareExchangePageView:OnClickActionButton()
	if self.ViewModel.ButtonText == LSTR(1700007) then
		if self.ViewModel.BtnEnabled then
			if self.ViewModel.PutGiftCfg then
				_G.OpsActivityMgr:Jump(self.ViewModel.PutGiftCfg.JumpType, self.ViewModel.PutGiftCfg.JumpParam)
			end
		else
			_G.MsgTipsUtil.ShowTips(LSTR(1700012))
		end

	elseif self.ViewModel.ButtonText == LSTR(1700010) then
		if self.ViewModel.BtnEnabled then
			if self.ViewModel.GetGiftCfg then
				_G.OpsActivityMgr:Jump(self.ViewModel.GetGiftCfg.JumpType, self.ViewModel.GetGiftCfg.JumpParam)
			end
		else
			_G.MsgTipsUtil.ShowTips(LSTR(1700013))
		end

	end
end

function NightGiftPrepareExchangePageView:OnClickRecordButton()
	if self.ViewModel.ButtonText == LSTR(1700007) then
		_G.UIViewMgr:ShowView(_G.UIViewID.OpsNightGiftRecord, {PutGift = self.ViewModel.PutGiftNode})
	elseif self.ViewModel.ButtonText == LSTR(1700010) then
		_G.UIViewMgr:ShowView(_G.UIViewID.OpsNightGiftRecord, {GetGift = self.ViewModel.GetGiftNode})
	end
end

function NightGiftPrepareExchangePageView:TimeOutCallback()
	self.ViewModel:StartGetGift()
	self.Text2:SetText(LSTR(1700004))
end

function NightGiftPrepareExchangePageView:TimeUpdateCallback(LeftTime)
	return LSTR(1700066)
end


function NightGiftPrepareExchangePageView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return NightGiftPrepareExchangePageView