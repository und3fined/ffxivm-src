local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")

local UIViewID = require("Define/UIViewID")
local BattepassSeasonCfg = require("TableCfg/BattepassSeasonCfg")
local BattlepassLevelRewardCfg = require("TableCfg/BattlepassLevelRewardCfg")
local BattlepassGlobalCfg = require("TableCfg/BattlepassGlobalCfg")
local ActivityCfg = require("TableCfg/ActivityCfg")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local BattlepassBigrewardCfg = require("TableCfg/BattlepassBigrewardCfg")
local BattlePassDefine = require("Game/BattlePass/BattlePassDefine")
local PayUtil = require("Utils/PayUtil")
local TimeUtil = require("Utils/TimeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local MailSlotItemViewVM = require("Game/Mail/View/Item/MailSlotItemViewVM")

local GameNetworkMgr
local EventMgr
local UIViewMgr
local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.BattlePass.BattlePassCmd
local TASK_SUB_MSG_ID = ProtoCS.Game.Activity.Cmd

---@class BattlePassMgr : MgrBase
local BattlePassMgr = LuaClass(MgrBase)

---OnInit
function BattlePassMgr:OnInit()
	--只初始化自身模块的数据，不能引用其他的同级模块
    self.DataValidTime = 0 --数据有效时间戳
    self.Exp = 0 --当前总经验
    self.CurExpMax = 0 --本周经验上限
    self.BattlePassID = 0 -- 当前赛季ID
    self.BattlePassLevel = 1 -- 当前BP等级
    self.BattlePassMaxLevel = 1 -- 当前赛季最高等级
    self.BattlePassLevelLeftExp = 0 --当前BP等级升级剩余经验
    self.BattlePassGradeType = 1 -- BP级别(base,进阶,至臻)
    self.BattlePassWeekSign = false
    self.BattlePassSeasonCfg = nil -- 当前赛季Cfg
    self.ChallengeTaskList = {} --挑战任务
    self.WeeklyTaskList = {} --周任务

    self.BasicLevelList = {}    -- 记录基础当前已经领取的等级
    self.MiddleLevelList = {}   -- 记录进阶当前已经领取的等级

    self.PayFinished = false
    self.ReceivedGoods = false
    self.CurrentProductID = ""

    self.Cfg = {}
    self.StartTimer = nil       -- 战令开启定时器
    self.EndTimer = nil         -- 战令结束时间定时器
    self.IsBattlePassOpen = false --战令开放
end

---OnBegin
function BattlePassMgr:OnBegin()
    GameNetworkMgr = _G.GameNetworkMgr
    EventMgr = _G.EventMgr
    UIViewMgr = _G.UIViewMgr
end

function BattlePassMgr:OnEnd()
	--和OnBegin对应 在OnBegin中初始化的数据（相当于模块的私有数据），需要在这里清除
end

function BattlePassMgr:OnShutdown()
	--和OnInit对应 在OnInit中模块自身的数据，需要在这里清除
end

function BattlePassMgr:OnRegisterNetMsg()
	--示例代码先注释 以免影响正常逻辑
    --战令级别变化(基础/进阶/至臻) 服务器主动下发
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BATTLE_PASS, SUB_MSG_ID.BattlePassCmdExpChange, self.OnPushBattlePassExpChange)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BATTLE_PASS, SUB_MSG_ID.BattlePassCmdGradeChange , self.OnPushBattlePassGradeChange)

	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BATTLE_PASS, SUB_MSG_ID.BattlePassCmdState, self.OnSendBattlePassStateRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BATTLE_PASS, SUB_MSG_ID.BattlePassCmdLevel, self.OnSendBattlePassLevelRewardRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BATTLE_PASS, SUB_MSG_ID.BattlePassCmdGetLevelReward, self.OnSendBattlePassGetLevelReawrdRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BATTLE_PASS, SUB_MSG_ID.BattlePassCmdWeekSign , self.OnSendBattlePassWeekSignRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BATTLE_PASS, SUB_MSG_ID.BattlePassCmdLevelUp , self.OnSendBattlePassLevelUpRsp)
    

    --任务特殊化
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, TASK_SUB_MSG_ID.ListByID, self.OnSendBattlePassTaskRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, TASK_SUB_MSG_ID.Reward, self.OnNetMsgNodeGetReward) -- 领取活动节点奖励
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, TASK_SUB_MSG_ID.MultiReward, self.OnSendGetAllTaskReward) -- 一键领取所有任务奖励
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, TASK_SUB_MSG_ID.NodesChange, self.OnNetTaskNodesChange) -- 可领奖任务推送
end

function BattlePassMgr:OnRegisterGameEvent()
    -- 游戏内事件
	self:RegisterGameEvent(EventID.MajorCreate, self.OnMajorCreate)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnBattlePassModuleOpen)
end

function BattlePassMgr:OnMajorCreate()
    self.Cfg = BattepassSeasonCfg:FindAllCfg()
    if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBattlePass) then
        self:SendBattlePassStateReq()
    end
end

function BattlePassMgr:OnGameEventLoginRes(Params)
	if nil ~= Params and nil ~= Params.bReconnect and Params.bReconnect == true then
		_G.FLOG_INFO("BattlePassMgr:OnGameEventLoginRes, bReconnect is true")
		if self.CurrentProductID ~= "" then
			-- 断线重连时，可能有未收到完成通知的订单，需要重新查询状态
		end
	end
