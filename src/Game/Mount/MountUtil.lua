local Json = require("Core/Json")
local USaveMgr = _G.UE.USaveMgr

local MountUtil = {}

function MountUtil.SaveMap(Map, SaveKeyItem)
    local ModifiedMap = {}
    for Idx, Value in pairs(Map) do
        ModifiedMap[tostring(Idx)] = Value
    end
    local Str = Json.encode(ModifiedMap)
    USaveMgr.SetString(SaveKeyItem, Str, true)
end

function MountUtil.LoadMap(SaveKeyItem)
    local Str = USaveMgr.GetString(SaveKeyItem, nil, true)
    if Str == nil or string.len(Str) == 0 then
        return {}
    end
    local ModifiedMap = Json.decode(Str)
    if ModifiedMap == nil then return {} end
    local Map = {}
    for Idx, Value in pairs(ModifiedMap) do
        Map[tonumber(Idx)] = Value
    end
    return Map
end

return MountUtil