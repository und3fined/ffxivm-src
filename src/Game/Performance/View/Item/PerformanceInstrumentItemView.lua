---
--- Author: moodliu
--- DateTime: 2023-11-20 19:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PerformanceInstrumentItemVM = require("Game/Performance/VM/PerformanceInstrumentItemVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")

---@class PerformanceInstrumentItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInstrument UFButton
---@field ImgIcon UImage
---@field ImgInstrument UFImage
---@field PanelFavor UFCanvasPanel
---@field PanelSelected UFCanvasPanel
---@field TextName UFTextBlock
---@field AnimChencked UWidgetAnimation
---@field AnimUnChencked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceInstrumentItemView = LuaClass(UIView, true)

function PerformanceInstrumentItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInstrument = nil
	--self.ImgIcon = nil
	--self.ImgInstrument = nil
	--self.PanelFavor = nil
	--self.PanelSelected = nil
	--self.TextName = nil
	--self.AnimChencked = nil
	--self.AnimUnChencked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceInstrumentItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceInstrumentItemView:OnInit()
	self.InstrumentIndex = 0
	self.VM = PerformanceInstrumentItemVM.New()
	self.ParentView = _G.UIViewMgr:FindVisibleView(_G.UIViewID.MusicPerformanceSelectPanelView)
end

function PerformanceInstrumentItemView:OnDestroy()

end

function PerformanceInstrumentItemView:OnShow()
	self:PlayAnimation(self.AnimUnChencked)
	self:UpdateItemView()
end

function PerformanceInstrumentItemView:OnHide()
end

function PerformanceInstrumentItemView:UpdateItemView()
	self.VM:SetData(self.Params.Data)
	if self.ParentView then
		self.VM.AnimChencked = self.Params.Data.ID == self.ParentView.VM.SelectedID
		self.VM.SelectedVisible = self.Params.Data.ID == self.ParentView.VM.SelectedID
		if self.VM.AnimChencked then
			self.ParentView.PrevSelectedView = self
		end
	end
end

function PerformanceInstrumentItemView:OnBtnInstrumentClicked()
	EventMgr:SendEvent(EventID.MusicPerformanceUISelect, self)
end

function PerformanceInstrumentItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnInstrument, self.OnBtnInstrumentClicked)
end

function PerformanceInstrumentItemView:OnRegisterGameEvent()

end

function PerformanceInstrumentItemView:OnRegisterBinder()
	local Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "FavorVisible", UIBinderSetIsVisible.New(self, self.PanelFavor) },
		{ "SelectedVisible", UIBinderSetIsVisible.New(self, self.PanelSelected) },
		{ "AnimChencked", UIBinderValueChangedCallback.New(self, nil, self.OnAnimChenckedChanged) },
		--{ "TypeName", UIBinderSetText.New(self, self.TextType) },

		{ "BigIconPath", UIBinderSetImageBrush.New(self, self.ImgInstrument) },
		{ "SmallIconPath", UIBinderSetImageBrush.New(self, self.ImgIcon) },
	}

	self:RegisterBinders(self.VM, Binders)
end

function PerformanceInstrumentItemView:OnAnimChenckedChanged(IsCheck, PrevIsCheck)
	self:StopAllAnimations()
	if IsCheck then
		self:PlayAnimation(self.AnimChencked)
	elseif PrevIsCheck ~= nil then
		self:PlayAnimation(self.AnimUnChencked)
	end
end

return PerformanceInstrumentItemView