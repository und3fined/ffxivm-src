local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local UIBindableList = require("UI/UIBindableList")

local WeatherRegionVM = require("Game/Weather/VM/WeatherRegionVM")
local WeatherRegionExVM = require("Game/Weather/VM/WeatherRegionExVM")

local WeatherForecastCfg = require("TableCfg/WeatherForecastCfg")
local WeatherRegionCfg = require("TableCfg/WeatherRegionCfg")

local WeatherVM = LuaClass(UIViewModel) --单件

local TimeDefine = require("Define/TimeDefine")
local TimeType = TimeDefine.TimeType

local CommonUtil = require("Utils/CommonUtil")
-- local TimeUtil = require("Utils/TimeUtil")

function WeatherVM:Ctor()
    self.RegionTabData = nil
    self.WeatherData = nil
    -- 时间相关
    self.TimeTyTB = 
    {
        TimeType.Aozy,
        TimeType.Local,
        TimeType.Server,
    }

    self.SeltRegion = WeatherRegionVM.New()
    self.SeltRegionEx = WeatherRegionExVM.New() -- 展开
    self:Clear()
end

function WeatherVM:Clear()
    self.WeatherForecastUIBg = ""
    self.IsShow = false
    self.TimeIcon = ""
    self.TimeTyIdx = 1
    self.TimeTy = 1
    self.TimeFmt = "07:06"
    
    -- 主界面
    self.RegoinName = "Erlwa"
    self.BG = ""

    -- 列表
    self.SeltRegionIdx = 1
    self.SeltRegion:Clear()
    self.SeltRegionEx:Clear()

    self.IsShowExp = false

    -- 细节弹窗
    self.IsShowDetail = false
    self.DetailMapID = 0
    self.DetailTimeOff = 0

    self.IsUnExpBall = false
    self.DetailSeltBall = nil
    self.DetailBasePanel = nil

    self.ShowAreaIDMapList = {}
    self.ShowAreaIDAreaList = {}
    self.ShowAreaVMEx = nil
    self.ShowAreaVM = nil

    self.ExpMapID = nil
end

local function SortMap(A, B)
    local CfgA = WeatherForecastCfg:FindCfgByKey(A.MapID)
    local CfgB = WeatherForecastCfg:FindCfgByKey(B.MapID)
    if nil == CfgA or nil == CfgB then
        return
    end

    return CfgA.Priority < CfgB.Priority
end

local function SortArea(A, B)
    return A.AreaID < B.AreaID
end

local function SortRegion(A, B)
    return A.RegionID < B.RegionID
end

--[[
    Ret = {
        [1] = {
            RegionID,
            Areas[1] = {
                AreaID,
                Maps[1] = {
                    MapID
                }
            }
        }
    }
]]--

local function BuildWeatherData()
    local All = WeatherForecastCfg:FindAllAdv()
    local Ret = {}
    local Dict = {}

    for _, Cfg in pairs(All) do
        local MapID = Cfg.ID
        local RegionID = Cfg.RegionID
        local AreaID = Cfg.AreaID
        -- RegionID = 1
        if not Dict[RegionID] then
            Dict[RegionID] = {
                RegionID = RegionID,
                Areas = {}
            }
        end

        local Areas = Dict[RegionID].Areas
        if not Areas[AreaID] then
            Areas[AreaID] = {
                AreaID = AreaID,
                Maps = {}
            }
        end

        local Maps = Areas[AreaID].Maps
        if not Maps[MapID] then
            Maps[MapID] = {
                MapID = MapID,
                MapName = Cfg.MapName
            }
        end
    end

    for _, Region in pairs(Dict) do
        local Areas = {}
        for _, Area in pairs(Region.Areas) do
            local Maps = {}
            for _, Map in pairs(Area.Maps) do
                table.insert(Maps, Map)
            end
            table.sort(Maps, SortMap)

            table.insert(Areas, {AreaID = Area.AreaID, Maps = Maps})
        end
        table.sort(Areas, SortArea)
        table.insert(Ret, {RegionID = Region.RegionID, Areas = Areas})
    end
    table.sort(Ret, SortRegion)

    return Ret
end

local function MakeRegionTabData(WeatherData)
    local Ret = {}
    
    for _, Region in pairs(WeatherData) do
        local RegionID = Region.RegionID
        local Cfg = WeatherRegionCfg:FindCfgByKey(RegionID)
        if Cfg then
            local Data = {
                IconPath = Cfg.Icon,
                Name = Cfg.Name,
                RegionInfo = Region,
            }

            table.insert(Ret, Data)
        else
            _G.FLOG_ERROR("[Weather][WeatherVM][MakeRegionTabData] RegionID = " .. tostring(Region.RegionID))
        end
    end

    return Ret
end

function WeatherVM:OnInit()
    self.WeatherData = BuildWeatherData()
    self.RegionTabData = MakeRegionTabData(self.WeatherData)
end

function WeatherVM:UpdateVM()
    local _ <close> = CommonUtil.MakeProfileTag("[Weather][WeatherVM][UpdateVM]")
    self:UpdRegionOptimal()
    -- _G.FLOG_INFO('[Weather][WeatherVM][UpdateVM]')
