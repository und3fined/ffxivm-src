--
-- Author: anypkvcai
-- Date: 2023-04-13 15:49
-- Description:
--


---@class MathUtil
local MathUtil = {

}

function MathUtil.IsNearlyEqual(X, Y, Epsilon)
	if nil == Epsilon then
		Epsilon = 0.001
	end
	return math.abs(X - Y) <= Epsilon
end

function MathUtil.GetAngle(X, Y)
	local Radians = math.atan(Y, X)
	return (math.deg(Radians) + 360) % 360
end

function MathUtil.FloorLog2(Val)
	local Result = 0
    Val = Val + 1
    while Val > 1 do
        Val = Val / 2
        Result = Result + 1
    end
    return Result - 1
end

--- 匀减速运动至停止计算加速度
---@param S number@减速移动距离
---@param V number@减速移动初速度
---@return number@减速加速度
function MathUtil.GetAccelerationInDecelerationMotion(S, V)
    if not S or not V then
        return
    end
    return -1 * V * V /(2 * S)
end

--- 匀减速运动至停止计算加速度
---@param V number@减速移动初速度
---@param T number@减速移动时间
---@param A number@减速移动加速度
---@return number@减速移动当前移动距离
function MathUtil.GetMotionDisInDecelerationMotion(V, T, A)
    if not V or not T or not A then
        return
    end
    return V * T + A * T * T / 2
end

function MathUtil.Round(value, digits)
    return tonumber(string.format("%." .. digits .. "f", value))
end

-- 四舍五入
function MathUtil.RoundOff(Value)
	return math.floor(Value + 0.5)
end

--- 三维向量归一化
---@param X number@X坐标
---@param Y number@Y坐标
---@param Z number@Z坐标
---@return number, number, number @单位向量X, Y, Z
function MathUtil.Normalize(X, Y, Z)
    local SquareSum = X*X + Y*Y + Z*Z
    local Scale = 1 / math.sqrt(SquareSum)
    return X * Scale, Y * Scale, Z * Scale
end

--- 求三维坐标距离
---@param TableA table<X, Y, Z>@表<X,Y,Z>
---@param TableB table<X, Y, Z>@表<X,Y,Z>
function MathUtil.Dist(TableA, TableB)
    if not TableA or not TableB then
        return 0
    end
    local X1 = TableA.X or 0
    local Y1 = TableA.Y or 0
    local Z1 = TableA.Z or 0
    local X2 = TableB.X or 0
    local Y2 = TableB.Y or 0
    local Z2 = TableB.Z or 0
    local dx = X2 - X1
    local dy = Y2 - Y1
    local dz = Z2 - Z1
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--- 求Point点绕Center旋转Angle度后的坐标
function MathUtil.Rotate(Point, Center, Angle)
    local AngleRad = math.rad(Angle)
    local CosTheta = math.cos(AngleRad)
    local SinTheta = math.sin(AngleRad)

    local TranslatedX = Point.X - Center.X
    local TranslatedY = Point.Y - Center.Y

    local RotatedX = TranslatedX * CosTheta - TranslatedY * SinTheta
    local RotatedY = TranslatedX * SinTheta + TranslatedY * CosTheta

    local RotatePoint = { X = RotatedX + Center.X, Y = RotatedY + Center.Y, Z = Point.Z }

    return RotatePoint
end

--- 求Point是否在线段上（线段有宽度）
---@param px number
---@param py number
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param width number
---@return boolean
function MathUtil.IsPointOnLine(px, py, x1, y1, x2, y2, width)
    -- 计算线段向量
    local dx = x2 - x1
    local dy = y2 - y1
    local lengthSq = dx*dx + dy*dy  -- 线段长度的平方
    local radius = width / 2        -- 半径（线宽的一半）

    -- 处理线段退化为点的情况
    if lengthSq == 0 then
        local distSq = (px - x1)^2 + (py - y1)^2
        return distSq <= radius * radius
    end

    -- 计算投影参数t（限制在0-1之间）
    local t = ((px - x1)*dx + (py - y1)*dy) / lengthSq
    t = math.max(0, math.min(1, t))

    -- 计算最近点坐标
    local nearestX = x1 + t * dx
    local nearestY = y1 + t * dy

    -- 计算点到最近点的距离平方
    local distSq = (px - nearestX)^2 + (py - nearestY)^2

    -- 判断是否在半径范围内
    return distSq <= radius * radius
end

return MathUtil