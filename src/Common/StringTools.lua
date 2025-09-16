--字符串相关操作

local StringTools = {
}

-- 把字符串按SeparatorChar分割成并放入table
-- @Str 目标串
-- @SeparatorChar 分割符。注意这个分隔符是一个pattern，不能填%，如果分割符是%，则填%%
function StringTools.StringSplit(Str, SeparatorChar)
	if nil == Str then return {} end
	local RetStrTable = {}
	string.gsub(Str, '[^' .. SeparatorChar .. ']+', function(Word)
		table.insert(RetStrTable, Word)
	end)
	return RetStrTable
end

string.split = function(s, p)
	return StringTools.StringSplit(s, p)
end

-- 把字符串转为table
-- @s 目标字符串 有换行时会转换失败
string.totable = function(s)
	if nil == s or type(s) ~= "string" then return end

	local fun = load("return " .. s)
	if nil == fun then
		return
	end

	return fun()
end

local format = string.format

---Format 支持string.format("{1}{2}{3}",a,b,c)这种格式化，但是未考虑本来就要显示为"{0}"的情况
---@param FormatString string
function StringTools.Format(FormatString, ...)
	local Params = { ... }

	local Str, Count = string.gsub(FormatString, "{(%d+)}", function(IndexStr)
		return Params[tonumber(IndexStr)]
	end)

	if 0 < Count then
		return Str
	end

	return format(FormatString, ...)
end

local function IsNilOrEmpty(S)
	return (nil == S) or (type(S) ~= "string") or (S == "")
end

string.isnilorempty = IsNilOrEmpty

local function startsWith(str, start)
	return str:sub(1, #start) == start
end

string.startsWith = startsWith

local function endsWith(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

string.endsWith = endsWith

---FormatInt 给数字增加千分位分隔符，支持负数与小数
---@param FormatString string
local function FormatInt(number)
	local _, _, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")  
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

string.formatint = FormatInt

local function RevisePatternString( Str )
	if nil == Str then
		return
	end

	Str = string.gsub(Str, "%-", "%%-")
	Str = string.gsub(Str, "%+", "%%+")
	Str = string.gsub(Str, "%[", "%%[")
	Str = string.gsub(Str, "%]", "%%]")

	return Str
end

string.revisePattern = RevisePatternString

---- 1-3999 数字转罗马字符
local function NumberToRoman ( Num )
	if Num > 3999 or Num <= 0 then
		return ""
	end

	local Roman = {
		{ "", "Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ", "Ⅵ", "Ⅶ", "Ⅷ", "Ⅸ"  },  
		{ "", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC"  },
        { "", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM"  },
		{ "", "M", "MM", "MMM" },
	}
	local Ret = ""
	local Digit = 0
	while  Num > 0  do
		local ReMain = math.floor(Num % 10)
		Ret = Roman[(Digit+1)][(ReMain+1)] .. Ret
		Digit = Digit + 1
      Num = math.floor(Num / 10)
   end

	return Ret
end

string.NumberToRoman = NumberToRoman

--- a safe version of string format function.
---@param fmt string
---@return string
string.sformat = function(fmt, ...)
	local success, result = pcall(string.format, fmt, ...)
	-- if not success then
	-- 	_G.FLOG_ERROR("%s\n%s", string.format("string.sformat with %s: %s", fmt,tostring(result)), debug.traceback())
	-- end
	return success and result or fmt
end

local function FindLSTRAttrValue(t, k)
	local ID = k and rawget(t, "_LSTR_" .. k) or nil
	if type(ID) == 'number' then
		return _G.LSTR(ID)
	end
end

local LSTRAttrMetaTable = {
	__index = FindLSTRAttrValue,
}

local LSTRAtrrConstMetaTable = {
	__newindex = function (_, k)
		_G.FLOG_ERROR(string.sformat("error: try to set %s for a const table, trace:\n %s"), k, debug.traceback())
	end,
	__index = FindLSTRAttrValue,
}

--- Adpate for config with old LSTR defined attributes such as {xx = 1, name = LSTR("中文")}
--- the @param t must eliminates "name" liked attributes, use "_LSTR_" prefix instead : {xx = 1, _LSTR_name = 123} (123 is an ukey for example)
---@param t table like {xx = a, name=b} which is a LSTR("ABC") wrapped 
---@param bConst boolean | nil
---@return table
function StringTools.MakeLSTRDict(t, bConst)
	return setmetatable(t, bConst and  LSTRAtrrConstMetaTable or LSTRAttrMetaTable)
end

---@param Attr string | number
function StringTools.MakeLSTRAttrKey(Attr)
	return "_LSTR_" .. Attr
end


return StringTools