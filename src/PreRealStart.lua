--这里和游戏逻辑没有直接关系，先于游戏逻辑执行的
require("LuaDebug")
local SaveKey = require("Define/SaveKey")
local Priority = 0x01000000
local PriorityConsole = 0x09000000


_G.PreRealStart =
{

}

_G.PreRealStart.PerformanceRenderCmdConfig = {    -- Params: 中、高、极高；低和极低都按中这一档设置
    --视口距离
    -- {Cmd = "r.ViewDistanceScale",       Fmt = " %f",  Params = {0.9, 0.9, 0.9}, PMID = SaveKey.PM_ViewDistanceScale,    LstID = SaveKey.Lst_ViewDistanceScale, IsFloat = true},

    --抗锯齿
    {Cmd = "r.PostProcessAAQuality",    Fmt = " %d",  Params = {0, 0, 0},       PMID = SaveKey.PM_PostProcessAAQuality, LstID = SaveKey.Lst_PostProcessAAQuality},

    --阴影质量
    {Cmd = "r.Shadow.MaxCSMResolution", Fmt = " %d", Params = {1024, 1024, 1024}, PMID = SaveKey.PM_MaxCSMResolution,   LstID = SaveKey.Lst_MaxCSMResolution},
    {Cmd = "r.ShadowQuality",           Fmt = " %d", Params = {3, 3, 3},        PMID = SaveKey.PM_ShadowQuality,        LstID = SaveKey.Lst_ShadowQuality},
    {Cmd = "r.AOQuality",               Fmt = " %d", Params = {0, 0, 0},        PMID = SaveKey.PM_AOQuality,            LstID = SaveKey.Lst_AOQuality},
    {Cmd = "r.Mobile.FarShadowMapEnable", Fmt = " %d", Params = {0, 0, 0},      PMID = SaveKey.PM_FarShadowMapEnable,   LstID = SaveKey.Lst_FarShadowMapEnable},
    {Cmd = "r.Mobile.HDSelfShadowMapEnable", Fmt = " %d", Params = {0, 0, 0},   PMID = SaveKey.PM_HDSelfShadowMapEnable, LstID = SaveKey.Lst_HDSelfShadowMapEnable},
    {Cmd = "r.Mobile.EnableSpotLightShadowResolutionRate", Fmt = " %d", Params = {0, 0, 0},   PMID = SaveKey.PM_SpotLightShadowResolutionRate, LstID = SaveKey.Lst_SpotLightShadowResolutionRate},

    --后处理
    {Cmd = "r.Tonemapper.Quality",      Fmt = " %d", Params = {2, 2, 2},        PMID = SaveKey.PM_TonemapperQuality,    LstID = SaveKey.Lst_TonemapperQuality},
    {Cmd = "r.DepthOfFieldQuality",     Fmt = " %d", Params = {0, 0, 0},        PMID = SaveKey.PM_DepthOfFieldQuality,  LstID = SaveKey.Lst_DepthOfFieldQuality},
    {Cmd = "r.LightShaftQuality",       Fmt = " %d", Params = {0, 0, 0},        PMID = SaveKey.PM_LightShaftQuality,    LstID = SaveKey.Lst_LightShaftQuality},

    --分辨率
    {Cmd = "r.ScreenPercentage",        Fmt = " %d", Params = {75, 75, 75},     PMID = SaveKey.PM_ScreenPercentage,     LstID = SaveKey.Lst_ScreenPercentage, Priority = PriorityConsole},--ECVF_SetByConsole
    --帧率
    {Cmd = "t.maxfps",                  Fmt = " %d", Params = {30, 30, 30},     PMID = SaveKey.PM_Maxfps,               LstID = SaveKey.Lst_Maxfps},
}

local DefauleValueNotSave = -999999

