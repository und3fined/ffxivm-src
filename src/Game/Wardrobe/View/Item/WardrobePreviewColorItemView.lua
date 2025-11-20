---
--- Author: Administrator
--- DateTime: 2025-08-05 11:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class WardrobePreviewColorItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextTitle UFTextBlock
---@field WardrobeStainStyleI1 WardrobeStainStyleItemView
---@field WardrobeStainStyleI2 WardrobeStainStyleItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobePreviewColorItemView = LuaClass(UIView, true)

function WardrobePreviewColorItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextTitle = nil
	--self.WardrobeStainStyleI1 = nil
	--self.WardrobeStainStyleI2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobePreviewColorItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.WardrobeStainStyleI1)
	self:AddSubView(self.WardrobeStainStyleI2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobePreviewColorItemView:OnInit()
	self.Binders = {
		{"SectionName", UIBinderSetText.New(self, self.TextTitle)},
	}
end

function WardrobePreviewColorItemView:OnDestroy()

end

function WardrobePreviewColorItemView:OnShow()

end

function WardrobePreviewColorItemView:OnHide()

end

function WardrobePreviewColorItemView:OnRegisterUIEvent()

end

function WardrobePreviewColorItemView:OnRegisterGameEvent()

end

function WardrobePreviewColorItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	if ViewModel.ColorVM ~= nil then
	self.WardrobeStainStyleI1:SetParams({Data = ViewModel.ColorVM})
	end
	if ViewModel.PreColorVM ~= nil then
	self.WardrobeStainStyleI2:SetParams({Data = ViewModel.PreColorVM})
	end
end

return WardrobePreviewColorItemView