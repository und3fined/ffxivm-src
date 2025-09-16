--
-- Author: Carl
-- Date: 2025-3-6 16:57:14
-- Description:--光之启程Mgr

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local JumpUtil = require("Utils/JumpUtil")
local MapUtil = require("Game/Map/MapUtil")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local QuestMgr = require("Game/Quest/QuestMgr")
local QuestHelper = require("Game/Quest/QuestHelper")
local AdventureDefine = require("Game/Adventure/AdventureDefine")
local DataReportUtil = require("Utils/DataReportUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local DepartOfLightVMUtils = require("Game/Departure/DepartOfLightVMUtils")
local DepartOfLightDefine = require("Game/Departure/DepartOfLightDefine")
local DepartOfLightVM = require("Game/Departure/VM/DepartOfLightVM")
local TASK_SUB_MSG_ID = ProtoCS.Game.Activity.Cmd
local DEPART_SUB_MSG_ID = ProtoCS.Role.LightJourney.LightJourneyCmd
local DEPART_GAME_ID = ProtoCS.Role.LightJourney.JourneyGameID
local EModuleID = DepartOfLightDefine.EModuleID
local OPS_JUMP_TYPE = ProtoRes.Game.OPS_JUMP_TYPE
local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local EProfType = ProtoCommon.prof_type
local UIViewID = _G.UIViewID
local PWorldMgr = _G.PWorldMgr
local GameNetworkMgr
local UIViewMgr
local EventMgr

local CS_CMD = ProtoCS.CS_CMD
local DepartOfLightMgr = LuaClass(MgrBase)

function DepartOfLightMgr:OnInit()

end

function DepartOfLightMgr:OnBegin()
    GameNetworkMgr = _G.GameNetworkMgr
    EventMgr = _G.EventMgr
    UIViewMgr = _G.UIViewMgr
    self.TryOpenRecycleView = false
end

function DepartOfLightMgr:OnEnd()
end

function DepartOfLightMgr:OnShutdown()
end

function DepartOfLightMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, TASK_SUB_MSG_ID.ListByID, self.OnNetMsgDepartActivityInfoRsp) -- 活动节点信息
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, TASK_SUB_MSG_ID.Reward, self.OnNetMsgNodeGetReward) -- 领取活动节点奖励
    --self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, TASK_SUB_MSG_ID.MultiReward, self.OnNetMsgGetAllTaskReward) -- 一键领取所有任务奖励
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, TASK_SUB_MSG_ID.NodesChange, self.OnNetTaskNodesChange) -- 可领奖任务推送
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIGHT_JOURNEY, DEPART_SUB_MSG_ID.CmdTotalValue, self.OnNetMsgAllTaskProgressRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIGHT_JOURNEY, DEPART_SUB_MSG_ID.CmdPersonalityValue, self.OnNetMsgPersonRecordDataRsp)
end

function DepartOfLightMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpenNotify)
	self:RegisterGameEvent(EventID.ModuleOpenMainPanelFadeAnim,self.OnPlayFadeAnim)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldEnter)
end

--- @type 当进入副本
function DepartOfLightMgr:OnPWorldEnter(Params)
    UIViewMgr:HideView(UIViewID.DepartOfLightMainPanel) -- 隐藏主界面
    UIViewMgr:HideView(UIViewID.DepartOfLightActivityDetailView)
    UIViewMgr:HideView(UIViewID.DepartOfLightRecyclePanel)
end

function DepartOfLightMgr:OnGameEventLoginRes()
    -- 登录时拉取个性化数据，用于判断本玩法是否结束
    if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDLightJourney) then
        self:SendDepartActivityInfoReq()
        self:SendGetAllPersonRecordReq()
    end
end

---@type 左侧玩法页签被点击
function DepartOfLightMgr:OnActivityClicked(Index)
    DepartOfLightVM:OnActivityClicked(Index)
    UIViewMgr:HideView(UIViewID.DepartOfLightActivityDetailView)
end

---@type 说明图片被点击
function DepartOfLightMgr:OnDescIconClicked(SelectedIndex)
    -- 显示玩法详情界面
    UIViewMgr:ShowView(UIViewID.DepartOfLightActivityDetailView, {Index = SelectedIndex})
    DepartOfLightVM:OnDescIconClicked(SelectedIndex)
end

---@type 切换下张说明图片
function DepartOfLightMgr:OnNextDescIconClicked()
    return DepartOfLightVM:OnSwitchDescIconNext()
