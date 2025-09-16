---
--- Author: v_zanchang
--- DateTime: 2022-05-13 12:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
-- local UIUtil = require("Utils/UIUtil")

---@class DragHudView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DragUI_UIBP DragUIView
---@field DragedUISlot UOverlay
---@field NeedDragedUI UserWidget
---@field NeedDragedUI_M UserWidget
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DragHudView = LuaClass(UIView, true)

function DragHudView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DragUI_UIBP = nil
	--self.DragedUISlot = nil
	--self.NeedDragedUI = nil
	--self.NeedDragedUI_M = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DragHudView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.DragUI_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DragHudView:OnInit()

end

function DragHudView:OnDestroy()

end

function DragHudView:OnShow()
	-- self.DragUI_UIBP.NeedDragedUI = self.Params.Object
	-- --self.NeedDragedUI = self.Params.Object
	-- self.DragedUISlot:AddChild(self.NeedDragedUI)
	self:InitDragedUI(self.Params.Object)
end

function DragHudView:OnHide()
	self:HiddenUI()
end

function DragHudView:OnRegisterUIEvent()

end

function DragHudView:OnRegisterGameEvent()

end

function DragHudView:OnRegisterBinder()

end

return DragHudView