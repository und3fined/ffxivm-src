--
-- Author: ZhengJanChuan
-- Date: 2025-04-24 11:58
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")


local ItemCfg = require("TableCfg/ItemCfg")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ITEM_COLOR_TYPE = ProtoRes.ITEM_COLOR_TYPE

---@class OpsActivityFirstChargeRewardItemVM : UIViewModel
local OpsActivityFirstChargeRewardItemVM = LuaClass(UIViewModel)

OpsActivityFirstChargeRewardItemVM.ItemColorType =
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

OpsActivityFirstChargeRewardItemVM.ItemHQColorType =
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
function OpsActivityFirstChargeRewardItemVM:Ctor()
    self.Num = 0
    self.Icon = nil
    self.IsGot = nil
    self.ResID = nil
    self.IsShow = false
    self.IsShowLevel = nil
    self.ItemQualityIcon = self.ItemColorType[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE]
    self.IsMask = nil
    self.IconReceivedVisible = nil
end

function OpsActivityFirstChargeRewardItemVM:OnInit()
end

function OpsActivityFirstChargeRewardItemVM:OnBegin()
end

function OpsActivityFirstChargeRewardItemVM:OnEnd()
end

function OpsActivityFirstChargeRewardItemVM:OnShutdown()
end

function OpsActivityFirstChargeRewardItemVM:UpdateVM(Value)
    if Value.ResID ~= 0 then
    self.Icon = UIUtil.GetIconPath((ItemUtil.GetItemIcon(Value.ResID)))
    end
    self.IsShowLevel = Value.IsShowLevel or false
    self.IsGot = Value.IsGot
    self.IsSelect = Value.IsGet
    self.ResID = Value.ResID
    self.Num = Value.Num
    self.IsShow = not( Value.ResID == 0)
    self.IconChooseVisible = false
    self.BtnCheckVisible = ItemUtil.IsCanPreviewByResID(Value.ResID)
    
    self.IsMask = Value.IsGot
    self.IconReceivedVisible = Value.IsGot

    local Cfg = ItemCfg:FindCfgByKey(Value.ResID)
    if Cfg ~= nil then
	    if(1 == Cfg.IsHQ)then
	    	self.ItemQualityIcon = OpsActivityFirstChargeRewardItemVM.ItemHQColorType[Cfg.ItemColor]
	    else
	    	self.ItemQualityIcon = OpsActivityFirstChargeRewardItemVM.ItemColorType[Cfg.ItemColor]
	    end
    end
end

function OpsActivityFirstChargeRewardItemVM:UpdateGotState(bGot)
    self.IsBPGot = bGot
end

--要返回当前类
return OpsActivityFirstChargeRewardItemVM