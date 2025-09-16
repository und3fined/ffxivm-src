--
-- Author: enqingchen
-- Date: 2022-06-21 15:45:51
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local FLinearColor = _G.UE.FLinearColor

---@class UIBinderSetCost : UIBinder
local UIBinderSetCost = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UUserWidget
function UIBinderSetCost:Ctor(View, Widget, Format, ScoreID)
	self.Format = Format
    self.ScoreID = ScoreID
    self.OriginColor = Widget.ColorAndOpacity:GetSpecifiedColor()
end

---OnValueChanged
---@param NewValue boolean
---@param OldValue boolean
function UIBinderSetCost:OnValueChanged(NewValue, OldValue)
	if nil == self.Widget then
		return
	end
	self.Widget:SetText(string.format(self.Format, NewValue))
    self.ScoreValue = _G.ScoreMgr:GetScoreValueByID(self.ScoreID)
    if self.ScoreValue == nil or self.ScoreValue < 0 then
        self.ScoreValue = 0
    end

    local LinearColor
    if NewValue >= self.ScoreValue then
        LinearColor = FLinearColor.FromHex("B33939FF")
    else
		LinearColor = self.OriginColor
    end
	self.Widget:SetColorAndOpacity(LinearColor)

end

return UIBinderSetCost