---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-09-27
--- Description: 左侧边栏
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local UIViewConfig = require("Define/UIViewConfig")
local UILayer = require("UI/UILayer")

local LeftSidebarMgr = LuaClass(MgrBase)
local DefaultStayTime = 2 -- 默认停留2秒

local AnimInTime = 0.5 -- 动画淡入时间
local AnimOutTime = 0.5 -- 动画淡出时间

function LeftSidebarMgr:OnInit()
    self.HideExcludeIDTable = {} --不隐藏列表
    self.HideExcludeIDTable[UIViewID.MagicCardGameFinishPanel] = 1
    self.HideExcludeIDTable[UIViewID.SidebarLeft] = 1
    self.HideExcludeIDTable[UIViewID.SidebarMain] = 1
    self.HideExcludeIDTable[UIViewID.SidePopUpEasyUse] = 1
    self.HideExcludeIDTable[UIViewID.SidebarTaskEquipmentWin] = 1
    self.HideExcludeIDTable[UIViewID.SidebarCommon] = 1
    self.HideExcludeIDTable[UIViewID.SidebarTeamInvite] = 1

    self:ResetData()
end

function LeftSidebarMgr:OnBegin()
    local Key = ProtoRes.client_global_cfg_id.GLOBAL_CFG_LEFT_SIDE_BAR_STAY_TIME
    local ClientGlobalCfg = ClientGlobalCfg:FindCfgByKey(Key)
    local TimeInCfg = ClientGlobalCfg and ClientGlobalCfg.Value[1]
    local DefaultStayTime = TimeInCfg or 2
end

function LeftSidebarMgr:ResetData()
    self.DataIndex = 1
    self.PerformDataList = {}
    self.IdleDataQueue = {}
    self.CurPlayData = nil
    self.TargetUI = nil
end

---@return  Data 包含2个参数，1个是类型 SidebarDefine.LeftSidebarType , 1个是用于自定义的table
function LeftSidebarMgr:InternalGetPerformData()
    local Data = nil
    if (#self.IdleDataQueue > 0) then
        Data = table.remove(self.IdleDataQueue, 1)
    end

    if (Data == nil) then
        Data = {}
    end
    Data.Index = self.DataIndex
    self.DataIndex = self.DataIndex + 1
    Data.Type = SidebarDefine.LeftSidebarType.None
    Data.DataTable = nil
    return Data
end

function LeftSidebarMgr:OnEnd()
end

function LeftSidebarMgr:OnShutdown()
    self:ResetData()
end

function LeftSidebarMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ShowUI, self.OnUIShow)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventExitWorld)
    self:RegisterGameEvent(EventID.TutorialLoadingFinish, self.OnLoadingFinish)
end

