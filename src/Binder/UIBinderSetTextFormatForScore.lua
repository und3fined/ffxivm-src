local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local ScoreMgr = require("Game/Score/ScoreMgr")

---@class UIBinderSetTextFormatForScore : UIBinder
local UIBinderSetTextFormatForScore = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UTextBlock
function UIBinderSetTextFormatForScore:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetTextFormatForScore:OnValueChanged(NewValue, OldValue)
	if nil == NewValue then
		return
	end

	self.Widget:SetText(ScoreMgr.FormatScore(NewValue))
end

return UIBinderSetTextFormatForScore