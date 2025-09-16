---
--- Author: Administrator
--- DateTime: 2025-03-18 12:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class MarketEmptyPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelBook UFCanvasPanel
---@field PanelSearchEmpty CommBackpackEmptyView
---@field AnimState1 UWidgetAnimation
---@field AnimState2 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MarketEmptyPanelView = LuaClass(UIView, true)

function MarketEmptyPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelBook = nil
	--self.PanelSearchEmpty = nil
	--self.AnimState1 = nil
	--self.AnimState2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MarketEmptyPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PanelSearchEmpty)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MarketEmptyPanelView:OnInit()

end

function MarketEmptyPanelView:OnDestroy()

end

function MarketEmptyPanelView:OnShow()

end

function MarketEmptyPanelView:OnHide()

end

function MarketEmptyPanelView:SetConcernEmpty()
	self.PanelSearchEmpty:SetTipsContent(_G.LSTR(1010051))
	self:PlayAnimation(self.AnimState2)
end

function MarketEmptyPanelView:SetSearchEmpty(Str)
	self.PanelSearchEmpty:SetTipsContent(Str)
	self:PlayAnimation(self.AnimState1)
end

function MarketEmptyPanelView:OnRegisterUIEvent()

end

function MarketEmptyPanelView:OnRegisterGameEvent()

end

function MarketEmptyPanelView:OnRegisterBinder()

end

return MarketEmptyPanelView