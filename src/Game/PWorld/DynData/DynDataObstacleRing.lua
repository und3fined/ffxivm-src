--
-- Author: haialexzhou
-- Date: 2021-9-16
-- Description:动态阻挡
-- 以前用于出生点阻挡，现在改用动态物件了
local LuaClass = require("Core/LuaClass")
local DynDataObstacle = require("Game/PWorld/DynData/DynDataObstacle")
---@class DynDataObstacle
local DynDataObstacleRing = LuaClass(DynDataObstacle, true)

function DynDataObstacleRing:Ctor()
    self.OuterRadius = 0
    self.InnerRadius = 0
    self.Height = 0
    --self.EffectPath = "ParticleSystem'/Game/Assets/Effect/Particles/Sence/Common/PS_Born01_loop.PS_Born01_loop'"
    --self.DisappearEffectPath = "ParticleSystem'/Game/Assets/Effect/Particles/Sence/Common/PS_Born01_loop1.PS_Born01_loop1'"

    self.EffectPath = "Blueprint'/Game/Assets/Effect/Particles/Sence/Common/BP_Born01_loop.BP_Born01_loop_C'"
    self.DisappearEffectPath = "Blueprint'/Game/Assets/Effect/Particles/Sence/Common/BP_Born01_loop1.BP_Born01_loop1_C'"

    self.ModelPath = "Blueprint'/Game/BluePrint/PWorld/BP_DynObstacle_Ring.BP_DynObstacle_Ring_C'"
    self.ModelBaseSize = _G.UE.FVector(100, 100, 100)
    self.EffectBaseSize = 230
    
end

function DynDataObstacleRing:PlayObstacleEffect(EffectPath, IsDisappear)
    if (not self.bIsHideEffect and EffectPath ~= nil and EffectPath ~= "") then
        local CircleScale = self.InnerRadius / (self.EffectBaseSize / 2) --
        local Translation = self.Location
        local Rotation = _G.UE.FQuat()
        if (self.Rotator ~= nil) then
            Rotation = self.Rotator:ToQuat()
        end
        local Scale3D = _G.UE.FVector(CircleScale, CircleScale, CircleScale)
        local VfxParameter = _G.UE.FVfxParameter()
        VfxParameter.VfxRequireData.EffectPath = _G.CommonUtil.ParseBPPath(EffectPath)
        VfxParameter.VfxRequireData.VfxTransform = _G.UE.FTransform(Rotation, Translation, Scale3D)

        if (IsDisappear) then
            self.DisappearEffectInstID = self.Super:PlayEffect(VfxParameter)
            --print("PlayObstacleEffect self.DisappearEffectInstID=" .. tostring(self.DisappearEffectInstID))
        else
            self.EffectInstID = self.Super:PlayEffect(VfxParameter)
            --print("PlayObstacleEffect self.EffectInstID=" .. tostring(self.EffectInstID))
        end
    end
end

function DynDataObstacleRing:Show()
    --print("PlayObstacleEffect self.bIsLoading=" .. tostring(self.bIsLoading) .. "; #self.ObstacleActorList=" .. #self.ObstacleActorList)
    if (not self.bIsLoading and #self.ObstacleActorList == 0) then
        self.bIsLoading = true
        local function Callback()
            self.bIsLoading = false
            --print("PlayObstacleEffect self.bIsLoading=" .. tostring(self.bIsLoading) .. "; self.State=" .. tostring(self.State))
            if (self.State <= 0) then
                return
            end
			local ModelClass = _G.ObjectMgr:GetClass(self.ModelPath)
            if (ModelClass == nil) then
                return
            end
			--加载阻挡基础模型
            local NewLocation = self.Location - self:GetWorldOriginLocation()
            local ObstacleActor = _G.CommonUtil.SpawnActor(ModelClass, NewLocation)
            if (ObstacleActor == nil) then
                return
            end

            local RingScaleXY = self.InnerRadius / self.ModelBaseSize.X
            local ScaleRing = _G.UE.FVector(RingScaleXY, RingScaleXY, 3)
            ObstacleActor:SetActorScale3D(ScaleRing)
            ObstacleActor:SetActorHiddenInGame(true)

            if (_G.CommonUtil.IsWithEditor()) then
                local BlockName = string.format("%d", self.ID)
                ObstacleActor:SetActorLabel(BlockName)
                ObstacleActor:SetFolderPath("DynObstacles")
            end

            table.insert(self.ObstacleActorList, ObstacleActor)

            --播放阻挡特效
            self:PlayObstacleEffect(self.EffectPath, false)
		end
		_G.ObjectMgr:LoadClassAsync(self.ModelPath, Callback)
    end
end

function DynDataObstacleRing:Disappear()
    --播放阻挡消散特效
    self:PlayObstacleEffect(self.DisappearEffectPath, true)
end

return DynDataObstacleRing