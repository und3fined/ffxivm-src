---
--- Author: Administrator
--- DateTime: 2024-06-04 14:59
--- Description:
---特效组Item

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
---@class ArmySpecialEffectsItem03View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---@field TextCount UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmySpecialEffectsItem03View = LuaClass(UIView, true)

function ArmySpecialEffectsItem03View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--self.TextCount = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmySpecialEffectsItem03View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmySpecialEffectsItem03View:OnInit()
    self.Binders = {
		--{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)}, 
		{"Count", UIBinderSetText.New(self, self.TextCount)}, 
		{"IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)}, 
		{"IsHave", UIBinderValueChangedCallback.New(self, nil, self.OnSetGrey)}, 
    }
end

function ArmySpecialEffectsItem03View:OnDestroy()

end

function ArmySpecialEffectsItem03View:OnShow()

end

function ArmySpecialEffectsItem03View:OnHide()

end

function ArmySpecialEffectsItem03View:OnRegisterUIEvent()

end

function ArmySpecialEffectsItem03View:OnRegisterGameEvent()

end

---设置灰态
function ArmySpecialEffectsItem03View:OnSetGrey(IsHave)
	local IsGrey = not IsHave
	if self.ImgIcon and self.ViewModel.Icon then
		UIUtil.SetImageDesaturate(self.ImgIcon, self.ViewModel.Icon, IsGrey and 1 or 0, true)
	end
end

function ArmySpecialEffectsItem03View:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return ArmySpecialEffectsItem03View