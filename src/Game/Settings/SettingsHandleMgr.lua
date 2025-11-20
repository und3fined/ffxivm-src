local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MgrBase = require("Common/MgrBase")
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")
local SaveKey = require("Define/SaveKey")
local EventID = require("Define/EventID")
local SettingsUtils = require("Game/Settings/SettingsUtils")
local CommonUtil = require("Utils/CommonUtil")
local MajorUtil = require("Utils/MajorUtil")
local GameplayStaticsUtil = require("Utils/GameplayStaticsUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local USaveMgr
local LSTR = _G.LSTR

---@class SettingsHandleMgr : MgrBase
local SettingsHandleMgr = LuaClass(MgrBase)

local HandleMainType<const> = SettingsHandleDefine.HandleMainType
local HandleInputActionConfig<const> = SettingsHandleDefine.HandleInputActionConfig
local HandleOtherActionConfig<const> = SettingsHandleDefine.HandleOtherActionConfig
local HandleCusActionFunc<const> = SettingsHandleDefine.HandleCusActionFunc
local HandleCustomActionConfig<const> = SettingsHandleDefine.HandleCustomActionConfig
local HandleCustomActionType<const> = SettingsHandleDefine.HandleCustomActionType

function SettingsHandleMgr:OnInit()
    self.IsHandleAttached = false
    self.CursorActionKey = HandleInputActionConfig.HandleLB.Index
    self.HandleCloseBtnNum = 0
end

function SettingsHandleMgr:OnBegin()
    USaveMgr = _G.UE.USaveMgr
    _G.UE.USettingUtil.BindControllerConnectionChange()
    self.IsHandleAttached = _G.UE.USettingUtil.IsMajorGamepadAttached()
    self.CursorSpeed = 20
end

function SettingsHandleMgr:OnEnd()
end

function SettingsHandleMgr:OnShutdown()

end

function SettingsHandleMgr:OnRegisterNetMsg()
	
end
function SettingsHandleMgr:OnRegisterTimer()
    self:RegisterTimer(self.ExecuteHandleAttached, 1)
end

function SettingsHandleMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.CursorSpeedChange, self.OnCursorSpeedChange)
    self:RegisterGameEvent(EventID.MajorCreate, self.InitHandleMode)
    self:RegisterGameEvent(EventID.LoginToRoleSuccess, self.ExecuteHandleAttached)
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.UpdateByMajorProfSwitch)
end

-------为通用关闭加个注册计数机制----------------
---
function SettingsHandleMgr:RegisterHandleKeyDownData(HandleAction)
	if nil == SettingsHandleDefine.HandleCustomActionConfig[HandleAction] then
        return
	end
    if self.HandleCloseBtnNum > 0 then
        self.HandleCloseBtnNum = self.HandleCloseBtnNum + 1
		return
	end
	self.HandleCloseBtnNum = self.HandleCloseBtnNum + 1
	local Params1 = _G.EventMgr:GetEventParams()
	Params1.IntParam1 = HandleAction
	Params1.IntParam2 = EventID.GamePadClose
	Params1.IntParam3 = SettingsHandleDefine.HandleActionPriority.CommonUI
	_G.EventMgr:SendCppEvent(EventID.RegisiterKeyDownData, Params1)
end

function SettingsHandleMgr:UnRegisterHandleKeyDownData(HandleAction)
	if nil == SettingsHandleDefine.HandleCustomActionConfig[HandleAction] then
		return
	end
    if self.HandleCloseBtnNum > 1 then
        self.HandleCloseBtnNum = self.HandleCloseBtnNum - 1
		return
    elseif self.HandleCloseBtnNum <= 0 then
        self.HandleCloseBtnNum = 0
        return
	end
    self.HandleCloseBtnNum = 0
	local Params1 = _G.EventMgr:GetEventParams()
	Params1.IntParam1 = HandleAction
	Params1.IntParam2 = EventID.GamePadClose
	Params1.IntParam3 = SettingsHandleDefine.HandleActionPriority.CommonUI
	_G.EventMgr:SendCppEvent(EventID.UnRegisiterKeyDownData, Params1)
