---
--- Author: usakizhang
--- DateTime: 2025-03-05 16:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
---@class OpsCeremonyPartiesItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBanner UFImage
---@field TextDescribe UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCeremonyPartiesItemView = LuaClass(UIView, true)

function OpsCeremonyPartiesItemView:Ctor()

end

function OpsCeremonyPartiesItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCeremonyPartiesItemView:OnInit()
	self.Binders = {
		{"TitleText", UIBinderSetText.New(self, self.TextTitle)},
		{"DescribeText", UIBinderSetText.New(self, self.TextDescribe)},
		{"Icon", UIBinderValueChangedCallback.New(self, nil, self.OnIconChanged)},
	}
end

function OpsCeremonyPartiesItemView:OnDestroy()
	
end

function OpsCeremonyPartiesItemView:OnShow()
end

function OpsCeremonyPartiesItemView:OnHide()

end

function OpsCeremonyPartiesItemView:OnRegisterUIEvent()

end

function OpsCeremonyPartiesItemView:OnRegisterGameEvent()

end

function OpsCeremonyPartiesItemView:OnRegisterBinder()
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

function OpsCeremonyPartiesItemView:OnIconChanged(Icon)
	UIUtil.ImageSetMaterialTextureFromAssetPathSync(self.ImgBanner, Icon, "Texture")
end
return OpsCeremonyPartiesItemView