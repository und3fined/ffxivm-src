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
local FashionActionBtnType = {
    Action1 = 1,--雨伞
	Action2 = 2,--翅膀
	Wing = 3,--翅膀
	Switch = 4,--翅膀
};
local FashionDecorateAutoUseChooseType = {
	FashionDecorateUseByNone = 0,
	FashionDecorateUseByRand = 1,
	FashionDecorateUseByLike = 2,
	FashionDecorateUseByLast = 3,
}
local FashionDecorateHiddenPriority = {
	Map = 0,
	Common = 1,
	ChangeRole = 2,
	Mount = 3,
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

local FashionDecoDefine = {
	FashionDecoType = FashionDecoType,
	FashionDecoTypeConfig		= FashionDecoTypeConfig,
	FashionActionBtnType = FashionActionBtnType,
	FashionDecorateAutoUseChooseType = FashionDecorateAutoUseChooseType,
	FashionDecoTypeFaceIndexKey = FashionDecoTypeFaceIndexKey,
	FashionDecorateHiddenPriority = FashionDecorateHiddenPriority
}

return FashionDecoDefine