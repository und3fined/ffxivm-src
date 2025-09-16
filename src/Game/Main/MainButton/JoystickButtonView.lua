--
-- Author: anypkvcai
-- Date: 2020-08-20 15:23:47
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")

local JoystickButtonView = LuaClass(UIView, true)

function JoystickButtonView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn_Joystick = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JoystickButtonView:OnInit()
	print("JoystickButtonView:OnInit")
end

function JoystickButtonView:OnDestroy()
	print("JoystickButtonView:OnDestroy")
end

function JoystickButtonView:OnShow()
	print("JoystickButtonView:OnShow")


end

function JoystickButtonView:OnHide()

	print("JoystickButtonView:OnHide")

end

function JoystickButtonView:OnRegisterUIEvent()
	print("JoystickButtonView:OnRegisterUIEvent")

end

function JoystickButtonView:OnRegisterGameEvent()
	print("JoystickButtonView:OnRegisterGameEvent")

end

function JoystickButtonView:OnRegisterTimer()
	print("JoystickButtonView:OnRegisterTimer")

end

function JoystickButtonView:OnRegisterBinder()
	print("JoystickButtonView:OnRegisterBinder")

end

return JoystickButtonView