---
--- Author: erreetrtr
--- DateTime: 2023-02-02 14:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ShopVM = require("Game/Shop/ShopVM")
local ShopMgr = require("Game/Shop/ShopMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
--local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local BagMgr = require("Game/Bag/BagMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR

---@class ShopExchangeWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnAdd UFButton
---@field BtnAddTipReplace UFButton
---@field BtnCancel CommBtnLView
---@field BtnConfirm CommBtnLView
---@field BtnSub UFButton
---@field BtnSubTipReplace UFButton
---@field CommItemSlot CommBackpackSlotView
---@field CurrencyPage ShopCurrencyPageView
---@field PanelTips UFCanvasPanel
---@field ProBarAmount UProgressBar
---@field SliderAmount USlider
---@field TableViewCost UTableView
---@field TextExchangeAmount UFTextBlock
---@field TextName UFTextBlock
---@field TextSurplus UFTextBlock
---@field TextTipsContent UFTextBlock
---@field TextType UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopExchangeWinView = LuaClass(UIView, true)

function ShopExchangeWinView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnAdd = nil
	--self.BtnAddTipReplace = nil
	--self.BtnCancel = nil
	--self.BtnConfirm = nil
	--self.BtnSub = nil
	--self.BtnSubTipReplace = nil
	--self.CommItemSlot = nil
	--self.CurrencyPage = nil
	--self.PanelTips = nil
	--self.ProBarAmount = nil
	--self.SliderAmount = nil
	--self.TableViewCost = nil
	--self.TextExchangeAmount = nil
	--self.TextName = nil
	--self.TextSurplus = nil
	--self.TextTipsContent = nil
	--self.TextType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopExchangeWinView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnConfirm)
	self:AddSubView(self.CommItemSlot)
	self:AddSubView(self.CurrencyPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopExchangeWinView:OnInit()
    --滑动条百分比for UI效果
    self.bReceiveSliderChangeByMouse = false
    self.TableViewCostAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCost, nil, true)

    self.Binders = {
        {"ItemName", UIBinderSetText.New(self, self.TextName)},
        {"ItemTypeName", UIBinderSetText.New(self, self.TextType)},
        {"ShopBuyTypeName", UIBinderSetText.New(self, self.BG.FText_Title)},
        {"CostList", UIBinderUpdateBindableList.New(self, self.TableViewCostAdapter)},
        {"IsNeedLongClick", UIBinderSetIsVisible.New(self, self.PanelTips)},
        {"ToExchangeTips", UIBinderSetText.New(self, self.TextExchangeAmount)},
        {"IsLimited", UIBinderSetIsVisible.New(self, self.TextSurplus)},
        {"LimitMaxTips", UIBinderSetText.New(self, self.TextSurplus)},
        {"ExchangePercent", UIBinderSetPercent.New(self, self.ProBarAmount)},
        {"BtnConfirmName", UIBinderSetText.New(self, self.BtnConfirm.TextContent)},
        {"bNotAdd", UIBinderSetIsVisible.New(self, self.BtnAddTipReplace, nil, true)},
        {"bNotSub", UIBinderSetIsVisible.New(self, self.BtnSubTipReplace, nil, true)},
		{"bNotAdd", UIBinderSetIsEnabled.New(self, self.BtnAdd, true)},
		{"bNotSub", UIBinderSetIsEnabled.New(self, self.BtnSub, true)},
		{"IsBuyBtnEnable", UIBinderSetIsEnabled.New(self, self.BtnConfirm)},
        {"TextTipsContent",  UIBinderSetText.New(self, self.TextTipsContent)}
        --{"IsNeedLongClick", UIBinderValueChangedCallback.New(self, self.BtnConfirm, self.ChangeBtnConfirmClickState)}
    }
end

function ShopExchangeWinView:OnDestroy()
end

function ShopExchangeWinView:OnShow()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
    self.SliderAmount:SetValue(ViewModel.ExchangePercent)
end

function ShopExchangeWinView:OnHide()
	ShopVM.CurrencyPageVM:ChangeCanSelectState(true)
end

function ShopExchangeWinView:OnRegisterUIEvent()
    UIUtil.AddOnValueChangedEvent(self, self.SliderAmount, self.OnSliderAmountValueChange)
    UIUtil.AddOnMouseCaptureBeginEvent(self, self.SliderAmount, self.OnSliderMouseCaptureBegin)
    UIUtil.AddOnMouseCaptureEndEvent(self, self.SliderAmount, self.OnSliderMouseCaptureEnd)
    UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.OnBtnAddClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnSub, self.OnBtnSubClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnBtnCancelClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnAddTipReplace, self.OnBtnAddTipReplaceClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnSubTipReplace, self.OnBtnSubTipReplaceClicked)
    --UIUtil.AddOnClickedEvent(self, self.BtnConfirm.Button, self.OnBtnConfirmClicked)
