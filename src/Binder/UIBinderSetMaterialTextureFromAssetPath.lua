---
--- Author: anypkvcai
--- DateTime: 2021-04-26 16:57
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetMaterialTextureFromAssetPath : UIBinder
local UIBinderSetMaterialTextureFromAssetPath = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetMaterialTextureFromAssetPath:Ctor(View, Widget, TextureParamName)
	self.TextureParamName = TextureParamName
end

---OnValueChanged
---@param NewValue string
---@param OldValue string
function UIBinderSetMaterialTextureFromAssetPath:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end

	local AssetPath = NewValue
	if string.isnilorempty(AssetPath) then
		return
	end

	UIUtil.ImageSetMaterialTextureFromAssetPathSync(self.Widget, AssetPath, self.TextureParamName)
end

return UIBinderSetMaterialTextureFromAssetPath