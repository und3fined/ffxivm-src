---
--- Author: ds_tianjiateng
--- DateTime: 2024-12-18 16:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class StoreNewListTitleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextListTile UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreNewListTitleItemView = LuaClass(UIView, true)

function StoreNewListTitleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextListTile = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreNewListTitleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreNewListTitleItemView:OnInit()
	self.Binders = {
		{ "TittleText", UIBinderSetText.New(self, self.TextListTile) },
	}
end

function StoreNewListTitleItemView:OnDestroy()

end

function StoreNewListTitleItemView:OnShow()

end

function StoreNewListTitleItemView:OnHide()

end

function StoreNewListTitleItemView:OnRegisterUIEvent()

end

function StoreNewListTitleItemView:OnRegisterGameEvent()

end

function StoreNewListTitleItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data
	self:RegisterBinders(ViewModel, self.Binders)
end

return StoreNewListTitleItemView