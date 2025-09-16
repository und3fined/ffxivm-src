---
--- Author: v_zanchang
--- DateTime: 2022-05-13 12:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
-- local UIUtil = require("Utils/UIUtil")

---@class DragUIView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BImg UImage
---@field NeedDrag UOverlay
---@field DragOffset Vector2D
---@field DragedWidget UserWidget
---@field NeedDragedUI UserWidget
---@field NeedDragUIOffset Vector2D
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DragUIView = LuaClass(UIView, true)

function DragUIView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BImg = nil
	--self.NeedDrag = nil
	--self.DragOffset = nil
	--self.DragedWidget = nil
	--self.NeedDragedUI = nil
	--self.NeedDragUIOffset = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DragUIView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DragUIView:OnInit()

end

function DragUIView:OnDestroy()

end

function DragUIView:OnShow()

end

function DragUIView:OnHide()

end

function DragUIView:OnRegisterUIEvent()

end

function DragUIView:OnRegisterGameEvent()

end

function DragUIView:OnRegisterBinder()

end

return DragUIView