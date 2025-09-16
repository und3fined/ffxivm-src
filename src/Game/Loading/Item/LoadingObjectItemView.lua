---
--- Author: loiafeng
--- DateTime: 2024-05-09 10:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LoadingVM = require("Game/Loading/LoadingVM")

local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local ProtoRes = require("Protocol/ProtoRes")
local LOADING_TYPE = ProtoRes.LoadingType

---@class LoadingObjectItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Img UFImage
---@field ImgFish UFImage
---@field ImgMonster UFImage
---@field Title LoadingTitleItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoadingObjectItemView = LuaClass(UIView, true)

function LoadingObjectItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Img = nil
	--self.ImgFish = nil
	--self.ImgMonster = nil
	--self.Title = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoadingObjectItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Title)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoadingObjectItemView:OnInit()
	self.Binders = {
		{ "MainImage", UIBinderValueChangedCallback.New(self, nil, self.MainImageChangedCallback) },
	}
end

function LoadingObjectItemView:OnDestroy()

end

function LoadingObjectItemView:OnShow()

end

function LoadingObjectItemView:OnHide()

end

function LoadingObjectItemView:OnRegisterUIEvent()

end

function LoadingObjectItemView:OnRegisterGameEvent()

end

function LoadingObjectItemView:OnRegisterBinder()
	self:RegisterBinders(LoadingVM, self.Binders)
end

function LoadingObjectItemView:MainImageChangedCallback(NewValue)
	if string.isnilorempty(NewValue) then
		return
	end

	local LoadingType = LoadingVM.LoadingType or LOADING_TYPE.LOADING_NONE

	local IsCharacter = LOADING_TYPE.LOADING_CHARACTER == LoadingType
	local IsFish = LOADING_TYPE.LOADING_FISH == LoadingType
	local IsMonster = LOADING_TYPE.LOADING_TRIBAL == LoadingType or LOADING_TYPE.LOADING_MONSTER == LoadingType

	UIUtil.SetIsVisible(self.Img, IsCharacter)
	UIUtil.SetIsVisible(self.ImgFish, IsFish)
	UIUtil.SetIsVisible(self.ImgMonster, IsMonster)

	local Widget = IsCharacter and self.Img or (IsFish and self.ImgFish or (IsMonster and self.ImgMonster or nil))

	if Widget then
		UIUtil.ImageSetBrushFromAssetPathSync(Widget, NewValue)
	else
		FLOG_ERROR("LoadingObjectItemView.MainImageChangedCallback: Error LoadingType: " .. LoadingType)
	end
end

return LoadingObjectItemView