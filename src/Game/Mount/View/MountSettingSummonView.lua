---
--- Author: chunfengluo
--- DateTime: 2023-08-03 10:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local MountSettingTipsVM = require("Game/Mount/VM/MountSettingTipsVM")
local MountVM = require("Game/Mount/VM/MountVM")

local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")


---@class MountSettingSummonView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountSettingSummonView = LuaClass(UIView, true)

function MountSettingSummonView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountSettingSummonView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountSettingSummonView:OnInit()
	self.ViewModel = MountSettingTipsVM.New()
	self.TableView = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, false)
	self.TableView:SetScrollbarIsVisible(false)

	self.TextSetting:SetText(LSTR(1090021))
end

function MountSettingSummonView:OnDestroy()

end

function MountSettingSummonView:OnShow()

end

function MountSettingSummonView:OnHide()

end

function MountSettingSummonView:OnRegisterUIEvent()

end

function MountSettingSummonView:OnRegisterGameEvent()

end

function MountSettingSummonView:OnRegisterBinder()
	local Binders = {
		{ "ListSettingTipsItemVM", UIBinderUpdateBindableList.New(self, self.TableView) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

return MountSettingSummonView