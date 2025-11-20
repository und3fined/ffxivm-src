---
--- Author: yutingzhan
--- DateTime: 2025-05-27 15:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")

---@class BagTidyListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoto UFButton
---@field BtnInfo CommInforBtnView
---@field Choose1 BagTidyListChooseItemView
---@field Choose2 BagTidyListChooseItemView
---@field IconGoto UFImage
---@field PanelGoto UFCanvasPanel
---@field TextGoto UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BagTidyListItemView = LuaClass(UIView, true)

function BagTidyListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoto = nil
	--self.BtnInfo = nil
	--self.Choose1 = nil
	--self.Choose2 = nil
	--self.IconGoto = nil
	--self.PanelGoto = nil
	--self.TextGoto = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BagTidyListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnInfo)
	self:AddSubView(self.Choose1)
	self:AddSubView(self.Choose2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BagTidyListItemView:OnInit()
	self.Binders = {
		{ "TextTitle", UIBinderSetText.New(self, self.TextTitle) },
		{ "TextGoto", UIBinderSetText.New(self, self.TextGoto) },
		{ "GotoVisiable", UIBinderSetIsVisible.New(self, self.PanelGoto) },
		{ "Choose1TextVisiable", UIBinderSetIsVisible.New(self, self.Choose1.RichText) },
		{ "Choose1Text", UIBinderSetText.New(self, self.Choose1.RichText) },
		{ "Choose2Text", UIBinderSetText.New(self, self.Choose2.RichText) },
		{ "SingleBox1Enabled", UIBinderSetIsEnabled.New(self, self.Choose1.CommSingleBox.ToggleButton) },
		{ "SingleBox2Enabled", UIBinderSetIsEnabled.New(self, self.Choose2.CommSingleBox.ToggleButton) },
		{ "SingleBox1Enabled", UIBinderValueChangedCallback.New(self, nil, self.ToggleButtonState1Changed) },
		{ "SingleBox2Enabled", UIBinderValueChangedCallback.New(self, nil, self.ToggleButtonState2Changed) },
	}
end

function BagTidyListItemView:OnDestroy()
	-- 清理防抖定时器
	if self.UpdateTimer1 then
		_G.TimerMgr:CancelTimer(self.UpdateTimer1)
		self.UpdateTimer1 = nil
	end
	if self.UpdateTimer2 then
		_G.TimerMgr:CancelTimer(self.UpdateTimer2)
		self.UpdateTimer2 = nil
	end
end

function BagTidyListItemView:OnShow()
	if self.Params == nil or self.Params.Data == nil then return end

	local Data = self.Params.Data
	self.BtnInfo.HelpInfoID = Data.HelpInfoID
	if Data.Index == 1 then
		UIUtil.SetIsVisible(self.Choose2, false)
	elseif Data.Index == 2 or Data.Index == 3 then
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextGoto, "D6D6D6FF")
        UIUtil.ImageSetBrushFromAssetPath(self.IconGoto, "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Comm_Img_Goto_png.UI_Comm_Img_Goto_png'")
		self.BtnGoto:SetIsEnabled(true)
	end
	self:SetToggleState(Data)
end

function BagTidyListItemView:OnHide()

end

function BagTidyListItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.Choose1.CommSingleBox, self.OnToggle1StateChanged)
	UIUtil.AddOnStateChangedEvent(self, self.Choose2.CommSingleBox, self.OnToggle2StateChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnGoto, self.OnClickBtnGoto)
end

function BagTidyListItemView:OnRegisterGameEvent()

end

function BagTidyListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self:RegisterBinders(ViewModel, self.Binders)
end

function BagTidyListItemView:OnToggle1StateChanged()
	local IsChecked = self.Choose1.CommSingleBox:GetChecked()
	-- 添加防抖机制，避免频繁操作
	if self.UpdateTimer1 then
		_G.TimerMgr:CancelTimer(self.UpdateTimer1)
	end
	self.UpdateTimer1 = self:RegisterTimer(function()
		_G.EventMgr:SendEvent(_G.EventID.BagTidyWinUpdate, {Index = self.Params.Data.Index, IsChecked = IsChecked, SingleBoxIndex = 1})
		self.UpdateTimer1 = nil
	end, 0.1)  -- 100ms防抖延迟
end

function BagTidyListItemView:OnToggle2StateChanged()
	local IsChecked = self.Choose2.CommSingleBox:GetChecked()
	-- 添加防抖机制，避免频繁操作
	if self.UpdateTimer2 then
		_G.TimerMgr:CancelTimer(self.UpdateTimer2)
	end
	self.UpdateTimer2 = self:RegisterTimer(function()
		_G.EventMgr:SendEvent(_G.EventID.BagTidyWinUpdate, {Index = self.Params.Data.Index, IsChecked = IsChecked, SingleBoxIndex = 2})
		self.UpdateTimer2 = nil
	end, 0.1)  -- 100ms防抖延迟
end

function BagTidyListItemView:OnClickBtnGoto()
	local Params = self.Params
	if nil == Params then return end

	if Params.Index == 2 then
		_G.WardrobeMgr:OpenWardrobeMainPanel()
		_G.UIViewMgr:HideView(_G.UIViewID.BagTidyWin)
	elseif Params.Index == 3 then
		_G.UIViewMgr:ShowView(_G.UIViewID.CompanySealMainPanelView, {JumpData = {3}})
		_G.UIViewMgr:HideView(_G.UIViewID.BagTidyWin)
	end
end
function BagTidyListItemView:SetToggleState(Params)
    if not Params then return end

    if Params.Index == 1 then
        self.Choose1.CommSingleBox:SetChecked(Params.IsToggle1Enabled)
        return
    end

    if Params.Index >= 2 and Params.Index <= 4 then
        if Params.SingleBox1Enabled and Params.IsToggle1Enabled then
			self.Choose1.CommSingleBox:SetChecked(Params.IsToggle1Enabled)
		end

        if Params.SingleBox2Enabled and Params.IsToggle2Enabled then
            self.Choose2.CommSingleBox:SetChecked(Params.IsToggle2Enabled)
        end
    end
end

function BagTidyListItemView:ToggleButtonState1Changed()
	if self.Params == nil or self.Params.Data == nil then return end

	local Params = self.Params.Data

	local IsChecked = self.Choose1.CommSingleBox:GetChecked()
	if not Params.SingleBox1Enabled and IsChecked then
		self.Choose1.CommSingleBox:SetChecked(false)
	end
end

function BagTidyListItemView:ToggleButtonState2Changed()
	if self.Params == nil or self.Params.Data == nil then return end

	local Params = self.Params.Data

	local IsChecked = self.Choose2.CommSingleBox:GetChecked()
	if not Params.SingleBox2Enabled and IsChecked then
		self.Choose2.CommSingleBox:SetChecked(false)
	end
end

return BagTidyListItemView