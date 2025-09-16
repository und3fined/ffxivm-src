
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local LuaClass = require("Core/LuaClass")
local UIDefine = require("Define/UIDefine")
local UIViewID = require("Define/UIViewID")
local RollMgr = require("Game/Roll/RollMgr")
local MainPanelVM = require("Game/Main/MainPanelVM")
local TeamRollItemVM = require("Game/Team/VM/TeamRollItemVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local EventMgr = _G.EventMgr
local CommBtnColorType = UIDefine.CommBtnColorType
---@class TeamRollPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCloseTips UFButton
---@field BtnGiveUp CommBtnSView
---@field BtnNeed CommBtnSView
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field ItemTips ItemTipsFrameNewView
---@field TableViewReward UTableView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRollPanelView = LuaClass(UIView, true)

function TeamRollPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCloseTips = nil
	--self.BtnGiveUp = nil
	--self.BtnNeed = nil
	--self.CommSidebarFrameS_UIBP = nil
	--self.ItemTips = nil
	--self.TableViewReward = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRollPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGiveUp)
	self:AddSubView(self.BtnNeed)
	self:AddSubView(self.CommSidebarFrameS_UIBP)
	-- self:AddSubView(self.ItemTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRollPanelView:OnInit()
	UIUtil.SetIsVisible(self.TableViewReward, true, false)
	self.ButtonClickedStatusColor = {0.376262, 0.391573, 0.412543, 1}
	self.ButtonRawStatusColor = {1, 1, 1, 1}
	self.TableViewGoodsAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewReward, self.OnItemSelectChanged, true)

	self.ItemTipsOffset = {X = -750, Y = -510}
	-- 取消ItemTips背景板回调
	-- self.ItemTips.PopUpBG:SetCallback(self, nil)
	-- self.ItemTips.PopUpBG:SetHideOnClick(false)
	-- self.CloseBtn:SetCallback(self, self.OnHide)
end

function TeamRollPanelView:OnDestroy()

end

function TeamRollPanelView:OnShow()
	self.BtnGiveUp:SetText(LSTR(480001))		--- 全部放弃
	self.BtnNeed:SetText(LSTR(480002))			--- 全部需求
	self.CommSidebarFrameS_UIBP.CommonTitle:SetTextTitleName(LSTR(480003))				--- 队伍分配
	-- if MainPanelVM.FunctionVisible then
	-- 	self.IsNeedShowFunction = true
	-- 	MainPanelVM:SetFunctionVisible(false)
	-- end
	-- self:PlayAnimIn()
	EventMgr:SendEvent(EventID.TeamRollItemViewShowStatus, true)


	-- 打开队伍分配界面时，应该默认选中左起第一件未完成操作的装备
	local AwardListVM = TeamRollItemVM.AwardList:GetItems()
	self.IsAllOperated = true
	if AwardListVM == nil then
		self.IsAllOperated = false
	else
		for i = 1, #AwardListVM do
			if not AwardListVM[i].IsOperated then
				self.CurrentSelectedItemVM = AwardListVM[i]
				self.CurrentSelectedIndex = i
				local ItemDataHash = self.TableViewGoodsAdapter:GetHash(self.CurrentSelectedItemVM)
				local ItemIndex = self.TableViewGoodsAdapter:GetItemIndex(ItemDataHash)
				self.IsShowView = true
				self.IsAllOperated = false
				self.TableViewGoodsAdapter:SetSelectedIndex(ItemIndex)
				break
			end
		end
	end
	if TeamRollItemVM.IsAllOperated then
		self.IsNeedShowTips = false
		self.TableViewGoodsAdapter:SetSelectedIndex(1)
		-- EventMgr:SendEvent(EventID.TeamRollItemSelectEvent, {AwardID = self.CurrentSelectedItemVM.AwardID, IsSwitch = true, IsUpdate = true, Index = self.CurrentSelectedIndex, TeamID = self.CurrentSelectedItemVM.TeamID})
	end

	-- if self.CurrentSelectedItemVM ~= nil and TeamRollItemVM.IsShowTips then
	-- 	self.ItemTips.ViewModel:UpdateVM(self.CurrentSelectedItemVM)
	-- end
	-- self.IsShowView = false

	UIViewMgr:HideView(UIViewID.ItemTips)
	self:UpdateButtonState(TeamRollItemVM.IsAllOperated)
