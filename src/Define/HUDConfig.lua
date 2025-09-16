---
--- Author: anypkvcai
--- DateTime: 2021-03-08 10:54
--- Description:
---

local HUDType = require("Define/HUDType")

local FLOG_WARNING = _G.FLOG_WARNING

local HUDConfigs = {
	{ HUDType = HUDType.PlayerInfo, Path = "ActorInfo" },
	{ HUDType = HUDType.MonsterInfo, Path = "MonsterInfo" },
	{ HUDType = HUDType.NPCInfo, Path = "NPCInfo" },
	{ HUDType = HUDType.CompanionInfo, Path = "NPCInfo" },
	{ HUDType = HUDType.GatherInfo, Path = "GatherInfo" },
	{ HUDType = HUDType.InteractObjInfo, Path = "InteractObjInfo" },
	{ HUDType = HUDType.BuddyInfo, Path = "NPCInfo" },
	{ HUDType = HUDType.HouseObjInfo, Path = "HouseObjInfo" },

	{ HUDType = HUDType.MajorHPDamage1, Path = "MajorHPDamage_01", Text = "%d" },
	{ HUDType = HUDType.MajorHPDamage2, Path = "MajorHPDamage_02", Text = "%d" },
	{ HUDType = HUDType.MajorHPDamage3, Path = "MajorHPDamage_03", Text = "%d!" },
	{ HUDType = HUDType.MajorHPDamage4, Path = "MajorHPDamage_04", Text = "%d!!" },
	{ HUDType = HUDType.MajorHPDamage5, Path = "MajorHPDamage_05", Text = "%d" },
	{ HUDType = HUDType.MajorHPDamage6, Path = "MajorHPDamage_06", Text = "%d" },
	{ HUDType = HUDType.MajorHPDamage7, Path = "MajorHPDamage_07", Text = "%d!" },
	{ HUDType = HUDType.MajorHPDamage8, Path = "MajorHPDamage_08", Text = "%d!!" },

	{ HUDType = HUDType.MajorHPHeal1, Path = "MajorHPHeal_01", Text = "%d" },
	{ HUDType = HUDType.MajorHPHeal2, Path = "MajorHPHeal_02", Text = "%d" },
	{ HUDType = HUDType.MajorHPHeal3, Path = "MajorHPHeal_03", Text = "%d!" },

	--{ HUDType = HUDType.MajorMPDamage1, Path = "MajorMPDamage_01", Text = "%d" },
	--{ HUDType = HUDType.MajorMPHeal1, Path = "MajorMPHeal_01", Text = "%d" },

	{ HUDType = HUDType.ActorHPHeal1, Path = "ActorHPHeal_01", Text = "%d" },
	{ HUDType = HUDType.ActorHPHeal2, Path = "ActorHPHeal_02", Text = "%d" },
	{ HUDType = HUDType.ActorHPHeal3, Path = "ActorHPHeal_03", Text = "%d!" },
	{ HUDType = HUDType.ActorHPHeal4, Path = "ActorHPHeal_04", Text = "%d" },

	{ HUDType = HUDType.MonsterHPDamage1, Path = "MonsterHPDamage_01", Text = "%d" },
	{ HUDType = HUDType.MonsterHPDamage2, Path = "MonsterHPDamage_02", Text = "%d" },
	{ HUDType = HUDType.MonsterHPDamage3, Path = "MonsterHPDamage_03", Text = "%d!" },
	{ HUDType = HUDType.MonsterHPDamage4, Path = "MonsterHPDamage_04", Text = "%d!!" },
	{ HUDType = HUDType.MonsterHPDamage5, Path = "MonsterHPDamage_05", Text = "%d" },
	{ HUDType = HUDType.MonsterHPDamage6, Path = "MonsterHPDamage_06", Text = "%d" },
	{ HUDType = HUDType.MonsterHPDamage7, Path = "MonsterHPDamage_07", Text = "%d!" },
	{ HUDType = HUDType.MonsterHPDamage8, Path = "MonsterHPDamage_08", Text = "%d!!" },
	{ HUDType = HUDType.MonsterHPDamage9, Path = "MonsterHPDamage_09", Text = "%d" },

	{ HUDType = HUDType.MajorDodge, 	Path = "MajorDodge_01", },
	{ HUDType = HUDType.MajorSuperman, 	Path = "MajorSuperman_1", },
	{ HUDType = HUDType.MajorInvalid, 	Path = "MajorInvalid_01", },

	{ HUDType = HUDType.MonsterDodge, 		Path = "MonsterDodge_01", },
	{ HUDType = HUDType.MonsterSuperman, 	Path = "MonsterSuperman_01", },
	{ HUDType = HUDType.MonsterInvalid, 	Path = "MonsterInvalid_01", },

	{ HUDType = HUDType.MajorBufferAdd, 	Path = "MajorBufferAdd_01", 	Text = "+%s" },
	{ HUDType = HUDType.MajorDBufferAdd, 	Path = "MajorDBufferAdd_01", 	Text = "+%s" },
	{ HUDType = HUDType.MajorBufferRemove,	Path = "MajorBufferRemove_01", 	Text = "-%s" },

	{ HUDType = HUDType.ActorBufferAdd, 	Path = "ActorBufferAdd_01", 	Text = "+%s" },
	{ HUDType = HUDType.ActorBufferRemove, 	Path = "ActorBufferRemove_01", 	Text = "-%s" },

	{ HUDType = HUDType.MonsterBufferAdd, 		Path = "MonsterBufferAdd_01", 		Text = "+%s" },
	{ HUDType = HUDType.MonsterBufferRemove, 	Path = "MonsterBufferRemove_02", 	Text = "-%s" },

	---------------- Life Skill ----------------

	{ HUDType = HUDType.LifeSkillFlyText1, Path = "LifeSkillFlyText_01", Text = "%d" },
	{ HUDType = HUDType.LifeSkillFlyText2, Path = "LifeSkillFlyText_02", Text = "%d!" },
	{ HUDType = HUDType.LifeSkillFlyText3, Path = "LifeSkillFlyText_03", Text = "%d" },
	{ HUDType = HUDType.LifeSkillFlyText4, Path = "LifeSkillFlyText_04", Text = "%d!" },


	-- 主界面浮标指引 --
	{ HUDType = HUDType.BuoyQuest, Path = "BuoyQuest", Text = "%sm",
		NormalIcon = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_TaskTrack_Icon_Track2_png.UI_TaskTrack_Icon_Track2_png'",
		SelectIcon = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_TaskTrack_Icon_Track2_Cancel_png.UI_TaskTrack_Icon_Track2_Cancel_png'",
	},
	{ HUDType = HUDType.BuoyMapFollow, Path = "BuoyMapFollow", Text = "%sm",
		NormalIcon = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_Hud_LandmarkTrack_png.UI_Icon_Hud_LandmarkTrack_png'",
		SelectIcon = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_Hud_LandmarkTrack_Cancel_png.UI_Icon_Hud_LandmarkTrack_Cancel_png'",
	},
	{ HUDType = HUDType.BuoyAetherCurrent, Path = "BuoyAetherCurrent", Text = "%sm" },
	{ HUDType = HUDType.BuoyUnActivatedCrystal, Path = "BuoyUnActivatedCrystal", Text = "%sm" },
	{ HUDType = HUDType.BuoyGoldGameNPC, Path = "BuoyGoldGameNPC", Text = "%sm",
		NormalIcon = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_Hud_GoldSaucerTrack_png.UI_Icon_Hud_GoldSaucerTrack_png'",
		SelectIcon = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_Hud_GoldSaucerTrack_Cancel_png.UI_Icon_Hud_GoldSaucerTrack_Cancel_png'",
	},

}

