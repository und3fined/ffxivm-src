--@author daniel
--@date 2023-03-13

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyDefine = require("Game/Army/ArmyDefine")
local DefineCategorys = ArmyDefine.DefineCategorys
local GlobalCfgType = ArmyDefine.GlobalCfgType
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local GroupMemberCategoryCfg = require("TableCfg/GroupMemberCategoryCfg")
local TimeUtil = require("Utils/TimeUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local LocalizationUtil = require("Utils/LocalizationUtil")


---@class ArmyMemListItemVM : UIViewModel
---@field RoleName string @成员名称
---@field JobName string @职业名称
---@field Record string @记录位置
---@field CategoryName string @分组名称
---@field OnlineStatusIcon string @在线状态Icon
---@field JobIcon string @职业头像
---@field PlaceIcon string @城市坐标头像
---@field CategoryIcon string @分组头像
---@field bSelected boolean @是否选中
---@field bOnline boolean @是否在线
local ArmyMemListItemVM = LuaClass(UIViewModel)

function ArmyMemListItemVM:Ctor()
    self.RoleName = ""
    self.JobName = nil
    self.State = nil
    self.CategoryName = nil
    self.OnlineStatusIcon = nil
    self.JobIcon = nil
    self.PlaceIcon = nil
    self.CategoryIcon = nil
    self.bSelected = false
    self.bOnline = nil
    self.RoleID = 0
    self.JoinTime = 0
    self.CategoryID = 0
    self.InternCountDown = 0
    self.CategoryShowIndex = 0
    self.IsShowCrossIcon = false
end

function ArmyMemListItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.RoleID == self.RoleID
end

function ArmyMemListItemVM:UpdateVM(Value)
    if nil == Value then
        return
    end
    local RoleSimData = Value.Simple
    self.RoleID = RoleSimData.RoleID
    self:UpdateCategoryID(RoleSimData.CategoryID)
    self.JoinTime = RoleSimData.JoinTime or 0
    self.PlaceIcon = nil
    self.bSelected = false
    self.RoleName = Value.RoleName
    local IsOnline = Value.IsOnline
    self.bOnline = IsOnline
    self.OnlineStatusIcon = Value.OnlineStatusIcon
    self.JobName = Value.Level
    self.JobIcon = Value.ProfIcon
    self.InternCountDown = 0
    self.IsShowCrossIcon = Value.IsShowCrossIcon


    if IsOnline then
        local MapResName = Value.MapResName
        if string.isnilorempty(MapResName) then
            -- LSTR string:未知
            self.State = _G.LSTR(910162)
        else
            self.State = MapResName
        end
    else
        local LogoutTime = Value.LogoutTime
        if Value.LogoutTime then
            local CurTime = TimeUtil.GetServerTime()
            local OfflineTime = CurTime - LogoutTime
            --self.State = self:FormatOfflineTime(OfflineTime)
            self.State = LocalizationUtil.GetTimerForLowPrecision(OfflineTime)
        end
    end
end


function ArmyMemListItemVM:FormatOfflineTime(Seconds)
    if Seconds < 3600 then
        -- LSTR string:分钟
        local MinStr = LSTR(910069)
        local Minutes = math.floor(Seconds / 60)
        return string.format("%d %s", Minutes, MinStr)
    elseif Seconds < 86400 then
        -- LSTR string:小时
        local HourStr = LSTR(910100)
        local Hours = math.floor(Seconds / 3600)
        return string.format("%d %s", Hours, HourStr)
    else
        -- LSTR string:天
        local DayStr = LSTR(910093)
        local Days
        if Seconds < 2592000 then  -- 30 天
            Days = math.floor(Seconds / 86400)
        else
            Days = 30
        end
        return string.format("%d %s", Days, DayStr)
    end
end

--- 更新分组ID
function ArmyMemListItemVM:UpdateCategoryID(CategoryID)
    if nil == CategoryID then
        return
    end
    self.CategoryID = CategoryID
    local CategoryData, CategoryShowIndex = _G.ArmyMgr:GetCategoryDataByID(CategoryID)
    if CategoryShowIndex then
        self.CategoryShowIndex = CategoryShowIndex
    end
    if CategoryData then
        self.CategoryName = CategoryData.Name
        if string.isnilorempty(self.CategoryName) then
            local CfgCategoryName
            if CategoryID == ArmyDefine.LeaderCID then
                CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMajorCategoryName)
                self.CategoryName = CfgCategoryName or DefineCategorys.LeaderName
            else
                CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMinorCategoryName)
                self.CategoryName = CfgCategoryName or DefineCategorys.MemName
            end
        end
        self.CategoryIcon = GroupMemberCategoryCfg:GetCategoryIconByID(CategoryData.IconID)
    else
        if type(CategoryID) ~= "table" then
            FLOG_ERROR("[ArmyMemListItemVm:UpdateCategoryID] CategoryData is nil, CategoryID = " .. tostring(CategoryID))
        else
            local LogString = ""
            for Key, Value in pairs(CategoryID) do
                -- body
                LogString = string.format("%s{%s, %s}",LogString, tostring(Key), tostring(Value))
            end
            FLOG_ERROR("[ArmyMemListItemVm:UpdateCategoryID] CategoryData is nil, CategoryID = " .. LogString)
        end
    end
end

function ArmyMemListItemVM:AdapterOnGetCanBeSelected()
    return true
end

function ArmyMemListItemVM:AdapterOnGetWidgetIndex()
    return self.ID
end

function ArmyMemListItemVM:GetCategoryID()
    return self.CategoryID
end

return ArmyMemListItemVM