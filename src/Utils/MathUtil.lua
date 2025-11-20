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

--- 覆盖全坐标系角度（-180 ~ 180 可以给设置TransformAngle使用）
function MathUtil.GetTransformAngle(X, Y)
	local Radians = math.atan(Y, X)
	return math.deg(Radians)
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

--- 二维向量叉乘公式
function MathUtil.CrossProduct2D(PointOrigin, PointA, PointB)
    return (PointA.X - PointOrigin.X) * (PointB.Y - PointOrigin.Y) - (PointA.Y - PointOrigin.Y) * (PointB.X - PointOrigin.X)
end

-- 定义向量操作函数
function MathUtil.Vector2DAdd(A, B)
    return {X = A.X + B.X, Y = A.Y + B.Y}
end

function MathUtil.Vector2DSub(A, B)
    return {X = A.X - B.X, Y = A.Y - B.Y}
end

function MathUtil.Vector2DDot(A, B)
    return A.X * B.X + A.Y * B.Y
end

function MathUtil.Vector2DLengthSquared(V)
    return V.X * V.X + V.Y * V.Y
end

function MathUtil.Vector2DRotate(V, Angle)
    local CosA = math.cos(Angle)
    local SinA = math.sin(Angle)
    return {
        X = V.X * CosA - V.Y * SinA,
        Y = V.X * SinA + V.Y * CosA
    }
end

--- 判断两条线段是否相交
---@param StartVecA table<X, Y>@线段A起始点
---@param EndVecA table<X, Y>@线段A结束点
---@param StartVecB table<X, Y>@线段B起始点
---@param EndVecB table<X, Y>@线段B结束点
function MathUtil.DoLinesIntersect(StartVecA, EndVecA, StartVecB, EndVecB)
    local CrossProduct1 = MathUtil.CrossProduct2D(StartVecA, EndVecA, StartVecB)
    local CrossProduct2 = MathUtil.CrossProduct2D(StartVecA, EndVecA, EndVecB)
    local CrossProduct3 = MathUtil.CrossProduct2D(StartVecB, EndVecB, StartVecA)
    local CrossProduct4 = MathUtil.CrossProduct2D(StartVecB, EndVecB, EndVecA)

    if CrossProduct1 * CrossProduct2 < 0 and CrossProduct3 * CrossProduct4 < 0 then
        return true -- 端点互项在两侧则必相交
    end

    -- 处理共线
    if CrossProduct1 == 0 and MathUtil.IsPointOnLine(StartVecB.X, StartVecB.Y, StartVecA.X, StartVecA.Y, EndVecA.X, EndVecA.Y, 0) then
        return true
    end
    if CrossProduct2 == 0 and MathUtil.IsPointOnLine(EndVecB.X, EndVecB.Y, StartVecA.X, StartVecA.Y, EndVecA.X, EndVecA.Y, 0) then
        return true
    end
    if CrossProduct3 == 0 and MathUtil.IsPointOnLine(StartVecA.X, StartVecA.Y, StartVecB.X, StartVecB.Y, EndVecB.X, EndVecB.Y, 0) then
        return true
    end
    if CrossProduct4 == 0 and MathUtil.IsPointOnLine(EndVecA.X, EndVecA.Y, StartVecB.X, StartVecB.Y, EndVecB.X, EndVecB.Y, 0) then
        return true
    end

    return false
end

--- 求线段是否与矩形相交（包括在矩形内部）
---@param StartVec 
function MathUtil.IsLineAcrossTheRect(StartVec, EndVec, RectCenter, RectSize, RectRotation)
    -- 计算区域码
    local function ComputeRegionCode(Point, RectMin, RectMax)
        local Code = 0
        if Point.X < RectMin.X then
            Code = Code | 1  -- LEFT
        elseif Point.X > RectMax.X then
            Code = Code | 2  -- RIGHT
        end
        if Point.Y < RectMin.Y then
            Code = Code | 4  -- BOTTOM
        elseif Point.Y > RectMax.Y then
            Code = Code | 8  -- TOP
        end
        return Code
    end

    -- 计算矩形的半宽和半高
    local HalfWidth = RectSize.X / 2
    local HalfHeight = RectSize.Y / 2
    
    -- 计算矩形的四个角点（在局部坐标系中）
    local RectCornersLocal = {
        {X = -HalfWidth, Y = -HalfHeight},  -- 左下
        {X = HalfWidth, Y = -HalfHeight},   -- 右下
        {X = HalfWidth, Y = HalfHeight},    -- 右上
        {X = -HalfWidth, Y = HalfHeight}    -- 左上
    }
    
    -- 旋转并平移角点到世界坐标系
    local RectCornersWorld = {}
    for Index, Corner in ipairs(RectCornersLocal) do
        local Rotated = MathUtil.Vector2DRotate(Corner, RectRotation)
        RectCornersWorld[Index] = MathUtil.Vector2DAdd(RectCenter, Rotated)
    end

    -- 定义矩形的四条边
    local RectEdges = {
        {RectCornersWorld[1], RectCornersWorld[2]},  -- 底边
        {RectCornersWorld[2], RectCornersWorld[3]},  -- 右边
        {RectCornersWorld[3], RectCornersWorld[4]},  -- 顶边
        {RectCornersWorld[4], RectCornersWorld[1]}   -- 左边
    }

    -- 检查线段是否与任何矩形边相交
    for _, Edge in ipairs(RectEdges) do
        if MathUtil.DoLinesIntersect(StartVec, EndVec, Edge[1], Edge[2]) then
            return true
        end
    end

    -- 检查线段是否有端点在矩形内部
    -- 计算矩形在局部坐标系中的边界
    local RectMinLocal = {X = -HalfWidth, Y = -HalfHeight}
    local RectMaxLocal = {X = HalfWidth, Y = HalfHeight}
    
    -- 将线段转换到矩形的局部坐标系
    local InvRotation = -RectRotation
    local LocalStart = MathUtil.Vector2DRotate(MathUtil.Vector2DSub(StartVec, RectCenter), InvRotation)
    local LocalEnd = MathUtil.Vector2DRotate(MathUtil.Vector2DSub(EndVec, RectCenter), InvRotation)
    
    -- 计算区域码
    local Code1 = ComputeRegionCode(LocalStart, RectMinLocal, RectMaxLocal)
    local Code2 = ComputeRegionCode(LocalEnd, RectMinLocal, RectMaxLocal)
    
    -- 如果两个端点在矩形内部，则必然与矩形相交
    if Code1 == 0 and Code2 == 0 then
        return true
    end
    
    -- 如果线段完全在矩形的一侧
    if (Code1 & Code2) ~= 0 then
        return false
    end

    return false
end

--- 编码：将 1-2**bitCount 的数字数组压缩成一个 UInt
--- @param numbers number[] 数字数组
--- @return integer 编码后的 UInt
function MathUtil.EncodeUint(numbers)
    if numbers == nil then
        return 0
    end
    local result = 0
    for i, num in pairs(numbers) do
        if num > 0 then
            result = result + 2 ^ num
        end
    end
    return result
end



--- 解码：从 UInt 中解压出数字数组
--- @return number[] 解码后的数字数组
function MathUtil.DecodeUint(num)
    local numbers = {}
    local index = 0
    while num > 0 do
        if num % 2 == 1 then
            table.insert(numbers, index) -- 插入到数组头部
        end
        num = math.floor(num / 2)
        index = index + 1
    end
    return numbers
end





return MathUtil