--
-- Author: ZhengJanChuan
-- Date: 2024-12-16 20:30
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")


local ItemCfg = require("TableCfg/ItemCfg")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ITEM_COLOR_TYPE = ProtoRes.ITEM_COLOR_TYPE

---@class BattlePassRewardSlotVM : UIViewModel
local BattlePassRewardSlotVM = LuaClass(UIViewModel)

BattlePassRewardSlotVM.ItemColorType =
{
	-- ITEM_COLOR_WHITE = 1,	-- 白
	-- ITEM_COLOR_GREEN = 2,	-- 绿
	-- ITEM_COLOR_BLUE = 3,	-- 蓝
	-- ITEM_COLOR_PURPLE = 4,	-- 紫
	-- ITEM_COLOR_RED = 6,	-- 红,
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_01.UI_Quality_Slot_NQ_01'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_02.UI_Quality_Slot_NQ_02'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_03.UI_Quality_Slot_NQ_03'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_04.UI_Quality_Slot_NQ_04'",
}

BattlePassRewardSlotVM.ItemHQColorType =
{
	-- ITEM_COLOR_WHITE = 1,	-- 白
	-- ITEM_COLOR_GREEN = 2,	-- 绿
	-- ITEM_COLOR_BLUE = 3,	-- 蓝
	-- ITEM_COLOR_PURPLE = 4,	-- 紫
	-- ITEM_COLOR_ORANGE = 5,	-- 橙
	-- ITEM_COLOR_RED = 6,	-- 红,
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_HQ_01.UI_Quality_Slot_HQ_01'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_HQ_02.UI_Quality_Slot_HQ_02'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_HQ_03.UI_Quality_Slot_HQ_03'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_HQ_04.UI_Quality_Slot_HQ_04'",
}


---Ctor
function BattlePassRewardSlotVM:Ctor()
    self.Num = 0
    self.IsAvailable = false
    self.Icon = nil
    self.IsGot = nil
    self.IsBPGot = false
    self.ResID = nil
    self.LvText = 0 --文本
    self.Lv = 0 -- 数据
    self.Grade = nil

    self.IsShow = false
    self.IsShowLevel = nil
    self.IsUnlock = false

    self.ItemQualityIcon = self.ItemColorType[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE]
end

function BattlePassRewardSlotVM:OnInit()
end

function BattlePassRewardSlotVM:OnBegin()
end

function BattlePassRewardSlotVM:OnEnd()
end

function BattlePassRewardSlotVM:OnShutdown()
end

function BattlePassRewardSlotVM:UpdateVM(Value)
    self.LvText = string.format(_G.LSTR(850006),  Value.Lv or 0) 
    self.Lv =  Value.Lv or 0
    if Value.ResID ~= 0 then
    self.Icon = UIUtil.GetIconPath((ItemUtil.GetItemIcon(Value.ResID)))
    end
    self.IsShowLevel = Value.IsShowLevel or false
    self.Grade = Value.Grade
    self.IsGot = Value.IsGot
    self.ResID = Value.ResID
    self.Num = Value.Num
    self.IsAvailable = Value.IsAvailable
    self.IsShow =not( Value.ResID == 0)

    if  Value.IsUnlock  ~= nil then
        self.IsUnlock = Value.IsUnlock
    else
        self.IsUnlock = false
    end

    local Cfg = ItemCfg:FindCfgByKey(Value.ResID)
    if Cfg ~= nil then
	    if(1 == Cfg.IsHQ)then
	    	self.ItemQualityIcon = BattlePassRewardSlotVM.ItemHQColorType[Cfg.ItemColor]
	    else
	    	self.ItemQualityIcon = BattlePassRewardSlotVM.ItemColorType[Cfg.ItemColor]
	    end
    end
end

function BattlePassRewardSlotVM:UpdateGotState(bGot)
    self.IsBPGot = bGot
end

--要返回当前类
return BattlePassRewardSlotVM