--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:时尚品鉴VM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local EModuleID = ProtoCommon.ModuleID
local MajorUtil = require("Utils/MajorUtil")
local UIBindableList = require("UI/UIBindableList")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local LocalizationUtil = require("Utils/LocalizationUtil")
local DepartOfLightDefine = require("Game/Departure/DepartOfLightDefine")
local DepartActivityDetailVM = require("Game/Departure/VM/DepartActivityDetailVM")
local DepartActivityItemVM = require("Game/Departure/VM/Item/DepartActivityItemVM")
local DepartActivityNodeItemVM = require("Game/Departure/VM/Item/DepartActivityNodeItemVM")
local DepartActivityDescItemVM = require("Game/Departure/VM/Item/DepartActivityDescItemVM")
local DepartHighLightItemVM = require("Game/Departure/VM/Item/DepartHighLightItemVM")
local DepartOfLightVMUtils = require("Game/Departure/DepartOfLightVMUtils")

local LSTR = _G.LSTR

local TimeUtil = _G.TimeUtil

---@class DepartOfLightVM : UIViewModel
---@field ThemeName string @
---@field GetProgressNum number @
---
local DepartOfLightVM = LuaClass(UIViewModel)

function DepartOfLightVM:Ctor()
end

function DepartOfLightVM:OnInit()
    self.DepartActivityDetailVM = DepartActivityDetailVM.New(self)
    self.ActivityInfoList = {} -- 整个玩法信息列表
    self.ActivityInfoVMList = UIBindableList.New(DepartActivityItemVM)
    self.CurrNodeInfoList = {} -- 玩法下的节点列表
    self.CurrNodeInfoVMList = UIBindableList.New(DepartActivityNodeItemVM)
    self.CurrActivityDescList = {} -- 玩法说明列表f
    self.CurrActivityDescVMList = UIBindableList.New(DepartActivityDescItemVM)
    self.ActivityNodeHeadInfoList = {}
    self.ActivityStatisticProgressMap = {}
    self.CurrActivityInfo = {}
    self.CurrActivityIndex = 0
    self.CurrActivityProgress = 0
    self.ProgressPercent = 0
    self.GoToBtnName = DepartOfLightDefine.GoToText
    self.GoToBtnDesc = ""
    self.GoToBtnDescVisible = true
    self.ActivityID = 0
    self.PageName = "" -- 页签名字
    self.Title = "" -- 标题
    self.SubTitle = "" -- 副标题
    self.Info = "" -- 简介
    self.NodeHeadDesc = "" -- 节点总进度说明
    self.BGIcon = ""
    self.IsCurActivityPreQuestFinished = true
    self.IsCurActivityUnlock = false
    -- 回收界面
    self.HighLightPerformList = {}
    self.HighLightPerformVMList = UIBindableList.New(DepartHighLightItemVM)
    self.RecycleContent = ""
    self.EndTime = 0
    self.ForeverCloseTime = 0
    self.ForeverCloseTimeText = "" -- 永久关闭倒计时文本
    self.HighLightBigIcon = ""  -- 回收界面左侧最好数据的玩法大图
    self.IsReadyClose = false -- 即将结束启程玩法
    self.IsForeverClose = true -- 永久结束启程玩法
    self.FirstHightLightGameID = 0 -- 表现最好的GameID
end

function DepartOfLightVM:OnBegin()
end

function DepartOfLightVM:OnEnd()

end

function DepartOfLightVM:OnShutdown()

end

---@type 更新所有活动信息
function DepartOfLightVM:UpdateActivityInfoList(InfoList)
    if InfoList == nil or next(InfoList) == nil then
        return
    end

    self.ActivityInfoList = InfoList
    self.ActivityInfoVMList:UpdateByValues(self.ActivityInfoList, nil, false)
end

function DepartOfLightVM:UpdateActivity(Info, Index)
    if Info == nil or next(Info) == nil then
        return
    end

    local UpdateActivityVM = self.ActivityInfoVMList and self.ActivityInfoVMList:Get(Index)
    if UpdateActivityVM then
        UpdateActivityVM:UpdateByValue(Info, nil, false)
        if self.CurrActivityIndex == Index then
            self:UpdateCurrActivityInfo(Index)
        end
    end
