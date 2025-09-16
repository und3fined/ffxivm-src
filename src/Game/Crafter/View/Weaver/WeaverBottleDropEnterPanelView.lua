---
--- Author: Administrator
--- DateTime: 2023-12-14 16:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")

---@class WeaverBottleDropEnterPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DirectionPanel UFCanvasPanel
---@field ImgArrow UFImage
---@field ImgDirection UFImage
---@field AnimIn UWidgetAnimation
---@field SutureSkillIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WeaverBottleDropEnterPanelView = LuaClass(UIView, true)

function WeaverBottleDropEnterPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DirectionPanel = nil
	--self.ImgArrow = nil
	--self.ImgDirection = nil
	--self.AnimIn = nil
	--self.SutureSkillIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WeaverBottleDropEnterPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WeaverBottleDropEnterPanelView:OnInit()

end

function WeaverBottleDropEnterPanelView:OnDestroy()

end

function WeaverBottleDropEnterPanelView:OnShow()

end

function WeaverBottleDropEnterPanelView:OnHide()

end

function WeaverBottleDropEnterPanelView:OnRegisterUIEvent()

end

function WeaverBottleDropEnterPanelView:OnRegisterGameEvent()

end

function WeaverBottleDropEnterPanelView:OnRegisterBinder()

end

function WeaverBottleDropEnterPanelView:OnDrop(MyGeometry, PointerEvent, Operation)

	local Index = self.SutureSkillIndex

	_G.CrafterMgr:CastLifeSkill(Index)
end

function WeaverBottleDropEnterPanelView:OnDragEnter(MyGeometry, PointerEvent, Operation)
	
end

function WeaverBottleDropEnterPanelView:OnDragLeave(MyGeometry, PointerEvent, Operation)
	
end

return WeaverBottleDropEnterPanelView