--
-- Author: haialexzhou
-- Date: 2021-9-23
-- Description:区域
--
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require ("Protocol/ProtoRes")
local LuaClass = require("Core/LuaClass")
local DynDataTriggerBase = require("Game/PWorld/DynData/DynDataTriggerBase")
local QuestDefine = require("Game/Quest/QuestDefine")
local MapGimmickFishAreaMgr = require("Game/PWorld/MapGimmickFishAreaMgr")

local NeedEndOverlapList = {JumbAreaID = 1100000}  -- 传送先销毁了Area需要离开事件白名单
---@class DynDataArea
local DynDataArea = LuaClass(DynDataTriggerBase, true)

function DynDataArea:Ctor()
    self.DataType = ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_AREA
    self.AreaFuncType = ProtoRes.area_func_type.AREA_FUNC_TYPE_NORMAL
    self.FuncData = nil --Map or Quest or Gimmick
    self.Priority = 0
end

function DynDataArea:OnTriggerBeginOverlap(Trigger, Target)
    if (not self:IsNeedTrigger(Trigger, Target)) then
        return
    end

    local EventParam = {};
    EventParam.AreaID = self.ID
    if self.AreaFuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_QUEST then
        EventParam.bTriggeredOnCreate = self.bTriggeredOnCreate
    elseif self.AreaFuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_GIMMICK then
        local GimmickData = self.FuncData
        -- 渔场区域
        if GimmickData.Type == ProtoRes.gimmick_type.GIMMICK_TYPE_FISHING then
            EventParam.FishAreaID = GimmickData.GimmickKey
            EventParam.Priority = self.Priority
            MapGimmickFishAreaMgr:EnterFishArea(EventParam)
        end
    elseif self.AreaFuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_NORMAL then
        local NormalData = self.FuncData
        EventParam.bforbidfly = NormalData.forbidfly
    end

    _G.EventMgr:SendEvent(_G.EventID.AreaTriggerBeginOverlap, EventParam)
    
    self.bIsTriggering = true
    _G.MapAreaMgr:SendEnterArea(self.ID, self.Priority)
end

function DynDataArea:OnTriggerEndOverlap(Trigger, Target)
    self.bIsTriggering = false
    if (not self:IsNeedTrigger(Trigger, Target, true)) then
        return
    end

    local EventParam = {};
    EventParam.AreaID = self.ID
    if self.AreaFuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_GIMMICK then
        local GimmickData = self.FuncData
        -- 渔场区域
        if GimmickData.Type == ProtoRes.gimmick_type.GIMMICK_TYPE_FISHING then
            EventParam.FishAreaID = GimmickData.GimmickKey
            MapGimmickFishAreaMgr:ExitFishArea(EventParam)
        end
    elseif self.AreaFuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_NORMAL then
        local NormalData = self.FuncData
        EventParam.bforbidfly = NormalData.forbidfly
    end
    _G.EventMgr:SendEvent(_G.EventID.AreaTriggerEndOverlap, EventParam)

    _G.MapAreaMgr:SendExitArea(self.ID)
end

function DynDataArea:IsForbidUse()
    for _, AreaID in pairs(NeedEndOverlapList) do
        if AreaID == self.ID then
            return false
        end
    end
    return self.State == 0 and self.AreaFuncType ~= ProtoRes.area_func_type.AREA_FUNC_TYPE_QUEST
end

function DynDataArea:PlayQuestAreaEffect()
	local Translation = self.Location - self:GetWorldOriginLocation()
	local Rotation = _G.UE.FQuat()
    local FXScale = self.Radius / 700 -- 试出来的数值
	local Scale3D = _G.UE.FVector(FXScale, FXScale, 1)
	local VfxParameter = _G.UE.FVfxParameter()
	VfxParameter.VfxRequireData.EffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/bgcommon/world/common/vfx_for_event/b0149_mrct_y/BP_b0149_mrct_y.BP_b0149_mrct_y_C'"
	VfxParameter.VfxRequireData.VfxTransform = _G.UE.FTransform(Rotation, Translation, Scale3D)
	VfxParameter.VfxRequireData.bAlwaysSpawn = true

    self.EffectInstID = self:PlayEffect(VfxParameter)
end

return DynDataArea