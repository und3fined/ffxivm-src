---
--- Author: enqingchen
--- DateTime: 2023-02-13 15:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
--local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local MountSettingTipsVM = require("Game/Mount/VM/MountSettingTipsVM")

local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class MountSettingTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountSettingTipsView = LuaClass(UIView, true)

function MountSettingTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountSettingTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountSettingTipsView:OnInit()
	self.ViewModel = MountSettingTipsVM.New()
	self.TableView = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, false)
	self.TableView:SetScrollbarIsVisible(false)
end

function MountSettingTipsView:OnDestroy()

end

function MountSettingTipsView:OnShow()
	
end

function MountSettingTipsView:OnHide()

end

function MountSettingTipsView:OnRegisterUIEvent()

end

function MountSettingTipsView:OnRegisterGameEvent()

end

function MountSettingTipsView:OnRegisterBinder()
	local Binders = {
		{ "ListSettingTipsItemVM", UIBinderUpdateBindableList.New(self, self.TableView) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

return MountSettingTipsView