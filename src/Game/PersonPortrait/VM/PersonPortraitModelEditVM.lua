---
--- Author: xingcaicao
--- DateTime: 2024-01-04 10:17
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local Json = require("Core/Json")
local PersonPortraitUtil = require("Game/PersonPortrait/PersonPortraitUtil")

---@class PersonPortraitModelEditVM : UIViewModel
local PersonPortraitModelEditVM = LuaClass(UIViewModel)

---Ctor
function PersonPortraitModelEditVM:Ctor( )
    self:Reset()
end

function PersonPortraitModelEditVM:Reset()
    self.MoveResetBtnVisible = false

    self.IsHideWeapon           = PersonPortraitUtil.GetDefaultIsHideWeapon() -- 隐藏武器
    self.IsHideHat              = PersonPortraitUtil.GetDefaultIsHideHat() -- 隐藏帽子
    self.IsFace                 = PersonPortraitUtil.GetDefaultIsFace() -- 面向镜头
    self.IsLook                 = PersonPortraitUtil.GetDefaultIsLook() -- 看向镜头
    self.Distance               = PersonPortraitUtil.GetDefaultDistance()
    self.FOV                    = PersonPortraitUtil.GetDefaultFOV()
    self.Roll                   = PersonPortraitUtil.GetDefaultRoll() 
    self.Rotate                 = PersonPortraitUtil.GetDefaultRotate() 
    self.Pitch                  = PersonPortraitUtil.GetDefaultPitch() 
    self.ActionPostion          = PersonPortraitUtil.GetDefaultActionPosition() -- 动作位置
    self.Move                   = PersonPortraitUtil.GetDefaultMove()   -- 移动数据(x,y,z)
    self.AmbientLightIntensity  = PersonPortraitUtil.GetDefaultAmbientLightIntensity() 
    self.AmbientLightColor      = PersonPortraitUtil.GetDefaultAmbientLightColor() 
    self.DirectLightIntensity   = PersonPortraitUtil.GetDefaultDirectLightIntensity() 
    self.DirectLightColor       = PersonPortraitUtil.GetDefaultDirectLightColor() 
    self.DirectLightDir         = PersonPortraitUtil.GetDefaultDirectLightDir() 
end

---@param Value table
function PersonPortraitModelEditVM:IsNotEqual(Value)
    local IsHideWeapon = Value.IsHideWeapon
    if self.IsHideWeapon ~= IsHideWeapon and IsHideWeapon ~= nil then
        return true
    end

    local IsHideHat = Value.IsHideHat
    if self.IsHideHat ~= IsHideHat and IsHideHat ~= nil then
        return true
    end

    local IsFace = Value.IsFace
    if self.IsFace ~= IsFace and IsFace ~= nil then
        return true
    end

    local IsLook = Value.IsLook
    if self.IsLook ~= IsLook and IsLook ~= nil then
        return true
    end

    local Distance = self.Distance
    if Distance ~= Value.Distance and Distance ~= PersonPortraitUtil.GetDefaultDistance() then
        return true
    end

    local FOV = self.FOV
    if FOV ~= Value.FOV and FOV ~= PersonPortraitUtil.GetDefaultFOV() then
        return true
    end

    local Roll = self.Roll
    if Roll ~= Value.Roll and Roll ~= PersonPortraitUtil.GetDefaultRoll() then
        return true
    end

    local Rotate = self.Rotate
    if Rotate ~= Value.Rotate and Rotate ~= PersonPortraitUtil.GetDefaultRotate() then
        return true
    end

    local Pitch = self.Pitch
    if Pitch ~= Value.Pitch and Pitch ~= PersonPortraitUtil.GetDefaultPitch() then
        return true
    end

    local Pos = self.ActionPostion
    if Pos ~= Value.ActionPostion and Pos ~= PersonPortraitUtil.GetDefaultActionPosition() then
        return true
    end

    local AmbIntensity = self.AmbientLightIntensity
    if AmbIntensity ~= Value.AmbientLightIntensity and AmbIntensity ~= PersonPortraitUtil.GetDefaultAmbientLightIntensity() then
        return true
    end

    local DirIntensity = self.DirectLightIntensity
    if DirIntensity ~= Value.DirectLightIntensity and DirIntensity ~= PersonPortraitUtil.GetDefaultDirectLightIntensity() then
        return true
    end

    local tValue = Value.Move or PersonPortraitUtil.GetDefaultMove()
    if not table.compare_table(self.Move or {}, tValue) then
        return true
    end

    tValue = Value.AmbientLightColor or PersonPortraitUtil.GetDefaultAmbientLightColor()
    if not table.compare_table(self.AmbientLightColor or {}, tValue) then
        return true
    end

    tValue = Value.DirectLightColor or PersonPortraitUtil.GetDefaultDirectLightColor()
    if not table.compare_table(self.DirectLightColor or {}, tValue) then
        return true
    end

    tValue = Value.DirectLightDir or PersonPortraitUtil.GetDefaultDirectLightDir()
    if not table.compare_table(self.DirectLightDir or {}, tValue) then
        return true
    end

    return false
end

