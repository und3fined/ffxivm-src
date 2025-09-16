--
-- Author: ashyuan
-- Date: 2024-3-5
-- Description:野外传送区域特效,同步端游LineVfx
--
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require ("Protocol/ProtoRes")
local LuaClass = require("Core/LuaClass")
local DynDataBase = require("Game/PWorld/DynData/DynDataBase")
---@class DynDataLineVfx
local DynDataLineVfx = LuaClass(DynDataBase, true)

function DynDataLineVfx:Ctor()
    self.PortalLineActor = nil
    self.bIsLoading = false
    self.Extent = _G.UE.FVector(100.0, 100.0, 100.0)
    --self.LineType = ProtoRes.linevfx_type.LINEVFX_TYPE_BLUE

    self.DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
    _G.EventMgr:RegisterEvent(EventID.UpdateInDialogOrSeq, self, self.OnGameUpdateInDialogOrSeq)
end

function DynDataLineVfx:Destroy()
    if self.Super ~= nil then
        self.Super:Destroy()
    end
    _G.EventMgr:UnRegisterEvent(EventID.UpdateInDialogOrSeq, self, self.OnGameUpdateInDialogOrSeq)
    if self.PortalLineActor then
        _G.CommonUtil.DestroyActor(self.PortalLineActor)
        self.PortalLineActor = nil
    end
end


function DynDataLineVfx:OnGameUpdateInDialogOrSeq(Params)
    if _G.CommonUtil.IsObjectValid(self.PortalLineActor) then
        self.PortalLineActor:SetActorHiddenInGame(not Params)
    end
end

function DynDataLineVfx:CreateBox(Box)
    self.Extent = _G.UE.FVector(Box.Extent.X, Box.Extent.Y, Box.Extent.Z)
    self.Location = _G.UE.FVector(Box.Center.X, Box.Center.Y, Box.Center.Z)
    self.Rotator = _G.UE.FRotator(Box.Rotator.Y, Box.Rotator.Z, Box.Rotator.X)
end

function DynDataLineVfx:UpdateState(NewState)
    self.Super:UpdateState(NewState)

    if (self.PortalLine ~= nil or self.bIsLoading) then
        return
    end
    self.bIsLoading = true

    local PortalLineResPath = "Blueprint'/Game/Assets/Effect/BluePrint/PortalLine/BP_PortalLine.BP_PortalLine_C'"

    --阻挡线
    -- if self.LineType ~= ProtoRes.linevfx_type.LINEVFX_TYPE_BLUE then
    --     PortalLineResPath = "Blueprint'/Game/Assets/Effect/BluePrint/PortalLine/BP_ObstacleLine.BP_ObstacleLine_C'"
    -- end

    local function LoadModelCallback()
        --FLOG_INFO("DynDataLineVfx:LoadModelCallback")
        self.bIsLoading = false
        local ModelClass = _G.ObjectMgr:GetClass(PortalLineResPath)
        if (ModelClass == nil) then
            return
        end
        local NewLocation = self.Location - self:GetWorldOriginLocation()

        local function SpawnActorCallback(_, NewActor)
            self.PortalLineActor = NewActor

            if (self.PortalLineActor == nil) or (self.PortalLineActor.GetMIPath == nil)then
                return
            end

            if (_G.CommonUtil.IsWithEditor()) then
                local ActorLabelName = string.format("LineVfx-%d", self.ID)
                self.PortalLineActor:SetActorLabel(ActorLabelName)
                self.PortalLineActor:SetFolderPath("LineVfx")
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
        
        --self.PortalLineActor = _G.CommonUtil.SpawnActor(ModelClass, NewLocation)

        _G.CommonUtil.SpawnActorAsync(ModelClass, NewLocation, nil, SpawnActorCallback)
    end

    _G.ObjectMgr:LoadClassAsync(PortalLineResPath, LoadModelCallback)
end

return DynDataLineVfx