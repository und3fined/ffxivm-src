---
--- Author: Administrator
--- DateTime: 2025-07-08 10:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local LSTR = _G.LSTR

local UE = _G.UE
local Anchor = UE.FAnchors()
Anchor.Minimum = UE.FVector2D(0.5, 0.5)
Anchor.Maximum = UE.FVector2D(0.5, 0.5)
local Alignment = UE.FVector2D(0.5, 0.5)
local Margin = UE.FMargin()
Margin.Left = 0
Margin.Top = 0
Margin.Right = 700
Margin.Bottom = 540

---@class PVPCrystallineRankRecordItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field PanelRank UFCanvasPanel
---@field RichTextSeasonTime URichTextBox
---@field TextRank UFTextBlock
---@field TextSeason UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPCrystallineRankRecordItemView = LuaClass(UIView, true)

function PVPCrystallineRankRecordItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.PanelRank = nil
	--self.RichTextSeasonTime = nil
	--self.TextRank = nil
	--self.TextSeason = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPCrystallineRankRecordItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPCrystallineRankRecordItemView:OnInit()
	

	

	self.Binders = {
		{ "Season", UIBinderSetTextFormat.New(self, self.TextSeason, LSTR(130096)) },
		{ "SeasonTime", UIBinderSetText.New(self, self.RichTextSeasonTime) },
		{ "RankName", UIBinderSetText.New(self, self.TextRank) },
		{ "RankBP", UIBinderValueChangedCallback.New(self, nil, self.OnRankBPChanged) },
		{ "BG", UIBinderSetBrushFromAssetPath.New(self, self.ImgBg) },
	}
end

function PVPCrystallineRankRecordItemView:OnDestroy()

end

function PVPCrystallineRankRecordItemView:OnShow()

end

function PVPCrystallineRankRecordItemView:OnHide()

end

function PVPCrystallineRankRecordItemView:OnRegisterUIEvent()

end

function PVPCrystallineRankRecordItemView:OnRegisterGameEvent()

end

function PVPCrystallineRankRecordItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then return end

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function PVPCrystallineRankRecordItemView:OnRankBPChanged(NewValue, OldValue)
	if not string.isnilorempty(NewValue) then
		local function OnComplete(Widget)
			if Widget then
				if UE.UCommonUtil.IsObjectValid(self.PanelRank) then
					self.PanelRank:AddChildToCanvas(Widget)
					UIUtil.CanvasSlotSetAnchors(Widget, Anchor)
					UIUtil.CanvasSlotSetAlignment(Widget, Alignment)
					UIUtil.CanvasSlotSetOffsets(Widget, Margin)
					self:AddSubView(Widget)
				else
					WidgetPoolMgr:RecycleWidget(Widget)
				end
			end
		end

		WidgetPoolMgr:CreateWidgetAsyncByName(NewValue, nil, OnComplete, true, true)
	end
end

return PVPCrystallineRankRecordItemView