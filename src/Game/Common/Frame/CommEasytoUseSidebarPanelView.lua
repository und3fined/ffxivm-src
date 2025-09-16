---
--- Author: Administrator
--- DateTime: 2025-02-25 10:58
--- Description:带侧边选择LIST的通用侧边栏
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SideBarDefine = require("Game/Common/Frame/Define/CommonSelectSideBarDefine")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")
local DataReportUtil = require("Utils/DataReportUtil")
local UE = _G.UE
local Margin
local Anchor
local DefaultSize = 850

---@class CommEasytoUseSidebarPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSidebarFrame CommEasytoUseSidebarFrameView
---@field ParentSlotPanel UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommEasytoUseSidebarPanelView = LuaClass(UIView, true)

function CommEasytoUseSidebarPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSidebarFrame = nil
	--self.ParentSlotPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommEasytoUseSidebarPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSidebarFrame)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommEasytoUseSidebarPanelView:OnInit()
	self.CurSelectType = nil
	self.DisplayWidget = nil
	Margin = UE.FMargin()
	Margin.Left = 0
	Margin.Top = 0
	Margin.Right = 0
	Margin.Bottom = 0

	Anchor = UE.FAnchors()
	Anchor.Minimum = UE.FVector2D(0, 0)
	Anchor.Maximum = UE.FVector2D(1, 1)
end

function CommEasytoUseSidebarPanelView:OnShow()
	local Params = self.Params or {}  --- 其他页面需要内容也可存在Params.PageParams 见 self:AddChildByType()
	local ClickSelectCallback = function(InIndex, ItemData, ItemView)
		self:OnTabBtnClickSelectType(InIndex, ItemData, ItemView)
	end

	local PanelType = Params.PanelType or SideBarDefine.PanelType.EasyToUse
	self.CurPanelType = PanelType
	self.CommSidebarFrame:SetSidebarSize(SideBarDefine.PanelSize[PanelType] or DefaultSize)
	self.CommSidebarFrame:SetTabSideBarSelectCallBack(ClickSelectCallback)
	local ShowTabData = self:GetSideBarShowDataByType(PanelType)
	self.CommSidebarFrame:SetTabSideBarData(ShowTabData,  Params.ShowTabType or 1)
end

function CommEasytoUseSidebarPanelView:GetSideBarShowDataByType(PanelType)
	local SideBarData = SideBarDefine.PanelTabData[PanelType] or {}
	local ShowData = {}
	for i, v in ipairs(SideBarData) do
		if not v.TabIsShowFunc or v.TabIsShowFunc() then
			table.insert(ShowData, v)
		end
	end

	return ShowData
end

function CommEasytoUseSidebarPanelView:OnTabBtnClickSelectType(InIndex, ItemData, ItemView)
	if table.is_nil_empty(ItemData) then
		FLOG_ERROR(" ItemData Nil or Empty Check CommonSelectSideBarDefine Config")
		return
	end

	if ItemData.IsLock then
		_G.ModuleOpenMgr:ModuleState(ItemData.ModuleID)
		return
	end


	if self.CurPanelType == SideBarDefine.PanelType.EasyToUse then
		if self.Params and self.Params.PageParams then
			if self.Params.PageParams.bOpen then
				DataReportUtil.ReportEasyUseFlowData(1, ItemData.Type)
			else
				DataReportUtil.ReportEasyUseFlowData(2, ItemData.Type, self.CurSelectType)
			end
			self.Params.PageParams.bOpen = false
		end
	end
	if ItemData.Type == SideBarDefine.EasyToUseTabType.Mount then
		DataReportUtil.ReportMountInterSystemFlowData(1, 2)
	end
	if not self.CurSelectType or self.CurSelectType ~= ItemData.Type then
		self.CurSelectType = ItemData.Type
		self:AddChildByType(ItemData)
		self.CommSidebarFrame:SetTitleText(ItemData.Title)
		self.CommSidebarFrame:SetHelpInfoID(ItemData.HelpInfoID)
		self.CommSidebarFrame:SetHelpInfoCallback(ItemData.HelpInfoViewID)
	end
end

function CommEasytoUseSidebarPanelView:AddChildByType(TabData)
	local function OnComplete(Widget)
		if UE.UCommonUtil.IsObjectValid(self.ParentSlotPanel) then
			self:HideCurTypeWidget()
			if Widget then
				self.ParentSlotPanel:AddChildToCanvas(Widget)
				UIUtil.CanvasSlotSetAnchors(Widget, Anchor)
				UIUtil.CanvasSlotSetOffsets(Widget, Margin)
				self:AddSubView(Widget)
				self.DisplayWidget = Widget
			end
		else
			WidgetPoolMgr:RecycleWidget(Widget)
		end
	end

	if not string.isnilorempty(TabData.ChildWidget) then
		local Params = self.Params and self.Params.PageParams or {}
		Params.TabData = TabData
		WidgetPoolMgr:CreateWidgetAsyncByName(TabData.ChildWidget, nil, OnComplete, true, true, Params)
	end
end

function CommEasytoUseSidebarPanelView:HideCurTypeWidget()
	if self.DisplayWidget then
		self.DisplayWidget:HideView()
		self:RemoveSubView(self.DisplayWidget)
		self.ParentSlotPanel:ClearChildren()
		WidgetPoolMgr:RecycleWidget(self.DisplayWidget)
		self.DisplayWidget = nil
	end
end

function CommEasytoUseSidebarPanelView:OnHide()
	self:HideCurTypeWidget()

	if self.CurPanelType == SideBarDefine.PanelType.MapSetting then
		-- 地图侧边栏界面关闭时需要重置部分状态
		_G.WorldMapVM:SetMapSettingPanelVisible(false)
	end
	self.CurPanelType = nil
	self.CurSelectType = nil
end

return CommEasytoUseSidebarPanelView