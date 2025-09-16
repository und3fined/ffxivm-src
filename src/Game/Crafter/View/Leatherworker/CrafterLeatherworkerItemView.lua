---
--- Author: Administrator
--- DateTime: 2024-10-28 16:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CrafterLeatherworkerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Ball1 CrafterLeatherworkerBallItemView
---@field Ball2 CrafterLeatherworkerBallItemView
---@field Ball3 CrafterLeatherworkerBallItemView
---@field Ball4 CrafterLeatherworkerBallItemView
---@field Ball5 CrafterLeatherworkerBallItemView
---@field Ball6 CrafterLeatherworkerBallItemView
---@field Ball7 CrafterLeatherworkerBallItemView
---@field MoveBall CrafterLeatherworkerBallItemView
---@field PanelBall UFCanvasPanel
---@field AnimIn UWidgetAnimation
---@field AnimMove UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field ThrillCurve CurveFloat
---@field SliderMoveTime float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterLeatherworkerItemView = LuaClass(UIView, true)

function CrafterLeatherworkerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Ball1 = nil
	--self.Ball2 = nil
	--self.Ball3 = nil
	--self.Ball4 = nil
	--self.Ball5 = nil
	--self.Ball6 = nil
	--self.Ball7 = nil
	--self.MoveBall = nil
	--self.PanelBall = nil
	--self.AnimIn = nil
	--self.AnimMove = nil
	--self.AnimOut = nil
	--self.ThrillCurve = nil
	--self.SliderMoveTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterLeatherworkerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Ball1)
	self:AddSubView(self.Ball2)
	self:AddSubView(self.Ball3)
	self:AddSubView(self.Ball4)
	self:AddSubView(self.Ball5)
	self:AddSubView(self.Ball6)
	self:AddSubView(self.Ball7)
	self:AddSubView(self.MoveBall)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterLeatherworkerItemView:OnInit()

end

function CrafterLeatherworkerItemView:OnDestroy()

end

function CrafterLeatherworkerItemView:OnShow()

end

function CrafterLeatherworkerItemView:OnHide()

end

function CrafterLeatherworkerItemView:OnRegisterUIEvent()

end

function CrafterLeatherworkerItemView:OnRegisterGameEvent()

end

function CrafterLeatherworkerItemView:OnRegisterBinder()

end

function CrafterLeatherworkerItemView:OnCrafterWeaverStateUpdate(States)
	for i = 1 , 7 , 1 do
		self["Ball" .. tostring(i)]:OnWeaverStateUpdate(States.Balls[i])
	end
	self.LastIndex = States.Index or 0
end

function CrafterLeatherworkerItemView:OnWeaverStateMoveAnim(State)
	self.MoveBall:OnWeaverStateUpdate(State)
	self:PlayAnimation(self.AnimMove)
end

function CrafterLeatherworkerItemView:OnStateChangeAnim(index)
	self["Ball" .. tostring(index)]:OnWeaverStateChangeAnim()
end

function CrafterLeatherworkerItemView:OnStateAnim()
	self.Ball1:OnWeaverStateAnim()
end

function CrafterLeatherworkerItemView:OnStateHideAnim()
	self.Ball1:OnWeaverStateAnimHide()
end

return CrafterLeatherworkerItemView