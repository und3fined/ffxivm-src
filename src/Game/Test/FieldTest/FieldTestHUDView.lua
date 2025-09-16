---
--- Author: sammrli
--- DateTime: 2023-06-16 00:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class FieldTestHUDView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Root UOverlay
---@field TextID UFTextBlock
---@field TextResID UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FieldTestHUDView = LuaClass(UIView, true)

function FieldTestHUDView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Root = nil
	--self.TextID = nil
	--self.TextResID = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FieldTestHUDView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FieldTestHUDView:OnInit()

end

function FieldTestHUDView:OnDestroy()

end

function FieldTestHUDView:OnShow()

end

function FieldTestHUDView:OnHide()

end

function FieldTestHUDView:OnRegisterUIEvent()

end

function FieldTestHUDView:OnRegisterGameEvent()

end

function FieldTestHUDView:OnRegisterBinder()

end

function FieldTestHUDView:SetText1(Param)
	self.TextID:SetText(tostring(Param))
end

function FieldTestHUDView:SetText2(Param)
	self.TextResID:SetText(tostring(Param))
end

return FieldTestHUDView