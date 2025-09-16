local VisionDefine = require("Game/Actor/VisionDefine")

local MeshLimiterChannel = VisionDefine.MeshLimiterChannel

-- 不同性能等级的模型缓存配置
local MeshCacheMap =
{
	[0] =
	{
		[MeshLimiterChannel.Player] = 7,
		[MeshLimiterChannel.NPC] = 3,
		[MeshLimiterChannel.Monster] = 5,
		[MeshLimiterChannel.Companion] = 3,
	},
	[1] =
	{
		[MeshLimiterChannel.Player] = 8,
		[MeshLimiterChannel.NPC] = 4,
		[MeshLimiterChannel.Monster] = 6,
		[MeshLimiterChannel.Companion] = 4,
	},
	[2] =
	{
		[MeshLimiterChannel.Player] = 9,
		[MeshLimiterChannel.NPC] = 5,
		[MeshLimiterChannel.Monster] = 7,
		[MeshLimiterChannel.Companion] = 5,
	},
	[3] =
	{
		[MeshLimiterChannel.Player] = 10,
		[MeshLimiterChannel.NPC] = 6,
		[MeshLimiterChannel.Monster] = 8,
		[MeshLimiterChannel.Companion] = 6,
	},
	[4] =
	{
		[MeshLimiterChannel.Player] = 11,
		[MeshLimiterChannel.NPC] = 7,
		[MeshLimiterChannel.Monster] = 9,
		[MeshLimiterChannel.Companion] = 7,
	},
}

local VisionConfigs =
{
	MeshCacheMap = MeshCacheMap,
}

return VisionConfigs