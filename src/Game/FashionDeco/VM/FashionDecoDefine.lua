---
--- Author: ccppeng
--- DateTime: 2024-11-01 15:58
--- Description:
---

local LSTR = _G.LSTR
local FashionDecoType = {
    Umbrella = 1,--雨伞
    Wing = 2,--翅膀
	Max = 3,
};
local FashionDecoTypeFaceIndexKey = {
    Umbrella = 37,--雨伞
    Wing = 36,--翅膀
};

--配饰改良初始化数据的系列总数
local DecoAmeliorateSeriesInitNum = {
    Umbrella = 0,--雨伞
    Wing = 5,--翅膀
};

local FashionActionBtnType = {
    Action1 = 1,--雨伞
	Action2 = 2,--翅膀
	Wing = 3,--翅膀
	Switch = 4,--翅膀
};

--雨伞在雨天的设置类型
local FashionDecorateAutoUseChooseType = {
	FashionDecorateUseByNone = 0, --不是雨天自动穿戴
	FashionDecorateUseByRand = 1, --当雨天自动穿戴勾选后，全部随机
	FashionDecorateUseByLike = 2, --当雨天自动穿戴勾选后，收藏随机
	FashionDecorateUseByLast = 3, --当雨天自动穿戴勾选后，最近召唤
}
local FashionDecorateHiddenPriority = {
	Map = 0, --副本
	Common = 1,
	ChangeRole = 2,
	Mount = 3,
	Skill = 4,
	Special = 5, --特殊道具(605896重生之境(66700089))
}
local FashionDecoTypeConfig = {
	{
		Type = FashionDecoType.Umbrella, Name = LSTR(1030001), -- "雨伞"
		NormalIcon = "PaperSprite'/Game/UI/Atlas/FashionDeco/Frames/UI_FashionDeco_Icon_Handheld_Noraml_png.UI_FashionDeco_Icon_Handheld_Noraml_png'",
		SelectedIcon = "PaperSprite'/Game/UI/Atlas/FashionDeco/Frames/UI_FashionDeco_Icon_Handheld_Select_png.UI_FashionDeco_Icon_Handheld_Select_png'",
	},
	{
		Type = FashionDecoType.Wing, Name = LSTR(1030002), -- "翅膀"
		NormalIcon = "PaperSprite'/Game/UI/Atlas/FashionDeco/Frames/UI_FashionDeco_Icon_Back_Noraml_png.UI_FashionDeco_Icon_Back_Noraml_png'",
		SelectedIcon = "PaperSprite'/Game/UI/Atlas/FashionDeco/Frames/UI_FashionDeco_Icon_Back_Select_png.UI_FashionDeco_Icon_Back_Select_png'",
	},
}

local DecoAmeliorateCostID = 66701026

local FashionDecoDefine = {
	FashionDecoType = FashionDecoType,
	FashionDecoTypeConfig		= FashionDecoTypeConfig,
	FashionActionBtnType = FashionActionBtnType,
	FashionDecorateAutoUseChooseType = FashionDecorateAutoUseChooseType,
	FashionDecoTypeFaceIndexKey = FashionDecoTypeFaceIndexKey,
	FashionDecorateHiddenPriority = FashionDecorateHiddenPriority,
	DecoAmeliorateSeriesInitNum = DecoAmeliorateSeriesInitNum,
	DecoAmeliorateCostID = DecoAmeliorateCostID
}

return FashionDecoDefine