---  
--- Author: xingcaicao
--- DateTime: 2023-03-23 16:44
--- Description:

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local SaveKey = require("Define/SaveKey")
local EventID = require("Define/EventID")

local ClientSetupID = require("Game/ClientSetup/ClientSetupID")

local SettingsDefine = require("Game/Settings/SettingsDefine")
local ItemDisplayStyle = SettingsDefine.ItemDisplayStyle
local SettingsUtils = require("Game/Settings/SettingsUtils")
local SettingsCfg = require("TableCfg/SettingsCfg")
local CommonUtil = require("Utils/CommonUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local DungeonFpsmodeCfg = require("TableCfg/DungeonFpsmodeCfg")
local ProtoRes = require ("Protocol/ProtoRes")
local EffectUtil = require("Utils/EffectUtil")

local USaveMgr
local TutorialGuideMgr
local Priority = 0x01000000
local PriorityConsole = 0x09000000

local SettingsMgr = LuaClass(MgrBase)

function SettingsMgr:OnInit()
    SettingsUtils.OnInit()

    --业务系统动态设置 设置项的显隐
    --[SettingID, true/false]
    self.SettingOpenMap = {}
    self.SettingIDMap = {}  --缓存SettingOpenMap的，不是所有的设置，所以不要用这个Map

    self.NeedRestartGameFeature = {6}  --需要重启的设置项 特效质量

    self.DefauleValueNotSave = -999999

end

function SettingsMgr:OnBegin()
	USaveMgr    = _G.UE.USaveMgr

    TutorialGuideMgr = _G.TutorialGuideMgr

    self.IsWithEmulatorMode = _G.UE.UUIMgr.Get():IsWithEmulator()
    self.CustomQualityIndex = 6
    if self.IsWithEmulatorMode then
        self.CustomQualityIndex = 7
    end

    self.NavigationState    = 1
    self.TutorialState      = 1
    self.TutorialGuideState = 1

    SettingsUtils.OnBegin()

    --[SaveKeyID, SettingCfg]
    self.SettingCfgMap = {}
    --[ClientSetupKeyMap, SettingCfg]
    self.ClientSetupKeyMap = {}

    self.PicSettingTmp = {}

    self.QulityLevelTmp = nil
    self.IsPerformanceMode = nil --关闭设置界面的时候   nil:没有动性能模式  false：关闭性能模式  true：开启性能模式

    --[SettingCfgID, MaxNum]    支持滑杆的最大值动态可变
    self.SliderMaxNum = {}
    
    -- --[PWorldResID, DungeonFpsmodeCfg]
    -- self.DungeonFpsModeMap = {}
    -- self.FpsModeDungeonNum = 0
    self.FpsModeDungeonList = {}
    
    self.ScaleFactorMap = {
        ["android"] =           {1, 1, 1, 1.3, 1.5},
        ["android_unknown"] =   {1, 1, 1, 1, 1},
        ["iphone"] =            {2, 2, 2, 2.1, 2.5},
        ["ipad"] =              {1, 1.5, 1.5, 1.5, 2.8},
        ["ipodtouch"] =         {2, 2, 2, 2, 2},
        ["ios_unknown"] =       {2.8, 2.8, 2.8, 2.8, 2.8},
        ["other"] =             {1, 1, 1, 1.3, 1.5},    --编辑器测试用
    }
    
    self.ScreenPercentMap = {
        ["android"] =           {75, 75, 100, 100, 100},
        ["android_unknown"] =   {100, 100, 100, 100, 100},
        ["iphone"] =            {75, 75, 100, 100, 100},
        ["ipad"] =              {75, 75, 100, 100, 100},
        ["ipodtouch"] =         {75, 75, 75, 75, 75},
        ["ios_unknown"] =       {100, 100, 100, 100, 100},
        ["other"] =             {75, 75, 100, 100, 100},    --编辑器测试用
    }

    self.DeviceScaleFactorList = nil
    self.ScreenPercentList = nil

    local DeviceProfileName = _G.UE.UConfigMgr:Get():GetActiveDeviceProfileName()
    DeviceProfileName = string.lower(DeviceProfileName)
    self.DeviceProfileName = DeviceProfileName
    if string.find(DeviceProfileName, "android") then
        self.DeviceScaleFactorList = self.ScaleFactorMap["android"]
        self.ScreenPercentList = self.ScreenPercentMap["android"]
    elseif string.find(DeviceProfileName, "iphone") then
        self.DeviceScaleFactorList = self.ScaleFactorMap["iphone"]
        self.ScreenPercentList = self.ScreenPercentMap["iphone"]
        self.IsIphoneDevice = true
    elseif string.find(DeviceProfileName, "android_unknown") then
        self.DeviceScaleFactorList = self.ScaleFactorMap["android_unknown"]
        self.ScreenPercentList = self.ScreenPercentMap["android_unknown"]
    elseif string.find(DeviceProfileName, "ios_unknown") then
        self.DeviceScaleFactorList = self.ScaleFactorMap["ios_unknown"]
        self.ScreenPercentList = self.ScreenPercentMap["ios_unknown"]
    elseif string.find(DeviceProfileName, "ipad") then
        self.DeviceScaleFactorList = self.ScaleFactorMap["ipad"]
        self.ScreenPercentList = self.ScreenPercentMap["ipad"]
        self.IsIpadDevice = true
    elseif string.find(DeviceProfileName, "ipodtouch") then
        self.DeviceScaleFactorList = self.ScaleFactorMap["ipodtouch"]
        self.ScreenPercentList = self.ScreenPercentMap["ipodtouch"]
    else
        self.DeviceScaleFactorList = self.ScaleFactorMap["other"]
        self.ScreenPercentList = self.ScreenPercentMap["other"]
    end
    FLOG_INFO("setting DeviceProfileName:%s, DeviceScaleFactorList:%s, ScreenPercentList:%s"
        , DeviceProfileName, table.tostring(self.DeviceScaleFactorList), table.tostring(self.ScreenPercentList))
        
    self.bIosHighDevice = false
    if self.IsIphoneDevice or self.IsIpadDevice then
        local DefaultQualityLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
        if DefaultQualityLevel >= 3 then    --定级为高、极高的设备
            self.bIosHighDevice = true
            FLOG_INFO("setting is IosHighDevice")
        end
    end

    self:InitAll()
end

function SettingsMgr:OnEnd()
    SettingsUtils.OnEnd()
end

function SettingsMgr:OnShutdown()
    SettingsUtils.OnShutdown()

    --业务系统动态设置 设置项的显隐
    --[SettingID, true/false]
    self.SettingOpenMap = {}
end

function SettingsMgr:IsIosHightDevice()
    return self.bIosHighDevice
end

function SettingsMgr:OnRegisterGameEvent()
    -- SettingsUtils.SettingsTabBase:OnRegisterGameEvent(self)
	self:RegisterGameEvent(EventID.ClientSetupPost, self.OnGameEventClientSetupCallback)  -- 设置在线状态成功的回调
    
    self:RegisterGameEvent(EventID.TutorialSwitch, self.RefreshTutorialState)
    self:RegisterGameEvent(EventID.TutorialGuideSwitch, self.RefreshTutorialGuideState)
    self:RegisterGameEvent(EventID.MajorNeedSelectAttacker, self.OnMajorNeedSelectAttacker)
    self:RegisterGameEvent(EventID.PlayerEnterIdleState, self.OnPlayerEnterIdleState)
    self:RegisterGameEvent(EventID.PWorldReady, self.OnPWorldReady)
    -- self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventExitWorld)
