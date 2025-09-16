
local EffectUtil = require("Utils/EffectUtil")
local SettingsUtils = require("Game/Settings/SettingsUtils")
local CommonDefine = require("Define/CommonDefine")
local CommonUtil = require("Utils/CommonUtil")
local SaveKey = require("Define/SaveKey")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local SettingsVM = require("Game/Settings/VM/SettingsVM")

--画面设置

local LightsNum = {0, 4, 8, 8888}       --灯光品质
local ScaleParams = {0.8, 1.0, 1.5}     --缩放系数
local Priority = 0x01000000
local PriorityConsole = 0x09000000


local SettingsTabPicture = {}

function SettingsTabPicture:OnInit()
    self.ScalabilityFeatureSettings = {}    --引擎Scalablity里和画质等级关联的那几个特性
    self.PictureFeatureSettings = {}        --和画质等级关联的，但不是Scalability里的那几个特性
end

function SettingsTabPicture:OnBegin()
end

function SettingsTabPicture:OnEnd()

end

function SettingsTabPicture:OnShutdown()
    self.PictureFeatureSettings = {}
    self.ScalabilityFeatureSettings = {}
end

----------------------------------  战斗特效 -----------------------------------------------
---自己的战斗特效
function SettingsTabPicture:SetCombatFXSelf( Value, IsSave )
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    self[FieldName] = SettingsUtils.GetDropDownListNumValue(Value, 0)
    EffectUtil.SetCombatFXLOD(self[FieldName], 0)
end

---小队的战斗特效
function SettingsTabPicture:SetCombatFXTeam( Value, IsSave )
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    self[FieldName] = SettingsUtils.GetDropDownListNumValue(Value, 0)
    EffectUtil.SetCombatFXLOD(self[FieldName], 1)
end

---其他玩家的战斗特效
function SettingsTabPicture:SetCombatFXPlayer( Value, IsSave )
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    self[FieldName] = SettingsUtils.GetDropDownListNumValue(Value, 0)
    EffectUtil.SetCombatFXLOD(self[FieldName], 2)
end

---敌对玩家的战斗特效
function SettingsTabPicture:SetCombatFXEnemy( Value, IsSave )
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    self[FieldName] = SettingsUtils.GetDropDownListNumValue(Value, 0)
    EffectUtil.SetCombatFXLOD(self[FieldName], 3)
end

----------------------------------  画面品质 -----------------------------------------------
--- SaveKey保存的是Index，而GetValue获取的是Index 
---
---预设方案
function SettingsTabPicture:GetQualityLevel()
    local QualityLevel = _G.UE.USaveMgr.GetInt(SaveKey.QualityLevel, _G.SettingsMgr.DefauleValueNotSave, false)
    if QualityLevel > 0 then
        FLOG_INFO("##Setting GetQualityLevelIdx %d", QualityLevel)
        return QualityLevel
    end

    local Level = _G.UE.USettingUtil.GetCurQualityLevel()
    FLOG_INFO("##Setting GetQualityLevel0 %d", Level)

    if Level < 0 then
        return SettingsMgr.CustomQualityIndex
    end

    return Level + 1
end

--客户端启动的时候，不用USettingUtil.SetQualityLevel；其下各个特性自己去set
--只有主动选择的切换画质，需要set
function SettingsTabPicture:SetQualityLevel( Value, IsSave , IsLoginInit, IsBySelect)
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    local Level = SettingsUtils.GetDropDownListNumValue(Value, 3)

    local IsWithEmulatorMode = _G.SettingsMgr.IsWithEmulatorMode
    local bNeedRefreshUI = false
    local LastSelectLevel = _G.UE.USaveMgr.GetInt(SaveKey.SelectQualityLevel, -1, false)
    if IsBySelect then  --从方案的下拉列表是选择不了自定义的；  而且选择了极低-极高/极致，就会去掉自定义
        local SelectLevel = Value - 1
        if IsWithEmulatorMode and Value == 6 then
            SelectLevel = 4
        end

        _G.UE.USaveMgr.SetInt(SaveKey.SelectQualityLevel, SelectLevel, false)
        FLOG_INFO("Setting SelectQualityLevel %d, LastSelectLevel:%d", SelectLevel, LastSelectLevel)

        if LastSelectLevel >= 2 and SelectLevel <= 1 or LastSelectLevel <= 1 and SelectLevel >= 2 then
            bNeedRefreshUI = true
        end

        if IsWithEmulatorMode then
            bNeedRefreshUI = false
        end
    end

    if IsWithEmulatorMode then
        if Value == 6 then
            Level = 4
        elseif Value == 7 then
            Level = -1
        end
    end
    self[FieldName] = Level
    FLOG_INFO("##Setting SetQualityLevel %d IsLoginInit:%s", Level, tostring(IsLoginInit))

    if not IsLoginInit then
        self.bSelectQualityLevelChanging = true
        --自定义的时候Level是-1，Util里会跳过，不会设置到引擎里
        local bLevelChg = self:GetQualityLevel() ~= Value
        _G.SettingsMgr:CacheQulityLevelSetting(Level)
        if bLevelChg then
            for _, ScalabilityFeatureSettingCfg in pairs(self.ScalabilityFeatureSettings) do
                --传给0-4的画质等级，而不是Index
                _G.SettingsMgr:SetValueBySaveKey(ScalabilityFeatureSettingCfg.SaveKey, Level, true)
            end

            for _, PictureFeatureSettingCfg in pairs(self.PictureFeatureSettings) do
                --传给0-4的画质等级，而不是Index
                _G.SettingsMgr:SetValueBySaveKey(PictureFeatureSettingCfg.SaveKey, Level, true)
            end
            
            --帧率，不和画质绑定的，手动修改是立即生效的，所以不能等到关闭界面再变，得是立即生效
            if _G.SettingsMgr:IsIosHightDevice() then
                if Level <= 2 then
                    FLOG_INFO("setting maxfps = 25")
                    _G.SettingsMgr:SetValueBySaveKey("MaxFPS", 2, true)
                    _G.SettingsMgr:SetSGFeaturesLevel(23, 25)
                else
                    local MaxFps = _G.UE.UKismetSystemLibrary.GetConsoleVariableIntValue("t.maxfps")
                    FLOG_INFO("setting get maxfps = %d", MaxFps)
                    if MaxFps == 25 then
                        _G.SettingsMgr:SetSGFeaturesLevel(23, 30)
                    end
                end
            end
        end

        self.bSelectQualityLevelChanging = false
        
        if IsSave then
            --存的是Index 1-6，而不是0-4，-1
            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], Value, false)
            _G.UE.USaveMgr.SetInt(SaveKey.LastQualityLevel, Value, false)
        end
        --上面的SetValueBySaveKey会造成触发OnePictureFeatureChg，变成自定义
        --下面会再重新修改为对应画质等级
        _G.EventMgr:SendEvent(_G.EventID.QualityLevelChg, Level, Value)
    else
        FLOG_INFO("##Setting SetQualityLevel %d LastSelectLevel:%d, bIosHighDevice:%s", Level, LastSelectLevel, tostring(_G.SettingsMgr:IsIosHightDevice()))
        if _G.SettingsMgr:IsIosHightDevice() then
            _G.SettingsMgr:RefreshIosHightDeviceParamsByQualityLvl(LastSelectLevel)
        end

        --客户端启动的时候，不用USettingUtil.SetQualityLevel；其下各个特性自己去set
        --非登录的时候会重启，所以登录的时候重写下设置就好了(所以不用管Value == 5的情况)
        if IsSave then
            --存的是Index 1-6，而不是0-4，-1
            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], Value, false)
            _G.UE.USaveMgr.SetInt(SaveKey.LastQualityLevel, Value, false)
        end

        if SettingsMgr.IsWithEmulatorMode then
            local LastQualityLevel = _G.UE.USaveMgr.GetInt(SaveKey.LastQualityLevel, _G.SettingsMgr.DefauleValueNotSave, false)
            FLOG_INFO("setting OverrideSet NoSettingItem Feature, LastQualityLevel:%d, Value:%d", LastQualityLevel, Value)
            if Value == 6 and not IsBySelect or LastQualityLevel == _G.SettingsMgr.DefauleValueNotSave or LastQualityLevel == 6 then
                self:OverrideSetOnEmulator(0, 5, IsLoginInit, IsBySelect, 5)
            else
                self:OverrideSetOnEmulator(0, 1, IsLoginInit, IsBySelect, 5)
            end
        end
    end

    if bNeedRefreshUI then    --刷新性能模式按钮的显隐
        SettingsVM:UpdateItemList(true)
    end

    --FLOG_INFO("SettingsTabPicture:SetQualityLevel, XXXXXXXXXXXXXXXXXXXXXXXXXX, Value:%d", Value)
    CommonUtil.SetQuality()
    CommonUtil.ReportQualityLevel()
    --SettingsUtils不用再SetInt了
    return true
