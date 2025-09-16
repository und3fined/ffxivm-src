---
--- Author: Administrator
--- DateTime: 2024-12-11 16:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local BattlePassMainVM = require("Game/BattlePass/VM/BattlePassMainVM")
local BattlePassDefine = require("Game/BattlePass/BattlePassDefine")
local BattlePassMgr = require("Game/BattlePass/BattlePassMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local BattlepassGlobalCfg = require("TableCfg/BattlepassGlobalCfg")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")

local DataReportUtil = require("Utils/DataReportUtil")

local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local Margin 
local Anchor
local UE = _G.UE

---@class BattlePassMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdvanced UFButton
---@field BtnBuyLevel CommBtnSView
---@field BtnClose CommonCloseBtnView
---@field BtnGetAll CommBtnMView
---@field BtnShop UFButton
---@field BtnUpgradeBP CommBtnMView
---@field CommMoneyBar CommMoneyBarView
---@field CommonBkg02 CommonBkg02View
---@field CommonBkgMask CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field EffProBar UFCanvasPanel
---@field EffProBarGrop UFCanvasPanel
---@field FCanvasPanel UFCanvasPanel
---@field FCanvasPanel_155 UFCanvasPanel
---@field PanelBattlePass UFCanvasPanel
---@field PanelBigReward UFCanvasPanel
---@field PanelMain UFCanvasPanel
---@field PanelPassContent UFCanvasPanel
---@field PanelTask UFCanvasPanel
---@field PanelUnLock UFCanvasPanel
---@field ProBarExp UFProgressBar
---@field RewardSlot01 BattlePassRewardSlotView
---@field RewardSlot02 BattlePassRewardSlotView
---@field TableViewReward UTableView
---@field Tabs CommVerIconTabsView
---@field TextAdvanced UFTextBlock
---@field TextCountDown UFTextBlock
---@field TextExp UFTextBlock
---@field TextLevel UFTextBlock
---@field TextLevel02 UFTextBlock
---@field TextMaxLevel UFTextBlock
---@field TextNormalPass UFTextBlock
---@field TextShop UFTextBlock
---@field AnimGrandPrizeIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimlPassContentIn UWidgetAnimation
---@field AnimProBar UWidgetAnimation
---@field AnimProBarControl UWidgetAnimation
---@field ValueAnimProbarStart float
---@field ValueAnimProbarEnd float
---@field CurveAnimProgressBar CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassMainView = LuaClass(UIView, true)

function BattlePassMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdvanced = nil
	--self.BtnBuyLevel = nil
	--self.BtnClose = nil
	--self.BtnGetAll = nil
	--self.BtnShop = nil
	--self.BtnUpgradeBP = nil
	--self.CommMoneyBar = nil
	--self.CommonBkg02 = nil
	--self.CommonBkgMask = nil
	--self.CommonTitle = nil
	--self.EffProBar = nil
	--self.EffProBarGrop = nil
	--self.FCanvasPanel = nil
	--self.FCanvasPanel_155 = nil
	--self.PanelBattlePass = nil
	--self.PanelBigReward = nil
	--self.PanelMain = nil
	--self.PanelPassContent = nil
	--self.PanelTask = nil
	--self.PanelUnLock = nil
	--self.ProBarExp = nil
	--self.RewardSlot01 = nil
	--self.RewardSlot02 = nil
	--self.TableViewReward = nil
	--self.Tabs = nil
	--self.TextAdvanced = nil
	--self.TextCountDown = nil
	--self.TextExp = nil
	--self.TextLevel = nil
	--self.TextLevel02 = nil
	--self.TextMaxLevel = nil
	--self.TextNormalPass = nil
	--self.TextShop = nil
	--self.AnimGrandPrizeIn = nil
	--self.AnimIn = nil
	--self.AnimlPassContentIn = nil
	--self.AnimProBar = nil
	--self.AnimProBarControl = nil
	--self.ValueAnimProbarStart = nil
	--self.ValueAnimProbarEnd = nil
	--self.CurveAnimProgressBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuyLevel)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnGetAll)
	self:AddSubView(self.BtnUpgradeBP)
	self:AddSubView(self.CommMoneyBar)
	self:AddSubView(self.CommonBkg02)
	self:AddSubView(self.CommonBkgMask)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.RewardSlot01)
	self:AddSubView(self.RewardSlot02)
	self:AddSubView(self.Tabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassMainView:OnInit()
	self.ViewModel = BattlePassMainVM
	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewReward)
	self.CurTabIndex = nil
	self.IsForward = true
	self.LastScrollValue = 0

	self.CurTaskToggleIndex = BattlePassDefine.TaskType.Weekly
	self.CurTabIndex = BattlePassDefine.TabIndex.LevelReward
	self.CurWeekIndex = 0
	self.bGo = true

	Margin = UE.FMargin()
	Margin.Left = 0
	Margin.Top = 0
	Margin.Right = 0
	Margin.Bottom = 0
	
	Anchor = UE.FAnchors()		
	Anchor.Minimum = UE.FVector2D(0, 0)
	Anchor.Maximum = UE.FVector2D(1, 1)