end

function BattlePassMgr:OnBattlePassModuleOpen(ModuleID)
    if ModuleID == ProtoCommon.ModuleID.ModuleIDBattlePass then
        self:SendBattlePassStateReq()
    end
end

-- 获取最近的赛季开启时间
function BattlePassMgr:GetNearestSeasonStartTime()
    local Cfgs = self.Cfg
    local ServerTime = TimeUtil.GetServerLogicTime()
    local Nearest_timestamp = nil
    local Min_diff = nil
    for _, cfg in ipairs(Cfgs) do
        local cfgStartTime = cfg.BeginTime
        if not string.isnilorempty(cfgStartTime) then
            local SeasonStartTime = TimeUtil.GetTimeFromString(cfgStartTime)
            local Diff = math.abs(SeasonStartTime - ServerTime)
            if Min_diff == nil or Diff < Min_diff then
                Min_diff = Diff
                Nearest_timestamp = SeasonStartTime
            end
        end
    end
    return Nearest_timestamp
end

-- 获取最近的赛季结束时间
function BattlePassMgr:GetNearestSeasonEndTime()
    local ServerTime = TimeUtil.GetServerLogicTime()
    local Nearest_timestamp = nil
    local Min_diff = nil
    local Cfg = BattepassSeasonCfg:FindCfgByKey(self.BattlePassID)
    if Cfg ~= nil then
        local cfgEndTime = Cfg.EndTime
        if not string.isnilorempty(cfgEndTime) then
            local SeasonEndTime = TimeUtil.GetTimeFromString(cfgEndTime)
            local Diff = math.abs(SeasonEndTime - ServerTime)
            if Min_diff == nil or Diff < Min_diff then
                Min_diff = Diff
                Nearest_timestamp = SeasonEndTime
            end
        end
    end
    return Nearest_timestamp or 0
end

-----------------------------------服务器协议 start-----------------------------------
-- 请求战令状态请求
function BattlePassMgr:SendBattlePassStateReq()
    local MsgID = CS_CMD.CS_CMD_BATTLE_PASS
    local SubMsgID = SUB_MSG_ID.BattlePassCmdState

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BattlePassMgr:OnSendBattlePassStateRsp(MsgBody)
    if MsgBody == nil then
        return
    end 
    local State = MsgBody.State 
    if State == nil then
        return
    end
    self.DataValidTime = State.DataValidTime
    self.Exp = State.Exp
    self.CurExpMax = State.CurExpMax
    self.BattlePassID = State.ID
    self.BattlePassLevel = State.Level
    self.BattlePassLevelLeftExp = State.LevelLeftExp
    self.BattlePassGradeType = State.Grade
    self.BattlePassWeekSign = State.WeekSign

    self:SetWeekSignRedDot()

    if self.EndTimer ~= nil then
        self:UnRegisterTimer(self.EndTimer)
        self.EndTimer = nil
    end
    if self.StartTimer ~= nil then
        self:UnRegisterTimer(self.StartTimer)
        self.StartTimer = nil
    end

    -- 如果赛季ID为0 或者 为空，通知其他界面隐藏战令按钮，开启下个赛季开启倒计时
    if self.BattlePassID == nil or self.BattlePassID == 0 then
        self.IsBattlePassOpen = false
        self.StartTimer = self:RegisterTimer(self.OnNextStartTimer,0, 1, 0)
    else
        -- 通知其他界面关闭赛季按钮，开启下个赛季开启倒计时
        self.IsBattlePassOpen = true
        self.EndTimer = self:RegisterTimer(self.OnNextEndTimer, 0, 1, 0)
    end

    local Cfg = BattepassSeasonCfg:FindCfgByKey(State.ID)
    if Cfg ~= nil then
        self.BattlePassMaxLevel = Cfg.LevelMax
        self.BattlePassSeasonCfg = Cfg
        EventMgr:SendEvent(EventID.BattlePassBaseInfoUpdate)
        EventMgr:SendEvent(EventID.BattlePassExpUpdate, {NewExp = self.BattlePassLevelLeftExp, NoPlayAnim = true})
        -- 获取任务信息跟等级奖励信息
        self:SendBattlePassLevelRewardReq()
        self:SendBattlePassTaskReq(BattlePassDefine.TaskType.All)
    end

    EventMgr:SendEvent(EventID.BattlePassOpeningUp)
end