end

function SettingsTabPicture:GetDefaultQualityLevelIndex()
    --0~4
    local DefaultLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
    if DefaultLevel < 0 then
        DefaultLevel = 0
    end
    
    _G.UE.USaveMgr.SetInt(SaveKey.SelectQualityLevel, DefaultLevel, false)
    -- FLOG_INFO("##Setting Get Default QualityLevel %d", DefaultLevel)
    return DefaultLevel + 1
end

function SettingsTabPicture:GetDefaultQualityLevel()
    --0~4   -1:没配置
    local DefaultLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
    FLOG_INFO("##Setting Get Default QualityLevel %d", DefaultLevel)
    
    if DefaultLevel < 0 then
        DefaultLevel = 0
    end
    
    return DefaultLevel
end

--得要配置SwitchTips才会进行check
function SettingsTabPicture:SwitchQualityLevelCheck(Value)
    local DefaultLevel = self:GetDefaultQualityLevel()
    local TargetLevel = SettingsUtils.GetDropDownListNumValue(Value, -2)
    
    if SettingsMgr.IsWithEmulatorMode then
        if TargetLevel < 0 then
            return false, false
        end
    else
        if TargetLevel < 0 then
            return false, false
        elseif TargetLevel > DefaultLevel then
            return false, true
        end
    end

    return true, false
end

function SettingsTabPicture:CacheScalabilityFeatures()
    local CurSettingID = SettingsUtils.CurSetingCfg.ID
    if not self.ScalabilityFeatureSettings[CurSettingID] then
        self.ScalabilityFeatureSettings[CurSettingID] = SettingsUtils.CurSetingCfg
    end
end

function SettingsTabPicture:CachePictureFeatures()
    local CurSettingID = SettingsUtils.CurSetingCfg.ID
    if not self.PictureFeatureSettings[CurSettingID] then
        self.PictureFeatureSettings[CurSettingID] = SettingsUtils.CurSetingCfg
    end
end

--1 ViewDistance没有暴露出来，但跟随画质等级变化

--2 抗锯齿 --   现在废弃，独立出去了 SettingsTabPicture:SetFxaa
--Value是下拉框的index
    --IsBySelect ：                 是手动选择下拉框
    --if IsLoginInit and IsSave：   第一次进入获取默认Index、下拉框选择的时候
--其他情况Value是画质等级0-4
    --比如下次重新登录，SaveInt已经有了，只需要取出来Set过来就好了   （对于IsScalabilityFeature的，SettingsItemView也会转换成Index）
function SettingsTabPicture:SetAntiAliasing(Value, IsSave , IsLoginInit, IsBySelect)
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey

    local ConfigValue = -1
    local ValueToSet = -1

    --if Value是Index
    if IsLoginInit and IsSave or IsBySelect then
        ConfigValue = SettingsUtils.GetDropDownListNumValue(Value, 0)
        ValueToSet = ConfigValue

        if IsSave then  --走到这里必然是true，都是要保存的
            if IsLoginInit then
                local DefaultLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
                if DefaultLevel == -1 then  -- -1:没配置
                    ValueToSet = 0
                end
            end

            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    else
        ValueToSet = Value
        if IsSave then
            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    end

    self:CacheScalabilityFeatures()

    FLOG_INFO("##Setting SetAntiAliasing Idx:%d, ConfigValue:%d ValueToSet:%d", Value, ConfigValue, ValueToSet)
    -- if not IsLoginInit then
        --启动客户端的时候自动设置过了的
        if ValueToSet >= 0 and ValueToSet <= 4 then
            self[FieldName] = ValueToSet

            local MaxLvlValue = self:GetMaxLvlValue(3)
            if IsLoginInit and ValueToSet == self:GetDefaultQualityLevel() then
                self:OnOneFeatureChanged(2, IsLoginInit, IsBySelect)
            else
                _G.SettingsMgr:CachePicSetting(2, ValueToSet, IsLoginInit, IsBySelect, MaxLvlValue)
                -- CommonUtil.ConsoleCommand(string.format("sg.AntiAliasingQuality %d", self[FieldName]))
            end
        end
    -- end

    --FLOG_INFO("SettingsTabPicture:SetAntiAliasing, XXXXXXXXXXXXXXXXXXXXXXXXXX, Value:%d", Value)
    CommonUtil.ReportAntiAliasingQuality()
    --SettingsUtils不用再SetInt了
    return true
end

--SetFuc***的时候使用
function SettingsTabPicture:GetMaxLvlValue(DefaultValue)
    local MaxLvlValue = DefaultValue
    if SettingsUtils.CurSetingCfg and SettingsUtils.CurSetingCfg.Num then
        local Cnt = #SettingsUtils.CurSetingCfg.Num
        MaxLvlValue = SettingsUtils.CurSetingCfg.Num[Cnt]
    end

    return MaxLvlValue
end

function SettingsTabPicture:GetDefaultAntiAliasingIndex()
    local DefaultLevel = self:GetDefaultQualityLevel()    --0-4
    local DefaultIndex = SettingsUtils.GetDropDownListIndex(DefaultLevel, SettingsUtils.CurSetingCfg)
    return DefaultIndex
end

--3 阴影质量
--Value是下拉框的index
    --IsBySelect ：                 是手动选择下拉框
    --if IsLoginInit and IsSave：   第一次进入获取默认Index、下拉框选择的时候
--其他情况Value是画质等级0-4
    --比如下次重新登录，SaveInt已经有了，只需要取出来Set过来就好了   （对于IsScalabilityFeature的，SettingsItemView也会转换成Index）
function SettingsTabPicture:SetShadowQuality(Value, IsSave , IsLoginInit, IsBySelect)
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey

    local ConfigValue = -1
    local ValueToSet = -1

    --if Value是Index
    if IsLoginInit and IsSave or IsBySelect then
        ConfigValue = SettingsUtils.GetDropDownListNumValue(Value, 0)
        ValueToSet = ConfigValue

        if IsSave then  --走到这里必然是true，都是要保存的
            if IsLoginInit then
                local DefaultLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
                if DefaultLevel == -1 then  -- -1:没配置
                    ValueToSet = 0
                end
            end

            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    else
        ValueToSet = Value
        if IsSave then
            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    end

    self:CacheScalabilityFeatures()
    FLOG_INFO("##Setting SetShadowQuality Idx:%d, ConfigValue:%d ValueToSet:%d", Value, ConfigValue, ValueToSet)
    -- if not IsLoginInit then
        --启动客户端的时候自动设置过了的
        if ValueToSet >= 0 and ValueToSet <= 4 then
            self[FieldName] = ValueToSet

            local MaxLvlValue = self:GetMaxLvlValue(3)
            if IsLoginInit and ValueToSet == self:GetDefaultQualityLevel() then
                self:OverrideSetOnEmulator(3, ValueToSet, IsLoginInit, IsBySelect, MaxLvlValue)
                self:OnOneFeatureChanged(3, IsLoginInit, IsBySelect)
            else
                _G.SettingsMgr:CachePicSetting(3, ValueToSet, IsLoginInit, IsBySelect, MaxLvlValue)
                -- CommonUtil.ConsoleCommand(string.format("sg.ShadowQuality %d", self[FieldName]))
            end
        end
    -- end

    --FLOG_INFO("SettingsTabPicture:SetShadowQuality, XXXXXXXXXXXXXXXXXXXXXXXXXX, Value:%d", Value)
    CommonUtil.ReportShadowQuality()
    --SettingsUtils不用再SetInt了
    return true
end

function SettingsTabPicture:GetDefaultShadowIndex()
    local DefaultLevel = self:GetDefaultQualityLevel()
    local DefaultIndex = SettingsUtils.GetDropDownListIndex(DefaultLevel, SettingsUtils.CurSetingCfg)

    return DefaultIndex
end