end

function WeatherVM:UpdRegionOptimal()

    if not self.SeltRegionIdx then
        return
    end

    if not self.RegionTabData then
        return
    end

    local _ <close> = CommonUtil.MakeProfileTag("[Weather][WeatherVM][UpdRegionOptimal]")

    local Data = self.RegionTabData[self.SeltRegionIdx]

    if Data then

        -- local Region = self.RegionTabData[self.SeltRegionIdx].RegionInfo
    
        if self.IsShowExp then
            self:UpdSeltRegionEx()
        else
            self:UpdSeltRegion()
        end
    
        -- _G.FLOG_INFO('[Weather][WeatherVM][UpdRegionOptimal]')
    end

end

function WeatherVM:TryUpdTopItem(Key, IsShow, IsMap)
    -- _G.FLOG_INFO('[Weather][WeatherVM][TryUpdTopItemEx] Key = ' .. tostring(Key))

    local Idx = -1
    local Region = self.SeltRegion or self.SeltRegionEx
    if Region then
        local Areas = Region.Areas
        if Areas then
            local Items = Areas:GetItems()
            for Index, VM in pairs(Items) do
                if VM.AreaID == Key then
                    Idx = Index
                    break;
                end
            end
        end
    end

    if Idx == -1 then
        return
    end

    if IsMap then
        if IsShow then
            self.ShowAreaIDMapList[Idx] = true
        else
            self.ShowAreaIDMapList[Idx] = nil
        end
    else
        if IsShow then
            self.ShowAreaIDAreaList[Idx] = true
        else
            self.ShowAreaIDAreaList[Idx] = nil
        end
    end

    

    local MinIdx

    -- _G.FLOG_INFO('[Weather][WeatherVM][TryUpdTopItemEx] ShowAreaIDList = ' .. table.tostring(self.ShowAreaIDList))

    for Index, _ in pairs(self.ShowAreaIDMapList) do
        if not MinIdx then
            MinIdx = Index
        elseif MinIdx > Index then
            MinIdx = Index
        end
    end

    for Index, _ in pairs(self.ShowAreaIDAreaList) do
        if not MinIdx then
            MinIdx = Index
        elseif MinIdx > Index then
            MinIdx = Index
        end
    end

    -- _G.FLOG_INFO('[Weather][WeatherVM][TryUpdTopItemEx] MinIdx = ' .. table.tostring(MinIdx))

    if not MinIdx then
        MinIdx = 1
    end

    local ShowIdx = MinIdx --== 1 and 1 or (MinIdx - 1)

    if self.SeltRegion then
        if self.ShowAreaVM then
            self.ShowAreaVM.IsShowTime = true
        end
        self.ShowAreaVM = self.SeltRegion.Areas:Get(ShowIdx)
        if self.ShowAreaVM then
            self.ShowAreaVM.IsShowTime = false
        end
    end

    if self.SeltRegionEx then
        if self.ShowAreaVMEx then
            self.ShowAreaVMEx.IsShowTime = true
        end
        self.ShowAreaVMEx = self.SeltRegionEx.Areas:Get(ShowIdx)
        if self.ShowAreaVMEx then
            self.ShowAreaVMEx.IsShowTime = false
        end
    end

    -- _G.FLOG_INFO('[Weather][WeatherVM][TryUpdTopItemEx] ShowIdx = ' .. table.tostring(ShowIdx))
end

-------------------------------------------------------------------------------------------------------
---@see SetValue

function WeatherVM:SetBackground(AssetPath)
    self.WeatherForecastUIBg = AssetPath
end

function WeatherVM:SetSeltRegionIdx(V)
    self.SeltRegionIdx = V
    self:UpdSeltRegion()
end

function WeatherVM:UpdSeltRegion(V)
    local Region = self.RegionTabData[self.SeltRegionIdx].RegionInfo
    self.SeltRegion:UpdateVM(Region)
    self.RegoinName = self.SeltRegion.Name
    self.BG = self.SeltRegion.BG
    -- if self.IsShowExp then
        self:UpdSeltRegionEx()
    -- end
    self.ExpMapID = nil
end

function WeatherVM:SetShowExp(V)
    self.IsShowExp = V

    if V then
        self:UpdSeltRegionEx()
    end
end

function WeatherVM:UpdSeltRegionEx()
    -- print('test info idx = ' .. tostring(self.SeltRegionIdx))

    local Region = self.RegionTabData[self.SeltRegionIdx].RegionInfo

    -- print('test info Region = ' .. table.tostring_block(Region))

    self.SeltRegionEx:UpdateVM(Region)
end

function WeatherVM:SetIsShowDetail(V)
    self.IsShowDetail = V
end

function WeatherVM:SetDetailInfo(MapID, TimeOff, SeltBall, IsUnExpBall)
    self.DetailMapID = MapID
    self.DetailTimeOff = TimeOff
    self.DetailSeltBall = SeltBall
    self.IsUnExpBall = IsUnExpBall
end

return WeatherVM