end
--------------------------------------------

----------手柄连接状态相关----------------------------------------
---GamePadConnectionChange时调用
function SettingsHandleMgr:CanStartHandleMode(IsHandleAttached)
    self.IsHandleAttached = IsHandleAttached
    self:ExecuteHandleAttached()
    return nil ~= SettingsUtils["SettingsTabHandle"]
end

--处理手柄连接
function SettingsHandleMgr:ExecuteHandleAttached()
    if self.IsHandleAttached then
        self:RegisterOpenCursor()
        self:GetHandleCursorSpeed()
    else
        self:UnRegisterOpenCursor()
    end
end


function SettingsHandleMgr:GetIsHandleAttached()
    if SettingsUtils["SettingsTabHandle"] then
        return SettingsUtils["SettingsTabHandle"]:GetIsHandleAttached()
    else
        return self.IsHandleAttached
    end
end
-----------------------------------------------------------------

----------光标相关----------------------------------------
--光标注册
function SettingsHandleMgr:RegisterOpenCursor()
    local MajorController = self:GetMajorController()
    if nil == MajorController then
        return
    end
    local HandleActionID = self.CursorActionKey
    local CursorActionID = EventID.SwitchOpenCloseVirtualCursor
    if nil == CursorActionID then
        return
    end
    if MajorController:FindKeyDownAndUpData(HandleActionID, CursorActionID, 
        SettingsHandleDefine.HandleActionPriority.Cursor, false) == false then
        local Params1 = _G.EventMgr:GetEventParams()
        Params1.IntParam1 = HandleActionID
        Params1.IntParam2 = CursorActionID
        Params1.IntParam3 = SettingsHandleDefine.HandleActionPriority.Cursor
        _G.EventMgr:SendCppEvent(EventID.RegisiterKeyUpData, Params1)
    end
end

function SettingsHandleMgr:UnRegisterOpenCursor()
    local MajorController = self:GetMajorController()
    if nil == MajorController then
        return
    end
    local HandleActionID = self.CursorActionKey
    local CursorActionID = EventID.SwitchOpenCloseVirtualCursor
    if nil == CursorActionID then
        return
    end
    if MajorController:FindKeyDownAndUpData(HandleActionID, CursorActionID, 
        SettingsHandleDefine.HandleActionPriority.Cursor, false) then
        local Params1 = _G.EventMgr:GetEventParams()
        Params1.IntParam1 = HandleActionID
        Params1.IntParam2 = CursorActionID
        Params1.IntParam3 = SettingsHandleDefine.HandleActionPriority.Cursor
        _G.EventMgr:SendCppEvent(EventID.UnRegisiterKeyUpData, Params1)
    end
end

--光标速度
function SettingsHandleMgr:GetHandleCursorSpeed()
    if nil ~= SettingsUtils["SettingsTabHandle"] and nil ~= SettingsUtils["SettingsTabHandle"].CursorSpeed then
        self.CursorSpeed =  SettingsUtils["SettingsTabHandle"].CursorSpeed
    else
        local CursorSpeed = _G.UE.USaveMgr.GetInt(SaveKey["HandleCursorSpeed"], -1, false)
        if nil ~= CursorSpeed and CursorSpeed > 0 then
            self.CursorSpeed = CursorSpeed
        end
    end
    return self.CursorSpeed
end

function SettingsHandleMgr:OnCursorSpeedChange(Value)
    if nil ~= Value and Value >= 10 then
	    self.CursorSpeed = Value
    end
end

function SettingsHandleMgr:GetVirtualCursorWidget()
    local VirtualCursorWidget = SettingsHandleDefine.HandleVirtualCursorWidget
    return VirtualCursorWidget
end

