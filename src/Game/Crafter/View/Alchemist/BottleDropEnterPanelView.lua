---
--- Author: chriswang
--- DateTime: 2023-09-13 15:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local AlchemistMainVM = require("Game/Crafter/Alchemist/AlchemistMainVM")

---@class BottleDropEnterPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DirectionPanel UFCanvasPanel
---@field ImgArrow UFImage
---@field ImgDirection UFImage
---@field AnimDirectionIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BottleDropEnterPanelView = LuaClass(UIView, true)

function BottleDropEnterPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DirectionPanel = nil
	--self.ImgArrow = nil
	--self.ImgDirection = nil
	--self.AnimDirectionIn = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BottleDropEnterPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BottleDropEnterPanelView:OnInit()

end

function BottleDropEnterPanelView:OnDestroy()

end

function BottleDropEnterPanelView:OnShow()

end

function BottleDropEnterPanelView:OnHide()

end

function BottleDropEnterPanelView:OnRegisterUIEvent()

end

function BottleDropEnterPanelView:OnRegisterGameEvent()

end

function BottleDropEnterPanelView:OnRegisterBinder()

end

function BottleDropEnterPanelView:OnDrop(MyGeometry, PointerEvent, Operation)
	local DraggedVM = Operation.WidgetReference.BaseBtnVM
	FLOG_INFO("crafter drag drop idx:%d, SkillID:%d", DraggedVM.ButtonIndex, DraggedVM.SkillID)
	_G.CrafterMgr:CastLifeSkill(DraggedVM.ButtonIndex, self.DraggedVM)

	AlchemistMainVM.bDragSuccess = true
	AlchemistMainVM.bBottleDropEnterPanel = false
    return false
end

function BottleDropEnterPanelView:OnDragEnter(MyGeometry, PointerEvent, Operation)
	print("drag Enter")
end

function BottleDropEnterPanelView:OnDragLeave(PointerEvent, Operation)
	print("drag Leave")
end

return BottleDropEnterPanelView