--
-- Author: enqingchen
-- Date: 2022-02-16 15:45:51
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

local NumberTable = nil
---@class UIBinderSetTextFormatForMoney : UIBinder
local UIBinderSetTextFormatForMoney = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UTextBlock
function UIBinderSetTextFormatForMoney:Ctor(View, Widget)
end

---OnValueChanged
---@param NewValue Number
---@param OldValue Number
function UIBinderSetTextFormatForMoney:OnValueChanged(NewValue, OldValue)
	if nil == NewValue then
		return
	end

	local Text = self:GetText(NewValue)

	self.Widget:SetText(Text)
end

---GetText
---@param NewValue Number
function UIBinderSetTextFormatForMoney:GetText(NewValue)
	local NumberValue = _G.math.abs(NewValue)
	local a, b = _G.math.modf(NumberValue)
	if NewValue < 0 then
		NumberTable = a == 0 and { "-0" } or { "-" }
	else
		NumberTable = a == 0 and { "0" } or { "" }
	end

	local iCount = 0
	--整数部分处理
	while (a > 0) do
		NumberTable[#NumberTable + 1] = tostring(a % 10)
		a = _G.math.modf(a / 10)
		iCount = iCount + 1
		if a > 0 and iCount % 3 == 0 then
			NumberTable[#NumberTable + 1] = ","
		end
	end
	--倒序
	local iNumberCount = #NumberTable
	local Temp
	for i = 1, iNumberCount / 2 do
		Temp = NumberTable[i]
		NumberTable[i] = NumberTable[iNumberCount - i + 1]
		NumberTable[iNumberCount - i + 1] = Temp
	end
	--小数部分拼接,保留小数点后2位
	if (b > 0) then
		b = _G.math.modf(b * 100)
		NumberTable[#NumberTable + 1] = "."
		if b % 10 == 0 then
			NumberTable[#NumberTable + 1] = b / 10
		else
			NumberTable[#NumberTable + 1] = b
		end
	end
	---concat
	local Text = table.concat(NumberTable)
	return Text
end

return UIBinderSetTextFormatForMoney