end

function TeamRollPanelView:OnHide()
	EventMgr:SendEvent(EventID.TeamRollItemViewShowStatus, false)
	UIViewMgr:HideView(UIViewID.ItemTipsStatus)
	TeamRollItemVM.IsShowTips = false
	RollMgr.IsQuery = false
	-- if self.IsNeedShowFunction then
	-- 	MainPanelVM:SetFunctionVisible(true)
	-- 	self.IsNeedShowFunction = false
	-- end 
end

function TeamRollPanelView:OnRegisterUIEvent()
	-- UIUtil.AddOnClickedEvent(self, self.CloseBtn.Btn_Close, self.OnBtnClose)
	UIUtil.AddOnClickedEvent(self, self.BtnGiveUp.Button, self.OnAllGiveUpBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnNeed.Button, self.OnAllDemandBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnCloseTips, self.OnBtnCloseTipsBtn)
end

function TeamRollPanelView:OnRegisterGameEvent()
	-- self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)				-- 退出副本通知隐藏Roll界面
	self:RegisterGameEvent(EventID.TeamRollCheckIsAllOperated, self.OnCheckIsAllOperated)
	self:RegisterGameEvent(EventID.PWorldTransBegin, self.Hide)
	self:RegisterGameEvent(EventID.TeamRollHiTipsEvent, self.OnHideTips)
end

function TeamRollPanelView:OnRegisterBinder()
	local Binders = {
		{ "AwardList", UIBinderUpdateBindableList.New(self, self.TableViewGoodsAdapter) },
		{ "IsAllOperated", UIBinderValueChangedCallback.New(self, nil, self.UpdateButtonState) },
		{ "IsStartRoll", UIBinderValueChangedCallback.New(self, nil, self.OnAwardStatusValueChangeCallback) },
		{ "IsAwradResult", UIBinderValueChangedCallback.New(self, nil, self.OnAwardStatusValueChangeCallback) },
		{ "IsShowTips", UIBinderSetIsVisible.New(self, self.BtnCloseTips, nil, true) },
		-- { "IsAwradResult", UIBinderValueChangedCallback.New(self, nil, self.OnAwardStatusValueChangeCallback) }
	}
	self:RegisterBinders(TeamRollItemVM, Binders)
	local IsStartRoll = TeamRollItemVM:FindBindableProperty("IsStartRoll")
	IsStartRoll:SetNoCheckValueChange(true)
	local IsAwradResult = TeamRollItemVM:FindBindableProperty("IsAwradResult")
	IsAwradResult:SetNoCheckValueChange(true)
end

function TeamRollPanelView:OnHideTips()
	-- UIViewMgr:HideView(UIViewID.ItemTips)
	-- UIUtil.SetIsVisible(self.ItemTips, false)
	TeamRollItemVM.IsShowTips = false
end

function TeamRollPanelView:OnItemSelectChanged(Index, ItemData, ItemView)
	if self.IsNeedShowTips then
		if ItemView ~= nil then
			if not ItemView.IsSecelted then
				ItemTipsUtil.ShowTipsByResID(ItemData.ResID, self.BtnGiveUp, {X = 35, Y = -850})
			end
			if self.ItemTips.ViewModel ~= nil then
				self.ItemTips.ViewModel.ShowDisCurEquipmentLevel = true
			end
		end
	else
		self.IsNeedShowTips = true
	end
	TeamRollItemVM.CurrentSelectedAwardID = ItemData.AwardID
	TeamRollItemVM.CurrentSelectedTeamID = ItemData.TeamID
	UIViewMgr:HideView(UIViewID.ItemTipsStatus)
	UIViewMgr:HideView(UIViewID.CommGetWayTipsView)
	self.CurrentSelectedItemVM = ItemData
	EventMgr:SendEvent(EventID.TeamRollItemSelectEvent, {AwardID = ItemData.AwardID, IsSwitch = true, IsUpdate = true, Index = Index, TeamID = ItemData.TeamID})
	if self.CurrentSelectedItemVM.IsGiveUp or self.CurrentSelectedItemVM.IsOperated or self.CurrentSelectedItemVM.NotObtained or self.IsAllOperated then
		TeamRollItemVM.IsOperated = true
	else
		TeamRollItemVM.IsOperated = false
	end

	if RollMgr:GetAwardBelong(self.CurrentSelectedItemVM.AwardID) == nil then
		TeamRollItemVM.IsAwradResult = false
		TeamRollItemVM.IsStartRoll = true
	else
		TeamRollItemVM.IsStartRoll = false
		TeamRollItemVM.IsAwradResult = true
	end
	TeamRollItemVM:SetSelectedIndex(Index)
