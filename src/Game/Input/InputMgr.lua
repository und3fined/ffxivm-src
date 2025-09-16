---
--- Author: anypkvcai
--- DateTime: 2021-03-02 10:10
--- Description:
---
---
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local InputConfig = require("Define/InputConfig")
local ChocoboInputConfig = require("Game/Chocobo/Race/ChocoboInputConfig")
local InputCallback = require("Game/Input/InputCallback")
local EventID = require("Define/EventID")
local InputActionConfig = InputConfig.InputActionConfig

---@class InputMgr : MgrBase
local InputMgr = LuaClass(MgrBase)

function InputMgr:OnInit()
end

function InputMgr:OnBegin()
end

function InputMgr:OnEnd()
end

function InputMgr:OnShutdown()

end

function InputMgr:OnRegisterNetMsg()

end

function InputMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ControllerRightJoystickSelect, self.OnGameEventRJoystickSelect)
end

function InputMgr.OnSetupInput()
	print("InputMgr:OnSetupInput")

	_G.InputMgr:OnRegisterInput()
end

--- FOnApplicationMousePreInputButtonDown
function InputMgr.OnApplicationMousePreInputButtonDown(pointEvent)
	print("OnApplicationMousePreInputButtonDown", pointEvent)
end

--- FOnApplicationMousePreInputButtonUp
function InputMgr.OnApplicationMousePreInputButtonUp(pointEvent)
	print("OnApplicationMousePreInputButtonUp", pointEvent)
end

-- InputAction的回调集合，在此处分发
function InputMgr.OnPlayerInputActionCallback(ActionName, EventType)
	--print("OnPlayerInputActionCallback", ActionName, EventType)

	local Cfg = InputConfig:FindActionConfig(ActionName, EventType)
	if nil == Cfg then return end

	if nil ~= Cfg.Callback then
		Cfg.Callback(Cfg.Params)
	end
end

-- InputAxis的回调集合，在此处分发
function InputMgr.OnPlayerInputAxisCallback(AxisName, AxisValue)
	print("OnPlayerInputAxisCallback", AxisName, AxisValue)
end

-- InputKey的回调集合，在此处分发
function InputMgr.OnPlayerInputKeyCallback(KeyName, EventType)
	print("OnPlayerInputKeyCallback", KeyName, EventType)

	if _G.ChocoboRaceMgr:IsInputVisible() then
		local Cfg = ChocoboInputConfig:FindActionConfig(KeyName, EventType)
		if nil == Cfg then return end

		if nil ~= Cfg.Callback then
			Cfg.Callback(Cfg.Params)
		end
	end
end

-- InputTouch的回调集合，在此处分发
function InputMgr.OnPlayerInputTouchCallback(EventType, FingerIndex, Location)
	print("OnPlayerInputTouchCallback", EventType, FingerIndex, Location)
end

-- InputVector的回调集合，在此处分发
function InputMgr.OnPlayerInputVectorCallback(Key, Vector)
	print("OnPlayerInputVectorCallback", Key, Vector)
end

function InputMgr:OnRegisterInput()
	print("InputMgr:OnRegisterInput")

	self:RegisterPlayerInputAction()
end

function InputMgr:RegisterPlayerInputAction()
	for _, v in pairs(InputActionConfig) do
		_G.UE.UInputMgr.Get():RegisterPlayerInputActionForLua(v.Action, v.Event)
	end
end

function InputMgr:OnGameEventRJoystickSelect(Params)
	local Angle = Params.FloatParam1
	InputCallback.OnRJoystickSelect(Angle)
end

return InputMgr