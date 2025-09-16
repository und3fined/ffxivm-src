local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class AdventureBaseVM : UIViewModel
---@field ItemList table<_, UIViewModel>

local AdventureBaseVM = LuaClass(UIViewModel)

---Ctor
function AdventureBaseVM:Ctor()
    self.ItemList = nil
end

function AdventureBaseVM:ClearItemList()
    if self.ItemList then
        self.ItemList:Clear()
    end
end

function AdventureBaseVM:SetItemListData(ItemListData)
    if next(ItemListData) and self.ItemList then
        self.ItemList:UpdateByValues(ItemListData)
    end
end

function AdventureBaseVM:SetOneItemListData(Value)
    if next(Value) and self.ItemList then
        self.ItemList:AddByValue(Value)
    end
end

return AdventureBaseVM