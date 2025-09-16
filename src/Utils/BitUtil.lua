--
-- Author: alex
-- Date: 2023-09-21 09:43
-- Description:Bit操作
--


---@class BitUtil
local BitUtil = {

}

--- 获取Byte值对应位上是否为1
---@param Byte number
---@param Index number @从0开始
---@param bLeft boolean @是否从左往右 true 从左往右
function BitUtil.IsBitSet(Byte, Index, bLeft)
	if Index < 0 or Index > 7 then
		return
	end
	local MaskOffset = Index
	if bLeft then
		MaskOffset = 7 - Index
	end
	local Mask = 1 << MaskOffset
	local Result = Byte & Mask
	return Result ~= 0
end

--- 清除Byte值对应位上的值
---@param Byte number
---@param Index number @从0开始
---@param bLeft boolean @是否从左往右 true 从左往右
function BitUtil.ClearBit(Byte, Index, bLeft)
	if Index < 0 or Index > 7 then
		return
	end
	local MaskOffset = Index
	if bLeft then
		MaskOffset = 7 - Index
	end
	local Mask = ~ (1 << MaskOffset)
	return Byte & Mask
end

--- 设置Byte值对应位上的值为1
---@param Byte number
---@param Index number @从0开始
---@param bLeft boolean @是否从左往右 true 从左往右
function BitUtil.SetBit(Byte, Index, bLeft)
	if Index < 0 or Index > 7 then
		return
	end
	local MaskOffset = Index
	if bLeft then
		MaskOffset = 7 - Index
	end
	local Mask = 1 << MaskOffset
	return Byte | Mask
end

--- 获取Byte值对应位上是否为1
---@param Byte number
---@param Index number @从0开始
---@param bLeft boolean @是否从左往右 true 从左往右
function BitUtil.IsBitSetByInt64(Byte, Index, bLeft)
	if Index < 0 or Index > 63 then
		return
	end
	local MaskOffset = Index
	if bLeft then
		MaskOffset = 7 - Index
	end
	local Mask = 1 << MaskOffset
	local Result = Byte & Mask
	return Result ~= 0
end

--- 将存储为字符串的字节数组转换
function BitUtil.StringToByteArray(Str)
    local ByteArr = {}
    for i = 1, #Str do
        ByteArr[i] = string.byte(Str, i)
    end
    return ByteArr
end

function BitUtil.ByteArrayToString(Arr)
	if Arr then
		local Str = string.char(table.unpack(Arr))
		return Str
	end
end

function BitUtil.ToBits(num)
    -- 返回一个包含二进制位的表，最低位在前
    local t = {}
    while num > 0 do
        local rest = math.fmod(num, 2)
        t[#t + 1] = rest
        num = (num - rest) / 2
    end
    return t
end

function BitUtil.ToNumber(BitsTable)
    -- 包含二进制位的表，最低位在前
    local i = 0
    for index, value in ipairs(BitsTable) do
		if value == 1 then
			local BitToNum = 1
			local MultiplyCount = index - 1
			while MultiplyCount > 0 do
				BitToNum = BitToNum * 2
				MultiplyCount = MultiplyCount - 1
			end
			
			i = i + BitToNum
		end
	end
    return i
end

function BitUtil.BitCount(Byte)
    local count = 0
    while Byte > 0 do
        count = count + (Byte & 1) -- 检查最低位是否为 1
        Byte = Byte >> 1           -- 右移一位，继续检查下一位
    end
    return count
end

return BitUtil