end

---@type 切换上张说明图片
function DepartOfLightMgr:OnUpDescIconClicked()
    return DepartOfLightVM:OnSwitchDescIconUp()
end


--- @type 跳转按钮被点击
function DepartOfLightMgr:OnGotoPlayStyle(Index)
    if DepartOfLightVM:IsDepartureReadyClosed() then
        self:ShowDepartRecycleView()
        return
    end

    local JumpType =  1
    local JumpParam = 12
    -- Fate、衣橱、战斗职业直接解锁
    local CurrActivityInfo = DepartOfLightVM:GetCurrActivityInfo()
    local ActivityID = CurrActivityInfo and CurrActivityInfo.ActivityID or 0
    local NodeInfo = DepartOfLightVM:GetActivityNodeHeadInfo(ActivityID) --NodeList[1]
    if NodeInfo then
        local NodeDetail = DepartOfLightVMUtils.GetActivityNodeDetail(NodeInfo.NodeID)
        JumpType =  NodeDetail and NodeDetail.JumpType  -- 配置
        JumpParam = NodeDetail and NodeDetail.JumpParam -- 配置
    end
    local ActivityDescInfo = DepartOfLightVMUtils.GetActivityDescInfoByActivityID(ActivityID)
    local ModuleID = ActivityDescInfo and ActivityDescInfo.ModuleID
    -- 制作笔记、采集笔记、钓鱼笔记\金蝶游乐场需要解锁
    local _IsModuelOpen, QuestName = DepartOfLightVM:GetModuleOpenInfo(ModuleID)
    if not _IsModuelOpen then
        -- 冒险系统解锁
        local _IsAdventureOpen, _ = DepartOfLightVM:GetModuleOpenInfo(EModuleID.ModuleIDAdventure)
        if ModuleID == EModuleID.ModuleIDMakerNote then
            if _IsAdventureOpen then
                JumpParam = 22 -- 职业任务界面->最前的能工巧匠职业
            else
                JumpParam = 38 -- 角色界面->最前的能工巧匠职业
            end
        end

        -- 解锁采矿工/园艺工后开启
        if ModuleID == EModuleID.ModuleIDGatherNote then
            if _IsAdventureOpen then
                _G.AdventureCareerMgr:JumpToTargetProf(EProfType.PROF_TYPE_MINER) -- 职业任务界面->选中最前的采集职业
                return
            else
                JumpParam = 38 -- 角色界面->最前的采矿工职业
            end
        end

        -- 解锁捕鱼人后开启
        if ModuleID == EModuleID.ModuleIDFisherNote then
            if _IsAdventureOpen then
                _G.AdventureCareerMgr:JumpToTargetProf(EProfType.PROF_TYPE_FISHER) -- 职业任务界面->选中捕鱼人职业
                return
            else
                JumpParam = 38 -- 角色界面->选中捕鱼人职业
            end
        end

        -- 金蝶游乐场
        if ModuleID == EModuleID.ModuleIDGoldSauserMain then
            --local IsFinishPreTask = string.isnilorempty(QuestName) -- 是否完成前置任务（主线11级任务）
            local IsFinishPreTask = _G.QuestMgr:GetQuestStatus(140553) == QUEST_STATUS.CS_QUEST_STATUS_FINISHED 
            if IsFinishPreTask then
                --JumpParam = 33 -- 前往任务界面
                self:OpenQuestView(17074)-- 171104
                return
            else
                _G.MsgTipsUtil.ShowTips("当前未完成主线11级任务") -- 需完成11级主线任务
                return
            end
        end

        -- 战斗职业，需判断冒险系统是否已解锁，如果解锁则跳转冒险，否则跳转角色系统
        if ModuleID == EModuleID.ModuleIDGamePworld then
            if _IsAdventureOpen then
                --_G.AdventureCareerMgr:JumpToTargetProf(EProfType.PROF_TYPE_MINER) -- 职业任务界面->选中最前的采集职业
                _G.UIViewMgr:ShowView(UIViewID.AdventruePanel) -- 冒险系统
                return
            else
                _G.EquipmentMgr:ShowProfDetail() -- 角色界面
            end
            return
        end
    end


    if JumpType == OPS_JUMP_TYPE.TABLE_JUMP then
        JumpUtil.JumpTo(tonumber(JumpParam))
    end
end

