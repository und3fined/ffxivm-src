---
--- Author: anypkvcai
--- DateTime: 2021-03-02 10:15
--- Description:
---

local CommonUtil = require("Utils/CommonUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local MainPanelVM = require("Game/Main/MainPanelVM")
local MajorUtil = require("Utils/MajorUtil")
local SkillUtil = require("Utils/SkillUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")

local UHUDMgr
local IE_Pressed = _G.UE.EInputEvent.IE_Pressed
local IE_Released = _G.UE.EInputEvent.IE_Released

---@class InputCallback
---@field HiddenCount number
local InputCallback = {

	-- 1.按下一次"F10"键，隐藏UI 仅保留HUD(场景中血条，名字，选中状态，伤害飘字)
	-- 2.再次按下一次"F10"，隐藏HUD 显示UI
	-- 3.再次按下一次"F10"，隐藏所有
	-- 4.再次按下一次"F10"，恢复显示
	HiddenCount = 0,

	IsControllerSLPressed = false,
	SelectButtonName = nil,
	SelectSkillIdList = nil,
	ControllerSkillPressedIndex = {},
}

function InputCallback.OnShowGMUI()
	if nil == UHUDMgr then
		UHUDMgr = _G.UE.UHUDMgr:Get()
	end

	local ProtoRes = require("Protocol/ProtoRes")
	local ModuleType = ProtoRes.module_type

	if not _G.LoginMgr:IsModuleSwitchOn(ModuleType.MODULE_GM) then
		return
	end

	if UIViewMgr:IsViewVisible(UIViewID.GMMain) then
		UIViewMgr:HideView(UIViewID.GMMain)
	else
		UIViewMgr:ShowView(UIViewID.GMMain)
	end
end

function InputCallback.OnHideUI()
	if nil == UHUDMgr then
		UHUDMgr = _G.UE.UHUDMgr:Get()
	end

	if 0 == InputCallback.HiddenCount then
		--_G.UIViewMgr:ShowLayer(UILayer.Input)
		_G.UIViewMgr:HideAllLayer()
		CommonUtil.HideJoyStick()
		InputCallback.HiddenCount = InputCallback.HiddenCount + 1
	elseif 1 == InputCallback.HiddenCount then
		_G.UIViewMgr:RestoreLayer()
		CommonUtil.ShowJoyStick()
		UHUDMgr:SetIsDrawHUD(false)
		InputCallback.HiddenCount = InputCallback.HiddenCount + 1
	elseif 2 == InputCallback.HiddenCount then
		_G.UIViewMgr:HideAllLayer()
		CommonUtil.HideJoyStick()
		UHUDMgr:SetIsDrawHUD(false)
		InputCallback.HiddenCount = InputCallback.HiddenCount + 1
	else
		InputCallback.HiddenCount = 0
		_G.UIViewMgr:RestoreLayer()
		CommonUtil.ShowJoyStick()
		UHUDMgr:SetIsDrawHUD(true)
	end
end

function InputCallback.OnShowDebugTool()
	if nil == UHUDMgr then
		UHUDMgr = _G.UE.UHUDMgr:Get()
	end

	local ProtoRes = require("Protocol/ProtoRes")
	local ModuleType = ProtoRes.module_type

	if not _G.LoginMgr:IsModuleSwitchOn(ModuleType.MODULE_GM) then
		return
	end

	if UIViewMgr:IsViewVisible(UIViewID.FieldTestPanel) then
		UIViewMgr:HideView(UIViewID.FieldTestPanel)
	else
		UIViewMgr:ShowView(UIViewID.FieldTestPanel)
	end

end

local IsCurrentFocusInputBox <const> = _G.UE.UUIUtil.IsCurrentFocusInputBox

function InputCallback.OnSkillPressed(Index)
	-- 当前聚焦在输入框时, 屏蔽InputAction, 防止打字误触技能
	if not IsCurrentFocusInputBox() then
		-- print("InputCallback.OnSkillPressed", Index)
		EventMgr:SendEvent(EventID.InputActionSkillPressed, Index)
	end
end

function InputCallback.OnSkillReleased(Index)
	if not IsCurrentFocusInputBox() then
		-- print("InputCallback.OnSkillReleased", Index)
		EventMgr:SendEvent(EventID.InputActionSkillReleased, Index)
	end
end

function InputCallback.OnHandlePressed(ButtonName)
	InputCallback.HandleControllerEvent(ButtonName, IE_Pressed)
end

function InputCallback.OnHandleReleased(ButtonName)
	InputCallback.HandleControllerEvent(ButtonName, IE_Released)
end

function InputCallback.HandleControllerEvent(ButtonName, EventType)
	if ButtonName == "B" then
		if MainPanelVM.IsFightState then
			InputCallback.HandleSkillButtonEvent(9, ButtonName, EventType)
		else
			InputCallback.HandleSkillButtonEvent(10, ButtonName, EventType)
		end
	elseif ButtonName == "A" then
		if MainPanelVM.IsFightState then
			InputCallback.HandleSkillButtonEvent(8, ButtonName, EventType)
		else
			InputCallback.HandleJumpButtonEvent(ButtonName, EventType)
		end
	elseif ButtonName == "X" then
		InputCallback.HandleSkillButtonEvent(0, ButtonName, EventType)
	elseif ButtonName == "Y" then
		if MainPanelVM.IsFightState then
			InputCallback.HandleSkillButtonEvent(1, ButtonName, EventType)
		end
	elseif ButtonName == "U" then
		if MainPanelVM.IsFightState then
			InputCallback.HandleSkillButtonEvent(19, ButtonName, EventType)
		end
	elseif ButtonName == "D" then
		if MainPanelVM.IsFightState then
			InputCallback.HandleSkillButtonEvent(19, ButtonName, EventType)
		end
	elseif ButtonName == "L" then
		if MainPanelVM.IsFightState then
				InputCallback.HandleSkillButtonEvent(20, ButtonName, EventType)
		end
	elseif ButtonName == "R" then
		if MainPanelVM.IsFightState then
			InputCallback.HandleSkillButtonEvent(11, ButtonName, EventType)
		end
	elseif ButtonName == "LB" then
		if MainPanelVM.IsFightState then
			if InputCallback.IsControllerSLPressed then
				InputCallback.HandleSkillButtonEvent(6, ButtonName, EventType)
			else
				InputCallback.HandleSkillButtonEvent(2, ButtonName, EventType)
			end
		end
	elseif ButtonName == "RB" then
		if MainPanelVM.IsFightState then
			if InputCallback.IsControllerSLPressed then
				InputCallback.HandleSkillButtonEvent(7, ButtonName, EventType)
			else
				InputCallback.HandleSkillButtonEvent(3, ButtonName, EventType)
			end
		end
	elseif ButtonName == "LT" then
		if MainPanelVM.IsFightState then
			InputCallback.HandleSkillButtonEvent(4, ButtonName, EventType)
		end
	elseif ButtonName == "RT" then
		if MainPanelVM.IsFightState then
			InputCallback.HandleSkillButtonEvent(5, ButtonName, EventType)
		end
	elseif ButtonName == "SR" then
		if MainPanelVM.IsFightState then
			local LBIndex = _G.SkillLimitMgr:GetLimitSkillIndex()
			InputCallback.HandleSkillButtonEvent(LBIndex, ButtonName, EventType)
		end
	elseif ButtonName == "SL" then
		InputCallback.IsControllerSLPressed = EventType == IE_Pressed
	end
end

function InputCallback.HandleSkillButtonEvent(Param, ButtonName, ButtonEventType)
	if ButtonEventType == IE_Pressed then
		InputCallback.SelectSkillIdList = InputCallback.GetSkillSelectIdList(Param)

		if InputCallback.SelectSkillIdList == nil then
			InputCallback.ControllerSkillPressedIndex[ButtonName] = Param
			InputCallback.OnSkillPressed(Param)
		else
			FLOG_INFO("Controller: selectable skill pressed")
			InputCallback.SelectButtonName = ButtonName
			MajorUtil.SetCameraControlEnabled(false)
		end
	elseif ButtonEventType == IE_Released then
		if InputCallback.SelectButtonName ~= ButtonName then
			if InputCallback.ControllerSkillPressedIndex[ButtonName] then
				local StoredParam = InputCallback.ControllerSkillPressedIndex[ButtonName]
				InputCallback.OnSkillReleased(StoredParam)
			else
				InputCallback.OnSkillReleased(Param)
			end
			InputCallback.ControllerSkillPressedIndex[ButtonName] = nil
		else
			FLOG_INFO("Controller: selectable skill released")
			InputCallback.SelectButtonName = nil
			MajorUtil.SetCameraControlEnabled(true)
		end
		InputCallback.SelectSkillIdList = nil
	end

end

function InputCallback.HandleDirectCastSkill(SkillID)
	SkillUtil.SendCastSkillEvent(_G.UE.ESkillCastType.NormalType, SkillID, 0, 0, 0, 50, nil)
end

function InputCallback.GetSkillSelectIdList(Index)
	local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	if LogicData == nil then return nil end
	local SkillData = LogicData.SkillMap[Index]
	if SkillData == nil then return nil end
	local SkillCfg = SkillMainCfg:FindCfgByKey(SkillData.SkillID)
	if SkillCfg == nil or #SkillCfg.SelectIdList == 0 then return nil end
	for i = 1, #SkillCfg.SelectIdList do
		if SkillCfg.SelectIdList[i].ID ~= 0 then
			return SkillCfg.SelectIdList
		end
	end
	return nil
end

function InputCallback.HandleJumpButtonEvent(ButtonEventType)
	local MajorController = MajorUtil.GetMajorController()
	if MajorController == nil then return end
	if ButtonEventType == IE_Pressed then
		MajorController:JumpStart()
	elseif ButtonEventType == IE_Released then
		MajorController:JumpEnd()
	end
end

function InputCallback.OnRJoystickSelect(Angle)
	FLOG_INFO("RJoystickSelect %s", tonumber(Angle))
	if SelectButtonName ~= nil or InputCallback.SelectSkillIdList == nil then return end
	local SelectSkillCount = #InputCallback.SelectSkillIdList
	local Index = 0
	if SelectSkillCount == 2 then
		if Angle > 270 or Angle < 90 then
			Index = 1
		else
			Index = 2
		end
	elseif SelectSkillCount == 3 then
		if Angle >= 270 or Angle < 30 then
			Index = 1
		elseif Angle >= 30 and Angle < 150 then
			Index = 2
		else
			Index = 3
		end
	elseif SelectSkillCount == 4 then
		if Angle >= 315 or Angle < 45 then
			Index = 2
		elseif Angle >= 45 and Angle < 135 then
			Index = 3
		elseif Angle >= 135 and Angle < 225 then
			Index = 4
		else
			Index = 1
		end
	else
		Index = math.ceil(Angle / 360 * SelectSkillCount)
	end

	if InputCallback.SelectSkillIdList[Index] == nil then return end
	InputCallback.HandleDirectCastSkill(InputCallback.SelectSkillIdList[Index].ID)
	FLOG_INFO("RJoystick select skill index = %s, skillID = %s", tonumber(Index), tonumber(InputCallback.SelectSkillIdList[Index].ID))
end

return InputCallback