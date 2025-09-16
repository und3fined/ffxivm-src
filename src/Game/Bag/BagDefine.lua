---
--- Author: anypkvcai
--- DateTime: 2021-08-16 20:43
--- Description:
---
local ProtoRes = require("Protocol/ProtoRes")
local ITEM_CLASSIFY_TYPE = ProtoRes.ITEM_CLASSIFY_TYPE

local ITEM_CLASSIFY_TYPE_ITEM_ALL = 100
local ITEM_CLASSIFY_TYPE_EQUIP_ALL = 101

local LSTR = _G.LSTR

local SortType = {
	Quality = 0, -- 品质
	Level = 1, --等级
}

local SortOrder = {
	Ascending = 0, -- 升序
	Descending = 1, --降序
}

local RedDotID = 13001


local ItemTabs = {
	{
		Type = ITEM_CLASSIFY_TYPE_ITEM_ALL, Name = LSTR(990013), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_All_Noraml.UI_Icon_Tab_Bag_Equip_All_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_All_Select.UI_Icon_Tab_Bag_Equip_All_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_PROP, Name = LSTR(990005), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Props_Noraml.UI_Icon_Tab_Bag_Goods_Props_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Props_Select.UI_Icon_Tab_Bag_Goods_Props_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_FOOD_DRUG, Name = LSTR(990014), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Medicine_Noraml.UI_Icon_Tab_Bag_Goods_Medicine_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Medicine_Select.UI_Icon_Tab_Bag_Goods_Medicine_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_MATERIAL, Name = LSTR(990015), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Market_Material_Noraml.UI_Icon_Tab_Bag_Market_Material_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Market_Material_Select.UI_Icon_Tab_Bag_Market_Material_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_FISH, Name = LSTR(990016), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Fish_Noraml.UI_Icon_Tab_Bag_Goods_Fish_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Fish_Select.UI_Icon_Tab_Bag_Goods_Fish_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_TASK, Name = LSTR(990017), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Task_Noraml.UI_Icon_Tab_Bag_Goods_Task_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Goods_Task_Select.UI_Icon_Tab_Bag_Goods_Task_Select'",

	},
}

local EquipTabs = {
	{
		Type = ITEM_CLASSIFY_TYPE_EQUIP_ALL, Name = LSTR(990018), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_All_Noraml.UI_Icon_Tab_Bag_Equip_All_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_All_Select.UI_Icon_Tab_Bag_Equip_All_Select'",
	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_MAIN_HAND, Name = LSTR(990019), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Master_Noraml.UI_Icon_Tab_Bag_Equip_Master_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Master_Select.UI_Icon_Tab_Bag_Equip_Master_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_DEPUTY_HAND, Name = LSTR(990020), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Deputies_Noraml.UI_Icon_Tab_Bag_Equip_Deputies_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Deputies_Select.UI_Icon_Tab_Bag_Equip_Deputies_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_HEAD, Name = LSTR(990021), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Head_Noraml.UI_Icon_Tab_Bag_Equip_Head_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Head_Select.UI_Icon_Tab_Bag_Equip_Head_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_BODY, Name = LSTR(990022), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Body_Noraml.UI_Icon_Tab_Bag_Equip_Body_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Body_Select.UI_Icon_Tab_Bag_Equip_Body_Select'",
	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_ARM, Name = LSTR(990023), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Hand_Noraml.UI_Icon_Tab_Bag_Equip_Hand_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Hand_Select.UI_Icon_Tab_Bag_Equip_Hand_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_LEG, Name = LSTR(990024), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Leg_Noraml.UI_Icon_Tab_Bag_Equip_Leg_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Leg_Select.UI_Icon_Tab_Bag_Equip_Leg_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_FOOT, Name = LSTR(990025), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Foot_Noraml.UI_Icon_Tab_Bag_Equip_Foot_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Foot_Select.UI_Icon_Tab_Bag_Equip_Foot_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_ERR, Name = LSTR(990026), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Eardrops_Noraml.UI_Icon_Tab_Bag_Equip_Eardrops_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Eardrops_Select.UI_Icon_Tab_Bag_Equip_Eardrops_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_NECK, Name = LSTR(990027), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Neck_Noraml.UI_Icon_Tab_Bag_Equip_Neck_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Neck_Select.UI_Icon_Tab_Bag_Equip_Neck_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_FINESSE, Name = LSTR(990028), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Finesse_Noraml.UI_Icon_Tab_Bag_Equip_Finesse_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Finesse_Select.UI_Icon_Tab_Bag_Equip_Finesse_Select'",

	},
	{
		Type = ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_RING, Name = LSTR(990029), NumVisible = false,
		IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Ring_Noraml.UI_Icon_Tab_Bag_Equip_Ring_Noraml'",
        SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_Ring_Select.UI_Icon_Tab_Bag_Equip_Ring_Select'",

	},
}

local ItemGetWaySource = {
	Mount = 1,              -- 坐骑图鉴
	Companion = 2,			-- 宠物图鉴
}

local BagDefine = {
	ItemTabs = ItemTabs,
	EquipTabs = EquipTabs,

	ITEM_CLASSIFY_TYPE_ITEM_ALL = ITEM_CLASSIFY_TYPE_ITEM_ALL,
	ITEM_CLASSIFY_TYPE_EQUIP_ALL = ITEM_CLASSIFY_TYPE_EQUIP_ALL,

	SortType = SortType,
	SortOrder = SortOrder,

	RedDotID = RedDotID,
	ItemGetWaySource = ItemGetWaySource,
}

return BagDefine