local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local UIUtil = require("Utils/UIUtil")
local ObjectGCType = require("Define/ObjectGCType")

---@class UIBinderSetBrushFromMaterial : UIBinder
local UIBinderSetBrushFromMaterial = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
---@param TexParam string | nil
function UIBinderSetBrushFromMaterial:Ctor(View, Widget, TexParam)
	self.TexParam = TexParam or "Texture"
end

---OnValueChanged
---@param NewValue string
---@param OldValue string
function UIBinderSetBrushFromMaterial:OnValueChanged(NewValue, OldValue)
	local Widget = self.Widget
	if nil == Widget then
		return
	end

	local AssetPath = NewValue
	if nil == AssetPath then
		return
	end

	if not string.isnilorempty(AssetPath) then
		if nil == _G.ObjectMgr:GetObject(AssetPath) then
			UIUtil.SetIsVisible(Widget, false)
		end

		local function Callback()
			if nil == Widget or not Widget:IsValid() then
				return
			end

			local Object = _G.ObjectMgr:GetObject(AssetPath)
			local DynamicMat = Widget:GetDynamicMaterial()
			if nil == DynamicMat then
				_G.FLOG_ERROR("UIBinderSetBrushFromMaterial:OnValueChanged(): Invalid DynamicMaterial.")
				return
			end

			DynamicMat:SetTextureParameterValue(self.TexParam, Object)
			Widget:SetBrushFromMaterial(DynamicMat)
			UIUtil.SetIsVisible(Widget, true)
		end

		_G.ObjectMgr:LoadObjectAsync(AssetPath, Callback, ObjectGCType.LRU)
	end
end

return UIBinderSetBrushFromMaterial