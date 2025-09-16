---
--- Author: daniel
--- DateTime: 2023-03-20 09:33
--- Description:部队动态
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local ArmyMgr = require("Game/Army/ArmyMgr")
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmyInfoPageVM = nil
local ArmyInfoTrendsVM = nil

local ArmyDefine = require("Game/Army/ArmyDefine")
---@class ArmyInfoTrendsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field CommEmpty CommEmptyView
---@field DropDownList CommDropDownListView
---@field TableViewTrends UTableView
---@field AnimUpdateList UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyInfoTrendsWinView = LuaClass(UIView, true)

function ArmyInfoTrendsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.CommEmpty = nil
	--self.DropDownList = nil
	--self.TableViewTrends = nil
	--self.AnimUpdateList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.LogsData = nil
end

function ArmyInfoTrendsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.DropDownList)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyInfoTrendsWinView:OnInit()
	ArmyInfoPageVM = ArmyMainVM:GetArmyInfoPageVM()
	ArmyInfoTrendsVM = ArmyInfoPageVM:GetArmyInfoTrendsVM()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTrends)
	self.Binders = {
		{"LogList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter)},
		{"IsEmpty", UIBinderSetIsVisible.New(self, self.CommEmpty)},
	}
end

function ArmyInfoTrendsWinView:OnDestroy()
end

function ArmyInfoTrendsWinView:OnShow()
	---固定文本设置
	-- LSTR string:部队动态
	self.BG:SetTitleText(LSTR(910302))
	-- LSTR string:暂无动态
	self.CommEmpty:UpdateText(LSTR(910303))
	self.DropDownList:UpdateItems(ArmyDefine.ArmyLogFilterType, 1)
	--UIUtil.SetIsVisible(self.FilterTips, false, true)
	ArmyMgr:SendGetArmyLogsMsg(true)
end

function ArmyInfoTrendsWinView:OnHide()
end

function ArmyInfoTrendsWinView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList, self.OnFilterSelectedChanged)
end

function ArmyInfoTrendsWinView:OnRegisterGameEvent()
end

function ArmyInfoTrendsWinView:OnRegisterBinder()
	self:RegisterBinders(ArmyInfoTrendsVM, self.Binders)
end

function ArmyInfoTrendsWinView:OnClickedCloseToggle()
	self.ToggleBtnFilter:SetCheckedState(_G.UE.EToggleButtonState.UnChecked)
end

function ArmyInfoTrendsWinView:OnFilterSelectedChanged(Index)
	self:PlayAnimation(self.AnimUpdateList)
	ArmyInfoTrendsVM:UpdateLogsList(Index - 1)
end

return ArmyInfoTrendsWinView