end

function SettingsMgr:RefreshTutorialState(Params)
    if nil == Params or nil == Params.Value then
        return
    end

    local Value = Params.Value
    SettingsUtils.SettingsTabUnCategory:SetTutorialState(Value, false)
end

function SettingsMgr:RefreshTutorialGuideState(Params)
    if nil == Params or nil == Params.Value then
        return
    end

    local Value = Params.Value
    SettingsUtils.SettingsTabUnCategory:SetTutorialGuideState(Value, false)
end

function SettingsMgr:OnMajorNeedSelectAttacker(Params)
    SettingsUtils.SettingsTabBase:OnMajorNeedSelectAttacker(Params)
end

function SettingsMgr:OnPlayerEnterIdleState(Params)
    SettingsUtils.SettingsTabRole:OnPlayerEnterIdleState(Params)
end

---------------------------------------------------------------------------------

--参数是字符串
function SettingsMgr:GetValueBySaveKey(SaveKeyStr)
    local SettingCfg = self.SettingCfgMap[SaveKey[SaveKeyStr]]
    if SettingCfg then
        return SettingsUtils.GetValue(SettingCfg.GetValueFunc, SettingCfg)
    end

    return -1
end

--参数是字符串
function SettingsMgr:GetDefaultValueBySaveKey(SaveKeyStr)
    local SettingCfg = self.SettingCfgMap[SaveKey[SaveKeyStr]]
    if SettingCfg then
        return self:GetDefaultValue(SettingCfg)
    end

    return -1
end


--参数是字符串
function SettingsMgr:GetValueByClientSetupKey(ClientSetupKeyStr)
    local SettingCfg = self.ClientSetupKeyMap[ClientSetupID[ClientSetupKeyStr]]
    if SettingCfg then
        return SettingsUtils.GetValue(SettingCfg.GetValueFunc, SettingCfg)
    end

    return -1
end

--参数是字符串, Value是数值
function SettingsMgr:SetValueBySaveKey(SaveKeyStr, Value)
    local SettingCfg = self.SettingCfgMap[SaveKey[SaveKeyStr]]
    if SettingCfg then
        return SettingsUtils.SetValue(SettingCfg.SetValueFunc, SettingCfg, Value, true)
    end

    return -1
end

--参数是字符串, Value是数值
function SettingsMgr:SetValueByClientSetupKey(ClientSetupKeyStr, Value)
    local SettingCfg = self.ClientSetupKeyMap[ClientSetupID[ClientSetupKeyStr]]
    if SettingCfg then
        return SettingsUtils.SetValue(SettingCfg.SetValueFunc, SettingCfg, Value, true)
    end

    return -1
end

--业务系统动态设置 设置项的显隐
function SettingsMgr:ShowByID(SettingID, bShow)
    self.SettingOpenMap[SettingID] = bShow

    local SettingCfg = SettingsCfg:FindCfgByKey(SettingID)
    if SettingCfg then
        self.SettingIDMap[SettingID] = SettingCfg
    end
end

function SettingsMgr:ShowBySaveKey(SaveKeyStr, bShow)
    local SettingCfg = self.SettingCfgMap[SaveKey[SaveKeyStr]]
    if SettingCfg then
        self.SettingOpenMap[SettingCfg.ID] = bShow
        self.SettingIDMap[SettingCfg.ID] = SettingCfg
    end
end

--获取Value对应的文本内存，得设置项实现函数 GetContentBy***
--  GetContentBy和SaveKeyStr拼接的函数名
--  返回的第2个参数是弹出界面的ViewID
function SettingsMgr:GetContentBySaveKey(SaveKeyStr, Value)
    local SettingCfg = self.SettingCfgMap[SaveKey[SaveKeyStr]]
    if SettingCfg then
        local FunctionName = string.format("GetContentBy%s", SaveKeyStr)
        return SettingsUtils.CallSettingItemFunc(FunctionName, SettingCfg, Value)
    end

    return nil
end

--获取Value对应的文本内存，得设置项实现函数 GetContentBy***
--  GetContentBy和ClientSetupKeyStr拼接的函数名
--  返回的第2个参数是弹出界面的ViewID
function SettingsMgr:GetContentByClientSetupKey(ClientSetupKeyStr, Value)
    local SettingCfg = self.ClientSetupKeyMap[ClientSetupID[ClientSetupKeyStr]]
    if SettingCfg then
        local FunctionName = string.format("GetContentBy%s", ClientSetupKeyStr)
        return SettingsUtils.CallSettingItemFunc(FunctionName, SettingCfg, Value)
    end

    return nil
