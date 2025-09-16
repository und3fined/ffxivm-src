--
-- Author: sammrli
-- Date: 2024-3-4
-- Description:灯光管理
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local EventID = require("Define/EventID")
local LightDefine = require("Game/Light/LightDefine")
local RenderSceneDefine = require("Game/Common/Render2D/RenderSceneDefine")

local PathMgr = require("Path/PathMgr")
local CommonUtil = require("Utils/CommonUtil")
local GameplayStaticsUtil = require("Utils/GameplayStaticsUtil")

local SystemLightCfg = require("TableCfg/SystemLightCfg")
local WeatherUiWeatherCfg = require("TableCfg/WeatherUiWeatherCfg")

local UE = _G.UE
local UWorldMgr
local FAmbientOcclusionParam = UE.FAmbientOcclusionParam()
local EAmbientOcclusionType = UE.EAmbientOcclusionType.UI

---@class LightMgr : MgrBase
---@field Stack table<number>@关卡id栈
local LightMgr = LuaClass(MgrBase)

function LightMgr:OnInit()
    self.StackLevel = {} -- 灯光关卡栈
    self.StackWeaher = {} -- 天气栈
    ---@type table<string, function>
    self.LoadCallbackList = {}
    self.LocationInfoList = {} --位置信息
end

function LightMgr:OnBegin()
    UWorldMgr = UE.UWorldMgr.Get()
end

function LightMgr:OnEnd()
end

function LightMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.LevelPostLoad, self.OnGameEventLevelPostLoad)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventEnterExit)
end

function LightMgr:__SetLocation(LevelName, Location)
    local LightLevel = UE.UGameplayStatics.GetStreamingLevel(FWORLD(), LevelName)
    if LightLevel then
        if LightLevel:IsLevelLoaded() then
            local Level = LightLevel:GetLoadedLevel()
            if Level then
                local Actors = UWorldMgr:GetActorsInLevel(Level)
                for i=1, Actors:Length() do
                    local Actor = Actors:GetRef(i)
                    if Actor then
                        local Name = Actor:GetName()
                        if Name == "LightRoot" or Name == "Light_Root" then
                            Actor:K2_SetActorLocation(Location, false, nil, false)
                            break
                        end
                    end
                end
            end
        end
    end
end

---转换：系统ID转换成美术配置最终读取的uitod文件
function LightMgr:__ParseToUITOD(SystemID)
    local SystemLightCfgItem = SystemLightCfg:FindCfgByKey(SystemID)
    if SystemLightCfgItem then
        return SystemLightCfgItem.UITOD
    end
    return 0 --转换失败
end

function LightMgr:OnGameEventLevelPostLoad(Params)
    local LevelName = Params.StringParam1
    --处理preload
    if self.LoadCallbackList[LevelName] then
        self.LoadCallbackList[LevelName]()
        self.LoadCallbackList[LevelName] = nil
    end

    local Location = self.LocationInfoList[LevelName]
    if Location then
        self:__SetLocation(LevelName, Location)
    else
        self:__SetLocation(LevelName, RenderSceneDefine.Location)
    end
end

function LightMgr:OnGameEventEnterExit()
    self.StackLevel = {}
    self.StackWeaher = {}
end

-- ==================================================
-- 外部系统接口
-- ==================================================


---加载灯光关卡
---@param LevelPath string@关卡路径
---@param Location table@{X,Y,Z}
function LightMgr:LoadLightLevelByPath(LevelPath, Location)
    if not string.isnilorempty(LevelPath) then
        if CommonUtil.IsWithEditor() then
            self:PrintLightLevel(LevelPath)
        end
        UWorldMgr:LoadDynamicLevel(LevelPath, false)
        if Location then
            local Vector = UE.FVector(Location.X, Location.Y, Location.Z)
            self.LocationInfoList[LevelPath] = Vector
        end
    end
end

---卸载灯光光卡
---@param LevelPath string@关卡路径
function LightMgr:UnLoadLightLevelByPath(LevelPath)
    if not string.isnilorempty(LevelPath) then
        UWorldMgr:UnLoadLevel(LevelPath, true)
    end
end