end

function BattlePassMainView:OnDestroy()
	self.DisplayWidget = nil
end

function BattlePassMainView:OnViewHide()
	-- BattlePassMgr:SendBattlePassTaskReq(BattlePassDefine.TaskType.All)
end

function BattlePassMainView:OnShow()
	UIUtil.SetIsVisible(self.FCanvasPanel, _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBattlePass) and _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_PASSPORT))

	self:InitTab()
	self:InitMoneyBar()
	BattlePassMgr:SendBattlePassStateReq()
	self:InitText()
end

function BattlePassMainView:AddChildByType(ParentWidget, CurSelectChildWidgetPath, PageParams)
	local function OnComplete(Widget)
		if self and ParentWidget and UE.UCommonUtil.IsObjectValid(ParentWidget) then
			self:HideCurTypeWidget()
			if Widget and self.SubViews then
				ParentWidget:AddChildToCanvas(Widget)
				self.ParentNodePanel = ParentWidget
				UIUtil.CanvasSlotSetAnchors(Widget, Anchor)
				UIUtil.CanvasSlotSetOffsets(Widget, Margin)
				self:AddSubView(Widget)
				self.DisplayWidget = Widget
				self.CurChildWidgetPath = CurSelectChildWidgetPath
			end
		else
			WidgetPoolMgr:RecycleWidget(Widget)
		end
	end

	if not self.CurChildWidgetPath or self.CurChildWidgetPath ~= CurSelectChildWidgetPath or not self.DisplayWidget then
		WidgetPoolMgr:CreateWidgetAsyncByName(CurSelectChildWidgetPath, nil, OnComplete, true, true, PageParams)
	else 
		self.DisplayWidget:UpdateView(PageParams)
	end
end

function BattlePassMainView:HideCurTypeWidget()
	if self.DisplayWidget then
		self.DisplayWidget:HideView()
		self:RemoveSubView(self.DisplayWidget)
		self.PanelTask:ClearChildren()
		self.PanelBigReward:ClearChildren()
		WidgetPoolMgr:RecycleWidget(self.DisplayWidget)
		self.DisplayWidget = nil
	end
end

function BattlePassMainView:OnHide()
	if self.BattleRemainTimer ~= nil then
		self:UnRegisterTimer(self.BattleRemainTimer)
		self.BattleRemainTimer = nil
	end
	if self.BattlePassDataValidTimer ~= nil then
		self:UnRegisterTimer(self.BattlePassDataValidTimer)
		self.BattlePassDataValidTimer = nil
	end
	if self.BattleRemainWeekTimer ~= nil then
		self:UnRegisterTimer(self.BattleRemainWeekTimer)
		self.BattleRemainWeekTimer = nil
	end

	self.CurChildWidgetPath = nil
	self.CurSelectMainKey = nil
	self:HideCurTypeWidget()
end

function BattlePassMainView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnShop, self.OnClickedBattlePassShopBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnBuyLevel.Button, self.OnClickedBuyLevelBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnGetAll.Button, self.OnClickedGetAllBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnUpgradeBP.Button, self.OnClickedUpgradeBPBtn)
	UIUtil.AddOnSelectionChangedEvent(self, self.Tabs, self.OnCommVerIconTabsChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnAdvanced, self.OnClickedAdvanceBtn)
	UIUtil.AddOnScrolledEvent(self, self.TableViewReward, self.OnLevelRewardScrolled)

end

function BattlePassMainView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BattlePassBaseInfoUpdate, self.OnBattlePassBaseInfoUpdate)
	self:RegisterGameEvent(EventID.BattlePassExpUpdate, self.OnBattlePassExpUpdate)
	self:RegisterGameEvent(EventID.BattlePassLevelRewardUpdate, self.OnBattlePassLevelRewardUpdate)
	self:RegisterGameEvent(EventID.BattlePassLevelRewardItemShow, self.OnLevelRewardItemShow)
	self:RegisterGameEvent(EventID.BattlePassLevelRewardItemHide, self.OnLevelRewardItemHide)
