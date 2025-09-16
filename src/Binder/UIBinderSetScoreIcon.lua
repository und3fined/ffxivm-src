---
--- Author: enqingchen
--- DateTime: 2022-02-17 20:13
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local ScoreMgr = require("Game/Score/ScoreMgr")

---@class UIBinderSetScoreIcon : UIBinder
local UIBinderSetScoreIcon = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UImage
function UIBinderSetScoreIcon:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetScoreIcon:OnValueChanged(NewValue, OldValue)
	if NewValue == nil then
		return
	end

	local IconPath = ScoreMgr:GetScoreIconName(NewValue)

	UIUtil.ImageSetBrushFromAssetPath(self.Widget, IconPath)
end

return UIBinderSetScoreIcon