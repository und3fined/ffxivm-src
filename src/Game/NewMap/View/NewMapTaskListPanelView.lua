---
--- Author: Administrator
--- DateTime: 2024-02-26 10:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")

---@class NewMapTaskListPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field PanelEmpty UFCanvasPanel
---@field Switch UFWidgetSwitcher
---@field TextEmpty UFTextBlock
---@field TextTitle UFTextBlock
---@field TreeViewTaskList UFTreeView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewMapTaskListPanelView = LuaClass(UIView, true)

function NewMapTaskListPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.PanelEmpty = nil
	--self.Switch = nil
	--self.TextEmpty = nil
	--self.TextTitle = nil
	--self.TreeViewTaskList = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewMapTaskListPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewMapTaskListPanelView:OnInit()
	self.AdapterTreeViewTaskList = UIAdapterTreeView.CreateAdapter(self, self.TreeViewTaskList, nil, true, true)

	self.Binders = {
		{ "TaskList", UIBinderUpdateBindableList.New(self, self.AdapterTreeViewTaskList) },
		{ "WidgetIndex", UIBinderSetActiveWidgetIndex.New(self, self.Switch) },
	}
end

function NewMapTaskListPanelView:OnDestroy()

end

function NewMapTaskListPanelView:OnShow()
	self:SetFixText()
	WorldMapVM.TaskListVM:SetShowUIMapID()
end

function NewMapTaskListPanelView:OnHide()
	WorldMapVM:ShowWorldMapTaskListPanel(false)
end

function NewMapTaskListPanelView:OnRegisterUIEvent()

end

function NewMapTaskListPanelView:OnRegisterGameEvent()

end

function NewMapTaskListPanelView:OnRegisterBinder()
	self:RegisterBinders(WorldMapVM.TaskListVM, self.Binders)
end

function NewMapTaskListPanelView:SetFixText()
	self.TextTitle:SetText(_G.LSTR(400007))
	self.TextEmpty:SetText(_G.LSTR(400008))
end

return NewMapTaskListPanelView