end

function BattlePassMainView:OnRegisterBinder()
	local Binders = {
		{"SubTitle", UIBinderSetText.New(self, self.CommonTitle.TextSubtitle)},
		{"CountDown", UIBinderSetText.New(self, self.TextCountDown)},
		{"MaxLevelVisible", UIBinderSetIsVisible.New(self, self.BtnBuyLevel, true)},
		{"MaxLevelVisible", UIBinderSetIsVisible.New(self, self.TextMaxLevel)},
		{"Level", UIBinderSetText.New(self, self.TextLevel)},
		{"Exp", UIBinderSetText.New(self, self.TextExp)},
		{"ExpPercent", UIBinderSetPercent.New(self, self.ProBarExp)},
		{"GradeLockVisible", UIBinderSetIsVisible.New(self, self.PanelUnLock, true)},
		{"BigRewardLevel", UIBinderSetText.New(self, self.TextLevel02)},
		{"GetAllBtnVisible",UIBinderSetIsVisible.New(self, self.BtnGetAll)},
		{"UpgradeBPVisible", UIBinderSetIsVisible.New(self, self.BtnUpgradeBP)},
		{"UpgradeBPText", UIBinderSetText.New(self, self.BtnUpgradeBP)},
		{"Grade", UIBinderSetText.New(self, self.TextAdvanced)},
		{"LevelRewardList", UIBinderUpdateBindableList.New(self, self.RewardListAdapter)},
	}

	self:RegisterBinders(self.ViewModel, Binders)
	self.RewardSlot01:SetParams({Data = self.ViewModel.BigReward1})
	self.RewardSlot02:SetParams({Data = self.ViewModel.BigReward2})
end

function BattlePassMainView:OnBattlePassExpUpdate(Params)
	local CurLevel = BattlePassMgr:GetBattlePassLevel()
    local TotalExp = BattlePassMgr:GetBattlePasslLevelUpNeedExp(CurLevel)
	local NewExp = Params.NewExp
	local IsLevelUp = Params.IsLevelUp
	local NoPlayAnim = Params.NoPlayAnim

	self:UpdateBuyBtnState()

	if NoPlayAnim then
		self.ViewModel:UpdateLevelValue(NewExp)
		return
	end

	-- 已经满级
	local EndPercent = TotalExp == 0 and 1 or NewExp/TotalExp
	if IsLevelUp then
		self:PlayAnimProBar(self.ProBarExp.Percent, 1)
		self:RegisterTimer(function ()
			--清空
			self.ProBarExp.Percent = 0
			self:PlayAnimProBar(0, EndPercent)
			--更新数值
			self.ViewModel:UpdateLevelValue(NewExp)
		end, self.AnimProBar:GetEndTime())
	else
		self:PlayAnimProBar(self.ProBarExp.Percent, EndPercent)
		self.ViewModel:UpdateLevelValue(NewExp)
	end
end

function BattlePassMainView:InitTab()
	local List = BattlePassDefine.TabList
	self.List = {}
	for _, v in ipairs(List) do
		if v.RedDotID ~= nil then
			v.RedDotType = RedDotDefine.RedDotStyle.NormalStyle
			v.RedDotData = {}
			v.RedDotData.RedDotName = _G.RedDotMgr:GetRedDotNameByID(v.RedDotID)
			v.RedDotData.IsStrongReminder = true
		end
		table.insert(self.List, v)
	end
	self.Tabs:UpdateItems(BattlePassDefine.TabList, 1)
end

function BattlePassMainView:InitText()
	self.TextNormalPass:SetText(_G.LSTR(850021)) -- 基础战令
	self.TextShop:SetText(_G.LSTR(850020))  -- 战令商店
	self.BtnBuyLevel:SetText(_G.LSTR(850042)) --购买等级
	self.BtnGetAll:SetText(_G.LSTR(850041)) --一键领取
	self.CommonTitle.TextTitleName:SetText(_G.LSTR(850019)) -- 战令
	self.TextMaxLevel:SetText(_G.LSTR(850108)) --已满级
	self.CommonTitle.CommInforBtn.HelpInfoID = 10015
end