function BattlePassMgr:OnNextStartTimer()
    local NextStartTime = BattlePassMgr:GetNearestSeasonStartTime()
    local ServerTime = TimeUtil.GetServerLogicTime()
    -- _G.FLOG_INFO("BattlePassMgr:OnNextStartTimer 1111 ServerTime " ..ServerTime )
    if ServerTime >= NextStartTime then
        self:UnRegisterTimer(self.StartTimer)
        self.StartTimer = nil
        -- 如果超过了最后1期的结束时间，别想了毁灭吧
        local Cfg = self.Cfg[#self.Cfg]
        if Cfg and not string.isnilorempty(Cfg.EndTime) then
            local LastestTime = TimeUtil.GetTimeFromString(Cfg.EndTime)
            if ServerTime <= LastestTime then
                BattlePassMgr:SendBattlePassStateReq()
            end
        end
    end
end

function BattlePassMgr:OnNextEndTimer()
    local NextEndTime = BattlePassMgr:GetNearestSeasonEndTime()
    local ServerTime = TimeUtil.GetServerLogicTime()
    -- _G.FLOG_INFO("BattlePassMgr:OnNextEndTimer 1111 ServerTime " ..ServerTime )
    if ServerTime >= NextEndTime then
        self:UnRegisterTimer(self.EndTimer)
        self.EndTimer = nil
        BattlePassMgr:SendBattlePassStateReq()
    end
end

-- 请求战令等级信息请求
function BattlePassMgr:SendBattlePassLevelRewardReq()
    local MsgID = CS_CMD.CS_CMD_BATTLE_PASS
    local SubMsgID = SUB_MSG_ID.BattlePassCmdLevel

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BattlePassMgr:OnSendBattlePassLevelRewardRsp(MsgBody)
    if MsgBody == nil then
        return
    end

    local Data = MsgBody.Level

    if Data == nil then
        return
    end
    
    ---记录已经领取的奖励的分段等级
    self.BasicLevelList = {}
    self.MiddleLevelList = {}
    for _, v in ipairs(Data.BasicList) do
        local EndLv = v.End
        for BeginLv = v.Begin, EndLv do
            if not table.contain(self.BasicLevelList, BeginLv) then
                table.insert(self.BasicLevelList, BeginLv)
            end
        end
    end

    for _, v in ipairs(Data.MiddleList) do
        local EndLv = v.End
        for BeginLv = v.Begin, EndLv do
            if not table.contain(self.MiddleLevelList, BeginLv) then
                table.insert(self.MiddleLevelList, BeginLv)
            end
        end
    end


    --设置红点
    if self:GetLevelRewardsAvailable() then
        _G.RedDotMgr:AddRedDotByID(BattlePassDefine.RedDotID.LevelReward)
    else
        _G.RedDotMgr:DelRedDotByID(BattlePassDefine.RedDotID.LevelReward)
    end
    
    -- 更新等级奖励
    EventMgr:SendEvent(EventID.BattlePassLevelRewardUpdate)
end

-- 请求战令领取等级奖励请求
---@param number Level 领取哪一级的奖励 如果为0，领取所有
---@param number GradeType 1基础  2进阶
function BattlePassMgr:SendBattlePassGetLevelReawrdReq(Level, GradeType)
    local MsgID = CS_CMD.CS_CMD_BATTLE_PASS
    local SubMsgID = SUB_MSG_ID.BattlePassCmdGetLevelReward

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    MsgBody.GetLevelReward = {Level = Level, Grade = GradeType}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

end

function BattlePassMgr:OnSendBattlePassGetLevelReawrdRsp(MsgBody)
    if MsgBody == nil then
        return
    end

    local GetLevelReward = MsgBody.GetLevelReward

    if GetLevelReward == nil then
        return
    end

    local GroupID = self:GetBattlePassGroupID()

    --展示奖励
    local Params = {}
    -- Params.ItemList = {}
    Params.ItemVMList = UIBindableList.New(MailSlotItemViewVM)
	Params.CommonRewardVMList =  UIBindableList.New(MailSlotItemViewVM)
	Params.BigRewardVMList =  UIBindableList.New(MailSlotItemViewVM)
    Params.ShowTips = true
    Params.PanelBtnVisible = true
    -- Params.HideClickItem = false
    Params.BtnRightCB = function ()
         UIViewMgr:HideView(UIViewID.BattlePassRewardPanel)  
        _G.UIViewMgr:ShowView(_G.UIViewID.BattlePassAdvanceView)
    end
    for _, v in ipairs(GetLevelReward.BasicChangeList) do
        for StartLv = v.Begin, v.End do
            local Cfg = BattlepassLevelRewardCfg:FindCfgByGroupIDAndLevel(GroupID, StartLv)
            if Cfg ~= nil and Cfg[1]~= nil and Cfg[1].BasicReward then
                for __, value in ipairs(Cfg[1].BasicReward) do
                    if value.ID ~= 0 then
                        -- table.insert(Params.CommonRewardList, { ResID = value.ID, Num = value.Num})
                        -- table.insert(Params.ItemList, {ResID = value.ID, Num = value.Num})

                        Params.ItemVMList:AddByValue({GID = 1, ResID = value.ID, Num = value.Num, IsValid = true, NumVisible = true, ItemNameVisible = true }, nil, true)
                        Params.CommonRewardVMList:AddByValue({GID = 1, ResID = value.ID, Num = value.Num, IsValid = true, NumVisible = true, ItemNameVisible = true }, nil, true)
                    end
                end
            end

            -- 数据更新
            if not table.contain(self.BasicLevelList, StartLv) then
                table.insert(self.BasicLevelList, StartLv)
            end

        end
    
	end

    -- 转换
    for _, v  in ipairs(GetLevelReward.MiddleChangeList) do
        for StartLv = v.Begin, v.End do
            local Cfg = BattlepassLevelRewardCfg:FindCfgByGroupIDAndLevel(GroupID, StartLv)
            if Cfg ~= nil and Cfg[1]~= nil and Cfg[1].MiddleReward then
                for __, value in ipairs(Cfg[1].MiddleReward) do
                    if value.ID ~= 0 then
                        -- table.insert(Params.CommonRewardList, {ResID = value.ID, Num = value.Num})
                        -- table.insert(Params.ItemList, {ResID = value.ID, Num = value.Num})
                        Params.ItemVMList:AddByValue({GID = 1, ResID = value.ID, Num = value.Num, IsValid = true, NumVisible = true, ItemNameVisible = true }, nil, true)
                        Params.CommonRewardVMList:AddByValue({GID = 1, ResID = value.ID, Num = value.Num, IsValid = true, NumVisible = true, ItemNameVisible = true }, nil, true)
                    end
                end
            end

            -- 数据更新
            if not table.contain(self.MiddleLevelList, StartLv) then
                table.insert(self.MiddleLevelList, StartLv)
            end
        end
	end

    local Cfgs = BattlepassBigrewardCfg:FindCfgsByGroupID(GroupID)
    for index, value in ipairs(Cfgs) do
        -- table.insert(Params.BigRewardList, {ResID = value.ItemID, Num = value.Num})
        Params.BigRewardVMList:AddByValue({GID = 1, ResID = value.ItemID, Num = value.Num, IsValid = true, NumVisible = false, ItemNameVisible = true }, nil, true)
    end

    -- 展示奖励
    if BattlePassMgr:GetBattlePassGrade() == BattlePassDefine.GradeType.Basic then
        UIViewMgr:ShowView(UIViewID.BattlePassRewardPanel, Params)  
    else
        UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
    end

    local IsLevelUp = GetLevelReward.Level > self.BattlePassLevel

    -- 数据更新
    self.Exp = GetLevelReward.Exp
    self.BattlePassLevel = GetLevelReward.Level
    self.BattlePassLevelLeftExp = GetLevelReward.LevelLeftExp

    -- 红点
    if self:GetLevelRewardsAvailable() then
        _G.RedDotMgr:AddRedDotByID(BattlePassDefine.RedDotID.LevelReward)
    else
        _G.RedDotMgr:DelRedDotByID(BattlePassDefine.RedDotID.LevelReward)
    end

    -- 更新界面
    EventMgr:SendEvent(EventID.BattlePassBaseInfoUpdate)
    EventMgr:SendEvent(EventID.BattlePassLevelRewardUpdate)

    if IsLevelUp then
        EventMgr:SendEvent(EventID.BattlePassLevelUp, { Level = GetLevelReward.Level })
    end

end

-- 请求战令任务信息
---@param number TaskType 任务类型 3本周  4挑战 
function BattlePassMgr:SendBattlePassTaskReq(InTaskType)
    local MsgID = CS_CMD.CS_CMD_ACTIVITY_SYSTEM
    local SubMsgID = TASK_SUB_MSG_ID.ListByID 

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID

    local ListByIDs = {}

    local WeekID = 3
    local ChallengeID = 4 
    local Cfg = (InTaskType ~= WeekID and InTaskType ~= ChallengeID) and ActivityCfg:FindLocalAllCfg(string.format("ActivityType = %d or ActivityType = %d", WeekID, ChallengeID)) or ActivityCfg:FindLocalAllCfg(string.format("ActivityType = %d", InTaskType))
    for _, v in ipairs(Cfg) do
        table.insert(ListByIDs, v.ActivityID)
    end
    MsgBody.ListByID = {ActIDs = ListByIDs}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BattlePassMgr:OnSendBattlePassTaskRsp(MsgBody)
    if MsgBody == nil then
        return
    end

    local Data = MsgBody.ListByID

    local List = Data.Details

    local ChallenegTaskList = {}
    local WeeklyTaskList = {}
    for _, data in ipairs(List) do
        local TaskActivityHead = data.Head
        local TaskID = TaskActivityHead.ActivityID
        local Cfg = ActivityCfg:FindCfgByKey(TaskID)
        if Cfg ~= nil then
            local TempTask = {}
            TempTask.TaskID = TaskID
            TempTask.Head = data.Head
            for _, node in ipairs(data.Nodes) do
                local NodeCfg = ActivityNodeCfg:FindCfgByKey(node.Head.NodeID)
                if NodeCfg ~= nil then
                    if NodeCfg.NodeSort == 1 then
                        TempTask.Nodes = node
                        if Cfg.ActivityType == 3 then
                            table.insert(WeeklyTaskList, TempTask)
                        elseif  Cfg.ActivityType == 4 then
                            table.insert(ChallenegTaskList, TempTask)
                        end
                    end
                end
            end
        end
    end

    if table.length(WeeklyTaskList) > 0 then
        self.WeeklyTaskList = WeeklyTaskList
    end
    if table.length(ChallenegTaskList) > 0 then
        self.ChallengeTaskList = ChallenegTaskList
    end

    -- 更新红点
    BattlePassMgr:SetBattlePassTaskRedDot()
    -- 更新界面
    EventMgr:SendEvent(EventID.BattlePassBaseInfoUpdate)
    EventMgr:SendEvent(EventID.BattlePassTaskUpdate)
end

--请求战令任务奖励
---@param number ActivityNodeID  任务ID
function BattlePassMgr:SendBattlePassGetTaskRewardReq(ActivityNodeID)
    local MsgID = CS_CMD.CS_CMD_ACTIVITY_SYSTEM
	local SubMsgID = TASK_SUB_MSG_ID.Reward

	local MsgBody = {
        Cmd = SubMsgID,
		Reward = { NodeID = ActivityNodeID },
    }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BattlePassMgr:OnNetMsgNodeGetReward(MsgBody)
    if nil == MsgBody or nil == MsgBody.Reward then
		return
	end
	local Reward = MsgBody.Reward
    local Detail = Reward.Detail
    local RewardNodeID = nil

    for _, data in ipairs(self.WeeklyTaskList) do
        local TaskActivityHead = data.Head
        local TaskID = TaskActivityHead.ActivityID
        if TaskID == Detail.Head.ActivityID then
            data.Head = Detail.Head
            for _, node in ipairs(Detail.Nodes) do
                if node.Head.NodeID == data.Nodes.Head.NodeID then
                    data.Nodes = node
                    RewardNodeID = data.Nodes.Head.NodeID
                    break
                end
            end
        end
    end

    for _, data1 in ipairs(self.ChallengeTaskList) do
        local TaskActivityHead = data1.Head
        local TaskID = TaskActivityHead.ActivityID
        if TaskID == Detail.Head.ActivityID then
            data1.Head = Detail.Head
            for _, node in ipairs(Detail.Nodes) do
                if node.Head.NodeID == data1.Nodes.Head.NodeID then
                    data1.Nodes = node
                    RewardNodeID = data1.Nodes.Head.NodeID
                    break
                end
            end
        end
    end

    --- 展示奖励道具(自己读表)
    -- if RewardNodeID ~= nil then
    --     local Params = {}
    --     Params.ItemList = {}
    --     local NodeCfg = ActivityNodeCfg:FindCfgByKey(RewardNodeID)
    --     if NodeCfg ~= nil then
    --         for _, value in ipairs(NodeCfg.Rewards) do
    --             if value.ItemID ~= 0 then
    --                 table.insert(Params.ItemList, {ResID = value.ItemID, Num = value.Num})
    --             end
    --         end
    --     end
    --     UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
    -- end

    self:SendBattlePassLevelRewardReq()
    self:SetBattlePassTaskRedDot()

    -- 更新界面
    EventMgr:SendEvent(EventID.BattlePassBaseInfoUpdate)
    EventMgr:SendEvent(EventID.BattlePassTaskUpdate)
end

--请求所有可以领取的任务奖励
function BattlePassMgr:SendGetAllTaskReward(NodeIDs)
    local MsgID = CS_CMD.CS_CMD_ACTIVITY_SYSTEM
	local SubMsgID = TASK_SUB_MSG_ID.MultiReward

	local MsgBody = {
        Cmd = SubMsgID,
		MultiReward = { NodeIDs = NodeIDs },
    }
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end


function BattlePassMgr:OnSendGetAllTaskReward(MsgBody)
    if nil == MsgBody or nil == MsgBody.MultiReward then
		return
	end

    local Details = MsgBody.MultiReward.Details

    if table.is_nil_empty(Details) then
        return
    end

    -- 
    -- local Params = {}
    -- Params.ItemList = {}
    -- local ItemMap = {}
    -- 解析领取的任务节点，把奖励放在里面
    -- for _, v in ipairs(Details) do
    --     for _, node in ipairs(v.Nodes) do
    --         local NodeCfg = ActivityNodeCfg:FindCfgByKey(node.Head.NodeID)
    --         if NodeCfg ~= nil and NodeCfg.NodeSort == 1 then
    --             for _, value in ipairs(NodeCfg.Rewards) do
    --                 if value.ItemID ~= 0 then
    --                     if table.contain(ItemMap, value.ItemID) then
    --                         ItemMap[value.ItemID].Num = value.Num + value.Num
    --                     else
    --                         ItemMap[value.ItemID] = {}
    --                         ItemMap[value.ItemID].ItemID = value.ItemID
    --                         ItemMap[value.ItemID].Num = value.Num
    --                     end 
    --                 end
    --             end
    --         end
    --     end
    -- end

    -- 
    -- for _, item in pairs(ItemMap) do
    --     table.insert(Params.ItemList, {ResID = item.ItemID, Num = item.Num})    
    -- end

    -- UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)

    -- 更新任务节点数据
    for _, detail in ipairs(Details) do
        BattlePassMgr:SetTaskInfo(detail, self.WeeklyTaskList)
        BattlePassMgr:SetTaskInfo(detail, self.ChallengeTaskList)
    end

    self:SendBattlePassLevelRewardReq()
    BattlePassMgr:SetBattlePassTaskRedDot()
    -- 更新界面
    EventMgr:SendEvent(EventID.BattlePassBaseInfoUpdate)
    EventMgr:SendEvent(EventID.BattlePassTaskUpdate)
    