--执行FGameInstance  RealStart之前的逻辑
function PreRealStart.OnPreRealStart()
    local IsWithEmulatorMode = _G.UE.UUIMgr.Get():IsWithEmulator()
    print("==== PreRealStart.OnPreRealStart IsWithEmulatorMode:" .. tostring(IsWithEmulatorMode))
    
    local USaveMgr = _G.UE.USaveMgr
    local USettingUtil = _G.UE.USettingUtil

    local LastFxaa = USaveMgr.GetInt(SaveKey.Fxaa, DefauleValueNotSave, false)
    local FxaaToSet = 0
    if LastFxaa < 0 then    --默认模拟器下才开启，然后就看玩家设置了
        if IsWithEmulatorMode then
            FxaaToSet = 1
        end
    else
        if LastFxaa == 2 then
            FxaaToSet = 1
        end
    end
    print("PreRealStart r.DefaultFeature.AntiAliasing:" .. FxaaToSet .. " LastFxaa:" .. LastFxaa)
    USettingUtil.ExeCommand("r.DefaultFeature.AntiAliasing", FxaaToSet, 0x09000000) --ECVF_SetByConsole
    
    if _G.UE.UPlatformUtil.IsWithEditor() then
        print("==== PreRealStart.OnPreRealStart IsWithEditor ====")
        --省电模式ui的时候stop游戏，重新play 需要恢复下原来的分辨率、帧率
        local ValueToSet = USaveMgr.GetInt(SaveKey.ScaleFactor, -1, false)
        if ValueToSet >= 0 then
            if ValueToSet < 75 then
                ValueToSet = 75
            end

            if ValueToSet > 100 then
                ValueToSet = 100
            end

            USettingUtil.ExeCommand("r.ScreenPercentage", ValueToSet, PriorityConsole)
        end

        return
    end
    
    local LastQualityLevel = USaveMgr.GetInt(SaveKey.LastQualityLevel, DefauleValueNotSave, false)

    local function OverrideBeastFeatures()
        PreRealStart.OverrideSetOnEmulator(7, 4, 4)                 --植被
        PreRealStart.OverrideSetOnEmulator(5, 4, 4)                 --贴图品质
        PreRealStart.OverrideSetOnEmulator(3, 4, 3)                 --阴影质量
        PreRealStart.OverrideSetOnEmulator(8, 4, 4)                 --贴图品质
        PreRealStart.OverrideSetOnEmulator(0, 4, 4)                 --方案是5的情况（极高）
    end

    --0~4   -1:没配置
    local DefaultQualityLevel = USettingUtil.GetDefaultQualityLevel()
    local SavedDefaultQualityLevel = USaveMgr.GetInt(SaveKey.DefaultQualityLevel, -2, false)
    print("DefaultQualityLevel:" .. DefaultQualityLevel .. " SavedDefaultQualityLevel:" .. SavedDefaultQualityLevel)
    --如果没有对机器定级，也就是没有默认配置，等热更配置的时候，重新按DefaultQualityLevel处理一遍
    if SavedDefaultQualityLevel == -1 and DefaultQualityLevel >= 0
        or SavedDefaultQualityLevel >= 0 and SavedDefaultQualityLevel ~= DefaultQualityLevel then
        USettingUtil.SetQualityLevel(DefaultQualityLevel)
        print("!!!!!!!!! setting HotReloadQualityLevel : " .. DefaultQualityLevel)
        PreRealStart.RefreshPerformanceParams()
        return
    end


    local QualityLevel = USaveMgr.GetInt(SaveKey.QualityLevel, DefauleValueNotSave, false)
    print("QualityLevel:" .. tostring(QualityLevel))
    if QualityLevel >= 1 and QualityLevel < 6 then
        -- 6是自定义，所以跳过这里，使用下面的设置          模拟器下6是极致，得设置4
        -- -1是没保存过，走下面的，会使用默认的
        USettingUtil.SetQualityLevel(QualityLevel - 1)
        PreRealStart.RefreshPerformanceParams()

        return
    elseif IsWithEmulatorMode and QualityLevel == 6 then
        USettingUtil.SetQualityLevel(4)
        OverrideBeastFeatures()

        return
    end

	-- AntiAliasingQuality = 10105,	--抗锯齿--废弃，不开放这个了；   新增了一个放入到其他和画质不绑定的抗锯齿了
    local ValueToSet = USaveMgr.GetInt(SaveKey.ShadowQuality, -1, false)
    print("3ShadowQuality:" .. tostring(ValueToSet))
    if ValueToSet < 0 then
        print("No SaveKey Data, Use Default")
        
        return
    end
    -- USettingUtil.SetSGFeaturesLevel(2, ValueToSet)

	-- ShadowQuality = 10106,	--
    -- ValueToSet = USaveMgr.GetInt(SaveKey.ShadowQuality, -1, false)
    print("3ShadowQuality:" .. tostring(ValueToSet))
    if ValueToSet >= 0 then
        USettingUtil.SetSGFeaturesLevel(3, ValueToSet)
        if IsWithEmulatorMode and LastQualityLevel == 6 then
            PreRealStart.OverrideSetOnEmulator(3, ValueToSet, 3)                 --阴影质量
        end
    end
	-- PostProcessQuality = 10107,
    ValueToSet = USaveMgr.GetInt(SaveKey.PostProcessQuality, -1, false)
    print("4PostProcessQuality:" .. tostring(ValueToSet))
    if ValueToSet >= 0 then
        USettingUtil.SetSGFeaturesLevel(4, ValueToSet)
    end
	-- TextureQuality = 10108,	--
    ValueToSet = USaveMgr.GetInt(SaveKey.TextureQuality, -1, false)
    print("5TextureQuality:" .. tostring(ValueToSet))
    if ValueToSet >= 0 then
        USettingUtil.SetSGFeaturesLevel(5, ValueToSet)
        if IsWithEmulatorMode and LastQualityLevel == 6 then
            PreRealStart.OverrideSetOnEmulator(5, ValueToSet, 4)                 --贴图品质
        end
    end
	-- EffectQuality = 10109,	--特效质量
    ValueToSet = USaveMgr.GetInt(SaveKey.EffectQuality, -1, false)
    print("6EffectQuality:" .. tostring(ValueToSet))
    if ValueToSet >= 0 then
        USettingUtil.SetSGFeaturesLevel(6, ValueToSet)
    end
	-- FoliageQuality = 10110,	--植被
    ValueToSet = USaveMgr.GetInt(SaveKey.FoliageQuality, -1, false)
    print("7FoliageQuality:" .. tostring(ValueToSet))
    if ValueToSet >= 0 then
        USettingUtil.SetSGFeaturesLevel(7, ValueToSet)
        if IsWithEmulatorMode and LastQualityLevel == 6 then
            PreRealStart.OverrideSetOnEmulator(7, ValueToSet, 2)                 --植被
        end
    end
	-- ScaleFactor = 10111,	--分辨率 r.ScreenPercentage
    
    local CurScreenPercent = _G.UE.UKismetSystemLibrary.GetConsoleVariableIntValue("r.ScreenPercentage")
    print("8r.ScreenPercentage:" .. CurScreenPercent)
    ValueToSet = USaveMgr.GetInt(SaveKey.ScaleFactor, -1, false)
    print("8ValueToSet:" .. tostring(ValueToSet))
    if ValueToSet >= 0 then
        if ValueToSet < 75 then
            ValueToSet = 75
        end

        if ValueToSet > 100 then
            ValueToSet = 100
        end

        -- local Cmd = string.format("r.ScreenPercentage %d", ValueToSet)
        -- _G.UE.UKismetSystemLibrary.ExecuteConsoleCommand(_G.UE.UFGameInstance.Get():GetWorld(), Cmd, nil)
        USettingUtil.ExeCommand("r.ScreenPercentage", ValueToSet, PriorityConsole)
        if IsWithEmulatorMode and LastQualityLevel == 6 then
            PreRealStart.OverrideSetOnEmulator(8, ValueToSet, 100)                 --分辨率
        end
        CurScreenPercent = _G.UE.UKismetSystemLibrary.GetConsoleVariableIntValue("r.ScreenPercentage")
        print("8 config r.ScreenPercentage:" .. CurScreenPercent)
    end
    
    if IsWithEmulatorMode and LastQualityLevel == 6 then
        PreRealStart.OverrideSetOnEmulator(0, 4, 4)
    end

    PreRealStart.RefreshPerformanceParams()
