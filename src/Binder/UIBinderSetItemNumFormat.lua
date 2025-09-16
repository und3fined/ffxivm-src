local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local CommonUtil = require("Utils/CommonUtil")

local NumberTable = nil
---@class UIBinderSetItemNumFormat : UIBinder
local UIBinderSetItemNumFormat = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UTextBlock
function UIBinderSetItemNumFormat:Ctor(View, Widget)
end

---OnValueChanged
---@param NewValue Number
---@param OldValue Number
function UIBinderSetItemNumFormat:OnValueChanged(NewValue, OldValue)
	if nil == NewValue then
		return
	end

	local Text = self:ParseTheValue(NewValue)

	self.Widget:SetText(Text)
end

function UIBinderSetItemNumFormat:ParseTheValue(NewValue)
	if type(NewValue) == "number" then
		return self:GetText(NewValue)
	elseif type(NewValue) == "string" then
		local SplitList = string.split(NewValue, "/")
		if #SplitList == 2 then
			local NumFront = tonumber(SplitList[1])
			local NumBehind = tonumber(SplitList[2])
			if NumFront and NumBehind then
				return string.format("%s/%s", self:GetText(NumFront), self:GetText(NumBehind))
			end
		end
	end
	return ""
end

---GetText
---@param NewValue Number
function UIBinderSetItemNumFormat:GetText(NewValue)
	local iCount = 0
	if NewValue == 0 then
		return string.format("%d", NewValue)
	end
	
	if NewValue // 1000000 == 0 then
		-- 6位数以内
		local a = NewValue
		NumberTable = {}
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
		---concat
		local Text = table.concat(NumberTable)
		return Text
	elseif NewValue // 100000000 == 0 then
			-- 8位数以内
			local Text = CommonUtil.IsCurCultureChinese() and  string.format(_G.LSTR(1020062), NewValue // 10000) or string.format("%dm", NewValue // 1000000)
			return Text
	else
		--8位数以上
		local Text = CommonUtil.IsCurCultureChinese() and  string.format(_G.LSTR(1020063), NewValue // 100000000) or string.format("%dm", NewValue // 1000000)
		return Text
	end
end

return UIBinderSetItemNumFormat