---加载灯光关卡
---@param SystemID number@系统ID
---@param Location table@{X,Y,Z}
---@param LevelIndex number@配置多个关卡可以填入序号，不填默认第一个
function LightMgr:LoadLightLevel(SystemID, Location, LevelIndex)
    local SystemLightCfgItem = SystemLightCfg:FindCfgByKey(SystemID)
    if SystemLightCfgItem then
        local Index = LevelIndex or 1
        local LevelPath = SystemLightCfgItem.LightLevelPaths[Index]
        if not string.isnilorempty(LevelPath) then
            if CommonUtil.IsWithEditor() then
                self:PrintLightLevel(LevelPath)
            end
            UWorldMgr:LoadDynamicLevel(LevelPath, false)
            if Location then
                local Vector = UE.FVector(Location.X, Location.Y, Location.Z)
                self.LocationInfoList[LevelPath] = Vector
            end
        end
    end
end

---卸载灯光光卡
---@param SystemID number@系统ID
---@param LevelIndex number@配置多个关卡可以填入序号，不填默认第一个
function LightMgr:UnLoadLightLevel(SystemID, LevelIndex)
    local SystemLightCfgItem = SystemLightCfg:FindCfgByKey(SystemID)
    if SystemLightCfgItem then
        local Index = LevelIndex or 1
        local LevelPath = SystemLightCfgItem.LightLevelPaths[Index]
        if not string.isnilorempty(LevelPath) then
            UWorldMgr:UnLoadLevel(LevelPath, true)
        end
    end
end


--- 打开UI天气
---@param SystemID number@系统ID
---@param DontPushStack boolean@不入栈
function LightMgr:EnableUIWeather(SystemID, DontPushStack)
    local UITodID = self:__ParseToUITOD(SystemID)
    if UITodID == 0 then
        FLOG_ERROR("[LightMgr] Parse To UITod Fail, SystemID="..tostring(SystemID))
        return
    end
    local PlatformName = CommonUtil.GetPlatformName()
    if PlatformName == "Windows" then
        local Content = UE.UExcelUtil.GetWeatherUISystemTable()
        if not string.isnilorempty(Content) then
            local WeatherTable = {}
            local RowList = string.split(Content, '|')
            for i=1, #RowList do
                local Row = RowList[i]
                local ValueList = string.split(Row, ',')
                table.insert(WeatherTable, {
                    ID = tonumber(ValueList[1]),
                    UITodID = tonumber(ValueList[2]),
                    WeatherFilePath = ValueList[4],
                    WeatherID = tonumber(ValueList[5]),
                    Para1 = tonumber(ValueList[6]),
                    Para2 = tonumber(ValueList[7]),
                    Para3 = tonumber(ValueList[8]),
                })
            end
            local Item = WeatherTable[UITodID]
            if Item then
                _G.WeatherMgr:EnableUISystemWeather(true, Item.WeatherFilePath, Item.WeatherID, Item.Para1, Item.Para2, Item.Para3)
                return
            end
        end
    end
    local Cfg = WeatherUiWeatherCfg:FindCfgByKey(UITodID)
    if Cfg then
        _G.WeatherMgr:EnableUISystemWeather(true, Cfg.WeatherFilePath, Cfg.WeatherID, Cfg.Para1, Cfg.Para2, Cfg.Para3)
    end
    if not DontPushStack then
        table.insert(self.StackWeaher, UITodID) -- 入栈
    end

    FAmbientOcclusionParam.bEnabled = true
    FAmbientOcclusionParam.AORadius = 2
    FAmbientOcclusionParam.AOIntensity = 0
    local UCameraPostEffectMgr = UE.UCameraPostEffectMgr.Get()
    if UCameraPostEffectMgr then
        UCameraPostEffectMgr:UpdateAmbientOcclusionParam(EAmbientOcclusionType, FAmbientOcclusionParam)
    end
end

