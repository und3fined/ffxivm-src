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

---@class WorldVisitSeverItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSever UFImage
---@field ImgSeverState UFImage
---@field TextSever2 UFTextBlock
---@field TextState UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldVisitSeverItemView = LuaClass(UIView, true)

function WorldVisitSeverItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSever = nil
	--self.ImgSeverState = nil
	--self.TextSever2 = nil
	--self.TextState = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldVisitSeverItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldVisitSeverItemView:OnInit()
	self.Binders = {
		{"ServerTitle", UIBinderSetText.New(self, self.TextState) },
		{"ServerState", UIBinderSetImageBrush.New(self, self.ImgSeverState)},
		{"SubServerName", UIBinderSetText.New(self, self.TextSever2)},
		{"ServerImg", UIBinderSetImageBrush.New(self, self.ImgSever)},
		{"IsShowServerImg", UIBinderSetIsVisible.New(self, self.ImgSever)}
	}
end

function WorldVisitSeverItemView:OnDestroy()

end

function WorldVisitSeverItemView:OnShow()

end

function WorldVisitSeverItemView:OnHide()

end

function WorldVisitSeverItemView:OnRegisterUIEvent()

end

function WorldVisitSeverItemView:OnRegisterGameEvent()

end

function WorldVisitSeverItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end

	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return WorldVisitSeverItemView