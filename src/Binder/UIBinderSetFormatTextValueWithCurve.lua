local LuaClass = require("Core/LuaClass")
local UIBinderSetValueWithCurveBase = require("Binder/UIBinderSetValueWithCurveBase")

local UIBinderSetFormatTextValueWithCurve = LuaClass(UIBinderSetValueWithCurveBase)



---Ctor
---@param View UIView
---@param Widget UTextBlock
---@param Curve UCurveFloat 可以传个nil, 如果为nil就线性变化
---@param FixedMoveTime number 如果该值不为nil, 移动到终点采用固定的时间
---@param FixedMoveSpeed number 如果改值不为nil, 移动到终点的时间根据移动的距离而定
---@param bIsInteger bool 是否是整数(或者小数)
function UIBinderSetFormatTextValueWithCurve:Ctor(View, Widget, Curve, FixedMoveTime, FixedMoveSpeed, Format, InitValue, bIsInteger)
    Format = Format or "%d"
    InitValue = InitValue or 0
    bIsInteger = bIsInteger or true
    self.TickValueFunc = function(Value)
        if bIsInteger then
            Value = math.floor(Value)
        end
        local Text = string.format(Format, Value)
        Widget:SetText(Text)
    end
    self.TickValueFunc(InitValue)

    self.InitValue = InitValue
    self.CurrentValue = self.InitValue
end

return UIBinderSetFormatTextValueWithCurve