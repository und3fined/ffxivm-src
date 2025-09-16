-- local WeatherUtil = require("Game/Weather/WeatherUtil")
-- local WeatherForecastCfg = require("TableCfg/WeatherForecastCfg")
-- local MapWeatherCfg = require("TableCfg/MapWeatherCfg")
-- local WeatherVM = require("Game/Weather/WeatherVM")

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require ("Protocol/ProtoRes")
local WeatherDefine = require("Game/Weather/WeatherDefine")
local TimeUtil = require("Utils/TimeUtil")
local CommonUtil = require("Utils/CommonUtil")
local TimeDefine = require("Define/TimeDefine")
local AozyTimeDefine = TimeDefine.AozyTimeDefine
local Weather = require("Game/Weather/Weather")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local WeatherService = require("Game/Weather/WeatherService")
local WeatherFuncCfg = require("TableCfg/WeatherFuncCfg")
local RareWeatherCfg = require("TableCfg/WeatherRareCfg")
local PworldCfg = require("TableCfg/PworldCfg")

local CS_CMD = ProtoCS.CS_CMD
local CS_SUB_CMD_FURTURE = ProtoCS.WeatherCmd.WeatherCmdFuture

local EventMgr = _G.EventMgr
local EventID = _G.EventID
local PWorldMgr = _G.PWorldMgr
local MapMgr = _G.MapMgr

local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

local WeatherMgr = LuaClass(MgrBase)

function WeatherMgr:OnBegin()
    self.WeatherForcast = {}
    self.WeatherForcastServer = {}
    self.MapTableCfg = PWorldMgr:GetAllPworldTableCfg()
    self.WeatherRareCfg = RareWeatherCfg:FindAllCfg()
    --美术特别需求，默认所有地图天气为碧空，正常天气流转需要用GM命令解锁
    self.InLevelTime = 0 --关卡驻留时间
    self.EnableDetermineTriggerMapEffectWithInLevelTime = 0 --是否触发场景特效判断驻留时间到期时
    self.EnableVaryWeatherEffect = false --可播放场景特效的时机
    self.UpdateVaryWeatherEffectHour = -1
    self.MapID = nil
    self.NeedAdjustWeatherData = false
    self.NeedOpenForcastUI = false
    self.UpdateWeatherTimer = nil
    self.NextUpdateWeatherServerTime = 0
end

function WeatherMgr:OnEnd()
    if self.UpdateWeatherTimer ~= nil then
        self:UnRegisterTimer(self.UpdateWeatherTimer)
        self.UpdateWeatherTimer = nil
    end
end

function WeatherMgr:OnShutdown()
end

function WeatherMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MapChanged, self.OnGameEventMapChange)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)
    self:RegisterGameEvent(EventID.WorldPostLoad, self.OnWorldPostLoad)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventExitWorld)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldEnter)
end

function WeatherMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_WEATHER, CS_SUB_CMD_FURTURE, self.RspWeatherForecast)
end

function WeatherMgr:OnGameEventLoginRes()
    self:SendWeatherForcastReq()
end

function WeatherMgr:OnGameEventExitWorld()
    self.EnableVaryWeatherEffect = false
    self:SetClientWeather(Weather.WeatherInfo.INVALID_WEATHER_ID,2.0,0,false)
end

function WeatherMgr:OnWorldPostLoad()
    self.EnableVaryWeatherEffect = false
end

function WeatherMgr:OnGameEventPWorldExit(Params)
    self.ClientWeather:Disable()
    self.ServerWeather:Disable()
end

