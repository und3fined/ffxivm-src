--
-- Author: anypkvcai
-- Date: 2020-08-11 15:56:20
-- Description:
--


---@class ObjectGCType
local ObjectGCType = {
	LRU = 0, --默认策略，根据缓存策略可能随时移除
	Map = 1, --切换场景时才移除
	Hold = 2, --游戏期间不移除
	NoCache = 3, --不缓存
}

return ObjectGCType