--- 关闭UI天气
---@param IsForce boolean@不使用栈,强制切回地图天气
function LightMgr:DisableUIWeather(IsForce)
    if IsForce then
        _G.WeatherMgr:EnableUISystemWeather(false)
        self.StackWeaher = {} -- 清空栈
        FAmbientOcclusionParam.bEnabled = false
        local UCameraPostEffectMgr = UE.UCameraPostEffectMgr.Get()
        if UCameraPostEffectMgr then
            UCameraPostEffectMgr:UpdateAmbientOcclusionParam(EAmbientOcclusionType, FAmbientOcclusionParam)
        end
    else
        local Current = #self.StackWeaher
        if Current > 1 then
            local LastWeatherID = self.StackWeaher[Current - 1]
            local Cfg = WeatherUiWeatherCfg:FindCfgByKey(LastWeatherID)
            if Cfg then
                _G.WeatherMgr:EnableUISystemWeather(true, Cfg.WeatherFilePath, Cfg.WeatherID, Cfg.Para1, Cfg.Para2, Cfg.Para3)
            end
            self.StackWeaher[Current] = nil
        else
            _G.WeatherMgr:EnableUISystemWeather(false)
            self.StackWeaher = {}
            FAmbientOcclusionParam.bEnabled = false
            local UCameraPostEffectMgr = UE.UCameraPostEffectMgr.Get()
            if UCameraPostEffectMgr then
                UCameraPostEffectMgr:UpdateAmbientOcclusionParam(EAmbientOcclusionType, FAmbientOcclusionParam)
            end
        end
    end
end

--- 设置天气系统tick开关（慎用：关闭了要保证有路径开启）
---@param IsEnable boolean
function LightMgr:SetWeatherTickEnable(IsEnable)
    local UEnvMgr = UE.UEnvMgr:Get()
	if UEnvMgr then
		UEnvMgr:SetTickEnabled(IsEnable)
	end
end

---切换世界场景灯光
---@param IsOn boolean@开灯
function LightMgr:SwitchSceneLights(IsOn)
    local World = GameplayStaticsUtil:GetWorld()
    local UGameplayStatics = UE.UGameplayStatics
    if IsOn then
        if not self.SceneLightCache then
            FLOG_ERROR("[LightMgr]Lights already on")
            return
        end
        for _,Component in pairs(self.SceneLightCache.AllSceneComponents) do
            Component:SetVisibility(true)
        end

        for _,Volume in pairs(self.SceneLightCache.AllPostProcessVolumes) do
            Volume.Enabled = true
        end

        if self.SceneLightCache.IsReflectionActive then
            local TodSystemMainActor = UGameplayStatics.GetActorOfClass(World, UE.ATodSystemMainActor.StaticClass())
            if TodSystemMainActor then
                TodSystemMainActor:SetReflectionActive(true)
            end
        end

        self.SceneLightCache = nil
    else
        if self.SceneLightCache then
            FLOG_ERROR("[LightMgr]Lights already off")
            return
        end
        self.SceneLightCache = {}
        self.SceneLightCache.AllSceneComponents = {}
        self.SceneLightCache.AllPostProcessVolumes = {}
        self.SceneLightCache.IsReflectionActive = false

        local AllHeightFogs = UE.TArray(UE.AActor)
        UGameplayStatics.GetAllActorsOfClass(World, UE.AExponentialHeightFog.StaticClass(), AllHeightFogs)
        for Index = 1, AllHeightFogs:Length() do
            local HeightFog = AllHeightFogs:GetRef(Index)
            if HeightFog.Component.bVisible then
                HeightFog.Component:SetVisibility(false)
                table.insert(self.SceneLightCache.AllSceneComponents, HeightFog.Component)
            end
        end

        local AllSkyLights = UE.TArray(UE.AActor)
        UGameplayStatics.GetAllActorsOfClass(World, UE.ASkyLight.StaticClass(), AllSkyLights)
        for Index = 1, AllSkyLights:Length() do
            local SkyLight = AllSkyLights:GetRef(Index)
            if SkyLight.LightComponent then
                if SkyLight.LightComponent.bVisible then
                    SkyLight.LightComponent:SetVisibility(false)
                    table.insert(self.SceneLightCache.AllSceneComponents, SkyLight.LightComponent)
                end
            end
        end

        local AllDirectionalLights = UE.TArray(UE.AActor)
        UGameplayStatics.GetAllActorsOfClass(World, UE.ADirectionalLight.StaticClass(), AllDirectionalLights)
        for Index = 1, AllDirectionalLights:Length() do
            local DirectionalLight = AllDirectionalLights:GetRef(Index)
            if DirectionalLight.DirectionalLightComponent then
                if DirectionalLight.DirectionalLightComponent.bVisible then
                    DirectionalLight.DirectionalLightComponent:SetVisibility(false)
                    table.insert(self.SceneLightCache.AllSceneComponents, DirectionalLight.DirectionalLightComponent)
                end
            end
        end

        local AllPostProcessVolumes = UE.TArray(UE.AActor)
        UGameplayStatics.GetAllActorsOfClass(World, UE.APostProcessVolume.StaticClass(), AllPostProcessVolumes)
        for Index = 1, AllPostProcessVolumes:Length() do
            local PostProcessVolume = AllPostProcessVolumes:GetRef(Index)
            if PostProcessVolume.bEnabled then
                PostProcessVolume.bEnabled = false
                table.insert(self.SceneLightCache.AllPostProcessVolumes, PostProcessVolume)
            end
        end

        local TodSystemMainActor = UGameplayStatics.GetActorOfClass(World, UE.ATodSystemMainActor.StaticClass())
        if TodSystemMainActor then
            local LightCompList = TodSystemMainActor:K2_GetComponentsByClass(UE.UDirectionalLightComponent)
            for i=1, LightCompList:Length() do
                local LightComp = LightCompList:Get(i)
                if LightComp.bVisible then
                    LightComp:SetVisibility(false)
                    table.insert(self.SceneLightCache.AllSceneComponents, LightComp)
                end
            end
            local SkyCompList = TodSystemMainActor:K2_GetComponentsByClass(UE.USkyAtmosphereComponent)
            for i=1, SkyCompList:Length() do
                local SkyComp = SkyCompList:Get(i)
                if SkyComp.bVisible then
                    SkyComp:SetVisibility(false)
                    table.insert(self.SceneLightCache.AllSceneComponents, SkyComp)
                end
            end

            self.SceneLightCache.IsReflectionActive = TodSystemMainActor:IsReflectionActive()
            if self.SceneLightCache.IsReflectionActive then
                TodSystemMainActor:SetReflectionActive(false)
            end
        end
    end