end

--在正常设置后，模拟器上可能会重置些 特性
-- 2到8是CachePicSetting过来的（登录的时候立即，再或者是关闭设置界面的时候）
-- 其他没有经过CachePicSetting的，得要自己额外专门调用，这有两种（有设置项的，没设置项的）
    --有设置项的：角色数量、角色lod、
    --没有设置项的：texturestraming、场景lod、植被lod、
function PreRealStart.OverrideSetOnEmulator(FeatureID, ValueToSet, MaxLvlValue)
    local bNeedBetter = false
    local QualityLevel = _G.UE.USaveMgr.GetInt(SaveKey.QualityLevel, DefauleValueNotSave, false)
    if QualityLevel == 6 then
        bNeedBetter = true
    elseif QualityLevel == 7 then
        local LastQualityLevel = _G.UE.USaveMgr.GetInt(SaveKey.LastQualityLevel, DefauleValueNotSave, false)
        if QualityLevel == 7 and LastQualityLevel == 6 and ValueToSet >= MaxLvlValue then
            bNeedBetter = true
        end
    end
    
    if bNeedBetter then    --QualityLevel == 7标识自定义
        if FeatureID == 7 then  --7 植被质量
            _G.UE.USettingUtil.ExeCommand("r.Mobile.ScreenMaxLocalLightNum", 9999)  --灯光上限
            _G.UE.USettingUtil.ExeCommand("r.ViewDistanceScale", 10)                --距离剔除
            _G.UE.USettingUtil.ExeCommand("grass.CullDistanceScale", 10)
        elseif FeatureID == 5 then  --5 贴图品质
            _G.UE.USettingUtil.ExeCommand("r.MaxAnisotropy", 16)                    --各项异性
        elseif FeatureID == 3 then  --3 阴影质
            _G.UE.USettingUtil.ExeCommand("r.Shadow.MaxCSMResolution", 4096)        --阴影分辨率
        elseif FeatureID == 8 then  --8 分辨率
            _G.UE.USettingUtil.ExeCommand("r.MobileContentScaleFactor", 0)        --分辨率 原生
        -- elseif FeatureID == 15 then  --15 角色Lod
        --     _G.UE.USettingUtil.ExeGameViewportCmd(string.format("FORCESKELLOD LOD=%d", 0))
        elseif FeatureID == 0 then  --0 方案是5，或者自定义方案的时候，上一次的方案是5
            -- _G.UE.USettingUtil.ExeCommand("r.ForceLOD", 0)                          --场景LOD
            -- _G.UE.USettingUtil.ExeCommand("foliage.ForceLOD", 0)                    --植被LOD
            _G.UE.USettingUtil.ExeCommand("r.TextureStreaming", 1)                  --TextureStreaming
        end
    else
        if FeatureID == 0 then  --关闭
            -- _G.UE.USettingUtil.ExeCommand("r.ForceLOD", -1)          --场景LOD
            -- _G.UE.USettingUtil.ExeCommand("foliage.ForceLOD", -1)   --植被LOD
            _G.UE.USettingUtil.ExeCommand("r.TextureStreaming", 0)  --TextureStreaming
        end
    end

    return bNeedBetter