--4 后期渲染
function SettingsTabPicture:SetPostProcess(Value, IsSave , IsLoginInit, IsBySelect)
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey

    local ConfigValue = -1
    local ValueToSet = -1

    --if Value是Index
    if IsLoginInit and IsSave or IsBySelect then
        ConfigValue = SettingsUtils.GetDropDownListNumValue(Value, 0)
        ValueToSet = ConfigValue

        if IsSave then  --走到这里必然是true，都是要保存的
            if IsLoginInit then
                local DefaultLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
                if DefaultLevel == -1 then  -- -1:没配置
                    ValueToSet = 0
                end
            end

            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    else
        ValueToSet = Value
        if IsSave then
            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    end

    self:CacheScalabilityFeatures()
    FLOG_INFO("##Setting SetPostProcess Idx:%d, ConfigValue:%d ValueToSet:%d", Value, ConfigValue, ValueToSet)
    -- if not IsLoginInit then
        --启动客户端的时候自动设置过了的
        if ValueToSet >= 0 and ValueToSet <= 4 then
            self[FieldName] = ValueToSet

            local MaxLvlValue = self:GetMaxLvlValue(3)
            if IsLoginInit and ValueToSet == self:GetDefaultQualityLevel() then
                self:OnOneFeatureChanged(4, IsLoginInit, IsBySelect)
            else
                -- CommonUtil.ConsoleCommand(string.format("sg.PostProcessQuality %d", self[FieldName]))
                _G.SettingsMgr:CachePicSetting(4, ValueToSet, IsLoginInit, IsBySelect, MaxLvlValue)
            end


        end
    -- end

    --SettingsUtils不用再SetInt了
    return true
end

function SettingsTabPicture:GetDefaultPostProcessIndex()
    local DefaultLevel = self:GetDefaultQualityLevel()
    local DefaultIndex = SettingsUtils.GetDropDownListIndex(DefaultLevel, SettingsUtils.CurSetingCfg)

    return DefaultIndex
end

--5 贴图品质
function SettingsTabPicture:SetTextureQuality(Value, IsSave , IsLoginInit, IsBySelect)
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey

    local ConfigValue = -1
    local ValueToSet = -1

    --if Value是Index
    if IsLoginInit and IsSave or IsBySelect then
        ConfigValue = SettingsUtils.GetDropDownListNumValue(Value, 0)
        ValueToSet = ConfigValue

        if IsSave then  --走到这里必然是true，都是要保存的
            if IsLoginInit then
                local DefaultLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
                if DefaultLevel == -1 then  -- -1:没配置
                    ValueToSet = 0
                end
            end

            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    else
        ValueToSet = Value
        if IsSave then
            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    end

    self:CacheScalabilityFeatures()
    FLOG_INFO("##Setting SetTextureQuality Idx:%d, ConfigValue:%d ValueToSet:%d", Value, ConfigValue, ValueToSet)
    -- if not IsLoginInit then
        --启动客户端的时候自动设置过了的
        if ValueToSet >= 0 and ValueToSet <= 4 then
            self[FieldName] = ValueToSet

            local MaxLvlValue = self:GetMaxLvlValue(4)
            if IsLoginInit and ValueToSet == self:GetDefaultQualityLevel() then
                self:OnOneFeatureChanged(5, IsLoginInit, IsBySelect)
                self:OverrideSetOnEmulator(5, ValueToSet, IsLoginInit, IsBySelect, MaxLvlValue)
            else
                -- CommonUtil.ConsoleCommand(string.format("sg.TextureQuality %d", self[FieldName]))
                _G.SettingsMgr:CachePicSetting(5, ValueToSet, IsLoginInit, IsBySelect, MaxLvlValue)
            end
        end
    -- end

    --SettingsUtils不用再SetInt了
    return true
end

function SettingsTabPicture:GetDefaultTextureQualityIndex()
    local DefaultLevel = self:GetDefaultQualityLevel()
    local DefaultIndex = SettingsUtils.GetDropDownListIndex(DefaultLevel, SettingsUtils.CurSetingCfg)

    return DefaultIndex
end

--6 特效质量
function SettingsTabPicture:SetEffectQuality(Value, IsSave , IsLoginInit, IsBySelect)
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey

    local ConfigValue = -1
    local ValueToSet = -1

    --if Value是Index
    if IsLoginInit and IsSave or IsBySelect then
        ConfigValue = SettingsUtils.GetDropDownListNumValue(Value, 0)
        ValueToSet = ConfigValue

        if IsSave then  --走到这里必然是true，都是要保存的
            if IsLoginInit then
                local DefaultLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
                if DefaultLevel == -1 then  -- -1:没配置
                    ValueToSet = 0
                end
            end

            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    else
        ValueToSet = Value
        if IsSave then
            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    end
    self:CacheScalabilityFeatures()
    FLOG_INFO("##Setting SetEffectQuality Idx:%d, ConfigValue:%d ValueToSet:%d", Value, ConfigValue, ValueToSet)
    -- if not IsLoginInit then
        --启动客户端的时候自动设置过了的
        if ValueToSet >= 0 and ValueToSet <= 4 then
            self[FieldName] = ValueToSet

            local MaxLvlValue = self:GetMaxLvlValue(3)
            if IsLoginInit and ValueToSet == self:GetDefaultQualityLevel() then
                self:OnOneFeatureChanged(6, IsLoginInit, IsBySelect)
            else
                -- CommonUtil.ConsoleCommand(string.format("sg.EffectsQuality %d", self[FieldName]))
                _G.SettingsMgr:CachePicSetting(6, ValueToSet, IsLoginInit, IsBySelect, MaxLvlValue)
            end
        end
    -- end

    --FLOG_INFO("SettingsTabPicture:SetEffectQuality, XXXXXXXXXXXXXXXXXXXXXXXXXX, Value:%d", Value)
    CommonUtil.ReportEffectQuality()
    --SettingsUtils不用再SetInt了
    return true
end

function SettingsTabPicture:GetDefaultEffectQualityIndex()
    local DefaultLevel = self:GetDefaultQualityLevel()
    local DefaultIndex = SettingsUtils.GetDropDownListIndex(DefaultLevel, SettingsUtils.CurSetingCfg)

    return DefaultIndex
end

--7 植被质量
function SettingsTabPicture:SetFoliageQuality(Value, IsSave, IsLoginInit, IsBySelect)
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey

    local ConfigValue = -1
    local ValueToSet = -1

    --if Value是Index
    if IsLoginInit and IsSave or IsBySelect then
        ConfigValue = SettingsUtils.GetDropDownListNumValue(Value, 0)
        ValueToSet = ConfigValue

        if IsSave then  --走到这里必然是true，都是要保存的
            if IsLoginInit then
                local DefaultLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
                if DefaultLevel == -1 then  -- -1:没配置
                    ValueToSet = 0
                end
            end

            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    else
        ValueToSet = Value
        if IsSave then
            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    end

    self:CacheScalabilityFeatures()
    FLOG_INFO("##Setting SetFoliageQuality Idx:%d, ConfigValue:%d ValueToSet:%d", Value, ConfigValue, ValueToSet)
    -- if not IsLoginInit then
        --启动客户端的时候自动设置过了的
        if ValueToSet >= 0 and ValueToSet <= 4 then
            self[FieldName] = ValueToSet

            local MaxLvlValue = self:GetMaxLvlValue(2)
            if IsLoginInit and ValueToSet == self:GetDefaultQualityLevel() then
                self:OnOneFeatureChanged(7, IsLoginInit, IsBySelect)
                self:OverrideSetOnEmulator(7, ValueToSet, IsLoginInit, IsBySelect, MaxLvlValue)
            else
                -- CommonUtil.ConsoleCommand(string.format("sg.FoliageQuality %d", self[FieldName]))
                _G.SettingsMgr:CachePicSetting(7, ValueToSet, IsLoginInit, IsBySelect, MaxLvlValue)
            end
        end
    -- end

    --SettingsUtils不用再SetInt了
    return true
end

function SettingsTabPicture:GetDefaultFoliageQualityIndex()
    local DefaultLevel = self:GetDefaultQualityLevel()
    local DefaultIndex = SettingsUtils.GetDropDownListIndex(DefaultLevel, SettingsUtils.CurSetingCfg)

    return DefaultIndex
end

--Scalability里的一个特性变化（客户端手动切换）
--这个时候需要级别变为自定义那一档，Scalability里的每个特性都记录在命令行参数里
function SettingsTabPicture:OnOneFeatureChanged(FeatureID, IsLoginInit, IsBySelect)
    if IsBySelect then
        FLOG_INFO("##Setting SaveKey.QualityLevel set to %d", SettingsMgr.CustomQualityIndex)
        _G.UE.USaveMgr.SetInt(SaveKey.QualityLevel, SettingsMgr.CustomQualityIndex, false)
    end

    _G.UE.USettingUtil.OnOneFeatureChanged()
    _G.EventMgr:SendEvent(_G.EventID.OnePictureFeatureChg, FeatureID)
end