end

--0-4，如果自定义，则是-1
function SettingsMgr:GetCurQualityLevel()
    local Value = USaveMgr.GetInt(SaveKey.QualityLevel, -1, false)
    local Level = 0
    if Value == -1 then
        Level = _G.UE.USettingUtil.GetDefaultQualityLevel()
        if Level < 0 then
            Level = 0
        end
    elseif self.CustomQualityIndex == Value then
        Level = -1
    else
        if SettingsMgr.IsWithEmulatorMode then
            if Value == 6 then
                Level = 4
            else
                Level = Value - 1
            end
        else
            Level = Value - 1
        end
    end
    
    FLOG_INFO("GetCurQualityLevel: QualityLevel(%d)->%d", Value, Level)
    return Level
end

--获取当前选择的是哪一个index
function SettingsMgr:GetIndexBySaveKey(SaveKeyStr, DefaultIndex)
    local SettingCfg = self.SettingCfgMap[SaveKey[SaveKeyStr]]
    if SettingCfg then
        local Value = SettingsUtils.GetValue(SettingCfg.GetValueFunc, SettingCfg)
        return SettingsUtils.GetDropDownListIndex(Value, SettingCfg)
    end

    return DefaultIndex or 1
end

--设置项里设置的
function SettingsMgr:GetMaxFPSValue()
    local SaveKeyStr = "MaxFPS"
    local SettingCfg = self.SettingCfgMap[SaveKey[SaveKeyStr]]
    if SettingCfg then
        local Value = SettingsUtils.GetValue(SettingCfg.GetValueFunc, SettingCfg)
        return Value or 30
    end

    return 30
end

--给上报提供通用的获取当前Index的接口
--返回-9表示获取出错;    滑杆返回数值，下来列表返回index
function SettingsMgr:GetValueForReport(SaveKeyStr)
    if string.isnilorempty(SaveKeyStr) then
        return -9
    end

    local SaveKeyID = SaveKey[SaveKeyStr]
    if not SaveKeyID then
        return -9
    end
    
    local SettingCfg = self.SettingCfgMap[SaveKey[SaveKeyStr]]
    if SettingCfg then
        if SaveKeyID == SaveKey.QualityLevel then
            return self:GetCurQualityLevel()
        end

        local IsPictureItem = false
        if SettingCfg.DisplayStyle == ItemDisplayStyle.DropDownList and
            SaveKeyID >= SaveKey.AntiAliasingQuality and SaveKeyID <= SaveKey.ActorLod  then
            IsPictureItem = true    --saveint记录的是0-4
        end

        local Value = self.DefauleValueNotSave
        if not self:IsSaveByRoleID(SettingCfg) then
            Value = USaveMgr.GetInt(SaveKeyID, self.DefauleValueNotSave, false)
        else
            Value = USaveMgr.GetInt(SaveKeyID, self.DefauleValueNotSave, true)
        end

        if Value == self.DefauleValueNotSave then
            Value = self:GetDefaultValue(SettingCfg)
        end

        if IsPictureItem then
            Value = SettingsUtils.GetDropDownListIndex(Value, SettingCfg)
        end
        
        return Value
    end

    return -9
end

--收集所有滑杆和下拉列表、调色盘、弹出自定义ui的设置数据进行上报
function SettingsMgr:CollectReportData(StringMap)
    local CfgList = SettingsCfg:FindAllCfg()
    if CfgList then
        -- print("setting =======================================")
        for _, Cfg in ipairs(CfgList) do
            local SaveKeyStr = Cfg.SaveKey
            local Value = self.DefauleValueNotSave
            
            -- if math.fmod(Cfg.ID, 10) == 0 then
            --     print("#### setting ####")
            -- end

		    --IsHide: 0 都显示  1：真机/编辑器下隐藏  2：模拟器下隐藏   3：完全隐藏（真机、模拟器都隐藏）
            local IsHide = true
            if self.IsWithEmulatorMode then
                if Cfg.IsHide == 0 or Cfg.IsHide == 1 then
                    IsHide = false
                end
            else
                if Cfg.IsHide == 0 or Cfg.IsHide == 2 then
                    IsHide = false
                end
            end

            if not IsHide then
                if Cfg.DisplayStyle == ItemDisplayStyle.DropDownList then
                    Value = self:GetValueForReport(SaveKeyStr)
                    if Value ~= -9 then
                    else
                        --只配置了服务器key，没配置SaveKey  --todo
                        Value = SettingsUtils.GetValue(Cfg.GetValueFunc, Cfg)
                    end
                elseif Cfg.DisplayStyle == ItemDisplayStyle.Slider then
                    Value = SettingsUtils.GetValue(Cfg.GetValueFunc, Cfg)
                elseif Cfg.DisplayStyle == ItemDisplayStyle.TextByCustomUI then
                    Value = SettingsUtils.GetValue(Cfg.GetValueFunc, Cfg)
                elseif Cfg.DisplayStyle == ItemDisplayStyle.ColorPalette then
                    Value = SettingsUtils.GetValue(Cfg.GetValueFunc, Cfg)
                end
    
                if string.isnilorempty(SaveKeyStr) then
                    SaveKeyStr = Cfg.ClientSetupKey
                end
                
                if Value ~= self.DefauleValueNotSave then
                    -- FLOG_WARNING("setting ID:%d, key:%s,   Value:%d", Cfg.ID, SaveKeyStr, Value)
                    StringMap:Add(SaveKeyStr, Value)
                end
            end
        end
        -- print("setting =======================================")
    end
end

---------------------------------------------------------------------------------
--- private
---
--初始化，存过的使用SaveMgr保存过的，没存过的使用默认值（DefaultIndex：Value数组中的第几个）
--现在超链接不用考虑默认的，slider、下拉框存储的分别是数值和index，所以都是int
    --这里可以直接检测到是否存过，没存的话，就使用默认值，直接set/让其生效