end

---@type 更新活动节点头信息
function DepartOfLightVM:UpdateActivityNodeHeadInfo(InfoList)
    if InfoList == nil or next(InfoList) == nil then
        return
    end

    self.ActivityNodeHeadInfoList = InfoList
end

---@type 更新当前选中活动信息
function DepartOfLightVM:UpdateCurrActivityInfo(Index)
    if self.ActivityInfoList == nil or next(self.ActivityInfoList) == nil then
        return
    end

    self.CurrActivityIndex = Index
    self.CurrActivityInfo = self.ActivityInfoList[Index]
    if self.CurrActivityInfo == nil then
        return
    end

    local Nodes = self.CurrActivityInfo.Nodes
    local ActivityID = self.CurrActivityInfo.ActivityID
    self.ActivityID = ActivityID
    local ActivityDescInfo = DepartOfLightVMUtils.GetActivityDescInfoByActivityID(ActivityID)
    local GameID = ActivityDescInfo and ActivityDescInfo.GameID
    self.BGIcon = DepartOfLightVMUtils.GetActivityBG(GameID)

    -- 设置奖励，说明等
    local ActivityInfo = DepartOfLightVMUtils.GetActivityInfo(ActivityID)
    if ActivityInfo then
        self.PageName = ActivityInfo.PageName
        self.Title = ActivityInfo.Title
        self.SubTitle = ActivityInfo.SubTitle
        self.Info = ActivityInfo.Info
    end
    self.CurrNodeInfoList = Nodes
    self.CurrNodeInfoVMList:UpdateByValues(self.CurrNodeInfoList, nil, false)
    self.GoToBtnDesc = self:GetGoToBtnDesc(ActivityDescInfo)
    self.GoToBtnDescVisible = not string.isnilorempty(self.GoToBtnDesc)
    -- 设置进度
    local NodeLenth = self.CurrNodeInfoList and #self.CurrNodeInfoList or 0
    if NodeLenth > 0 then
        local LastNode = self.CurrNodeInfoList[NodeLenth] -- 活动进度取最后一个活动节点的进度
        self:UpdateProgressPercent(LastNode, self.CurrNodeInfoList)
        self:UpdateProgressDesc(ActivityDescInfo)
    end

    --设置玩法说明
    local DescList = ActivityDescInfo and ActivityDescInfo.DescList or {}
    self.CurrActivityDescList = DescList
    self.CurrActivityDescVMList:UpdateByValues(self.CurrActivityDescList)
    self.DepartActivityDetailVM:UpdateDescList(self.CurrActivityDescList)

    if self:IsDepartureReadyClosed() then
        self:OnDepartureReadyClosed()
    end
end

---@type 更新总进度描述
function DepartOfLightVM:UpdateProgressDesc(ActivityDescInfo)
    if ActivityDescInfo == nil or type(ActivityDescInfo) ~= "table" then
        return
    end
    local ModuleID = ActivityDescInfo and ActivityDescInfo.ModuleID
    local GameID = ActivityDescInfo and ActivityDescInfo.GameID
    local CurStatisticProgress = self:GetActivityProgress(GameID) or 0
    local _IsModuelOpen, QuestName = self:GetModuleOpenInfo(ModuleID)
    -- Fate、衣橱直接解锁
    if ModuleID == EModuleID.ModuleIDFATE or ModuleID == EModuleID.ModuleIDAvatar 
     or ModuleID == EModuleID.ModuleIDGamePworld then
        self.NodeHeadDesc = string.format(ActivityDescInfo.NodeDescUnlock, CurStatisticProgress)
    else
        if _IsModuelOpen then
            self.NodeHeadDesc = string.format(ActivityDescInfo.NodeDescUnlock, CurStatisticProgress)
        else
            self.NodeHeadDesc = ActivityDescInfo.NodeDescLocked
        end
    end
end

