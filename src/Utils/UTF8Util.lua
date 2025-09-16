---
--- Author: anypkvcai
--- DateTime: 2021-06-01 15:42
--- Description:
---

-- ABNF from RFC 3629
--
-- UTF8-octets = *( UTF8-char )
-- UTF8-char = UTF8-1 / UTF8-2 / UTF8-3 / UTF8-4
-- UTF8-1 = %x00-7F
-- UTF8-2 = %xC2-DF UTF8-tail
-- UTF8-3 = %xE0 %xA0-BF UTF8-tail / %xE1-EC 2( UTF8-tail ) /
-- %xED %x80-9F UTF8-tail / %xEE-EF 2( UTF8-tail )
-- UTF8-4 = %xF0 %x90-BF 2( UTF8-tail ) / %xF1-F3 3( UTF8-tail ) /
-- %xF4 %x80-8F 2( UTF8-tail )
-- UTF8-tail = %x80-BF

-- 0xxxxxxx                            | 007F   (127)
-- 110xxxxx	10xxxxxx                   | 07FF   (2047)
-- 1110xxxx	10xxxxxx 10xxxxxx          | FFFF   (65535)
-- 11110xxx	10xxxxxx 10xxxxxx 10xxxxxx | 10FFFF (1114111)

local pattern = '[%z\1-\127\194-\244][\128-\191]*'

-- helper function
local Posrelat =
function (pos, Len)
	if pos < 0 then
		pos = Len + pos + 1
	end

	return pos
end

local UTF8Util = {}

-- THE MEAT

-- maps f over s's UTF8Util characters f can accept args: (visual_index, utf8_character, byte_index)
UTF8Util.Map =
function (s, f, no_subs)
	local i = 0

	if no_subs then
		for b, e in s:gmatch('()' .. pattern .. '()') do
			i = i + 1
			local c = e - b
			f(i, c, b)
		end
	else
		for b, c in s:gmatch('()(' .. pattern .. ')') do
			i = i + 1
			f(i, c, b)
		end
	end
end

-- THE REST

-- generator for the above -- to iterate over all UTF8Util Chars
UTF8Util.Chars =
function (s, no_subs)
	return coroutine.wrap(function () return UTF8Util.Map(s, coroutine.yield, no_subs) end)
end

-- returns the number of characters in a UTF-8 string
UTF8Util.Len =
function (s)
	-- count the number of non-continuing bytes
	return select(2, s:gsub('[^\128-\193]', ''))
end

-- Replace all UTF8Util Chars with mapping
UTF8Util.Replace =
function (s, Map)
	return s:gsub(pattern, Map)
end

-- Reverse a UTF8Util string
UTF8Util.Reverse =
function (s)
	-- Reverse the individual greater-than-single-byte characters
	s = s:gsub(pattern, function (c) return #c > 1 and c:Reverse() end)

	return s:Reverse()
end

-- Strip non-ascii characters from a UTF-8 string
UTF8Util.Strip =
function (s)
	return s:gsub(pattern, function (c) return #c > 1 and '' end)
end

-- like string.sub() but i, j are UTF-8 strings
-- a UTF8Util-safe string.sub()
UTF8Util.Sub =
function (s, i, j)
	local l = UTF8Util.Len(s)

	i =       Posrelat(i, l)
	j = j and Posrelat(j, l) or l

	if i < 1 then i = 1 end
	if j > l then j = l end

	if i > j then return '' end

	local diff = j - i
	local iter = UTF8Util.Chars(s, true)

	-- advance up to i
	for _ = 1, i - 1 do iter() end

	local c, b = select(2, iter())

	-- i and j are the same, single-charaacter Sub
	if diff == 0 then
		return string.sub(s, b, b + c - 1)
	end

	i = b

	-- advance up to j
	for _ = 1, diff - 1 do iter() end

	c, b = select(2, iter())

	return string.sub(s, i, b + c - 1)
end

return UTF8Util
