---
--- Author: jamiyang
--- DateTime: 2023-04-03 16:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class MagicsAttributeTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PopUpBG CommonPopUpBGView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsAttributeTipsView = LuaClass(UIView, true)

function MagicsAttributeTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PopUpBG = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicsAttributeTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsAttributeTipsView:OnInit()

end

function MagicsAttributeTipsView:OnDestroy()

end

function MagicsAttributeTipsView:OnShow()

end

function MagicsAttributeTipsView:OnHide()

end

function MagicsAttributeTipsView:OnRegisterUIEvent()

end

function MagicsAttributeTipsView:OnRegisterGameEvent()

end

function MagicsAttributeTipsView:OnRegisterBinder()

end

return MagicsAttributeTipsView