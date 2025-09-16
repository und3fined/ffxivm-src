---
--- Author: sammrli
--- DateTime: 2024-04-30 15:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ChocoboTransportTrackBirdRoomItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AnimIn UWidgetAnimation
---@field AnimTrackLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboTransportTrackBirdRoomItemView = LuaClass(UIView, true)

function ChocoboTransportTrackBirdRoomItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboTransportTrackBirdRoomItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboTransportTrackBirdRoomItemView:OnInit()

end

function ChocoboTransportTrackBirdRoomItemView:OnDestroy()

end

function ChocoboTransportTrackBirdRoomItemView:OnShow()

end

function ChocoboTransportTrackBirdRoomItemView:OnHide()

end

function ChocoboTransportTrackBirdRoomItemView:OnRegisterUIEvent()

end

function ChocoboTransportTrackBirdRoomItemView:OnRegisterGameEvent()

end

function ChocoboTransportTrackBirdRoomItemView:OnRegisterBinder()

end

function ChocoboTransportTrackBirdRoomItemView:PlayAnim()
	self:PlayAnimation(self.AnimIn)
end

function ChocoboTransportTrackBirdRoomItemView:PlayAnimLoop()
	self:PlayAnimation(self.AnimTrackLoop, 0, 0)
end

function ChocoboTransportTrackBirdRoomItemView:StopAnimLoop()
	self:StopAnimation(self.AnimTrackLoop)
end

return ChocoboTransportTrackBirdRoomItemView