end

function ShopExchangeWinView:OnRegisterGameEvent()
end

function ShopExchangeWinView:OnRegisterBinder()
    self.CurrencyPage:SetParams({Data = ShopVM.CurrencyPageVM})
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
    self.CommItemSlot:SetParams({Data = ViewModel.CommItemSlotVM})
    self:RegisterBinders(ViewModel, self.Binders)

    local bLongClick = ViewModel.IsNeedLongClick
    self:RefreshBtnConfirmClickState(bLongClick)
end

function ShopExchangeWinView:RefreshBtnConfirmClickState(bLongClick)
    local ConfirmBtn = self.BtnConfirm
    if nil == ConfirmBtn then
        -- body
        FLOG_ERROR("ShopExchangeWinView:RefreshBtnConfirmClickState ConfirmBtn is nil")
        return
    end
    -- 清理btn的监听事件
    local OnLongPressedOfConfirmBtn = ConfirmBtn.OnLongPressed
    if nil ~= OnLongPressedOfConfirmBtn then
        OnLongPressedOfConfirmBtn:Clear()
    end

    local OnClickedOfConfirmBtn = ConfirmBtn.OnClicked
    if nil ~= OnClickedOfConfirmBtn then
        OnClickedOfConfirmBtn:Clear()
    end

    ConfirmBtn.ParamLongPress = bLongClick
    if bLongClick == false then
        UIUtil.SetIsVisible(ConfirmBtn.ProBarLongPress, false)
        UIUtil.AddOnClickedEvent(self, self.BtnConfirm, self.OnBtnConfirmClicked)
        print("ShopExchangeWinView:AddOnClickedEvent()")
    else
		ConfirmBtn.ProBarLongPress:SetPercent(0)
		UIUtil.SetIsVisible(ConfirmBtn.ImgNormal, false)
		UIUtil.SetIsVisible(ConfirmBtn.ImgRecommend, false)
		UIUtil.SetIsVisible(ConfirmBtn.ImgDisable, false)
		UIUtil.SetIsVisible(ConfirmBtn.ProBarLongPress, true)--]]
        UIUtil.AddOnLongPressedEvent(self, self.BtnConfirm, self.OnBtnConfirmClicked)
        print("ShopExchangeWinView:AddOnLongPressedEvent()")
    end
end

function ShopExchangeWinView:OnSliderMouseCaptureBegin()
    self.bReceiveSliderChangeByMouse = true
end

function ShopExchangeWinView:OnSliderMouseCaptureEnd()
    self.bReceiveSliderChangeByMouse = false
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    local Per = ViewModel.ExchangePercent
    local NewExchangeNum = math.floor(ViewModel.MaxValue * Per + 0.5)
    ViewModel.ExchangePercent = NewExchangeNum / ViewModel.MaxValue
    self.SliderAmount:SetValue(ViewModel.ExchangePercent)
    ViewModel:ChangeExchangeNum(NewExchangeNum)
end

function ShopExchangeWinView:OnSliderAmountValueChange(_, Value)
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    if self.bReceiveSliderChangeByMouse == true then
        ViewModel:ChangeExchangeNumBySlider(Value)
    else
        self.SliderAmount:SetValue(ViewModel.ExchangePercent)
    end
end

function ShopExchangeWinView:OnBtnAddClicked()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    ViewModel:AddExchangeNum()
    self.SliderAmount:SetValue(ViewModel.ExchangePercent)
end

function ShopExchangeWinView:OnBtnSubClicked()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    ViewModel:SubExchangeNum()
    self.SliderAmount:SetValue(ViewModel.ExchangePercent)
end

function ShopExchangeWinView:OnBtnCancelClicked()
	self:Hide()
end

function ShopExchangeWinView:OnBtnConfirmClicked()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    local LeftSlotCount = BagMgr:GetBagLeftNum(ViewModel.ItemId)
    local ExchangeName = ShopMgr:IsNeedShowBuyOrExchange(ShopMgr.CurOpenMallId)
    if LeftSlotCount <= 0 then
        local TipsToShow = string.format(LSTR(1200074), ExchangeName)
        MsgTipsUtil.ShowTips(TipsToShow)
        return
    end

    ShopMgr:BuyShopItem(ViewModel.ShopItemId, ViewModel.ToExchangeNum)
	self:Hide()
end

function ShopExchangeWinView:OnBtnAddTipReplaceClicked()
	MsgTipsUtil.ShowErrorTips(LSTR(1200044), 1)
end

function ShopExchangeWinView:OnBtnSubTipReplaceClicked()
	MsgTipsUtil.ShowErrorTips(LSTR(1200044), 1)
end

return ShopExchangeWinView
