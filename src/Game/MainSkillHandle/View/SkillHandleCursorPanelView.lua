---
--- Author: ccppeng
--- DateTime: 2025-06-26 16:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")
local InputCallback = require("Game/Input/InputCallback")
local MajorUtil = require("Utils/MajorUtil")
---@class SkillHandleCursorPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgHandle UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillHandleCursorPanelView = LuaClass(UIView, true)

function SkillHandleCursorPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgHandle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillHandleCursorPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

local CursorSpeedMin = 10
local CursorDefault = 20
function SkillHandleCursorPanelView:OnInit()
	self.CursorSpeed = CursorDefault
	self.CursorLimitX = 1000
	self.CursorLimitY = 1000
	self.MaxFPSParam = 1
	self.CursorX = 0
	self.CursorY = 0
end

function SkillHandleCursorPanelView:OnDestroy()

end

function SkillHandleCursorPanelView:OnShow()
	local Params1 = _G.EventMgr:GetEventParams()
	Params1.StringParam1 = ""
	Params1.StringParam2 = "MoveRight"
	Params1.IntParam1 = EventID.VirtualCursorClickMoveX
	Params1.IntParam2 = SettingsHandleDefine.HandleActionPriority.Cursor
	local Params2 = _G.EventMgr:GetEventParams()
	Params2.StringParam1 = ""
	Params2.StringParam2 = "MoveForward"
	Params2.IntParam1 = EventID.VirtualCursorClickMoveY
	Params2.IntParam2 = SettingsHandleDefine.HandleActionPriority.Cursor
	local Params3 = _G.EventMgr:GetEventParams()
	Params3.IntParam1 = SettingsHandleDefine.HandleCustomActionType.NormalSkill
	Params3.IntParam2 = EventID.VirtualCursorClickEnd
	Params3.IntParam3 = SettingsHandleDefine.HandleActionPriority.Cursor
	local Params4 = _G.EventMgr:GetEventParams()
	Params4.IntParam1 = SettingsHandleDefine.HandleCustomActionType.NormalSkill
	Params4.IntParam2 = EventID.VirtualCursorClickStart
	Params4.IntParam3 = SettingsHandleDefine.HandleActionPriority.Cursor
	_G.EventMgr:SendCppEvent(EventID.RegisiterAxisData,Params1)
	_G.EventMgr:SendCppEvent(EventID.RegisiterAxisData,Params2)
	_G.EventMgr:SendCppEvent(EventID.RegisiterKeyUpData,Params3)
	_G.EventMgr:SendCppEvent(EventID.RegisiterKeyDownData,Params4)
	self.CursorSpeed = _G.SettingsHandleMgr:GetHandleCursorSpeed()
	self.Clicking = false
	self:ResetCursorPosition()
	---Todo:@kanohchen 临时方案解决摇杆技能按下时，按键被抢注册，导致没有释放事件的问题
	_G.EventMgr:SendEvent(EventID.GamePadSkillCancel)
	self:ResetVirtualJoystick()
	-- 解除自动移动
    _G.UE.UActorManager.Get():SetVirtualJoystickIsSprintLocked(false)
	--禁止摇杆输入
	_G.UE.UActorManager.Get():SetVirtualJoystickCanProcessAnalog(false)
	self:OnSettingsMaxFPSChanged()
end

function SkillHandleCursorPanelView:OnHide()
	local Params1 = _G.EventMgr:GetEventParams()
	Params1.StringParam1 = ""
	Params1.StringParam2 = "MoveRight"
	Params1.IntParam1 = EventID.VirtualCursorClickMoveX
	Params1.IntParam2 = SettingsHandleDefine.HandleActionPriority.Cursor
	local Params2 = _G.EventMgr:GetEventParams()
	Params2.StringParam1 = ""
	Params2.StringParam2 = "MoveForward"
	Params2.IntParam1 = EventID.VirtualCursorClickMoveY
	Params2.IntParam2 = SettingsHandleDefine.HandleActionPriority.Cursor
	local Params3 = _G.EventMgr:GetEventParams()
	Params3.IntParam1 = SettingsHandleDefine.HandleCustomActionType.NormalSkill
	Params3.IntParam2 = EventID.VirtualCursorClickEnd
	Params3.IntParam3 = SettingsHandleDefine.HandleActionPriority.Cursor
	local Params4 = _G.EventMgr:GetEventParams()
	Params4.IntParam1 = SettingsHandleDefine.HandleCustomActionType.NormalSkill
	Params4.IntParam2 = EventID.VirtualCursorClickStart
	Params4.IntParam3 = SettingsHandleDefine.HandleActionPriority.Cursor
	_G.EventMgr:SendCppEvent(EventID.UnRegisiterAxisData,Params1)
	_G.EventMgr:SendCppEvent(EventID.UnRegisiterAxisData,Params2)
	_G.EventMgr:SendCppEvent(EventID.UnRegisiterKeyUpData,Params3)
	_G.EventMgr:SendCppEvent(EventID.UnRegisiterKeyDownData,Params4)
	_G.UE.UActorManager.Get():SetVirtualJoystickCanProcessAnalog(true)