end

function BattlePassMgr:SetBattlePassTaskRedDot()
    local MaxLevel = BattlePassMgr:GetBattlePassMaxLevel()
	local CurLevel = BattlePassMgr:GetBattlePassLevel()

    if CurLevel >= MaxLevel  then
        _G.RedDotMgr:DelRedDotByID(BattlePassDefine.RedDotID.Week)
        _G.RedDotMgr:DelRedDotByID(BattlePassDefine.RedDotID.Challenge)
        return
    end

    if self:GetWeeklyTaskAvailable() then
        _G.RedDotMgr:AddRedDotByID(BattlePassDefine.RedDotID.Week)
    else
        _G.RedDotMgr:DelRedDotByID(BattlePassDefine.RedDotID.Week)
    end

    if self:GetChallengeTaskAvailable() then
        _G.RedDotMgr:AddRedDotByID(BattlePassDefine.RedDotID.Challenge)
    else
        _G.RedDotMgr:DelRedDotByID(BattlePassDefine.RedDotID.Challenge)
    end
end

function BattlePassMgr:SetWeekSignRedDot()
    local MaxLevel = BattlePassMgr:GetBattlePassMaxLevel()
	local CurLevel = BattlePassMgr:GetBattlePassLevel()
    if (not self.BattlePassWeekSign) and not (CurLevel >= MaxLevel) then
        _G.RedDotMgr:AddRedDotByID(BattlePassDefine.RedDotID.WeekSign)
    else
        _G.RedDotMgr:DelRedDotByID(BattlePassDefine.RedDotID.WeekSign)
    end
