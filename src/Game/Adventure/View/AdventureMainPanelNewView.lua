---
--- Author: sammrli
--- DateTime: 2023-05-12 15:46
--- Description:冒险系统主界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AdventureDefine = require("Game/Adventure/AdventureDefine")
local AdventureMgr = require("Game/Adventure/AdventureMgr")
local AdventureRecommendTaskMgr = require("Game/Adventure/AdventureRecommendTaskMgr")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local ProtoCommon = require("Protocol/ProtoCommon")
local AdventureCareerMgr = require("Game/Adventure/AdventureCareerMgr")
local MajorUtil = require("Utils/MajorUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")

local LSTR = _G.LSTR
local WidgetPoolMgr = require("UI/WidgetPoolMgr")
local UE = _G.UE
local Margin 
local Anchor	

---@class AdventureMainPanelNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bkg CommonBkg01View
---@field CloseBtn CommonCloseBtnView
---@field CommonTitle CommonTitleView
---@field ListItem CommMenuView
---@field MainPanel UFCanvasPanel
---@field ParentNodePanel UFCanvasPanel
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimPanelIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureMainPanelNewView = LuaClass(UIView, true)

function AdventureMainPanelNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bkg = nil
	--self.CloseBtn = nil
	--self.CommonTitle = nil
	--self.ListItem = nil
	--self.MainPanel = nil
	--self.ParentNodePanel = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimPanelIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AdventureMainPanelNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bkg)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.ListItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureMainPanelNewView:OnInit()
	self.DisplayWidget = nil
	self.CurChildWidgetPath = nil
	self.CurSelectMainKey = nil
	Margin = UE.FMargin()
	Margin.Left = 0
	Margin.Top = 0
	Margin.Right = 0
	Margin.Bottom = 0
	
	Anchor = UE.FAnchors()		
	Anchor.Minimum = UE.FVector2D(0, 0)
	Anchor.Maximum = UE.FVector2D(1, 1)
	self.IsDestroy = false
end

local function MakeRecommendTaskTab(Data)
	local Parent = {
		Key = Data.Index, 
		Name = Data.PageName, 
		RedDotID = AdventureDefine.TabNewRed[Data.Index].Tab, 
		RedDotStyle = 1,
		ModuleID =  ProtoCommon.ModuleID.ModuleIDAdviseTask,
		ChildWidget = Data.ChildWidget
	}

	Parent.Children = {}
	for _, value in ipairs(AdventureDefine.RecommendTabs) do
		local TableList = AdventureRecommendTaskMgr:GetRecommendTaskByType(value.Index)
		if not table.is_nil_empty(TableList) and not AdventureRecommendTaskMgr:GetAdventureRecommendFinished(TableList) then
			local Child = {
				Key = Data.Index * 10 + value.Index, 
				Name =  value.PageName, 
				RedDotID = AdventureDefine.TabNewRed[Data.Index].Children[value.Index],
				RedDotStyle = 1,
			}
			table.insert(Parent.Children, Child)
		end
	end

	return Parent
end

local function MakeProfCareerTab(Data)
	local TabData = {
		Key = Data.Index, 
		Name = Data.PageName,
		RedDotID = Data.RedDotID,
		Children = 	AdventureCareerMgr:GetCareerProfMenuChildTab(),
		ModuleID = Data.ModuleID,
		ChildWidget = Data.ChildWidget
	}

	return TabData
end

function AdventureMainPanelNewView:OnShow()
	self.CommonTitle:SetTextTitleName(LSTR(520006))
	self.Tabs = {}
	for _, v in ipairs(AdventureDefine.MainTabs) do
		if v.Index == AdventureDefine.MainTabIndex.RecommendTask then
			table.insert(self.Tabs, MakeRecommendTaskTab(v))
		elseif v.Index == AdventureDefine.MainTabIndex.ProfCareer then
			table.insert(self.Tabs, MakeProfCareerTab(v))
		else
			local ParentData = {
				Key = v.Index, 
				Name = v.PageName,
				ModuleID = v.ModuleID,
				ChildWidget = v.ChildWidget
			}

			if _G.ModuleOpenMgr:CheckOpenState(v.ModuleID) then
				ParentData.RedDotID = v.RedDotID
				ParentData.RedDotStyle = 1
				ParentData.RedDot2ID =  AdventureDefine.TabNewRed[v.Index] and AdventureDefine.TabNewRed[v.Index].Tab
				ParentData.RedDot2Text =  LSTR(520030)
			end

			table.insert(self.Tabs, ParentData)
		end
	end

	self:OnChangeBtnOpenState()				-- 刷新解锁状态
	self.ListItem:UpdateItems(self.Tabs, false)

	local TabIndex = 1
	if self.Params and self.Params.JumpData then
		local ShowTabIndex = self.Params.JumpData[1]
		TabIndex = (not self.Tabs[ShowTabIndex].IsModuleOpen) and ShowTabIndex or 1
	else
		TabIndex = self:OnGetUnlockIndex()
	end

	self.ListItem:SetIsExpansion(AdventureDefine.MainTabIndex.RecommendTask, false)
	self.ListItem:SetSelectedIndex(TabIndex)

	--发送获取挑战笔记所有资源及宝箱信息
	if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDChallengeNote) then
		AdventureMgr:SendChallengeLog(0)
    end
	
	self:RefreshNewTabRed()
end

