---
--- Author: loiafeng
--- DateTime: 2024-03-14 13:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SettingColorItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgColor UFImage
---@field ImgPressed UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingColorItemView = LuaClass(UIView, true)

function SettingColorItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgColor = nil
	--self.ImgPressed = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingColorItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingColorItemView:OnInit()

end

function SettingColorItemView:OnDestroy()

end

function SettingColorItemView:OnShow()
	local Params = self.Params
	local ColorCfg = Params and Params.Data
	local PaletteColor = ColorCfg and ColorCfg.Palette or "ffffffff"

	UIUtil.ImageSetColorAndOpacityHex(self.ImgColor, PaletteColor)
end

function SettingColorItemView:OnHide()

end

function SettingColorItemView:OnRegisterUIEvent()

end

function SettingColorItemView:OnRegisterGameEvent()

end

function SettingColorItemView:OnRegisterBinder()

end

function SettingColorItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.ImgPressed, IsSelected)
end

return SettingColorItemView