---
--- Author: chriswang
--- DateTime: 2021-12-06 14:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local InteractiveMainPanelVM = require("Game/Interactive/MainPanel/InteractiveMainPanelVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
--local ProtoRes = require("Protocol/ProtoRes")

---@class InteractiveMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnNpcSwitchSingle UButton
---@field BtnNpcSwitchSingle1 UButton
---@field EntranceCanvasPanel UFCanvasPanel
---@field FixedFunctionPanel UFCanvasPanel
---@field FunctionPanel UFCanvasPanel
---@field IconNpcSwitchSingle UFImage
---@field IconNpcSwitchSingle1 UFImage
---@field NewEntranceItems UTableView
---@field NewEntrancePanel UFCanvasPanel
---@field PanelNpcSwitchSingle UFCanvasPanel
---@field PanelNpcSwitchSingle1 UFCanvasPanel
---@field SingleEntrance BubbleBoxCommonItemView
---@field TabViewFixedFunctionItems UTableView
---@field TabViewFunctionItems UTableView
---@field TextNpcNameSingle UFTextBlock
---@field TextNpcNameSingle1 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InteractiveMainPanelView = LuaClass(UIView, true)

function InteractiveMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnNpcSwitchSingle = nil
	--self.BtnNpcSwitchSingle1 = nil
	--self.EntranceCanvasPanel = nil
	--self.FixedFunctionPanel = nil
	--self.FunctionPanel = nil
	--self.IconNpcSwitchSingle = nil
	--self.IconNpcSwitchSingle1 = nil
	--self.NewEntranceItems = nil
	--self.NewEntrancePanel = nil
	--self.PanelNpcSwitchSingle = nil
	--self.PanelNpcSwitchSingle1 = nil
	--self.SingleEntrance = nil
	--self.TabViewFixedFunctionItems = nil
	--self.TabViewFunctionItems = nil
	--self.TextNpcNameSingle = nil
	--self.TextNpcNameSingle1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InteractiveMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SingleEntrance)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InteractiveMainPanelView:OnInit()
	self.TableViewFunction = UIAdapterTableView.CreateAdapter(self, self.TabViewFunctionItems)
	self.TableViewEntrance = UIAdapterTableView.CreateAdapter(self, self.NewEntranceItems)
	self.TableViewFixedFunction = UIAdapterTableView.CreateAdapter(self, self.TabViewFixedFunctionItems)
	self.FunctionPanelTop = UIUtil.CanvasSlotGetOffsets(self.FunctionPanel).Top
	self.NewEntrancePanelTop = UIUtil.CanvasSlotGetOffsets(self.NewEntrancePanel).Top

	self.Binders = {
		--直接绑控件
		{ "FunctionItemList", UIBinderUpdateBindableList.New(self, self.TableViewFunction) },
		{ "FixedFunctionItemList", UIBinderUpdateBindableList.New(self, self.TableViewFixedFunction) },

		{ "MainPanelVisible", UIBinderValueChangedCallback.New(self, nil, self.OnMainPanelVisible) },
		{ "EntranceVisible", UIBinderValueChangedCallback.New(self, nil, self.SetEntrancesVisible) },
		{ "FunctionVisible", UIBinderValueChangedCallback.New(self, nil, self.SetFunctionVisible) },
		{ "FixedFunctionVisible", UIBinderValueChangedCallback.New(self, nil, self.SetFixedFunctionVisible) },
		{ "PanelTargetSwitchVisible", UIBinderValueChangedCallback.New(self, nil, self.SetPanelTargetSwitchVisible) },
		{ "PanelPlayerSwitchVisible", UIBinderValueChangedCallback.New(self, nil, self.SetPanelPlayerSwitchVisible) },

		--回调
		{ "EntranceItemList", UIBinderValueChangedCallback.New(self, nil, self.SetEntranceItems) },
		{ "SingleEntranceItem", UIBinderValueChangedCallback.New(self, nil, self.SetSingleEntrance) },
		--{ "EntranceTableViewTop", UIBinderValueChangedCallback.New(self, nil, self.OnSetEntranceTableViewTop) },
		{ "FuctionTableViewTop", UIBinderValueChangedCallback.New(self, nil, self.OnSetFuctionTableViewTop) },
		{ "TargetName", UIBinderValueChangedCallback.New(self, nil, self.OnSetTargetName) },
		{ "PlayerName", UIBinderValueChangedCallback.New(self, nil, self.OnSetPlayerName) },
	}
end

function InteractiveMainPanelView:OnDestroy()
end

function InteractiveMainPanelView:OnShow()
end

function InteractiveMainPanelView:OnHide()

end

function InteractiveMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnNpcSwitchSingle, self.OnBtnNpcSwitchClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnNpcSwitchSingle1, self.OnBtnPlayerSwitchClicked)
end

function InteractiveMainPanelView:OnRegisterGameEvent()