end

function BattlePassMgr:SetTaskInfo(Detail, List)
    for _, data in ipairs(List) do
        local TaskActivityHead = data.Head
        local TaskID = TaskActivityHead.ActivityID
        if TaskID == Detail.Head.ActivityID then
            data.Head = Detail.Head
            for _, node in ipairs(Detail.Nodes) do
                if node.Head.NodeID == data.Nodes.Head.NodeID then
                    data.Nodes = node
                    return data.Head.NodeID
                end
            end
        end
    end
end

--请求战令周签到
function BattlePassMgr:SendBattlePassWeekSignReq()
    local MsgID = CS_CMD.CS_CMD_BATTLE_PASS
    local SubMsgID = SUB_MSG_ID.BattlePassCmdWeekSign 

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BattlePassMgr:OnSendBattlePassWeekSignRsp(MsgBody)
    if MsgBody == nil then
        return
    end

    local WeekSignRsp = MsgBody.WeekSign

    if WeekSignRsp == nil then
        return
    end

    local IsLevelUp =  WeekSignRsp.Level > self.BattlePassLevel
    self.Exp = WeekSignRsp.Exp
    self.BattlePassWeekSign = true
    self.BattlePassLevel = WeekSignRsp.Level
    self.BattlePassLevelLeftExp = WeekSignRsp.LevelLeftExp

    self:SendBattlePassLevelRewardReq()

    self:SetWeekSignRedDot()

    -- if self.BattlePassSeasonCfg ~= nil then
    --     local Params = {}
    --     Params.ItemList = {}
    --     table.insert(Params.ItemList, {ResID = ProtoRes.SCORE_TYPE.SCORE_TYPE_BATTLE_PASS_EXP, Num = self.BattlePassSeasonCfg.WeekSignExp})
    --     UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
    -- end

    if IsLevelUp then
        EventMgr:SendEvent(EventID.BattlePassLevelUp, { Level = WeekSignRsp.Level })
    end

    -- 更新界面
    EventMgr:SendEvent(EventID.BattlePassBaseInfoUpdate)
    EventMgr:SendEvent(EventID.BattlePassExpUpdate, {NewExp = self.BattlePassLevelLeftExp, IsLevelUp = IsLevelUp})
