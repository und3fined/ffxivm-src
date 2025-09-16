local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local PhotoCameraUtil = require("Game/Photo/Util/PhotoCameraUtil")
local PhotoDefine = require("Game/Photo/PhotoDefine")
local PhotoTemplateUtil = require("Game/Photo/Util/PhotoTemplateUtil")
local PhotoActorUtil = require("Game/Photo/Util/PhotoActorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local PhotoCamVM = LuaClass(UIViewModel)
local UITabSubCamera = PhotoDefine.UITabSub[PhotoDefine.UITabMain.Camera]
local LSTR = _G.LSTR
local PhotoVM

function PhotoCamVM:Ctor()
    self.DOFDisOff = 0
    self.DOFRegion = 50

    self.CurAngle = 0
    self.CurUnit = 50
    self.CurParamValue = 0
    self.UnitText = 0
    self.IsShowActiveArw = false

    self.OffX = 0
    self.OffY = 0

    self:MakeCameraComp()
end

function PhotoCamVM:MakeCameraComp()
    local VM = self
    self.CameraComp = {
        [UITabSubCamera.FOV] = {
            Value = 50,
            ParamValue = 0,
            OnValueChanged = function(self)
                local CurValue = PhotoDefine.CameraTurnplateUnitMax - self.Value
                self.ParamValue = PhotoDefine.CameraUnit2ValueFOVMin + CurValue * 
                                    PhotoDefine.CameraUnit2ValueFOVMax / PhotoDefine.CameraTurnplateUnitMax
                local P = 40 + self.ParamValue / 200 * 80
                PhotoCameraUtil.SetFOV(P)
            end,
        },

        [UITabSubCamera.DOF] = {
            Value = 50,
            ParamValue = 0,
            OnValueChanged = function(self)
                local CurValue = PhotoDefine.CameraTurnplateUnitMax - self.Value
                self.ParamValue = PhotoDefine.CameraUnit2ValueDOFMin + CurValue * 
                                    PhotoDefine.CameraUnit2ValueDOFMax / PhotoDefine.CameraTurnplateUnitMax
                local DOF = (self.ParamValue / PhotoDefine.CameraUnit2ValueDOFMax) * PhotoDefine.CameraDOFMax
                PhotoCameraUtil.SetDOFScale(DOF)
                _G.PhotoMgr:CheckAndSwitchDOFTimer(DOF)
            end,
        },

        [UITabSubCamera.Rot] = {
            Value = 50,
            ParamValue = 0,
            OnValueChanged = function(self)
                -- _G.FLOG_INFO('[Photo][PhotoCamVM][OnValueChanged-Rot] Value = ' .. tostring(self.Value))
                local CurValue = PhotoDefine.CameraTurnplateUnitMax - self.Value
                self.ParamValue = PhotoDefine.CameraUnit2ValueRotMin + CurValue * 
                                    (PhotoDefine.CameraUnit2ValueRotMax - PhotoDefine.CameraUnit2ValueRotMin) / (PhotoDefine.CameraTurnplateUnitMax)
                PhotoCameraUtil.SetRatateRoll(self.ParamValue)
            end,
        },
    }

    self.CameraComp.SetValue = function(self, Ty, Value)
        local Property = self[Ty]
        if Property then
            Property.Value = Value
            Property.OnValueChanged(Property)
        end
    end

    self.CameraComp.GetValue = function(self, Ty)
        local Property = self[Ty]
        if Property then
            return Property.Value
        end

        return 0
    end

    self.CameraComp.ResetValue = function(self)
        for _, Ty in pairs(UITabSubCamera) do
            self:SetValue(Ty, 50)
        end
    end

    self.CameraComp.GetParamValue = function(self, Ty)
        local Property = self[Ty]
        if Property then
            return Property.ParamValue
        end

        return 0
    end

    
end

function PhotoCamVM:OnInit()
    PhotoVM = _G.PhotoVM
end

function PhotoCamVM:OnBegin()
end

function PhotoCamVM:OnEnd()
end

function PhotoCamVM:OnShutdown()
end

function PhotoCamVM:UpdateVM()
    self:Reset2Default()
end

function PhotoCamVM:OnTimer()
end

function PhotoCamVM:Reset2Default()
    self.CameraComp:ResetValue()
    self.CurUnit = 50

    self:UpdCurAngle()
    self:UpdCameraParamValue()
    self:UpdIsShowActiveArw()
    self:SetOffXY(0, 0)
end

-------------------------------------------------------------------------------------------------------
---@region Set

--- Unit

function PhotoCamVM:ResetCurUnit()
    _G.FLOG_INFO('[Photo][PhotoCamVM][ResetCurUnit] Idx = ' .. tostring(Idx))
    local Idx = PhotoVM.SubTabIdx
    local CurUnit = self.CameraComp:GetValue(Idx)
    self:SetCurUnit(CurUnit)
end

function PhotoCamVM:AddUnit(DelUnit)
    local NextUnit = self.CurUnit + DelUnit
    self:SetCurUnit(NextUnit)
end

function PhotoCamVM:SetCurUnit(V, NoSync)
    self.CurUnit = math.clamp(V, PhotoDefine.CameraTurnplateUnitMin, PhotoDefine.CameraTurnplateUnitMax)
	-- _G.FLOG_INFO('Andre.PhotoCamVM:SetCurUnit Unit = ' .. tostring(self.CurUnit))
    if not NoSync then
        local Idx = PhotoVM.SubTabIdx
        self.CameraComp:SetValue(Idx, self.CurUnit)
    end

    self:UpdCurAngle()
    self:UpdCameraParamValue()
    self:UpdIsShowActiveArw()
end

function PhotoCamVM:UpdCurAngle()
    self.CurAngle = self.CurUnit * PhotoDefine.Unit2TurnplateAngle - PhotoDefine.CameraTurnplateAngle / 2
	-- _G.FLOG_INFO('Andre.PhotoCamVM:UpdCurAngle CurAngle = ' .. tostring(self.CurAngle))
end

function PhotoCamVM:UpdCameraParamValue()
    local Idx = PhotoVM.SubTabIdx
    self.CurParamValue = self.CameraComp:GetParamValue(Idx)
    self.UnitText = self.CurParamValue // 1
end

function PhotoCamVM:UpdIsShowActiveArw()
    self.IsShowActiveArw = self.CurUnit % 10 == 0
end

---@group CameraOffset
local LastShowTime = nil
local function ShowTips(Content)
    if LastShowTime then
        local Now = TimeUtil.GetLocalTime()
        if Now - LastShowTime <= 5 then
            return
        end
    end

    MsgTipsUtil.ShowTips(Content)
    LastShowTime = TimeUtil.GetLocalTime()
end

function PhotoCamVM:AddOffXY(AxisX, AxisY)
    local DelX = AxisX * PhotoDefine.CameraMoveStep
    local DelY = AxisY * PhotoDefine.CameraMoveStep

    -- check dir

    local Y = self.OffY
    local X = self.OffX

    local TypeY = DelY > 0 and 1 or 2
    local TypeX = DelX > 0 and 4 or 3

    if PhotoCameraUtil.SetOffsetTest(TypeY) then
        Y = self.OffY + DelY
    else
	    ShowTips(LSTR(630044))
    end

    if PhotoCameraUtil.SetOffsetTest(TypeX) then
        X = self.OffX + DelX
    else
	    ShowTips(LSTR(630044))
    end

    if X ~= self.OffX or Y ~= self.OffY then
        self:SetOffXY(X, Y)
    end
end

function PhotoCamVM:SetOffXY(X, Y)
    self.OffY = Y
    self.OffX = X

    _G.FLOG_INFO('PhotoCamVM debug OffX = ' .. tostring(self.OffX) .. " OffY = " .. tostring(self.OffY))
    PhotoCameraUtil.SetOffset(self.OffX, self.OffY)
end

function PhotoCamVM:GetTLogData()
    return 
    {
        FOV = self.CameraComp:GetParamValue(UITabSubCamera.FOV),
        DOF = self.CameraComp:GetParamValue(UITabSubCamera.DOF),
        Rot = self.CameraComp:GetParamValue(UITabSubCamera.Rot),
    }
end

-------------------------------------------------------------------------------------------------------
---@region template setting

function PhotoCamVM:TemplateSave(InTemplate)
    local FOV = self.CameraComp:GetValue(UITabSubCamera.FOV)
    local DOF = self.CameraComp:GetValue(UITabSubCamera.DOF)
    local Rot = self.CameraComp:GetValue(UITabSubCamera.Rot)

    local MajorRot = PhotoActorUtil.GetMajorRotator()
    local CamRot = PhotoCameraUtil.GetRatate()

    local RelaRat = {
        Yaw = CamRot.Yaw - MajorRot.Yaw - 180,
        Pitch = CamRot.Pitch - MajorRot.Pitch,
    }

    PhotoTemplateUtil.SetCam(InTemplate, FOV, DOF, Rot, self.OffX, self.OffY, RelaRat)
end

function PhotoCamVM:TemplateApply(InTemplate)
    local Info = PhotoTemplateUtil.GetCam(InTemplate)
    -- _G.FLOG_INFO('[Photo][PhotoCamVM][TemplateApply] Info = ' .. table.tostring(Info))
    if Info then
        self:SetOffXY(Info.OffX, Info.OffY)
        self.CameraComp:SetValue(UITabSubCamera.FOV, Info.FOV or 0)
        self.CameraComp:SetValue(UITabSubCamera.DOF, Info.DOF or 0)
        self.CameraComp:SetValue(UITabSubCamera.Rot, 50)
        -- self.CameraComp:SetValue(UITabSubCamera.Rot, 50)

        self:ResetCurUnit()
        local RelaRot = Info.RelaRot
        -- RelaRat = {
        --     Yaw = -20,
        --     Pitch = 0,
        -- }

        if RelaRot then
            local MajorRot = PhotoActorUtil.GetMajorRotator()
            local CamRot = PhotoCameraUtil.GetRatate()
            CamRot.Yaw = MajorRot.Yaw + RelaRot.Yaw + 180
            CamRot.Pitch = MajorRot.Pitch + RelaRot.Pitch
            PhotoCameraUtil.SetRatate(CamRot)
        end
    end
end

return PhotoCamVM