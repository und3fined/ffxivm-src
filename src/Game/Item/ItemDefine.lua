--
-- Author: anypkvcai
-- Date: 2022-03-23 16:32
-- Description:
--

local ProtoRes = require("Protocol/ProtoRes")
local ITEM_COLOR_TYPE = ProtoRes.ITEM_COLOR_TYPE

---@class ItemSource
local ItemSource = {
	Bag = 1, -- 背包
	BagDepot = 2, -- 背包 打开仓库时
	Depot = 3, -- 仓库
	FishBait = 4,	--鱼饵背包
	Chat = 5, -- 聊天超链接
	TeamRollPanel = 6,
	Shop = 7, -- 商店
	Glamours = 8, -- 幻化
	MatchReward = 9,-- 副本奖励列表
}

---@class ItemTipsButton
local ItemTipsButton = {
	Use = 1, -- 使用
	EquipOn = 2, -- 穿装备
	EquipOff = 3, -- 脱装备
	DepotIn = 4, -- 存入仓库
	DepotOut = 5, -- 从仓库取出
	Drop = 6, -- 丢弃
	Repair = 7, -- 修理
}

local BagTipsMoreMenu = {
	Drop = 1, --丢弃
	Inlay = 2, -- 镶嵌
	Degradation = 3, -- 降品
	Improve = 4, --改良
	Wardrobe = 5, --解锁外观
	RareTask = 6, -- 筹备任务
}

-- 查询角色道具作用类型
local QueryRoleItemType = {
	None = 1, -- 数据查找
	ChatHyperlink = 2, -- 聊天超链接
}

-- 物品使用判断条件类型
local ItemUseCondType = {
	None = 0, -- 无
	ClassLimit = 1, -- 职业类型限制
	ProfLimit = 2, -- 职业限制
	Grade = 3, -- 等级
	RaceTypeLimit = 4, -- 种族
	Gender = 5, -- 性别
}

local ItemIconColorType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_01.UI_Quality_Slot_NQ_01'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_02.UI_Quality_Slot_NQ_02'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_03.UI_Quality_Slot_NQ_03'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_04.UI_Quality_Slot_NQ_04'",
}

local HQItemIconColorType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_HQ_01.UI_Quality_Slot_HQ_01'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_HQ_02.UI_Quality_Slot_HQ_02'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_HQ_03.UI_Quality_Slot_HQ_03'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_HQ_04.UI_Quality_Slot_HQ_04'",
}

local Item58SlotColotType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_58Slot_NQ_01_png.UI_Quality_58Slot_NQ_01_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_58Slot_NQ_02_png.UI_Quality_58Slot_NQ_02_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_58Slot_NQ_03_png.UI_Quality_58Slot_NQ_03_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_58Slot_NQ_04_png.UI_Quality_58Slot_NQ_04_png'",
}

local HQItem58SlotColotType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_58Slot_HQ_01_png.UI_Quality_58Slot_HQ_01_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_58Slot_HQ_02_png.UI_Quality_58Slot_HQ_02_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_58Slot_HQ_03_png.UI_Quality_58Slot_HQ_03_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_58Slot_HQ_04_png.UI_Quality_58Slot_HQ_04_png'",
}

local Item74SlotColotType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_74Slot_NQ_01_png.UI_Quality_74Slot_NQ_01_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_74Slot_NQ_02_png.UI_Quality_74Slot_NQ_02_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_74Slot_NQ_03_png.UI_Quality_74Slot_NQ_03_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_74Slot_NQ_04_png.UI_Quality_74Slot_NQ_04_png'",
}

local HQItem74SlotColotType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_74Slot_HQ_01_png.UI_Quality_74Slot_HQ_01_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_74Slot_HQ_02_png.UI_Quality_74Slot_HQ_02_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_74Slot_HQ_03_png.UI_Quality_74Slot_HQ_03_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_74Slot_HQ_04_png.UI_Quality_74Slot_HQ_04_png'",
}

local Item96SlotColotType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_96Slot_NQ_01_png.UI_Quality_96Slot_NQ_01_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_96Slot_NQ_02_png.UI_Quality_96Slot_NQ_02_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_96Slot_NQ_03_png.UI_Quality_96Slot_NQ_03_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_96Slot_NQ_04_png.UI_Quality_96Slot_NQ_04_png'",
}

local HQItem96SlotColotType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_96Slot_HQ_01_png.UI_Quality_96Slot_HQ_01_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_96Slot_HQ_02_png.UI_Quality_96Slot_HQ_02_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_96Slot_HQ_03_png.UI_Quality_96Slot_HQ_03_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_96Slot_HQ_04_png.UI_Quality_96Slot_HQ_04_png'",
}

local Item126SlotColotType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_126Slot_NQ_01_png.UI_Quality_126Slot_NQ_01_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_126Slot_NQ_02_png.UI_Quality_126Slot_NQ_02_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_126Slot_NQ_03_png.UI_Quality_126Slot_NQ_03_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_126Slot_NQ_04_png.UI_Quality_126Slot_NQ_04_png'",
}

local HQItem126SlotColotType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_126Slot_HQ_01_png.UI_Quality_126Slot_HQ_01_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_126Slot_HQ_02_png.UI_Quality_126Slot_HQ_02_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_126Slot_HQ_03_png.UI_Quality_126Slot_HQ_03_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_126Slot_HQ_04_png.UI_Quality_126Slot_HQ_04_png'",
}

local Item152SlotColotType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_152Slot_NQ_01_png.UI_Quality_152Slot_NQ_01_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_152Slot_NQ_02_png.UI_Quality_152Slot_NQ_02_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_152Slot_NQ_03_png.UI_Quality_152Slot_NQ_03_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_152Slot_NQ_04_png.UI_Quality_152Slot_NQ_04_png'",
}

local HQItem152SlotColotType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_152Slot_HQ_01_png.UI_Quality_152Slot_HQ_01_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_152Slot_HQ_02_png.UI_Quality_152Slot_HQ_02_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_152Slot_HQ_03_png.UI_Quality_152Slot_HQ_03_png'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/UI_Quality_152Slot_HQ_04_png.UI_Quality_152Slot_HQ_04_png'",
}

local ItemSlotType =
{
	Item58Slot = 1,
	Item74Slot = 2,
	Item96Slot = 3,
	Item126Slot = 4,
	Item152Slot = 5,
}



local ItemDefine = {
	ItemSource = ItemSource,
	ItemTipsButton = ItemTipsButton,
	BagTipsMoreMenu = BagTipsMoreMenu,
	QueryRoleItemType = QueryRoleItemType,
	ItemUseCondType = ItemUseCondType,
	ItemIconColorType = ItemIconColorType,
	HQItemIconColorType = HQItemIconColorType,
	Item58SlotColotType = Item58SlotColotType,
	HQItem58SlotColotType = HQItem58SlotColotType,
	Item74SlotColotType = Item74SlotColotType,
	HQItem74SlotColotType = HQItem74SlotColotType,
	Item96SlotColotType = Item96SlotColotType,
	HQItem96SlotColotType = HQItem96SlotColotType,
	Item126SlotColotType = Item126SlotColotType,
	HQItem126SlotColotType = HQItem126SlotColotType,
	Item152SlotColotType = Item152SlotColotType,
	HQItem152SlotColotType = HQItem152SlotColotType,
	ItemSlotType = ItemSlotType
}

return ItemDefine