function AdventureMainPanelNewView:AddChildByType(CurSelectChildWidgetPath, PageParams)
	local function OnComplete(Widget)
		if self and not self.IsDestroy and UE.UCommonUtil.IsObjectValid(self.ParentNodePanel) then
			self:HideCurTypeWidget()
			if Widget and self.SubViews then
				self.ParentNodePanel:AddChildToCanvas(Widget)
				UIUtil.CanvasSlotSetAnchors(Widget, Anchor)
				UIUtil.CanvasSlotSetOffsets(Widget, Margin)
				self:AddSubView(Widget)
				self.DisplayWidget = Widget
			end
		else
			WidgetPoolMgr:RecycleWidget(Widget)
		end
	end

	if not self.CurChildWidgetPath or self.CurChildWidgetPath ~= CurSelectChildWidgetPath or not self.DisplayWidget then
		self.CurChildWidgetPath = CurSelectChildWidgetPath
		WidgetPoolMgr:CreateWidgetAsyncByName(CurSelectChildWidgetPath, nil, OnComplete, true, true, PageParams)
	else
		self.DisplayWidget:UpdateView(PageParams)
	end
end

function AdventureMainPanelNewView:HideCurTypeWidget()
	if self.DisplayWidget then
		self.DisplayWidget:HideView()
		self:RemoveSubView(self.DisplayWidget)
		self.ParentNodePanel:ClearChildren()
		WidgetPoolMgr:RecycleWidget(self.DisplayWidget)
		self.DisplayWidget = nil
	end
end

function AdventureMainPanelNewView:OnDestroy()
	self.DisplayWidget = nil
	self.IsDestroy = true
end

function AdventureMainPanelNewView:OnHide()
	AdventureCareerMgr:UpdateAdventureCareerRed()
	_G.EquipmentMgr:SetPreviewProfID(false, nil)
	self.CurChildWidgetPath = nil
	self.CurSelectMainKey = nil
	self:HideCurTypeWidget()
end

function AdventureMainPanelNewView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.ListItem, self.OnTabItemSelectChanged)
end

function AdventureMainPanelNewView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ModuleOpenGMBtnEvent, self.OnChangeBtnOpenState)
	self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpenNotify)
	
end

--- TableViewTab Index Changed Event
---@param Index number start from 1
function AdventureMainPanelNewView:OnTabItemSelectChanged(Index, ItemData, ItemView, MainKey, SubKey)
	if self.CurSelectMainKey ~= MainKey and self:IsOnMainTabSelectDeal(MainKey, SubKey) then return end

	local JumpData = self.Params and self.Params.JumpData or {}
	local CurSelectChildWidgetPath = self.Tabs[MainKey] and self.Tabs[MainKey].ChildWidget or ""
	local PageParams = {
		Index = Index, 
		MainKey = MainKey, 
		SubKey = SubKey, 
		CurTabData = self.Tabs[MainKey], JumpID = JumpData[2],
		MainView = self
	}

	self:IsShowBgTwoType()
	self:AddChildByType(CurSelectChildWidgetPath, PageParams)
	self:ClearJumpData()
	self.CurSelectMainKey = MainKey
end

function AdventureMainPanelNewView:IsOnMainTabSelectDeal(MainKey ,SubKey)
	local JumpData = self.Params and self.Params.JumpData or {}
	if MainKey == AdventureDefine.MainTabIndex.ProfCareer then
		AdventureCareerMgr:InitProfCareerChildList()
		local FistSelectKey = AdventureCareerMgr:GetCareerFirstSelectKey(JumpData[2])
		if FistSelectKey ~= SubKey then
			self.CurSelectMainKey = MainKey
			self.ListItem:SetSelectedKey(FistSelectKey, true)
			return true
		end
	end

	return false
end

function AdventureMainPanelNewView:ClearJumpData()
	if self.Params and self.Params.JumpData then
		self.Params.JumpData = nil
	end
end

function AdventureMainPanelNewView:OnModuleOpenNotify(ModuleID)
	if ModuleID == ProtoCommon.ModuleID.ModuleIDDailyRand then
		self.Tabs[1].IsModuleOpen = false
	elseif ModuleID == ProtoCommon.ModuleID.ModuleIDChallengeNote then
		self.Tabs[2].IsModuleOpen = false
	elseif ModuleID == ProtoCommon.ModuleID.ModuleIDJobQuest then
		self.Tabs[4].IsModuleOpen = false
	end
end

function AdventureMainPanelNewView:OnChangeBtnOpenState()
	for i = 1, #self.Tabs do
		self.Tabs[i].IsModuleOpen = not _G.ModuleOpenMgr:CheckOpenState(self.Tabs[i].ModuleID)
	end
end

-- 界面打开时初始选中Index 每日随机解锁时返回1   默认选中每日随机
function AdventureMainPanelNewView:OnGetUnlockIndex()
	for i = 1, #self.Tabs do
		if not self.Tabs[i].IsModuleOpen then
			return i
		end
	end

	return 1
end

function AdventureMainPanelNewView:RefreshNewTabRed()
	local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
	for i, v in ipairs(self.Tabs) do
		if _G.ModuleOpenMgr:CheckOpenState(v.ModuleID) then
			local HideNewRed = (v.Key == AdventureDefine.MainTabIndex.Weekly and AdventureMgr:IsStageRewardCanGet())
			if not HideNewRed and AdventureMgr:IsCurTabNotRead(v.Key) then
				RedDotMgr:AddRedDotByID(AdventureDefine.TabNewRed[v.Key].Child)
			end
		end
	end
end

function AdventureMainPanelNewView:IsShowBgTwoType(IsShowBgTwoType)
	UIUtil.SetIsVisible(self.Bkg.PanelBG1, not IsShowBgTwoType)
	UIUtil.SetIsVisible(self.Bkg.PanelBG2, IsShowBgTwoType)
end

return AdventureMainPanelNewView