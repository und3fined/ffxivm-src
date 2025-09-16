

--local LuaClass = require("Core/LuaClass")
local Class = _G.Class

---@class AlchemistBottleDragDropOp : UDragDropOperation
---@field WidgetReference UUserWidget
---@field DragOffset FVector2D
---@field DragEnteredItem MagicCardCardItemVM
--local AlchemistBottleDragDropOp = LuaClass(LuaUEObject)
local AlchemistBottleDragDropOp = Class()

---@param CardItemVm MagicCardCardItemVM @nil for reset
function AlchemistBottleDragDropOp:SetDragBottom(BottleVM)
    if self.DragEnteredItem ~= nil then
        self.DragEnteredItem.IsShowLightFrame = false
        self.DragEnteredItem = nil
    end
    
    if BottleVM then
        self.DragEnteredItem = BottleVM
        self.DragEnteredItem.IsShowLightFrame = true
    end
end

return AlchemistBottleDragDropOp