end
function SkillHandleCursorPanelView:OnStartClick(Params)
		local WidgetSize = UIUtil.CanvasSlotGetSize(self.ImgHandle)
		local ScreenPosition = UIUtil.LocalToAbsolute(self.ImgHandle, _G.UE.FVector2D(0, 0))
		local ClickPosition = UIUtil.LocalToAbsolute(self.ImgHandle, _G.UE.FVector2D(WidgetSize.X/2, WidgetSize.Y/2))
		if ScreenPosition.X ~= 0 and ScreenPosition.Y ~= 0 then
			_G.EventMgr:SendEvent(EventID.SimulatedTouchStartClickConfirm, ClickPosition)
			self.Clicking= true
		end
end
function SkillHandleCursorPanelView:OnEndClick(Params)
		local WidgetSize = UIUtil.CanvasSlotGetSize(self.ImgHandle)
		local ScreenPosition = UIUtil.LocalToAbsolute(self.ImgHandle, _G.UE.FVector2D(0, 0))
		local ClickPosition = UIUtil.LocalToAbsolute(self.ImgHandle, _G.UE.FVector2D(WidgetSize.X/2, WidgetSize.Y/2))
		if ScreenPosition.X ~= 0 and ScreenPosition.Y ~= 0 then
			_G.EventMgr:SendEvent(EventID.SimulatedTouchEndClickConfirm, ClickPosition)
			self.Clicking = false
		end
end
function SkillHandleCursorPanelView:OnClickMoveX(Params)
		local ScreenPosition = UIUtil.LocalToAbsolute(self.ImgHandle, _G.UE.FVector2D(0,0))
		if ScreenPosition.X ~= 0 and ScreenPosition.Y ~= 0 then
			local WidgetSize = UIUtil.CanvasSlotGetSize(self.ImgHandle)
			ScreenPosition.X = ScreenPosition.X+WidgetSize.X/2
			ScreenPosition.Y = ScreenPosition.Y+WidgetSize.Y/2
			local Slot = UIUtil.SlotAsCanvasSlot(self.ImgHandle)
			local Position = Slot:GetPosition()
			self.CursorX = Params.FloatParam1
			Position.X = Position.X + self:GetCurrentCursorSpeed(Params.FloatParam1) * self.MaxFPSParam
			if (Params.FloatParam1 > 0.1 or Params.FloatParam1 < -0.1) then
				if Position.X > self.CursorLimitX then
					Position.X = self.CursorLimitX
				end
				if Position.X < -self.CursorLimitX then
					Position.X = -self.CursorLimitX
				end
				Slot:SetPosition(Position)
				if self.Clicking  then
					InputCallback.SimulatedTouchMove(ScreenPosition)
				end
			end
			--print(Position)
			--_G.EventMgr:SendEvent(EventID.SimulatedTouchStartClickConfirm, ScreenPosition)FloatParam1
		end