end

---记录当前开启的灯光预设，仅编辑器使用
function LightMgr:RecordLightPreset(SceneActor, LightPreset)
	if not CommonUtil.IsWithEditor() then
		return
	end
	self.SceneActor = SceneActor
	self.CurrentLightPreset = LightPreset
	if nil == self.LightPresetProxy or not CommonUtil.IsObjectValid(self.LightPresetProxy) then
		self.LightPresetProxy =
			CommonUtil.SpawnActor(UE.AFMLightPresetProxy, UE.FVector(0, 0, 0), UE.FRotator(0, 0, 0))
	end
	self.LightPresetProxy.LightPresetPath = UE.UKismetSystemLibrary.GetPathName(LightPreset)
end

function LightMgr:DisableCurrentLightPreset()
	if nil == self.SceneActor or not CommonUtil.IsObjectValid(self.LightPresetProxy) then
		self.SceneActor = nil
		return
	end
	local LightComps = self.SceneActor:K2_GetComponentsByClass(UE.ULightComponent)
	for Index = 1, LightComps:Length() do
		local LightComp = LightComps:GetRef(Index)
		LightComp:SetVisibility(false)
	end
end

-- ==================================================
-- 调试信息 只有editor下执行
-- ==================================================

function LightMgr:PrintBluePrint(Path, Para1, Para2, Para3)
    self.MsgBluePrint = string.format("%s %s %s %s", tostring(Path), tostring(Para1), tostring(Para2), tostring(Para3))
    self:Print()
end

function LightMgr:PrintLightLevel(Path)
    self.MsgLightLevel = Path
    self:Print()
end

function LightMgr:PrintLightPreset(Path)
    self.MsgLightPreset = Path
end

function LightMgr:Print()
    if self.PrintTimerID then
        return
    end
    self.PrintTimerID = self:RegisterTimer(self.OnTimePrint, 1)
end

function LightMgr:ClearPrint()
    self.MsgBluePrint = nil
    self.MsgLightLevel = nil
    self.MsgLightPreset = nil
end

function LightMgr:OnTimePrint()
    self.PrintTimerID = nil
    FLOG_INFO("----------------------------TOD切换配置信息----------------------------")
    FLOG_INFO("当前TOD加载参数蓝图路径："..tostring(self.MsgBluePrint))
    FLOG_INFO("当前灯光关卡加载名称+路径："..tostring(self.MsgLightLevel))
    FLOG_INFO("当前灯光预设加载名称+路径："..tostring(self.MsgLightPreset))
    self:ClearPrint()
end

return LightMgr