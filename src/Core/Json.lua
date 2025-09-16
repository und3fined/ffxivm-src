local rapidjson = require("rapidjson")

--rapidjson
--[[
--性能更好 但只支持标准json格式
--使用方式：
local Json = require("Core/Json")

--encode
local T = {1, 2, 3, 4, 5}
local Str = Json.encode(T)
--结果:"[1,2,3,4,5]"

--Key必须是字符串
local T = {"1" : "a", "Key" : 5}
local Str = Json.encode(T)
--结果:"{"Key2":5,"Key1":"a"}"

local T = { 1, 2, [10] = 10 }
local Str = Json.encode(T)
--结果:"[1,2]" 会丢失一部分数据, 因为当做数组了

--不连续的数组可以转成标准json格式
local T = { ["1"]=1, ["2"] = 2, ["10"] = 10 }
local Str = Json.encode(T)
--结果:"{"10":10,"1":1,"2":2}"

--空表默认要当做数组的话，可以用empty_table_as_array参数
local T = {}
local Str = Json.encode(T)
--结果:"{}"

local Str = Json.encode(T, { empty_table_as_array = true })
--结果:"[]"

--decode
local T = Json.decode(Str)
]]

rapidjson.safe_decode = function(json_str)
    local data, err = rapidjson.decode(json_str)
    if type(data) == "userdata" then
        return rapidjson.decode(json_str, {object_as_meta = false})
    end
    return data, err
end

return rapidjson