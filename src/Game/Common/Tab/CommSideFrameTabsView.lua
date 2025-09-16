---
--- Author: ccppeng
--- DateTime: 2025-02-26 15:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommSideFrameTabsVM = require("Game/Common/Tab/CommSideFrameTabsVM")
local UIBinderSetViewParams = require("Binder/UIBinderSetViewParams")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
---@class CommSideFrameTabsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Tab1 CommSideFrameTabItemView
---@field Tab2 CommSideFrameTabItemView
---@field Tab3 CommSideFrameTabItemView
---@field Tab4 CommSideFrameTabItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommSideFrameTabsView = LuaClass(UIView, true)

function CommSideFrameTabsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Tab1 = nil
	--self.Tab2 = nil
	--self.Tab3 = nil
	--self.Tab4 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommSideFrameTabsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Tab1)
	self:AddSubView(self.Tab2)
	self:AddSubView(self.Tab3)
	self:AddSubView(self.Tab4)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommSideFrameTabsView:OnInit()
	self.ViewModel = CommSideFrameTabsVM.New()
end

function CommSideFrameTabsView:OnDestroy()

end

function CommSideFrameTabsView:OnShow()

end

function CommSideFrameTabsView:OnHide()

end

function CommSideFrameTabsView:OnRegisterUIEvent()

end

function CommSideFrameTabsView:OnRegisterGameEvent()

end

function CommSideFrameTabsView:OnRegisterBinder()
	if self.Params ~= nil  then
		self.ViewModel = self.Params
	else
		self.ViewModel = CommSideFrameTabsVM.New()
	end
	self.Binders = {

		{ "CommSideFrameTabItemVMTab1", UIBinderSetViewParams.New(self, self.Tab1)},
		{ "CommSideFrameTabItemVMTab2", UIBinderSetViewParams.New(self, self.Tab2)},
		{ "CommSideFrameTabItemVMTab3", UIBinderSetViewParams.New(self, self.Tab3) },
		{ "CommSideFrameTabItemVMTab4", UIBinderSetViewParams.New(self, self.Tab4) },
		{ "CurrentSelect", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateToSelect) },
		}
	self:RegisterBinders(self.ViewModel, self.Binders)
end
function CommSideFrameTabsView:OnUpdateToSelect(NewValue,OldValue)
	self.ViewModel:OnUpdateToSelect(NewValue,OldValue)
end
return CommSideFrameTabsView