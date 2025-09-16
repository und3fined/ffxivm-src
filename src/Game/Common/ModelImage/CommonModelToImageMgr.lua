---
--- Author: sammrli
--- DateTime: 2023-12-04 10:25
--- Description:
---

local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local MathUtil = require("Utils/MathUtil")
local ObjectGCType = require("Define/ObjectGCType")
local RenderSceneDefine = require("Game/Common/Render2D/RenderSceneDefine")
local UILevelMgr = require("Game/Common/Render2D/Level/UILevelMgr")

local CommonUtil = nil
local UE = nil

local MAX_SIZE = 1024

---@class CommonModelToImageMgr : MgrBase
---@field CameraCachePool table<UE.ACameraActor>
---@field RTCachePool table<number, table<UnLuaManualRefProxy, UE.UTextureRenderTarget2D>>
local CommonModelToImageMgr = LuaClass(MgrBase)

function CommonModelToImageMgr:OnInit()
    self.CameraCachePool = nil
    self.RTCachePool = nil
    self.RenderSceneActor = nil
    self.IsUseCache = true
    self.ReferenceCount = 0
end

function CommonModelToImageMgr:OnBegin()
    CommonUtil = _G.CommonUtil
    UE = _G.UE
end

function CommonModelToImageMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventExitWorld)
    self:RegisterGameEvent(EventID.WorldPreLoad, self.OnGameEventWorldPreLoad)
end

function CommonModelToImageMgr:OnEnd()
    self:Clear()
end

function CommonModelToImageMgr:OnShutdown()
end

function CommonModelToImageMgr:Clear()
    self.RTCachePool = {}
end

function CommonModelToImageMgr:CreateCameraActor()
    local CameraActor = nil
    local FindValidCamera = false
    if self.IsUseCache and self.CameraCachePool and #self.CameraCachePool > 0 then
        for i=#self.CameraCachePool, 1, -1 do
            CameraActor = self.CameraCachePool[i]
            if CameraActor and CommonUtil.IsObjectValid(CameraActor) then
                CameraActor.CameraComponent:SetVisibility(true)
                table.remove(self.CameraCachePool, i)
                FindValidCamera = true
                --FLOG_INFO("[CommonModelToImageMgr] 找到有效 Camera "..tostring(i))
                break
            else
                --FLOG_INFO("[CommonModelToImageMgr] 无效 Camera， 移除 "..tostring(i))
                table.remove(self.CameraCachePool, i)
            end
        end
    end
    if not FindValidCamera then
        --FLOG_INFO("[CommonModelToImageMgr] 没有 Camera， 创建 ")
        CameraActor = CommonUtil.SpawnActor(UE.ACameraActor.StaticClass())
        --设置参数
        CameraActor.CameraComponent:SetFieldOfView(40)
        CameraActor.CameraComponent:SetConstraintAspectRatio(false)
    end

    return CameraActor
end

---创建RenderTarget2D （尺寸最大1024）
---@param Actor UE.AActor
---@param SizeX number
---@param SizeY number
---@param IsHD boolean@已失效
---@return UE.UTextureRenderTarget2D, UE.FVector2D
function CommonModelToImageMgr:CreateRenderTarget2D(Actor, SizeX, SizeY, IsHD)
    local ChangeX = math.floor(SizeX)
    local ChangeY = math.floor(SizeY)
    local RatioOld = SizeX / SizeY  --x:y比例
    local RatioNew = RatioOld
    --不是高清,进行压缩 -已失效
    --if not IsHD then
        --尺寸适配
        --规则：向下取2的次幂
        ChangeX = math.min(MAX_SIZE, 2 ^ MathUtil.FloorLog2(SizeX))
        ChangeY = math.min(MAX_SIZE, 2 ^ MathUtil.FloorLog2(SizeY))
        RatioNew = ChangeX / ChangeY
    --end

    --FLOG_ERROR(string.format("[CommonModelToImageMgr] CreateRenderTarget2D sizeX=%f, sizeY=%f, changeX=%d, changeY=%d", SizeX, SizeY, ChangeX, ChangeY))

    local Key = ChangeX * 10000 + ChangeY
    if self.IsUseCache and self.RTCachePool then
        local Pool = self.RTCachePool[Key]
        if Pool and next(Pool) then
            local Ref, RT = next(Pool)
            Pool[Ref] = nil
            --FLOG_INFO("[CommonModelToImageMgr] 找到有效 RT ")
            return RT, UE.FVector2D(RatioNew / RatioOld , 1) --以y为准，x缩放
        end
    end
    --FLOG_INFO("[CommonModelToImageMgr] 没有 RT， 创建 ")
    local RT = UE.UKismetRenderingLibrary.CreateRenderTarget2D(Actor, math.tointeger(ChangeX), math.tointeger(ChangeY), UE.ETextureRenderTargetFormat.RTF_RGBA8)

    return RT, UE.FVector2D(RatioNew / RatioOld, 1) --以y为准，x缩放