function WeatherMgr:OnGameEventPWorldEnter(Params)
    local MapID = PWorldMgr:GetCurrMapResID()

    --本地切地图
    if MapID == self.MapID then
        --从不同的地图切回来的
        if Params.bChangeMap then
            local PEnvMgrInstance = _G.UE.UEnvMgr:Get()

            --if self.CutWeatherId == 0 then
            if #self.CutWeatherIdStack == 0 then
                --恢复当前地图天气
                PEnvMgrInstance:SetWeather(self.GraphicWeather_,0.0)

                if self:GetActiveWeather() == self.ServerWeather then
                    PEnvMgrInstance:SetDesireAsyoTime(self.ServerWeather.SettingCurrentAysoTime_,self.ServerWeather.IsFixed_)
                elseif self:GetActiveWeather() == self.ClientWeather then
                    PEnvMgrInstance:SetDesireAsyoTime(self.ClientWeather.SettingCurrentAysoTime_,self.ClientWeather.IsFixed_)
                end
            else
                local CutWeatherInfo = self.CutWeatherIdStack[#self.CutWeatherIdStack]
                PEnvMgrInstance:SetWeather(CutWeatherInfo[1],0.0)
                PEnvMgrInstance:SetDesireAsyoTime(CutWeatherInfo[2],CutWeatherInfo[3])
                --PEnvMgrInstance:SetWeather(self.CutWeatherId,0.0)
                --PEnvMgrInstance:SetDesireAsyoTime(self.CutTime,true)
            end
        end
    end

    self.MapID = MapID
end

function WeatherMgr:SendWeatherForcastReq()
    local MsgID = CS_CMD.CS_CMD_WEATHER
    local SubMsgID = CS_SUB_CMD_FURTURE
    ---local MapTableCfg = PWorldMgr:GetAllPworldTableCfg()
    local MapIDList = {}

    for _, Value in ipairs(self.MapTableCfg) do
        if Value and not table.empty(Value.MapList) then
            local MapID = Value.MapList[1]
            local MapType = Value.Type

            if MapType == ProtoRes.pworld_type.PWORLD_CATEGORY_MAIN_CITY or MapType == ProtoRes.pworld_type.PWORLD_CATEGORY_FIELD then
                table.insert(MapIDList,MapID)
            end
        end
    end

    if MapIDList ~= {} then
        local MsgBody = {}
        MsgBody.Cmd = SubMsgID
        MsgBody.Future = { MapResIDs = MapIDList }

        GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    end
end

function WeatherMgr:RspWeatherForecast(MsgBody)
    local _ <close> = CommonUtil.MakeProfileTag("[Weather][WeatherMgr][RspWeatherForecast]")

    local Msg = MsgBody.Future

    if nil == Msg then
        return
    end

    self.WeatherForcast = {}
    local Hour = TimeUtil.GetAozyHour()
    local StartDay = TimeUtil.GetAozyDay()
    local Start = 1
    local HourStr = {"-0","-8","-16"}

    --开始时间要减去二个时间段
    if Hour < 8 then
        Start = 2
        StartDay = StartDay - 1
    elseif Hour >= 8 and Hour < 16 then
        Start = 3
        StartDay = StartDay - 1
    else
        Start = 1
    end

    for k,v in pairs(Msg.Futures) do
        local MapWeather = {}
        local Size = #v.Weathers
        local Day = StartDay
        local StartTime = Start

        for i=1,Size do
            local WeatherDay = Day * 10 + StartTime
            MapWeather[WeatherDay] = v.Weathers[i]

            if StartTime == 3 then
                Day = Day + 1
                StartTime = 1
            else
                StartTime = StartTime + 1
            end
        end

        self.WeatherForcast[v.MapResID] = MapWeather
        self.WeatherForcastServer[v.MapResID] = v.Weathers
    end

    self.NeedAdjustWeatherData = false

    if self.NeedOpenForcastUI == true then
        --如果之前需要同步消息才打开界面这里收到消息需要打开界面
        self.NeedOpenForcastUI = false
        UIViewMgr:ShowView(UIViewID.WeatherForecastMainPanel, {Source = WeatherDefine.Source.Map})
    end

    _G.FLOG_INFO('[Weather][WeatherMgr][RspWeatherForecast]')
    _G.WeatherVM:UpdRegionOptimal()
end

function WeatherMgr:OnRegisterTimer()
    self:RegisterTimer(self.OnUpdate, 0, 0.2, 0)
    self:StartUpdateTimer()
end

function WeatherMgr:OnGameEventMapChange(Params)
    local MapID = PWorldMgr:GetCurrMapResID()
    local PWorldResID = PWorldMgr:GetCurrPWorldResID()
    local Type = PworldCfg:FindValue(PWorldResID, "Type")

    FLOG_INFO("OnGameEventMapChange MapID = %d",MapID)

    local Weather = {}

    --野外和主城查天气预报
    if ProtoRes.pworld_type.PWORLD_CATEGORY_MAIN_CITY == Type or ProtoRes.pworld_type.PWORLD_CATEGORY_FIELD == Type then
        --新手村乌尔达哈特殊处理一下
        if MapID == 6020 or (MapID >= 2106 and MapID <= 2114) then
            Weather = self:GetWeatherAndParams(MapID,false,0)
        else
            Weather = self:GetWeatherAndParams(MapID,true,0)
        end
    else
        Weather = self:GetWeatherAndParams(MapID,false,0)
    end

    local WeatherID = Weather[1]
    local WeatherParams = Weather[2]
    self:ZoneInit(WeatherID,false,WeatherParams)
end

function WeatherMgr:OpenWeahterForecastUI(Params)
    --需要重新同步天气信息
    if self.NeedAdjustWeatherData then
        self:SendWeatherForcastReq()
        self.NeedOpenForcastUI = true
    else
        UIViewMgr:ShowView(UIViewID.WeatherForecastMainPanel, Params or {Source = WeatherDefine.Source.Default})
    end
end

function WeatherMgr:Ctor()
    -- body
    self.ServerWeather = Weather.New()
    self.ClientWeather = Weather.New()
    self.ClientWeatherId = Weather.WeatherInfo.INVALID_WEATHER_ID
    self.GraphicWeather_ = Weather.WeatherInfo.INVALID_WEATHER_ID
    self.NextUpdateTime_ = -1
    self.IndividualWeather = Weather.WeatherInfo.EXD_INDIVIDUAL_WEATHER_INVALID
    self.NeedUpdateIndividualWeather = false
    self.InstantIndividualWeather = false
    self.CutWeatherId = Weather.WeatherInfo.INVALID_WEATHER_ID
    self.CutWeatherIdStack = {}
end

function WeatherMgr:OnInit()
    self.GraphicWeather_ = Weather.WeatherInfo.INVALID_WEATHER_ID
    self.NextUpdateTime_ = -1
    self.IndividualWeather = Weather.WeatherInfo.EXD_INDIVIDUAL_WEATHER_INVALID
    self.NeedUpdateIndividualWeather = false
    self.InstantIndividualWeather = false
end

-- Aozy时间 8小时刷新一次
local UpdDelta = AozyTimeDefine.AozyHour2RealSec * 8
-- 抛消息时延
local NtfDelay = 1
function WeatherMgr:StartUpdateTimer()
    local Now = TimeUtil.GetServerTime()
    -- 下次更新时间 = 轮换时间 - （当前时间戳 - 上次更新时间戳）
    local Delta = UpdDelta - (Now % UpdDelta)
    self.NextUpdateWeatherServerTime = Now + Delta + 1
    --self.UpdateWeatherTimer = self:RegisterTimer(self.OnTimer, Delta, 0, 1)
end

function WeatherMgr:NextUpdateTimer()
    if self.UpdateWeatherTimer ~= nil then
        self:UnRegisterTimer(self.UpdateWeatherTimer)
        self.UpdateWeatherTimer = nil
    end

    self.UpdateWeatherTimer = self:RegisterTimer(self.OnTimer, UpdDelta, 0, 1)
end

function WeatherMgr:OnTimer(Seconds)
    -- print("zhg send OnTimer")
    --self:SendWeatherForcastReq()

    self.NeedAdjustWeatherData = true

    ---8小时变更一下天气
    if _G.PWorldMgr.BaseInfo == nil or table.empty(_G.PWorldMgr.BaseInfo) then
        --self:NextUpdateTimer()
        local Now = TimeUtil.GetServerTime()
        local Delta = UpdDelta - (Now % UpdDelta)
        self.NextUpdateWeatherServerTime = Now + Delta + 1
        return
    end

    FLOG_INFO("Update Weather on Timer")

    local Number = Seconds / UpdDelta
    Number = math.floor(Number) + 1

    --删除第一个时间
    while (Number > 0) do
        self:PopFirstWeather()
        Number = Number - 1
    end

    local MapID = _G.PWorldMgr.BaseInfo.CurrMapResID
    local PWorldResID = PWorldMgr:GetCurrPWorldResID()
    local Type = PworldCfg:FindValue(PWorldResID, "Type")
    local Weather = {}

    --野外和主城查天气预报(取下一个天气因为这里还没有收到服务器回包)
    if ProtoRes.pworld_type.PWORLD_CATEGORY_MAIN_CITY == Type or ProtoRes.pworld_type.PWORLD_CATEGORY_FIELD == Type then
    --新手村乌尔达哈特殊处理一下
        if MapID == 6020 then
            Weather = self:GetWeatherAndParams(MapID,false,0)
        else
            Weather = self:GetWeatherAndParams(MapID,true,0)
        end
    else
        Weather = self:GetWeatherAndParams(MapID,false,0)
    end

    local WeatherID = Weather[1]
    local WeatherParams = Weather[2]
    local CurrentWeatherTime = 0
    local IsFixed = false

    if #WeatherParams > 0 then
        CurrentWeatherTime = WeatherParams[1]
        IsFixed = WeatherParams[2] == 1 or false
    end

    --MapMgr:UpdateWeather(WeatherID)

    self:SetServerWeather(WeatherID,20.0,false,CurrentWeatherTime,IsFixed)

    self:RegisterTimer(function()
    EventMgr:SendEvent(EventID.UpdateWeatherForecast)

    end, NtfDelay, 0, 1)

    --self:NextUpdateTimer()
    end

function WeatherMgr:OnUpdate()
    self:UpdateIndividualWeather()

    self.ServerWeather:OnUpdate(0.2)
    self.ClientWeather:OnUpdate(0.2)

    local Now = TimeUtil.GetServerTime()
    --超过更新的系统时间则需要换天气
    if self.NextUpdateWeatherServerTime > 0 and self.NextUpdateWeatherServerTime - Now <= 0 then
        local Val = Now - self.NextUpdateWeatherServerTime
        self:OnTimer(Val)
        local Delta = UpdDelta - (Now % UpdDelta)
        self.NextUpdateWeatherServerTime = Now + Delta + 1
    end

    --if self.CutWeatherId > Weather.WeatherInfo.DEFAULT_WEATHER_ID then
    if #self.CutWeatherIdStack > 0 then
        return
    end

    local InvalidWeatherID = Weather.WeatherInfo.INVALID_WEATHER_ID
    local NextWeatherID = Weather.WeatherInfo.INVALID_WEATHER_ID
    local Weather = nil

    if self:GetActiveWeather() == self.ServerWeather then
        if not self.ServerWeather:GetIsContent() then
            NextWeatherID = self.ClientWeatherId

            if NextWeatherID == InvalidWeatherID then
                NextWeatherID = self.ServerWeather:GetNextWeatherId()
            end
            Weather = self.ServerWeather
        end
    elseif self:GetActiveWeather() == self.ClientWeather then
        NextWeatherID = self.ClientWeather:GetNextWeatherId()
        Weather = self.ClientWeather

        ---本地天气结束了
        if NextWeatherID == Weather.WeatherInfo.INVALID_WEATHER_ID then
            local TransitionTime = Weather:GetGraphicTransitionTime()
            if not self.ServerWeather:GetIsContent() then
                NextWeatherID = self.ClientWeatherId

                if NextWeatherID == InvalidWeatherID then
                    NextWeatherID = self.ServerWeather:GetNextWeatherId()
                end
            else
                NextWeatherID = self.ServerWeather:GetNextWeatherId()
            end

            Weather = self.ServerWeather
            Weather:SetGraphicTransitionTime(TransitionTime)
        end
    end

    self.InLevelTime = self.InLevelTime + 0.2

    if self.EnableVaryWeatherEffect then
        if self.EnableDetermineTriggerMapEffectWithInLevelTime > 0 then
            if self.InLevelTime >= self.EnableDetermineTriggerMapEffectWithInLevelTime then
                self:PlayMapEffect()
                self.EnableDetermineTriggerMapEffectWithInLevelTime = 0
                self.UpdateVaryWeatherEffectHour = -1
            end
        else
            --每小时判断一次是否可播罕见天气特效，如果失败，下一个小时继续
            local Hour = TimeUtil.GetAozyHour()

            if Hour == self.UpdateVaryWeatherEffectHour then
                --进地图更新一下罕见天气
                if not self:UpdateRareWeather() then
                    self.UpdateVaryWeatherEffectHour = (TimeUtil.GetAozyHour() + 1) % 24
                else
                    self.UpdateVaryWeatherEffectHour = -1 --这张图已经播过特效了，就不用再播了
                end
            end
        end
    end

    local IsChange = (NextWeatherID ~= self.GraphicWeather_)

    if IsChange then
        ---设置天气变更
        self.GraphicWeather_ = NextWeatherID
        self.InstantIndividualWeather = false

        if Weather ~= nil then
            Weather:SetCppWeather()
            MapMgr:UpdateWeather(self.GraphicWeather_)
        end
    end
end

function WeatherMgr:GetWeatherFuncParams(WeatherPlanID)
    local Params = {}
    local Cfg = WeatherFuncCfg:FindCfgByKey(WeatherPlanID)

    if Cfg ~= nil then
        table.insert(Params,Cfg.StartFrameNumber)
        table.insert(Params,Cfg.LockTime)
        return Params
    end

    return Params
end

function WeatherMgr:PopFirstWeather()
    if self.WeatherForcast ~= nil then
        if table.length(self.WeatherForcast) > 0 then
            for MapId,v in pairs(self.WeatherForcast) do
                local Weathers = self.WeatherForcastServer[MapId]

                for k,val in pairs(Weathers) do
                    Weathers[k] = nil
                    break
                end
            end
        end
    end
end

function WeatherMgr:GetForcastWeatherID(MapID,Offset)
    if self.WeatherForcast[MapID] ~= nil then
        local Weathers = self.WeatherForcastServer[MapID]
        local index = -2

        for _,v in pairs(Weathers) do
            if index == Offset then
                return v.WeatherIndex
            end

            index = index + 1
        end
    end

    return Weather.WeatherInfo.EXD_WEATHER_SUNY
end

--获得特定变化段天气
function WeatherMgr:GetVaryTimeWeather(VaryTime,MapID)
    if self.WeatherForcast[MapID] ~= nil then
        local Weathers = self.WeatherForcast[MapID]
        local Day = TimeUtil.GetAozyDay()
        local Now

        if VaryTime < 8 then
            Now = Day * 10 + 1
            --Now = tostring(Day).."-0"
        elseif VaryTime >= 8 and VaryTime < 16 then
            Now = Day * 10 + 2
            --Now = tostring(Day).."-8"
        else
            Now = Day * 10 + 3
            --Now = tostring(Day).."-16"
        end

        for k,v in pairs(Weathers) do
            if k == Now then
                return v.WeatherIndex
            end
        end

        FLOG_ERROR(string.format("Error: WeatherMgr GetVaryTimeWeather day = %d and hour = %d,is not exist", Day,VaryTime))
        return Weather.WeatherInfo.EXD_WEATHER_SUNY
    else
        local Hour = TimeUtil.GetAozyHour()

        local Cfg = _G.PWorldMgr:GetMapTableCfg(MapID)
        if not Cfg then
            return Weather.WeatherInfo.EXD_WEATHER_SUNY
        end

        local OffsetHour = Hour - VaryTime

        local WeatherPlanID = tonumber(Cfg.WeatherPlanID)
        local T = TimeUtil.GetServerTime() - AozyTimeDefine.AozyHour2RealSec * OffsetHour --上一个天气时间的服务器时间
        local WeatherID = WeatherService.GetWeather(WeatherPlanID, WeatherService.GetWeatherRate(T))
        return WeatherID
    end
end

function WeatherMgr:GetPreWeather(MapID)
    if self.WeatherForcastServer[MapID] ~= nil then
        local WeatherID = self:GetForcastWeatherID(MapID, -1)
        return {WeatherID,{}}
    else
        local Cfg = _G.PWorldMgr:GetMapTableCfg(MapID)
        if not Cfg then
            return Weather.WeatherInfo.EXD_WEATHER_SUNY
        end

        local WeatherPlanID = tonumber(Cfg.WeatherPlanID)
        local T = TimeUtil.GetServerTime() - AozyTimeDefine.AozyHour2RealSec * 8 --上一个天气时间的服务器时间
        local WeatherID = WeatherService.GetWeather(WeatherPlanID, WeatherService.GetWeatherRate(T))
        return WeatherID
    end
end

--- 根据地图id获取当前天气ID todo 少波那边改完删除
function WeatherMgr:GetWeatherAndParams(MapID,NeedFindForcast,Index)
    ---return WeatherUtil.GetMapWeather(MapID, 0)

    local Hour = TimeUtil.GetAozyHour()
    local Day = TimeUtil.GetAozyDay()

    local Cfg = _G.PWorldMgr:GetMapTableCfg(MapID)

    ---如果MAPID中填了FatherWeatherPlan则说明他的天气方案用的是对应ID的地图的天气方案
    if Cfg ~= nil and Cfg.FatherWeatherPlan > 0 and not NeedFindForcast then
        local FatherWeatherPlanID = tonumber(Cfg.FatherWeatherPlan)

        if FatherWeatherPlanID > 0 then
            MapID = FatherWeatherPlanID
            NeedFindForcast = true
        end
    end

    if NeedFindForcast == true then
        if self.WeatherForcastServer[MapID] ~= nil then
            local WeatherID = self:GetForcastWeatherID(MapID, Index)
            return {WeatherID,{}}
        end

        FLOG_ERROR(string.format("Error: WeatherMgr GetWeatherNow day = %d and hour = %d,is not exist", Day,Hour))
        return {Weather.WeatherInfo.EXD_WEATHER_SUNY,{}}
    else
        if not Cfg then
            FLOG_ERROR(string.format("Error: WeatherUtil GetMapWeather mapID = %d is not exist", MapID))
            return {Weather.WeatherInfo.EXD_WEATHER_SUNY,{}}
        end

        local WeatherPlanID = tonumber(Cfg.WeatherPlanID)

        if WeatherPlanID == nil then
            WeatherPlanID = 0
        end

        -- 每次天气轮换是 AOZY时间的8个小时
        local T = TimeUtil.GetServerTime()
        local WeatherID = WeatherService.GetWeather(WeatherPlanID, WeatherService.GetWeatherRate(T))
        local Params = self:GetWeatherFuncParams(WeatherPlanID)
        return {WeatherID,Params}
    end
end

function WeatherMgr:ZoneInit(WeatherID,IsContent,WeatherParams)
    self.ServerWeather:ZoneInit(WeatherID,IsContent,WeatherParams)
    self.GraphicWeather_ = WeatherID

    MapMgr:UpdateWeather(WeatherID)

    self:RegisterTimer(function()
        EventMgr:SendEvent(EventID.UpdateWeatherForecast)

    end, NtfDelay, 0, 1)

    self.InLevelTime = 0
    self.EnableDetermineTriggerMapEffectWithInLevelTime = 0
    --self.UpdateVaryWeatherEffectHour = 0

    --进地图更新一下罕见天气
    --if not self:UpdateRareWeather() then
    --self.UpdateVaryWeatherEffectHour = (TimeUtil.GetAozyHour() + 1) % 24
    --else
    -- self.UpdateVaryWeatherEffectHour = -1 --这张图已经播过特效了，就不用再播了
    -- end
end

function WeatherMgr:SetServerWeather(WeatherID,TransitionTime,IsContent,Time,IsFixed)
    local WeatherID = WeatherID or Weather.WeatherInfo.INVALID_WEATHER_ID
    local TransitionTime = TransitionTime or 0.0
    local IsContent = IsContent or false
    self.ServerWeather:SetWeather(WeatherID,TransitionTime,IsContent,Time,IsFixed)
end

--设置默认碧空天气，这里的逻辑与正常CLIENT天气有些不一样，需要用到WEATHERPLANID为0方案
function WeatherMgr:SetClientWeatherPlanWithFindParams(WeatherPlanID)
    if WeatherPlanID ~= nil and WeatherPlanID > 0 then
        local T = TimeUtil.GetServerTime() * AozyTimeDefine.AozyHour2RealSec * 8
        local WeatherID = WeatherService.GetWeather(WeatherPlanID, WeatherService.GetWeatherRate(T))
        local WeatherParams = self:GetWeatherFuncParams(WeatherPlanID)
        local CurrentWeatherTime = 0
        local IsFixed

        if #WeatherParams > 0 then
            CurrentWeatherTime = WeatherParams[1]
            IsFixed = WeatherParams[2] == 1 or false
            self:SetClientWeather(WeatherID,2.0,CurrentWeatherTime,IsFixed)
        else
            self:SetClientWeather(WeatherID,2.0,0,false)
        end
    else
        ---WeatherPlanID为0意为取消client weather
        local WeatherID = self.ClientWeather:GetWeatherId()

        if WeatherID ~= Weather.WeatherInfo.INVALID_WEATHER_ID then
            self:SetClientWeather(Weather.WeatherInfo.INVALID_WEATHER_ID,2.0,0,false)
        end
    end
end

function WeatherMgr:PlaySpecialClientWeatherEffect(WeatherID,TransitionTime,Time,IsFixed)
    local WeatherID = WeatherID or Weather.WeatherInfo.INVALID_WEATHER_ID
    local TransitionTime = TransitionTime or 0.0
    self.ClientWeather:PlaySpecialWeatherEffect(WeatherID,TransitionTime,Time,IsFixed)
end

function WeatherMgr:SetClientWeather(WeatherID,TransitionTime,Time,IsFixed)
    local WeatherID = WeatherID or Weather.WeatherInfo.INVALID_WEATHER_ID
    local TransitionTime = TransitionTime or 0.0
    self.ClientWeather:SetWeather(WeatherID,TransitionTime,false,Time,IsFixed)
end

function WeatherMgr:RestoreCutSceneWeather()
    local PEnvMgrInstance = _G.UE.UEnvMgr:Get()

    if #self.CutWeatherIdStack > 0 then
        table.remove(self.CutWeatherIdStack,#self.CutWeatherIdStack)
    end

    if #self.CutWeatherIdStack > 0 then
        local CutWeatherInfo = self.CutWeatherIdStack[#self.CutWeatherIdStack]
        self.CutWeatherId = CutWeatherInfo[1]
        PEnvMgrInstance:SetWeather(CutWeatherInfo[1],2.0)
        PEnvMgrInstance:SetDesireAsyoTime(CutWeatherInfo[2],CutWeatherInfo[3])
    else
        PEnvMgrInstance:SetWeather(self.GraphicWeather_,0.0)
        self.CutWeatherId = 0
        self.CutWeatherIdStack = {}

        if self:GetActiveWeather() == self.ServerWeather then
            PEnvMgrInstance:SetDesireAsyoTime(self.ServerWeather.SettingCurrentAysoTime_,self.ServerWeather.IsFixed_)
        elseif self:GetActiveWeather() == self.ClientWeather then
            PEnvMgrInstance:SetDesireAsyoTime(self.ClientWeather.SettingCurrentAysoTime_,self.ClientWeather.IsFixed_)
        end
    end
end

function WeatherMgr:SetCutSceneWeather(WeatherID,TransitionTime,Time,IsFixed)
    local PEnvMgrInstance = _G.UE.UEnvMgr:Get()
    self.CutWeatherId = WeatherID

   if WeatherID > 0 then
       table.insert(self.CutWeatherIdStack,{WeatherID,Time,IsFixed})
    --else
        --table.remove(self.CutWeatherIdStack,#self.CutWeatherIdStack)
   end

    self.CutTime = Time

    --恢复游戏天气
    if WeatherID == Weather.WeatherInfo.INVALID_WEATHER_ID then
        PEnvMgrInstance:SetWeather(self.GraphicWeather_,0.0)
        self.CutWeatherIdStack = {}

        if self:GetActiveWeather() == self.ServerWeather then
            PEnvMgrInstance:SetDesireAsyoTime(self.ServerWeather.SettingCurrentAysoTime_,self.ServerWeather.IsFixed_)
        elseif self:GetActiveWeather() == self.ClientWeather then
            PEnvMgrInstance:SetDesireAsyoTime(self.ClientWeather.SettingCurrentAysoTime_,self.ClientWeather.IsFixed_)
        end
    else
        PEnvMgrInstance:SetWeather(WeatherID,TransitionTime)
        PEnvMgrInstance:SetDesireAsyoTime(Time,IsFixed)
    end
end

function WeatherMgr:EnableUISystemWeather(Enable,WeatherFilePath,WeatherID,Para1,Para2,Para3)
    if Enable == true then
        if CommonUtil.IsWithEditor() then
            _G.LightMgr:PrintBluePrint(WeatherFilePath, Para1, Para2, Para3)
        end
        _G.UE.UEnvMgr:Get():EnableUISystemWeather(WeatherFilePath,WeatherID,Para1,Para2,Para3)
    else
        _G.UE.UEnvMgr:Get():DisableUISystemWeather()
    end
end

function WeatherMgr:GetServerWeather()
    return self.ServerWeather:GetWeatherId()
end

function WeatherMgr:GetActiveWeather()
    if self.ClientWeather:GetWeatherId() ~= Weather.WeatherInfo.INVALID_WEATHER_ID then
        return self.ClientWeather
    elseif self.ServerWeather:GetWeatherId() ~= Weather.WeatherInfo.INVALID_WEATHER_ID then
        return self.ServerWeather
    else
        return nil
    end
end

function WeatherMgr:GetActiveGraphicWeather()
    if not self.ServerWeather:GetIsContentNext() then
        if self.ClientWeatherId ~= Weather.WeatherInfo.INVALID_WEATHER_ID then
            return self.ClientWeatherId
        end
    end

    return self.ServerWeather:GetNextWeatherId()
end

function WeatherMgr:GetIndividualWeather()
    if self.ClientWeatherId ~= self.WeatherInfo.INVALID_WEATHER_ID then
        if not self.ServerWeather:IsContent() then
            return self.ClientWeatherId
        end
    end

    return self.ServerWeather:GetWeatherId()
end

function WeatherMgr:GetTerritoryTypeIndividualWeather(MapID)
    return Weather.WeatherInfo.INVALID_WEATHER_ID
end

function WeatherMgr:GetIndividualWeatherLocal(IndividualWeatherID)
    return Weather.WeatherInfo.EXD_WEATHER_SUNY
end

function WeatherMgr:UpdateIndividualWeather()
    if self.NeedUpdateIndividualWeather then
        if self.IndividualWeather ~= Weather.WeatherInfo.EXD_INDIVIDUAL_WEATHER_INVALID then
            self.ClientWeatherId = self:GetIndividualWeatherLocal(self.IndividualWeather)
        else
            self.ClientWeatherId = self.WeatherInfo.INVALID_WEATHER_ID
        end

        self.NeedUpdateIndividualWeather = false
    end
end

function WeatherMgr:RefreshIndividualWeather()
    --任务系统更新的时候就更新一下这里，因为独立天气依赖任务系统进度
    self.InstantIndividualWeather = true
    self.NeedUpdateIndividualWeather = true
end

function WeatherMgr:IsIndividualWeather()
    if self.ServerWeather:IsContent() then
        return false
    end

    if self.ClientWeatherId == self.WeatherInfo.INVALID_WEATHER_ID then
        return false
    end

    return true
end

function WeatherMgr:IsIndividualWeatherTerritorytype(MapID)
    return false
end

local function GetTimeFromString(str,split)
    local strarray = string.split(str,split)

    if strarray[2][1] == '0' then
        return tonumber(strarray[2][2])
    else
        return tonumber(strarray[2])
    end
end

function WeatherMgr:PlayMapEffect()
    FLOG_WARNING("PlayMapEffect")
end

function WeatherMgr:UpdateRareWeather()
    local MapID = PWorldMgr:GetCurrMapResID()
    local Weather = self:GetWeatherAndParams(MapID,false,0)
    local PreWeather = self:GetPreWeather(MapID)
    local CurrentWeather = Weather[1]

    --当前天气是否符合
    local function IsContainCurrentWeather(MapCurrentWeather,CurrentWeather)
        if MapCurrentWeather == nil then
            return true
        else
            local CurrentWeatherArray = string.split(MapCurrentWeather,",")

            for i=1,table.length(CurrentWeatherArray) do
                if tonumber(CurrentWeatherArray[i]) == CurrentWeather then
                    return true
                end
            end
        end

        return false
    end

    --除变化天气是否符合
    local function IsExWeatherContain(MapExWeather,VaryWeather)
        if MapExWeather == nil then
            return false
        else
            local VaryWeatherArray = string.split(MapExWeather,",")

            for i=1,table.length(VaryWeatherArray) do
                if tonumber(VaryWeatherArray[i]) == VaryWeather then
                    return true
                end
            end
        end

        return false
    end

    --变化天气是否符合
    local function IsVaryWeatherContain(MapVaryWeather,VaryWeather)
        if MapVaryWeather == nil then
            return true
        else
            local VaryWeatherArray = string.split(MapVaryWeather,",")

            for i=1,table.length(VaryWeatherArray) do
                if tonumber(VaryWeatherArray[i]) == VaryWeather then
                    return true
                end
            end
        end

        return false
    end

    --除前置天气是否符合
    local function IsExPreWeatherContain(MapExPreWeather,PreWeather)
        if MapExPreWeather == nil then
            return false
        else
            local ExPreWeatherArray = string.split(MapExPreWeather,",")

            for i=1,table.length(ExPreWeatherArray) do
                if tonumber(ExPreWeatherArray[i]) == PreWeather then
                    return true
                end
            end
        end

        return false
    end

    --前置天气是否符合
    local function IsPreWeatherContain(MapPreWeather,PreWeather)
        if MapPreWeather == nil then
            return true
        else
            local PreWeatherArray = string.split(MapPreWeather,",")

            for i=1,table.length(PreWeatherArray) do
                if tonumber(PreWeatherArray[i]) == PreWeather then
                    return true
                end
            end
        end

        return false
    end


    --是否在开始结束日期内
    local function IsInDatePeriod(StartDay,EndDay,Day,Hour)
        if StartDay ~= nil and EndDay ~= nil then
            FLOG_WARNING(StartDay)
            FLOG_WARNING(EndDay)
            local StartTimeArray = GetTimeFromString(StartDay,"_")
            local StartDayTimeArray = GetTimeFromString(StartTimeArray[1],"-")
            local StartHourTimeArray = GetTimeFromString(StartTimeArray[2],"-")
            local EndTimeArray = GetTimeFromString(EndDay,"_")
            local EndDayTimeArray = GetTimeFromString(EndTimeArray[1],"-")
            local EndHourTimeArray = GetTimeFromString(EndTimeArray[2],"-")

            if Day >= StartDayTimeArray[3] or Day <= EndDayTimeArray[3] then
                if Day == StartDayTimeArray[3] then
                    if Hour >= StartHourTimeArray[1] then
                        return true
                    end
                elseif Day == EndDayTimeArray[3]  then
                    if Hour < EndHourTimeArray[1] then
                        return true
                    end
                else
                    return false
                end
            end
        else
            return true
        end

        return false
    end

    for _, WeatherRareTable in ipairs(self.WeatherRareCfg) do
        if WeatherRareTable then
            if MapID == WeatherRareTable.MapID or WeatherRareTable.MapID == nil then
                local Day = TimeUtil.GetAozyDay() % 32 + 1
                local Hour = TimeUtil.GetAozyHour()
                local Minute = TimeUtil:GetAozyMinute()

                --判断是否在效果时间内
                if WeatherRareTable.EffectStartTime ~= nil and WeatherRareTable.EffectEndTime ~= nil then
                    local times = string.split(WeatherRareTable.EffectStartTime,":")
                    local hour = tonumber(times[1])
                    local minute = GetTimeFromString(WeatherRareTable.EffectStartTime,":")

                    FLOG_WARNING("WeatherRareTable.EffectStartTime is %d,%d",hour,minute)

                    if Hour >= hour and Minute >= minute then
                        times = string.split(WeatherRareTable.EffectEndTime,":")
                        hour = tonumber(times[1])
                        minute = GetTimeFromString(WeatherRareTable.EffectEndTime,":")

                        FLOG_WARNING("WeatherRareTable.EffectEndTime is %d,%d",hour,minute)

                        if Hour <= hour and Minute <= minute then
                            if IsInDatePeriod(WeatherRareTable.StartDay,WeatherRareTable.EndDay,Day,Hour) then
                                if IsContainCurrentWeather(WeatherRareTable.CurrentWeather,CurrentWeather) then
                                    --需要判断变化天气
                                    if WeatherRareTable.VaryTime ~= nil then
                                        local VaryWeather = self:GetVaryTimeWeather(tonumber(WeatherRareTable.VaryTime),MapID)
                                        if IsVaryWeatherContain(WeatherRareTable.Weather,VaryWeather) and not IsExWeatherContain(WeatherRareTable.ExWeather,VaryWeather) then
                                            --判断前置天气
                                            if not IsExPreWeatherContain(WeatherRareTable.ExPreWeather,PreWeather) and IsPreWeatherContain(WeatherRareTable.PreWeather,PreWeather) then
                                                --需要判断驻留时间
                                                if WeatherRareTable.StaySeconds ~= nil then
                                                    if self.InLevelTime >= tonumber(WeatherRareTable.StaySeconds) then
                                                        self.EnableDetermineTriggerMapEffectWithInLevelTime = 0
                                                        self:PlayMapEffect()
                                                        return true
                                                    else
                                                        self.EnableDetermineTriggerMapEffectWithInLevelTime = tonumber(WeatherRareTable.StaySeconds)
                                                        FLOG_WARNING("EnableDetermineTriggerMapEffectWithInLevelTime is %d",self.EnableDetermineTriggerMapEffectWithInLevelTime)
                                                    end
                                                else
                                                    self:PlayMapEffect()
                                                    return true
                                                end
                                            end
                                        end
                                    else
                                        --判断前置天气
                                        if not IsExPreWeatherContain(WeatherRareTable.ExPreWeather,PreWeather) and IsPreWeatherContain(WeatherRareTable.PreWeather,PreWeather) then
                                            FLOG_WARNING("WeatherRareTable.ExPreWeather is %s",WeatherRareTable.ExPreWeather)
                                            FLOG_WARNING("PreWeather is %d",PreWeather)
                                            --需要判断驻留时间
                                            if WeatherRareTable.StaySeconds ~= nil then
                                                if self.InLevelTime >= tonumber(WeatherRareTable.StaySeconds) then
                                                    self.EnableDetermineTriggerMapEffectWithInLevelTime = 0
                                                    self:PlayMapEffect()
                                                    return true
                                                else
                                                    self.EnableDetermineTriggerMapEffectWithInLevelTime = tonumber(WeatherRareTable.StaySeconds)
                                                end
                                            else
                                                self:PlayMapEffect()
                                                return true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return false
end

return WeatherMgr