-- 加载结束了
function LeftSidebarMgr:OnLoadingFinish()
    if (self.NeedHideAgain) then
        self:CountdownForCurInfoView()
        return
    end

    if (#self.PerformDataList < 1) then
        return
    end

    if (self.TargetUI == nil) then
        self:TryShowNextInfoView()
    end
end

function LeftSidebarMgr:OnUIShow(Params)
    if (self.TargetUI == nil) then
        return
    end

    local InViewID = Params
    if (InViewID == nil) then
        return
    end
    if (self.HideExcludeIDTable[InViewID] ~= nil) then
        return
    end
    local Config = UIViewConfig[InViewID]
    if (Config == nil) then
        return
    end

    if (Config.Layer >= UILayer.Normal and Config.Layer ~= UILayer.Tips and Config.Layer ~= UILayer.Highest and
        Config.Layer ~= UILayer.Loading and Config.Layer ~= UILayer.Exclusive) then
        self.PerformDataList = {}
        if (self.CurPlayData ~= nil) then
            table.insert(self.IdleDataQueue, self.CurPlayData)
        end
        self.CurPlayData = nil
        if (self.TargetUI ~= nil and self.TargetUI.Object ~= nil and self.TargetUI.Object:IsValid()) then
            self.TargetUI:StopAnimation(self.TargetUI.AnimIn)
            self.TargetUI:StopAnimation(self.TargetUI.AnimHide)
            self.TargetUI:Hide()
            self.TargetUI = nil
            if (self.TimerCountdownForCurInfoView ~= nil) then
                self:UnRegisterTimer(self.TimerCountdownForCurInfoView)
                self.TimerCountdownForCurInfoView = nil
            end
        end
    end
end

function LeftSidebarMgr:OnGameEventExitWorld()
    self.PerformDataList = {}
end

function LeftSidebarMgr:CountdownForCurInfoView()
    -- 正在加载中不触发隐藏，并且弹的是成就，则不触发隐藏
    if (_G.LoadingMgr:IsLoadingView() and self.CurPlayData ~= nil and self.CurPlayData.Type == SidebarDefine.LeftSidebarType.Achievement) then
        self.NeedHideAgain = true
        return
    end

    self.TimerCountdownForCurInfoView = nil
    if (self.TargetUI ~= nil and self.TargetUI.Object ~= nil and self.TargetUI.Object:IsValid()) then
        local DelayTime = AnimOutTime
        if (self.TargetUI.AnimHide ~= nil) then
            DelayTime = self.TargetUI.AnimHide:GetEndTime(self.TargetUI.AnimHide) or AnimOutTime
            self.TargetUI:PlayAnimation(self.TargetUI.AnimHide)
        end

        self:RegisterTimer(
            function()
                if (self.TargetUI ~= nil and self.TargetUI.Object ~= nil and self.TargetUI.Object:IsValid()) then
                    self.TargetUI:Hide()
                end
                self.TargetUI = nil
                self:TryShowNextInfoView()
            end,
            AnimOutTime,
            0,
            1
        )
    else
        self:TryShowNextInfoView()
    end
end

function LeftSidebarMgr:TryShowNextInfoView()
    if (self.TargetUI ~= nil) then
        _G.FLOG_ERROR("左侧弹窗，当前有UI正在显示， 不能 CountdownForHide ，请检查")
        return
    end

    -- 正在加载中不弹出
    if (_G.LoadingMgr:IsLoadingView()) then
        return
    end

    if (self.CurPlayData ~= nil) then
        table.insert(self.IdleDataQueue, self.CurPlayData)
    end

    self.CurPlayData = nil

    -- 这里看下是否有需要显示的
    if (#self.PerformDataList < 1) then
        return
    end

    if not self:CheckCondition(self.PerformDataList[1]) then
        return
    end

    self.CurPlayData = table.remove(self.PerformDataList, 1)
    self.TargetUI = UIViewMgr:ShowView(UIViewID.SidebarLeft, self.CurPlayData)
    local DelayTime = AnimInTime + self.CurPlayData.StayTime
    self.TimerCountdownForCurInfoView = self:RegisterTimer(self.CountdownForCurInfoView, DelayTime, 0, 1, nil)
end

function LeftSidebarMgr:CheckCondition(CurPlayData)
    if CurPlayData then
        -- 成就
        if CurPlayData.Type == SidebarDefine.LeftSidebarType.Achievement then
            -- 成就侧边栏不显示，LCut中
            if not _G.FashionEvaluationMgr:CanShowAchievementLeftBar() then
                FLOG_INFO("成就侧边栏不显示，LCu中==========")
                return false
            end
        end
    end

    return true
end

function LeftSidebarMgr:Test1()
    do
        local InDataTable = {
            AchievementID = 1990001,
            ClickCallback = function()
                _G.AchievementMgr:OpenAchieveMainViewByAchieveID(3010010)
            end
        }
        self:AppendPerform(SidebarDefine.LeftSidebarType.Achievement, InDataTable)
    end

    TimerMgr:RegisterTimer(
        function()
            do
                local InDataTable = {
                    AchievementID = 1990002,
                    ClickCallback = function()
                        _G.AchievementMgr:OpenAchieveMainViewByAchieveID(3010010)
                    end
                }
                self:AppendPerform(SidebarDefine.LeftSidebarType.Achievement, InDataTable)
            end
        end,
        0.1,
        0,
        1
    )
end

function LeftSidebarMgr:Test()
    do
        local InDataTable = {
            AchievementID = 1990001,
            ClickCallback = function()
                _G.AchievementMgr:OpenAchieveMainViewByAchieveID(3010010)
            end
        }
        self:AppendPerform(SidebarDefine.LeftSidebarType.Achievement, InDataTable)
    end

    do
        local InDataTable = {
            AchievementID = 1990002,
            ClickCallback = function()
                _G.AchievementMgr:OpenAchieveMainViewByAchieveID(3010010)
            end
        }
        self:AppendPerform(SidebarDefine.LeftSidebarType.Achievement, InDataTable)
    end
    do
        local InDataTable = {
            AchievementID = 1990003,
            ClickCallback = function()
                _G.AchievementMgr:OpenAchieveMainViewByAchieveID(3010010)
            end
        }
        self:AppendPerform(SidebarDefine.LeftSidebarType.Achievement, InDataTable)
    end
    do
        local InDataTable = {
            AchievementID = 1990004,
            ClickCallback = function()
                _G.AchievementMgr:OpenAchieveMainViewByAchieveID(3010010)
            end
        }
        self:AppendPerform(SidebarDefine.LeftSidebarType.Achievement, InDataTable)
    end
end

---LeftSidebarMgr.AppendPerform 显示左侧的弹窗，弹窗UI的LUA代码是SidebarLeftWinView
---@param InType                            SidebarDefine.LeftSidebarType 类型
---@param InDataTable                       table       传入数据
---@param InDataTable.Title                 string      标题
---@param InDataTable.Content               string      内容
---@param InDataTable.ClickCallback         function    点击回调
---@param InDataTable.xxx                   any         自定义数据，后续添加的同事请写下注释
---@param InDataTable.CardID                   int32         幻卡用的新获得卡片ID
---@param InDataTable.AchievementID         int32       成就ID
---@param InStayTime    float 停留时间，不传的话，走默认，一般是默认，默认2秒
---@return  Type Description
function LeftSidebarMgr:AppendPerform(InType, InDataTable, InStayTime)
    if (InType == nil or InType == SidebarDefine.LeftSidebarType.None) then
        _G.FLOG_ERROR("传入的类型无效，请检查")
        return
    end
    local Data = self:InternalGetPerformData()
    Data.Type = InType
    Data.DataTable = InDataTable
    Data.StayTime = InStayTime or DefaultStayTime

    table.insert(self.PerformDataList, Data)
    if (#self.PerformDataList > 1) then
        table.sort(
            self.PerformDataList,
            function(Left, Right)
                if (Left.Type ~= Right.Type) then
                    return Left.Type > Right.Type
                else
                    return Left.Index < Right.Index
                end
            end
        )
    end

    if (#self.PerformDataList <= 1 and self.TargetUI == nil) then
        -- 这里等待0.1秒再显示，看是不是有很多窗口挤到一块了
        local DelayTime = 0.1
        self:RegisterTimer(
            function()
                self:TryShowNextInfoView()
            end,
            DelayTime
        )
    end
end

function LeftSidebarMgr:ResetDefaultStayTimeForTest(StayTime)
    DefaultStayTime = StayTime
end

return LeftSidebarMgr