end

function CommonModelToImageMgr:SetRenderSceneActorVisiable(IsVisiable)
    self.IsRenderSceneActorVisiable = IsVisiable
    if IsVisiable then
        --临时处理，需要天气那边提供接口
        local TodSystemActor = UE.UGameplayStatics.GetActorOfClass(FWORLD(), UE.ATodSystemActor.StaticClass())
        if TodSystemActor then
            local LightComp = TodSystemActor.SunLightComponent
            if LightComp then
                LightComp:SetVisibility(false)
            end
        end

        local TodSystemMainActor = UE.UGameplayStatics.GetActorOfClass(FWORLD(), UE.ATodSystemMainActor.StaticClass())
        if TodSystemMainActor then
            local LightComp = TodSystemMainActor:GetComponentByClass(UE.UDirectionalLightComponent)
            if LightComp then
                LightComp:SetVisibility(false)
            end

            local SkyComp = TodSystemMainActor:GetComponentByClass(UE.USkyLightComponent)
            if SkyComp then
                SkyComp:SetVisibility(false)
            end
        end
    else
        local TodSystemActor = UE.UGameplayStatics.GetActorOfClass(FWORLD(), UE.ATodSystemActor.StaticClass())
        if TodSystemActor then
            local LightComp = TodSystemActor.SunLightComponent
            if LightComp then
                LightComp:SetVisibility(true)
            end
        end

        local TodSystemMainActor = UE.UGameplayStatics.GetActorOfClass(FWORLD(), UE.ATodSystemMainActor.StaticClass())
        if TodSystemMainActor then
            local LightComp = TodSystemMainActor:GetComponentByClass(UE.UDirectionalLightComponent)
            if LightComp then
                LightComp:SetVisibility(true)
            end

            local SkyComp = TodSystemMainActor:GetComponentByClass(UE.USkyLightComponent)
            if SkyComp then
                SkyComp:SetVisibility(true)
            end
        end
    end
end

---设置是否使用缓存
---@param Val boolean
function CommonModelToImageMgr:SetUseCache(Val)
    self.IsUseCache = Val
end

function CommonModelToImageMgr:CreateRenderSceneActor()
    if self.IsCreatingRenderSceneActor then
        return
    end
    --local Location = TargetActor:K2_GetActorLocation()
    self.IsCreatingRenderSceneActor = true
    local ResPath = "Blueprint'/Game/UI/Render2D/BP_Render2DModel.BP_Render2DModel_C'"
    local function CallBack()
        self.IsCreatingRenderSceneActor = false
        local UClass = _G.ObjectMgr:GetClass(ResPath)
        if not UClass then
            return
        end
        local Ratation = UE.FRotator(0, 0, 0)
        local Location = RenderSceneDefine.Location
        self.RenderSceneActor = CommonUtil.SpawnActor(UClass, Location, Ratation)
        --这个版本只有方向光
        --local LightPreset = _G.ObjectMgr:LoadObjectSync(_G.EquipmentMgr:GetLightConfig())
        --if LightPreset then
        --    if TargetActor and CommonUtil.IsObjectValid(TargetActor) then
        --        self.RenderSceneActor:UpdateLights(TargetActor, LightPreset)
        --    end
        --end
        if not self.IsRenderSceneActorVisiable then
            self.RenderSceneActor:SetActorHiddenInGame(true)
        end
    end
    _G.ObjectMgr:LoadClassAsync(ResPath, CallBack, ObjectGCType.LRU)
end

---@param CameraActor UE.ACameraActor
function CommonModelToImageMgr:ReleaseCameraActor(CameraActor)
    if self.IsUseCache and CameraActor then
        if not self.CameraCachePool then
            self.CameraCachePool = {}
        end
        --重置参数
        CameraActor.CameraComponent:SetVisibility(false)
        table.insert(self.CameraCachePool, CameraActor)
    end
end

---@param RenderTarget2D UE.UTextureRenderTarget2D
function CommonModelToImageMgr:ReleaseRenderTarger2D(RenderTarget2D)
    if self.IsUseCache and RenderTarget2D and CommonUtil.IsObjectValid(RenderTarget2D) then
        if not self.RTCachePool then
            self.RTCachePool = {}
        end
        local Key = RenderTarget2D.SizeX * 10000 + RenderTarget2D.SizeY
        if not self.RTCachePool[Key] then
            self.RTCachePool[Key] = {}
        end
        local Ref = UnLua.Ref(RenderTarget2D)
        if not Ref then
            return
        end
        self.RTCachePool[Key][Ref] = RenderTarget2D
    end
end