function SettingsMgr:InitAll()
    if _G.DemoMajorType == 1 then
        return
    end
    
    local CfgList = SettingsCfg:FindAllCfg()
    if CfgList then
        local DefaultQualityLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
        local SavedDefaultQualityLevel = USaveMgr.GetInt(SaveKey.DefaultQualityLevel, -2, false)
        FLOG_INFO("Setting DefaultQualityLevel %d, SavedDefaultQualityLevel %d", DefaultQualityLevel, SavedDefaultQualityLevel)
        local HotReloadQualityLevel = false
        --如果没有对机器定级，也就是没有默认配置，等热更配置的时候，重新按DefaultQualityLevel处理一遍
        if SavedDefaultQualityLevel == -1 and DefaultQualityLevel >= 0
            or SavedDefaultQualityLevel >= 0 and SavedDefaultQualityLevel ~= DefaultQualityLevel then
            HotReloadQualityLevel = true
            FLOG_WARNING("!!!!!!!!! setting HotReloadQualityLevel = true !!!!!!!!!")
        end
        _G.UE.USaveMgr.SetInt(SaveKey.DefaultQualityLevel, DefaultQualityLevel, false)

        for _, Cfg in ipairs(CfgList) do
            if Cfg.DisplayStyle == ItemDisplayStyle.Slider 
                or Cfg.DisplayStyle == ItemDisplayStyle.DropDownList 
                or Cfg.DisplayStyle == ItemDisplayStyle.ColorPalette
                or Cfg.DisplayStyle == ItemDisplayStyle.TextByCustomUI
                or Cfg.DisplayStyle == ItemDisplayStyle.CustonBPEmbed then
                local ClientSetupKeyStr = Cfg.ClientSetupKey
                local SetupKeyID = not string.isnilorempty(ClientSetupKeyStr) and ClientSetupID[ClientSetupKeyStr]
                if SetupKeyID then
                    self.ClientSetupKeyMap[SetupKeyID] = Cfg
                end

                -- if Cfg.ID >= 51 then
                --     return
                -- end
                
                local SaveKeyStr = Cfg.SaveKey
                if not string.isnilorempty(SaveKeyStr) then
                    local SaveKeyID = SaveKey[SaveKeyStr]
                    if SaveKeyID then
                        self.SettingCfgMap[SaveKeyID] = Cfg
    
                        local IsPictureItem = false
                        if SaveKeyID == SaveKey.QualityLevel
                            or SaveKeyID >= SaveKey.AntiAliasingQuality and SaveKeyID <= SaveKey.PictureSaveKeyMax  then
                            IsPictureItem = true
                        end

                        local Value = self.DefauleValueNotSave
                        if not self:IsSaveByRoleID(Cfg) then
                            Value = USaveMgr.GetInt(SaveKeyID, self.DefauleValueNotSave, false)
                        else
                            Value = USaveMgr.GetInt(SaveKeyID, self.DefauleValueNotSave, true)
                        end

                        --如果没有对机器定级，也就是没有默认配置，等热更配置的时候，重新按DefaultQualityLevel处理一遍
                        if HotReloadQualityLevel then
                            if IsPictureItem then
                                FLOG_INFO("     Setting no DefaultQualityLevel, so ID:%d, Set Value %d to :%d"
                                    , Cfg.ID, Value, self.DefauleValueNotSave)
                                Value = self.DefauleValueNotSave
                            end
                        end

                        if Value == self.DefauleValueNotSave or IsPictureItem and Value == -1 then
                            local Value = self:GetDefaultValue(Cfg)
                            if Value ~= self.DefauleValueNotSave then
                                FLOG_INFO("Setting ID:%d, default save Value(Idx):%d", Cfg.ID, Value)
                                SettingsUtils.SetValue(Cfg.SetValueFunc, Cfg, Value, true, true)
                            end
                        else
                            --设置Mgr中的数值，并且游戏设置生效，但不Save
                            FLOG_INFO("Setting ID:%d, get Value:%d", Cfg.ID, Value)
                            SettingsUtils.SetValue(Cfg.SetValueFunc, Cfg, Value, false, true)
                            -- if Cfg.IsScalabilityFeature ~= 1 then
                            -- else
                            --     FLOG_INFO("Setting ID:%d, get Value:%d, IsScalabilityFeature = 1", Cfg.ID, Value)
                            -- end
                        end
                    else
                        FLOG_ERROR("Setting ID:%d, %s not config SaveKey in lua", Cfg.ID, Cfg.Desc)
                    end
                else
                    FLOG_WARNING("Setting ID:%d, %s not config SaveKey in xls", Cfg.ID, Cfg.Desc)
                end
            end
        end

        --所有都处理完之后再手动处理性能模式        
        if self:IsPerforcemanceMode() then
            FLOG_WARNING("setting EnablePerformanceParams After InitAll")
            SettingsUtils.SettingsTabPicture:EnablePerformanceParams(true, false)
        end
    end
    
    self:LoadFpsModeDungeonList()
	-- print("pcw MaxPfS:" .. self:GetValueForReport("MaxFPS"))
	-- print("pcw QualityLevel:" .. self:GetValueForReport("QualityLevel"))
	-- print("pcw TextureQuality:" .. self:GetValueForReport("TextureQuality"))
	-- print("pcw VisionPlayerNum:" .. self:GetValueForReport("VisionPlayerNum"))
	-- print("pcw AntiAliasingQuality:" .. self:GetValueForReport("AntiAliasingQuality"))
	-- print("pcw ShadowQuality:" .. self:GetValueForReport("ShadowQuality"))

    --CommonUtil.ReportPerformanceMetricsData()
end

--当前性能模式正在生效ing
function SettingsMgr:IsPerforcemanceMode()
    local PerformanceMode = _G.SettingsMgr:GetValueBySaveKey("PerformanceMode")
    if PerformanceMode == 2 and not self:IsHidePerforceMode() then
        return true
    end

    return false
