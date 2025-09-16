--
-- Author: sammrli
-- Date: 2024-3-18
-- Description:星空场景控制
--

local LuaClass = require("Core/LuaClass")

local ModelDefine = require("Game/Model/Define/ModelDefine")

local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")

local EventID = require("Define/EventID")
local ObjectGCType = require("Define/ObjectGCType")

local GameEventRegister = require("Register/GameEventRegister")
local LightMgr = require("Game/Light/LightMgr")

local ObjectMgr = _G.ObjectMgr
---@class StageUniverseController
---@field RenderStage UE.AActor
---@field FinishCallbackParam table@创建完成回调参数
---@field UIComplexCharacter UE.AActor
local StageUniverseController = LuaClass()

function StageUniverseController:Ctor()
    self.RenderStage = nil
    self.FinishCallbackParam = nil
    self.UIComplexCharacter = nil
    self.LightPresetRef = nil
end

function StageUniverseController:RegisterGameEvent()
    self.GameEventRegister = GameEventRegister.New()
    --self.GameEventRegister:Register(EventID.Avatar_AssembleAllEnd, self, self.OnAssembleAllEnd)
end

--function StageUniverseController:OnAssembleAllEnd(Params)
--    if Params.ULongParam1 == 0 then
--        self:UpdateLights()
--    end
--end

function StageUniverseController:Create(LocationParam, RotationParam, InStagePath)
    local AvatarComp = MajorUtil.GetMajorAvatarComponent()
    if not AvatarComp then
        return
    end
    local AttachType = AvatarComp:GetAttachType()
    local StagePath = InStagePath and InStagePath or string.format(ModelDefine.StagePath.Universe, AttachType, AttachType)
    
    local function CallBack()
        local Class1 = ObjectMgr:GetClass(StagePath)
        if Class1 == nil then
            return
        end

        local Location = LocationParam and LocationParam or ModelDefine.DefaultLocation
        local Rotation = RotationParam and RotationParam or ModelDefine.DefaultRotation

        self.RenderStage = CommonUtil.SpawnActor(Class1, Location, Rotation)

        local FinishCallbackParam = self.FinishCallbackParam
        if FinishCallbackParam then
            FinishCallbackParam.Callback(FinishCallbackParam.Target)
        end
        self:DisableEnvironmentLights()
    end
    if not self.GameEventRegister then
        self:RegisterGameEvent()
    end
    ObjectMgr:LoadClassAsync(StagePath, CallBack, ObjectGCType.NoCache)
end

function StageUniverseController:Release()
    if self.RenderStage then
        CommonUtil.DestroyActor(self.RenderStage)
        self.RenderStage = nil
    end
    if self.GameEventRegister then
		self.GameEventRegister:UnRegisterAll()
        self.GameEventRegister = nil
	end
    self.LightPresetRef = nil
end

function StageUniverseController:GetActor()
    return self.RenderStage
end

---绑定UIComplexCharacter（场景里的灯光,需要获取UIComplexCharacter的bound来计算）
---@param UIComplexCharacter UE.AUIComplexCharacter
function StageUniverseController:BindUIComplexCharacter(UIComplexCharacter)
    self.UIComplexCharacter = UIComplexCharacter
    --self:UpdateLights()
end

---更新灯光参数
function StageUniverseController:UpdateLights(LightPresetPath)
    if not self.RenderStage then
        return
    end
    if not self.UIComplexCharacter then
        return
    end
    local LightPreset = ObjectMgr:LoadObjectSync(LightPresetPath)
    self.LightPresetRef = _G.UnLua.Ref(LightPreset)
    if LightPreset then
        self.RenderStage:UpdateLights(self.UIComplexCharacter, LightPreset)
		LightMgr:RecordLightPreset(self.RenderStage, LightPreset)
    end
end

---设置创建完成回调
function StageUniverseController:SetCreateFinish(Target, Callback)
    self.FinishCallbackParam = {
        Target = Target,
        Callback = Callback,
    }
end

function StageUniverseController:DisableEnvironmentLights()
    if nil == self.RenderStage then
        return
    end

    local CompsToDisable = {}
    table.insert(CompsToDisable, self.RenderStage:GetComponentByClass(_G.UE.USkyLightComponent))
    table.insert(CompsToDisable, self.RenderStage:GetComponentByClass(_G.UE.UDirectionalLightComponent))
    table.insert(CompsToDisable, self.RenderStage:GetComponentByClass(_G.UE.UPlanarReflectionComponent))
    table.insert(CompsToDisable, self.RenderStage:GetComponentByClass(_G.UE.UChildActorComponent))
    table.insert(CompsToDisable, self.RenderStage:GetComponentByClass(_G.UE.UPostProcessComponent))
    for _, Comp in ipairs(CompsToDisable) do
        Comp:SetVisibility(false)
        if nil ~= Comp.bEnabled then
            Comp.bEnabled = false
        end
    end

    --关闭聚光灯
    local SpotLightList = self.RenderStage:K2_GetComponentsByClass(_G.UE.USpotLightComponent)
    local Count = SpotLightList:Length()
    for i = 1, Count do
        local SpotLightComponent = SpotLightList:Get(i)
        SpotLightComponent:SetVisibility(false)
        SpotLightComponent:SetActive(false)
    end
end

return StageUniverseController