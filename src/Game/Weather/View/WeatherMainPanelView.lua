---
--- Author: v_hggzhang
--- DateTime: 2023-11-28 16:11
--- Description:
---

-- local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local WeatherMappingCfg = require("TableCfg/WeatherMappingCfg")
local DataReportUtil = require("Utils/DataReportUtil")

local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")

local UIBinderSetSelectedItem = require("Binder/UIBinderSetSelectedItem")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local WeatherDefine = require("Game/Weather/WeatherDefine")

local WeatherVM = nil
---@class NewWeatherMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackBtn CommBackBtnView
---@field BgPanel UFCanvasPanel
---@field BtnTipMask UFButton
---@field CloseBtn CommonCloseBtnView
---@field CloseBtn2 CommBackBtnView
---@field CommonBkg CommonBkg01View
---@field DetailBase UCanvasPanel
---@field DetailsBgPanel UFCanvasPanel
---@field DetailsPanel UFCanvasPanel
---@field ExpandBtn UFButton
---@field FTreeViewArea UFTreeView
---@field FTreeViewArea2 UFTreeView
---@field ImgBg UFImage
---@field ImgDetailsBg UFImage
---@field MaskPanel UFCanvasPanel
---@field TextArea UFTextBlock
---@field TextTitleName UFTextBlock
---@field VerIconTabs CommVerIconTabsView
---@field WeatherAreaTime WeatherAreaTimeItemView
---@field WeatherAreaTime2 WeatherAreaTime2ItemView
---@field WeatherTimeBar WeatherTimeBarItemView
---@field WeatherTips WeatherDetailsItemView
---@field AnimFold UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---@field AnimWeatherTipsIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewWeatherMainPanelView = LuaClass(UIView, true)

function NewWeatherMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackBtn = nil
	--self.BgPanel = nil
	--self.BtnTipMask = nil
	--self.CloseBtn = nil
	--self.CloseBtn2 = nil
	--self.CommonBkg = nil
	--self.DetailBase = nil
	--self.DetailsBgPanel = nil
	--self.DetailsPanel = nil
	--self.ExpandBtn = nil
	--self.FTreeViewArea = nil
	--self.FTreeViewArea2 = nil
	--self.ImgBg = nil
	--self.ImgDetailsBg = nil
	--self.MaskPanel = nil
	--self.TextArea = nil
	--self.TextTitleName = nil
	--self.VerIconTabs = nil
	--self.WeatherAreaTime = nil
	--self.WeatherAreaTime2 = nil
	--self.WeatherTimeBar = nil
	--self.WeatherTips = nil
	--self.AnimFold = nil
	--self.AnimIn = nil
	--self.AnimUnfold = nil
	--self.AnimWeatherTipsIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewWeatherMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CloseBtn2)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.VerIconTabs)
	self:AddSubView(self.WeatherAreaTime)
	self:AddSubView(self.WeatherAreaTime2)
	self:AddSubView(self.WeatherTimeBar)
	self:AddSubView(self.WeatherTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewWeatherMainPanelView:OnInit()
	WeatherVM = _G.WeatherVM
	self.WeatherAreaTime2:SetIsBanner(true)
	self.WeatherAreaTime:SetIsBanner(true)

	WeatherVM.DetailBasePanel = self.DetailBase
	self.AdpWeatherTree 	= UIAdapterTreeView.CreateAdapter(self, self.FTreeViewArea)
	self.AdpWeatherTreeEx 	= UIAdapterTreeView.CreateAdapter(self, self.FTreeViewArea2)
	-- self.WeatherAreaTime2:OnInit()

	self.WeatherBinder = 
	{
		{ "RegoinName", 			UIBinderSetText.New(self, self.CommonTitle.TextSubtitle) },
		{ "IsShowExp",       		UIBinderSetIsVisible.New(self, self.DetailsBgPanel, true) },
		{ "IsShowExp",       		UIBinderSetIsVisible.New(self, self.FTreeViewArea, true) },
		{ "IsShowExp",       		UIBinderSetIsVisible.New(self, self.FTreeViewArea2, nil) },
		{ "SeltRegion", 			UIBinderValueChangedCallback.New(self, nil, self.OnSeltRegionChg) },
		{ "BG",       				UIBinderSetBrushFromAssetPath.New(self, self.ImgBg, false, true) },
		-- -------------------------------------------------------------------------------
		-- { "IsShowExp",       		UIBinderSetIsVisible.New(self, self.CloseBtn, true, true) },
		-- { "IsShowExp",       		UIBinderSetIsVisible.New(self, self.CloseBtn2, true, true) },
		-- { "IsShowExp",       		UIBinderSetIsVisible.New(self, self.BackBtn, nil, true) },
		-------------------------------------------------------------------------------
		-- { "ShowAreaName", 			UIBinderSetText.New(self, self.WeatherAreaTime2.TextRegionCurrent) },
		-- { "IsShowExp",       		UIBinderSetIsVisible.New(self, self.WeatherAreaTime2, nil) },
		{ "IsShowExp",       		UIBinderSetIsVisible.New(self, self.WeatherAreaTime, true) },
		{ "IsShowExp", 				UIBinderValueChangedCallback.New(self, nil, self.OnBindIsExpand) },
		-------------------------------------------------------------------------------
		-- { "IsShowDetail",       	UIBinderValueChangedCallback.New(self, nil, self.WeatherTips) },
	}

	self.SeltRegionBinder = 
	{
		{ "Areas", UIBinderUpdateBindableList.New(self, self.AdpWeatherTree) },
	}

	self.SeltRegionExBinder = 
	{
		{ "Areas", UIBinderUpdateBindableList.New(self, self.AdpWeatherTreeEx) },
	}

end

function NewWeatherMainPanelView:OnDestroy()

end

function NewWeatherMainPanelView:OnShow()

	DataReportUtil.ReportSystemFlowData("WeatherSystemInfo", 1, (self.Params or {}).Source or WeatherDefine.Source.Default)

	local _ <close> = CommonUtil.MakeProfileTag("[Weather][MainView][OnShow]")

	WeatherVM:UpdateVM()

	local ListData = WeatherVM.RegionTabData
	local CurMapID = _G.PWorldMgr:GetCurrMapResID()
	local MappingID = WeatherMappingCfg:FindValue(CurMapID, "Mapping") or CurMapID
	local Rlt = 1
    local WeatherData = WeatherVM.WeatherData
	if WeatherData then
		for Idx, Region in pairs(WeatherData) do
			for _, Area in pairs(Region.Areas) do
				for _, Map in pairs(Area.Maps) do
					if Map.MapID == MappingID then
						Rlt = Idx
					end
				end

			end

		end
	end

	-- _G.FLOG_INFO(string.format('[Weather][MainView][OnShow] Map = %s, Idx = %s, WeatherData',
	-- 	tostring(CurMapID)
	-- 	,tostring(Rlt)
	-- 	-- ,table.tostring(WeatherData)
	-- ))

	self.VerIconTabs:UpdateItems(ListData, Rlt)

	self:PlayAnimation(self.AnimIn)

	--
	-- self.CommonTitle:SetTextTitleName(LSTR(620045))

	self.CommonTitle:SetTextTitleName(_G.LSTR(610001))
end

function NewWeatherMainPanelView:OnHide()
	self:Clear()
	self:PlayAnimation(self.AnimFold, 0.7)
end

function NewWeatherMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, 				self.ExpandBtn, 			self.OnExpBtn)
	UIUtil.AddOnClickedEvent(self, 				self.BackBtn.Button, 		self.OnBackBtn)
	-- UIUtil.AddOnClickedEvent(self, 				self.BtnTime, 				self.OnBtnTimeNext)
	UIUtil.AddOnClickedEvent(self, 				self.CloseBtn2.Button, 	 	self.Hide)
	UIUtil.AddOnSelectionChangedEvent(self, 	self.VerIconTabs, 			self.OnTabChg)
end

function NewWeatherMainPanelView:OnRegisterTimer()
	-- self:RegisterTimer(self.OnTimer, 0, 0.2, 0)
end

function NewWeatherMainPanelView:OnTimer()
end

function NewWeatherMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.WeatherMainUIExp, self.OnEveExp)
	self:RegisterGameEvent(_G.EventID.WeatherArrowBallAnimFinished, self.OnEveArrowBallAnimFinished)
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnEveMouseDown)
end

function NewWeatherMainPanelView:OnRegisterBinder()
	self:RegisterBinders(WeatherVM, 				self.WeatherBinder)
	self:RegisterBinders(WeatherVM.SeltRegionEx, 	self.SeltRegionExBinder)
end

-------------------------------------------------------------------------------------------------------
---@see VMHandle

