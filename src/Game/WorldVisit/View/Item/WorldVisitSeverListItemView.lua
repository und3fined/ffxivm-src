---
--- Author: Administrator
--- DateTime: 2025-02-10 14:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class WorldVisitSeverListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSever UFImage
---@field ImgSeverState UFImage
---@field TextSever UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldVisitSeverListItemView = LuaClass(UIView, true)

function WorldVisitSeverListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSever = nil
	--self.ImgSeverState = nil
	--self.TextSever = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldVisitSeverListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldVisitSeverListItemView:OnInit()
	self.Binders = {
		{"ServerTitle", UIBinderSetText.New(self, self.TextSever) },
		{"ServerState", UIBinderSetImageBrush.New(self, self.ImgSeverState)},
		{"ServerImg", UIBinderSetImageBrush.New(self, self.ImgSever)},
		{"IsShowServerImg", UIBinderSetIsVisible.New(self, self.ImgSever)}
	}
end

function WorldVisitSeverListItemView:OnDestroy()

end

function WorldVisitSeverListItemView:OnShow()

end

function WorldVisitSeverListItemView:OnHide()

end

function WorldVisitSeverListItemView:OnRegisterUIEvent()

end

function WorldVisitSeverListItemView:OnRegisterGameEvent()

end

function WorldVisitSeverListItemView:OnRegisterBinder()
	if not self.Params or not self.Params.Data then
		return
	end

	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return WorldVisitSeverListItemView