function BattlePassMainView:InitMoneyBar()
	local Widget = self.CommMoneyBar
	UIUtil.SetIsVisible(Widget.Money1, true)
	UIUtil.SetIsVisible(Widget.Money2,  true )
	UIUtil.SetIsVisible(Widget.Money3,  false)
	
	Widget.Money1:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS, true, _G.UIViewID.StoreNewMainPanel, true)
	Widget.Money2:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_BATTLE_PASS_MEDAL, false, _G.UIViewID.MarketExchangeWin, true)
end

function BattlePassMainView:UpdateBuyBtnState()
	local MaxLevel = BattlePassMgr:GetBattlePassMaxLevel()
	local CurLevel = BattlePassMgr:GetBattlePassLevel()
	local CfgReward = BattlepassGlobalCfg:FindCfgByKey(ProtoRes.BattlePassGlobalParamType.BattlePassGlobalParamTypeBuyLevelMax)
	if  CfgReward ~= nil then
		MaxLevel =  CfgReward.Value[1]
	end

	if CurLevel >= MaxLevel then
		self.BtnBuyLevel:SetIsDisabledState(true, true)
	else
		self.BtnBuyLevel:SetIsRecommendState(true)
	end
end

function BattlePassMainView:OnCommVerIconTabsChanged(Index, ItemData, ItemView)
	self.CurTabIndex = Index
	self.ViewModel.SubTitle = BattlePassDefine.TabList[Index].Name
	self.ViewModel.ContentVisible = not (Index == BattlePassDefine.TabIndex.BigReward)
	self.ViewModel.RewardsVisible = Index ~= BattlePassDefine.TabIndex.BigReward and Index == BattlePassDefine.TabIndex.LevelReward
	self.ViewModel:UpdateBtnState(Index)

	-- 	-- 这里已经没有动画了
	if Index ==  BattlePassDefine.TabIndex.BigReward then
		self:PlayAnimation(self.AnimGrandPrizeIn)
	else
		self:PlayAnimation(self.AnimlPassContentIn)
	end

	-- 大奖界面隐藏，任务，等级奖励显示
	if Index == BattlePassDefine.TabIndex.LevelReward then
		self:HideCurTypeWidget()
	end

	UIUtil.SetIsVisible(self.PanelPassContent, not (Index ==  BattlePassDefine.TabIndex.BigReward))
	UIUtil.SetIsVisible(self.PanelBigReward, Index ==  BattlePassDefine.TabIndex.BigReward)

	if Index ==  BattlePassDefine.TabIndex.Task  or Index == BattlePassDefine.TabIndex.LevelReward then
		-- 等级奖励界面显示
		UIUtil.SetIsVisible(self.PanelBattlePass, Index ==  BattlePassDefine.TabIndex.LevelReward)
	end

	if Index ==  BattlePassDefine.TabIndex.Task  or Index ==  BattlePassDefine.TabIndex.BigReward then
		local ParentWidget = Index ==  BattlePassDefine.TabIndex.Task and self.PanelTask or self.PanelBigReward
		local CurSelectChildWidgetPath = (self.List[Index] and self.List[Index].ChildWidget) and self.List[Index].ChildWidget or ""
		local PageParams = {
			Index = Index, 
			MainView = self
		}

		self:AddChildByType(ParentWidget, CurSelectChildWidgetPath, PageParams)
	end

	if Index == BattlePassDefine.TabIndex.LevelReward then
		DataReportUtil.ReportBattlePassData(tostring(BattlePassDefine.ScanDest.LevelRewardPanel))
	elseif Index == BattlePassDefine.TabIndex.Task  then
		DataReportUtil.ReportBattlePassData(tostring(BattlePassDefine.ScanDest.TaskPanel))
	elseif Index == BattlePassDefine.TabIndex.BigReward  then
		DataReportUtil.ReportBattlePassData(tostring(BattlePassDefine.ScanDest.BigRewardPanel))
	end

end

function BattlePassMainView:OnLevelRewardScrolled(TableView, ItemOffset)
	if self.LastScrollValue == nil then
		self.LastScrollValue = self.TableViewReward:GetScrollOffset()
		return
	end

	local CurScrollValue = self.TableViewReward:GetScrollOffset()
	self.IsForward = CurScrollValue > self.LastScrollValue
end

function BattlePassMainView:OnLevelRewardItemShow(Level)
	if not self.IsForward then
		return
	end 
	self:UpdateBigRewardData(Level)
end

