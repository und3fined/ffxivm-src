--
-- Author: haialexzhou
-- Date: 2021-9-16
-- Description:动态阻挡
local LuaClass = require("Core/LuaClass")
local DynDataObstacle = require("Game/PWorld/DynData/DynDataObstacle")

---@class DynDataObstacle
local DynDataObstacleBox = LuaClass(DynDataObstacle, true)

function DynDataObstacleBox:Ctor()
    self.Extent = nil
    self.ObstacleBoxList = {}
    self.EffectPath = ""
    self.EffectPathNoBlock = ""
    self.ModelPath = "Blueprint'/Game/BluePrint/PWorld/BP_DynObstacle_Box.BP_DynObstacle_Box_C'"
    self.ModelBaseSize = _G.UE.FVector(100, 100, 100)
    self.EffectBaseSize = 0
    self.EffectNoBlockBaseSize = 0
    self.DefaultEffectID = 1
    self.DefaultNoBlockEffectID = 7
    self.ObstacleLineActors = {}
    _G.EventMgr:RegisterEvent(_G.EventID.UpdateInDialogOrSeq, self, self.OnGameUpdateInDialogOrSeq)
end

function DynDataObstacleBox:PlayEffect(VfxParameter)
    return self.Super:PlayEffect(VfxParameter)
end

function DynDataObstacleBox:UpdateState(NewState)
    self.Super:UpdateState(NewState)

    if (self.State == 0) then
        self:DestroyAllObstacle()

    elseif (self.State == 2) then
        self:BreakAllEffect()
        for _, ObstacleBox in ipairs(self.ObstacleBoxList) do
            --播放阻挡特效
            if (not self.bIsHideEffect and self.EffectPathNoBlock ~= nil and self.EffectPathNoBlock ~= "") then
                local Translation = _G.UE.FVector(ObstacleBox.Location.X, ObstacleBox.Location.Y, ObstacleBox.Location.Z - ObstacleBox.Extent.Z)
                local Rotation = ObstacleBox.Rotator:ToQuat()
                local Scale3D = _G.UE.FVector((ObstacleBox.Extent.X * 2) / self.EffectNoBlockBaseSize, 1.0, 1.0)
                local VfxParameter = _G.UE.FVfxParameter()
                VfxParameter.VfxRequireData.EffectPath = _G.CommonUtil.ParseBPPath(self.EffectPathNoBlock)
                VfxParameter.VfxRequireData.VfxTransform = _G.UE.FTransform(Rotation, Translation, Scale3D)

                self.EffectInstID = self:PlayEffect(VfxParameter)
            end
        end
    end
end

