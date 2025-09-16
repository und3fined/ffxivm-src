--
-- Author: ZhengJanChuan
-- Date: 2024-12-23 18:52
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class BattlePassPrizeViewItemVM : UIViewModel
local BattlePassPrizeViewItemVM = LuaClass(UIViewModel)

---Ctor
function BattlePassPrizeViewItemVM:Ctor()
    self.ItemName = ""
    self.Icon = nil
    self.ResID = nil
    self.ID = nil
end

function BattlePassPrizeViewItemVM:OnInit()
end

function BattlePassPrizeViewItemVM:OnBegin()
end

function BattlePassPrizeViewItemVM:OnEnd()
end

function BattlePassPrizeViewItemVM:OnShutdown()
end

function BattlePassPrizeViewItemVM:UpdateVM(Value)
    self.ID = Value.ID
    self.ResID = Value.ResID
    self.ItemName = ItemUtil.GetItemName(Value.ResID)
    self.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(Value.ResID))
end

--要返回当前类
return BattlePassPrizeViewItemVM