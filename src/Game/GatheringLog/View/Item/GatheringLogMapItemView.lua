---
--- Author: Leo
--- DateTime: 2023-03-29 10:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class GatheringLogMapItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnMap UFButton
---@field ImgBg UFImage
---@field SpacerInterval USpacer
---@field SpacerItem USpacer
---@field TextMap UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringLogMapItemView = LuaClass(UIView, true)

function GatheringLogMapItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnMap = nil
	--self.ImgBg = nil
	--self.SpacerInterval = nil
	--self.SpacerItem = nil
	--self.TextMap = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringLogMapItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringLogMapItemView:OnInit()
	self.Binders = {
		{ "TabName", UIBinderSetText.New(self, self.TextMap) },
		{ "bSpaceVisible", UIBinderSetIsVisible.New(self, self.SpacerInterval) },

	}
end

function GatheringLogMapItemView:OnDestroy()

end

function GatheringLogMapItemView:OnShow()

end

function GatheringLogMapItemView:OnHide()

end

function GatheringLogMapItemView:OnRegisterUIEvent()

end

function GatheringLogMapItemView:OnRegisterGameEvent()

end

function GatheringLogMapItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return GatheringLogMapItemView