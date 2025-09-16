---
--- Author: fish
--- DateTime: 2023-02-02 15:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ActivityVM = require("Game/Activity/ActivityVM")
local ActivityDefine = require("Game/Activity/ActivityDefine")

local UIAdapterToggleGroup = require("UI/Adapter/UIAdapterToggleGroup")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LSTR = _G.LSTR

---@class ActivityMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityNotice ActivityNoticeView
---@field BtnClose CommonCloseBtnView
---@field MainTab UToggleGroupDynamic
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ActivityMainView = LuaClass(UIView, true)

function ActivityMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityNotice = nil
	--self.BtnClose = nil
	--self.MainTab = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ActivityMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActivityNotice)
	self:AddSubView(self.BtnClose)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ActivityMainView:OnInit()
	self.AdapterMainTabToggleGroup = UIAdapterToggleGroup.CreateAdapter(self, self.MainTab, self.OnMainTabChanged, true)

	self.Binders = {
		{"ActivityNoticeVisible", UIBinderSetIsVisible.New(self, self.ActivityNotice)},
	}
end

function ActivityMainView:OnDestroy()

end

function ActivityMainView:OnShow()
	self.AdapterMainTabToggleGroup:UpdateAll(ActivityDefine.MainTabs)
	self.TextTitle:SetText(LSTR("公告"))
end

function ActivityMainView:OnHide()

end

function ActivityMainView:OnRegisterUIEvent()

end

function ActivityMainView:OnRegisterGameEvent()

end

function ActivityMainView:OnRegisterBinder()
	self:RegisterBinders(ActivityVM, self.Binders)
end

--- Main Tab Index Changed Event
---@param Index any
---start from 1
---@param ItemData any
---@param ItemView any
function ActivityMainView:OnMainTabChanged(Index, ItemData, ItemView)
	_G.FLOG_ERROR("OnMainTabChanged " .. tostring(Index))
	ActivityVM.ActivityNoticeVisible = Index == 1
end

return ActivityMainView