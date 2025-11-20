---
--- Author: Administrator
--- DateTime: 2025-07-31 16:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class NightGiftRecordListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NightGiftRecordListItemView = LuaClass(UIView, true)

function NightGiftRecordListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NightGiftRecordListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NightGiftRecordListItemView:OnInit()
	self.Binders = {
		{ "TitleName", UIBinderSetText.New(self, self.TextTitle) },
		
	}
end

function NightGiftRecordListItemView:OnDestroy()

end

function NightGiftRecordListItemView:OnShow()

end

function NightGiftRecordListItemView:OnHide()

end

function NightGiftRecordListItemView:OnRegisterUIEvent()

end

function NightGiftRecordListItemView:OnRegisterGameEvent()

end

function NightGiftRecordListItemView:OnRegisterBinder()
	local Params = self.Params
	if not Params then return end
		
	local ViewModel = Params.Data

	self:RegisterBinders(ViewModel, self.Binders)
end

return NightGiftRecordListItemView