--在正常设置后，模拟器上可能会重置些 特性
-- 2到8是CachePicSetting过来的（登录的时候立即，再或者是关闭设置界面的时候）
-- 其他没有经过CachePicSetting的，得要自己额外专门调用，这有两种（有设置项的，没设置项的）
    --有设置项的：角色数量、角色lod、
    --没有设置项的：texturestraming、场景lod、植被lod、
function SettingsTabPicture:OverrideSetOnEmulator(FeatureID, ValueToSet, IsLoginInit, IsBySelect, MaxLvlValue)
    local IsEmulator = _G.SettingsMgr.IsWithEmulatorMode
    if not IsEmulator then
        return
    end

    local Rlt = _G.PreRealStart.OverrideSetOnEmulator(FeatureID, ValueToSet, MaxLvlValue)
    local QualityLevel = _G.UE.USaveMgr.GetInt(SaveKey.QualityLevel, _G.SettingsMgr.DefauleValueNotSave, false)
    FLOG_INFO("setting OverrideSet FeatureID: %d, ValueToSet:%d, MaxLvlValue:%d, Rlt:%s, IsLoginInit:%s, IsBySelect:%s"
        , FeatureID, ValueToSet, MaxLvlValue, tostring(Rlt), tostring(IsLoginInit), tostring(IsBySelect))
        
    if Rlt then
        -- if FeatureID == 0 then  --0 方案是5，或者自定义方案的时候，上一次的方案是5
        --     local VisionMgr = _G.UE.UVisionMgr.Get()
        --     VisionMgr:SetEnableVisionMeshLimiter(false)                             --角色数量限制取消
        --     -- VisionMgr:RefreshVision()    --客户端进游戏RoleLife的时候已经SetEnable了，所以不需要刷新视野了
        -- end
    else
        -- if FeatureID == 0 then  --关闭
        --     local VisionMgr = _G.UE.UVisionMgr.Get()
        --     VisionMgr:SetEnableVisionMeshLimiter(true)              --角色数量限制取消
        -- end
    end
end

--8 分辨率  保存的都是ScreenPercent的数值
function SettingsTabPicture:SetScaleFactor(Value, IsSave , IsLoginInit, IsBySelect)
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    
    local ConfigValue = -1
    local ValueToSet = -1
    
    if self.bSelectQualityLevelChanging then
        if Value >= 0 and Value <= 4 then
            if _G.SettingsMgr:IsIosHightDevice() and Value <= 2 then
                Value = 100
            else
                Value = _G.SettingsMgr.ScreenPercentList[Value + 1]
            end
        end
    end

    --if Value是Index
    if IsLoginInit and IsSave or IsBySelect then
        ConfigValue = SettingsUtils.GetDropDownListNumValue(Value, 0)
        ValueToSet = ConfigValue

        if IsSave then  --走到这里必然是true，都是要保存的
            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    else
        ValueToSet = Value
        if IsSave then
            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    end
    
    self:CacheScalabilityFeatures()
    FLOG_INFO("##Setting SetScreenPercentage Idx:%d, ConfigValue:%d ValueToSet:%d", Value, ConfigValue, ValueToSet)
    -- if not IsLoginInit then
        --启动客户端的时候自动设置过了的
        if ValueToSet > 0 and ValueToSet <= 100 then
            self[FieldName] = ValueToSet

            local MaxLvlValue = self:GetMaxLvlValue(100)
            local DefaultLevel = self:GetDefaultQualityLevel()
            if IsLoginInit then
                -- local CmdStr = string.format("r.ScreenPercentage %d", ValueToSet)
                -- CommonUtil.ConsoleCommand(CmdStr)
                _G.UE.USettingUtil.ExeCommand("r.ScreenPercentage", ValueToSet, PriorityConsole)
                FLOG_INFO("setting(IsLoginInit=true) r.ScreenPercentage -> %d", ValueToSet)

                self:OnOneFeatureChanged(8, IsLoginInit, IsBySelect)
                self:OverrideSetOnEmulator(8, ValueToSet, IsLoginInit, IsBySelect, MaxLvlValue)
            else
                -- CommonUtil.ConsoleCommand(string.format("sg.FoliageQuality %d", self[FieldName]))
                _G.SettingsMgr:CachePicSetting(8, ValueToSet, IsLoginInit, IsBySelect, MaxLvlValue)
            end
        end
    -- end

    --FLOG_INFO("SettingsTabPicture:SetScaleFactor, XXXXXXXXXXXXXXXXXXXXXXXXXX, Value:%d", Value)
    CommonUtil.ReportScaleFactor()
    --SettingsUtils不用再SetInt了
    return true
end

function SettingsTabPicture:GetDefaultScaleFactorIndex()
    local CurScreenPercent = _G.UE.UKismetSystemLibrary.GetConsoleVariableIntValue("r.ScreenPercentage")
    local DefaultIndex = SettingsUtils.GetDropDownListIndex(CurScreenPercent, SettingsUtils.CurSetingCfg)

    return DefaultIndex
end

function SettingsTabPicture:SwitchScreenPercentCheck(Value)
    local DefaultLevel = self:GetDefaultQualityLevel()
    local DefaultValue = _G.SettingsMgr.ScreenPercentList[DefaultLevel + 1]
    local TargetValue = SettingsUtils.GetDropDownListNumValue(Value, -2)
    
    if TargetValue < 0 then
        return false, false
    end

    if TargetValue > DefaultValue then
        return false, true
    end

    return true, false
end
-----------------------------------------
--13 特效lod
function SettingsTabPicture:SetEffectLod(Value, IsSave , IsLoginInit, IsBySelect)
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    --是画质等级预案手动切换 过来的；  Value此时是新的画质等级0-4
    --根据当前画质等级确定该特性的Index
    if self.bSelectQualityLevelChanging then
        Value = SettingsUtils.GetDropDownListIndex(Value, SettingsUtils.CurSetingCfg)
    end
    local ConfigValue = SettingsUtils.GetDropDownListNumValue(Value, 0)

    self:CachePictureFeatures()
    FLOG_INFO("##Setting SetEffectLod Idx:%d, Value:%d", Value, ConfigValue)
    -- if not IsLoginInit then
        --启动客户端的时候自动设置过了的
        if ConfigValue >= 0 then
            self[FieldName] = ConfigValue
            EffectUtil.SetQualityLevelFXLOD(ConfigValue)

            self:OnOneFeatureChanged(13, IsLoginInit, IsBySelect)
        end
    -- end

    if IsSave then
        _G.UE.USaveMgr.SetInt(SaveKey[FieldName], Value, false)
    end
    --SettingsUtils不用再SetInt了
    return true
end

function SettingsTabPicture:GetDefaultEffectLodIndex()
    local DefaultLevel = self:GetDefaultQualityLevel()
    local DefaultIndex = SettingsUtils.GetDropDownListIndex(DefaultLevel, SettingsUtils.CurSetingCfg)

    return DefaultIndex
end

--14 特效最大数量
function SettingsTabPicture:SetEffectMaxNum(Value, IsSave , IsLoginInit, IsBySelect)
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    --是画质等级预案手动切换 过来的；  Value此时是新的画质等级0-4
    --根据当前画质等级确定该特性的Index
    if self.bSelectQualityLevelChanging then
        Value = SettingsUtils.GetDropDownListIndex(Value, SettingsUtils.CurSetingCfg)
    end
    local ConfigValue = SettingsUtils.GetDropDownListNumValue(Value, 0)

    self:CachePictureFeatures()
    FLOG_INFO("##Setting SetEffectMaxNum Idx:%d, Value:%d", Value, ConfigValue)
    -- if not IsLoginInit then
        --启动客户端的时候自动设置过了的
        if ConfigValue >= 0 then
            self[FieldName] = ConfigValue
            EffectUtil.SetQualityLevelFXMaxCount(ConfigValue)

            self:OnOneFeatureChanged(14, IsLoginInit, IsBySelect)
        end
    -- end

    if IsSave then
        _G.UE.USaveMgr.SetInt(SaveKey[FieldName], Value, false)
    end
    --SettingsUtils不用再SetInt了
    return true
end

function SettingsTabPicture:GetDefaultEffectMaxNumIndex()
    local DefaultLevel = self:GetDefaultQualityLevel()
    local DefaultIndex = SettingsUtils.GetDropDownListIndex(DefaultLevel, SettingsUtils.CurSetingCfg)

    return DefaultIndex
end