end

function PreRealStart.IsCanPerformanceMode()
    --0~4   -1:没配置
    local DefaultQualityLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
    if DefaultQualityLevel <= 1 then
        return -1
    end
    
	local Platform = _G.UE.UGameplayStatics.GetPlatformName()
	if Platform == "IOS" then
        return -5
    end

    local IsWithEmulatorMode = _G.UE.UUIMgr.Get():IsWithEmulator()
    if IsWithEmulatorMode then
        return -2
    end

    local PerformanceMode = _G.UE.USaveMgr.GetInt(SaveKey.PerformanceMode, -1, false)
    print("PerformanceMode:" .. tostring(PerformanceMode))
    if PerformanceMode <= 1 then    -- 1 关闭   2：开启   -1第一次刚启动
        return -3
    end

    --0~4
    local SelectQualityLevel = _G.UE.USaveMgr.GetInt(SaveKey.SelectQualityLevel, -1, false)
    print("==== PreRealStart RefreshPerformance Lvl: " .. tostring(SelectQualityLevel))
    if SelectQualityLevel <= 1 then
        return -4
    end

    return 0
end

function PreRealStart.RefreshPerformanceParams()
    local Rlt = PreRealStart.IsCanPerformanceMode()
    if Rlt < 0 then
        print("==== PreRealStart no PerformanceMod " .. tostring(Rlt))
        return 
    end

    print("============ PreRealStart RefreshPerformance ===============")

    local USaveMgr = _G.UE.USaveMgr
    local USettingUtil = _G.UE.USettingUtil

    local CurWorld = _G.UE.UFGameInstance.Get():GetWorld()
    local RenderConfigs = PreRealStart.PerformanceRenderCmdConfig
    for _, Config in ipairs(RenderConfigs) do
        local Value = -1
        if Config.IsFloat then
            Value = USaveMgr.GetFloat(Config.PMID, -1, false)
        else
            Value = USaveMgr.GetInt(Config.PMID, -1, false)
        end

        if Value >= 0 then
            local CmdFmt = string.format("%s%s", Config.Cmd, Config.Fmt)
            local CmdStr = string.format( CmdFmt, Value)
            print(CmdStr)
            if Config.IsFloat then
                _G.UE.UKismetSystemLibrary.ExecuteConsoleCommand(CurWorld, CmdStr, nil)
            elseif Config.Priority then
                USettingUtil.ExeCommand(Config.Cmd, Value, Config.Priority)
            else
                USettingUtil.ExeCommand(Config.Cmd, Value, Priority)
            end
        end
    end
end