end

function BattlePassMgr:SendBattlePassLevelUp(Level)
    local MsgID = CS_CMD.CS_CMD_BATTLE_PASS
    local SubMsgID = SUB_MSG_ID.BattlePassCmdLevelUp 

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    MsgBody.LevelUp  = {UpToLevel  = Level}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BattlePassMgr:OnSendBattlePassLevelUpRsp(MsgBody)
    if MsgBody == nil then
        return
    end

    local LevelUp = MsgBody.LevelUp

    if LevelUp == nil then
        return
    end

    self.Exp = LevelUp.Exp
    self.BattlePassLevel = LevelUp.Level
    self.BattlePassLevelLeftExp = LevelUp.LevelLeftExp

    self:SendBattlePassLevelRewardReq()

    -- 更新界面
    EventMgr:SendEvent(EventID.BattlePassBaseInfoUpdate)
    EventMgr:SendEvent(EventID.BattlePassLevelUp, { Level = LevelUp.Level })
    EventMgr:SendEvent(EventID.BattlePassExpUpdate, {NewExp = self.BattlePassLevelLeftExp, IsLevelUp = true})
end

--战令级别变化
function BattlePassMgr:OnPushBattlePassGradeChange(MsgBody)
    if MsgBody == nil then
        return
    end

    local GradeChangeRsp = MsgBody.GradeChange

    if GradeChangeRsp == nil then
        return
    end
    
    self.BattlePassGradeType = GradeChangeRsp.Grade

    -- 更新界面
    self:SendBattlePassStateReq()
    EventMgr:SendEvent(EventID.BattlePassBaseInfoUpdate)
    EventMgr:SendEvent(EventID.BattlePassGradeUpdate, {Grade =  GradeChangeRsp.Grade})
end