function NewWeatherMainPanelView:OnSeltRegionChg(New, Old)

	if self:IsAnimationPlaying(self.AnimFold) or self:IsAnimationPlaying(self.AnimUnFold) then
		return
	end

	if Old then
		self:UnRegisterBinders(Old, self.SeltRegionBinder)
	end

	if New then
		self:RegisterBinders(New, self.SeltRegionBinder)
	end

	self.AdpWeatherTree:ScrollToTop()
	self.AdpWeatherTreeEx:ScrollToTop()
end

function NewWeatherMainPanelView:OnBindIsExpand(New, Old)
	if New == true then
		self:PlayAnimation(self.AnimWeatherTipsIn)
		local Idx = self.AdpWeatherTree.Widget:GetScrollOffset()
		self.AdpWeatherTreeEx.Widget:SetScrollOffset(Idx)

	else
		-- todo play inpand state

		local Idx = self.AdpWeatherTreeEx.Widget:GetScrollOffset()
		self.AdpWeatherTree.Widget:SetScrollOffset(Idx)
	end

	if not New then
		UIUtil.SetIsVisible(self.BackBtn, false)
		if self.Params and self.Params.Source == WeatherDefine.Source.Map then
			UIUtil.SetIsVisible(self.CloseBtn, false)
			UIUtil.SetIsVisible(self.CloseBtn2, true, true)
		else
			UIUtil.SetIsVisible(self.CloseBtn2, false)
			UIUtil.SetIsVisible(self.CloseBtn, true, true)
		end
	else
		UIUtil.SetIsVisible(self.CloseBtn2, false)
		UIUtil.SetIsVisible(self.CloseBtn, false)
		UIUtil.SetIsVisible(self.BackBtn, true, true)
	end

	if New then
		UIUtil.SetIsVisible(self.WeatherAreaTime2, true)
	end

	-- _G.FLOG_INFO('[Weather][NewWeatherMainPanelView][OnBindIsExpand] Idx = ' .. tostring(Idx))
end

-------------------------------------------------------------------------------------------------------
---@see UIEveHandle

function NewWeatherMainPanelView:OnExpBtn()
    local _ <close> = CommonUtil.MakeProfileTag("[Weather][NewWeatherMainPanelView][OnExpBtn]")
	WeatherVM:SetShowExp(true)
	_G.EventMgr:SendEvent(_G.EventID.WeatherMainUIExp, true)
end

function NewWeatherMainPanelView:OnBackBtn()
	WeatherVM:SetShowExp(false)
	_G.EventMgr:SendEvent(_G.EventID.WeatherMainUIExp, false)
end

-- function NewWeatherMainPanelView:OnBtnTimeNext()
-- 	WeatherVM:NextTimeTy()
-- end

function NewWeatherMainPanelView:OnTabChg(Idx)
    local _ <close> = CommonUtil.MakeProfileTag("[Weather][NewWeatherMainPanelView][OnTabChg]")
	_G.EventMgr:SendEvent(_G.EventID.WeatherMainUIDSeltIdxChg, Idx)
	WeatherVM:SetSeltRegionIdx(Idx)
	self:GC()
end

function NewWeatherMainPanelView:GC()
    local _ <close> = CommonUtil.MakeProfileTag("[Weather][NewWeatherMainPanelView][GC]")
	if CommonUtil.IsIOSPlatform() then
		_G.ObjectMgr:CollectGarbage(false)
	else
		self.TabChgCount = (self.TabChgCount or 0) + 1
		-- 每三次做一次GC
		if self.TabChgCount >= 3 then
			_G.ObjectMgr:CollectGarbage(false)
			self.TabChgCount = 0
		end
	end
end

function NewWeatherMainPanelView:Clear()
	_G.WeatherVM:Clear()
    self:GC()
end

-------------------------------------------------------------------------------------------------------
---@see EveHdl

function NewWeatherMainPanelView:OnEveMouseDown()
	_G.FLOG_INFO('[Weather][NewWeatherMainPanelView][OnEveMouseDown]')
	_G.UIViewMgr:HideView(_G.UIViewID.WeatherForecastTips)
end

function NewWeatherMainPanelView:OnEveExp(IsExp)
	if IsExp then
		self:StopAnimation(self.AnimFold)
		self:PlayAnimation(self.AnimUnfold)
	else
		self:StopAnimation(self.AnimUnfold)
		self:PlayAnimation(self.AnimFold)
	end
end

function NewWeatherMainPanelView:OnEveArrowBallAnimFinished()
	_G.FLOG_INFO('[Weather][NewWeatherMainPanelView][OnEveArrowBallAnimFinished]')
	self.FTreeViewArea2:RequestRefresh()
end


return NewWeatherMainPanelView