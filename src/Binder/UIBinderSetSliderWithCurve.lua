-- 让Slider按照曲线进行平滑移动的类
-- 曲线的x和y都在0~1之间, x表示时间, 0表示开始移动的时间, 1表示结束移动的时间
-- 曲线的y表示移动的距离, 0表示开始移动时Slider的值, 1表示结束移动时Slider的值
-- FixedMoveTime和FixedMoveSpeed和移动速度有关, 只需设置一个有值即可, 另一个为nil
-- FixedMoveTime表示Slider从开始移动到结束移动经历固定的时间
-- FixedMoveSpeed表示Slider从开始移动到结束移动经历的时间为 Diff / FixedMoveSpeed (Diff为Slider值的变化)



local LuaClass = require("Core/LuaClass")
local UIBinderSetValueWithCurveBase = require("Binder/UIBinderSetValueWithCurveBase")

local UIBinderSetSliderWithCurve = LuaClass(UIBinderSetValueWithCurveBase)



---Ctor
---@param View UUserWidget
---@param Widget USlider | UFSlider
---@param Curve UCurveFloat 如果Widget为UFSlider类型, 则不需要指定Curve及后面的参数
---@param FixedMoveTime number 如果该值不为nil, 移动到终点采用固定的时间
---@param FixedMoveSpeed number 如果改值不为nil, 移动到终点的时间根据移动的距离而定
function UIBinderSetSliderWithCurve:Ctor(View, Widget, Curve, FixedMoveTime, FixedMoveSpeed)
    -- 如果使用的是FSlider, 使用C++侧的SetValue进行更新
    if Widget ~= nil and Widget.__name == "UFSlider" then
        self.bDisableTimer = true
        self.TickValueFunc = function(Value)
            Widget:SetValueWithCurve(Value)
        end
    else
        self.TickValueFunc = function(Value)
            Widget:SetValue(Value)
        end
    end

    self.InitValue = Widget:GetValue()
    self.CurrentValue = self.InitValue
end

return UIBinderSetSliderWithCurve