end

function InteractiveMainPanelView:OnRegisterBinder()
	self:RegisterBinders(InteractiveMainPanelVM, self.Binders)
end

function InteractiveMainPanelView:OnMainPanelVisible(bShow)
	--_G.FLOG_INFO("InteractiveMainPanelView:OnMainPanelVisible, bShow=%s", tostring(bShow))
	--UIUtil.SetIsVisible(self, Flag)
	local Opacity = bShow == false and 0.0 or 1.0
	UIUtil.SetRenderOpacity(self, Opacity)
end

function InteractiveMainPanelView:SetEntrancesVisible(bShow)
	--_G.FLOG_INFO("InteractiveMainPanelView:SetEntrancesVisible, bShow=%s", tostring(bShow))
	self.mIsShowEntrance = bShow
	UIUtil.SetIsVisible(self.EntranceCanvasPanel, bShow)
end

function InteractiveMainPanelView:SetFunctionVisible(bShow)
	--_G.FLOG_INFO("InteractiveMainPanelView:SetFunctionVisible, bShow=%s", tostring(bShow))
	if bShow then
		self.mIsShowEntrance = false
	end

	UIUtil.SetIsVisible(self.FunctionPanel, bShow)
end

function InteractiveMainPanelView:SetFixedFunctionVisible(bShow)
	--_G.FLOG_INFO("InteractiveMainPanelView:SetFixedFunctionVisible, bShow=%s", tostring(bShow))
	if bShow then
		self.mIsShowEntrance = false
	end
	UIUtil.SetIsVisible(self.FixedFunctionPanel, bShow)
end

function InteractiveMainPanelView:SetPanelTargetSwitchVisible(bShow)
	--_G.FLOG_INFO("InteractiveMainPanelView:PanelTargetSwitchVisible, bShow=%s", tostring(bShow))
	UIUtil.SetIsVisible(self.PanelNpcSwitchSingle, bShow)
end

function InteractiveMainPanelView:SetPanelPlayerSwitchVisible(bShow)
	--_G.FLOG_INFO("InteractiveMainPanelView:SetPanelPlayerSwitchVisible, bShow=%s", tostring(bShow))
	UIUtil.SetIsVisible(self.PanelNpcSwitchSingle1, bShow)
end

function InteractiveMainPanelView:SetEntranceItems(ItemList)
	if self.mIsShowEntrance then
		self.TableViewEntrance:UpdateAll(ItemList)
	end
end

function InteractiveMainPanelView:SetSingleEntrance(Item)
	if Item == nil then
		UIUtil.SetIsVisible(self.SingleEntrance, false)
		return
	end

	if self.mIsShowEntrance then
		self.SingleEntrance:FillEntrance(Item)
	end

	UIUtil.SetIsVisible(self.SingleEntrance, self.mIsShowEntrance, true)
end

function InteractiveMainPanelView:OnSetEntranceTableViewTop(TableViewTop)
	if self.TableViewEntrance and TableViewTop then
		local offset = UIUtil.CanvasSlotGetOffsets(self.NewEntrancePanel)
		if offset then
			offset.Top = self.NewEntrancePanelTop + TableViewTop
			UIUtil.CanvasSlotSetOffsets(self.NewEntrancePanel, offset)
		end
	end
end

function InteractiveMainPanelView:OnSetFuctionTableViewTop(TableViewTop)
	if self.TabViewFunctionItems and TableViewTop then
		-- local offset = UIUtil.CanvasSlotGetOffsets(self.TabViewFunctionItems)
		-- if offset then
		-- 	offset.Top = TableViewTop
		-- 	UIUtil.CanvasSlotSetOffsets(self.TabViewFunctionItems, offset)
		-- end
		-- self.TabViewFunctionItems:ScrollToTop()
		local offset = UIUtil.CanvasSlotGetOffsets(self.FunctionPanel)
		if offset then
			offset.Top = self.FunctionPanelTop + TableViewTop
			UIUtil.CanvasSlotSetOffsets(self.FunctionPanel, offset)
		end
	end
end

function InteractiveMainPanelView:OnSetTargetName(Name)
	--_G.FLOG_INFO("InteractiveMainPanelView:OnSetTargetName, Name=%s", Name)
	self.TextNpcNameSingle:SetText(Name)
end

function InteractiveMainPanelView:OnSetPlayerName(Name)
	--_G.FLOG_INFO("InteractiveMainPanelView:OnSetPlayerName, Name=%s", Name)
	self.TextNpcNameSingle1:SetText(Name)
end

function InteractiveMainPanelView:OnBtnNpcSwitchClicked()
	InteractiveMgr:SwitchInteractiveTarget()
end

function InteractiveMainPanelView:OnBtnPlayerSwitchClicked()
	InteractiveMgr:SwitchPlayer()
end

return InteractiveMainPanelView