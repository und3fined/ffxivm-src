---
--- Author: v_zanchang
--- DateTime: 2022-11-21 15:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
-- local UIUtil = require("Utils/UIUtil")

---@class TeamRollINumbertemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AnimRollend UWidgetAnimation
---@field AnimRollendWin UWidgetAnimation
---@field AnimRolling UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRollINumbertemView = LuaClass(UIView, true)

function TeamRollINumbertemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AnimRollend = nil
	--self.AnimRollendWin = nil
	--self.AnimRolling = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRollINumbertemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRollINumbertemView:OnInit()

end

function TeamRollINumbertemView:OnDestroy()

end

function TeamRollINumbertemView:OnShow()

end

function TeamRollINumbertemView:OnHide()

end

function TeamRollINumbertemView:OnRegisterUIEvent()

end

function TeamRollINumbertemView:OnRegisterGameEvent()

end

function TeamRollINumbertemView:OnRegisterBinder()

end

function TeamRollINumbertemView:OnAnimationFinished(Animation)
	local Params = self.Params
	if nil == Params or Params.OnItemAnimationFinished == nil then
		return
	end

	Params.OnItemAnimationFinished(Params.View, self, Animation)
end

return TeamRollINumbertemView