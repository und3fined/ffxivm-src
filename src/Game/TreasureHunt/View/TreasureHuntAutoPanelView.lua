---
--- Author: Administrator
--- DateTime: 2023-11-15 16:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class TreasureHuntAutoPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Map01 TreasureHuntMapSItemView
---@field Map02 TreasureHuntMapSItemView
---@field Map03 TreasureHuntMapSItemView
---@field Map04 TreasureHuntMapSItemView
---@field Map05 TreasureHuntMapSItemView
---@field Map06 TreasureHuntMapSItemView
---@field Map07 TreasureHuntMapSItemView
---@field Map08 TreasureHuntMapSItemView
---@field Map09 TreasureHuntMapSItemView
---@field Map10 TreasureHuntMapSItemView
---@field AnimIn UWidgetAnimation
---@field NewAnimation UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TreasureHuntAutoPanelView = LuaClass(UIView, true)

function TreasureHuntAutoPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Map01 = nil
	--self.Map02 = nil
	--self.Map03 = nil
	--self.Map04 = nil
	--self.Map05 = nil
	--self.Map06 = nil
	--self.Map07 = nil
	--self.Map08 = nil
	--self.Map09 = nil
	--self.Map10 = nil
	--self.AnimIn = nil
	--self.NewAnimation = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TreasureHuntAutoPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Map01)
	self:AddSubView(self.Map02)
	self:AddSubView(self.Map03)
	self:AddSubView(self.Map04)
	self:AddSubView(self.Map05)
	self:AddSubView(self.Map06)
	self:AddSubView(self.Map07)
	self:AddSubView(self.Map08)
	self:AddSubView(self.Map09)
	self:AddSubView(self.Map10)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TreasureHuntAutoPanelView:OnInit()

end

function TreasureHuntAutoPanelView:OnDestroy()

end

function TreasureHuntAutoPanelView:OnShow()

end

function TreasureHuntAutoPanelView:OnHide()

end

function TreasureHuntAutoPanelView:OnRegisterUIEvent()

end

function TreasureHuntAutoPanelView:OnRegisterGameEvent()

end

function TreasureHuntAutoPanelView:OnRegisterBinder()

end

return TreasureHuntAutoPanelView