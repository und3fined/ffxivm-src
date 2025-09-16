--
-- Author: haialexzhou
-- Date: 2021-9-23
-- Description:传送门
--
local ProtoRes = require ("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local LuaClass = require("Core/LuaClass")
local DynDataTriggerBase = require("Game/PWorld/DynData/DynDataTriggerBase")
local DynDataCommon = require("Game/PWorld/DynData/DynDataCommon")
local ProtoCS = require("Protocol/ProtoCS")

local EDynDataTriggerShapeType = DynDataCommon.EDynDataTriggerShapeType
---@class DynDataTransDoor : DynDataTriggerBase
local DynDataTransDoor = LuaClass(DynDataTriggerBase, true)

function DynDataTransDoor:Ctor()
    self.EffectPath = ""
    self.EffectScale = _G.UE.FVector(1.0, 1.0, 1.0)
    self.PortalLineActor = nil
    self.RecentTransTime = 0
    self.MinIntervalTime = 1.0
    self.bIsLoading = false
    self.DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_TRANSPOINT
    self.TransType = ProtoRes.trans_type.TRANS_TYPE_DOOR
    self.DefaultEffectID = 3
    self.EffectID = 0
end

function DynDataTransDoor:UpdateState(NewState)
    self.Super:UpdateState(NewState)

    if (self.State > 0) then
        local function PlayEffectInternal()
            local Translation = _G.UE.FVector(self.Location.X, self.Location.Y, self.Location.Z)
            local Rotation = _G.UE.FQuat()
            if (self.Rotator ~= nil) then
                Rotation = self.Rotator:ToQuat()
            end
            local Scale3D = self.EffectScale
            local VfxParameter = _G.UE.FVfxParameter()
            VfxParameter.VfxRequireData.EffectPath = _G.CommonUtil.ParseBPPath(self.EffectPath)
            VfxParameter.VfxRequireData.VfxTransform = _G.UE.FTransform(Rotation, Translation, Scale3D)


            self.EffectInstID = self.Super:PlayEffect(VfxParameter)
        end

        if (self.ShapeType == EDynDataTriggerShapeType.TriggerShapeType_Cylinder) then
            PlayEffectInternal()

        elseif (self.ShapeType == EDynDataTriggerShapeType.TriggerShapeType_Box) then
            if (self.EffectPath ~= "") then
                PlayEffectInternal()
                return
            end

            if (self.PortalLine ~= nil or self.bIsLoading or self.EffectID == 0) then
                return
            end
            self.bIsLoading = true

            local PortalLineResPath = "Blueprint'/Game/Assets/Effect/BluePrint/PortalLine/BP_PortalLine.BP_PortalLine_C'"
            local function LoadModelCallback()
                self.bIsLoading = false
                local ModelClass = _G.ObjectMgr:GetClass(PortalLineResPath)
                if (ModelClass == nil) then
                    return
                end
                local NewLocation = self.Location - self:GetWorldOriginLocation()
                self.PortalLineActor = _G.CommonUtil.SpawnActor(ModelClass, NewLocation)
                if (self.PortalLineActor == nil) then
                    return
                end

                if (_G.CommonUtil.IsWithEditor()) then
                    local ActorLabelName = string.format("TransDoor-%d", self.ID)
                    self.PortalLineActor:SetActorLabel(ActorLabelName)
                    self.PortalLineActor:SetFolderPath("TransDoor")
                end

                --local PortalLineMaterialResPath = "MaterialInstanceConstant'/Game/Assets/Effect/BluePrint/PortalLine/MI_PortalLine_0.MI_PortalLine_0'"
                local PortalLineMaterialResPath = self.PortalLineActor:GetMIPath()
                local function LoadMaterialCallback()
                    self.bIsLoading = false
                    local MaterialObject = _G.ObjectMgr:GetObject(PortalLineMaterialResPath)
                    if (MaterialObject == nil) then
                        return
                    end
                    local PointA = _G.UE.FVector2D(NewLocation.X - self.Extent.X, NewLocation.Y - self.Extent.Y)
                    local PointB = _G.UE.FVector2D(NewLocation.X + self.Extent.X, NewLocation.Y - self.Extent.Y)
                    local PointC = _G.UE.FVector2D(NewLocation.X + self.Extent.X, NewLocation.Y + self.Extent.Y)
                    local PointD = _G.UE.FVector2D(NewLocation.X - self.Extent.X, NewLocation.Y + self.Extent.Y)
                    local PointAD = (PointA + PointD) / 2
                    local PointBC = (PointB + PointC) / 2
                    local MaterialInstance = MaterialObject:Cast(_G.UE.UMaterialInstance)
                    if (MaterialInstance ~= nil) then
                        self.PortalLineActor.MI_PortalLine = MaterialInstance
                    end

                    if (self.Rotator == nil) then
                        self.Rotator = _G.UE.FRotator(0, 0, 0)
                    end

                    self.PortalLineActor.LinePoint_A = _G.UE.UCommonUtil.RotatePoint(NewLocation, self.Rotator.Yaw, _G.UE.FVector(PointAD.X, PointAD.Y, NewLocation.Z))
                    self.PortalLineActor.LinePoint_B = _G.UE.UCommonUtil.RotatePoint(NewLocation, self.Rotator.Yaw, _G.UE.FVector(PointBC.X, PointBC.Y, NewLocation.Z))
                    self.PortalLineActor.FloorZValue = NewLocation.Z - self.Extent.Z - 200
                    self.PortalLineActor.CeilingZValue = NewLocation.Z + self.Extent.Z
                    self.PortalLineActor.UpOffSetDistance_meter = self.Extent.Z / 100
                    self.PortalLineActor.DownOffSetDistance_meter = self.Extent.Z / 100 + 10
                    self.PortalLineActor:ReCalculateLine()
                end

                _G.ObjectMgr:LoadObjectAsync(PortalLineMaterialResPath, LoadMaterialCallback)
            end

            _G.ObjectMgr:LoadClassAsync(PortalLineResPath, LoadModelCallback)
        end
    else
        if (self.ShapeType == EDynDataTriggerShapeType.TriggerShapeType_Cylinder) then
            self:BreakAllEffect()

        elseif (self.ShapeType == EDynDataTriggerShapeType.TriggerShapeType_Box) then
            if (self.EffectPath ~= "") then
                self:BreakAllEffect()
            elseif (self.PortalLineActor ~= nil) then
                _G.CommonUtil.DestroyActor(self.PortalLineActor)
                self.PortalLineActor = nil
            end
        end
    end
end

function DynDataTransDoor:OnTriggerBeginOverlap(Trigger, Target)
    local NowTimeSeconds = _G.TimeUtil.GetLocalTime()
    if (NowTimeSeconds - self.RecentTransTime >= self.MinIntervalTime) then
        self.bIsTriggering = false
    end

    if (not self:IsNeedTrigger(Trigger, Target)) then
        return
    end
    self.RecentTransTime = _G.TimeUtil.GetLocalTime()
    self.bIsTriggering = true
    self:SendPWorldTrans(self.ID)
end

function DynDataTransDoor:OnTriggerEndOverlap(Trigger, Target)
    local NowTimeSeconds = _G.TimeUtil.GetLocalTime()
    if (NowTimeSeconds - self.RecentTransTime >= self.MinIntervalTime) then
        self.bIsTriggering = false
    end
end

function DynDataTransDoor:SendPWorldTrans(TransPointID)

    local function DoSendPWorldTrans()
        -- 显示黑屏渐隐
        local Params = {}
        Params.FadeColorType = 3
        Params.Duration = 0.6
        Params.bAutoHide = false
        _G.UIViewMgr:ShowView(UIViewID.CommonFadePanel, Params)

        _G.PWorldMgr:SendTrans(ProtoCS.PWORLD_TRANS_TYPE.PWORLD_TRANS_TYPE_POINT, TransPointID)
    end

    if (self.TransType == ProtoRes.trans_type.TRANS_TYPE_LEAVE) then
        _G.MsgBoxUtil.MessageBox(LSTR(800010), LSTR(10002), LSTR(10003),  function()
            DoSendPWorldTrans()
		end)
    else
        DoSendPWorldTrans()
    end
end

return DynDataTransDoor