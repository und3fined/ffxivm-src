---
--- Author: saintzhao
--- DateTime: 2025-09-28 10:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class MainFullScreenButtonView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FullScreenButton UFButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainFullScreenButtonView = LuaClass(UIView, true)

function MainFullScreenButtonView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FullScreenButton = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainFullScreenButtonView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainFullScreenButtonView:OnInit()

end

function MainFullScreenButtonView:OnDestroy()

end

function MainFullScreenButtonView:OnShow()

end

function MainFullScreenButtonView:OnHide()

end

function MainFullScreenButtonView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FullScreenButton, self.OnFullScreenButtonClicked)
end

function MainFullScreenButtonView:OnRegisterGameEvent()

end

function MainFullScreenButtonView:OnRegisterBinder()

end

function MainFullScreenButtonView:OnFullScreenButtonClicked()
	_G.FLOG_INFO("MainFullScreenButtonView:OnFullScreenButtonClicked")
end

return MainFullScreenButtonView