---@param Value table @服务器保存的模型编辑数据
function PersonPortraitModelEditVM:UpdateVM(Value)
    self.MoveResetBtnVisible = false

    self.IsHideWeapon = Value.IsHideWeapon or PersonPortraitUtil.GetDefaultIsHideWeapon()
    self.IsHideHat   = Value.IsHideHat or PersonPortraitUtil.GetDefaultIsHideHat()
    self.IsFace      = Value.IsFace or PersonPortraitUtil.GetDefaultIsFace() 
    self.IsLook      = Value.IsLook or PersonPortraitUtil.GetDefaultIsLook() 
    self.Distance    = Value.Distance or PersonPortraitUtil.GetDefaultDistance()
    self.FOV         = Value.FOV or PersonPortraitUtil.GetDefaultFOV()
    self.Roll        = Value.Roll or PersonPortraitUtil.GetDefaultRoll() 
    self.Rotate      = Value.Rotate or PersonPortraitUtil.GetDefaultRotate() 
    self.Pitch       = Value.Pitch or PersonPortraitUtil.GetDefaultPitch() 
    self.Move        = Value.Move or PersonPortraitUtil.GetDefaultMove()

    self.ActionPostion          = Value.ActionPostion or PersonPortraitUtil.GetDefaultActionPosition() -- 动作位置
    self.AmbientLightIntensity  = Value.AmbientLightIntensity or PersonPortraitUtil.GetDefaultAmbientLightIntensity() 
    self.DirectLightIntensity   = Value.DirectLightIntensity or PersonPortraitUtil.GetDefaultDirectLightIntensity() 

    local tValue = Value.AmbientLightColor
    self.AmbientLightColor = (tValue and #tValue == 3) and tValue or PersonPortraitUtil.GetDefaultAmbientLightColor()

    tValue = Value.DirectLightColor
    self.DirectLightColor = (tValue and #tValue == 3) and tValue or PersonPortraitUtil.GetDefaultDirectLightColor()

    tValue = Value.DirectLightDir
    self.DirectLightDir = (tValue and #tValue == 2) and tValue or PersonPortraitUtil.GetDefaultDirectLightDir()
end

function PersonPortraitModelEditVM:GetDataJsonStr( )
    local Data = {
        IsHideWeapon = self.IsHideWeapon,
        IsHideHat   = self.IsHideHat,
        IsFace      = self.IsFace,
        IsLook      = self.IsLook,
        Distance    = self.Distance,
        FOV         = self.FOV,
        Roll        = self.Roll,
        Rotate      = self.Rotate,
        Pitch       = self.Pitch,
        Move        = self.Move,

        ActionPostion           = self.ActionPostion,
        AmbientLightIntensity   = self.AmbientLightIntensity,
        DirectLightIntensity    = self.DirectLightIntensity, 
        AmbientLightColor       = self.AmbientLightColor,
        DirectLightColor        = self.DirectLightColor,
        DirectLightDir          = self.DirectLightDir,
    }

    return Json.encode(Data)
end

function PersonPortraitModelEditVM:SetIsHideWeapon(Value)
    self.IsHideWeapon = Value
end

function PersonPortraitModelEditVM:SetIsHideHat(Value)
    self.IsHideHat = Value
end

function PersonPortraitModelEditVM:SetDistance(Distance)
    self.Distance = Distance 
end

function PersonPortraitModelEditVM:SetFOV(Value)
    self.FOV = Value
end

function PersonPortraitModelEditVM:SetIsFace(Value)
    self.IsFace = Value
end

function PersonPortraitModelEditVM:SetIsLook(Value)
    self.IsLook = Value
end

function PersonPortraitModelEditVM:SetRotate(Value)
    self.Rotate = Value
end

function PersonPortraitModelEditVM:SetPitch(Value)
    self.Pitch = Value
end

function PersonPortraitModelEditVM:SetRoll(Value)
    self.Roll = Value 
end

function PersonPortraitModelEditVM:SetActionPosition(Value)
    self.ActionPostion = Value or PersonPortraitUtil.GetDefaultActionPosition()
end

function PersonPortraitModelEditVM:SetMove(X, Y, Z)
    if X and Y and Z then
        self.Move = {X, Y, Z}
    end
end

function PersonPortraitModelEditVM:SetAmbientLightIntensity(Value)
    self.AmbientLightIntensity = Value 
end

function PersonPortraitModelEditVM:SetAmbientLightColor(R, G, B)
    if R and G and B then
        self.AmbientLightColor = {R, G, B} 
    end
end

function PersonPortraitModelEditVM:SetDirectLightIntensity(Value)
    self.DirectLightIntensity = Value 
end

function PersonPortraitModelEditVM:SetDirectLightColor(R, G, B)
    if R and G and B then
        self.DirectLightColor = {R, G, B} 
    end
end

function PersonPortraitModelEditVM:SetDirectLightDir(X, Y)
    if X and Y then
        self.DirectLightDir = {X, Y}
    end
end

function PersonPortraitModelEditVM:SetMoveResetBtnVisible(b)
    self.MoveResetBtnVisible = b 
end

return PersonPortraitModelEditVM