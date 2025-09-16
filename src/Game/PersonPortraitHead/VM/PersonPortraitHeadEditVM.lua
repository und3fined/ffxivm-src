---
--- Author: xingcaicao
--- DateTime: 2024-01-04 10:17
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local Json = require("Core/Json")
local PersonPortraitHeadUtil = require("Game/PersonPortraitHead/PersonPortraitHeadUtil")

---@class PersonPortraitHeadEditVM : UIViewModel
local PersonPortraitHeadEditVM = LuaClass(UIViewModel)

---Ctor
function PersonPortraitHeadEditVM:Ctor( )
    self:Reset()
end

function PersonPortraitHeadEditVM:Reset()
    self.bIsShowWeapon = true
    self.bIsHoldWeapon = false
    self.bIsShowHead = false

    self.IsFace                 = PersonPortraitHeadUtil.GetDefaultIsFace() -- 面向镜头
    self.IsLook                 = PersonPortraitHeadUtil.GetDefaultIsLook() -- 看向镜头
    self.Distance               = PersonPortraitHeadUtil.GetDefaultDistance()
    self.FOV                    = PersonPortraitHeadUtil.GetDefaultFOV()
    self.Roll                   = PersonPortraitHeadUtil.GetDefaultRoll() 
    self.Rotate                 = PersonPortraitHeadUtil.GetDefaultRotate() 
    self.ActionPostion          = PersonPortraitHeadUtil.GetDefaultActionPosition() -- 动作位置
    self.EmotionPostion         = PersonPortraitHeadUtil.GetDefaultEmotionPosition() -- 表情位置
    self.Move                   = PersonPortraitHeadUtil.GetDefaultMove()   -- 移动数据(x,y,z)
    self.AmbientLightIntensity  = PersonPortraitHeadUtil.GetDefaultAmbientLightIntensity() 
    self.AmbientLightColor      = PersonPortraitHeadUtil.GetDefaultAmbientLightColor() 
    self.DirectLightIntensity   = PersonPortraitHeadUtil.GetDefaultDirectLightIntensity() 
    self.DirectLightColor       = PersonPortraitHeadUtil.GetDefaultDirectLightColor() 
    self.DirectLightDir         = PersonPortraitHeadUtil.GetDefaultDirectLightDir() 
end

---@param Value table
function PersonPortraitHeadEditVM:IsNotEqual(Value)
    local bIsShowWeapon = Value.bIsShowWeapon
    if self.bIsShowWeapon ~= bIsShowWeapon and bIsShowWeapon ~= nil then
        return true
    end

    local bIsHoldWeapon = Value.bIsHoldWeapon
    if self.bIsHoldWeapon ~= bIsHoldWeapon and bIsHoldWeapon ~= nil then
        return true
    end

    local bIsShowHead = Value.bIsShowHead
    if self.bIsShowHead ~= bIsShowHead and bIsShowHead ~= nil then
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
    if Distance ~= Value.Distance and Distance ~= PersonPortraitHeadUtil.GetDefaultDistance() then
        return true
    end

    local FOV = self.FOV
    if FOV ~= Value.FOV and FOV ~= PersonPortraitHeadUtil.GetDefaultFOV() then
        return true
    end

    local Roll = self.Roll
    if Roll ~= Value.Roll and Roll ~= PersonPortraitHeadUtil.GetDefaultRoll() then
        return true
    end

    local Rotate = self.Rotate
    if Rotate ~= Value.Rotate and Rotate ~= PersonPortraitHeadUtil.GetDefaultRotate() then
        return true
    end

    local Pos = self.ActionPostion
    if Pos ~= Value.ActionPostion and Pos ~= PersonPortraitHeadUtil.GetDefaultActionPosition() then
        return true
    end

    Pos = self.EmotionPostion
    if Pos ~= Value.EmotionPostion and Pos ~= PersonPortraitHeadUtil.GetDefaultEmotionPosition() then
        return true
    end

    local AmbIntensity = self.AmbientLightIntensity
    if AmbIntensity ~= Value.AmbientLightIntensity and AmbIntensity ~= PersonPortraitHeadUtil.GetDefaultAmbientLightIntensity() then
        return true
    end

    local DirIntensity = self.DirectLightIntensity
    if DirIntensity ~= Value.DirectLightIntensity and DirIntensity ~= PersonPortraitHeadUtil.GetDefaultDirectLightIntensity() then
        return true
    end

    local tValue = Value.Move or PersonPortraitHeadUtil.GetDefaultMove()
    if not table.compare_table(self.Move or {}, tValue) then
        return true
    end

    tValue = Value.AmbientLightColor or PersonPortraitHeadUtil.GetDefaultAmbientLightColor()
    if not table.compare_table(self.AmbientLightColor or {}, tValue) then
        return true
    end

    tValue = Value.DirectLightColor or PersonPortraitHeadUtil.GetDefaultDirectLightColor()
    if not table.compare_table(self.DirectLightColor or {}, tValue) then
        return true
    end

    tValue = Value.DirectLightDir or PersonPortraitHeadUtil.GetDefaultDirectLightDir()
    if not table.compare_table(self.DirectLightDir or {}, tValue) then
        return true
    end

    return false