--15 角色Lod
function SettingsTabPicture:SetActorLod(Value, IsSave , IsLoginInit, IsBySelect)
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    --是画质等级预案手动切换 过来的；  Value此时是新的画质等级0-4
    --根据当前画质等级确定该特性的Index
    if self.bSelectQualityLevelChanging then
        Value = SettingsUtils.GetDropDownListIndex(Value, SettingsUtils.CurSetingCfg)
    end
    local ConfigValue = SettingsUtils.GetDropDownListNumValue(Value, 0)

    self:CachePictureFeatures()
    FLOG_INFO("##Setting SetActorLod Idx:%d, Value:%d", Value, ConfigValue)
    -- if not IsLoginInit then
        --启动客户端的时候自动设置过了的
        if ConfigValue >= 0 then
           self[FieldName] = ConfigValue
           local LODOffset = CommonDefine.QualityLevelActorLOD[ConfigValue]
           _G.UE.UActorManager:Get():SetActorLODOffsetConfig(LODOffset.Major, LODOffset.Player, LODOffset.Boss, LODOffset.Monster, LODOffset.NPC)
            
           self:OnOneFeatureChanged(15, IsLoginInit, IsBySelect)
        --    local MaxLvlValue = self:GetMaxLvlValue(4)
        --     self:OverrideSetOnEmulator(15, ConfigValue, IsLoginInit, IsBySelect, MaxLvlValue)
        end
    -- end

    if IsSave then
        _G.UE.USaveMgr.SetInt(SaveKey[FieldName], Value, false)
    end
    --SettingsUtils不用再SetInt了
    return true
end

function SettingsTabPicture:GetDefaultActorLodIndex()
    local DefaultLevel = self:GetDefaultQualityLevel()
    local DefaultIndex = SettingsUtils.GetDropDownListIndex(DefaultLevel, SettingsUtils.CurSetingCfg)

    return DefaultIndex
end
----------------------------------   -----------------------------------------------
--- 16
--AmbientOcclusion
function SettingsTabPicture:SetAO(Value, IsSave, IsLoginInit, IsBySelect)
    return true
    -- self:CachePictureFeatures()
    -- _G.UE.USettingUtil.SetMobileAmbientOcclusion(Value == 2)
    -- self:OnOneFeatureChanged(16, IsLoginInit, IsBySelect)
    
    -- if self.bSelectQualityLevelChanging then
    --     local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    --     self[FieldName] = -1
    --     _G.UE.USaveMgr.SetInt(SaveKey[FieldName], -1, false)

    --     return true
    -- end
end

function SettingsTabPicture:SwitchAOCheck(Value)
    local bCan = true
    if Value == 2 then
        bCan = _G.UE.USettingUtil.CanMobileAmbientOcclusion()
        if not bCan then
            return false, true
        end
    end

    return bCan, false
end

function SettingsTabPicture:GetDefaultAOIndex()
    local bOpen = _G.UE.USettingUtil.GetMobileAmbientOcclusion()
    if bOpen then
        return 2
    end

    return 1
end

--测试代码：NoTranslateStr配置该函数，下拉列表的内容
function SettingsTabPicture:GetAOListData(bPreClickDropDownList, SettingCfg)
    if bPreClickDropDownList then
        return {"关闭2", "开启2"}
    end

    return {"关闭1", "开启1"}
end

--17
--LightShaft
function SettingsTabPicture:SetLightShaft(Value, IsSave, IsLoginInit, IsBySelect)
    self:CachePictureFeatures()
    _G.UE.USettingUtil.SetMobileLightShaft(Value == 2)
    self:OnOneFeatureChanged(17, IsLoginInit, IsBySelect)

    if self.bSelectQualityLevelChanging then
        local FieldName = SettingsUtils.CurSetingCfg.SaveKey
        self[FieldName] = -1
        _G.UE.USaveMgr.SetInt(SaveKey[FieldName], -1, false)

        return true
    end
end

function SettingsTabPicture:SwitchLightShaftCheck(Value)
    local bCan = true
    if Value == 2 then
        bCan = _G.UE.USettingUtil.CanMobileLightShaft()
        if not bCan then
            return false, true
        end
    end

    return bCan, false
end

function SettingsTabPicture:GetDefaultLightShaftIndex()
    local bOpen = _G.UE.USettingUtil.GetMobileLightShaft()
    if bOpen then
        return 2
    end

    return 1
end

function SettingsTabPicture:GetQualityLevelByLastSaveKey()
    local Level = 0

    local LastQualityLevel = _G.UE.USaveMgr.GetInt(SaveKey.LastQualityLevel, _G.SettingsMgr.DefauleValueNotSave, false)
    if LastQualityLevel == _G.SettingsMgr.CustomQualityIndex then   --自定义画质的话，当做默认画质的
        Level = self:GetDefaultQualityLevel()
    elseif LastQualityLevel == 6 then   --模拟器下的极致那一档
        Level = 4
    elseif LastQualityLevel == _G.SettingsMgr.DefauleValueNotSave then  --安装完成，还没设置这个
        Level = self:GetDefaultQualityLevel()
    else
        Level = LastQualityLevel - 1
        if Level < 0 then
            Level = 0
        end
    end

    return Level
end

function SettingsTabPicture:SetMaxNumByQualityLevel(Level, CurSetingCfg, DefaultMaxNum)
    local MaxNum = DefaultMaxNum
    if Level >= 0 and Level <= 4 then
        MaxNum = CurSetingCfg.Num[Level + 1]
        _G.SettingsMgr.SliderMaxNum[CurSetingCfg.ID] = MaxNum
    else
        FLOG_ERROR("setting SetMaxNumByQualityLevel Value(%d) Error, ID:%d", Level, CurSetingCfg.ID)
    end

    return MaxNum
end

-- 18 设置玩家数量（副本外）
function SettingsTabPicture:SetVisionPlayerNum(Value, IsSave, IsLoginInit, IsBySelect)
    local Num = Value or 7
    local MaxNum = Value
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    --是画质等级预案手动切换 过来的；  Value此时是新的画质等级0-4
    --根据当前画质等级确定该特性的Index
    if self.bSelectQualityLevelChanging then
        --画质等级变化，重新设置默认值
        Num = tonumber(SettingsUtils.CurSetingCfg.Value[2]) or 7
        if _G.SettingsMgr:IsIosHightDevice() and Value <= 2 then
            Num = 5
        end

        MaxNum = self:SetMaxNumByQualityLevel(Value, SettingsUtils.CurSetingCfg, 10) or 10
    else
        local Level = self:GetQualityLevelByLastSaveKey()
        MaxNum = self:SetMaxNumByQualityLevel(Level, SettingsUtils.CurSetingCfg, 10) or 10
    end

    self:CachePictureFeatures()
    FLOG_INFO("##Setting SetVisionPlayerNum Value:%d, Num:%d MaxNum:%d", Value, Num, MaxNum)
    -- if not IsLoginInit then
        --启动客户端的时候自动设置过了的
        if Num >= 0 then
           self[FieldName] = Num
        --    --1 表示玩家
        --    _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(1, false, Num, true)
            self:RefreshVisionPlayerNum()

            self:OnOneFeatureChanged(18, IsLoginInit, IsBySelect)
        end
    -- end

    if IsSave then
        _G.UE.USaveMgr.SetInt(SaveKey[FieldName], Num, false)
    end
    --FLOG_INFO("SettingsTabPicture:SetVisionPlayerNum, XXXXXXXXXXXXXXXXXXXXXXXXXX, Value:%d", Value)
    CommonUtil.ReportVisionPlayerNum()
    --SettingsUtils不用再SetInt了
    return true
end

-- 24 设置玩家数量（副本内）
function SettingsTabPicture:SetDungeonVisionPlayerNum(Value, IsSave, IsLoginInit, IsBySelect)
    local Num = Value or 7
    local MaxNum = Value
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    --是画质等级预案手动切换 过来的；  Value此时是新的画质等级0-4
    --根据当前画质等级确定该特性的Index
    if self.bSelectQualityLevelChanging then
        --画质等级变化，重新设置默认值
        Num = tonumber(SettingsUtils.CurSetingCfg.Value[2]) or 7
        if _G.SettingsMgr:IsIosHightDevice() and Value <= 2 then
            Num = 5
        end

        MaxNum = self:SetMaxNumByQualityLevel(Value, SettingsUtils.CurSetingCfg, 10) or 10
    else
        local Level = self:GetQualityLevelByLastSaveKey()
        MaxNum = self:SetMaxNumByQualityLevel(Level, SettingsUtils.CurSetingCfg, 10) or 10
    end

    self:CachePictureFeatures()
    FLOG_INFO("##Setting SetVisionPlayerNum Dungeon Value:%d, Num:%d MaxNum:%d", Value, Num, MaxNum)
    -- if not IsLoginInit then
        --启动客户端的时候自动设置过了的
        if Num >= 0 then
           self[FieldName] = Num
        --    --1 表示玩家
        --    _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(1, false, Num, true)
            self:RefreshVisionPlayerNum()

            self:OnOneFeatureChanged(24, IsLoginInit, IsBySelect)
        end
    -- end

    if IsSave then
        _G.UE.USaveMgr.SetInt(SaveKey[FieldName], Num, false)
    end
    --FLOG_INFO("SettingsTabPicture:SetVisionPlayerNum, XXXXXXXXXXXXXXXXXXXXXXXXXX, Value:%d", Value)
    -- CommonUtil.ReportVisionPlayerNum()
    --SettingsUtils不用再SetInt了
    return true
