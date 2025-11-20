---
--- Author: Administrator
--- DateTime: 2025-07-22 15:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")

local FLOG_ERROR = _G.FLOG_ERROR

local MaxSampleIdx = 13 -- 当前最大样例

---@class GoldSauserMainBodyguardBambooItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgErrorFrame UFImage
---@field MI_DX_GoldsauserBodyguard_1 UFImage
---@field PanelTrace1 UFCanvasPanel
---@field PanelTrace10 UFCanvasPanel
---@field PanelTrace11 UFCanvasPanel
---@field PanelTrace12 UFCanvasPanel
---@field PanelTrace13 UFCanvasPanel
---@field PanelTrace2 UFCanvasPanel
---@field PanelTrace3 UFCanvasPanel
---@field PanelTrace4 UFCanvasPanel
---@field PanelTrace5 UFCanvasPanel
---@field PanelTrace6 UFCanvasPanel
---@field PanelTrace7 UFCanvasPanel
---@field PanelTrace8 UFCanvasPanel
---@field PanelTrace9 UFCanvasPanel
---@field TextNumber UFTextBlock
---@field TraceItem1 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_1 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_10 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_11 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_12 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_13 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_14 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_15 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_16 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_17 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_2 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_3 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_4 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_5 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_6 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_7 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_8 GoldSauserMainBodyguardTraceItemView
---@field TraceItem1_9 GoldSauserMainBodyguardTraceItemView
---@field TraceItem4_1 GoldSauserMainBodyguardTraceItemView
---@field TraceItem4_2 GoldSauserMainBodyguardTraceItemView
---@field TraceItem4_3 GoldSauserMainBodyguardTraceItemView
---@field TraceItem4_4 GoldSauserMainBodyguardTraceItemView
---@field TraceItem4_5 GoldSauserMainBodyguardTraceItemView
---@field TraceItem4_6 GoldSauserMainBodyguardTraceItemView
---@field TraceItem4_7 GoldSauserMainBodyguardTraceItemView
---@field AnimWrong UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainBodyguardBambooItemView = LuaClass(UIView, true)

function GoldSauserMainBodyguardBambooItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgErrorFrame = nil
	--self.MI_DX_GoldsauserBodyguard_1 = nil
	--self.PanelTrace1 = nil
	--self.PanelTrace10 = nil
	--self.PanelTrace11 = nil
	--self.PanelTrace12 = nil
	--self.PanelTrace13 = nil
	--self.PanelTrace2 = nil
	--self.PanelTrace3 = nil
	--self.PanelTrace4 = nil
	--self.PanelTrace5 = nil
	--self.PanelTrace6 = nil
	--self.PanelTrace7 = nil
	--self.PanelTrace8 = nil
	--self.PanelTrace9 = nil
	--self.TextNumber = nil
	--self.TraceItem1 = nil
	--self.TraceItem1_1 = nil
	--self.TraceItem1_10 = nil
	--self.TraceItem1_11 = nil
	--self.TraceItem1_12 = nil
	--self.TraceItem1_13 = nil
	--self.TraceItem1_14 = nil
	--self.TraceItem1_15 = nil
	--self.TraceItem1_16 = nil
	--self.TraceItem1_17 = nil
	--self.TraceItem1_2 = nil
	--self.TraceItem1_3 = nil
	--self.TraceItem1_4 = nil
	--self.TraceItem1_5 = nil
	--self.TraceItem1_6 = nil
	--self.TraceItem1_7 = nil
	--self.TraceItem1_8 = nil
	--self.TraceItem1_9 = nil
	--self.TraceItem4_1 = nil
	--self.TraceItem4_2 = nil
	--self.TraceItem4_3 = nil
	--self.TraceItem4_4 = nil
	--self.TraceItem4_5 = nil
	--self.TraceItem4_6 = nil
	--self.TraceItem4_7 = nil
	--self.AnimWrong = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainBodyguardBambooItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.TraceItem1)
	self:AddSubView(self.TraceItem1_1)
	self:AddSubView(self.TraceItem1_10)
	self:AddSubView(self.TraceItem1_11)
	self:AddSubView(self.TraceItem1_12)
	self:AddSubView(self.TraceItem1_13)
	self:AddSubView(self.TraceItem1_14)
	self:AddSubView(self.TraceItem1_15)
	self:AddSubView(self.TraceItem1_16)
	self:AddSubView(self.TraceItem1_17)
	self:AddSubView(self.TraceItem1_2)
	self:AddSubView(self.TraceItem1_3)
	self:AddSubView(self.TraceItem1_4)
	self:AddSubView(self.TraceItem1_5)
	self:AddSubView(self.TraceItem1_6)
	self:AddSubView(self.TraceItem1_7)
	self:AddSubView(self.TraceItem1_8)
	self:AddSubView(self.TraceItem1_9)
	self:AddSubView(self.TraceItem4_1)
	self:AddSubView(self.TraceItem4_2)
	self:AddSubView(self.TraceItem4_3)
	self:AddSubView(self.TraceItem4_4)
	self:AddSubView(self.TraceItem4_5)
	self:AddSubView(self.TraceItem4_6)
	self:AddSubView(self.TraceItem4_7)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainBodyguardBambooItemView:OnInit()
	self.Binders = {
		{"Index", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateItemWhichTracePanelToShow)},
		{"TriggerWrongAnim", UIBinderValueChangedCallback.New(self, nil, self.OnPlayWrongAnim)},
		{"ShowIndex", UIBinderSetText.New(self, self.TextNumber)},
	}
end

function GoldSauserMainBodyguardBambooItemView:OnDestroy()

end

function GoldSauserMainBodyguardBambooItemView:OnShow()

end

function GoldSauserMainBodyguardBambooItemView:OnHide()
	self:StopAllAnimations()
end

function GoldSauserMainBodyguardBambooItemView:OnRegisterUIEvent()

end

function GoldSauserMainBodyguardBambooItemView:OnRegisterGameEvent()

end

function GoldSauserMainBodyguardBambooItemView:OnRegisterBinder()
	local Params = self.Params
	if not Params then
		return
	end
	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function GoldSauserMainBodyguardBambooItemView:OnUpdateItemWhichTracePanelToShow(PanelIndex)
	if not PanelIndex or type(PanelIndex) ~= "number" then
		FLOG_ERROR("GoldSauserMainBodyguardBambooItemView:OnUpdateItemWhichTracePanelToShow PanelIndex is invalid")
		return
	end

	for Index = 1, MaxSampleIdx do
		local WidgetName = string.format("PanelTrace%s", Index)
		local Widget = self[WidgetName]
		if Widget then
			UIUtil.SetIsVisible(Widget, Index == PanelIndex)
		end
	end
	--self.TextNumber:SetText(tostring(PanelIndex))
end

function GoldSauserMainBodyguardBambooItemView:OnPlayWrongAnim(NewValue)
	if NewValue == nil then
		self:StopAnimation(self.AnimWrong)
		return
	end

	self:PlayAnimation(self.AnimWrong)
end

return GoldSauserMainBodyguardBambooItemView