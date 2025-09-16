

-- local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")
local Util = {}
local CameraMgr = _G.UE.UCameraMgr
-- local MCamCtr = nil

-- 相机是动态的，不能缓存
function Util.GetCam()
    return Util.GetCamCtr():GetTopDownCameraComponent()
end

function Util.GetCamCtr()
    -- if MCamCtr then
    --     return MCamCtr
    -- end
    local Major = MajorUtil.GetMajor()
    local MCamCtr = Major:GetCameraControllComponent()
    return MCamCtr
end

function Util.GetCamMgr()
    return CameraMgr.Get()
end

-- 景深

function Util.SetDOFScale(Scale)
    local Cam = Util.GetCam()

    if Cam then
        local PostProcessSettings = Cam.PostProcessSettings
        if Scale > 0 then
            PostProcessSettings.bOverride_DepthOfFieldScale             = true
            PostProcessSettings.DepthOfFieldScale                       = Scale
            PostProcessSettings.MobileBokehDOFScale                     = 0
            PostProcessSettings.bOverride_MobileBokehDOFScale           = true
            PostProcessSettings.DepthOfFieldFstop                       = 4.3-Scale
            PostProcessSettings.bOverride_DepthOfFieldFstop             = true
            PostProcessSettings.bMobileDiaphragmDOF                     = true
            PostProcessSettings.bOverride_MobileDiaphragmDOF            = true
        else
            PostProcessSettings.bOverride_DepthOfFieldScale             = false
            PostProcessSettings.bOverride_MobileBokehDOFScale           = false
            PostProcessSettings.bOverride_DepthOfFieldFocalRegion       = false
            PostProcessSettings.bOverride_MobileDiaphragmDOF            = false
        end

        _G.FLOG_INFO(string.format('[Photo][PhotoCameraUtil][SetDOFScale] DepthOfFieldScale = %s ', 
            PostProcessSettings.DepthOfFieldScale
        ))
    end
end

function Util.SetDOFRegionAndDis(Dis, Region)
    local Cam = Util.GetCam()

    if Cam then
        local PostProcessSettings = Cam.PostProcessSettings;
        PostProcessSettings.bOverride_DepthOfFieldFocalRegion       = true
        PostProcessSettings.DepthOfFieldFocalRegion                 = Region
        PostProcessSettings.bOverride_DepthOfFieldFocalDistance     = true
        PostProcessSettings.DepthOfFieldFocalDistance               = Dis

        _G.FLOG_INFO(string.format('[Photo][PhotoCameraUtil][SetDOFBokeh] DepthOfFieldFocalDistance = %s, DepthOfFieldFocalRegion = %s ', 
            PostProcessSettings.DepthOfFieldFocalDistance,
            PostProcessSettings.DepthOfFieldFocalRegion
        ))

    end
end

function Util.BeginCameraEnv()
    local CamMgr = Util.GetCamMgr()
    CamMgr:SwitchVirtual(true)
    Util.GetCamCtr():SetDOFUpdateEnabled(false)
    Util.GetCamCtr():SwitchRoll(true)
end

function Util.EndCameraEnv()
    local CamMgr = Util.GetCamMgr()
    CamMgr:SwitchVirtual(false)
    Util.GetCamCtr():SetDOFUpdateEnabled(true)
    Util.GetCamCtr():SwitchRoll(false)
end

-- 散景系数（景深）220cm距离以内才会开启，引擎那边的限制
function Util.SetDOFBokehNotVirtual(Val)
    local CamMgr = Util.GetCamMgr()
    CamMgr:SwitchVirtual(false)
    local Cam = Util.GetCam()
    Cam.PostProcessSettings.MobileBokehDOFScale = Val
end

function Util.GetDOFBokeh()
    local Cam = Util.GetCam()
    return Cam.PostProcessSettings.MobileBokehDOFScale
end

-- 对焦
function Util.SetDOFFocalDist(Val)
    local CamCtr = Util.GetCamCtr()
    CamCtr:SetATPCCameraFOV(Val)
end

-- FOV
function Util.SetFOV(V)
    Util.GetCamCtr():SetATPCCameraFOV(V)
end

function Util.GetFOV()
    return Util.GetCamCtr():GetATPCCameraFOV(V)
end

-- 旋转
--- @param Vec _G.UE.FRotator(Pitch, Yaw, Roll)
function Util.SetRatate(Rot)
    Util.GetCamCtr():SetCameraBoomRelativeRotation(Rot)
end

function Util.GetRatate()
    return Util.GetCamCtr():GetCameraBoomRelativeRotation()
end

---@param Type number up/down/left/right
function Util.SetOffsetTest(Type)
    local Y = 0
    local Z = 0
    local X = 0

    if Type == 1 then
        Z = 1
    elseif Type == 2 then
        Z = -1
    elseif Type == 3 then
        Y = -1
    elseif Type == 4 then
        Y = 1
    end

    local Vec = _G.UE.FVector(Y, X, Z)
    
    return Util.GetCamCtr():CheckCanTranslate(Vec)
end

function Util.SetOffset(X, Y)
    local Vec = Util.GetCamCtr():GetSocketTargetOffset()
    Vec.Y = X
    Vec.Z = Y
    Util.GetCamCtr():SetSocketTargetOffset(Vec)
end

function Util.SetOffsetVec(Vec)
    Util.GetCamCtr():SetSocketTargetOffset(Vec)
end

function Util.GetOffset()
    return Util.GetCamCtr():GetSocketTargetOffset()
end

function Util.SetRatateRoll(Roll)
    local CamCtr = Util.GetCamCtr()
    local R = CamCtr:GetCameraBoomRelativeRotation()
    R.Roll = Roll
    Util.GetCamCtr():SetCameraBoomRelativeRotation(R)
end

function Util.GetRatateRoll()
    local CamCtr = Util.GetCamCtr()
    local R = CamCtr:GetCameraBoomRelativeRotation()
    return R.Roll
end

-- -- 光圈系数
-- function Util.SetSOF(V)
    
-- end

return Util