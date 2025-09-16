local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ItemDefine = require("Game/Item/ItemDefine")
---@class OpsCeremony126SlotVM : UIViewModel
local OpsCeremony126SlotVM = LuaClass(UIViewModel)
---Ctor
function OpsCeremony126SlotVM:Ctor()
    self.ScoreID = nil
    self.AchievementID = nil
    self.Type = nil
    self.Num = nil
    self.Icon = nil
    self.IconReceivedVisible = nil
end

function OpsCeremony126SlotVM:Update(Params)
    self.Num = Params.Num
    if Params.IsItem then
        self.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(Params.ResID))
        self.ItemQualityIcon = ItemUtil.GetSlotColorIcon(Params.ResID, ItemDefine.ItemSlotType.Item126Slot)
    else
        self.Icon = Params.Icon
    end
    self.IsItem = Params.IsItem
    self.ResID = Params.ResID
    self.AchievementID = Params.AchievementID
    self.IconReceivedVisible = Params.IconReceivedVisible
end

return OpsCeremony126SlotVM