---
--- Author: anypkvcai
--- DateTime: 2021-08-24 19:46
--- Description: 仓库图标
---

local DepotIconConfig = {
	{ ID = 1, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Default_png.UI_Bag_Img_Default_png'" },
	{ ID = 2, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Tool_png.UI_Bag_Img_Tool_png'" },
	{ ID = 3, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Source_png.UI_Bag_Img_Source_png'" },
	{ ID = 4, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Drug_png.UI_Bag_Img_Drug_png'" },
	{ ID = 5, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Weapon_png.UI_Bag_Img_Weapon_png'" },
	{ ID = 6, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Armor_png.UI_Bag_Img_Armor_png'" },
	{ ID = 7, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Jewelry_png.UI_Bag_Img_Jewelry_png'" },
	{ ID = 8, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Other_png.UI_Bag_Img_Other_png'" },
}

local DepotWhiteIconConfig = {
	{ ID = 1, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Default_White_png.UI_Bag_Img_Default_White_png'" },
	{ ID = 2, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Tool_White_png.UI_Bag_Img_Tool_White_png'" },
	{ ID = 3, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Source_White_png.UI_Bag_Img_Source_White_png'" },
	{ ID = 4, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Drug_White_png.UI_Bag_Img_Drug_White_png'" },
	{ ID = 5, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Weapon_White_png.UI_Bag_Img_Weapon_White_png'" },
	{ ID = 6, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Armor_White_png.UI_Bag_Img_Armor_White_png'" },
	{ ID = 7, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Jewelry_White_png.UI_Bag_Img_Jewelry_White_png'" },
	{ ID = 8, Icon = "PaperSprite'/Game/UI/Atlas/Bag/Frames/UI_Bag_Img_Other_White_png.UI_Bag_Img_Other_White_png'" },
}

local function FindDepotIcon(ID)
	local Config = DepotWhiteIconConfig[ID]
	if nil == Config then
		return DepotWhiteIconConfig[1].Icon
	end

	return Config.Icon
end

local DepotConfig = {
	DepotWhiteIconConfig = DepotWhiteIconConfig,
	DepotIconConfig = DepotIconConfig,
	FindDepotIcon = FindDepotIcon
}

return DepotConfig