---@type 更新完成节点进度
function DepartOfLightVM:UpdateProgressPercent(LastNode, NodeList)
    if LastNode == nil or NodeList == nil or #NodeList < 2 then
        self.ProgressPercent = 0
        return
    end

    self.ProgressPercent = 0
    local NodeLenth = #NodeList
    local FirstNodePercent = 0.12 -- UI第一个节点只有大概一半,可根据实际蓝图UI调整

    local FinishedNodeNum = LastNode.FinishedNodeNum or 0
    if FinishedNodeNum <= 0 then
        local LastNodeFinishedNext = NodeList[1]
        local LastNodeNextDetail = DepartOfLightVMUtils.GetActivityNodeDetail(LastNodeFinishedNext.NodeID)
        local LastNodeFinishedNextTarget = LastNodeNextDetail and LastNodeNextDetail.Target or 1
        local SubValue = LastNode.Progress
        local SubValueMax = LastNodeFinishedNextTarget
        local RemainPercent = (SubValue / SubValueMax) * FirstNodePercent
        self.ProgressPercent = RemainPercent
        return
    end

    local PerNodePercent = (1 - FirstNodePercent) / (NodeLenth - 1)
    self.CurrActivityProgress = LastNode.Progress or 0
    local LastNodeFinished = NodeList[FinishedNodeNum] -- 完成的最后一个节点，用于判断当前进度值是否超出
    local LastNodeFinishedNext = NodeList[FinishedNodeNum + 1] -- 完成的最后一个节点下一个，用于计算差值
    self.ProgressPercent = FirstNodePercent + (FinishedNodeNum - 1) * PerNodePercent -- 因为奖励UI之间是等间距，而目标值之间不是，所以按完成数量设置完成进度
    if LastNodeFinished and LastNodeFinishedNext then
        local LastNodeDetail = DepartOfLightVMUtils.GetActivityNodeDetail(LastNodeFinished.NodeID)
        local LastNodeNextDetail = DepartOfLightVMUtils.GetActivityNodeDetail(LastNodeFinishedNext.NodeID)
        local LastNodeFinishedTarget = LastNodeDetail and LastNodeDetail.Target or 1
        local LastNodeFinishedNextTarget = LastNodeNextDetail and LastNodeNextDetail.Target or 1
        local SubValue = self.CurrActivityProgress - LastNodeFinishedTarget -- 当前进度值与最后一个完成节点目标之间的差值
        local SubValueMax = LastNodeFinishedNextTarget - LastNodeFinishedTarget -- 两个节点之间的目标差值
        if SubValue > 0 then
            local RemainPercent = (SubValue / SubValueMax) * PerNodePercent
            self.ProgressPercent = self.ProgressPercent + RemainPercent -- 加上多出来的进度百分比
        end
    end
end

---@type 更新所有玩法记录
function DepartOfLightVM:UpdateAllStatisticInfo(InfoList)
    if InfoList == nil or next(InfoList) == nil then
        return
    end

    if self.ActivityStatisticProgressMap == nil then
        self.ActivityStatisticProgressMap = {}
    end

    for GameID, Progress in pairs(InfoList) do
        self.ActivityStatisticProgressMap[GameID] = Progress
        if self.ActivityID and self.ActivityID > 0 then
            local ActivityDescInfo = DepartOfLightVMUtils.GetActivityDescInfoByActivityID(self.ActivityID)
            local CurGameID = ActivityDescInfo and ActivityDescInfo.GameID or 0
            if CurGameID == GameID then
                self:UpdateProgressDesc(ActivityDescInfo)
                self:OnProgressChanged(self.ActivityID, Progress)
            end
        end
    end
end