end

--RefreshMode 1：副本外的Set  2：副本内的Set  0：切换场景
function SettingsTabPicture:RefreshVisionPlayerNum()
    if _G.SettingsMgr:IsPerforcemanceMode() then
        FLOG_INFO("setting RefreshVisionPlayerNum is perforcemancemode")
        return
    end
    
    local Num = -1
    if _G.PWorldMgr:CurrIsInDungeon() then
        Num = _G.SettingsMgr:GetValueBySaveKey("DungeonVisionPlayerNum") or -1
        FLOG_INFO("setting RefreshVisionPlayerNum %d InDungeon", Num)
    else
        Num = _G.SettingsMgr:GetValueBySaveKey("VisionPlayerNum") or -1
        FLOG_INFO("setting RefreshVisionPlayerNum %d", Num)
    end

    if Num >= 0 then
        --1 表示玩家
        _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(1, false, Num, true)
    end
end

-- 19 设置Npc数量
function SettingsTabPicture:SetVisionNpcNum(Value, IsSave, IsLoginInit, IsBySelect)
    local Num = Value
    local MaxNum = Value
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    --是画质等级预案手动切换 过来的；  Value此时是新的画质等级0-4
    --根据当前画质等级确定该特性的Index
    if self.bSelectQualityLevelChanging then
        --画质等级变化，重新设置默认值，也是当前值
        Num = self:GetNpcNumByQualityLevel(Value, SettingsUtils.CurSetingCfg)
        if _G.SettingsMgr:IsIosHightDevice() and Value <= 2 then
            Num = 4
        end
        MaxNum = self:SetMaxNumByQualityLevel(Value, SettingsUtils.CurSetingCfg, 10)
    else
        local Level = self:GetQualityLevelByLastSaveKey()
        MaxNum = self:SetMaxNumByQualityLevel(Level, SettingsUtils.CurSetingCfg, 10)
    end

    self:CachePictureFeatures()
    FLOG_INFO("##Setting SetVisionNpcNum Value:%d, Num:%d MaxNum:%d", Value, Num, MaxNum)
    -- if not IsLoginInit then
        --启动客户端的时候自动设置过了的
        if Num >= 0 then
           self[FieldName] = Num
           --3 表示NPC
           _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(3, false, Num, true)

           self:OnOneFeatureChanged(19, IsLoginInit, IsBySelect)
        end
    -- end

    if IsSave then
        _G.UE.USaveMgr.SetInt(SaveKey[FieldName], Num, false)
    end
    --SettingsUtils不用再SetInt了
    return true
end

function SettingsTabPicture:GetDefaultVisionNpcNum()
    -- local DefaultLevel = self:GetDefaultQualityLevel()
    local Level = self:GetQualityLevelByLastSaveKey()
    local DefaultValue = self:GetNpcNumByQualityLevel(Level, SettingsUtils.CurSetingCfg)

    return DefaultValue
end

function SettingsTabPicture:GetNpcNumByQualityLevel(CurQualityLevel, CurSetingCfg)
    local Num = 0

    if CurQualityLevel >= 0 and CurQualityLevel <= 1 then
        Num = tonumber(CurSetingCfg.Value[2])
    elseif CurQualityLevel == 2 then
        Num = tonumber(CurSetingCfg.Value[4])
    elseif CurQualityLevel > 2 then
        Num = tonumber(CurSetingCfg.Value[5])
    else
        Num = tonumber(CurSetingCfg.Value[3]) or 5
    end

    return Num or 5
end

-- 20 设置宠物数量
function SettingsTabPicture:SetVisionPetNum(Value, IsSave, IsLoginInit, IsBySelect)
    local Num = Value
    local MaxNum = Value
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    --是画质等级预案手动切换 过来的；  Value此时是新的画质等级0-4
    --根据当前画质等级确定该特性的Index
    if self.bSelectQualityLevelChanging then
        --画质等级变化，重新设置默认值
        Num = tonumber(SettingsUtils.CurSetingCfg.Value[2])
        if _G.SettingsMgr:IsIosHightDevice() and Value <= 2 then
            Num = 2
        end
        MaxNum = self:SetMaxNumByQualityLevel(Value, SettingsUtils.CurSetingCfg, 7)
    else
        local Level = self:GetQualityLevelByLastSaveKey()
        MaxNum = self:SetMaxNumByQualityLevel(Level, SettingsUtils.CurSetingCfg, 7)
    end

    self:CachePictureFeatures()
    FLOG_INFO("##Setting SetVisionPetNum Value:%d, Num:%d MaxNum:%d", Value, Num, MaxNum)
    -- if not IsLoginInit then
        --启动客户端的时候自动设置过了的
        if Num >= 0 then
           self[FieldName] = Num
           --4 表示宠物
           _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(4, false, Num, true)

           self:OnOneFeatureChanged(20, IsLoginInit, IsBySelect)
        end
    -- end

    if IsSave then
        _G.UE.USaveMgr.SetInt(SaveKey[FieldName], Num, false)
    end
    --SettingsUtils不用再SetInt了
    return true
end

-- 21 设置其他玩家特效质量
function SettingsTabPicture:SetOtherPlayerEffectSwitch( Value, IsSave , IsLoginInit, IsBySelect)
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    if self.bSelectQualityLevelChanging then
        Value = self:GetDefaultOtherPlayerEffectSwitch(Value)
    end
    FLOG_INFO("##Setting SetOtherPlayerEffectSwitch Value:%d", Value)
    self[FieldName] = Value
    self:CachePictureFeatures()
    if IsSave then
        _G.UE.USaveMgr.SetInt(SaveKey[FieldName], Value, false)
    end

    self:OnOneFeatureChanged(21, IsLoginInit, IsBySelect)
    return true
end

function SettingsTabPicture:GetDefaultOtherPlayerEffectSwitch(Level)
    local DefaultValue = 2
    if Level == 0 then
        DefaultValue = 1
    end
    return DefaultValue
end

function SettingsTabPicture:GetOtherPlayerEffectSwitch()
    local value = self["OtherPlayerEffectSwitch"]
    if value == nil then
        value = self:GetDefaultOtherPlayerEffectSwitch()
    end
    return value - 1
end

--22
--HighqualityBRDFds
function SettingsTabPicture:SetHighqualityBRDFds(Value, IsSave, IsLoginInit, IsBySelect)
    return true
    -- self:CachePictureFeatures()
    -- _G.UE.USettingUtil.SetMobileHighqualityBRDFds(Value == 2)
    -- self:OnOneFeatureChanged(22, IsLoginInit, IsBySelect)

    -- if self.bSelectQualityLevelChanging then
    --     local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    --     self[FieldName] = -1
    --     _G.UE.USaveMgr.SetInt(SaveKey[FieldName], -1, false)

    --     return true
    -- end
end

