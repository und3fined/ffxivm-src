---
--- Author: sammrli
--- DateTime: 2023-09-14 11:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class GatePointItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImageScore100 UFImage
---@field ImageScore20 UFImage
---@field ImageScore300 UFImage
---@field ImageScore50 UFImage
---@field Panel100 UFCanvasPanel
---@field Panel20 UFCanvasPanel
---@field Panel300 UFCanvasPanel
---@field Panel50 UFCanvasPanel
---@field Anim100 UWidgetAnimation
---@field Anim300 UWidgetAnimation
---@field Anim50 UWidgetAnimation
---@field AnimNegative20 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatePointItemView = LuaClass(UIView, true)

function GatePointItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImageScore100 = nil
	--self.ImageScore20 = nil
	--self.ImageScore300 = nil
	--self.ImageScore50 = nil
	--self.Panel100 = nil
	--self.Panel20 = nil
	--self.Panel300 = nil
	--self.Panel50 = nil
	--self.Anim100 = nil
	--self.Anim300 = nil
	--self.Anim50 = nil
	--self.AnimNegative20 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatePointItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatePointItemView:OnInit()

end

function GatePointItemView:OnDestroy()

end

function GatePointItemView:OnShow()

end

function GatePointItemView:OnHide()

end

function GatePointItemView:OnRegisterUIEvent()

end

function GatePointItemView:OnRegisterGameEvent()

end

function GatePointItemView:OnRegisterBinder()

end

function GatePointItemView:PlayAnim(LocationX, LocaitonY, Kind)
	local Location = _G.UE.FVector2D(LocationX, LocaitonY)
	if Kind == 1 then
		--UIUtil.SetIsVisible(self.Panel300, true)
		UIUtil.CanvasSlotSetPosition(self.Panel300, Location)
		self:PlayAnimation(self.Anim300)
	elseif Kind == 2 then
		--UIUtil.SetIsVisible(self.Panel100, true)
		UIUtil.CanvasSlotSetPosition(self.Panel100, Location)
		self:PlayAnimation(self.Anim100)
	elseif Kind == 3 then
		--UIUtil.SetIsVisible(self.Panel50, true)
		UIUtil.CanvasSlotSetPosition(self.Panel50, Location)
		self:PlayAnimation(self.Anim50)
	else
		--UIUtil.SetIsVisible(self.Panel20, true)
		UIUtil.CanvasSlotSetPosition(self.Panel20, Location)
		self:PlayAnimation(self.AnimNegative20)
	end
end

return GatePointItemView