--
-- Author: sammrli
-- Date: 2024-3-18
-- Description:模型相机base
-- 通用性功能在此类拓展,特殊性功能建议继承该类拓展

local LuaClass = require("Core/LuaClass")
local UILevelMgr = require("Game/Common/Render2D/Level/UILevelMgr")

local UE = _G.UE

---@class ModelCameraController
---@field CameraActor UE.Actor
---@field SpringArmComponent UE.USpringArmComponent
local ModelCameraController = LuaClass()

function ModelCameraController:Ctor()
    self.CameraActor = nil
    self.CameraComponent = nil
    self.SpringArmComponent = nil

    self.Location = UE.FVector(0, 0, 0)
    self.Rotation = UE.FRotator(0, 0, 0)

    self.FocusPoint = nil

    self.bEnableZoom = true
    self.bEnableRotator = true
    self.bEnableMove = false
end


-- ==================================================
-- 内部函数
-- ==================================================

function ModelCameraController:__SetInterp(SpringArmComponent, bInterp)
    if bInterp then
        SpringArmComponent.bEnableCameraLag = true
        SpringArmComponent.CameraLagSpeed = 10
    else
        SpringArmComponent.bEnableCameraLag = false
    end
end

function ModelCameraController:__UpdateFocus()
    if self.CallbackGetFocus then
        return self.CallbackGetFocus()
    end
end

-- ==================================================
-- 外部初始化接口
-- ==================================================

---创建相机
function ModelCameraController:Create()
end

---绑定相机Actor(挂载CameraComponent的Actor)
---@param CameraActor UE.Actor
function ModelCameraController:BindCameraActor(CameraActor)
    self.CameraActor = CameraActor
    self.CameraComponent = self.CameraActor:GetComponentByClass(UE.UCameraComponent)
    self.SpringArmComponent = self.CameraActor:GetComponentByClass(UE.USpringArmComponent)
end

---绑定CommGestureView
---@param UIView CommGestureView
function ModelCameraController:BindCommGesture(UIView)
    UIView:SetOnClickedCallback(function(ScreenPosition) self:OnClickedHandle(ScreenPosition) end)
    UIView:SetOnScaleChangedCallback(function(Scale) self:OnZoomHandle(Scale) end)
    UIView:SetOnPositionChangedCallback(function(X, Y) self:OnDragHandle(X, Y) end)
end

---绑定获取焦点回调
---@param Func funtion<UE.FVector>
function ModelCameraController:BindGetFocusCallback(Func)
    self.CallbackGetFocus = Func
end

---切换相机
---@param bEnable boolean
function ModelCameraController:Switch(bEnable)
    if bEnable then
        local CameraMgr = UE.UCameraMgr.Get()
        if CameraMgr ~= nil then
            -- 禁用关卡流送，避免主视角切换导致子关卡被卸载
            UILevelMgr:SwitchLevelStreaming(false)
            if self.CameraActor then
                CameraMgr:SwitchCamera(self.CameraActor, 0)
            end
        end
    else
        local CameraMgr = UE.UCameraMgr.Get()
        if CameraMgr ~= nil then
            CameraMgr:ResumeCamera(0, true, self.CameraActor)
			-- 恢复关卡流送
			UILevelMgr:SwitchLevelStreaming(true)
        end
    end
end

---设置相机焦点
---@param Point UE.FVector
function ModelCameraController:SetFocusPoint(Point)
    self.FocusPoint = {X=Point.x, Y=Point.y, Z=Point.z}
end

function ModelCameraController:EnableZoom(bEnable)
    self.bEnableZoom = bEnable
end

function ModelCameraController:EnableRotator(bEnable)
    self.bEnableRotator = bEnable
end

function ModelCameraController:EnableMove(bEnable)
    self.bEnableMove = bEnable
end

-- ==================================================
-- 设置相机参数
-- ==================================================


---设置相机FOV
function ModelCameraController:SetCameraFOV(InFOV, bInterp, InterpVelocity)
    if InFOV == nil then
        return
    end

    local CameraMgr = UE.UCameraMgr.Get()
    if CameraMgr ~= nil then
        CameraMgr:SetCurrentPlayerManagerLockedFOV(InFOV)
    end
end

function ModelCameraController:GetFOV()
    local CameraMgr = _G.UE.UCameraMgr.Get()
    if CameraMgr ~= nil then
        return CameraMgr:GetCurrentPlayerManagerLockedFOV()
    end

    return nil
end

function ModelCameraController:GetSpringArmComponent()
    return self.SpringArmComponent
end

---获取弹簧臂距离
function ModelCameraController:GetSpringArmCompArmLength()
    if self.SpringArmComponent then
        return self.SpringArmComponent.TargetArmLength
    end
    return 0
end

---设置弹簧臂距离
---@param ArmLength number
function ModelCameraController:SetSpringArmCompArmLength(ArmLength, bInterp)
    local SpringArmComponent = self.SpringArmComponent
    if SpringArmComponent then
        self:__SetInterp(SpringArmComponent, bInterp)
        SpringArmComponent.TargetArmLength = ArmLength
    end
end

---设置位置
---@param TargetLocation UE.FVector
function ModelCameraController:SetSpringArmLocation(TargetLocation, bInterp)
    local SpringArmComponent = self.SpringArmComponent
    if SpringArmComponent then
        self:__SetInterp(SpringArmComponent, bInterp)
        SpringArmComponent:K2_SetRelativeLocation(TargetLocation, false, nil, false)
    end
end

---设置旋转
---@param TargetRotator UE.FRotator
function ModelCameraController:SetSpringArmRotation(TargetRotator, bInterp)
    local SpringArmComponent = self.SpringArmComponent
    if SpringArmComponent then
        self:__SetInterp(SpringArmComponent, bInterp)
        SpringArmComponent:K2_SetRelativeRotation(TargetRotator, false, nil, false)
    end
end

---设置Roll
function ModelCameraController:SetRoll(Val)
    if self.CameraComponent then
        self.CameraComponent:K2_SetRelativeRotation(UE.FRotator(0, 0, Val), false, nil, false)
    end
end

function ModelCameraController:GetSpringArmLocation()
    if self.SpringArmComponent ~= nil then
        return self.SpringArmComponent:GetRelativeLocation()
    end
    return _G.UE.FVector(0, 0, 0);
end

function ModelCameraController:GetSpringArmRotation()
    if self.SpringArmComponent ~= nil then
        return self.SpringArmComponent:GetRelativeRotation()
    end
    return _G.UE.FRotator(0, 0, 0);
end

-- ==================================================
-- 手势事件回调
-- ==================================================

function ModelCameraController:OnZoomHandle(Scale)
    if self.bEnableZoom then
        self:SetSpringArmCompArmLength(700 - Scale.X * 300)
    end
end

function ModelCameraController:OnDragHandle(X, Y)
    if self.bEnableRotator then
        self.Rotation.Yaw = X
        self:SetSpringArmRotation(self.Rotation)
    end
    if self.bEnableMove then
        self.Location.y = X
        self.Location.z = Y
        self:SetSpringArmLocation(self.Location)
    end
end

function ModelCameraController:OnClickedHandle(ScreenPosition)
end

function ModelCameraController:GetCameraActor()
    return self.CameraComponent
end

return ModelCameraController