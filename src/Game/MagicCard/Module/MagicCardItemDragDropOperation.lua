---
--- Author: frankjfwang
--- DateTime: 2021-08-27 19:01
--- Description:
---


--local LuaClass = require("Core/LuaClass")
local Class = _G.Class

---@class MagicCardItemDragDropOperation : UDragDropOperation
---@field WidgetReference UUserWidget
---@field DragOffset FVector2D
---@field DragEnteredItem
--local MagicCardItemDragDropOperation = LuaClass(LuaUEObject)
local MagicCardItemDragDropOperation = Class()

---@param CardItemVm @nil for reset
function MagicCardItemDragDropOperation:SetDragEnterCard(CardItemVm)
    if self.DragEnteredItem ~= nil then
        self.DragEnteredItem.IsShowLightFrame = false
        self.DragEnteredItem = nil
    end
    if CardItemVm then
        self.DragEnteredItem = CardItemVm
        self.DragEnteredItem.IsShowLightFrame = true
    end
end

return MagicCardItemDragDropOperation
