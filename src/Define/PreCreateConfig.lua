local ProtoRes = require ("Protocol/ProtoRes")
local EActorType = _G.UE.EActorType
local EActorSubType = _G.UE.EActorSubType

local PreCreateActorLevels = {
	Low = 1,
	Normal = 2,
	Many = 3,
}

local PreCreateConfigTemplates = {
	-- 少量
	[PreCreateActorLevels.Low] = {
		PoolLimitCount = 20,			-- 缓存池的限制数量
		FillToCount = 10,				-- 填充至的数量
		MinFillThreshold = 3,			-- 数量少于此时开始填充
		InitCount = 10,
	},
	-- 常规
	[PreCreateActorLevels.Normal] = {
		PoolLimitCount = 30,			-- 缓存池的限制数量
		FillToCount = 20,				-- 填充至的数量
		MinFillThreshold = 6,			-- 数量少于此时开始填充
		InitCount = 20,
	},
	-- 多
	[PreCreateActorLevels.Many] = {
		PoolLimitCount = 40,			-- 缓存池的限制数量
		FillToCount = 30,				-- 填充至的数量
		MinFillThreshold = 9,			-- 数量少于此时开始填充
		InitCount = 30,
	},
}

--@class PreCreateConfig
local PreCreateConfig =
{
	-- 主城
	[ProtoRes.pworld_type.PWORLD_CATEGORY_MAIN_CITY] = {
		{
			ActorType = EActorType.Npc,
			SubType = EActorSubType.Normal,
			Config = PreCreateConfigTemplates[PreCreateActorLevels.Many]
		},
		{
			ActorType = EActorType.Player,
			SubType = EActorSubType.Normal,
			Config = PreCreateConfigTemplates[PreCreateActorLevels.Normal]
		},
	},
	-- 副本
	[ProtoRes.pworld_type.PWORLD_CATEGORY_DUNGEON] = {
		{
			ActorType = EActorType.Monster,
			SubType = EActorSubType.Normal,
			Config = PreCreateConfigTemplates[PreCreateActorLevels.Many]
		},
		{
			ActorType = EActorType.Player,
			SubType = EActorSubType.Normal,
			Config = PreCreateConfigTemplates[PreCreateActorLevels.Low]
		},
	},
	-- 野外
	[ProtoRes.pworld_type.PWORLD_CATEGORY_FIELD] = {
		{
			ActorType = EActorType.Npc,
			SubType = EActorSubType.Normal,
			Config = PreCreateConfigTemplates[PreCreateActorLevels.Low]
		},
		{
			ActorType = EActorType.Monster,
			SubType = EActorSubType.Normal,
			Config = PreCreateConfigTemplates[PreCreateActorLevels.Many]
		},
		{
			ActorType = EActorType.Player,
			SubType = EActorSubType.Normal,
			Config = PreCreateConfigTemplates[PreCreateActorLevels.Low]
		},
	},

	MaxFillCount = 5,
}

function PreCreateConfig:FindConfig(PWorldType, ActorType, SubType)
	local PWorldConfigs = self[PWorldType]
	if PWorldConfigs == nil then
		return
	end

	for _, Item in ipairs(PWorldConfigs) do
		if Item and Item.ActorType == ActorType and Item.SubType == SubType then
			return Item.Config
		end
	end
end

return PreCreateConfig