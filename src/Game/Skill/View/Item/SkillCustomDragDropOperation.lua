---@class SkillCustomDragDropOperation : UDragDropOperation
---@field DraggedView SkillCustomBtnBaseView - 被拖拽的控件
local SkillCustomDragDropOperation = {}

function SkillCustomDragDropOperation:Dragged(MouseEvent)
    local View = self.DraggedView
    if View then
        View.ParentView:DragMove(MouseEvent)
    end
end

return SkillCustomDragDropOperation
