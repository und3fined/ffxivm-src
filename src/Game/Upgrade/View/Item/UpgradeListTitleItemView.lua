---
--- Author: yutingzhan
--- DateTime: 2025-03-13 15:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")

---@class UpgradeListTitleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextListTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local UpgradeListTitleItemView = LuaClass(UIView, true)

function UpgradeListTitleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextListTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function UpgradeListTitleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function UpgradeListTitleItemView:OnInit()
	self.Binders = {
		{"TaskTitle", UIBinderSetText.New(self, self.TextListTitle)},
	}
end

function UpgradeListTitleItemView:OnDestroy()

end

function UpgradeListTitleItemView:OnShow()

end

function UpgradeListTitleItemView:OnHide()

end

function UpgradeListTitleItemView:OnRegisterUIEvent()

end

function UpgradeListTitleItemView:OnRegisterGameEvent()

end

function UpgradeListTitleItemView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end

	local ViewModel = self.Params.Data

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)
end

return UpgradeListTitleItemView