function BattlePassMainView:SetRedDot()
	local Len = self.RewardListAdapter:GetNum()
	local HasMaxAvailable = false
	local HasMinAvailable = false
	local FirstShowIndex = 1
	local LastShowIndex = 80
	for index = 1, Len, 1 do
		local ItemData = self.RewardListAdapter:GetItemDataByIndex(index)
		if ItemData ~= nil then
			if ItemData.IsShow then
				FirstShowIndex = index
				break
			end
		end
	end

	for index = Len, 1, -1 do
		local ItemData = self.RewardListAdapter:GetItemDataByIndex(index)
		if ItemData ~= nil then
			if ItemData.IsShow then
				LastShowIndex = index
				break
			end
		end
	end


	for index = 1, Len, 1 do
		local ItemData = self.RewardListAdapter:GetItemDataByIndex(index)
		if ItemData ~= nil and index < FirstShowIndex then
			if ItemData.IsAvailable then
				HasMinAvailable = true
				break
			end
		end
	end

	for index = Len, 1, -1 do
		local ItemData = self.RewardListAdapter:GetItemDataByIndex(index)
		if ItemData ~= nil and index > LastShowIndex then
			if ItemData.IsAvailable then
				HasMaxAvailable = true
				break
			end
		end
	end

	if HasMinAvailable then
		UIUtil.SetIsVisible(self.CommonBorderRedDot_UIBP_Left, true)
	else
		UIUtil.SetIsVisible(self.CommonBorderRedDot_UIBP_Left, false)
	end

	if HasMaxAvailable then
		UIUtil.SetIsVisible(self.CommonBorderRedDot_UIBP_Right, true)
	else
		UIUtil.SetIsVisible(self.CommonBorderRedDot_UIBP_Right, false)
	end
end

function BattlePassMainView:OnLevelRewardItemHide(Level)
	-- OnHide 查看有边是否奖励
	-- self:SetRedDot()
	
	if self.IsForward then
		return
	end 

	self:UpdateBigRewardData(Level)
end

function BattlePassMainView:UpdateBigRewardData(Level)
	local Len = self.RewardListAdapter:GetNum()

	local specialValues = {}
	for i = 1, Len, 10 do
		if i % 10 == 1 then
			specialValues[i] = (i - 1) + 10
 		end
	end
	
	for index, showLevel in pairs(specialValues) do
		if index == Level then
			self.ViewModel:UpdateBigRewardData(showLevel)
			return 
		end
	end
end

-- 每日签到
function BattlePassMainView:OnClickedBtnWeeklySignIn()
	if not BattlePassMgr:GetBattlePassWeekSign() then
		BattlePassMgr:SendBattlePassWeekSignReq()
	end
end

function BattlePassMainView:OnClickedBattlePassShopBtn()
	local ShopID = BattlePassMgr:GetBattleShopID()
	_G.ShopMgr:OpenShop(ShopID, nil, false, 1)
end

function BattlePassMainView:OnClickedBuyLevelBtn()
	local MaxLevel = BattlePassMgr:GetBattlePassMaxLevel()
	local CurLevel = BattlePassMgr:GetBattlePassLevel()
	local CfgReward = BattlepassGlobalCfg:FindCfgByKey(ProtoRes.BattlePassGlobalParamType.BattlePassGlobalParamTypeBuyLevelMax)
	if  CfgReward ~= nil then
		MaxLevel =  CfgReward.Value[1]
	end

	if CurLevel >= MaxLevel then
		MsgTipsUtil.ShowTipsByID(134029)
		return
	end
	_G.UIViewMgr:ShowView(_G.UIViewID.BattlePassBuyLevelWin)
end

--  一键领取
function BattlePassMainView:OnClickedGetAllBtn()
	local Index = self.CurTabIndex
	if Index ==  BattlePassDefine.TabIndex.LevelReward then
		BattlePassMgr:SendBattlePassGetLevelReawrdReq(0)
	elseif Index == BattlePassDefine.TabIndex.Task then
		local NodeIDs = {}

		local List1 = BattlePassMgr:GetTaskList(BattlePassDefine.TaskType.Weekly)
		local List2 = BattlePassMgr:GetTaskList(BattlePassDefine.TaskType.Challenge)
		for _, v in ipairs(List1) do
			if v.Nodes.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
				table.insert(NodeIDs, v.Nodes.Head.NodeID)
			end
		end

		for _, v in ipairs(List2) do
			if v.Nodes.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
				table.insert(NodeIDs, v.Nodes.Head.NodeID)
			end
		end
		BattlePassMgr:SendGetAllTaskReward(NodeIDs)
	end
end