end

function SettingsMgr:LoadFpsModeDungeonList()
    if self.FpsModeDungeonList and #self.FpsModeDungeonList > 0 then
        return
    end
    
    local CfgList = DungeonFpsmodeCfg:FindAllCfg()
    if CfgList then
        -- self.DungeonFpsModeMap = {}
        -- self.FpsModeDungeonNum = 0
        self.FpsModeDungeonList = {}

        for _, Cfg in ipairs(CfgList) do
            if _G.ClientVisionMgr:CheckVersionByGlobalVersion(Cfg.VersionName) then
                table.insert(self.FpsModeDungeonList, Cfg.PWorldResID)
            end
        end
    end
end

 function SettingsMgr:GetDefaultValue(Cfg)
    if not Cfg then
        FLOG_ERROR("Setting GetDefaultValue Cfg is nil")
        return -1
    end

    local DefaultValue = -1
    local DefaultIdx = Cfg.DefaultIndex
    if DefaultIdx and DefaultIdx > 0 then
        DefaultValue = DefaultIdx

        --slide：具体的数值
        --下拉框：index
        if Cfg.DisplayStyle == ItemDisplayStyle.Slider then
            DefaultValue = tonumber(Cfg.Value[2]) or 0
        end
    else
        DefaultValue = SettingsUtils.GetDefaultIndex(Cfg.DefaultIndexFunc, Cfg) or -1
    end

    return DefaultValue
 end

--  --最终数据，而不是index（有的默认值是相当于index）
--  function SettingsMgr:GetDefaultRealValue(Cfg)
--     if not Cfg then
--         FLOG_ERROR("Setting GetDefaultValue Cfg is nil")
--         return -1
--     end

--     local DefaultValue = self:GetDefaultValue(Cfg)              --滑杆
--     if Cfg.DisplayStyle == ItemDisplayStyle.DropDownList then   --下拉列表
--     end

--     return DefaultValue
--  end

 --记录在服务器那面的设置
 --     将数据 从服务器同步到本地的设置和SaveMgr，并功能生效
 function SettingsMgr:OnGameEventClientSetupCallback(Params)
    local SettingCfg = self.ClientSetupKeyMap[Params.IntParam1]
    if SettingCfg then
        local Value = Params.StringParam1 or ""
        -- local IsSetCB = Params.BoolParam1
        if not string.isnilorempty(Value) then
            if SettingCfg.DisplayStyle == ItemDisplayStyle.Slider 
                or SettingCfg.DisplayStyle == ItemDisplayStyle.DropDownList
                or SettingCfg.DisplayStyle == ItemDisplayStyle.ColorPalette
                or SettingCfg.DisplayStyle == ItemDisplayStyle.TextByCustomUI
                or SettingCfg.DisplayStyle == ItemDisplayStyle.CustonBPEmbed then
                local IntVal = tonumber(Value)
                if IntVal then
                    SettingsUtils.SetValue(SettingCfg.SetValueFunc, SettingCfg, IntVal, false)
                    USaveMgr.SetInt(SaveKey[SettingCfg.SaveKey], IntVal, true)
                end
            end
        end
    end
end

function SettingsMgr:MakeMCSF(factor)
    return string.format("CVars=r.MobileContentScaleFactor=%f",factor)
end
-- 设置新的device profiles
function SettingsMgr:TrySetMobileContentScaleFactor(new_factor_value)
    local config_mgr = _G.UE.UConfigMgr:Get()
    local active_dp_name = config_mgr:GetActiveDeviceProfileName();

    local default_dp_path = string.format("%s/%s",_G.UE.UPathMgr.ConfigDir(false),"DefaultDeviceProfiles.ini")
    
    local b_load_default_dp_status,loaded_default_dp_str = _G.UE.UFlibAssetManageHelper.LoadFileToString(default_dp_path)
    local default_dp_lines = _G.UE.UKismetStringLibrary.ParseIntoArray(loaded_default_dp_str,"\n",false)
    print("[MCSF] default_dp_path: "..default_dp_path..", read: "..tostring(b_load_default_dp_status)..", lines: "..default_dp_lines:Num())
    
    local match_dp_str = string.format("[%s DeviceProfile]",active_dp_name)
    print("[MCSF] match_dp_str: "..match_dp_str)

    local find_match_dp_strs = ""
    local b_matching = false
    local b_replaced_mcsf = false

    local b_replaced_ssaqx = false
    local b_replaced_ssaqy = false

    for index = 1, default_dp_lines:Num() do
        local line = _G.UE.UKismetStringLibrary.Replace(default_dp_lines[index],"\n","")
        line = _G.UE.UKismetStringLibrary.Trim(line)
        line = _G.UE.UKismetStringLibrary.TrimTrailing(line)

        -- 从匹配的section开始读
        local b_match_mark = _G.UE.UKismetStringLibrary.StartsWith(line,match_dp_str)
        if b_match_mark then
            b_matching = true
            print("[MCSF] begin match! line: "..index)
        end
        -- print(string.format("line: \"%s\" , match: %s",line,tostring(b_match_mark)))
        if b_matching and (not (line == "")) then
            -- 替换.CVars前缀
            local replaced_line =  _G.UE.UKismetStringLibrary.Replace(line,".CVars","CVars")
            replaced_line =  _G.UE.UKismetStringLibrary.Replace(replaced_line,"\n","")
            if _G.UE.UKismetStringLibrary.Contains(replaced_line,"r.MobileContentScaleFactor",false) then
                replaced_line = self:MakeMCSF(new_factor_value)
                b_replaced_mcsf = true
            end

            -- 强制修改r.Mobile.SpotLightShadowAtlasResolutionX/Y为2048（引擎要求）
            if _G.UE.UKismetStringLibrary.Contains(replaced_line,"r.Mobile.SpotLightShadowAtlasResolutionX",false) then
                replaced_line = string.format("CVars=r.Mobile.SpotLightShadowAtlasResolutionX=4096")
                b_replaced_ssaqx = true
            end
            if _G.UE.UKismetStringLibrary.Contains(replaced_line,"r.Mobile.SpotLightShadowAtlasResolutionY",false) then
                replaced_line = string.format("CVars=r.Mobile.SpotLightShadowAtlasResolutionY=4096")
                b_replaced_ssaqy = true
            end

            find_match_dp_strs = string.format("%s\n%s",find_match_dp_strs,replaced_line)
        end
        -- 找到下一个空行为止
        if b_matching and (line == "") then
            b_matching = false
            print("[MCSF] end match! line: "..index)
            -- 如果没有替换mcsf，则插入一个新行
            if not b_replaced_mcsf then
                find_match_dp_strs = string.format("%s\n%s",find_match_dp_strs,self:MakeMCSF(new_factor_value))
            end

            -- 如果没有配这两项，也默认写入
            if not b_replaced_ssaqx then
                find_match_dp_strs = string.format("%s\n%s",find_match_dp_strs,string.format("CVars=r.Mobile.SpotLightShadowAtlasResolutionX=4096"))
            end
            if not b_replaced_ssaqy then
                find_match_dp_strs = string.format("%s\n%s",find_match_dp_strs,string.format("CVars=r.Mobile.SpotLightShadowAtlasResolutionY=4096"))
            end
        end
    end

    saved_config_dp_path = string.format("%s/%s",config_mgr:GetSavedConfigDir(),"DeviceProfiles.ini")
    print("[MCSF] saved_config_dp_path: "..saved_config_dp_path)

    print("[MCSF] find_match_dp_strs: "..find_match_dp_strs)
    b_save_status = _G.UE.UFlibAssetManageHelper.SaveStringToFile(saved_config_dp_path,find_match_dp_strs)
    print("[MCSF] b_save_status: "..tostring(b_save_status))