function DepartOfLightMgr:OpenQuestView(ChapterID)
    --local ID = 140553
	local ViewModel = self.ViewModel

	--local ChapterID = ID
    local ChapterCfg = QuestHelper.GetChapterCfgItem(ChapterID)
	if ChapterCfg == nil or ChapterCfg.StartQuest == nil then
		return
	end
    local StartQuestCfg = QuestHelper.GetQuestCfgItem(ChapterCfg.StartQuest)
	if  StartQuestCfg == nil or StartQuestCfg.id == nil  then
		return
	end
    local Status = QuestMgr:GetQuestStatus(StartQuestCfg.id)
    local MapDefine = require("Game/Map/MapDefine")

    if Status == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED then
        local Params = {}
        Params.MapID  = StartQuestCfg.AcceptMapID or 0
        --ViewModel:SetItemNewState(false)
        -- local Type = AdventureRecommendTaskMgr:GetRecommendTaskType(ChapterID)
        -- AdventureRecommendTaskMgr:DelRedDot(Type, ChapterID)

        _G.WorldMapMgr:ShowWorldMapQuest(StartQuestCfg.AcceptMapID, nil, StartQuestCfg.id, MapDefine.MapOpenSource.RecommendTask)

        DataReportUtil.ReportRecommendTaskData("ReTasksInfo", tostring(AdventureDefine.ReportAdventureRecommendTaskType.GoToBtn), ChapterID)
    else
		local QuestMainVM = require("Game/Quest/VM/QuestMainVM")
		local AllVMs = QuestMainVM.QuestLogVM:GetAllChapterVMs()
		local TargetQuestID = StartQuestCfg.id or 0
		for i = 1, AllVMs:Length() do
			local VM = AllVMs:Get(i)
			if VM.ChapterID == ChapterID then
				local MapID = VM.TargetMapID
				TargetQuestID = VM.QuestID
				if (MapID == nil) or (MapID == 0) then return end
				local UIMapID = MapUtil.GetUIMapID(MapID)
				_G.WorldMapMgr:ShowWorldMapQuest(MapID, UIMapID, TargetQuestID)
				DataReportUtil.ReportRecommendTaskData("ReTasksInfo", tostring(AdventureDefine.ReportAdventureRecommendTaskType.GoToBtn), ChapterID)
				break
			end
		end
    end
end

function DepartOfLightMgr:OnModuleOpenNotify(ModuleID)
    if ProtoCommon.ModuleID.ModuleIDLightJourney == ModuleID then
        self.NewOpenLightJourney = true
        DepartOfLightVM.IsForeverClose = false
        self:SendDepartActivityInfoReq()
        self:SendGetAllPersonRecordReq()
    end
end

function DepartOfLightMgr:OnPlayFadeAnim(IsIn)
	if IsIn then
        if self.NewOpenLightJourney then
            self.NewOpenLightJourney = false
            EventMgr:SendEvent(EventID.DepartEntranceOpened)
        end
	end
end

--- @type 是否显示主界面入口
function DepartOfLightMgr:IsShowEntrance()
    local IsOpen = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDLightJourney)
    local IsClosedForever = DepartOfLightVM:IsDepartureClosedForever()
    return IsOpen and not IsClosedForever
end

--- @type 显示主界面
function DepartOfLightMgr:ShowDepartMainView()
    self:SendDepartActivityInfoReq()
    self:SendGetAllTaskProgressReq()
    self:SendGetAllPersonRecordReq()
    UIViewMgr:ShowView(UIViewID.DepartOfLightMainPanel)
end

--- @type 当启程永久关闭
function DepartOfLightMgr:OnDepartureClosedForever()
    EventMgr:SendEvent(EventID.DepartEntranceUpdate) -- 隐藏入口
    UIViewMgr:HideView(UIViewID.DepartOfLightMainPanel) -- 隐藏主界面
end

--- @type 显示回收界面
function DepartOfLightMgr:ShowDepartRecycleView()
    UIViewMgr:HideView(UIViewID.DepartOfLightActivityDetailView)
    self.TryOpenRecycleView = true
    self:SendGetAllPersonRecordReq()
end


--region 测试---------------------------------------------------------------

