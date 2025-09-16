--
-- Author: ZhengJanChuan
-- Date: 2024-12-16 14:32
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local UIBindableList = require("UI/UIBindableList")
local BattlePassRewardListItemVM = require("Game/BattlePass/VM/Item/BattlePassRewardListItemVM")
local BattlePassPrizeViewItemVM = require("Game/BattlePass/VM/Item/BattlePassPrizeViewItemVM")
local BattlePassRewardSlotVM = require("Game/BattlePass/VM/Item/BattlePassRewardSlotVM")
local BattlePassTaskItemVM = require("Game/BattlePass/VM/Item/BattlePassTaskItemVM")
local BattlePassMgr = require("Game/BattlePass/BattlePassMgr")
local BattlepassLevelRewardCfg = require("TableCfg/BattlepassLevelRewardCfg")
local BattlepassTaskCfg = require("TableCfg/BattlepassTaskCfg")
local BattlepassBigrewardCfg = require("TableCfg/BattlepassBigrewardCfg")
local BattepassSeasonCfg = require("TableCfg/BattepassSeasonCfg")
local ActivityCfg = require("TableCfg/ActivityCfg")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local BattlePassDefine = require("Game/BattlePass/BattlePassDefine")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local TimeUtil = require("Utils/TimeUtil")

---@class BattlePassMainVM : UIViewModel
local BattlePassMainVM = LuaClass(UIViewModel)

---Ctor
function BattlePassMainVM:Ctor()
    self.RewardsVisible = true
    self.ContentVisible = true
    self.SubTitle = ""
    self.CountDown = ""
    self.MaxLevelVisible = true
    self.Exp = ""
    self.Level = ""
    self.ExpPercent = 0
    self.GradeLockVisible = true
    self.BigRewardLevel = ""
    self.GetAllBtnVisible = false
    self.GetTaskAllVisible = false
    self.UpgradeBPVisible = true
    self.Grade = ""
    self.LevelRewardList = UIBindableList.New(BattlePassRewardListItemVM)
    self.TaskList = UIBindableList.New(BattlePassTaskItemVM)
    self.TaskWeekToggleChecked = true
    self.PanelDropDownVisible = true
    self.NextWeekCountDown = ""

    self.BigReward1 = BattlePassRewardSlotVM.New()
    self.BigReward2 = BattlePassRewardSlotVM.New()

    self.GrandPrize1 = BattlePassPrizeViewItemVM.New()
    self.GrandPrize2 = BattlePassPrizeViewItemVM.New()
    self.GrandPrize3 = BattlePassPrizeViewItemVM.New()
    self.GrandPrize4 = BattlePassPrizeViewItemVM.New()
    self.GrandPrize5 = BattlePassPrizeViewItemVM.New()

    self.GrandPrizeName = ""
    self.GrandPrizeImg = nil
    self.GrandPrizeID = 0
    self.GrandPrizeJumpID = nil

    self.WeekSignEff = false

    self.UpgradeBPText = ""
end

function BattlePassMainVM:OnInit()
end

function BattlePassMainVM:OnBegin()
end

function BattlePassMainVM:OnEnd()
end

function BattlePassMainVM:OnShutdown()
end

function BattlePassMainVM:UpdateBaseData()
    local Grade =  BattlePassMgr:GetBattlePassGrade() 
    self.GradeLockVisible = Grade > BattlePassDefine.GradeType.Basic
    if Grade == BattlePassDefine.GradeType.Basic then
        self.Grade = _G.LSTR(850022) --进阶战令
    elseif Grade == BattlePassDefine.GradeType.Middle then
        self.Grade = _G.LSTR(850033) --升级至臻
    elseif Grade == BattlePassDefine.GradeType.Best then
        self.Grade = _G.LSTR(850029) -- 至臻战令
    end

    self.WeekSignEff = BattlePassMgr:GetBattlePassWeekSign()
end

-- 设置经验
function BattlePassMainVM:UpdateLevelValue(NewExp)
    local Level = BattlePassMgr:GetBattlePassLevel()
    local TotalExp = BattlePassMgr:GetBattlePasslLevelUpNeedExp(Level)
    local CurExp = BattlePassMgr:BattlePasslCurLevelExp()
    if NewExp then CurExp = NewExp end

    if TotalExp == 0 then
        self.Exp = ""
        self.ExpPercent = 1.0
    else
        self.Exp = string.format(_G.LSTR(850017), CurExp, TotalExp) --战令经验:%d/%d
        self.ExpPercent = CurExp / TotalExp
    end

    self.Level = string.format("Lv%d", Level)
    self.MaxLevelVisible = TotalExp == 0
end

function BattlePassMainVM:UpdateBtnState(Index)
    local Grade =  BattlePassMgr:GetBattlePassGrade()
    self.GetAllBtnVisible = Index == BattlePassDefine.TabIndex.LevelReward  and BattlePassMgr:GetLevelRewardsAvailable()
    self.GetTaskAllVisible = Index == BattlePassDefine.TabIndex.Task and  BattlePassMgr:GetTaskAvailable()
    self.UpgradeBPVisible = not (Grade == BattlePassDefine.GradeType.Best)
    self.UpgradeBPText = Grade == BattlePassDefine.GradeType.Basic and _G.LSTR(850022) or _G.LSTR(850029)