end

--Level 0-4
function SettingsMgr:RefreshIosHightDeviceParamsByQualityLvl(Level)
    if not Level or Level <= 2 then
        CommonUtil.ConsoleCommand("r.hudztest.enable 0")
        -- CommonUtil.ConsoleCommand("fx.allowgpuparticles 0")
    else
        CommonUtil.ConsoleCommand("r.hudztest.enable 1")
        -- CommonUtil.ConsoleCommand("fx.allowgpuparticles 1")
    end
end

-- 应用画质设置
function SettingsMgr:ApplyPicSetting()
    local NeedRestart = false

    --如果是关闭性能模式，先还原
    if self.IsPerformanceMode == false then
        SettingsUtils.SettingsTabPicture:EnablePerformanceParams(false)
    end

    if self.QulityLevelTmp ~= nil then
        -- _G.UE.USettingUtil.SetQualityLevel(self.QulityLevelTmp)
        NeedRestart = true

        if self.QulityLevelTmp >= 0 and self.QulityLevelTmp < #self.DeviceScaleFactorList then
            local QulityLevelIdx = self.QulityLevelTmp + 1
            local Factor = self.DeviceScaleFactorList[QulityLevelIdx]
            -- _G.UE.UConfigMgr:Get():WriteMobileScaleFactorToSavedConfig(Factor);

            --1. 极高和高的ios机型，切成中， 低和极低的时候，不走当前的scaleFactor数组，直接设置iPhone 极低1.5，低1.5，中1.7， ipad 极低 1， 低 1，中 1
            if self.bIosHighDevice then --从高、极高切到中、低、极低
                if self.QulityLevelTmp <= 2 then
                    local IphoneScaleFactor = {1.5, 1.5, 1.7}
                    local IPadScaleFactor = {1, 1, 1}
                    if self.IsIphoneDevice then
                        Factor = IphoneScaleFactor[QulityLevelIdx]
                    elseif self.IsIpadDevice then
                        Factor = IPadScaleFactor[QulityLevelIdx]
                    end
    
                    --强制设置一次
    
                    --分辨率、 Actor数量 在切画质的那个Set的时候，去for cache就处理了
                end
                
                self:RefreshIosHightDeviceParamsByQualityLvl(self.QulityLevelTmp)
            end

            self:TrySetMobileContentScaleFactor(Factor)
            FLOG_INFO("setting Write config ScaleFactor:%f", Factor)
        else
            FLOG_WARNING("setting DeviceScaleFactorList Error :%s  %d", self.DeviceProfileName, self.QulityLevelTmp)
        end

        if self.IsPerformanceMode == nil then
            --清除下记录的数据，以防有问题没有还原的可能
            SettingsUtils.SettingsTabPicture:ClearRecordPerformanceData()
        end
    end

    if self.PicSettingTmp == nil then
        self.PicSettingTmp = {}
    end

    for k, v in pairs(self.PicSettingTmp) do
        if not table.contain(self.NeedRestartGameFeature,k) then
            self:SetSGFeaturesLevel(k, v.ValueToSet)
            self:OnOneFeatureChanged(k, v.IsLoginInit, v.IsBySelect)
            SettingsUtils.SettingsTabPicture:OverrideSetOnEmulator(k, v.ValueToSet, v.IsLoginInit, v.IsBySelect, v.MaxLvlValue)
        else
            NeedRestart = true
        end
    end

    --如果是打开性能模式，等其他的都设置过了，再设置性能模式的参数
    if self.IsPerformanceMode == true then
        SettingsUtils.SettingsTabPicture:EnablePerformanceParams(true, true)
    end

    self.IsPerformanceMode = nil
    DataReportUtil.ReportSettingData("GameSettingFlow")

    local function Confirm()
        for k, v in pairs(self.PicSettingTmp) do
            if table.contain(self.NeedRestartGameFeature,k) then
                self:SetSGFeaturesLevel(k, v.ValueToSet)
                self:OnOneFeatureChanged(k, v.IsLoginInit, v.IsBySelect)
                SettingsUtils.SettingsTabPicture:OverrideSetOnEmulator(k, v.ValueToSet, v.IsLoginInit, v.IsBySelect, v.MaxLvlValue)
            end
        end

        self.PicSettingTmp = {}
        self.QulityLevelTmp = nil
        CommonUtil.QuitGame()
    end
    
    local function Cancel()
        self.PicSettingTmp = {}
        self.QulityLevelTmp = nil
    end

    if NeedRestart then
        MsgBoxUtil.ShowMsgBoxTwoOp(nil, LSTR(10004),
        LSTR(110010), Confirm, Cancel,
        LSTR(10003), LSTR(10002))
    else
        self.PicSettingTmp = {}
        self.QulityLevelTmp = nil
    end
