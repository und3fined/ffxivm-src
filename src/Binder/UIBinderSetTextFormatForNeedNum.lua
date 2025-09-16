local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local RichTextUtil = require("Utils/RichTextUtil")

local NumMax = 999
---@class UIBinderSetTextFormatForNeedNum : UIBinder
local UIBinderSetTextFormatForNeedNum = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UTextBlock
function UIBinderSetTextFormatForNeedNum:Ctor(View, Widget)
	self.TotalNum = NumMax
end

function UIBinderSetTextFormatForNeedNum:SetTotalNum(Total)
	self.TotalNum = Total
	if Total > NumMax then
		self.TotalNum = NumMax
	end
end

---OnValueChanged
---@param NewValue Number
---@param OldValue Number
function UIBinderSetTextFormatForNeedNum:OnValueChanged(NewValue, OldValue)
	if nil == NewValue then
		return
	end

	local Text = self:GetText(NewValue)

	self.Widget:SetText(Text)
end

---GetText
---@param NewValue Number
function UIBinderSetTextFormatForNeedNum:GetText(NewValue)
	if self.TotalNum == nil then
		return ""
	end

	if NewValue > NumMax then
		NewValue = NumMax
	end

	if NewValue >= self.TotalNum then
		return string.format("%d/%d", NewValue, self.TotalNum )
	end

	local curNumRichText = RichTextUtil.GetText(string.format("%d", NewValue), "dc5868", 0, nil)
    return string.format("%s/%d", curNumRichText, self.TotalNum)

end

return UIBinderSetTextFormatForNeedNum