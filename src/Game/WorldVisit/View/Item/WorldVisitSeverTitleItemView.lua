---
--- Author: Administrator
--- DateTime: 2025-02-10 14:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class WorldVisitSeverTitleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextState UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldVisitSeverTitleItemView = LuaClass(UIView, true)

function WorldVisitSeverTitleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextState = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldVisitSeverTitleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldVisitSeverTitleItemView:OnInit()
	self.Binders = {
		{"ServerTitle", UIBinderSetText.New(self, self.TextState) },
	}
end

function WorldVisitSeverTitleItemView:OnDestroy()

end

function WorldVisitSeverTitleItemView:OnShow()

end

function WorldVisitSeverTitleItemView:OnHide()

end

function WorldVisitSeverTitleItemView:OnRegisterUIEvent()

end

function WorldVisitSeverTitleItemView:OnRegisterGameEvent()

end

function WorldVisitSeverTitleItemView:OnRegisterBinder()
	if not self.Params or not self.Params.Data then
		return
	end

	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return WorldVisitSeverTitleItemView