local IsCurrentFocusInputBox <const> = _G.UE.UUIUtil.IsCurrentFocusInputBox
function SettingsHandleMgr:SwitchOpenCloseVirtualCursor(bIsOpen)
    local IsOpen = -1
    if bIsOpen then
        IsOpen = 1
    end
    if self:GetIsHandleAttached() then
        if not IsCurrentFocusInputBox() then
            local Params1 = _G.EventMgr:GetEventParams()
            Params1.IntParam2 = IsOpen
            _G.EventMgr:SendCppEvent(EventID.SwitchOpenCloseVirtualCursor, Params1)
        end
    end
end
-----------------------------------------------------------------

------------------手柄自定义Action映射------------------------------------

function SettingsHandleMgr:StartHandleCusAction(Params, EventType)
    local InputAction = Params.BtnName
    local CurHandleCusAction = self:FindHandleCusAction(InputAction)
    if nil == CurHandleCusAction then
        return
    end
    local CusActionName = CurHandleCusAction[1]
    local CusActionParam= CurHandleCusAction[2]
    if nil == CusActionName then
        return
    end
    print("SettingsMgr.StartHandleCusAction%s %s %s", Params.BtnName, CusActionParam, EventType)
    local CurHandleCusActionFunc = HandleCusActionFunc[CusActionName]
    if nil ~= CurHandleCusActionFunc then
        if type(CurHandleCusActionFunc) == "string" or type(CurHandleCusActionFunc) == "number" then
            _G.EventMgr:SendEvent(CurHandleCusActionFunc, {CusActionName = CusActionName, EventType = EventType})
        else
            Params.Index = CusActionParam
            CurHandleCusActionFunc(Params, EventType)
        end
    end
end

function SettingsHandleMgr:FindHandleCusAction(InputAction)
    if nil == HandleInputActionConfig[InputAction] then
        return
    end
    if HandleInputActionConfig[InputAction].MainType == HandleMainType.Other then
        return HandleOtherActionConfig[InputAction].Params
    else
        if nil == SettingsUtils["SettingsTabHandle"] then
            return
        end
        local CurActionIndex = SettingsUtils["SettingsTabHandle"]:GetCusActionIndexBySaveKey(InputAction)
        if nil ~= CurActionIndex then
            return HandleCustomActionConfig[CurActionIndex].Params
        end
    end
end


--CusAction相关接口
function SettingsHandleMgr:GetHandleInputActionByCusAction(CusAction)
    local InputAction = CusAction
    if CusAction > 100 then
        InputAction = self:GetSaveKeyByCusAction(CusAction)
    else
        InputAction = self:GetOtherActionByCusAction(CusAction)
    end
    return InputAction
end

function SettingsHandleMgr:GetSaveKeyByCusAction(CusAction)
    if nil == CusAction then
        return
    end
    if nil ~= SettingsUtils["SettingsTabHandle"] then
        return SettingsUtils["SettingsTabHandle"]:GetSaveKeyByCusAction(CusAction)
    end 
    for key, value in pairs(SettingsHandleDefine.HandleDefaultCustomAction) do
        if value == CusAction then
            return key
        end
    end
end

function SettingsHandleMgr:GetOtherActionByCusAction(CusAction)
    if nil == CusAction then
        return
    end
    if nil ~= SettingsUtils["SettingsTabHandle"] then
        return SettingsUtils["SettingsTabHandle"]:GetOtherActionByCusAction(CusAction)
    end 
    for key, value in pairs(SettingsHandleDefine.HandleInputActionConfig) do
        if CusAction == value.Index then
            return key
        end
    end
end

function SettingsHandleMgr:GetHandleInputActionTextByCusAction(CusAction)
    local InputAction = self:GetHandleInputActionByCusAction(CusAction)
    if InputAction and HandleInputActionConfig[InputAction] then
       return HandleInputActionConfig[InputAction].Text
    end
    return ""
end

