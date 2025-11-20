---
--- Author: Administrator
--- DateTime: 2025-06-13 11:52
--- Description:仙人赐福右上信息栏
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MainPanelVM = require("Game/Main/MainPanelVM")
local GoldSaucerBlessingVM = require("Game/GoldSaucerMiniGame/MiniGameBless/GoldSaucerBlessingVM")
local MainPanelConfig = require("Game/Main/MainPanelConfig")

local LSTR = _G.LSTR

---@class GoldSaucerGameInfoPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFold UToggleButton
---@field BtnTips CommInforBtnView
---@field ImgDown UFImage
---@field ImgPlayStyleType UFImage
---@field ImgTime UFImage
---@field ImgUp UFImage
---@field PanelCountDown UFCanvasPanel
---@field PanelGateInfo UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field RichTextTips URichTextBox
---@field TextSlideTitle CommTextSlideView
---@field TextTime UFTextBlock
---@field TextUntilTime UFTextBlock
---@field AnimGetUpdate UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerGameInfoPanelView = LuaClass(UIView, true)

function GoldSaucerGameInfoPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFold = nil
	--self.BtnTips = nil
	--self.ImgDown = nil
	--self.ImgPlayStyleType = nil
	--self.ImgTime = nil
	--self.ImgUp = nil
	--self.PanelCountDown = nil
	--self.PanelGateInfo = nil
	--self.PanelTips = nil
	--self.RichTextTips = nil
	--self.TextSlideTitle = nil
	--self.TextTime = nil
	--self.TextUntilTime = nil
	--self.AnimGetUpdate = nil
	--self.AnimIn = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerGameInfoPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnTips)
	self:AddSubView(self.TextSlideTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerGameInfoPanelView:InitConstStringInfo()
	self.TextUntilTime:SetText(LSTR(1270003))
	self.BtnTips:SetHelpInfoID(11236)
end

function GoldSaucerGameInfoPanelView:OnInit()
	self.bFold = false
	self.LastCheck = false
	self.MultiBinders = {
		{
			ViewModel = MainPanelVM,
			Binders = {
				{ "FunctionVisible", UIBinderValueChangedCallback.New(self, nil, self.OnFunctionVisibleChanged) },
				{ "PlayStyleInfoVisible", UIBinderValueChangedCallback.New(self, nil, self.OnPlayStyleInfoVisibleChanged) },
			}
		},
		{
			ViewModel = GoldSaucerBlessingVM,
			Binders = {
				{"ActivityName", UIBinderValueChangedCallback.New(self, nil, self.OnActivityNameChanged)}, -- 标题
				{"ActivityDesc", UIBinderSetText.New(self, self.RichTextTips)}, -- 活动描述
				{"ActivityTime", UIBinderSetText.New(self, self.TextTime)}, -- 倒计时
				{"bShowCountDownTitle", UIBinderSetIsVisible.New(self, self.TextUntilTime)}, -- 倒计时title是否显示
				{"KindIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgPlayStyleType)}, -- 倒计时
			}
		}
	}
	self:InitConstStringInfo()
end

function GoldSaucerGameInfoPanelView:OnDestroy()

end

function GoldSaucerGameInfoPanelView:OnShow()
	UIUtil.SetIsVisible(self.PanelGateInfo, true)
    self.BtnFold:SetIsChecked(false)
end

function GoldSaucerGameInfoPanelView:OnHide()

end

function GoldSaucerGameInfoPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnFold, self.OnBtnFoldClicked)
end

function GoldSaucerGameInfoPanelView:OnRegisterGameEvent()

end

function GoldSaucerGameInfoPanelView:OnRegisterBinder()
	self:RegisterMultiBinders(self.MultiBinders)
end

function GoldSaucerGameInfoPanelView:OnPlayStyleInfoVisibleChanged(NewValue, _)
	if NewValue then
		_G.GoldSaucerBlessingMgr:HideRightTopPanel() -- 机遇临门显示时隐藏面板
	end
end

function GoldSaucerGameInfoPanelView:OnFunctionVisibleChanged(NewValue, _)
    self.bFold = NewValue
    self.BtnFold:SetIsChecked(self.bFold)
    local bExpand = not self.bFold
    if bExpand then
        self:PlayAnimation(self.AnimUnfold)
    end
    
    UIUtil.SetIsVisible(self.PanelGateInfo, bExpand)
end

function GoldSaucerGameInfoPanelView:OnActivityNameChanged(NewValue, _)
    self.TextSlideTitle:ShowSliderText(NewValue)
end

function GoldSaucerGameInfoPanelView:OnBtnFoldClicked()
    local bExpand = not self.bFold
    MainPanelVM:SetFunctionVisible(bExpand, MainPanelConfig.TopRightInfoType.GoldSauserBless)
end

return GoldSaucerGameInfoPanelView