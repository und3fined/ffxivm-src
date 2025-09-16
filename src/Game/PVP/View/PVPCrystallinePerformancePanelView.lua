---
--- Author: Administrator
--- DateTime: 2024-06-03 14:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PVPCrystallinePerformanceVM = require ("Game/PVP/VM/PVPCrystallinePerformanceVM")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local LSTR = _G.LSTR

---@class PVPCrystallinePerformancePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommTabs CommTabsView
---@field DropDownMode CommDropDownListView
---@field DropDownTime CommDropDownListView
---@field FiveEdgePolygonWidget UFiveEdgePolygonWidget
---@field PanelPerformanceDetail UFCanvasPanel
---@field PanelPerformanceDiagram UFCanvasPanel
---@field TableViewExerciseDetail UTableView
---@field TableViewPerformanceDetail UTableView
---@field TableViewRankDetail UTableView
---@field TextCure UFTextBlock
---@field TextEscort UFTextBlock
---@field TextExerciseDetail UFTextBlock
---@field TextInfoDesc UFTextBlock
---@field TextKDA UFTextBlock
---@field TextOutput UFTextBlock
---@field TextRankDetail UFTextBlock
---@field TextSurvival UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPCrystallinePerformancePanelView = LuaClass(UIView, true)

function PVPCrystallinePerformancePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommTabs = nil
	--self.DropDownMode = nil
	--self.DropDownTime = nil
	--self.FiveEdgePolygonWidget = nil
	--self.PanelPerformanceDetail = nil
	--self.PanelPerformanceDiagram = nil
	--self.TableViewExerciseDetail = nil
	--self.TableViewPerformanceDetail = nil
	--self.TableViewRankDetail = nil
	--self.TextCure = nil
	--self.TextEscort = nil
	--self.TextExerciseDetail = nil
	--self.TextInfoDesc = nil
	--self.TextKDA = nil
	--self.TextOutput = nil
	--self.TextRankDetail = nil
	--self.TextSurvival = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPCrystallinePerformancePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommTabs)
	self:AddSubView(self.DropDownMode)
	self:AddSubView(self.DropDownTime)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPCrystallinePerformancePanelView:OnInit()
	self.CommTabs:SetCallBack(self, self.OnTabsChanged)
	self.RankDetailList = UIAdapterTableView.CreateAdapter(self, self.TableViewRankDetail)
	self.ExerciseDetailList = UIAdapterTableView.CreateAdapter(self, self.TableViewExerciseDetail)
	self.PerformanceDetailList = UIAdapterTableView.CreateAdapter(self, self.TableViewPerformanceDetail)
	self.ViewModel = PVPCrystallinePerformanceVM.New()
	self.Binders = {
		{ "RankDetailVMList", UIBinderUpdateBindableList.New(self, self.RankDetailList) },
		{ "ExerciseDetailVMList", UIBinderUpdateBindableList.New(self, self.ExerciseDetailList) },
		{ "PerformanceDetailVMList", UIBinderUpdateBindableList.New(self, self.PerformanceDetailList) },
		{ "ModeFilterList", UIBinderValueChangedCallback.New(self, nil, self.OnModeFilterListChanged) },
		{ "TimeFilterList", UIBinderValueChangedCallback.New(self, nil, self.OnTimeFilterListChanged) },
		{ "ModeFilter", UIBinderValueChangedCallback.New(self, nil, self.UpdatePerformanceDetail) },
		{ "TimeFilter", UIBinderValueChangedCallback.New(self, nil, self.UpdatePerformanceDetail) },
		{ "PerformanceData", UIBinderValueChangedCallback.New(self, nil, self.OnPerformanceDataChanged) },
	}
end

function PVPCrystallinePerformancePanelView:OnDestroy()

end

function PVPCrystallinePerformancePanelView:OnShow()
	self:SetFixText()
	self.ViewModel:ShowData()
end

function PVPCrystallinePerformancePanelView:OnHide()

end

function PVPCrystallinePerformancePanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownMode, self.OnSelectionChangedModeFilter)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownTime, self.OnSelectionChangedTimeFilter)
end

function PVPCrystallinePerformancePanelView:OnRegisterGameEvent()

end

function PVPCrystallinePerformancePanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function PVPCrystallinePerformancePanelView:OnTabsChanged(Index)
	UIUtil.SetIsVisible(self.PanelPerformanceDiagram, Index == 1)
	UIUtil.SetIsVisible(self.PanelPerformanceDetail, Index == 2)

	local Text = Index == 1 and LSTR(130003) or LSTR(130004)
	self.TextInfoDesc:SetText(Text)
end

function PVPCrystallinePerformancePanelView:OnModeFilterListChanged(NewValue, OldValue)
	if NewValue == nil then return end

	self.DropDownMode:UpdateItems(NewValue)
end

function PVPCrystallinePerformancePanelView:OnTimeFilterListChanged(NewValue, OldValue)
	if NewValue == nil then return end

	self.DropDownTime:UpdateItems(NewValue)
end

function PVPCrystallinePerformancePanelView:UpdatePerformanceDetail(NewValue, OldValue)
	self.ViewModel:UpdatePerformanceDetail()
end

function PVPCrystallinePerformancePanelView:OnPerformanceDataChanged(NewValue, OldValue)
	if NewValue == nil then return end

	local EscortTimePercent = NewValue.EscortTimePercent
	local OutputPercent = NewValue.OutputPercent
	local SurvivalPercent = NewValue.SurvivalPercent
	local CurePercent = NewValue.CurePercent
	local KDAPercent = NewValue.KDAPercent
	-- 注意接口数据顺序
	self.FiveEdgePolygonWidget:SetPolygonValue(EscortTimePercent, SurvivalPercent, CurePercent, KDAPercent, OutputPercent)
end

function PVPCrystallinePerformancePanelView:OnSelectionChangedModeFilter(Index, ItemData, ItemView, IsByClick)
	local Data = ItemData.ItemData
	local ModeFilterValue = Data.Mode
	self.ViewModel:SetModeFilter(ModeFilterValue)
end

function PVPCrystallinePerformancePanelView:OnSelectionChangedTimeFilter(Index, ItemData, ItemView, IsByClick)
	local Data = ItemData.ItemData
	local TimeFilterValue = Data.Time
	self.ViewModel:SetTimeFilter(TimeFilterValue)
end

function PVPCrystallinePerformancePanelView:SetFixText()
	self.TextRankDetail:SetText(LSTR(130032))
	self.TextExerciseDetail:SetText(LSTR(130033))
	self.TextEscort:SetText(LSTR(130034))
	self.TextOutput:SetText(LSTR(130035))
	self.TextKDA:SetText(LSTR(130036))
	self.TextCure:SetText(LSTR(130037))
	self.TextSurvival:SetText(LSTR(130038))
end

return PVPCrystallinePerformancePanelView