---@type 只处理未达成节点目标时的进度
function DepartOfLightVM:OnProgressChanged(ChangeActivityID, Progress)
    local ChangeActivityInfo, Index = DepartOfLightVM:GetActivityInfoByActivityID(ChangeActivityID)
    if ChangeActivityInfo and ChangeActivityInfo.Nodes then
        local LastNode = ChangeActivityInfo.Nodes[#ChangeActivityInfo.Nodes]
        if LastNode then
            LastNode.Progress = Progress
        end
        DepartOfLightVM:UpdateActivity(ChangeActivityInfo, Index)
    end
end

---@type 更新高光记录
function DepartOfLightVM:UpdateJourneyInfo(Info)
    self.HighLightPerformList = {}
    if Info then
        self.BestTotalStatistic = self:GetBestTotalStatistic(Info.JourneyValues) -- 前三好的模块总数据
        if Info.BeginTime > 0 and Info.EndTime > 0 then
            self.TotalTime = Info.EndTime - Info.BeginTime -- 启程玩法总时长
        end
        local CloseDelay = DepartOfLightVMUtils.GetDepartureCloseDelay()
        -- 启程玩法结束
        if Info.EndTime and Info.EndTime > 0 then
            self.EndTime = Info.EndTime
            self.ForeverCloseTime = Info.EndTime + CloseDelay
            local LocTime = _G.TimeUtil.GetServerLogicTime()
            if self.ForeverCloseTime and self.ForeverCloseTime > 0 then
                self.IsReadyClose = LocTime > self.EndTime and LocTime < self.ForeverCloseTime
                self.IsForeverClose = LocTime >= self.ForeverCloseTime
                self:UpdateRemainTime()
            end
        else
            self.IsReadyClose = false
            self.IsForeverClose = false
        end
        self.HighLightPerformList = self:GetHighLightList(Info.JourneyValues) -- 前三好的高光时刻数据
        if self.HighLightPerformList and #self.HighLightPerformList > 0 then
            local FirstHighLight = self.HighLightPerformList[1]
            self.FirstHightLightGameID = FirstHighLight and FirstHighLight.GameID
            self.HighLightBigIcon = DepartOfLightVMUtils.GetActivityBG(self.FirstHightLightGameID)
        end
    end
    self.HighLightPerformVMList:UpdateByValues(self.HighLightPerformList, nil, false)
    
    local StatisticContentPoints = {}
    if self.BestTotalStatistic then
        for _, value in ipairs(self.BestTotalStatistic) do
            local GameID = value.GameID
            local Progress = value.TotalProgress or 0
            local Desc = DepartOfLightDefine.HighLightDescList[GameID]
            if not string.isnilorempty(Desc) then
                local DescText = string.format(Desc, Progress)
                table.insert(StatisticContentPoints, DescText)
            end
        end
    end
    local TotalTimeText = ""
    if self.TotalTime and self.TotalTime > 0 then
        TotalTimeText = LocalizationUtil.GetCountdownTimeForLongTime(self.TotalTime) or ""
    end
    local Content1 = StatisticContentPoints[1] or ""
    local Content2 = StatisticContentPoints[2] or ""
    local Content3 = StatisticContentPoints[3] or ""
    local MajorName = MajorUtil.GetMajorName()
    self.RecycleContent = string.format(DepartOfLightDefine.RecycleContent,MajorName,  TotalTimeText, Content1, Content2, Content3)
end

function DepartOfLightVM:UpdateRemainTime()
    local LocTime = _G.TimeUtil.GetServerLogicTime()
    local RemainTime = self.ForeverCloseTime - LocTime
    RemainTime = RemainTime > 0 and RemainTime or 0
    local ForeverCloseTimeLocal = LocalizationUtil.GetCountdownTimeForLongTime(RemainTime) or ""
    self.ForeverCloseTimeText = string.format(DepartOfLightDefine.RecycleText, ForeverCloseTimeLocal)
    return RemainTime
end

---@type 获取前三好的模块总数据
function DepartOfLightVM:GetBestTotalStatistic(JourneyValues)
    if JourneyValues == nil then
        return
    end
    
    -- 总完成比例(大到小) > 单玩法完成时间(小从到大) > GameID(从小到大)
    table.sort(JourneyValues, function(a, b) 
        if a.TotalPercent ~= b.TotalPercent then
            return a.TotalPercent > b.TotalPercent
        elseif a.FinishTime ~= b.FinishTime then
            return a.FinishTime < b.FinishTime
        else
            return a.GameID < b.GameID
        end
        return false
    end)

    local BestTotalStatistics = {}
    for index = 1, 3 do
        if JourneyValues[index] then
            table.insert(BestTotalStatistics, JourneyValues[index])
        else
            break
        end
    end
    return BestTotalStatistics
end

---@type 获取前三好的高光时刻数据
function DepartOfLightVM:GetHighLightList(JourneyValues)
    if JourneyValues == nil then
        return
    end
    -- 单日最大完成比例(大到小) > 单玩法完成时间(小从到大) > GameID(从小到大)
    table.sort(JourneyValues, function(a, b) 
        if a.DayMaxPercent ~= b.DayMaxPercent then
            return a.DayMaxPercent > b.DayMaxPercent
        elseif a.DayMaxValueTime ~= b.DayMaxValueTime then
            return a.DayMaxValueTime < b.DayMaxValueTime
        else
            return a.GameID < b.GameID
        end
        return false
    end)

    local HighLightList = {}
    for index = 1, 3 do
        if JourneyValues[index] then
            table.insert(HighLightList, JourneyValues[index])
        else
            break
        end
    end
    return HighLightList
end

---@type 左侧玩法页签被点击
function DepartOfLightVM:OnActivityClicked(Index)
    self:UpdateCurrActivityInfo(Index)
end

---@type 说明图片被点击
function DepartOfLightVM:OnDescIconClicked(Index)
    if self.CurrActivityDescList == nil then
        return
    end
    local CurrSelectedDesc = self.CurrActivityDescList[Index]
    if CurrSelectedDesc then
        self.DepartActivityDetailVM:UpdateActivityDescInfo(CurrSelectedDesc, Index)
    end
end

---@type 切换下张说明图片
function DepartOfLightVM:OnSwitchDescIconNext()
    if self.CurrActivityDescList == nil then
        return
    end
    local Length = #self.CurrActivityDescList
    local CurIndex = self.DepartActivityDetailVM:GetCurDescIndex()
    local NewIndex = CurIndex + 1
    if NewIndex > Length then
        NewIndex = 1
    end
    self:OnDescIconClicked(NewIndex)
    return NewIndex
end

---@type 切换上张说明图片
function DepartOfLightVM:OnSwitchDescIconUp()
    if self.CurrActivityDescList == nil then
        return
    end
    local Length = #self.CurrActivityDescList
    local CurIndex = self.DepartActivityDetailVM:GetCurDescIndex()
    local NewIndex = CurIndex - 1
    if NewIndex <= 0 then
        NewIndex = Length
    end
    self:OnDescIconClicked(NewIndex)
    return NewIndex
end

---@type 获取跳转按钮名字
function DepartOfLightVM:GetGoToBtnDesc(ActivityDescInfo)
    if ActivityDescInfo == nil then
        return
    end

    self.IsCurActivityUnlock = false
    self.IsCurActivityPreQuestFinished = true
    if self:IsDepartureReadyClosed() then
        return ""
    end

    local GameID = ActivityDescInfo.GameID
    local ModuleID = ActivityDescInfo.ModuleID
    local EGameID = DepartOfLightDefine.DEPART_GAME_ID
    -- Fate、衣橱、直接解锁
    if ModuleID == EModuleID.ModuleIDFATE or ModuleID == EModuleID.ModuleIDAvatar then
        self.IsCurActivityUnlock = true
       return DepartOfLightDefine.GoToBtnNameMap[GameID] or ""
    end

    -- 制作笔记、采集笔记、钓鱼笔记\金蝶游乐场需要解锁
    local _IsModuelOpen, QuestName = self:GetModuleOpenInfo(ModuleID)
    if not _IsModuelOpen then
        -- 冒险系统解锁
        local _IsAdventureOpen, _ = DepartOfLightVM:GetModuleOpenInfo(EModuleID.ModuleIDAdventure)
        if ModuleID == EModuleID.ModuleIDMakerNote then
           return DepartOfLightDefine.MakeNoteOpenCondition or "" -- 解锁任意能工巧匠后开启
        end

        if ModuleID == EModuleID.ModuleIDGatherNote then
           return DepartOfLightDefine.GatherNoteOpenCondition or "" -- 解锁采矿工/园艺工后开启
        end

        if ModuleID == EModuleID.ModuleIDFisherNote then
            return DepartOfLightDefine.FishNoteOpenCondition or "" -- 解锁捕鱼人后开启
        end

        -- 金蝶游乐场
        if ModuleID == EModuleID.ModuleIDGoldSauserMain then
            --local IsFinishPreTask = string.isnilorempty(QuestName) -- 是否完成前置任务（主线11级任务）
            local IsFinishPreTask = _G.QuestMgr:GetQuestStatus(140553) == QUEST_STATUS.CS_QUEST_STATUS_FINISHED 
            if IsFinishPreTask then
                return DepartOfLightDefine.GoToOpenGoldSauserText -- 前往开启
            else
                self.IsCurActivityPreQuestFinished = false
                return DepartOfLightDefine.GoldSauserOpenCondition -- 需完成11级主线任务
            end
        end

        -- 战斗职业，需判断冒险系统是否已解锁，如果解锁则跳转冒险，否则跳转角色系统
        if ModuleID == EModuleID.ModuleIDGamePworld then
            if _IsAdventureOpen then
                self.IsCurActivityUnlock = true
                return DepartOfLightDefine.GoToBtnNameMap[GameID] or "" -- 冒险系统
            else
                return DepartOfLightDefine.GoToRoleModuleText -- 角色界面
            end
        end
    end
    self.IsCurActivityUnlock = true
    return DepartOfLightDefine.GoToBtnNameMap[GameID] or ""
end



--- 从系统解锁表获取所有解锁状态信息
---@param ModuleID ProtoCommon.ModuleID @模块ID
function DepartOfLightVM:GetModuleOpenInfo(ModuleID)
    local bUnlock = _G.ModuleOpenMgr:CheckOpenState(ModuleID)
    if bUnlock then
        return true, ""
    end
    local OpenCfg = _G.ModuleOpenMgr:GetCfgByModuleID(ModuleID)
    local PreTaskList = OpenCfg and OpenCfg.PreTask
    local QuestName = ""
    if PreTaskList then
        for _, QuestID in ipairs(PreTaskList) do
            if _G.QuestMgr:GetQuestStatus(QuestID) ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
                QuestName = _G.QuestMgr:GetQuestName(QuestID)
                break
            end
        end
    end
    return bUnlock, QuestName
end

---@type 获取活动信息列表
function DepartOfLightVM:GetActivityInfoList()
    return self.ActivityInfoList
end

---@type 获取活动信息
function DepartOfLightVM:GetActivityInfoByActivityID(ActivityID)
    if self.ActivityInfoList == nil then
        return
    end 

    local Element, Index = table.find_item(self.ActivityInfoList, ActivityID, "ActivityID")
    return Element, Index
end

---@type 获取当前选中活动信息
function DepartOfLightVM:GetCurrActivityInfo()
    return self.CurrActivityInfo
end

---@type 获取当前选中活动索引
function DepartOfLightVM:GetCurrActivityIndex()
    return self.CurrActivityIndex
end

---@type 获取当前选中活动节点列表
function DepartOfLightVM:GetCurrNodeInfoList()
    return self.CurrNodeInfoList
end

---@type 获取活动信息
function DepartOfLightVM:GetActivityNodeHeadInfo(ActivityID)
    return self.ActivityNodeHeadInfoList and self.ActivityNodeHeadInfoList[ActivityID]
end

---@type 获取活动统计进度
function DepartOfLightVM:GetActivityProgress(GameID)
    return self.ActivityStatisticProgressMap and self.ActivityStatisticProgressMap[GameID] or 0
end

---@type 启程玩法是否永久关闭
function DepartOfLightVM:IsDepartureClosedForever()
    return self.IsForeverClose
end

---@type 启程玩法永久关闭
function DepartOfLightVM:OnDepartureClosedForever()
    self.IsForeverClose = true
end

---@type 启程玩法是否准备结束
function DepartOfLightVM:IsDepartureReadyClosed()
    return self.IsReadyClose
end

---@type 启程玩法准备结束
function DepartOfLightVM:OnDepartureReadyClosed()
    self.IsReadyClose = true
    self.GoToBtnName = DepartOfLightDefine.GoToRecycleText
end

function DepartOfLightVM:GetRemainTime()
    return self.RemainTime
end

return DepartOfLightVM