end
function SkillHandleCursorPanelView:OnClickMoveY(Params)
		local ScreenPosition = UIUtil.LocalToAbsolute(self.ImgHandle, _G.UE.FVector2D(0,0))
		if ScreenPosition.X ~= 0 and ScreenPosition.Y ~= 0 then
			local WidgetSize = UIUtil.CanvasSlotGetSize(self.ImgHandle)
			ScreenPosition.X = ScreenPosition.X+WidgetSize.X/2
			ScreenPosition.Y = ScreenPosition.Y+WidgetSize.Y/2
			--_G.EventMgr:SendEvent(EventID.SimulatedTouchStartClickConfirm, ScreenPosition)
			local Slot = UIUtil.SlotAsCanvasSlot(self.ImgHandle)
			local Position = Slot:GetPosition()
			self.CursorY = Params.FloatParam1
			Position.Y = Position.Y - self:GetCurrentCursorSpeed(Params.FloatParam1) * self.MaxFPSParam
			if Params.FloatParam1 > 0.1 or Params.FloatParam1 < -0.1 then
				if Position.Y > self.CursorLimitY then
					Position.Y = self.CursorLimitY
				end
				if Position.Y < -self.CursorLimitY then
					Position.Y = -self.CursorLimitY
				end
				Slot:SetPosition(Position)
				if self.Clicking  then
					InputCallback.SimulatedTouchMove(ScreenPosition)
				end
			end

			--print(Position)
		end
end
function SkillHandleCursorPanelView:OnRegisterUIEvent()

end

function SkillHandleCursorPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.VirtualCursorClickStart, self.OnStartClick)
	self:RegisterGameEvent(EventID.VirtualCursorClickMoveX, self.OnClickMoveX)
	self:RegisterGameEvent(EventID.VirtualCursorClickMoveY, self.OnClickMoveY)
	self:RegisterGameEvent(EventID.VirtualCursorClickEnd, self.OnEndClick)
	self:RegisterGameEvent(EventID.CursorSpeedChange, self.OnCursorSpeedChange)
	self:RegisterGameEvent(EventID.InputActionTypeChange, self.OnInputActionTypeChange)
	self:RegisterGameEvent(EventID.SettingsMaxFPSChanged, self.OnSettingsMaxFPSChanged)
end

function SkillHandleCursorPanelView:OnCursorSpeedChange(Value)
	if nil ~= Value and Value >= CursorSpeedMin then
	    self.CursorSpeed = Value
    end
end

function SkillHandleCursorPanelView:OnRegisterBinder()

end

function SkillHandleCursorPanelView:ResetCursorPosition()
	local WidgetSize = UIUtil.GetWidgetSize(self)
	self.CursorLimitX = WidgetSize.X / 2
	self.CursorLimitY = WidgetSize.Y / 2
	local Slot = UIUtil.SlotAsCanvasSlot(self.ImgHandle)
	Slot:SetPosition(_G.UE.FVector2D(0,0))
end

function SkillHandleCursorPanelView:OnInputActionTypeChange(IsHandleAttached)
	if IsHandleAttached == false then
		 local Params1 = _G.EventMgr:GetEventParams()
            Params1.IntParam2 = -1
            _G.EventMgr:SendCppEvent(EventID.SwitchOpenCloseVirtualCursor, Params1)
	end
end

function SkillHandleCursorPanelView:ResetVirtualJoystick()
	local MajorController = MajorUtil.GetMajorController()
	if MajorController == nil then return end
	MajorController:VirtualJoystickReset()
end

function SkillHandleCursorPanelView:GetCurrentCursorSpeed(Param)
	-- if Param <= -0.1 then
	-- 	return  -(2^(-Param*6 - 0.6) * (self.CursorSpeed/18/2)) - 1
	-- elseif Param > 0.1 then
	-- 	return  2^(6*Param - 0.6) * (self.CursorSpeed/18/2) + 1
	-- end
    local IsPositive = true
	if Param < 0 then
		Param = -Param
		IsPositive = false
	end
	local CursorScale = math.sqrt(self.CursorX*self.CursorX + self.CursorY*self.CursorY)
	local result = CursorDefault
	if CursorScale >= 0.1 and CursorScale < 0.2 then
		result = 1
	elseif CursorScale >= 0.2 and CursorScale < 0.6 then
		result = (Param - 0.1) * (self.CursorSpeed/0.9)/4 + 1
	elseif  CursorScale >= 0.6 and CursorScale < 0.9 then
		result = (Param - 0.1) * (self.CursorSpeed/0.9)/2 + 1
	else
		result = (Param - 0.1) * (self.CursorSpeed/0.9) + 1
	end
	if not IsPositive then
		result = -result
	end
	return result
end

function SkillHandleCursorPanelView:OnSettingsMaxFPSChanged()
	local MaxFPSValue = _G.SettingsMgr:GetMaxFPSValue()
	self.MaxFPSParam = 4/(MaxFPSValue/15)
end

return SkillHandleCursorPanelView