end

function SettingsMgr:SetSGFeaturesLevel(FeatureID, ValueToSet)
    if FeatureID == 8 then
        -- local DefaultLevel = SettingsUtils.SettingsTabPicture:GetDefaultQualityLevel()
        -- local CmdStr = ""
        -- CmdStr = string.format("r.ScreenPercentage %d", ValueToSet)
        
        _G.UE.USettingUtil.ExeCommand("r.ScreenPercentage", ValueToSet, PriorityConsole)
        -- CommonUtil.ConsoleCommand(CmdStr)
        FLOG_INFO("setting SetSGFeaturesLevel8 r.ScreenPercentage -> %d", ValueToSet)
    elseif FeatureID == 23 then
        if ValueToSet < 15 or ValueToSet > 60 then
            FLOG_ERROR("##Setting SetMaxFPS23 ValueToSet:%d", ValueToSet)
            ValueToSet = 30
        end

        -- local CmdStr = string.format("t.maxfps %d", ValueToSet)
        _G.UE.USettingUtil.ExeCommand("t.maxfps", ValueToSet, Priority)
        -- CommonUtil.ConsoleCommand(CmdStr)
        FLOG_INFO("setting SetSGFeaturesLevel23 t.maxfps -> %d", ValueToSet)
    else
        _G.UE.USettingUtil.SetSGFeaturesLevel(FeatureID, ValueToSet)
    end
end

function SettingsMgr:CachePicSetting(FeatureID, ValueToSet, IsLoginInit, IsBySelect, MaxLvlValue)
    if IsLoginInit then
        self:SetSGFeaturesLevel(FeatureID, ValueToSet)
        SettingsUtils.SettingsTabPicture:OverrideSetOnEmulator(FeatureID, ValueToSet, IsLoginInit, IsBySelect, MaxLvlValue)
    else
        self.PicSettingTmp[FeatureID] = {
            ValueToSet = ValueToSet,
            IsLoginInit = IsLoginInit,
            MaxLvlValue = MaxLvlValue,
            IsBySelect = IsBySelect
        }
    end
    _G.EventMgr:SendEvent(_G.EventID.OnePictureFeatureChg, FeatureID)
end

function SettingsMgr:CacheQulityLevelSetting(Level)
    self.QulityLevelTmp = Level
end

function SettingsMgr:OnOneFeatureChanged(FeatureID, IsLoginInit, IsBySelect)
    SettingsUtils.SettingsTabPicture:OnOneFeatureChanged(FeatureID, IsLoginInit, IsBySelect)
end

function SettingsMgr:IsSaveByRoleID(Cfg)
    if Cfg and Cfg.Category == 6 then
        return false
    end

    return true
end
---------------------------------------------------------------------------------
---

function SettingsMgr:IsFpsModeDungeon()
    local Cnt = #self.FpsModeDungeonList
    if Cnt == 0 then
        return -1, 0
    end

    local PWorldTableCfg = _G.PWorldMgr:GetCurrPWorldTableCfg()
	if PWorldTableCfg and PWorldTableCfg.Type == ProtoRes.pworld_type.PWORLD_CATEGORY_DUNGEON then
        for index = 1, Cnt do
            if self.FpsModeDungeonList[index] == PWorldTableCfg.ID then
                return 1, PWorldTableCfg.ID
            end
        end

        return 0, 0    --普通副本
	end

    return -1, 0 --不是副本
end

-- function SettingsMgr:OnGameEventExitWorld()
--     FLOG_INFO("setting ExitWorld mode:%s", tostring(self.DungeonMode))
--     if self.DungeonMode > 0 then
--         SettingsUtils.SettingsTabPicture:RefreshMaxFps(false, self.DungeonMode)
--     end

--     self.DungeonMode = -1
-- end

function SettingsMgr:IsHidePerforceMode()
    local bHidePerforceMode = false
    
    local IsWithEmulatorMode = _G.UE.UUIMgr.Get():IsWithEmulator()
    if IsWithEmulatorMode then
        return true
    end

	local Platform = CommonUtil.GetPlatformName()
	if Platform == "IOS" then
        return true
    end

    local PerformanceMode = USaveMgr.GetInt(SaveKey.PerformanceMode, -1, false)

    --模拟器、定级为低和极低的、切换到低和极低的中高配机都不会显示性能模式
    local SelectQualityLevel = USaveMgr.GetInt(SaveKey.SelectQualityLevel, -1, false)     --0~4
    local DefaultQualityLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
    FLOG_INFO("setting PerformanceMode:%d, SelectQualityLevel:%d", PerformanceMode, SelectQualityLevel)
    --如果外网已经再玩的手机，这个时候SelectQualityLevel是-1，就不会显示性能模式了
    if SelectQualityLevel == -1 and DefaultQualityLevel <= 1
        or SelectQualityLevel >= 0 and SelectQualityLevel <= 1
        or DefaultQualityLevel <= 1 then
        bHidePerforceMode = true
    end

    return bHidePerforceMode
end

