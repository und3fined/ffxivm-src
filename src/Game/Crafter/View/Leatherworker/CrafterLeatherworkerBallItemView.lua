---
--- Author: Administrator
--- DateTime: 2024-10-28 11:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CrafterConfig = require("Define/CrafterConfig")

-- 状态球颜色和服务器发送的数字对应
local CircleStateIndex = {
	Normal = 1,
	Green = 2,
	Yellow = 4,
	Red = 8,
	GreenYellow = 6,
    GreenRed = 10,
    YellowRed = 12
}

local WeaverCircleItemIconPath = {
    [CircleStateIndex.Normal] = CrafterConfig.WeaverCircleItemIconPath.NormalItem,
    [CircleStateIndex.Green] = CrafterConfig.WeaverCircleItemIconPath.GreenItem,
    [CircleStateIndex.Yellow] = CrafterConfig.WeaverCircleItemIconPath.YellowItem,
    [CircleStateIndex.Red] = CrafterConfig.WeaverCircleItemIconPath.RedItem,
}

local WeaverCircleAnim = {
	[CircleStateIndex.Normal] = "AnimStateGrey",
    [CircleStateIndex.Green] = "AnimStateGreen",
    [CircleStateIndex.Yellow] = "AnimStateYellow",
    [CircleStateIndex.Red] = "AnimStateOrange",
}

---@class CrafterLeatherworkerBallItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBall UFImage
---@field AnimState0 UWidgetAnimation
---@field AnimStateChange UWidgetAnimation
---@field AnimStateGreen UWidgetAnimation
---@field AnimStateGrey UWidgetAnimation
---@field AnimStateOrange UWidgetAnimation
---@field AnimStateYellow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterLeatherworkerBallItemView = LuaClass(UIView, true)

function CrafterLeatherworkerBallItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBall = nil
	--self.AnimState0 = nil
	--self.AnimStateChange = nil
	--self.AnimStateGreen = nil
	--self.AnimStateGrey = nil
	--self.AnimStateOrange = nil
	--self.AnimStateYellow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterLeatherworkerBallItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterLeatherworkerBallItemView:OnInit()
	self.LastState = 0
end

function CrafterLeatherworkerBallItemView:OnDestroy()

end

function CrafterLeatherworkerBallItemView:OnShow()

end

function CrafterLeatherworkerBallItemView:OnHide()

end

function CrafterLeatherworkerBallItemView:OnRegisterUIEvent()

end

function CrafterLeatherworkerBallItemView:OnRegisterGameEvent()

end

function CrafterLeatherworkerBallItemView:OnRegisterBinder()

end

function CrafterLeatherworkerBallItemView:OnWeaverStateUpdate(State)
	local Path = WeaverCircleItemIconPath[State]
	UIUtil.ImageSetBrushFromAssetPath(self.ImgBall,Path)
	self.LastState = State
end

function CrafterLeatherworkerBallItemView:OnWeaverStateAnim()
	self:PlayAnimation(self[WeaverCircleAnim[self.LastState]])
	FLOG_INFO("[CrafterWeaverCircleItemView]OnStateAnim:PlayAnimation CurrentState = "..self.LastState)
end

function CrafterLeatherworkerBallItemView:OnWeaverStateAnimHide()
	if self.LastState then
		self:StopAnimation(self[WeaverCircleAnim[self.LastState]])
		self:PlayAnimation(self.AnimState0)
		FLOG_INFO("[CrafterWeaverCircleItemView]OnHideStateAnim:StopAnimation LastState = "..self.LastState)
	end
end

function CrafterLeatherworkerBallItemView:OnWeaverStateChangeAnim()
	self:PlayAnimation(self.AnimStateChange)
end


return CrafterLeatherworkerBallItemView