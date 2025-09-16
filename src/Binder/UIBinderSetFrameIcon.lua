---
--- Author: andre_lightpaw
--- DateTime: 2021-04-13 20:13
--- Description: 设置头像框
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local HeadFrameCfg = require("TableCfg/HeadFrameCfg")
local UIUtil = require("Utils/UIUtil")

---@class UIBinderSetFrameIcon : UIBinder
local UIBinderSetFrameIcon = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetFrameIcon:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetFrameIcon:OnValueChanged(NewValue, OldValue)
	if NewValue == nil then
		return
	end

	local FrameID = NewValue
	local Cfg = HeadFrameCfg:FindCfgByKey(FrameID)

    if Cfg then
        UIUtil.ImageSetBrushFromAssetPath(self.Widget, Cfg.FrameIcon)
    end
end

return UIBinderSetFrameIcon