end

function TeamRollPanelView:OnInputGameModeDisable()
	-- print("SetInputMode_UIOnly")
	UIUtil.SetInputMode_UIOnly()
end

function TeamRollPanelView:OnInputGameModeEnable()
	UIUtil.SetInputMode_GameAndUI()
end

function TeamRollPanelView:OnBtnButtonClose()
	UIUtil.SetIsVisible(self.DistributionTips, false)
end

function TeamRollPanelView:OnBtnClose()
	self:Hide()
	EventMgr:SendEvent(EventID.TeamRollItemViewShowStatus, false)
end

function TeamRollPanelView:OnAllGiveUpBtn()
	EventMgr:SendEvent(EventID.TeamRollAllGiveUp)
end

function TeamRollPanelView:OnAllDemandBtn()
	EventMgr:SendEvent(EventID.TeamRollAllRandom)
end

function TeamRollPanelView:UpdateButtonState(NewValue)
	if NewValue then
		-- self.BtnGiveUp:UpdateBtnEnable(CommBtnColorType.Disable)
		self.BtnGiveUp:UpdateImage(CommBtnColorType.Disable)
		self.BtnGiveUp:UpdateTextColor(CommBtnColorType.Disable)
		-- self.BtnNeed:UpdateBtnEnable(CommBtnColorType.Disable)
		self.BtnNeed:UpdateImage(CommBtnColorType.Disable)
		self.BtnNeed:UpdateTextColor(CommBtnColorType.Disable)
	else
		self.BtnGiveUp:UpdateImage(CommBtnColorType.Normal)
		self.BtnGiveUp:UpdateTextColor(CommBtnColorType.Normal)
		self.BtnNeed:UpdateTextColor(CommBtnColorType.Normal)
		self.BtnNeed:UpdateImage(CommBtnColorType.Recommend)
	end
	UIUtil.SetIsVisible(self.BtnGiveUp.Button, true, not NewValue)
	UIUtil.SetIsVisible(self.BtnNeed.Button, true, not NewValue)

end

function TeamRollPanelView:OnCheckIsAllOperated()
	local AwardList = TeamRollItemVM.AwardList
	for i = 1, AwardList:Length() do
		local AwardItemVM = AwardList:Get(i)
		if AwardItemVM.IsQualify then
			return
		end
	end
	self.BtnNeed:UpdateImage(CommBtnColorType.Disable)
	self.BtnNeed:UpdateTextColor(CommBtnColorType.Disable)
	UIUtil.SetIsVisible(self.BtnNeed.Button, true, false)
end


function TeamRollPanelView:OnBtnCloseTipsBtn()
	TeamRollItemVM.IsShowTips = false
	UIViewMgr:HideView(UIViewID.ItemTipsStatus)
	UIViewMgr:HideView(UIViewID.CommGetWayTipsView)
end

function TeamRollPanelView:OnAwardStatusValueChangeCallback()
	-- if TeamRollItemVM.IsStartRoll then
	-- 	if RollMgr:GetAwardBelong(TeamRollItemVM.UpdateAwardID, TeamRollItemVM.UpdateTeamID) == nil then
	-- 		local AwardVM = TeamRollItemVM:GetAwardVM(TeamRollItemVM.UpdateAwardID)
	-- 		if AwardVM.IsOperated and not AwardVM.IsAlreadyPossessed and not AwardVM.IsGiveUp then
	-- 			AwardVM.IsWait = true
	-- 		end
	-- 	end

	-- elseif TeamRollItemVM.IsAwradResult then
	-- 	if RollMgr:GetAwardBelong(TeamRollItemVM.UpdateAwardID, TeamRollItemVM.UpdateTeamID) ~= nil then
	-- 		local AwardVM = TeamRollItemVM:GetAwardVM(TeamRollItemVM.UpdateAwardID)
	-- 		if AwardVM.IsOperated then
	-- 			AwardVM.IsWait = false
	-- 		end
	-- 	end
	-- end
end


return TeamRollPanelView