function SettingsMgr:OnPWorldReady()
    SettingsUtils.SettingsTabPicture:RefreshVisionPlayerNum()
    
    -- 不显示性能模式的，肯定不提示
    if self:IsHidePerforceMode() then
        FLOG_INFO("setting OnPWorldReady %d", -1)
        return
    end

    -- 显示了，并且开启了，也不进行提示了
    local PerformanceMode = USaveMgr.GetInt(SaveKey.PerformanceMode, -1, false)
    if PerformanceMode == 2 then
        FLOG_INFO("setting OnPWorldReady %d", -2)
        return
    end
    
    -- 显示了，但是没开的才进入下一步：副本相关判定
    local bFpsModeDugeon, PWorldResID = self:IsFpsModeDungeon()
    --是副本列表中的
    if bFpsModeDugeon == 1 and PWorldResID then
        local PWorldID1 = USaveMgr.GetInt(SaveKey.PerformanceTipPWorldResID1, -1, false)
        local PWorldID2 = USaveMgr.GetInt(SaveKey.PerformanceTipPWorldResID2, -1, false)
        FLOG_INFO("setting OnPWorldReady CurPWorld:%d, RecordID1:%d, RecordID2:%d", PWorldResID, PWorldID1, PWorldID2)
        if PWorldResID == PWorldID1 or PWorldResID == PWorldID2 or PWorldID1 > 0 and PWorldID2 > 0 then
            --已经进入过或者 已经进入过2次不同的副本了
            --所以就不用触发提示了
            return
        end

        if PWorldID1 == -1 then
            USaveMgr.SetInt(SaveKey.PerformanceTipPWorldResID1, PWorldResID, false)
        elseif PWorldID2 == -1 then
            USaveMgr.SetInt(SaveKey.PerformanceTipPWorldResID2, PWorldResID, false)
        end

        --进行弹窗提示
        FLOG_WARNING("setting to select PerformanceMode")
        _G.UIViewMgr:ShowView(_G.UIViewID.SettingsFPSMode)
    end
end

function SettingsMgr:HaveFpsModeDungeon()
    if self.FpsModeDungeonList and #self.FpsModeDungeonList > 0 then
        return true
    end

    return false
end

---------------------------------------------------------------------------------
---
function SettingsMgr:PerformanceMode()
    FLOG_INFO("==============SettingsMgr:PerformanceMode()")
    
    --视口距离
    CommonUtil.ConsoleCommand("r.ViewDistanceScale 0.9")
    local UKismetSystemLibrary = _G.UE.UKismetSystemLibrary
    
    FLOG_INFO("PostProcessAAQuality:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.PostProcessAAQuality"))
    FLOG_INFO("MaxCSMResolution:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.Shadow.MaxCSMResolution"))
    FLOG_INFO("ShadowQuality:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.ShadowQuality"))
    FLOG_INFO("AOQuality:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.AOQuality"))
    FLOG_INFO("FarShadowMapEnable:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.Mobile.FarShadowMapEnable"))
    FLOG_INFO("HDSelfShadowMapEnable:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.Mobile.HDSelfShadowMapEnable"))
    FLOG_INFO("EnableSpotLightShadowResolutionRate:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.Mobile.EnableSpotLightShadowResolutionRate"))

    FLOG_INFO("Tonemapper:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.Tonemapper.Quality"))
    FLOG_INFO("DepthOfFieldQuality:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.DepthOfFieldQuality"))
    FLOG_INFO("LightShaftQuality:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.LightShaftQuality"))
    
    FLOG_INFO("ScreenPercentage:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.ScreenPercentage"))
    FLOG_INFO("maxfps:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.maxfps"))

    local USettingUtil = _G.UE.USettingUtil
        --抗锯齿
        USettingUtil.ExeCommand("r.PostProcessAAQuality", 0, Priority)

        --阴影质量
        USettingUtil.ExeCommand("r.Shadow.MaxCSMResolution", 1024, Priority)
        USettingUtil.ExeCommand("r.ShadowQuality", 3, Priority)
        USettingUtil.ExeCommand("r.AOQuality", 0, Priority)
        USettingUtil.ExeCommand("r.Mobile.FarShadowMapEnable", 0, Priority)
        USettingUtil.ExeCommand("r.Mobile.HDSelfShadowMapEnable", 0, Priority)
        USettingUtil.ExeCommand("r.Mobile.EnableSpotLightShadowResolutionRate", 0, Priority)
    
        --后处理
        USettingUtil.ExeCommand("r.Tonemapper.Quality", 2, Priority)
        USettingUtil.ExeCommand("r.DepthOfFieldQuality", 0, Priority)
        USettingUtil.ExeCommand("r.LightShaftQuality", 0, Priority)
    
        --偏移
        EffectUtil.SetQualityLevelFXLOD(1)      --特效LOD
        EffectUtil.SetWorldEffectMaxCount(0)    --特效最大数量（非强显特效
    
        --分辨率
        USettingUtil.ExeCommand("r.ScreenPercentage", 75, PriorityConsole)
        --帧率
        USettingUtil.ExeCommand("t.maxfps", 30, Priority)

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

    FLOG_INFO("PostProcessAAQuality:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.PostProcessAAQuality"))
    FLOG_INFO("MaxCSMResolution:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.Shadow.MaxCSMResolution"))
    FLOG_INFO("ShadowQuality:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.ShadowQuality"))
    FLOG_INFO("AOQuality:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.AOQuality"))
    FLOG_INFO("FarShadowMapEnable:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.Mobile.FarShadowMapEnable"))
    FLOG_INFO("HDSelfShadowMapEnable:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.Mobile.HDSelfShadowMapEnable"))
    FLOG_INFO("EnableSpotLightShadowResolutionRate:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.Mobile.EnableSpotLightShadowResolutionRate"))

    FLOG_INFO("Tonemapper:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.Tonemapper.Quality"))
    FLOG_INFO("DepthOfFieldQuality:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.DepthOfFieldQuality"))
    FLOG_INFO("LightShaftQuality:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.LightShaftQuality"))
    
    FLOG_INFO("ScreenPercentage:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.ScreenPercentage"))
    FLOG_INFO("maxfps:%d", UKismetSystemLibrary.GetConsoleVariableIntValue("r.maxfps"))
end

return SettingsMgr