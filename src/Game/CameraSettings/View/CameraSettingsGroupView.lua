---
--- Author: zimuyi
--- DateTime: 2023-08-22 11:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class CameraSettingsGroupView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewProperties UTableView
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CameraSettingsGroupView = LuaClass(UIView, true)

function CameraSettingsGroupView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewProperties = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CameraSettingsGroupView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CameraSettingsGroupView:OnInit()
	self.AdapterTableViewProps = UIAdapterTableView.CreateAdapter(self, self.TableViewProperties)
	self.Binders =
	{
		{ "GroupName", UIBinderSetText.New(self, self.TextTitle) },
		{ "PropertyVMList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewProps) },
	}
end

function CameraSettingsGroupView:OnDestroy()

end

function CameraSettingsGroupView:OnShow()

end

function CameraSettingsGroupView:OnHide()

end

function CameraSettingsGroupView:OnRegisterUIEvent()

end

function CameraSettingsGroupView:OnRegisterGameEvent()

end

function CameraSettingsGroupView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end
	self.ViewModel = self.Params.Data
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return CameraSettingsGroupView