---@type 玩家玩法历史高光数据回包
function DepartOfLightMgr:OnNetMsgPersonRecordDataRspTest()
    local MsgBody = {
        PersonalityValue = {
            JourneyValues = {
                {GameID = 2, TotalValue = 10, DayMaxValue = 3, DayMaxValueTime = _G.TimeUtil.GetLocalTime(), FinishTime = _G.TimeUtil.GetLocalTime() - 1800},
                {GameID = 1, TotalValue = 10, DayMaxValue = 3, DayMaxValueTime = _G.TimeUtil.GetLocalTime(), FinishTime = _G.TimeUtil.GetLocalTime() - 1800},
                {GameID = 4, TotalValue = 10, DayMaxValue = 3, DayMaxValueTime = _G.TimeUtil.GetLocalTime(), FinishTime = _G.TimeUtil.GetLocalTime() - 1800},
                {GameID = 5, TotalValue = 80, DayMaxValue = 3, DayMaxValueTime = _G.TimeUtil.GetLocalTime(), FinishTime = _G.TimeUtil.GetLocalTime() - 1800},
                {GameID = 7, TotalValue = 100, DayMaxValue = 30, DayMaxValueTime = _G.TimeUtil.GetLocalTime(), FinishTime = _G.TimeUtil.GetLocalTime() - 1800},
                {GameID = 6, TotalValue = 10, DayMaxValue = 3, DayMaxValueTime = _G.TimeUtil.GetLocalTime(), FinishTime = _G.TimeUtil.GetLocalTime() - 1800},
                {GameID = 3, TotalValue = 50, DayMaxValue = 3, DayMaxValueTime = _G.TimeUtil.GetLocalTime(), FinishTime = _G.TimeUtil.GetLocalTime() - 1800},
            }
        }
    }

    self:OnNetMsgPersonRecordDataRsp(MsgBody)
end
--endregion测试

--region NetMsg---------------------------------------------------------------

---@type 请求光之启程活动信息
function DepartOfLightMgr:SendDepartActivityInfoReq()
    local MsgID = CS_CMD.CS_CMD_ACTIVITY_SYSTEM
    local SubMsgID = TASK_SUB_MSG_ID.ListByID 
    local ListByIDs = DepartOfLightVMUtils.GetActivityIDList()
    if ListByIDs == nil then
        return
    end
    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    MsgBody.ListByID = {ActIDs = ListByIDs}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 光之启程活动信息
function DepartOfLightMgr:OnNetMsgDepartActivityInfoRsp(MsgBody)
    if MsgBody == nil then
        return
    end

    local ListByID = MsgBody.ListByID
    local List = ListByID.Details
    local ActivityInfoList = {}
    for _, Data in ipairs(List) do
        local ActivityID = Data.Head and Data.Head.ActivityID or 0
        if not DepartOfLightVMUtils.IsDepartureActivity(ActivityID) then
            return
        end
        local ActivityInfo = self:GetActivityInfoFromServer(Data)
        if ActivityInfo then
            table.insert(ActivityInfoList, ActivityInfo)
        end
    end
    
    DepartOfLightVM:UpdateActivityInfoList(ActivityInfoList)
    local ActivityNodeHeadList = self:GetActivityNodeHeadList(List)
    DepartOfLightVM:UpdateActivityNodeHeadInfo(ActivityNodeHeadList)
    -- 更新界面
    EventMgr:SendEvent(EventID.DepartOfLightBaseInfoUpdate)
end

