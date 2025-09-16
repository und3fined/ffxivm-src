--
-- Author: Carl
-- Date: 2024-06-20 16:57:14
-- Description:结算界面 解锁商品列表ItemVM

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local GoodsCfg = require("TableCfg/MysteryMerchantGoodsCfgCfg")

---@class MerchantUnlockListItemVM : UIViewModel
local MerchantUnlockListItemVM = LuaClass(UIViewModel)

function MerchantUnlockListItemVM:Ctor()
    self.GoodsID = 0
    self.ItemID = 0
    self.Icon = ""
    self.IconChooseVisible = false
    self.HideItemLevel = true
    self.NumVisible = false
end


function MerchantUnlockListItemVM:IsEqualVM(Value)
    return tonumber(Value) == self.GoodsID
end

-- function MerchantUnlockListItemVM:GetKey()
-- 	return self.GoodsID
-- end

function MerchantUnlockListItemVM:UpdateVM(Value)
    self.GoodsID = tonumber(Value)
    if self.GoodsID == nil then
        return
    end
    local Cfg = GoodsCfg:FindCfgByKey(self.GoodsID)
	if Cfg then
        self.ItemID = Cfg.Item and Cfg.Item.ID or 0
        local ItemCfg = ItemCfg:FindCfgByKey(self.ItemID)
        if ItemCfg == nil then
            FLOG_WARNING(string.format("冒险游商团道具ItemID %s 不可用：", self.ItemID))
        else
            self.Icon = UIUtil.GetIconPath(ItemCfg.IconID)
        end
    else
        self.Icon = ""
        FLOG_WARNING(string.format("冒险游商团解锁商品ID：%s 在商品表中不存在，请检查", self.GoodsID))
	end
end

return MerchantUnlockListItemVM 