end

---@param Value table @服务器保存的模型编辑数据
function PersonPortraitHeadEditVM:UpdateVM(Value)
    self.IsFace      = Value.IsFace or PersonPortraitHeadUtil.GetDefaultIsFace() 
    self.IsLook      = Value.IsLook or PersonPortraitHeadUtil.GetDefaultIsLook() 
    self.Distance    = Value.Distance or PersonPortraitHeadUtil.GetDefaultDistance()
    self.FOV         = Value.FOV or PersonPortraitHeadUtil.GetDefaultFOV()
    self.Roll        = Value.Roll or PersonPortraitHeadUtil.GetDefaultRoll() 
    self.Rotate      = Value.Rotate or PersonPortraitHeadUtil.GetDefaultRotate() 
    self.Move        = Value.Move or PersonPortraitHeadUtil.GetDefaultMove()

    self.bIsShowWeapon = Value.bIsShowWeapon == true
    self.bIsHoldWeapon = Value.bIsHoldWeapon or false
    self.bIsShowHead = Value.bIsShowHead or false

    self.ActionPostion          = Value.ActionPostion or PersonPortraitHeadUtil.GetDefaultActionPosition() -- 动作位置
    self.EmotionPostion         = Value.EmotionPostion or PersonPortraitHeadUtil.GetDefaultEmotionPosition() -- 表情位置
    self.AmbientLightIntensity  = Value.AmbientLightIntensity or PersonPortraitHeadUtil.GetDefaultAmbientLightIntensity() 
    self.DirectLightIntensity   = Value.DirectLightIntensity or PersonPortraitHeadUtil.GetDefaultDirectLightIntensity() 

    local tValue = Value.AmbientLightColor
    self.AmbientLightColor = (tValue and #tValue == 3) and tValue or PersonPortraitHeadUtil.GetDefaultAmbientLightColor()

    tValue = Value.DirectLightColor
    self.DirectLightColor = (tValue and #tValue == 3) and tValue or PersonPortraitHeadUtil.GetDefaultDirectLightColor()

    tValue = Value.DirectLightDir
    self.DirectLightDir = (tValue and #tValue == 2) and tValue or PersonPortraitHeadUtil.GetDefaultDirectLightDir()
end

function PersonPortraitHeadEditVM:GetDataJsonStr( )
    local Data = {
        IsFace      = self.IsFace,
        IsLook      = self.IsLook,
        Distance    = self.Distance,
        FOV         = self.FOV,
        Roll        = self.Roll,
        Rotate      = self.Rotate,
        Move        = self.Move,

        ActionPostion           = self.ActionPostion,
        EmotionPostion          = self.EmotionPostion,
        AmbientLightIntensity   = self.AmbientLightIntensity,
        DirectLightIntensity    = self.DirectLightIntensity, 
        AmbientLightColor       = self.AmbientLightColor,
        DirectLightColor        = self.DirectLightColor,
        DirectLightDir          = self.DirectLightDir,

        bIsShowWeapon = self.bIsShowWeapon,
        bIsHoldWeapon = self.bIsHoldWeapon,
        bIsShowHead = self.bIsShowHead,
    }

    return Json.encode(Data)
end

function PersonPortraitHeadEditVM:SetDistance(Distance)
    self.Distance = Distance 
end

function PersonPortraitHeadEditVM:SetFOV(Value)
    self.FOV = Value
end

function PersonPortraitHeadEditVM:SetIsFace(Value)
    self.IsFace = Value
end

function PersonPortraitHeadEditVM:SetIsLook(Value)
    self.IsLook = Value
end

function PersonPortraitHeadEditVM:SetRotate(Value)
    self.Rotate = Value
end

function PersonPortraitHeadEditVM:SetRoll(Value)
    self.Roll = Value 
end

function PersonPortraitHeadEditVM:SetActionPosition(Value)
    self.ActionPostion = Value or PersonPortraitHeadUtil.GetDefaultActionPosition()
end

function PersonPortraitHeadEditVM:SetEmotionPosition(Value)
    self.EmotionPostion = Value or PersonPortraitHeadUtil.GetDefaultEmotionPosition()
end

function PersonPortraitHeadEditVM:SetMove(X, Y, Z)
    if X and Y and Z then
        self.Move = {X, Y, Z}
    end
end

function PersonPortraitHeadEditVM:SetAmbientLightIntensity(Value)
    self.AmbientLightIntensity = Value 
end

function PersonPortraitHeadEditVM:SetAmbientLightColor(R, G, B)
    if R and G and B then
        self.AmbientLightColor = {R, G, B} 
    end
end

function PersonPortraitHeadEditVM:SetDirectLightIntensity(Value)
    self.DirectLightIntensity = Value 
end

function PersonPortraitHeadEditVM:SetDirectLightColor(R, G, B)
    if R and G and B then
        self.DirectLightColor = {R, G, B} 
    end
end

function PersonPortraitHeadEditVM:SetDirectLightDir(X, Y)
    if X and Y then
        self.DirectLightDir = {X, Y}
    end
end

return PersonPortraitHeadEditVM