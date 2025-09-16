---
--- Author: peterxie
--- DateTime: 2024-08-14
--- Description: 地图标记追踪动效
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")


---@class MapTrackView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AnimIn UWidgetAnimation
---@field AnimTrackLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapTrackView = LuaClass(UIView, true)

function MapTrackView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AnimIn = nil
	--self.AnimTrackLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapTrackView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapTrackView:OnInit()

end

function MapTrackView:OnDestroy()

end

function MapTrackView:OnShow()

end

function MapTrackView:OnHide()

end

function MapTrackView:OnRegisterUIEvent()

end

function MapTrackView:OnRegisterGameEvent()

end

function MapTrackView:OnRegisterBinder()

end

function MapTrackView:PlayAnimLoop()
	self:PlayAnimation(self.AnimTrackLoop, 0, 0)
end

function MapTrackView:StopAnimLoop()
	if self:IsAnimationPlaying(self.AnimTrackLoop) then
		--self:StopAnimation(self.AnimTrackLoop)
		local EndTime = self.AnimTrackLoop:GetEndTime()
		self:PlayAnimationTimeRange(self.AnimTrackLoop, EndTime)
	end
end

return MapTrackView