--23
---最大帧率：Value是index，不是MaxFps
function SettingsTabPicture:SetMaxFPS(Value, IsSave, IsLoginInit, IsBySelect)
    -- self:CachePictureFeatures()

    local ConfigValue = -1
    local ValueToSet = -1

    if self.bSelectQualityLevelChanging then
        FLOG_INFO("##Setting SetMaxFPS ChangeQualityLevel")
        Value = 2 --切画质的时候，默认都是中帧率  30fps
    end

    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    --if Value是Index
    if IsLoginInit and IsSave or IsBySelect then
        ValueToSet = Value
        if IsSave then  --走到这里必然是true，都是要保存的
            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    else
        ValueToSet = Value
        if IsSave then
            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], ValueToSet, false)
        end
    end

    ConfigValue = SettingsUtils.GetDropDownListNumValue(ValueToSet, 30)
    FLOG_INFO("Setting SetMaxFPS IsLoginInit:%s, bIosHigh:%s, selectLvl:%d", tostring(IsLoginInit), tostring(_G.SettingsMgr:IsIosHightDevice()), _G.UE.USaveMgr.GetInt(SaveKey.SelectQualityLevel, -1, false))
    if IsLoginInit and _G.SettingsMgr:IsIosHightDevice() then
        local SelectQualityLevel = _G.UE.USaveMgr.GetInt(SaveKey.SelectQualityLevel, -1, false)
        if SelectQualityLevel <= 2 and Value == 2 then
            FLOG_INFO("setting IosHighDevice defaultIdx:2, so maxfps->25")
            ConfigValue = 25
        end
    end

    if ConfigValue < 15 or ConfigValue > 60 then
        FLOG_ERROR("##Setting SetMaxFPS ConfigValue:%d Value:%d", ConfigValue, Value)
        ConfigValue = 30
    end

    --默认30
    self[FieldName] = ConfigValue
    FLOG_INFO("##Setting SetMaxFPS Idx:%d, ConfigValue:%d ValueToSet:%d"
        , Value, ConfigValue, ValueToSet)

    _G.UE.USettingUtil.ExeCommand("t.maxfps", ConfigValue, Priority)
    if IsBySelect then
        _G.EventMgr:SendEvent(_G.EventID.SettingsMaxFPSChanged)
    end
    -- if IsLoginInit then
    --     _G.UE.USettingUtil.ExeCommand("t.maxfps", ConfigValue, Priority)
    --     -- CommonUtil.ConsoleCommand(string.format("t.maxfps %d", ConfigValue))
    -- else
    --     --不用Override
    --     _G.SettingsMgr:CachePicSetting(23, ConfigValue, IsLoginInit, IsBySelect, 0)
        
    --     --SetQuality和SettingsMaxFPSChanged事件取的帧率都是self[FieldName]
    --     CommonUtil.SetQuality()
    --     self:OnOneFeatureChanged(23, IsLoginInit, IsBySelect)
    --     --CommonUtil.ReportTargetFrameRate()

    --     if IsBySelect then
    --         _G.EventMgr:SendEvent(_G.EventID.SettingsMaxFPSChanged)
    --     end
    -- end

    --SettingsUtils不用再SetInt了
    return true
end

--24：副本内视野玩家数量，在上面

function SettingsTabPicture:SwitchMaxFPSCheck(Value)
    local CurLevel = self:GetQualityLevel()
    if CurLevel <= 2 then   --极低、低
        if Value > 2 then
            return false, true
        end
    else                        --中、高、极高：  都可以设置到60fps     、自定义 SettingsMgr.CustomQualityIndex
        if CurLevel == _G.SettingsMgr.CustomQualityIndex then
            local LastQualityLevel = _G.UE.USaveMgr.GetInt(SaveKey.LastQualityLevel, _G.SettingsMgr.DefauleValueNotSave, false)
            if LastQualityLevel <= 2 then   --极低、低
                if Value > 2 then
                    return false, true
                end
            end
        end
    end

    return true, false
end

-- function SettingsTabPicture:SetDungeonFpsState(Value, IsSave, IsLoginInit, IsBySelect)
--     self:RefreshMaxFps()
-- end

function SettingsTabPicture:RefreshMaxFps(bPWorldReady, DungeonMode)
    -- local IsWithEmulatorMode = _G.UE.UUIMgr.Get():IsWithEmulator()
    -- if IsWithEmulatorMode then
    --     return
    -- end
    
    -- if DungeonMode == nil then
    -- end
    
    -- local CurFps = self.MaxFPS or 30
    -- if DungeonMode < 1 then --上层过滤掉了，不会走到这个分支
    --     _G.UE.USettingUtil.ExeCommand("t.maxfps", CurFps, Priority)
    --     -- CommonUtil.ConsoleCommand(string.format("t.maxfps %d", CurFps))
    --     FLOG_INFO("setting RefreshMaxFps :%d", CurFps)

    --     return 
    -- end

    -- --副本中
    -- if bPWorldReady and DungeonMode > 0 and self.DungeonFpsMode == 1 then--建议模式，30帧
    --     -- CommonUtil.ConsoleCommand(string.format("t.maxfps %d", 30))
    --     _G.UE.USettingUtil.ExeCommand("t.maxfps", 30, Priority)
    --     FLOG_INFO("setting RefreshMaxFps :30")
    -- else
    --     -- CommonUtil.ConsoleCommand(string.format("t.maxfps %d", CurFps))
    --     _G.UE.USettingUtil.ExeCommand("t.maxfps", CurFps, Priority)
    --     FLOG_INFO("setting RefreshMaxFps :%d", CurFps)
    -- end
end

function SettingsTabPicture:SwitchBRDFCheck(Value)
    local bCan = true
    if Value == 2 then
        bCan = _G.UE.USettingUtil.CanMobileHighqualityBRDFds()
        if not bCan then
            return false, true
        end
    end

    return bCan, false
end

function SettingsTabPicture:SwitchHatVisible(Value) 
    if not _G.EquipmentMgr:GetCanSwitchHatVisble() then
        return false, true
    else
        return true, false
    end
end

function SettingsTabPicture:GetDefaultBRDFIndex()
    local bOpen = _G.UE.USettingUtil.GetMobileHighqualityBRDFds()
    if bOpen then
        return 2
    end

    return 1
end

--抗锯齿，独立的开关，和画质无关
function SettingsTabPicture:SetFxaa(Value, IsSave , IsLoginInit, IsBySelect)
    -- body
    if Value == 2 then
        _G.UE.USettingUtil.ExeCommand("r.DefaultFeature.AntiAliasing", 1, 0x09000000)
    else
        _G.UE.USettingUtil.ExeCommand("r.DefaultFeature.AntiAliasing", 0, 0x09000000)
    end

    FLOG_INFO("##Setting SetFxaa Value:%d", Value)
end

function SettingsTabPicture:GetDefaultFxaaIndex()
    local IsWithEmulatorMode = _G.SettingsMgr.IsWithEmulatorMode
    if IsWithEmulatorMode then
        return 2
    end

    return 1
end

--根据设备性能调整画质
--IsLoginInit为true的时候，不让生效，在所有设置都处理完之后再直接调用SettingsTabPicture:EnablePerformanceParams(bEnable)
--IsBySelect 延迟到设置界面关闭的时候再SettingsTabPicture:EnablePerformanceParams
function SettingsTabPicture:SetPerformance(Value, IsSave , IsLoginInit, IsBySelect)
    local FieldName = SettingsUtils.CurSetingCfg.SaveKey
    self[FieldName] = Value
    FLOG_INFO("setting SetPerformanceMode :%d", Value)

    if Value == 2 then  --开启
        if IsBySelect then
            local function OkBtnCallback()
                FLOG_INFO("setting SetPerformanceMode ok")
                if IsSave then
                    _G.UE.USaveMgr.SetInt(SaveKey[FieldName], Value, false)
                end
                
                SettingsVM:UpdateItemList(true)
    
                if IsBySelect then
                    _G.SettingsMgr.IsPerformanceMode = true
                end
            end
        
            local function CancelCallBack()
                FLOG_INFO("setting SetPerformanceMode Cancel")
                self[FieldName] = 1
                _G.UE.USaveMgr.SetInt(SaveKey[FieldName], 1, false)
                
                _G.EventMgr:SendEvent(_G.EventID.OnePictureFeatureChg, 0)
                if IsBySelect then
                    _G.SettingsMgr.IsPerformanceMode = nil
                end
            end
        
            if IsSave and not IsBySelect then
                _G.UE.USaveMgr.SetInt(SaveKey[FieldName], Value, false)
            end

            _G.SettingsMgr.IsPerformanceMode = nil
            local Tips = LSTR(110082)
            MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(110026), Tips, OkBtnCallback, CancelCallBack, nil, nil, {CloseClickCB = CancelCallBack})
        elseif not IsLoginInit then
            if IsSave then
                _G.UE.USaveMgr.SetInt(SaveKey[FieldName], Value, false)
            end

            --不是ui选择，也不是登录的立即生效
            self:EnablePerformanceParams(true, true)
        end

    else--关闭
        if IsSave then
            _G.UE.USaveMgr.SetInt(SaveKey[FieldName], Value, false)
        end

        SettingsVM:UpdateItemList(true)
        if IsBySelect then
            _G.SettingsMgr.IsPerformanceMode = false
        elseif not IsLoginInit then
            self:EnablePerformanceParams(false)
        end
    end

    return true
end

function SettingsTabPicture:ClearRecordPerformanceData()
    FLOG_INFO("setting ClearRecordPerformanceData")
    local RenderConfigs = _G.PreRealStart.PerformanceRenderCmdConfig
    local USaveMgr = _G.UE.USaveMgr

    local Value = -1
    for _, Config in ipairs(RenderConfigs) do
        --先本地保存当前的数值，然后再设置性能模式的参数
        if Config.IsFloat then
            USaveMgr.SetFloat(Config.LstID, Value, false)
            USaveMgr.SetFloat(Config.PMID, Value, false)
        else
            USaveMgr.SetInt(Config.LstID, Value, false)
            USaveMgr.SetInt(Config.PMID, Value, false)
        end
    end
