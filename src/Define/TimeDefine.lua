--
-- Author: anypkvcai
-- Date: 2022-12-15 17:19
-- Description:
--

local LSTR = _G.LSTR

---@class TimeType
local TimeType = {
	Aozy = 1,
	Local = 2,
	Server = 3,
	Min = 1,
	Max = 3,
}

local AozyTimeDefine = {
	RealSec2AozyMin = 12 / 35,
	AozyMin2RealSec = 35 / 12, --避免计算误差
	AozyHour2RealSec = 175,
	AozyDay2RealSec = 4200,

	BellEqRealSecs = 175,
	SunEqRealSecs = 4200,
	BellsEverySun = 24,
}

local MoonType = {
	Star 	= 1, -- 星月
	Spirit 	= 2, -- 灵月
}

local MoonTypeName = {
	[MoonType.Star] 	= LSTR(1500012), --- 星
	[MoonType.Spirit] 	= LSTR(1500013),  --- 灵
}

local TimeNameConfig = {
	[TimeType.Aozy] 		= LSTR(1500014),  --- 艾
	[TimeType.Local] 		= LSTR(1500015),  --- 本
	[TimeType.Server] 		= LSTR(1500016),  --- 服
}

local TimeIconConfig = {
	[TimeType.Aozy] 		= "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Img_TimeArea_png.UI_Map_Img_TimeArea_png'",
	[TimeType.Local] 		= "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Img_TimeLocal_png.UI_Map_Img_TimeLocal_png'",
	[TimeType.Server] 		= "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Img_TimeServer_png.UI_Map_Img_TimeServer_png'",
}

local TimeDefine = {
	TimeType = TimeType,
	TimeNameConfig = TimeNameConfig,
	TimeIconConfig = TimeIconConfig,
	AozyTimeDefine = AozyTimeDefine,

	MoonType = MoonType,
	MoonTypeName = MoonTypeName,
}
return TimeDefine