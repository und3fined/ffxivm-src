---
--- Author: Administrator
--- DateTime: 2024-05-09 11:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class ArmyClassAuthorityItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyClassAuthorityItemView = LuaClass(UIView, true)

function ArmyClassAuthorityItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyClassAuthorityItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyClassAuthorityItemView:OnInit()
	self.Binders = {
		{ "PermissionsIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
		{ "Name", UIBinderSetText.New(self, self.Text01)},
		{ "PermissionsStr", UIBinderSetText.New(self, self.Text02)},
	}
end

function ArmyClassAuthorityItemView:OnDestroy()

end

function ArmyClassAuthorityItemView:OnShow()

end

function ArmyClassAuthorityItemView:OnHide()

end

function ArmyClassAuthorityItemView:OnRegisterUIEvent()

end

function ArmyClassAuthorityItemView:OnRegisterGameEvent()

end

function ArmyClassAuthorityItemView:OnRegisterBinder()
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

return ArmyClassAuthorityItemView