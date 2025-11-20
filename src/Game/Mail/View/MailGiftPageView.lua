local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText =  require("Binder/UIBinderSetText")
local UIBinderSetTextFormat =  require("Binder/UIBinderSetTextFormat")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MailMainVM = require("Game/Mail/View/MailMainVM")

local LSTR = _G.LSTR

---@class MailGiftPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck CommBtnMView
---@field BtnDeleteMail CommBtnMView
---@field BtnOpen CommBtnLView
---@field CommTabs_UIBP CommTabsView
---@field CommonBkgMask CommonBkgMaskView
---@field EFF UFCanvasPanel
---@field ImgBGItem01 UFImage
---@field ImgBGItem03 UFImage
---@field PanelBGCover UFCanvasPanel
---@field PanelBGItem UFCanvasPanel
---@field PanelContent UFCanvasPanel
---@field PanelGift UFCanvasPanel
---@field PanelGiftMail UFCanvasPanel
---@field PanelGiftMailContent UFCanvasPanel
---@field PanelItem UFCanvasPanel
---@field PanelMailContent UFCanvasPanel
---@field RichTextBy URichTextBox
---@field RichTextDate URichTextBox
---@field RichTextMailContent URichTextBox
---@field RichTextToName URichTextBox
---@field Spine_Store_Mail USpineWidget
---@field TableViewGift UTableView
---@field TableViewMailList UTableView
---@field TextFromName UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimBGItem0 UWidgetAnimation
---@field AnimBGItem1 UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimShow1 UWidgetAnimation
---@field AnimShow2 UWidgetAnimation
---@field AnimShow3 UWidgetAnimation
---@field AnimSwitch1 UWidgetAnimation
---@field AnimSwitch2 UWidgetAnimation
---@field AnimSwitch3 UWidgetAnimation
---@field AnimToggleSwitch UWidgetAnimation
---@field MailLastIsOpen bool
---@field MailLastIsEmpty bool
---@field CanSwitch bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MailGiftPageView = LuaClass(UIView, true)

function MailGiftPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.BtnDeleteMail = nil
	--self.BtnOpen = nil
	--self.CommTabs_UIBP = nil
	--self.CommonBkgMask = nil
	--self.EFF = nil
	--self.ImgBGItem01 = nil
	--self.ImgBGItem03 = nil
	--self.PanelBGCover = nil
	--self.PanelBGItem = nil
	--self.PanelContent = nil
	--self.PanelGift = nil
	--self.PanelGiftMail = nil
	--self.PanelGiftMailContent = nil
	--self.PanelItem = nil
	--self.PanelMailContent = nil
	--self.RichTextBy = nil
	--self.RichTextDate = nil
	--self.RichTextMailContent = nil
	--self.RichTextToName = nil
	--self.Spine_Store_Mail = nil
	--self.TableViewGift = nil
	--self.TableViewMailList = nil
	--self.TextFromName = nil
	--self.TextTitle = nil
	--self.AnimBGItem0 = nil
	--self.AnimBGItem1 = nil
	--self.AnimIn = nil
	--self.AnimShow1 = nil
	--self.AnimShow2 = nil
	--self.AnimShow3 = nil
	--self.AnimSwitch1 = nil
	--self.AnimSwitch2 = nil
	--self.AnimSwitch3 = nil
	--self.AnimToggleSwitch = nil
	--self.MailLastIsOpen = nil
	--self.MailLastIsEmpty = nil
	--self.CanSwitch = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MailGiftPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCheck)
	self:AddSubView(self.BtnDeleteMail)
	self:AddSubView(self.BtnOpen)
	self:AddSubView(self.CommTabs_UIBP)
	self:AddSubView(self.CommonBkgMask)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MailGiftPageView:OnInit()
	self.AdapterMailList = UIAdapterTableView.CreateAdapter(self, self.TableViewMailList, self.OnSelectChangedAdapterMailList, true)
	self.AdapterTabReward = UIAdapterTableView.CreateAdapter(self, self.TableViewGift, self.OnSelectChangedTableViewGift, true )
	self.Binders = {
		{ "MailList", UIBinderUpdateBindableList.New(self, self.AdapterMailList) },
		{ "MailContent", UIBinderSetText.New(self, self.RichTextMailContent) },
		{ "SendTimeText", UIBinderSetTextFormat.New(self, self.RichTextDate, LSTR(740006)) },
		{ "SenderName", UIBinderSetTextFormat.New(self, self.RichTextBy, LSTR(740013)) },
		{ "ReceiverName", UIBinderSetTextFormat.New(self, self.RichTextToName, LSTR(740003)) },
		{ "GiftTextFromName", UIBinderSetText.New(self, self.TextFromName) },
		{ "AttachsInfoList", UIBinderUpdateBindableList.New(self, self.AdapterTabReward) },
		{ "GiftMailBtnCheckVisible", UIBinderSetIsVisible.New(self, self.BtnCheck) },
		{ "MailListDelChanged", UIBinderValueChangedCallback.New(self, nil, self.OnMailListDelChanged) },

		{ "GiftMailEnvelopeVisible", UIBinderValueChangedCallback.New(self, nil, self.EnvelopeVisibleChange) },
		{ "PanelGiftMailContentVisible", UIBinderSetIsVisible.New(self, self.PanelGiftMailContent) },
		{ "PanelEmptyVisible", UIBinderValueChangedCallback.New(self, nil, self.PanelEmptyVisibleChange) },
	}

	self.CommTabs_UIBP:SetCallBack(self, self.OnToggleGroupSwitchChanged)