end

function BattlePassMainVM:UpdateBigRewardData(Level)
    if Level == nil  then
        return
    end

    local GroupID = BattlePassMgr:GetBattlePassGroupID()
    local Cfgs = BattlepassLevelRewardCfg:FindCfgByGroupIDAndLevel(GroupID, Level)
    local Grade = BattlePassMgr:GetBattlePassGrade()

    local Cfg = Cfgs[1]
    if Cfg == nil then
        return
    end

    local CurLevel = BattlePassMgr:GetBattlePassLevel()

    
    self.BigRewardLevel = string.format("%d", Cfg.Level)
    local TempReward1 = Cfg.BasicReward[1]
    local BaseRewardGotStatus = BattlePassMgr:GotLevelReward(Cfg.Level, BattlePassDefine.GradeType.Basic)
    local VM1 = {}
    VM1.Lv = Cfg.Level
    VM1.ResID = TempReward1.ID
    VM1.IsGot = BaseRewardGotStatus
    VM1.Num = TempReward1.Num
    VM1.IsAvailable = CurLevel >= Cfg.Level and not BaseRewardGotStatus
    VM1.Grade = BattlePassDefine.GradeType.Basic

    if BaseRewardGotStatus then
        VM1.IsUnlock = false
    else
        VM1.IsUnlock = not (CurLevel >= Cfg.Level and not BaseRewardGotStatus)
    end
    self.BigReward1:UpdateVM(VM1)
    
    local TempReward2 = Cfg.MiddleReward[1]
    local AdvanceGotStatus = BattlePassMgr:GotLevelReward(Cfg.Level, BattlePassDefine.GradeType.Middle)
    local VM2 = {}
    VM2.Lv = Cfg.Level
    VM2.ResID = TempReward2.ID
    VM2.IsGot = AdvanceGotStatus
    VM2.Num = TempReward2.Num
    VM2.IsAvailable =  CurLevel >= Cfg.Level and not AdvanceGotStatus and Grade > BattlePassDefine.GradeType.Basic
    VM2.Grade = BattlePassDefine.GradeType.Middle
    if AdvanceGotStatus then
        VM2.IsUnlock = false
    else
        VM2.IsUnlock = not (CurLevel >= Cfg.Level and not AdvanceGotStatus and Grade > BattlePassDefine.GradeType.Basic)
    end
    self.BigReward2:UpdateVM(VM2)
end

function BattlePassMainVM:InitLevelRewardList()
    local GroupID = BattlePassMgr:GetBattlePassGroupID()
    local Grade = BattlePassMgr:GetBattlePassGrade()
    local CurLevel = BattlePassMgr:GetBattlePassLevel()
    local Cfgs = BattlepassLevelRewardCfg:FindCfgsByGroupID(GroupID)

    self.LevelRewardList:Clear(true)
    local ItemList = {}

    for _, v in ipairs(Cfgs) do
        local Item = {}
        Item.Lv = v.Level
        Item.IsCurLv = v.Level == CurLevel
        Item.BaseReward = {}
        Item.AdvanceReward = {}
        local AdvanceGotStatus = BattlePassMgr:GotLevelReward(v.Level, BattlePassDefine.GradeType.Middle)
        local BaseRewardGotStatus = BattlePassMgr:GotLevelReward(v.Level, BattlePassDefine.GradeType.Basic)
        for index, value in ipairs(v.BasicReward) do
            Item.BaseReward.Lv = v.Level
            Item.BaseReward.Num = value.Num
            Item.BaseReward.ResID = value.ID
            Item.BaseReward.Grade = BattlePassDefine.GradeType.Basic

            Item.BaseReward.IsAvailable = CurLevel >= v.Level and not BaseRewardGotStatus
            Item.BaseReward.IsGot = BaseRewardGotStatus
            if BaseRewardGotStatus then
                Item.BaseReward.IsUnlock = false
            else
                Item.BaseReward.IsUnlock = not (CurLevel >= v.Level and not BaseRewardGotStatus)
            end
        end
        
        for index, value in ipairs(v.MiddleReward) do
            if index == 1 then
                    Item.AdvanceReward.Num = value.Num
                    Item.AdvanceReward.Lv = v.Level
                    Item.AdvanceReward.ResID = value.ID
                    Item.AdvanceReward.Grade = BattlePassDefine.GradeType.Middle
                    Item.AdvanceReward.IsGot = AdvanceGotStatus
                    Item.AdvanceReward.IsAvailable = CurLevel >= v.Level and not AdvanceGotStatus and Grade > BattlePassDefine.GradeType.Basic
                    if AdvanceGotStatus then
                        Item.AdvanceReward.IsUnlock = false
                    else
                        Item.AdvanceReward.IsUnlock = not (CurLevel >= v.Level and not AdvanceGotStatus and Grade > BattlePassDefine.GradeType.Basic)
                    end
            end
        end

        table.insert(ItemList, Item)
    end

    self.LevelRewardList:UpdateByValues(ItemList)