-----------------------------------------------------------------

------------手柄辅助模式----------------------------------------
---
--手柄辅助模式是否开启
function SettingsHandleMgr:IsGameHandleMode()
    if nil == SettingsUtils["SettingsTabHandle"] then
        return false
    end
    return SettingsUtils["SettingsTabHandle"]:GetHandleMode()
end


function SettingsHandleMgr:InitHandleMode()
    if _G.DemoMajorType == 1 then
        return
    end
    _G.UE.USettingUtil.BindControllerConnectionChange()
    local IsHandleAttached = _G.UE.USettingUtil.IsMajorGamepadAttached()
    if self:CanStartHandleMode(IsHandleAttached) then
        self:IsStartHandleMode(IsHandleAttached, true)
    end
end
function SettingsHandleMgr:IsStartHandleMode(IsHandleAttached, bSendHandleModeEvent)
    if IsHandleAttached and SettingsUtils["SettingsTabHandle"].IsHandleAttached == false then
        SettingsUtils["SettingsTabHandle"]:StartHandleMode()
        --安卓没有断开事件，需要定义一个计时器进行检测
        self:StartAndroidHandleCheck()
    elseif IsHandleAttached == false and SettingsUtils["SettingsTabHandle"].IsHandleAttached then
        SettingsUtils["SettingsTabHandle"]:StopHandleMode()
    elseif bSendHandleModeEvent then
        local CurHandleMode = SettingsUtils["SettingsTabHandle"]:GetHandleMode()
        SettingsUtils["SettingsTabHandle"]:SetHandleMode(CurHandleMode)
    end
end

function SettingsHandleMgr:StartAndroidHandleCheck()
    local Platform = CommonUtil.GetPlatformName()
	if Platform == "Android" and nil == self.AndroidHandleCheckTimerID then
        self.AndroidHandleCheckTimerID = _G.TimerMgr:AddTimer(self, 
        self.TickAndroidHandleCheck, 3, 3, 0)
    end
end

function SettingsHandleMgr:TickAndroidHandleCheck()
    if SettingsUtils["SettingsTabHandle"].IsHandleAttached then
        local IsHandleAttached = _G.UE.USettingUtil.IsMajorGamepadAttached()
        self:IsStartHandleMode(IsHandleAttached)
    elseif self.AndroidHandleCheckTimerID then
        _G.TimerMgr:CancelTimer(self.AndroidHandleCheckTimerID)
        self.AndroidHandleCheckTimerID = nil
    end
end
-----------------------------------------------------------------

function SettingsHandleMgr:GetMajorController()
    local MajorController = MajorUtil.GetMajorController()
	if MajorController == nil then 
		local PlayerController = GameplayStaticsUtil.GetPlayerController()
	    MajorController = PlayerController:Cast(_G.UE.AMajorController)
	end
    return MajorController
end

function SettingsHandleMgr:UpdateByMajorProfSwitch()
    if SettingsUtils["SettingsTabHandle"]then
        SettingsUtils["SettingsTabHandle"]:UpdateByMajorProfSwitch()
    end
end

---Debug------------
---
function SettingsHandleMgr:GMSwitchGameMode(bHandleGameMode)
    if SettingsUtils["SettingsTabHandle"] then
        if bHandleGameMode and not SettingsUtils["SettingsTabHandle"]:GetHandleMode()then
            if not SettingsUtils["SettingsTabHandle"].IsHandleAttached then
                MsgTipsUtil.ShowTips(LSTR("110079"))
                return
            end
            SettingsUtils["SettingsTabHandle"]:SetHandleMode(SettingsHandleDefine.HandleModeType.On)
        elseif not bHandleGameMode and SettingsUtils["SettingsTabHandle"]:GetHandleMode()then
            SettingsUtils["SettingsTabHandle"]:SetHandleMode(SettingsHandleDefine.HandleModeType.Off)
        end
    end
end

return SettingsHandleMgr