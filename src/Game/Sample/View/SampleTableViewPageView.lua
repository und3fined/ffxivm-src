---
--- Author: anypkvcai
--- DateTime: 2024-06-17 11:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local SampleMgr = _G.SampleMgr
local SampleVM = _G.SampleVM
local FLOG_INFO = _G.FLOG_INFO

---@class SampleTableViewPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommVerIconTabs CommVerIconTabsView
---@field TableViewItem UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SampleTableViewPageView = LuaClass(UIView, true)

function SampleTableViewPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommVerIconTabs = nil
	--self.TableViewItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SampleTableViewPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommVerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SampleTableViewPageView:OnInit()
	SampleMgr:InitTableViewData()

	self.AdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewItem, self.OnSelectionChangedTableView, false)

	self.Binders = {
		{ "TableViewData", UIBinderUpdateBindableList.New(self, self.AdapterTableView) }
	}
end

function SampleTableViewPageView:OnDestroy()
end

function SampleTableViewPageView:OnShow()
	local IconPath = "Texture2D'/Game/Assets/Icon/Profe/Job/UI_Icon_Job_Main_WZ.UI_Icon_Job_Main_WZ"
	local ListData = {
		{ IconPath = IconPath },
		{ IconPath = IconPath },
		{ IconPath = IconPath },
		{ IconPath = IconPath },
		{ IconPath = IconPath }
	}
	self.CommVerIconTabs:UpdateItems(ListData, 1)
end

function SampleTableViewPageView:OnHide()
end

function SampleTableViewPageView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommVerIconTabs, self.OnSelectionChangedCommVerIconTabs)
end

function SampleTableViewPageView:OnRegisterGameEvent()
end

function SampleTableViewPageView:OnRegisterBinder()
	local ViewModel = SampleVM

	self:RegisterBinders(ViewModel, self.Binders)
end

function SampleTableViewPageView:OnSelectionChangedCommVerIconTabs(Index)
	FLOG_INFO("OnSelectionChangedTab Index=%d ", Index)

	local Data = SampleMgr:GetTableViewDataByType(Index)

	SampleVM:UpdateTableViewData(Data)
end

function SampleTableViewPageView:OnSelectionChangedTableView(Index)
	FLOG_INFO("OnSelectionChangedTableView Index=%d ", Index)
end

return SampleTableViewPageView