local HUDConfigMap = {}

---@class HUDConfig
local HUDConfig = {

}

---GetConfig
---@param Type HUDType
---@return table
function HUDConfig:GetConfig(Type)
	local Config = HUDConfigMap[Type]
	if nil ~= Config then
		return Config
	end

	for i = 1, #HUDConfigs do
		local v = HUDConfigs[i]
		if v.HUDType == Type then
			HUDConfigMap[Type] = v
			return v
		end
	end

	FLOG_WARNING("HUDConfig:GetConfig Config is nil, Type=%d", Type)
end

---GetPath
---@param Type HUDType
---@return string
function HUDConfig:GetPath(Type)
	local Config = self:GetConfig(Type)
	if nil == Config then
		return
	end

	return string.format("FHUDAsset'/Game/UI/HUD/%s.%s'", Config.Path, Config.Path)
end

---GetText
---@param Type HUDType
---@return string
function HUDConfig:GetText(Type)
	local Config = self:GetConfig(Type)
	if nil == Config then
		return
	end

	return Config.Text
end

---获取浮标正常状态下的贴图
---@param Type HUDType
---@return string
function HUDConfig:GetNormalStateTexturePath(Type)
	local Config = self:GetConfig(Type)
	if nil == Config then
		return
	end

	return Config.NormalIcon