---引用计数+1
function CommonModelToImageMgr:AddReferenceCount()
    self.ReferenceCount = self.ReferenceCount + 1
    if self.ReferenceCount == 1 then
        UILevelMgr:SwitchLevelStreaming(false)
    end
end

---引用计数-1
function CommonModelToImageMgr:RemoveReferenceCount()
    self.ReferenceCount = self.ReferenceCount - 1
    if self.ReferenceCount == 0 then
        UILevelMgr:SwitchLevelStreaming(true)
    end
    if self.ReferenceCount < 0 then
        FLOG_ERROR("[CommonModelToImageMgr] Reference Count Error ! Count="..tostring(self.ReferenceCount))
        self.ReferenceCount = 0
    end
end

function CommonModelToImageMgr:OnGameEventExitWorld()
    self:Clear()
end

function CommonModelToImageMgr:OnGameEventWorldPreLoad()
    self:Clear()
end

---先临时写死数值测试
function CommonModelToImageMgr:TestCreateModelBg()
    local BgResPath = "Blueprint'/Game/UI/Render2D/Common/BP_Render_BG.BP_Render_BG_C'"
    local function LoadResCallback()
        local ResClass = _G.ObjectMgr:GetClass(BgResPath)
        if not ResClass then
            return
        end
        local BgActor = _G.CommonUtil.SpawnActor(ResClass, UE.FVector(0, 0, 0))
        if not BgActor then
            return
        end

        BgActor:K2_SetActorLocation(UE.FVector(-2000, 0, 100150), false, nil, false)
        BgActor:K2_SetActorRotation(UE.FRotator(0, -90, 90), false)
        --BgActor:SetActorScale3D(UE.FVector(10.1425, 5.42, 1))
        BgActor:SetActorScale3D(UE.FVector(47.1, 25.3524, 1))
    end
    _G.ObjectMgr:LoadClassAsync(BgResPath, LoadResCallback)
end

function CommonModelToImageMgr:CreateModelBg(FPos, FRot, FScale, Type)
    local BgResPath = "Blueprint'/Game/UI/Render2D/Common/BP_Render_BG.BP_Render_BG_C'"
    if Type then
       BgResPath = "Blueprint'/Game/UI/Render2D/Common/BP_Render_BG_2.BP_Render_BG_2_C'"
    end
    local function LoadResCallback()
        local ResClass = _G.ObjectMgr:GetClass(BgResPath)
        if not ResClass then
            return
        end
        local BgActor = _G.CommonUtil.SpawnActor(ResClass, FPos)
        if not BgActor then
            return
        end

        --BgActor:K2_SetActorLocation(FPos, false, nil, false)
        BgActor:K2_SetActorRotation(FRot, false)
        BgActor:SetActorScale3D(FScale)
    end
    _G.ObjectMgr:LoadClassAsync(BgResPath, LoadResCallback)
end


function CommonModelToImageMgr:TestModelBg()
    self.TestModelBgMode = true
end

function CommonModelToImageMgr:TestRechangeMoveActor()
    _G.RechargingMgr.SceneActor:K2_SetActorLocation(_G.UE.FVector(-100093, -43, 100043), false, nil, false)
    _G.RechargingMgr.SceneActor:K2_SetActorRotation(_G.UE.FRotator(0, 0, 8), false)
end

function CommonModelToImageMgr:CreateTest(TargetActor)
    local ResPath = "Blueprint'/Game/UI/Render2D/BP_Render2DModel_2.BP_Render2DModel_2_C'"
    local function Callback()
        local UClass = _G.ObjectMgr:GetClass(ResPath)
        if not UClass then
            return
        end
        local Ratation = UE.FRotator(0, 0, 0)
        local Location = RenderSceneDefine.Location
        self.RenderSceneActor = CommonUtil.SpawnActor(UClass, Location, Ratation)
        self.RenderSceneActor.CaptureFinal:ShowOnlyActorComponents(TargetActor, true)
        self.RenderSceneActor.CaptureAlpha:ShowOnlyActorComponents(TargetActor, true)
    end
    _G.ObjectMgr:LoadClassAsync(ResPath, Callback, ObjectGCType.LRU)
end

function CommonModelToImageMgr:OpenPostProcessing()
end

function CommonModelToImageMgr:ClosePostProcessing()
    local World = GameplayStaticsUtil:GetWorld()
    local UGameplayStatics = UE.UGameplayStatics
    local AllPostProcessVolumes = UE.TArray(UE.AActor)
    UGameplayStatics.GetAllActorsOfClass(World, UE.APostProcessVolume.StaticClass(), AllPostProcessVolumes)
    for Index = 1, AllPostProcessVolumes:Length() do
        local PostProcessVolume = AllPostProcessVolumes:GetRef(Index)
        if PostProcessVolume.bEnabled then
            PostProcessVolume.bEnabled = false
        end
    end
end

return CommonModelToImageMgr