end

function BattlePassMainVM:UpdateTaskList(ToggleIndex, WeekIndex)
    local TaskList = {}
    local List = BattlePassMgr:GetTaskList(ToggleIndex)
    local SeasonID = BattlePassMgr:GetSeasonID()
    local BPCfg = BattepassSeasonCfg:FindCfgByKey(SeasonID)
    -- self.TaskList:Clear()

    --Todo, 需要时间筛选
    for _, v in ipairs(List) do
        local Cfg = ActivityCfg:FindCfgByKey(v.TaskID)
        local NodeCfg = ActivityNodeCfg:FindCfgByKey(v.Nodes.Head.NodeID) 
        if Cfg ~= nil and NodeCfg ~= nil and BPCfg ~= nil then
                local RewardStatus = v.Nodes.Head.RewardStatus
                local Progress = v.Nodes.Extra.Progress.Value
                local TaskWeekIndex = self:GetTaskWeekIndex(BPCfg.BeginTime, BPCfg.EndTime, Cfg.ChinaActivityTime.ShowTime)
                if WeekIndex == TaskWeekIndex or WeekIndex == 0 then
                    local ItemVM = {}
                    ItemVM.TaskName = string.format(NodeCfg.NodeDesc, Progress or "", NodeCfg.Target or "")
                    ItemVM.BtnState = RewardStatus
                    ItemVM.TaskID = v.TaskID
                    ItemVM.NodeID = v.Nodes.Head.NodeID
                    ItemVM.IsAvailable = RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet
                    ItemVM.IsGot = RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone
                    if not table.is_nil_empty(NodeCfg.Rewards) then
                        ItemVM.ResID = NodeCfg.Rewards[1].ItemID
                        ItemVM.Num = NodeCfg.Rewards[1].Num
                    end
                    table.insert(TaskList, ItemVM)
                end
        end
    end

    table.sort(TaskList, BattlePassMainVM.SortListPredicate)

    self.TaskList:UpdateByValues(TaskList)
end

function BattlePassMainVM:GetTaskWeekIndex(SeasonStart, SeasonEnd, TaskStart)
    local SeasonStartTime = TimeUtil.GetTimeFromString(SeasonStart)
    local TaskStartTime = TimeUtil.GetTimeFromString(TaskStart)
    local SeasonEndTime = TimeUtil.GetTimeFromString(SeasonEnd)

    -- 确保任务开始时间在赛季时间内
    if TaskStartTime < SeasonStartTime then
        return -1
    elseif TaskStartTime > SeasonEndTime then
        return -1
    end

    -- 计算任务开始日期相对于赛季开始日期的周数
    local DifferenceInSeconds = TaskStartTime - SeasonStartTime
    local WeeksIndex = math.floor(DifferenceInSeconds / (7 * 24 * 60 * 60)) + 1  -- 加1因为计数从第1周开始

    return WeeksIndex
end

function BattlePassMainVM.SortListPredicate(a, b)
    if a.IsAvailable ~= b.IsAvailable then
        return a.IsAvailable
    end
    
    -- IsGot 的置底（值true的排后面）
    if a.IsGot ~= b.IsGot then
        return not a.IsGot
    end
    
    -- 其余情况按 taskID 升序排列
    return a.TaskID < b.TaskID  
end

function BattlePassMainVM:InitGrandPrize()
    local GroupID = BattlePassMgr:GetBattlePassGroupID()
    local Cfgs = BattlepassBigrewardCfg:FindCfgsByGroupID(GroupID)
    local ItemList = {}

    table.insert(ItemList, self.GrandPrize1)
    table.insert(ItemList, self.GrandPrize2)
    table.insert(ItemList, self.GrandPrize3)
    table.insert(ItemList, self.GrandPrize4)
    table.insert(ItemList, self.GrandPrize5)

    for index, v in ipairs(Cfgs) do
        if index <= table.length(ItemList) then
            local Temp = {}
            Temp.ID = v.ID
            Temp.ResID = v.ItemID
            ItemList[index]:UpdateVM(Temp)
        end
    end

    if table.length(Cfgs) <= 0 then
        return
    end

    local Len = table.length(Cfgs)
    local LastPrizeCfg = Cfgs[Len]
    if LastPrizeCfg ~= nil then
        self.GrandPrizeID = LastPrizeCfg.ItemID
        self.GrandPrizeJumpID = LastPrizeCfg.ItemID
        if LastPrizeCfg.ItemType == 4 then
            self.GrandPrizeJumpID = LastPrizeCfg.SuitID
        end
        self.GrandPrizeName = ItemUtil.GetItemName(LastPrizeCfg.ItemID)
    end	
    
    local SeasonID = BattlePassMgr:GetSeasonID()
    local Cfg = BattepassSeasonCfg:FindCfgByKey(SeasonID)
    if Cfg ~= nil then
        self.GrandPrizeImg = Cfg.RewardBG
    end
end

--要返回当前类
return BattlePassMainVM