--
-- Author: haialexzhou
-- Date: 2021-9-23
-- Description:传送阵
--
local ProtoCommon = require("Protocol/ProtoCommon")
local LuaClass = require("Core/LuaClass")
local DynDataTriggerBase = require("Game/PWorld/DynData/DynDataTriggerBase")
---@class DynDataTransArray
local DynDataTransArray = LuaClass(DynDataTriggerBase, true)

function DynDataTransArray:Ctor()
    self.ModelPath = "Blueprint'/Game/BluePrint/PWorld/BP_Interact.BP_Interact_C'"
    self.EffectPath = "ParticleSystem'/Game/Assets/Effect/Particles/Sence/Common/PS_transferpoint.PS_transferpoint'"
    self.EffectScale = _G.UE.FVector(1.0, 1.0, 1.0)
    self.InteractActor = nil
    self.bIsLoading = false
    self.DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_TRANSPOINT
end

function DynDataTransArray:UpdateState(NewState)
    self.Super:UpdateState(NewState)

    if (self.State > 0) then
        if (not self.bIsLoading) then
            self.bIsLoading = true
            local function LoadModelCallback()
                self.bIsLoading = false
                local ModelClass = _G.ObjectMgr:GetClass(self.ModelPath)
                if (ModelClass == nil) then
                    return
                end
                local NewLocation = self.Location - self:GetWorldOriginLocation()
                self.InteractActor = _G.CommonUtil.SpawnActor(ModelClass, NewLocation, self.Rotator)
                if (self.InteractActor ~= nil) then
                    self.InteractActor:SetActorHiddenInGame(true)
    
                    local DynamicAssetActor = self.InteractActor:Cast(_G.UE.AMapDynamicAssetBase)
                    if (DynamicAssetActor ~= nil) then
                        DynamicAssetActor.ID = self.ID
                        DynamicAssetActor.DynamicAssetType = _G.UE.EMapDynamicAssetType.MapDynamicAssetType_TransArray
                    end
    
                    if (_G.CommonUtil.IsWithEditor()) then
                        local ActorLabelName = string.format("TransArray-%d", self.ID)
                        self.InteractActor:SetActorLabel(ActorLabelName)
                        self.InteractActor:SetFolderPath("TransDoor")
                    end
                end
            end
            _G.ObjectMgr:LoadClassAsync(self.ModelPath, LoadModelCallback)
        end

        local Translation = _G.UE.FVector(self.Location.X, self.Location.Y, self.Location.Z)
        local Rotation = self.Rotator:ToQuat()
        local Scale3D = self.EffectScale
        local VfxParameter = _G.UE.FVfxParameter()
        VfxParameter.VfxRequireData.EffectPath = _G.CommonUtil.ParseBPPath(self.EffectPath)
        VfxParameter.VfxRequireData.VfxTransform = _G.UE.FTransform(Rotation, Translation, Scale3D)

        self.EffectInstID = self.Super:PlayEffect(VfxParameter)
    else
        self:BreakAllEffect()
    end
end

function DynDataTransArray:OnClicked()
    -- _G.MsgBoxUtil.MessageBox(LSTR("是否传送至储存点？"), LSTR(10033), LSTR(10034), function()
	-- 	local ProtoCS = require("Protocol/ProtoCS")
	-- 	_G.PWorldMgr:SendTrans(ProtoCS.PWORLD_TRANS_TYPE.PWORLD_TRANS_TYPE_POINT, self.ID)
	-- end)
    --传送阵目前暂未启用
    local ProtoCS = require("Protocol/ProtoCS")
	_G.PWorldMgr:SendTrans(ProtoCS.PWORLD_TRANS_TYPE.PWORLD_TRANS_TYPE_POINT, self.ID)
end

return DynDataTransArray