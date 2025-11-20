local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ItemDefine = require("Game/Item/ItemDefine")

---@class MysteryShopWinItemVM : UIViewModel
local MysteryShopWinItemVM = LuaClass(UIViewModel)

---Ctor
function MysteryShopWinItemVM:Ctor()
    self.ItemID = nil
    self.ItemQualityIcon = nil
    self.Icon = nil
    self.Num = nil
    self.ItemColorAndOpacity = nil
    self.NumVisible = false
    self.IsValid = true
    self.IsMask = false
    self.IsSelect = false
    self.IsQualityVisible = true
end

function MysteryShopWinItemVM:UpdateVM(Params)
    local ItemID = Params.ItemID
    self.ItemID = ItemID
    self.ItemQualityIcon = ItemUtil.GetItemColorIcon(ItemID)
    self.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(ItemID))
    self.ItemColorAndOpacity = nil
    self.Num = Params.Num
    self.NumVisible = (self.Num or 0) > 1
    self.IsValid = true
    self.IsMask = false
    self.IsSelect = false
    self.IsQualityVisible = true
end

function MysteryShopWinItemVM:IsEqualVM(Value)
    return true
end


return MysteryShopWinItemVM