---
--- Author: Administrator
--- DateTime: 2025-05-19 10:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local CommonUtil = require("Utils/CommonUtil")

---@class TouringBandMusicalNotationItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AnimIGO UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TouringBandMusicalNotationItemView = LuaClass(UIView, true)

function TouringBandMusicalNotationItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AnimIGO = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TouringBandMusicalNotationItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TouringBandMusicalNotationItemView:OnInit()

end

function TouringBandMusicalNotationItemView:OnDestroy()

end

function TouringBandMusicalNotationItemView:OnShow()

end

function TouringBandMusicalNotationItemView:OnHide()

end

function TouringBandMusicalNotationItemView:OnRegisterUIEvent()

end

function TouringBandMusicalNotationItemView:OnRegisterGameEvent()

end

function TouringBandMusicalNotationItemView:OnRegisterBinder()

end

function TouringBandMusicalNotationItemView:PlayAnimGo(Listener, Callback)
    self.Listener = Listener
    self.Callback = Callback
    self:PlayAnimation(self.AnimIGO)
end

function TouringBandMusicalNotationItemView:OnAnimationFinished(Animation)
    if Animation == self.AnimIGO then
        if self.Listener and self.Callback then
            CommonUtil.XPCall(self.Listener, self.Callback)
            self.Listener = nil
            self.Callback = nil
        end
    end
end

return TouringBandMusicalNotationItemView