---
--- Author: sammrli
--- DateTime: 2024-02-18 11:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class TravelLogTaskTitleItneView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FTextBlock_43 UFTextBlock
---@field IconMark UFImage
---@field ImgLine UFImage
---@field TableViewTask UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TravelLogTaskTitleItneView = LuaClass(UIView, true)

function TravelLogTaskTitleItneView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FTextBlock_43 = nil
	--self.IconMark = nil
	--self.ImgLine = nil
	--self.TableViewTask = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TravelLogTaskTitleItneView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TravelLogTaskTitleItneView:OnInit()
	self.LogListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTask, self.OnLogListSelectChanged, true)
end

function TravelLogTaskTitleItneView:OnDestroy()

end

function TravelLogTaskTitleItneView:OnShow()
	self.ViewModel:UpdateList()
	if self.ViewModel.FirstTitleItne then
		self.LogListAdapter:SetSelectedIndex(1)
    end
end

function TravelLogTaskTitleItneView:OnHide()

end

function TravelLogTaskTitleItneView:OnRegisterUIEvent()

end

function TravelLogTaskTitleItneView:OnRegisterGameEvent()

end

function TravelLogTaskTitleItneView:OnRegisterBinder()
	if nil == self.Params then return end

	---@type TravelLogTaskTitleItneVM
	self.ViewModel = self.Params.Data

	local Binders = {
		{ "Title", UIBinderSetText.New(self, self.FTextBlock_43) },
		{ "LogVMList", UIBinderUpdateBindableList.New(self, self.LogListAdapter)},
		{ "IsMarkVisible", UIBinderSetIsVisible.New(self, self.IconMark)},
		{ "IsLineVisible", UIBinderSetIsVisible.New(self, self.ImgLine)},
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function TravelLogTaskTitleItneView:OnLogListSelectChanged(Index, ItemData, ItemView)
	---@type TravelLogMainPanelView
	local MainPanelView = self.ParentView.ParentView
	MainPanelView.TravelLogMainPanelVM.TaskTitle = ItemData.TextTask
	MainPanelView.TravelLogMainPanelVM:UpdateTaskContent(ItemData.LogID)
	MainPanelView.TravelLogFilmItem_UIBP:Show(ItemData.LogID)
	MainPanelView.TravelLogMainPanelVM:SetSelectedTaskItne(ItemData.LogID)
end

return TravelLogTaskTitleItneView