end

function MailGiftPageView:OnDestroy()

end

function MailGiftPageView:TranslatedText()
	self.BtnDeleteMail:SetText(LSTR(10024))
	self.BtnCheck:SetText(LSTR(10025))
	self.BtnOpen:SetText(LSTR(740021))       --打开礼物
	self.TextTitle:SetText(LSTR(740018))     --赠礼
end

function MailGiftPageView:OnShow()
	self:TranslatedText()
	self.CommTabs_UIBP:SetSelectedIndex(1, true)
	self:PlayAnimShow(MailMainVM.PanelEmptyVisible, MailMainVM.PanelGiftMailContentVisible)
end

function MailGiftPageView:OnHide()
	MailMainVM:SetGiftPageVisible(false)
end

function MailGiftPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnOpen, self.OnBtnOpenClick)
	UIUtil.AddOnClickedEvent(self, self.BtnDeleteMail, self.OnBtnDeleteMailClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCheck, self.OnBtnCheckClick)
end

function MailGiftPageView:OnRegisterGameEvent()

end

function MailGiftPageView:OnRegisterBinder()
	self:RegisterBinders(MailMainVM, self.Binders)
	local TabList = {{Name = LSTR(740019)},{Name = LSTR(740020)} }  --收到礼物  --赠礼记录
	self.CommTabs_UIBP:UpdateItems(TabList, 1)
end

function MailGiftPageView:OnToggleGroupSwitchChanged( Index )
	MailMainVM:SetGiftToggleGroupIndex(Index)
	self.AdapterMailList:CancelSelected()

	if MailMainVM.GiftPageVisible then
		self:PlayAnimation(self.AnimToggleSwitch)
	end

	if self.AdapterMailList:GetNum() > 0 then
		if MailMainVM.FirstPickMailID then
			local Ret = self.AdapterMailList:SetSelectedByPredicate(
				function(Item) 
					return Item.ID == MailMainVM.FirstPickMailID
				end)
			MailMainVM:SetFirstPickMailID(nil)
		else
			self.AdapterMailList:SetSelectedIndex(1)
			self.AdapterMailList:ScrollToIndex(1)
		end
	end
end

function MailGiftPageView:OnSelectChangedAdapterMailList(Index, ItemData, ItemView)
	self.BtnOpen:SetText(ItemData.IsGreetingCard and LSTR(740026) or LSTR(740021)) --“打开贺卡” “打开礼物”
	self.TextTitle:SetText(ItemData.IsGreetingCard and LSTR(740024) or LSTR(740018))     --“贺卡”  “赠礼”

	MailMainVM:SetMailListLastSelectIndex(Index)
	MailMainVM:SelectMail(ItemData.ID)

	if MailMainVM.GiftPageVisible then
		self:PlayAnimSwitch(MailMainVM.PanelEmptyVisible, MailMainVM.PanelGiftMailContentVisible)
	end
	local MailData = _G.MailMgr:GetMailData(MailMainVM.CurrentMailID, MailMainVM.CurrentMailType, MailMainVM.CurrentMailBoxType)
	local CardStyle = (MailData.GreetingCardData or {}).StyleID or 0
	if ItemData.IsGreetingCard and CardStyle == 1 then
		self.Spine_Store_Mail:SetSkin("Holiday")
	else
		self.Spine_Store_Mail:SetSkin("Store")
	end
end

function MailGiftPageView:OnSelectChangedTableViewGift(Index, ItemData, ItemView)
	ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView, {X = 0,Y = -715}, nil)
end

function MailGiftPageView:OnBtnOpenClick()
	MailMainVM:ShowStoreGiftMailExpandedView(true)
end

function MailGiftPageView:OnBtnDeleteMailClick()
	local DeleteList = { MailMainVM.CurrentMailID }
	_G.MailMgr:DeleteMail(DeleteList, MailMainVM.CurrentMailType, MailMainVM.CurrentMailBoxType )
end

function MailGiftPageView:OnBtnCheckClick()
	MailMainVM:ShowStoreGiftMailExpandedView()
end

function MailGiftPageView:OnMailListDelChanged(NewValue, OldValue)
	if OldValue == nil then	return end
	local Index = MailMainVM.MailListLastSelectIndex
	if Index ~= nil and self.AdapterMailList:GetNum() >= Index then
		self.AdapterMailList:SetSelectedIndex(Index)
	else
		local MailListCount = self.AdapterMailList:GetNum()
		if MailListCount > 0 then
			self.AdapterMailList:SetSelectedIndex(MailListCount)
		end
	end
end

function MailGiftPageView:PanelEmptyVisibleChange(NewValue, OldValue)
	UIUtil.SetIsVisible(self.PanelItem, not NewValue)
	-- 删除最后邮件变换
	if OldValue ~= nil and MailMainVM.GiftPageVisible then
		self:PlayAnimSwitch(MailMainVM.PanelEmptyVisible, MailMainVM.PanelGiftMailContentVisible)
	end
end

function MailGiftPageView:EnvelopeVisibleChange(NewValue, OldValue)
	UIUtil.SetIsVisible(self.PanelGiftMail, NewValue)
	if OldValue ~= nil and MailMainVM.GiftPageVisible then
		-- 领取赠礼后变换
		self:PlayAnimSwitch( MailMainVM.PanelEmptyVisible , MailMainVM.PanelGiftMailContentVisible )
	end
end

return MailGiftPageView