---@type 活动信息 后台返回的数据本地重新组织
function DepartOfLightMgr:GetActivityInfoFromServer(ActivityDetail)
    if ActivityDetail == nil then
        return
    end

    local TaskActivityHead = ActivityDetail.Head
    local ActivityInfo = {
        ActivityID = TaskActivityHead and TaskActivityHead.ActivityID or 0, -- 活动ID/玩法节点
        EmergencyShutDown = TaskActivityHead and TaskActivityHead.EmergencyShutDown,  -- 紧急关闭
        Effected = TaskActivityHead and TaskActivityHead.Effected,    -- 是否已生效/生效条件
        Hiden = TaskActivityHead and TaskActivityHead.Hiden   -- 是否隐藏 仅隐藏活动逻辑事件正常触发
    }

    if not DepartOfLightVMUtils.IsDepartureActivity(ActivityInfo.ActivityID) then
        return
    end
    
    local IsGetAllReward = true
    local NodeList = {}
    local NeeDelRedDot = true
    local RedDotName = self:GetRedDotName(ActivityInfo.ActivityID)
    local FinishedNodeNum = 0
    for _, Node in ipairs(ActivityDetail.Nodes) do
        local NodeHead = Node.Head
        local NodeExtra = Node.Extra
        local NodeInfo = {
            NodeID = NodeHead.NodeID,   -- 节点ID
            Locked = NodeHead.Locked,  -- 是否已锁定
            Finished = NodeHead.Finished,  -- 是否已完成
            RewardStatus = NodeHead.RewardStatus, -- 奖励领取状态
            AwardTimes = NodeHead.AwardTimes, -- 领奖次数
            EmergencyShutDown = NodeHead.EmergencyShutDown, -- 是否紧急关闭 
            Progress = (NodeExtra and NodeExtra.Progress and NodeExtra.Progress.Value) or 0, -- 进度值
            FinishedNodeNum = 0,
        }
        local NodeDetail = DepartOfLightVMUtils.GetActivityNodeDetail(NodeInfo.NodeID)
        -- 排除第一个节点头
        if NodeDetail and NodeDetail.NodeSort ~= 0 then
            if IsGetAllReward then
                IsGetAllReward = NodeHead.Finished and NodeHead.RewardStatus == DepartOfLightDefine.ERewardStatus.RewardStatusDone
            end
            table.insert(NodeList, NodeInfo)

            -- 统计完成节点总数
            if NodeHead.Finished then
                FinishedNodeNum = FinishedNodeNum + 1
            end
            -- 添加红点
            if NodeInfo.RewardStatus == DepartOfLightDefine.ERewardStatus.RewardStatusWaitGet then
                _G.RedDotMgr:AddRedDotByName(RedDotName)
                NeeDelRedDot = false
            end
        end
    end

    -- 移除红点
    if NeeDelRedDot then
        local FindRedNode = _G.RedDotMgr:FindRedDotNodeByName(RedDotName)
        if FindRedNode then
            _G.RedDotMgr:DelRedDotByName(RedDotName)
        end
    end

    ActivityInfo.Nodes = NodeList
    ActivityInfo.IsGetAllReward = IsGetAllReward
    table.sort(ActivityInfo.Nodes, function(a, b) 
        if a.NodeID ~= b.NodeID then
            return a.NodeID < b.NodeID
        end
        return false
    end)

    -- 排序后设置最后一个值
    local LastNode = ActivityInfo.Nodes[#ActivityInfo.Nodes]
    if LastNode then
        LastNode.FinishedNodeNum = FinishedNodeNum
    end

    return ActivityInfo
end

---@type 获取节点头列表
function DepartOfLightMgr:GetActivityNodeHeadList(ActivityDetailList)
    if ActivityDetailList == nil then
        return
    end

    local ActivityNodeHeadList = {}
    for _, Data in ipairs(ActivityDetailList) do
        local TaskActivityHead = Data.Head
        local ActivityID = TaskActivityHead and TaskActivityHead.ActivityID or 0 -- 活动ID/玩法节点
        for _, Node in ipairs(Data.Nodes) do
            local NodeHead = Node.Head
            local NodeID = NodeHead and NodeHead.NodeID or 0
            local NodeDetail = DepartOfLightVMUtils.GetActivityNodeDetail(NodeID)
            if NodeDetail and NodeDetail.NodeSort == 0 then
                if ActivityID then
                    ActivityNodeHeadList[ActivityID] = NodeDetail
                end
            end
        end
    end

    return ActivityNodeHeadList
end

---@type 请求光之启程任务奖励
---@param number ActivityNodeID  任务ID
function DepartOfLightMgr:SendDepartureGetTaskRewardReq(ActivityNodeID)
    local MsgID = CS_CMD.CS_CMD_ACTIVITY_SYSTEM
	local SubMsgID = TASK_SUB_MSG_ID.Reward

	local MsgBody = {
        Cmd = SubMsgID,
		Reward = { NodeID = ActivityNodeID },
    }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 光之启程任务奖励
function DepartOfLightMgr:OnNetMsgNodeGetReward(MsgBody)
    if nil == MsgBody or nil == MsgBody.Reward then
		return
	end
	local Reward = MsgBody.Reward
    local Detail = Reward.Detail
    local RewardNodeID = nil
    local ActivityInfoList = DepartOfLightVM:GetActivityInfoList()
    if ActivityInfoList == nil then
        return
    end

    for _, ActivityInfo in ipairs(ActivityInfoList) do
        local TaskID = ActivityInfo.ActivityID
        local DetailHead = Detail.Head
        if TaskID == DetailHead.ActivityID then
            ActivityInfo.EmergencyShutDown = DetailHead and DetailHead.EmergencyShutDown
            ActivityInfo.Effected = DetailHead and DetailHead.Effected
            ActivityInfo.Hiden = DetailHead and DetailHead.Hiden
            for _, node in ipairs(Detail.Nodes) do
                local NewRewardTimes = node.Head and node.Head.AwardTimes or 0
                local Item, Index = table.find_item(ActivityInfo.Nodes, node.Head.NodeID, "NodeID")
                if Item ~= nil then
                    local OldRewardTimes = Item.AwardTimes or 0
                    -- 领奖次数不一致，则认为最新领取奖励节点
                    if NewRewardTimes ~= OldRewardTimes then
                        RewardNodeID = Item.NodeID
                        break
                    end
                end
            end
        end
    end

    --- 展示奖励道具(自己读表)
    if RewardNodeID ~= nil then
        -- 更新界面
        local CurActivityIndex = DepartOfLightVM:GetCurrActivityIndex()
        local ActivityList = DepartOfLightVM:GetActivityInfoList()
        local CurActivityInfo = nil
        if ActivityList and #ActivityList > 0 then
            CurActivityInfo = self:GetActivityInfoFromServer(Detail)
            ActivityList[CurActivityIndex] = CurActivityInfo
        end
        
        DepartOfLightVM:UpdateActivity(CurActivityInfo, CurActivityIndex)
        local function OnRewardPanelClosed()
            -- 当前玩法所有奖励已领取，则判断是否所有玩法的奖励都已领取，从而判断是否结束启程整个玩法
            if CurActivityInfo and CurActivityInfo.IsGetAllReward then
                self:CheckDepartureEnd()
            end
        end

        local Params = {}
        Params.ItemList = {}
        local NodeCfg = ActivityNodeCfg:FindCfgByKey(RewardNodeID)
        if NodeCfg ~= nil then
            for _, value in ipairs(NodeCfg.Rewards) do
                if value.ItemID ~= 0 then
                    table.insert(Params.ItemList, {ResID = value.ItemID, Num = value.Num})
                end
            end
        end
        Params.CloseCallback = OnRewardPanelClosed
        UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
    end
end

---@type 请求所有可以领取的任务奖励
function DepartOfLightMgr:SendGetAllTaskReward(NodeIDs)
    local MsgID = CS_CMD.CS_CMD_ACTIVITY_SYSTEM
	local SubMsgID = TASK_SUB_MSG_ID.MultiReward

	local MsgBody = {
        Cmd = SubMsgID,
		MultiReward = { NodeIDs = NodeIDs },
    }
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 所有任务奖励回包
-- function DepartOfLightMgr:OnNetMsgGetAllTaskReward(MsgBody)
--     if nil == MsgBody or nil == MsgBody.MultiReward then
-- 		return
-- 	end

--     local Details = MsgBody.MultiReward.Details

--     if table.is_nil_empty(Details) then
--         return
--     end

--     local Params = {}
--     Params.ItemList = {}

--     local ItemMap = {}
--     -- 解析领取的任务节点，把奖励放在里面
--     for _, v in ipairs(Details) do
--         for _, node in ipairs(v.Nodes) do
--             local NodeCfg = ActivityNodeCfg:FindCfgByKey(node.Head.NodeID)
--             if NodeCfg ~= nil and NodeCfg.NodeSort == 1 then
--                 for _, value in ipairs(NodeCfg.Rewards) do
--                     if value.ItemID ~= 0 then
--                         if table.contain(ItemMap, value.ItemID) then
--                             ItemMap[value.ItemID].Num = value.Num + value.Num
--                         else
--                             ItemMap[value.ItemID] = {}
--                             ItemMap[value.ItemID].ItemID = value.ItemID
--                             ItemMap[value.ItemID].Num = value.Num
--                         end 
--                     end
--                 end
--             end
--         end
--     end

--     for _, item in pairs(ItemMap) do
--         table.insert(Params.ItemList, {ResID = item.ItemID, Num = item.Num})    
--     end

--     UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
-- end

---@type 节点数据更新
function DepartOfLightMgr:OnNetTaskNodesChange(MsgBody)
    if MsgBody == nil then
        return
    end

    local NodesChange = MsgBody.NodesChange 

    if NodesChange == nil then
        return
    end

    local List = NodesChange.Nodes
    local ActivityInfoList = DepartOfLightVM:GetActivityInfoList()
    if List == nil or ActivityInfoList == nil then
        return
    end

    -- 更新任务节点数据
    for _, Value in ipairs(List) do
        local Head = Value.Head
        local NodeExtra = Value.Extra
        local ChangeNodeID = Head and Head.NodeID
        local ChangeNodeDetail = DepartOfLightVMUtils.GetActivityNodeDetail(ChangeNodeID)
        local ChangeActivityID = ChangeNodeDetail and ChangeNodeDetail.ActivityID
        if ChangeActivityID then
            local ChangeActivityInfo, Index = DepartOfLightVM:GetActivityInfoByActivityID(ChangeActivityID)
            local ActivityDescInfo = DepartOfLightVMUtils.GetActivityDescInfoByActivityID(ChangeActivityID)
            local GameID = ActivityDescInfo and ActivityDescInfo.GameID or 0
            if ChangeActivityInfo and ChangeActivityInfo.Nodes then
                local FinishedNodeNum = 0
                for _, NodeData in ipairs(ChangeActivityInfo.Nodes) do
                    if NodeData.NodeID == ChangeNodeID then
                        NodeData.Locked = Head.Locked  -- 是否已锁定
                        NodeData.Finished = Head.Finished -- 是否已完成
                        NodeData.RewardStatus = Head.RewardStatus -- 奖励领取状态
                        NodeData.EmergencyShutDown = Head.EmergencyShutDown -- 是否紧急关闭 
                        NodeData.Progress = (NodeExtra and NodeExtra.Progress and NodeExtra.Progress.Value) or 0 -- 进度值
                        -- 添加红点
                        if NodeData.RewardStatus == DepartOfLightDefine.ERewardStatus.RewardStatusWaitGet then
                            local RedDotName = self:GetRedDotName(ChangeActivityID)
                            _G.RedDotMgr:AddRedDotByName(RedDotName)
                        end
                    end
                    -- 统计完成节点总数
                    if NodeData.Finished then
                        FinishedNodeNum = FinishedNodeNum + 1
                    end
                end
                -- 排序后设置最后一个值
                local LastNode = ChangeActivityInfo.Nodes[#ChangeActivityInfo.Nodes]
                if LastNode then
                    LastNode.FinishedNodeNum = FinishedNodeNum
                end
                DepartOfLightVM:UpdateActivity(ChangeActivityInfo, Index)
                self:SendGetTaskProgressReq(GameID)
            end
        end
    end
end


---@type 请求统计总值
function DepartOfLightMgr:SendGetAllTaskProgressReq(GameIDs)
    local MsgID = CS_CMD.CS_CMD_LIGHT_JOURNEY
	local SubMsgID = DEPART_SUB_MSG_ID.CmdTotalValue
	local MsgBody = {
        Cmd = SubMsgID,
		TotalValue = { 
            GameIDs = {
                DEPART_GAME_ID.GameIDFate,
                DEPART_GAME_ID.GameIDCloset,
                DEPART_GAME_ID.GameIDGoldSauser,
                DEPART_GAME_ID.GameIDMakerNote,
                DEPART_GAME_ID.GameIDGatherNote,
                DEPART_GAME_ID.GameIDFisherNote,
                DEPART_GAME_ID.GameIDCombatProf,
            }
        },
    }
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 请求需要的统计总值
function DepartOfLightMgr:SendGetTaskProgressReq(GameID)
    if GameID == nil or GameID <= 0 then
        return
    end
    local MsgID = CS_CMD.CS_CMD_LIGHT_JOURNEY
	local SubMsgID = DEPART_SUB_MSG_ID.CmdTotalValue
	local MsgBody = {
        Cmd = SubMsgID,
		TotalValue = { 
            GameIDs = {}
        },
    }
    table.insert(MsgBody.TotalValue.GameIDs, GameID)
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 需要的统计总值回包
function DepartOfLightMgr:OnNetMsgAllTaskProgressRsp(MsgBody)
    if MsgBody == nil or MsgBody.TotalValue == nil then
        return
    end
    local TotalValueList = MsgBody.TotalValue.TotalValues
    if TotalValueList == nil then
        return
    end

    local StatisticMap = {}
    for _, TotalValue in ipairs(TotalValueList) do
        StatisticMap[TotalValue.GameID] = TotalValue.Value
    end
    DepartOfLightVM:UpdateAllStatisticInfo(StatisticMap) 
end

---@type 请求玩家玩法历史高光数据
function DepartOfLightMgr:SendGetAllPersonRecordReq()
    local MsgID = CS_CMD.CS_CMD_LIGHT_JOURNEY
	local SubMsgID = DEPART_SUB_MSG_ID.CmdPersonalityValue
	local MsgBody = {
        Cmd = SubMsgID,
    }
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 玩家玩法历史高光数据回包
function DepartOfLightMgr:OnNetMsgPersonRecordDataRsp(MsgBody)
    if MsgBody == nil then
        return
    end
    local PersonalityValueInfo = MsgBody.PersonalityValue
    if PersonalityValueInfo == nil then
        return
    end

    local JourneyValues = PersonalityValueInfo.JourneyValues
    local Info = {
        BeginTime = PersonalityValueInfo.BeginTime or 0, -- 开始统计的时间戳
        EndTime = PersonalityValueInfo.EndTime or 0, -- 所有子玩法都领取完奖励的时间戳  如果小于等于0，表示 光之启程还未结束
        JourneyValues = {}
    }

    if JourneyValues then
        for _, Value in ipairs(JourneyValues) do
            local JourneyValue = {
                GameID = Value.GameID, -- 玩法ID
                TotalProgress = Value.TotalValue, -- 总统计值
                FinishTime = Value.FinishTime, -- 该玩法完成时间戳 单位秒

                DayMaxProgress = Value.DayMaxValue, -- 单日最大统计值
                DayMaxValueTime = Value.DayMaxValueTime, -- 单日最大统计值 时间戳 单位秒
            }
            local ActivityDescInfo = DepartOfLightVMUtils.GetActivityDescInfoByGameID(JourneyValue.GameID)
            if ActivityDescInfo then
                JourneyValue.TotalPercent = JourneyValue.TotalProgress / ActivityDescInfo.MaxTarget
                JourneyValue.DayMaxPercent = JourneyValue.DayMaxProgress / ActivityDescInfo.MaxTarget
            end
            table.insert(Info.JourneyValues, JourneyValue)
        end
    end

    DepartOfLightVM:UpdateJourneyInfo(Info)

    local function UpdateRemainTime()
        local RemainTime = DepartOfLightVM:UpdateRemainTime()
        if RemainTime <= 0 then
            DepartOfLightVM:OnDepartureClosedForever()
            self:OnDepartureClosedForever()
        end
    end

    if DepartOfLightVM:IsDepartureReadyClosed() then
        self:RegisterTimer(UpdateRemainTime, 0, 1, -1)
    end

    if DepartOfLightVM:IsDepartureReadyClosed() or not DepartOfLightVM:IsDepartureClosedForever() then
        EventMgr:SendEvent(EventID.DepartEntranceUpdate)
    end
    
    -- 尝试打开回收界面且未永久关闭
    if self.TryOpenRecycleView and not DepartOfLightVM:IsDepartureClosedForever() then
        self.TryOpenRecycleView = false
        UIViewMgr:ShowView(UIViewID.DepartOfLightRecyclePanel)
        EventMgr:SendEvent(EventID.OnDepartRecycleViewVisibleChange, true)
    end
end

--endregion NetMsg


function DepartOfLightMgr:GetRedDotName(ActivityID, NodeID)
	if ActivityID ~= nil and  ActivityID > 0 then
		if string.isnilorempty(NodeID) then
			return DepartOfLightDefine.RedDotName .. '/' .. tostring(ActivityID)
		else
			return DepartOfLightDefine.RedDotName .. '/' .. tostring(ActivityID).. '/' .. tostring(NodeID)
		end
	end
	return DepartOfLightDefine.RedDotName
end

---@type 检查启程玩法是否结束 所有奖励是否已领取
function DepartOfLightMgr:CheckDepartureEnd()
	local ActivityList = DepartOfLightVM:GetActivityInfoList()
    if ActivityList == nil then
        return
    end
    local IsDepartureEnd = true
    for _, ActivityInfo in ipairs(ActivityList) do
        if not ActivityInfo.IsGetAllReward then
            IsDepartureEnd = false
            break
        end
    end

    if IsDepartureEnd then
        self:OnDepartureEnd()
    end 
end

---@type 启程玩法结束 所有奖励已领取
function DepartOfLightMgr:OnDepartureEnd()
    DepartOfLightVM:OnDepartureReadyClosed()
    self:ShowDepartRecycleView()
end

return DepartOfLightMgr