end

---获取浮标选中状态下的贴图
---@param Type HUDType
---@return string
function HUDConfig:GetSelectStateTexturePath(Type)
	local Config = self:GetConfig(Type)
	if nil == Config then
		return
	end

	return Config.SelectIcon
end


-- 怪物Rank相关图标不需要策划配置，这里直接写死
-- 资源顺序与枚举NPC_RANK_TYPE一致，使用接口函数
local MonsterRankTypeIconRes = {
	-- Default 常见于野外
	"/Game/UI/Atlas/HUD/Frames/UI_Icon_061707_png.UI_Icon_061707_png", 		-- Active
	"/Game/UI/Atlas/HUD/Frames/UI_Icon_061701_png.UI_Icon_061701_png",		-- Passive

	-- Boss 或者PVP
	"/Game/UI/Atlas/HUD/Frames/UI_Icon_061712_png.UI_Icon_061712_png", 		-- Active
	"/Game/UI/Atlas/HUD/Frames/UI_Icon_061706_png.UI_Icon_061706_png",		-- Passive

	-- BossL2 中级Boss
	"/Game/UI/Atlas/HUD/Frames/UI_Icon_061711_png.UI_Icon_061711_png", 		-- Active
	"/Game/UI/Atlas/HUD/Frames/UI_Icon_061705_png.UI_Icon_061705_png",		-- Passive

	-- NM Notorious Monster 恶名精英
	"/Game/UI/Atlas/HUD/Frames/UI_Icon_061710_png.UI_Icon_061710_png", 		-- Active
	"/Game/UI/Atlas/HUD/Frames/UI_Icon_061704_png.UI_Icon_061704_png",		-- Passive

	-- Elite1 精英1
	"/Game/UI/Atlas/HUD/Frames/UI_Icon_061708_png.UI_Icon_061708_png", 		-- Active
	"/Game/UI/Atlas/HUD/Frames/UI_Icon_061702_png.UI_Icon_061702_png",		-- Passive

	-- Elite1 精英2	或精英3
	"/Game/UI/Atlas/HUD/Frames/UI_Icon_061709_png.UI_Icon_061709_png", 		-- Active
	"/Game/UI/Atlas/HUD/Frames/UI_Icon_061703_png.UI_Icon_061703_png",		-- Passive
}

---GetMonsterRankTypeIcon
---@param RankType number RankType枚举
---@param Active bool 主动或被动
---@return string | nil
function HUDConfig:GetMonsterRankTypeIcon(RankType, Active)
	local Index = RankType * 2 + 1 + (Active and 0 or 1)
	return MonsterRankTypeIconRes[Index]
end

HUDConfig.IsDrawFlag = {
	Common = 1 << 0,
	Sequence = 1 << 1,

	All = ~0x00,
}

return HUDConfig