---
--- Author: bowxiong
--- DateTime: 2025-01-02 10:14
--- Description:
---

local ProtoRes = require("Protocol/ProtoRes")
local CommonDefine = require("Define/CommonDefine")
local AudioUtil = require("Utils/AudioUtil")
local CommonUtil = require("Utils/CommonUtil")

local CULTURE_NAME = CommonDefine.CultureName
local MOVIE_TYPE = ProtoRes.MOVIE_TYPE

local MovieUtil = {
}

-- 端游全部cg文件
local MOVIE_RESOURCE = {
	MOVIE_RESOURCE_OPENING = 0,
	MOVIE_RESOURCE_TITLE = 1,
	MOVIE_RESOURCE_GIN = 2,
	MOVIE_RESOURCE_BAHA = 3,
	MOVIE_RESOURCE_V3TITLE = 4,
	MOVIE_RESOURCE_V4TITLE = 5,
	MOVIE_RESOURCE_V5TITLE = 6,
	MOVIE_RESOURCE_V6TITLE = 7,
}

-- 端游特殊CG名字和MovieResource的映射
local MOVIE_NAME_MAP = {
	["ffxiv/00002.mp4"] = MOVIE_RESOURCE.MOVIE_RESOURCE_GIN,
	["ffxiv/00003.mp4"] = MOVIE_RESOURCE.MOVIE_RESOURCE_BAHA,
}

-- 端游CG动画资源相关参数
-- { CG动画类型, 字幕起始ID, 是否有职员表 }
local MOVIE_RESOURCE_PARAMS = {
	[MOVIE_RESOURCE.MOVIE_RESOURCE_OPENING] = { MOVIE_TYPE.MOVIE_TYPE_OPENING, 125000, false },
	[MOVIE_RESOURCE.MOVIE_RESOURCE_TITLE] = { MOVIE_TYPE.MOVIE_TYPE_NONE, 0, false },
	[MOVIE_RESOURCE.MOVIE_RESOURCE_GIN] = { MOVIE_TYPE.MOVIE_TYPE_VOYAGE, 125050, false },
	[MOVIE_RESOURCE.MOVIE_RESOURCE_BAHA] = { MOVIE_TYPE.MOVIE_TYPE_NONE, 0, false },
	[MOVIE_RESOURCE.MOVIE_RESOURCE_V3TITLE] = { MOVIE_TYPE.MOVIE_TYPE_NONE, 0, false },
	[MOVIE_RESOURCE.MOVIE_RESOURCE_V4TITLE] = { MOVIE_TYPE.MOVIE_TYPE_NONE, 0, false },
	[MOVIE_RESOURCE.MOVIE_RESOURCE_V5TITLE] = { MOVIE_TYPE.MOVIE_TYPE_VER500, 125100, false },
	[MOVIE_RESOURCE.MOVIE_RESOURCE_V6TITLE] = { MOVIE_TYPE.MOVIE_TYPE_NONE, 0, true },
}

-- 根据当前语言类型, 选择不同的字幕刷新时间配置
local CULTURENAME_YPE = {
	[CULTURE_NAME.Japanese] = 0,
	[CULTURE_NAME.English] = 1,
	[CULTURE_NAME.German] = 2,
	[CULTURE_NAME.French] = 3,
	[CULTURE_NAME.Chinese] = 4,
	[CULTURE_NAME.Korean] = 5,
}

local CULTURETYPE_NAME = {
	[0] = "ja",
	[1] = "en",
	[2] = "de",
	[3] = "fr",
	[4] = "chs",
	[5] = "ko",
}

local MOVIE_BGM_FORMAT = {
	[MOVIE_RESOURCE.MOVIE_RESOURCE_GIN] = "AkAudioEvent'/Game/WwiseAudio/Events/cut/ffxiv/movie/Ginruiko_%s/Play_Ginruiko_%s.Play_Ginruiko_%s'",
}

local MOVIE_SUBTITLE_FORMAT = {
	-- [MOVIE_TYPE.MOVIE_TYPE_OPENING] = "",
	[MOVIE_TYPE.MOVIE_TYPE_VOYAGE] = "Texture2D'/Game/UI/Texture/MovieSubtitle/%s/MovieSubtitle_Voyage_%d.MovieSubtitle_Voyage_%d'",
	-- [MOVIE_TYPE.MOVIE_TYPE_VER500] = "",
}

-- 端游一定会有全部30张字幕图片, 手游可以去掉用来占位的无效图片
-- 这里标记一下不同语言有效字幕图片的索引
local MOVIE_SUBTITLE_MAXINDEX = {
	[MOVIE_TYPE.MOVIE_TYPE_VOYAGE] = { 8, 14, 13, 15, 10, 8 }
}

---GetMovieResource
---@param MovieName string @CG动画资源名
---@return MOVIE_RESOURCE
function MovieUtil.GetMovieResource(MovieName)
	return MOVIE_NAME_MAP[MovieName]
end

---GetMovieType
---@param MovieResource MOVIE_RESOURCE @CG动画资源类型
---@return MOVIE_TYPE @CG动画类型
function MovieUtil.GetMovieType(MovieResource)
	local Params = MOVIE_RESOURCE_PARAMS[MovieResource]
	return Params and Params[1] or MOVIE_TYPE.MOVIE_TYPE_NONE
end

---GetMovieParams
---@param MovieResource MOVIE_RESOURCE @CG动画资源类型
---@return table @CG动画参数
function MovieUtil.GetMovieParams(MovieResource)
	return MOVIE_RESOURCE_PARAMS[MovieResource]
end

---GetCultureType 端游不同语言的字幕刷新时间不一致
---@return number
function MovieUtil.GetAudioCultureType()
	local CurrentCulture = AudioUtil.GetCurrentCulture()
	return CULTURENAME_YPE[CurrentCulture]
end

function MovieUtil.GetSubtitleCultureType()
	local CurrentCulture = CommonUtil.GetCurrentCultureName()
	return CULTURENAME_YPE[CurrentCulture]
end

---GetSubtitleImagePath
---@param MovieType MOVIE_TYPE
---@param SubtitleIndex number
---@return string
function MovieUtil.GetSubtitleImagePath(MovieType, SubtitleIndex, CultureType)
	local Format = MOVIE_SUBTITLE_FORMAT[MovieType]
	if not Format then
		return nil
	end
	local CultureName = CULTURETYPE_NAME[CultureType]
	if not CultureName then
		return nil
	end
	return string.format(Format, CultureName, SubtitleIndex, SubtitleIndex)
end

---GetMovieBGM
---@param MovieResource MOVIE_RESOURCE
---@param CultureType number
---@return number
function MovieUtil.GetMovieBGM(MovieResource, CultureType)
	if not CultureType then
		return nil
	end
	local BGMFormat = MOVIE_BGM_FORMAT[MovieResource]
	if not BGMFormat then
		return nil
	end
	local CultureName = CULTURETYPE_NAME[CultureType]
	if not CultureName then
		return nil
	end
	return string.format(BGMFormat, CultureName, CultureName, CultureName)
end

---GetSubtitleMaxIndex
---@param MovieType MOVIE_TYPE
---@param CultureType number
---@return number
function MovieUtil.GetSubtitleMaxIndex(MovieType, CultureType)
	if not CultureType then
		return 0
	end
	local Config = MOVIE_SUBTITLE_MAXINDEX[MovieType]
	if not Config then
		return 0
	end
	return Config[CultureType + 1]
end

return MovieUtil