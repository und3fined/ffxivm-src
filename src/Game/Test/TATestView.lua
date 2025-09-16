---
--- Author: anypkvcai
--- DateTime: 2022-01-05 15:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
--local UIUtil = require("Utils/UIUtil")

---@class TATestView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonCloseBtn CommonCloseBtnView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TATestView = LuaClass(UIView, true)

function TATestView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonCloseBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TATestView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonCloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TATestView:OnInit()

end

function TATestView:OnDestroy()

end

function TATestView:OnShow()

end

function TATestView:OnHide()

end

function TATestView:OnRegisterUIEvent()

end

function TATestView:OnRegisterGameEvent()

end

function TATestView:OnRegisterBinder()

end

return TATestView