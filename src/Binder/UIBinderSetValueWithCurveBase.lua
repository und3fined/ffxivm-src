local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")

local UIBinderSetValueWithCurveBase = LuaClass(UIBinder)

-- Timer的间隔
local Interval = 0.05

---Ctor
---@param View UIView
---@param Widget UUserWidget
---@param Curve UCurveFloat 可以传个nil, 如果为nil就线性变化
---@param FixedMoveTime number 如果该值不为nil, 移动到终点采用固定的时间
---@param FixedMoveSpeed number 如果改值不为nil, 移动到终点的时间根据移动的距离而定
---@param TickValueFunc function 值变化时调用的回调
---@param InitValue function 初始值
function UIBinderSetValueWithCurveBase:Ctor(View, Widget, Curve, FixedMoveTime, FixedMoveSpeed, TickValueFunc, InitValue)
    self.Curve = Curve
    self.FixedMoveTime = FixedMoveTime
    self.FixedMoveSpeed = FixedMoveSpeed
    self.TickValueFunc = TickValueFunc
    self.InitValue = InitValue or 0
    self.CurrentValue = self.InitValue
end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetValueWithCurveBase:OnValueChanged(NewValue, OldValue)
    local Widget = self.Widget
    local View = self.View
    local TickValueFunc = self.TickValueFunc
	if nil == Widget or nil == View or nil == TickValueFunc then
		return
	end

    if self.bDisableTimer then
        TickValueFunc(NewValue)
        return
    end

	local CurrentValue = self.CurrentValue
    local ValueDiff = NewValue - CurrentValue
    local MoveTime = nil

    if self.FixedMoveTime then
        MoveTime = self.FixedMoveTime
    elseif self.FixedMoveSpeed then
        MoveTime = math.abs(ValueDiff) / self.FixedMoveSpeed
    end

    if self.TimerID then
        View:UnRegisterTimer(self.TimerID)
        self.TimerID = nil
    end

    if MoveTime then
        self.TimerID = View:RegisterTimer(function(_, _, ElapsedTime)
            if nil == Widget then
                return
            end

            local Curve = self.Curve
            local MovePercent = math.clamp(ElapsedTime / MoveTime, 0, 1)
            local CurveFloatValue
            if Curve then
                CurveFloatValue = Curve:GetFloatValue(MovePercent)
            else
                CurveFloatValue = MovePercent
            end
            local Value = CurrentValue + ValueDiff * CurveFloatValue
            self.CurrentValue = Value
            TickValueFunc(Value)
        end, 0, Interval, math.ceil(MoveTime / Interval) + 1)  -- 多跑一帧, 保证能到终点
    else
	    TickValueFunc(NewValue)
    end
end

return UIBinderSetValueWithCurveBase