function BattlePassMainView:OnClickedUpgradeBPBtn()
	-- if BattlePassMgr:GetBattlePassGrade() >= BattlePassDefine.GradeType.Best then
	-- 	return
	-- end
	_G.UIViewMgr:ShowView(_G.UIViewID.BattlePassAdvanceView)
	-- BattlePassMgr:DoDelayOpenRewardPanel()
end

function BattlePassMainView:OnClickedAdvanceBtn()
	-- if BattlePassMgr:GetBattlePassGrade() >= BattlePassDefine.GradeType.Best then
	-- 	return
	-- end
	_G.UIViewMgr:ShowView(_G.UIViewID.BattlePassAdvanceView)
	-- BattlePassMgr:DoDelayOpenRewardPanel()
end

function BattlePassMainView:OnBattlePassBaseInfoUpdate()
	self:StartBattlePassCountdown()
	self:StartBattlePassDataCountdown()
	self.ViewModel:UpdateBaseData()
	self:UpdateBuyBtnState()
	self.ViewModel:UpdateBtnState(self.CurTabIndex)
end

function BattlePassMainView:OnBattlePassLevelRewardUpdate()
	self.ViewModel:InitLevelRewardList()
	-- 当前最近的一个大奖
	self:RegisterTimer(function ()
		local Level = BattlePassMgr:GetBattlePassLevel()
		self.RewardListAdapter:ScrollToIndex(Level)
		for i = 1, self.RewardListAdapter:GetNum() do
			local ItemData = self.RewardListAdapter:GetItemDataByIndex(i)
			if ItemData ~= nil then
				if ItemData.Lv <= Level then
					self:UpdateBigRewardData(ItemData.Lv)
				end
			end
		end
	end, 0.1)
end


function BattlePassMainView:StartBattlePassCountdown()
	local EndTime = BattlePassMgr:GetBattlePassEndTime()

	if EndTime ~= "" then
        local Timestamp = TimeUtil.GetTimeFromString(EndTime)
        local Servertime =TimeUtil.GetServerLogicTime()
        local TempTime =  Timestamp - Servertime

		if TempTime > 0 then
			if self.BattleRemainTimer ~= nil then
				self:UnRegisterTimer(self.BattleRemainTimer)
				self.BattleRemainTimer = nil
			end
			self.BattleRemainTimer = self:RegisterTimer(self.OnBattlePassRemainCountDown, 0, 1, 0)
		end
	end
end

function BattlePassMainView:OnBattlePassRemainCountDown()
	local EndTime = BattlePassMgr:GetBattlePassEndTime()

	if EndTime ~= "" then
		local Timestamp = TimeUtil.GetTimeFromString(EndTime)
        local Servertime =TimeUtil.GetServerLogicTime()
        local TempTime =  Timestamp - Servertime
		if TempTime > 0 then
			local Str = string.format("%s%s", _G.LSTR(850010), LocalizationUtil.GetCountdownTimeForSimpleTime(TempTime, self:GetTimeFormat(TempTime)))
			self.ViewModel.CountDown = Str
		else
			if self.BattleRemainTimer ~= nil then
				self:UnRegisterTimer(self.BattleRemainTimer)
				self.BattleRemainTimer = nil
			end
		end
	end
end

function BattlePassMainView:StartBattlePassDataCountdown()
	if BattlePassMgr:GetDataValidTime() > 0 then
		if self.BattlePassDataValidTimer ~= nil then
			self:UnRegisterTimer(self.BattlePassDataValidTimer)
			self.BattlePassDataValidTimer = nil
		end
		self.BattlePassDataValidTimer = self:RegisterTimer(self.OnBattlePassDataValid, 0, 1, 0)
	end
end

function BattlePassMainView:OnBattlePassDataValid()
	local Time =TimeUtil.GetServerLogicTime()
	local VaildTime = BattlePassMgr:GetDataValidTime()
	if Time >= VaildTime then
		self:UnRegisterTimer(self.BattlePassDataValidTimer)
		self.BattlePassDataValidTimer = nil
		BattlePassMgr:SendBattlePassStateReq()
	end
end

function BattlePassMainView:GetTimeFormat(SecondsTime)
	local days = SecondsTime / (24 * 3600)
    if days >= 1 then
        return "d"
    end
    
    local hours = SecondsTime / 3600
    if hours >= 1 then
        return "h"
    end
    
    local minutes = SecondsTime / 60
    if minutes >= 1 then
        return "m"
    end

    return "s"
end

return BattlePassMainView