--战令经验改变推送
function BattlePassMgr:OnPushBattlePassExpChange(MsgBody)
    if MsgBody == nil then
        return
    end

    local ExpChange = MsgBody.ExpChange

    if ExpChange == nil then
        return
    end
    
    local IsLevelUp = ExpChange.Level > self.BattlePassLevel
    
    self.Exp = ExpChange.Exp
    self.BattlePassLevel = ExpChange.Level
    self.BattlePassLevelLeftExp = ExpChange.LevelLeftExp

    self:SendBattlePassStateReq()

    if IsLevelUp then
        EventMgr:SendEvent(EventID.BattlePassLevelUp, { Level = ExpChange.Level })
    end

    -- 更新界面
    EventMgr:SendEvent(EventID.BattlePassBaseInfoUpdate)
    EventMgr:SendEvent(EventID.BattlePassExpUpdate, {NewExp = self.BattlePassLevelLeftExp, IsLevelUp = IsLevelUp})
end

function BattlePassMgr:OnNetTaskNodesChange(MsgBody)
    if MsgBody == nil then
        return
    end

    local NodesChange = MsgBody.NodesChange 

    if NodesChange == nil then
        return
    end

    local List = NodesChange.Nodes

    -- 更新任务节点数据
    for _, v in ipairs(List) do
        for _, value in ipairs(self.ChallengeTaskList) do
            if value.Nodes.Head.NodeID == v.Head.NodeID then
                value.Nodes.Extra.Progress = v.Extra.Progress
                -- value.Nodes.Head = v
                value.Nodes = v
            end
        end

        for _, value in ipairs(self.WeeklyTaskList) do
            if value.Nodes.Head.NodeID ==v.Head.NodeID  then
                -- value.Nodes.Extra.Progress = v.Extra.Progress
                value.Nodes = v
            end
        end
    end

    -- 更新红点
    BattlePassMgr:SetBattlePassTaskRedDot()
    -- 更新界面
    EventMgr:SendEvent(EventID.BattlePassBaseInfoUpdate)
    EventMgr:SendEvent(EventID.BattlePassTaskUpdate)
end
-----------------------------------服务器协议 end-----------------------------------
------------------------------------对外接口 start----------------------------------
---
---
function BattlePassMgr:GetIsBattlePassOpen()
    return self.IsBattlePassOpen
end
---@return number 当前总经验
function BattlePassMgr:GetTotalExp()
    return self.Exp
end

---@return number 本周经验上限 
function BattlePassMgr:GetWeekMaxExp()
    return self.CurExpMax
end

---@return number 当前赛季ID 
function BattlePassMgr:GetSeasonID()
    return self.BattlePassID
end

---@return number 通行证等级
function BattlePassMgr:GetBattlePassLevel()
    return self.BattlePassLevel
end

---@return number 通行证上限等级
function BattlePassMgr:GetBattlePassMaxLevel()
    if self.BattlePassSeasonCfg == nil then
        return 0
    end

    return self.BattlePassSeasonCfg.LevelMax or 0
end

---@return number 通行证groupId
function BattlePassMgr:GetBattlePassGroupID()
    if self.BattlePassSeasonCfg == nil then
        return 0
    end

    return self.BattlePassSeasonCfg.LevelGroup or 0
end

---@return number 当前等级升级所需经验
function BattlePassMgr:GetBattlePasslLevelUpNeedExp(Level)
    if self.BattlePassSeasonCfg == nil then
        return 1
    end

    local Cfg = BattlepassLevelRewardCfg:FindCfgByGroupIDAndLevel(self.BattlePassSeasonCfg.LevelGroup, Level)
    
    if Cfg[1] == nil then
        return 1
    end

    return Cfg[1].UpExp or 1
end

---@return number 赛季结束时间
function BattlePassMgr:GetBattlePassEndTime()
    if self.BattlePassSeasonCfg == nil then
        return ""
    end

    return self.BattlePassSeasonCfg.EndTime or ""
end

---@return number 赛季开始时间
function BattlePassMgr:GetBattlePassStartTime()
    if self.BattlePassSeasonCfg == nil then
        return ""
    end

    return self.BattlePassSeasonCfg.BeginTime or ""
end

---@return number 赛季商店ID
function BattlePassMgr:GetBattleShopID()
    if self.BattlePassSeasonCfg == nil then
        return 0
    end

    return self.BattlePassSeasonCfg.ShopID or 0
end

---@return number 当前等级经验
function BattlePassMgr:BattlePasslCurLevelExp()
    return self.BattlePassLevelLeftExp
end

---@return number 通行证级别(基础，进阶，至臻)
function BattlePassMgr:GetBattlePassGrade()
    return self.BattlePassGradeType
end

---@return boolean 本周是否签到(false 未签到，true已经签到)
function BattlePassMgr:GetBattlePassWeekSign()
    return self.BattlePassWeekSign
end

---@return boolean 等级奖励页签是否能领奖
function BattlePassMgr:GetLevelRewardsAvailable()
    local GroupID = BattlePassMgr:GetBattlePassGroupID()
    local CurLevel = BattlePassMgr:GetBattlePassLevel()
    local Grade = BattlePassMgr:GetBattlePassGrade()
    local Cfgs = BattlepassLevelRewardCfg:FindCfgsByGroupID(GroupID)

    local Available = false
    for _, v in ipairs(Cfgs) do
        for index, value in ipairs(v.BasicReward) do
            local GotStatus = BattlePassMgr:GotLevelReward(v.Level, BattlePassDefine.GradeType.Basic)
            if CurLevel >= v.Level and not GotStatus then
                Available =  true
            end
        end
        
        -- 进阶的两个奖励是一起发的
        if Grade > BattlePassDefine.GradeType.Basic then
            for index, value in ipairs(v.MiddleReward) do
                if index == 1 then
                    local GotStatus = BattlePassMgr:GotLevelReward(v.Level, BattlePassDefine.GradeType.Middle)
                    if CurLevel >= v.Level and not GotStatus then
                        Available = true
                    end
                end
            end
        end
    end

    return Available