function DynDataObstacleBox:Show()
    if (not self.bIsLoading and #self.ObstacleActorList == 0 and #self.ObstacleBoxList > 0) then
        self.bIsLoading = true

        local function Callback()
            self.bIsLoading = false
            if (self.State <= 0) then
                return
            end
            local ModelClass = _G.ObjectMgr:GetClass(self.ModelPath)
            if (ModelClass == nil) then
                return
            end
            self:BreakAllEffect()
            --加载阻挡基础模型
            for _, ObstacleBox in ipairs(self.ObstacleBoxList) do
                local NewLocation = ObstacleBox.Location - self:GetWorldOriginLocation()
                local ObstacleActor = _G.CommonUtil.SpawnActor(ModelClass, NewLocation, ObstacleBox.Rotator)
                if (ObstacleActor ~= nil) then
                    local ScaleBox = (ObstacleBox.Extent * 2) / self.ModelBaseSize
                    ScaleBox = _G.UE.FVector(math.abs(ScaleBox.X), math.abs(ScaleBox.Y), math.abs(ScaleBox.Z));
                    ObstacleActor:SetActorScale3D(ScaleBox)
                    ObstacleActor:SetActorHiddenInGame(true)

                    if (_G.CommonUtil.IsWithEditor()) then
                        local BlockName = string.format("%d-%d", self.ID, ObstacleBox.ID)
                        ObstacleActor:SetActorLabel(BlockName)
                        ObstacleActor:SetFolderPath("DynObstacles")
                    end
                   
                    table.insert(self.ObstacleActorList, ObstacleActor)

                    --播放阻挡特效
                    if (not self.bIsHideEffect and self.EffectPath ~= nil and self.EffectPath ~= "") then

                        --临时判断条件：特效是否为阻挡线
                        if self.EffectPath == "Blueprint'/Game/Assets/Effect/BluePrint/PortalLine/BP_ObstacleLine.BP_ObstacleLine_C'" then
                            self:ShowObstacleLine(ObstacleBox)
                        else
                            local Translation = _G.UE.FVector(ObstacleBox.Location.X, ObstacleBox.Location.Y, ObstacleBox.Location.Z - ObstacleBox.Extent.Z)
                            local Rotation = ObstacleBox.Rotator:ToQuat()
                            local Scale3D = _G.UE.FVector((ObstacleBox.Extent.X * 2) / self.EffectBaseSize, 1.0, 1.0)
                            local VfxParameter = _G.UE.FVfxParameter()
                            VfxParameter.VfxRequireData.EffectPath = _G.CommonUtil.ParseBPPath(self.EffectPath)
                            VfxParameter.VfxRequireData.VfxTransform = _G.UE.FTransform(Rotation, Translation, Scale3D)
                
                            self.EffectInstID = self:PlayEffect(VfxParameter)
                        end
                    end
                end
            end
        end
        _G.ObjectMgr:LoadClassAsync(self.ModelPath, Callback)
    end
end

function DynDataObstacleBox:ShowObstacleLine(ObstacleBox)
    local function LoadModelCallback()
        self.bIsLoading = false
        if (self.State <= 0) then
            return
        end
        local EffectClass = _G.ObjectMgr:GetClass(self.EffectPath)
        if (EffectClass == nil) then
            return
        end

        local NewLocation = ObstacleBox.Location - self:GetWorldOriginLocation()
        local ObstacleLineActor = _G.CommonUtil.SpawnActor(EffectClass, NewLocation)
        if (ObstacleLineActor == nil or ObstacleLineActor:Cast(_G.UE.APortalLine) == nil) then
            return
        end

        if (_G.CommonUtil.IsWithEditor()) then
            local ActorLabelName = string.format("Obstacle-%d", self.ID)
            ObstacleLineActor:SetActorLabel(ActorLabelName)
            ObstacleLineActor:SetFolderPath("Obstacle")
        end


        --local PortalLineMaterialResPath = "MaterialInstanceConstant'/Game/Assets/Effect/BluePrint/PortalLine/MI_ObstacleLine.MI_ObstacleLine'"
        local PortalLineMaterialResPath = ObstacleLineActor:GetMIPath()
        local function LoadMaterialCallback()
            self.bIsLoading = false
            local MaterialObject = _G.ObjectMgr:GetObject(PortalLineMaterialResPath)
            if (MaterialObject == nil) then
                return
            end
            local PointA = _G.UE.FVector2D(NewLocation.X - ObstacleBox.Extent.X, NewLocation.Y - ObstacleBox.Extent.Y)
            local PointB = _G.UE.FVector2D(NewLocation.X + ObstacleBox.Extent.X, NewLocation.Y - ObstacleBox.Extent.Y)
            local PointC = _G.UE.FVector2D(NewLocation.X + ObstacleBox.Extent.X, NewLocation.Y + ObstacleBox.Extent.Y)
            local PointD = _G.UE.FVector2D(NewLocation.X - ObstacleBox.Extent.X, NewLocation.Y + ObstacleBox.Extent.Y)
            local PointAD = (PointA + PointD) / 2
            local PointBC = (PointB + PointC) / 2
            local MaterialInstance = MaterialObject:Cast(_G.UE.UMaterialInstance)
            if (MaterialInstance ~= nil) then
                ObstacleLineActor.MI_PortalLine = MaterialInstance
            end

            ObstacleLineActor.LinePoint_A = _G.UE.UCommonUtil.RotatePoint(NewLocation, ObstacleBox.Rotator.Yaw, _G.UE.FVector(PointAD.X, PointAD.Y, NewLocation.Z))
            ObstacleLineActor.LinePoint_B = _G.UE.UCommonUtil.RotatePoint(NewLocation, ObstacleBox.Rotator.Yaw, _G.UE.FVector(PointBC.X, PointBC.Y, NewLocation.Z))
            ObstacleLineActor.FloorZValue = NewLocation.Z - ObstacleBox.Extent.Z - 200
            ObstacleLineActor.CeilingZValue = NewLocation.Z + ObstacleBox.Extent.Z
            ObstacleLineActor.UpOffSetDistance_meter = ObstacleBox.Extent.Z / 100
            ObstacleLineActor.DownOffSetDistance_meter = ObstacleBox.Extent.Z / 100 + 10
            ObstacleLineActor:ReCalculateLine()
            local bHide =   _G.UE.UFGameFXManager.Get():GetNeedSheildEff()
            ObstacleLineActor:SetActorHiddenInGame(bHide)

            table.insert(self.ObstacleLineActors, ObstacleLineActor)
        end

        --_G.ObjectMgr:LoadObjectAsync(PortalLineMaterialResPath, LoadMaterialCallback)
        _G.ObjectMgr:LoadObjectSync(PortalLineMaterialResPath)
        LoadMaterialCallback()

    end
    --_G.ObjectMgr:LoadClassAsync(self.EffectPath, LoadModelCallback)
    _G.ObjectMgr:LoadClassSync(self.EffectPath)
    LoadModelCallback()
end

function DynDataObstacleBox:OnGameUpdateInDialogOrSeq(Params)
    for _, Actor in ipairs(self.ObstacleLineActors) do
        if _G.CommonUtil.IsObjectValid(Actor) then
            Actor:SetActorHiddenInGame(not Params)
        end
    end
end

function DynDataObstacleBox:DestroyAllObstacle()
    _G.EventMgr:UnRegisterEvent(_G.EventID.UpdateInDialogOrSeq, self, self.OnGameUpdateInDialogOrSeq)
    self.Super:DestroyAllObstacle()

    for _, Actor in ipairs(self.ObstacleLineActors) do
        _G.CommonUtil.DestroyActor(Actor)
    end
    self.ObstacleLineActors = {}
end

return DynDataObstacleBox