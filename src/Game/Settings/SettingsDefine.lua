local CommonDefine = require("Define/CommonDefine")
local LSTR = _G.LSTR

local ItemDisplayStyle = {
	Slider 			= 1, -- 进度条。Value[最大值、默认值]
	Hyperlink 		= 2, -- 超链接（唤起网页）。
	DropDownList 	= 3, -- 下拉列表。
	Button          = 4, -- 点击回调
	ColorPalette	= 5, -- 调色盘
	TextByCustomUI	= 6, -- 点击弹自己的ui，SettingItemView显示的文本是通过Get*** 获取的
	CustonBPEmbed	= 7, -- 嵌入设置界面中的自定义UI
}

local ColorList = {
	"FFFFFF", "FFBDBD", "FFDEC7", "FFF7B0", "E8FFE0", "E5FFFC", "9CCFF2", "FFDBFF",
	"F7F7F7", "FF4040", "FF7F00", "FFFF00", "00FF00", "00FFFF", "0000FF", "FF00FF",
	"DEDEDE", "FF4A4A", "FFA666", "FFFFB0", "7FFF00", "BAFFF0", "409EFF", "E05E8F",
	"D6D6D6", "FF7D7D", "FFCCAB", "FFDE73", "7FF75E", "66E5FF", "94BFFF", "FF8AC4",
	"cccccc", "FFBFBF", "FF6600", "F0C76B", "D4FF7D", "ABDBE5", "7F7FFF", "FFB8DE",
	"BDBDBD", "D6BFBF", "D6666B", "CCCC66", "ABD647", "B0E5E5", "B28AFF", "DEA6BA",
	"A6A6A6", "C4A1A1", "D6BDAB", "C7BF9E", "38E5B2", "3BE5E5", "DEBFF7", "DE87F2",	
}

local CultureName = CommonDefine.CultureName
--到了外网之后，这个定义不能变，要不会出现功能的错乱
local LanguageType = {
	[CultureName.Chinese] 	= 1, -- 简体中文
	[CultureName.English] 	= 2, -- 英文
	[CultureName.Japanese] 	= 3, -- 日文
	[CultureName.Korean] 	= 4, -- 韩文
	[CultureName.French] 	= 5, -- 法文
	[CultureName.German] 	= 6, -- 德文
}

-- !!!! 此处语言不需走多语言
local LanguagesDesc = {
	"中文",
	"English",
	"日本语",
	"한국어",
	"Français",
	"Deutsch",
}

--正在使用的各个语言的翻译
local UsingDesc = {
	"正在使用",
	"in use",
	"使用中",
	"사용중",
	"im Einsatz",
	"en cours d'utilisation",
}

local LanguageSetCategory = 10
local LanguageSubCategory = 1

local SettingsDefine = {
	ColorList 			= ColorList,
	ItemDisplayStyle 	= ItemDisplayStyle,
	LanguageType 		= LanguageType,
	LanguagesDesc 		= LanguagesDesc,
	UsingDesc 		= UsingDesc,
	LanguageSetCategory = LanguageSetCategory,
	LanguageSubCategory = LanguageSubCategory,
}

return SettingsDefine