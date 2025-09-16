---
--- Author: anypkvcai
--- DateTime: 2021-11-01 16:46
--- Description:
---


---@class HashUtil
local HashUtil = {

}

---BKDRHash
---@param Str string
function HashUtil.BKDRHash(Str)
	local Seed = 131
	local Hash = 0

	for i = 1, string.len(Str) do
		Hash = Hash * Seed + string.byte(Str, i)
	end

	return (Hash & 0x7FFFFFFF)
end

return HashUtil