end

--开的时候，要画质等都生效完，再调用
--关的时候，要先调用，先还原，然后再执行画质的选项
--bRecordCurValue只有bEnable为true的时候才有用
function SettingsTabPicture:EnablePerformanceParams(bEnable, bRecordCurValue)
    FLOG_INFO("===================== SettingsTabPicture EnablePerformanceParams:%s", tostring(bEnable))

    local USaveMgr = _G.UE.USaveMgr
    local USettingUtil = _G.UE.USettingUtil
    local UKismetSystemLibrary = _G.UE.UKismetSystemLibrary

    local CurWorld = _G.UE.UFGameInstance.Get():GetWorld()
    local RenderConfigs = _G.PreRealStart.PerformanceRenderCmdConfig
    --0~4
    local SelectQualityLevel = USaveMgr.GetInt(SaveKey.SelectQualityLevel, -1, false)
    if bEnable then
        local Idx = SelectQualityLevel - 1 --2/3/4转换为    Config.Params的{中、高、极高}的index
        if Idx <= 0 then
            Idx = 1
            FLOG_ERROR("setting EnablePerformanceParams %d", SelectQualityLevel)            
        end

        if Idx > 3 then
            Idx = 3
            FLOG_ERROR("setting EnablePerformanceParams %d", SelectQualityLevel)            
        end
        
        for _, Config in ipairs(RenderConfigs) do
            --先本地保存当前的数值，然后再设置性能模式的参数
            local Value = -1
            local bNeedSet = true
            if Config.IsFloat then
                if bRecordCurValue then
                    Value = UKismetSystemLibrary.GetConsoleVariableFloatValue(Config.Cmd)
                    USaveMgr.SetFloat(Config.LstID, Value, false)
                else
                    Value = USaveMgr.GetFloat(Config.LstID, -1, false)
                end
            else
                if bRecordCurValue then
                    Value = UKismetSystemLibrary.GetConsoleVariableIntValue(Config.Cmd)
                    if Config.LstID == SaveKey.Lst_Maxfps then
                        if Value <= 30 then
                            bNeedSet = false
                            FLOG_INFO("setting donot SetMaxFps")
                            USaveMgr.SetInt(Config.LstID, -1, false)
                        else
                            FLOG_INFO("setting SetMaxFps 30")
                            USaveMgr.SetInt(Config.LstID, Value, false)
                        end
                    else
                        USaveMgr.SetInt(Config.LstID, Value, false)
                    end
                else
                    Value = USaveMgr.GetInt(Config.LstID, -1, false)
                end
            end

            local ParamValue = Config.Params[Idx]
            FLOG_INFO("===============  setting open %s SaveCurValue:%s ==> SetNewValue:%s", Config.Cmd, tostring(Value), tostring(ParamValue))
    
            if ParamValue and ParamValue >= 0 and bNeedSet then
                local CmdFmt = string.format("%s%s", Config.Cmd, Config.Fmt)
                local CmdStr = string.format( CmdFmt, ParamValue)
                print(CmdStr)   --todel 日志
                if Config.IsFloat then
                    UKismetSystemLibrary.ExecuteConsoleCommand(CurWorld, CmdStr, nil)
                    USaveMgr.SetFloat(Config.PMID, ParamValue, false)
                elseif Config.Priority then
                    USettingUtil.ExeCommand(Config.Cmd, ParamValue, Config.Priority)
                    USaveMgr.SetInt(Config.PMID, ParamValue, false)
                else
                    USettingUtil.ExeCommand(Config.Cmd, ParamValue, Priority)
                    USaveMgr.SetInt(Config.PMID, ParamValue, false)
                end
            end

            if Config.IsFloat then
                Value = UKismetSystemLibrary.GetConsoleVariableFloatValue(Config.Cmd)--todel 日志
            else
                Value = UKismetSystemLibrary.GetConsoleVariableIntValue(Config.Cmd) --todel 日志
            end
            FLOG_WARNING("------setting AfterSet:%s", tostring(Value))--todel 日志
        end
        
        --===================非Cmd设置===================
        --偏移
        EffectUtil.SetQualityLevelFXLOD(1)      --特效LOD
        EffectUtil.SetWorldEffectMaxCount(0)    --特效最大数量（非强显特效

        --视野人数默认
            --1 表示玩家
            _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(1, false, 7, true)
            --3 表示NPC
            _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(3, false, 5, true)
            --4 表示宠物
            _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(4, false, 3, true)
    
        FLOG_INFO("===============  setting open LevelFXLOD->1 EffectMaxCount->0 player7 npc5 pet3")
    else
        --ViewDistanceScale就不还原了，始终以性能模式的设置为准，除非再次启动客户端
        for _, Config in ipairs(RenderConfigs) do
            --还原本地保存开启性能模式之前的数值，清除记录的性能模式的数值
            local LastValue = -1
            local CurValue = -1
            if Config.IsFloat then
                LastValue = USaveMgr.GetFloat(Config.LstID, -1, false)
                USaveMgr.SetFloat(Config.PMID, -1, false)
                CurValue = UKismetSystemLibrary.GetConsoleVariableFloatValue(Config.Cmd)
            else
                LastValue = USaveMgr.GetInt(Config.LstID, -1, false)
                USaveMgr.SetInt(Config.PMID, -1, false)
                CurValue = UKismetSystemLibrary.GetConsoleVariableIntValue(Config.Cmd)
            end

            FLOG_INFO("===============  setting close %s CurValue:%s ==> LastValue:%s", Config.Cmd, tostring(CurValue), tostring(LastValue))
    
            if LastValue and LastValue >= 0 then
                local CmdFmt = string.format("%s%s", Config.Cmd, Config.Fmt)
                local CmdStr = string.format( CmdFmt, LastValue)
                print(CmdStr)   --todel 日志
                if Config.IsFloat then
                    ---- 就不还原了，始终以性能模式的设置为准，除非再次启动客户端;   目前只有ViewDistanceScale才会这样
                    -- UKismetSystemLibrary.ExecuteConsoleCommand(CurWorld, CmdStr, nil)   
                elseif Config.Priority then
                    USettingUtil.ExeCommand(Config.Cmd, LastValue, Config.Priority)
                else
                    USettingUtil.ExeCommand(Config.Cmd, LastValue, Priority)
                end
            end

            if Config.IsFloat then
                Value = UKismetSystemLibrary.GetConsoleVariableFloatValue(Config.Cmd)--todel 日志
            else
                Value = UKismetSystemLibrary.GetConsoleVariableIntValue(Config.Cmd) --todel 日志
            end
            FLOG_WARNING("------setting AfterSet:%s", tostring(Value))--todel 日志
        end

        --===================非Cmd设置===================
        --偏移
        local LastFxLODLevel = _G.SettingsMgr:GetValueBySaveKey("EffectLod")
        FLOG_INFO("======setting close SetQualityLevelFXLOD 1 ==> LastValue:%d", LastFxLODLevel)
        EffectUtil.SetQualityLevelFXLOD(LastFxLODLevel)                 --特效LOD
        local LastEffectMaxNumLevel = _G.SettingsMgr:GetValueBySaveKey("EffectMaxNum")
        FLOG_INFO("======setting close LastEffectMaxNumValue:%d", LastEffectMaxNumLevel)
        EffectUtil.SetQualityLevelFXMaxCount(LastEffectMaxNumLevel)     --特效最大数量（非强显特效

        --视野人数默认
            self:RefreshVisionPlayerNum()
            --1 表示玩家
            -- local LastVisionNum = _G.SettingsMgr:GetValueBySaveKey("VisionPlayerNum")
            -- FLOG_INFO("======setting close Last Player Vision Num:%d", LastVisionNum)
            -- _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(1, false, LastVisionNum, true)
            --3 表示NPC
            LastVisionNum = _G.SettingsMgr:GetValueBySaveKey("VisionNpcNum")
            FLOG_INFO("======setting close Last VisionNpcNum :%d", LastVisionNum)
            _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(3, false, LastVisionNum, true)
            --4 表示宠物
            LastVisionNum = _G.SettingsMgr:GetValueBySaveKey("VisionPetNum")
            FLOG_INFO("======setting close Last VisionPetNum :%d", LastVisionNum)
            _G.UE.UVisionMgr.Get():OverrideChannelMaxCount(4, false, LastVisionNum, true)
    end
    
	_G.EventMgr:SendEvent(_G.EventID.SettingsMaxFPSChanged)
end

return SettingsTabPicture