end

---@return boolean 任务页签是否能领奖
function BattlePassMgr:GetTaskAvailable()
    return self:GetWeeklyTaskAvailable() or self:GetChallengeTaskAvailable()
end

function BattlePassMgr:GetWeeklyTaskAvailable()
    for _, v in ipairs(self.WeeklyTaskList) do
        if v.Nodes.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
            return true
        end
    end
    return false
end

function BattlePassMgr:GetChallengeTaskAvailable()
    for _, v in ipairs(self.ChallengeTaskList) do
        if v.Nodes.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
            return true
        end
    end
    return false
end

function BattlePassMgr:GetDataValidTime()
    return self.DataValidTime
end

function BattlePassMgr:GotLevelReward(Level, GradeType)
    local MaxLevel = BattlePassMgr:GetBattlePassMaxLevel()
	local CfgReward = BattlepassGlobalCfg:FindCfgByKey(ProtoRes.BattlePassGlobalParamType.BattlePassGlobalParamTypeBuyLevelMax)
	if  CfgReward ~= nil then
		MaxLevel =  CfgReward.Value[1]
	end
    if GradeType == BattlePassDefine.GradeType.Basic then
        if Level > MaxLevel then
            return true
        end
        return table.contain(self.BasicLevelList, Level)
    end

    if GradeType == BattlePassDefine.GradeType.Middle then
        return table.contain(self.MiddleLevelList, Level) and self:GetBattlePassGrade() > BattlePassDefine.GradeType.Basic
    end

    return false
end

function BattlePassMgr:GetTaskList(Type)
    return Type == BattlePassDefine.TaskType.Weekly and self.WeeklyTaskList or self.ChallengeTaskList
end

function BattlePassMgr:GetTaskByID(TaskID)
    for _, v in ipairs(self.WeeklyTaskList) do
        if v.TaskID == TaskID then
            return v, BattlePassDefine.TaskType.Weekly
        end
    end

    for _, v in ipairs(self.ChallengeTaskList) do
        if v.TaskID == TaskID then
            return v, BattlePassDefine.TaskType.Challenge
        end
    end

    return nil
end

function BattlePassMgr:GetTaskCanGetByID(TaskID)
    local Task, TaskType = self:GetTaskByID(TaskID)
    return Task, TaskType, (Task.CanGetNum > 0)
end

function BattlePassMgr:DoDelayOpenRewardPanel()
    _G.UIViewMgr:ShowView(_G.UIViewID.BattlePassAdvanceView)
    _G.UIViewMgr:HideView(_G.UIViewID.BattlePassMainView)
end 

function BattlePassMgr:DelayCloseRewardPanel()
    self.TimerID = self:RegisterTimer(self, self.DoDelayCloseOpenRewardPanel, 0.1, 0.1, 1)
end

function BattlePassMgr:DoDelayCloseOpenRewardPanel()
    _G.UIViewMgr:ShowView(_G.UIViewID.BattlePassMainView)
    _G.UIViewMgr:HideView(_G.UIViewID.BattlePassAdvanceView)
end

function BattlePassMgr:OpenBattlePassPanel()
    if not BattlePassMgr:GetIsBattlePassOpen() then
        MsgTipsUtil.ShowTips(LSTR())
        return
    end

    _G.UIViewMgr:ShowView(_G.UIViewID.BattlePassMainView)
end

------------------------------------ 对外接口 end ----------------------------------
function BattlePassMgr:Recharge(Order, Crystas, Bonus, View)
	FLOG_INFO("Recharge amount: "..tostring(Crystas))
	FLOG_INFO("Recharge bonus: "..tostring(Bonus))

	PayUtil.BuyCoins(Order,
	function(_, BillData) self:OnBillReceived(BillData) end,
	function(_) self:OnLoginExpired() end,
	nil, ---- 切后台可能导致米大师回调丢失，不再使用
	function(_, GoodsData) self:OnGoodsReceived(GoodsData) end,
	View)
end


function BattlePassMgr:OnBillReceived(BillData)
	if BillData == nil then
		FLOG_ERROR("Cannot get pay bill data")
		return
	end

	if BillData.URL == "" then
		FLOG_ERROR("Pay bill is empty")
	end
end

function BattlePassMgr:OnLoginExpired()
	FLOG_ERROR("Login expired!")
end

function BattlePassMgr:OnPayFinished(PayReturnData)
	if PayReturnData == nil then
		FLOG_ERROR("Cannot get pay return data")
		return
	end

    if PayReturnData.ResultCode == 0 then
		FLOG_INFO("Pay succeeded.")
		if not self.ReceivedGoods then
			FLOG_INFO("Waiting for goods...")
			self.PayFinished = true
		else
			self:OnRechargeSucceed()
		end
	end
end

function BattlePassMgr:OnGoodsReceived(GoodsData)
    self:OnRechargeSucceed()
end

function BattlePassMgr:OnRechargeSucceed()
	self.ReceivedGoods = false
	self.PayFinished = false
end


--要返回当前类
return BattlePassMgr