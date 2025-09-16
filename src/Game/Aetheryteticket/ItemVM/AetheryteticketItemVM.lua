local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
---@class AetheryteticketItemVM : UIViewModel
---@field Name string

local AetheryteticketItemVM = LuaClass(UIViewModel)

---Ctor
function AetheryteticketItemVM:Ctor()
    -- Main Part
    self.ResID = nil
    self.Name = ""
    self.OwnNum = ""
    self.IconPath = ""
    self.bDisable = false
    self.bEnable = true
    self.IconColor = ""
    self.UseTextColor = ""
end

function AetheryteticketItemVM:IsEqualVM(Value)
    return true
end


function AetheryteticketItemVM:UpdateVM(Value)
    self.ResID = Value.ResID
    self.Name = Value.Name
    self.OwnNum = Value.OwnNum
    self.IconPath = Value.IconPath
    self.bDisable = Value.bDisable
    self.bEnable = Value.bEnable
    self.IconColor = Value.IconColor
    self.UseTextColor = Value.UseTextColor
end

-- ---@type 是否可以展开树形控件子节点
-- function AetheryteticketItemVM:AdapterOnGetIsCanExpand()
--     return true
-- end

-- --- 设置返回的索引：0
-- function AetheryteticketItemVM:AdapterOnGetWidgetIndex()
--     return 0
-- end

-- function AetheryteticketItemVM:AdapterOnGetCanBeSelected()
--     return true
-- end

-- --- 返回子节点列表
-- function AetheryteticketItemVM:AdapterOnGetChildren()
--     return {}
-- end

return AetheryteticketItemVM