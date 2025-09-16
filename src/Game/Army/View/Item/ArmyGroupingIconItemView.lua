---
--- Author: Administrator
--- DateTime: 2024-05-10 17:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class ArmyGroupingIconItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field BtnSwitch UFButton
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyGroupingIconItemView = LuaClass(UIView, true)

function ArmyGroupingIconItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.BtnSwitch = nil
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyGroupingIconItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyGroupingIconItemView:OnInit()
    self.Binders = {
        {"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
        {"bUsed", UIBinderSetIsVisible.New(self, self.BtnSwitch)},
		{"bSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
    }
end

function ArmyGroupingIconItemView:OnDestroy()

end

function ArmyGroupingIconItemView:OnShow()

end

function ArmyGroupingIconItemView:OnHide()

end

function ArmyGroupingIconItemView:OnRegisterUIEvent()

end

function ArmyGroupingIconItemView:OnRegisterGameEvent()

end

function ArmyGroupingIconItemView:OnRegisterBinder()
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

return ArmyGroupingIconItemView