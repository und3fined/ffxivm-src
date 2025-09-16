local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local EquipmentAttrItemVM = require("Game/Equipment/VM/EquipmentAttrItemVM")

---@class EquipmentMsgItemVM : UIViewModel
local EquipmentMsgItemVM = LuaClass(UIViewModel)

function EquipmentMsgItemVM:Ctor()
    self.TitleText = ""
    self.RightIcon = nil
    self.bHasIcon = false
    self.lstEquipmentAttrItemVM = {}
    self.IconClick = nil
end

return EquipmentMsgItemVM