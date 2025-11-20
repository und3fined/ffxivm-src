local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local ActivityCfg = require("TableCfg/ActivityCfg")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local OpsReturnCfg = require("TableCfg/OpsReturnCfg")
local OpsReturnTagLogicCfg = require("TableCfg/OpsReturnTagLogicCfg")
local OpsReturnTagCfg = require("TableCfg/OpsReturnTagCfg")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local TimeUtil = require("Utils/TimeUtil")
local AchievementUtil = require("Game/Achievement/AchievementUtil")
local OpsReturnDefine = require("Game/Ops/View/OpsReturn/OpsReturnDefine")
local ProtoRes = require("Protocol/ProtoRes")
local SaveKey = require("Define/SaveKey")
local Json = require("Core/Json")
local GUIDE_TYPE = ProtoCommon.GUIDE_TYPE
local NodeOpType = ProtoCS.Game.Activity.NodeOpType
local SUB_MSG_ID = ProtoCS.Game.Activity.Cmd
local USaveMgr = _G.UE.USaveMgr
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local OpsActivityMgr
local ModuleOpenMgr
local GameNetworkMgr
local EventMgr

local CS_CMD = ProtoCS.CS_CMD
local TASK_SUB_MSG_ID = ProtoCS.Game.Activity.Cmd

---@class OpsReturnMgr : MgrBase
local OpsReturnMgr = LuaClass(MgrBase)

---OnInit
function OpsReturnMgr:OnInit()
end

function OpsReturnMgr:OnBegin()
    OpsActivityMgr = _G.OpsActivityMgr
    ModuleOpenMgr = _G.ModuleOpenMgr
    GameNetworkMgr = _G.GameNetworkMgr
    EventMgr = _G.EventMgr
    self.ActivityID = 25070301 --后续关闭
    self.ActivityNodeID = 2507030130  --节点数据
    self.Stage1NodeID = 2507030109 --  阶段1数据
    self.Stage2NodeID = 2507030110 --  阶段2数据
    self.Stage3NodeID = 2507030111 --  阶段3数据
    self.TagList = {}  -- 玩家的标签
    self.CurTag = 0 -- 玩家当前标签
    self.TaskIDList = {} --玩家的任务列表
    self.GuideType = GUIDE_TYPE.GUIDE_TYPE_NONE
    self.TaskStage = 1
    self.ActivityStartTime = 0 --活动开始时间, 每个人的时间都不一样
    self.StageDay = {0, 0, 0}
    self.StageRedDotTime = {0, 0, 0}   --记录阶段红点的进入时间。
    self.PageRedDotTime = {0, 0, 0}   --记录页签的红点进入时间
    self.StageTimer = nil
    self.CurSignNodeID = nil   -- 记录当前签到领奖的id
    self.CurStageTaskNodeID = nil   -- 记录当前阶段任务领奖的id
    self.LastLoginOutTime = 0 -- 记录回归前最后一次登录的时间
    self.ContentStartIndex = 1
    self.ContentEndIndex = 1
end

function OpsReturnMgr:OnEnd()
end

function OpsReturnMgr:OnShutdown()
end

function OpsReturnMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, SUB_MSG_ID.NodeOperate, self.OnNetMsgNodeOperate) -- 节点操作
end

function OpsReturnMgr:OnRegisterGameEvent()
    -- 活动更新
	self:RegisterGameEvent(EventID.OpsActivityUpdate, self.OnUpdateActivity)
    -- 活动信息更新
    self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.OnUpdateActivity)
    -- -- 活动节点推送
	-- self:RegisterGameEvent(EventID.OpsActivityNodeChanged, self.OnUpdateActivity)
    -- -- 活动领奖推送
    -- self:RegisterGameEvent(EventID.OpsActivityNodeGetReward, self.OnUpdateActivity)
    -- 登录查询 是否开启活动功能
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
end

function OpsReturnMgr:OnGameEventLoginRes(Params)
	if not ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDActivitySystem) then
        return
    end
end

function OpsReturnMgr:SetCurSignNodeID(NodeID)
    self.CurSignNodeID = NodeID
end

function OpsReturnMgr:GetCurSignNodeID()
    return self.CurSignNodeID
end

function OpsReturnMgr:SetCurStageTaskNodeID(NodeID)
    self.CurStageTaskNodeID = NodeID
end

function OpsReturnMgr:GetCurStageTaskNodeID()
    return self.CurStageTaskNodeID
end

-- 重置活动红点逻辑
function OpsReturnMgr:ResetActivtyRedDot()
    self.StageRedDotTime = {0, 0, 0}   --记录阶段红点的进入的时间。
    self.PageRedDotTime = {0, 0, 0}    --记录页签的红点进入时间
end

function OpsReturnMgr:GetActivityID()
    return self.ActivityID
end

function OpsReturnMgr:GetCurTag()
    return self.CurTag
end

-- 获取当前任务阶段
function OpsReturnMgr:GetTaskStage()
    return self.TaskStage
end

function OpsReturnMgr:SetTaskStage(TaskStage)
    self.TaskStage = TaskStage
end

-- 获取当前任务阶段的时间
function OpsReturnMgr:GetStageOpenTime(Stage)
    if self.ActivityStartTime == 0 then
        return 0
    end
    local Stage = Stage > 3 and 3 or Stage
    if Stage <= 0 then
        Stage = 1
    end
    local StartDate = os.date("*t", self.ActivityStartTime)
    StartDate.hour = 5
    StartDate.min = 0
    StartDate.sec = 0
    local BaseTime = os.time(StartDate)

    local Days = OpsReturnMgr:GetStageStartDays(Stage)
    return BaseTime + (Days - 1) * 86400
end

function OpsReturnMgr:GetActivityEndTime()
    if self.ActivityStartTime == 0 then
        return 0
    end
    local StartDate = os.date("*t", self.ActivityStartTime)
    StartDate.hour = 5
    StartDate.min = 0
    StartDate.sec = 0
    local BaseTime = os.time(StartDate)
    return BaseTime + 14 * 86400   
end

function OpsReturnMgr:OnUpdateActivity(Detail)
    if Detail and Detail.Head then
        -- Todo 有游戏开启时间之后，判断一下是否超过阶段3，如果超过阶段3 直接判断一次红点即可。未超过阶段3 开启定时器，进行阶段红点判断。
        self.ActivityStartTime = Detail.Head.CRTime
        -- local List = {self.Stage1NodeID, self.Stage2NodeID, self.Stage3NodeID}
        for i = 1, 3, 1 do
            self:SetStageStartDays(i, i)
        end
        local ServerTimeStamp = TimeUtil.GetServerLogicTime()
        local Stage3TimeStamp =  OpsReturnMgr:GetStageOpenTime(3)
        if Stage3TimeStamp == nil then
            return
        end
        for i = 1, 3, 1 do
           local Time = OpsReturnMgr:GetStageOpenTime(i)
           if ServerTimeStamp >= Time then
                self:SetTaskStage(i)
           end 
        end
        OpsReturnMgr:SetRedDot()
        if not (ServerTimeStamp >= Stage3TimeStamp) then
            if self.StageTimer ~= nil then
                self:UnRegisterTimer(self.StageTimer)
                self.StageTimer = nil
            end
            OpsReturnMgr:StartStageTimer()
        end
        return
    end

    --更新活动信息
    local NodeData = OpsActivityMgr:GetActivtyNodeInfo(self.ActivityID)
	if NodeData and NodeData.NodeList then
		local NodeList = NodeData.NodeList or {}
		for i = 1, #NodeList do
            if NodeList[i].Head then
			    if NodeList[i].Head.NodeID then
                    if NodeList[i].Head.NodeID == self.ActivityNodeID then
                        local Data = NodeList[i].Extra
                        if Data then
                            local BackFlowBaseInfo = Data.BackFlowBaseInfo
                            if BackFlowBaseInfo then
                                if BackFlowBaseInfo.Tag and BackFlowBaseInfo.TaskID then
                                    -- 活动第一次的时候 客户端计算一下标签。Todo 重置所有红点逻辑。
                                    if BackFlowBaseInfo.Tag == 0 or BackFlowBaseInfo.CurTag == 0 then
                                        self.TagList = OpsReturnMgr:CalcPlayerTag()
                                        self.CurTag = #self.TagList > 0 and self.TagList[1] or 1
                                        self.TaskIDList = {}
                                        self.LastLoginOutTime = BackFlowBaseInfo.LastLogout
                                        OpsReturnMgr:ResetActivtyRedDot()
                                        OpsReturnMgr:SaveLocalOpenTime()
                                        OpsReturnMgr:UpdateReturnData(self.TagList, self.CurTag, self.TaskIDList)
                                        return
                                    end
                                    OpsReturnMgr:CheckLocalOpenTime()
                                    self.TagList = OpsReturnMgr:ParseTagListByte(BackFlowBaseInfo.Tag)
                                    self.CurTag = BackFlowBaseInfo.CurTag or 1
                                    self.TaskIDList = BackFlowBaseInfo.TaskID or {}
                                    self.GuideType = BackFlowBaseInfo.GuideType or GUIDE_TYPE.GUIDE_TYPE_NONE
                                    self.LastLoginOutTime = BackFlowBaseInfo.LastLogout
                                    OpsActivityMgr:SendQueryActivity(self.ActivityID)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    EventMgr:SendEvent(EventID.UpdateOpsReturn)
end

-- 获取回归前的最后一次登录时间
function OpsReturnMgr:GetLastLastLoginOutTime()
    return self.LastLoginOutTime
end

function OpsReturnMgr:SetContentStartIndex(Index)
    self.ContentStartIndex = Index
end

function OpsReturnMgr:GetContentStartIndex()
    return  self.ContentStartIndex
end

function OpsReturnMgr:SetContentEndIndex(Index)
    self.ContentEndIndex = Index
end

function OpsReturnMgr:GetContentEndIndex()
    return  self.ContentEndIndex
end


function OpsReturnMgr:SetStageStartDays(Stage, Day)
    self.StageDay[Stage] = Day
end

function OpsReturnMgr:GetStageStartDays(Stage)
    return self.StageDay[Stage] or 1
end

function OpsReturnMgr:StartStageTimer()
    self.StageTimer = self:RegisterTimer(self.OnStageTimerCallback, 0, 1, -1)
end

function OpsReturnMgr:OnStageTimerCallback()
    local ServerTime = TimeUtil.GetServerLogicTime()
    local Stage3Time = OpsReturnMgr:GetStageOpenTime(3)
    if Stage3Time ~= nil then
         -- 阶段红点判断
        for i = 1, 3 do
            local Stage = OpsReturnMgr:GetStageOpenTimeStatus(i)
            if Stage then
                RedDotMgr:AddRedDotByID(OpsReturnDefine.RedDotID[i + 3])
            else
                RedDotMgr:DelRedDotByID(OpsReturnDefine.RedDotID[i + 3])
            end
        end
        if ServerTime > Stage3Time then
            self:UnRegisterTimer(self.StageTimer)
            self.StageTimer = nil
        end        
    end
end

function OpsReturnMgr:GetGuideType()
    return self.GuideType
end

function OpsReturnMgr:GetNextTagID()
    local AllTagList = OpsReturnTagCfg:FindAllCfg()
    table.sort(AllTagList, function(a, b)
        return a.Priority < b.Priority
    end)

    for i, v in ipairs(AllTagList) do
        if v.TagID == self.CurTag then
            local nextIndex = i % #AllTagList + 1
            return AllTagList[nextIndex].TagID
        end
    end

    return  (AllTagList[1] and AllTagList[1].TagID) and  AllTagList[1].TagID or 1
end

function OpsReturnMgr:GetTaskIDList()
    return self.TaskIDList
end

function OpsReturnMgr:GetTaskFinishedList()
    local TaskIDList = OpsReturnMgr:GetTaskIDList()
    local RetList = {0, 0, 0}

    --获取保存在服务器上的任务列表
    for stage, taskID in ipairs(TaskIDList) do
        local Data =  _G.OpsReturnMgr:GetNodeHeadData(taskID)
        if Data then
           if Data.RewardStatus ~= ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
                if RetList[stage] == 0 then
                    local Cfg = ActivityNodeCfg:FindCfgByKey(taskID)
                    if Cfg ~= nil then
                        local CfgStage = Cfg.NodeSort
                        if RetList[CfgStage] == 0 then
                            RetList[CfgStage] = taskID
                        end
                    end
                end
           end
        end
    end
    -- 每个阶段应该查一下
    for stage, taskID in ipairs(RetList) do
        if taskID == 0 then
            local CurTag = OpsReturnMgr:GetCurTag()
            local NewTaskID = OpsReturnMgr:GetStaskTaskByTag(CurTag, stage)
            local Data = OpsReturnMgr:GetNodeHeadData(NewTaskID)
            local NodeCfg = ActivityNodeCfg:FindCfgByKey(NewTaskID)
            if NodeCfg ~= nil then
                if Data ~= nil then
                    if Data ~= nil and NodeCfg.NodeSort == stage and Data.RewardStatus ~= ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
                        RetList[tonumber(NodeCfg.NodeSort)] = NewTaskID
                    end
                end
            end
        end
    end

    local TempRet = {}
    for _, taskID in ipairs(RetList) do
        if taskID ~= 0 then
            table.insert(TempRet, taskID)
        end
    end

    return TempRet
end

function OpsReturnMgr:GetNodeHeadData(NodeID)
    local NodeData = OpsActivityMgr:GetActivtyNodeInfo(self.ActivityID)
	if NodeData and NodeData.NodeList then
		local NodeList = NodeData.NodeList or {}
		for i = 1, #NodeList do
            if NodeList[i].Head then
			    if NodeList[i].Head.NodeID and NodeList[i].Head.NodeID == NodeID then
                    local Data = NodeList[i].Head
                    return Data
                end
            end
        end
    end
end

-- 更新
function OpsReturnMgr:UpdateReturnData(TagList, TagID, TaskIDList)
    local Num = 0
    for _, num in ipairs(TagList) do
        Num = Num | num
    end
    local Data = {
        Tag = Num,
        CurTag = TagID,
        TaskID = TaskIDList,
    }
    OpsActivityMgr:SendActivityNodeOperate(self.ActivityNodeID, NodeOpType.NodeOpTypeUpdateTagSuggestTask, {UpdateSuggestTagTaskReq = Data})
end

function OpsReturnMgr:DoTest()
    OpsReturnMgr:UpdateReturnData({1,2,4}, 1, {})
end

-- 节点操作更新
function OpsReturnMgr:OnNetMsgNodeOperate(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.NodeOperate then
		return
	end
	local NodeOperate = MsgBody.NodeOperate

    if NodeOperate.OpType == ProtoCS.Game.Activity.NodeOpType.NodeOpTypeUpdateTagSuggestTask then
        local Data = NodeOperate.ActivityDetail
        if Data ~= nil then
            local NodeList = Data.Nodes
            for i = 1, #NodeList do
                if NodeList[i].Head then
                    if NodeList[i].Head.NodeID and NodeList[i].Head.NodeID == self.ActivityNodeID then
                        local Extra = NodeList[i].Extra
                        if Extra then
                            local BackFlowBaseInfo = Extra.BackFlowBaseInfo
                            if BackFlowBaseInfo then
                                self.TagList = OpsReturnMgr:ParseTagListByte(BackFlowBaseInfo.Tag)
                                self.CurTag = BackFlowBaseInfo.CurTag or 1
                                self.TaskIDList = BackFlowBaseInfo.TaskID or {}
                                self.GuideType = BackFlowBaseInfo.GuideType or GUIDE_TYPE.GUIDE_TYPE_NONE
                                EventMgr:SendEvent(_G.EventID.UpdateOpsReturn)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

function  OpsReturnMgr:ParseTagListByte(TagNum)
    local TagIDList = {}
    local Power = 1  -- 初始幂值：2^0 = 1
    while TagNum > 0 do
        if TagNum % 2 == 1 then
            table.insert(TagIDList, Power)
        end
        TagNum = math.floor(TagNum / 2)
        Power = Power * 2
    end
    return TagIDList
end

function OpsReturnMgr:GetTagList()
    return self.TagList
end

function OpsReturnMgr:CalcPlayerTag()
    local TagList = {}
    -- 获取成就数据
    -- 获取成就数据，然后通过，成就分类进行标签判断。战斗标签的总成就点数>= N, 玩家对战总成就点数>= N , 制造生产标签下的 类别ID == （502 to 509） 的总成就点数 >= N
    -- 世界探索 总成就点数>= N ， 金蝶游乐场的 总成就点数 >= N
    -- 根据OpsReturnTagCfg的标签优先级进行排序，只要前3个
    local CfgList = OpsReturnTagLogicCfg:FindAllCfg()
    for _, cfg in ipairs(CfgList) do
        if cfg.AllStats == 1 then
            local AchievementList = AchievementUtil.GetAchievementDataByType(cfg.AchievementType)
            local List = AchievementUtil.GetAllFinishAchievementData(AchievementList)
            local TempSum = 0
            for _, v in ipairs(List) do
                TempSum =  TempSum + v.AchievePoint
                if TempSum >= cfg.ObjVal then
                    if not table.contain(TagList, cfg.Tag) then
                    table.insert(TagList, cfg.Tag)
                    break
                    end
                end
            end
        else
            local TempSum = 0
            for _, v in ipairs(cfg.Category) do
                local AchievementList = AchievementUtil.GetAchievementDataByType(cfg.AchievementType, v)
                local List = AchievementUtil.GetAllFinishAchievementData(AchievementList)
                for _, value in ipairs(List) do
                    TempSum =  TempSum + value.AchievePoint
                    if TempSum >= cfg.ObjVal then
                        if not table.contain(TagList, cfg.Tag) then
                        table.insert(TagList, cfg.Tag)
                        break
                        end
                    end
                end
            end
        end
    end

    table.sort(TagList, function(a, b)
        local Acfg = OpsReturnTagCfg:FindCfgByKey(a)
        local Bcfg = OpsReturnTagCfg:FindCfgByKey(b)

        if Acfg ~= nil and Bcfg ~= nil then
            local APriority = Acfg.Priority or 99
            local BPriority = Bcfg.Priority or 99
            return APriority < BPriority
        end

        return false
    end)

    if table.length(TagList) > 3 then
        return {TagList[1],TagList[2], TagList[3]}
    end

    if table.is_nil_empty(TagList) then
        local AllTagList = OpsReturnTagCfg:FindAllCfg()
        local MaxPriority = nil
        local TagID = 1
        for _, cfg in ipairs(AllTagList) do
            if MaxPriority == nil then
                MaxPriority = cfg.Priority
                TagID = cfg.TagID
            end
            if MaxPriority > cfg.Priority then
                MaxPriority = cfg.Priority
                TagID = cfg.TagID
            end
        end

        return {TagID}
    end

    return TagList
end

-- 通过玩家的标签List获取所有的内容
function OpsReturnMgr:GetContentsByPlayerTags(PlayerTags)
    local Result = {}
    local UsedIDs = {} -- 用于记录已经选中的内容ID，避免重复

    local AllTagList = OpsReturnTagCfg:FindAllCfg()
    -- 构建标签优先级映射表，便于快速查找
    local tagPriorityMap = {}
    for _, v in ipairs(AllTagList) do
        if v.Priority then
            tagPriorityMap[v.TagID] = v.Priority
        end
    end

    -- 先处理玩家标签的内容
    for _, tagID in ipairs(PlayerTags) do
        local TagContents = OpsReturnMgr:GetContentsByTag(tagID)
        for _, content in ipairs(TagContents) do
            if not UsedIDs[content.ID] then
                table.insert(Result, content)
                UsedIDs[content.ID] = true
            end
        end
    end

    -- 构建剩余标签列表并按优先级排序
    local remainingTags = {}
    for tagId, priority in pairs(tagPriorityMap) do
        if not table.contain(PlayerTags, tagId) then
            table.insert(remainingTags, {id = tagId, priority = priority})
        end
    end

    -- 按优先级升序排序
    table.sort(remainingTags, function(a, b)
        return a.priority < b.priority
    end)

    -- 按照优先级顺序获取剩余标签的内容
    for _, tagInfo in ipairs(remainingTags) do
        local tagContents = OpsReturnMgr:GetContentsByTag(tagInfo.id)
        for _, content in ipairs(tagContents) do
            if not UsedIDs[content.ID] then
                table.insert(Result, content)
                UsedIDs[content.ID] = true
            end
        end
    end
    return Result
end

-- 由于玩家内容不足6个 补充旧的内容进去
function OpsReturnMgr:GetSupplementContentsByPlayerTags(PlayerTags, List)
    local Result = {}
    local UsedIDs = {} -- 用于记录已经选中的内容ID，避免重复

    local AllTagList = OpsReturnTagCfg:FindAllCfg()
    -- 构建标签优先级映射表，便于快速查找
    local tagPriorityMap = {}
    for _, v in ipairs(AllTagList) do
        if v.Priority then
            tagPriorityMap[v.TagID] = v.Priority
        end
    end

    -- 先处理玩家标签的内容
    for _, tagID in ipairs(PlayerTags) do
        local TagContents = OpsReturnMgr:GetSupplementContentsByTag(tagID, List)
        for _, content in ipairs(TagContents) do
            if not UsedIDs[content.ID] then
                table.insert(Result, content)
                UsedIDs[content.ID] = true
            end
        end
    end

    return Result
end

function OpsReturnMgr:GetLoopContents(List, CurIndex)
    local TempResult = {}
    local MaxNum = 6
    local Len = #List
    if Len <= MaxNum then
        _G.FLOG_INFO("OpsReturnMgr:FilterContents Is Less ！！！")
        return List, CurIndex, #List
    end

    CurIndex = ((CurIndex - 1) % Len) + 1
    local StartPos = CurIndex
    local EndPos
    
    -- 从CurIndex开始取元素，直到取满6个或到达末尾
    for i = 0, MaxNum - 1 do
        local idx = (CurIndex + i - 1) % Len + 1
        table.insert(TempResult, List[idx])
        
        -- 记录结束位置
        if i == MaxNum - 1 then
            EndPos = idx
        end
    end
    
    return TempResult, StartPos, EndPos

    
end

-- 通过标签获取所有内容，并排序
function OpsReturnMgr:GetContentsByTag(TagID)
    local Result = {}
    local ServerTimeStamp = TimeUtil.GetServerLogicTime()    
    local CfgList = OpsReturnCfg:FindAllCfg(string.format("TagID = %d", TagID))
    for _, cfg in ipairs(CfgList) do
            if cfg.Version and _G.UE.UVersionMgr.IsBelowOrEqualGameVersion(cfg.Version) then
            -- if cfg.Version and true then
            -- 如果有限时的活动, 活动时间必须处于当前激活状态
            if cfg.ActivityID == 0 or cfg.ActivityID == nil then
                local Temp = table.deepcopy(cfg)
                local StartTime = OpsActivityMgr:GetTimeStampByTimeStr(cfg.StartTime)
                if StartTime >= self.LastLoginOutTime and ServerTimeStamp >= StartTime then
                    Temp.EndTime = 0
                    table.insert(Result, Temp)
                end
            else
                local Cfg1 = ActivityCfg:FindCfgByKey(cfg.ActivityID)
                if Cfg1 ~= nil then
                    local IsActive = cfg.LimitTime == 0
                    local Temp = table.deepcopy(cfg)
                    Temp.EndTime = 0
                    local StartTime = OpsActivityMgr:GetActivityStartTime(Cfg1) 
                    if StartTime >= self.LastLoginOutTime then
                        local EndTime = OpsActivityMgr:GetActivityEndTime(Cfg1)
                        IsActive = (ServerTimeStamp >= StartTime) and (ServerTimeStamp <= EndTime)
                        Temp.EndTime = EndTime or ""
                    end
                    if IsActive then
                        table.insert(Result, Temp)
                    end
                end
            end
        end
    end

    local CurrentTime = TimeUtil.GetServerLogicTime()

    table.sort(Result, function(a, b) 
        -- 第一优先级：配置优先级（降序）
        if a.Priority ~= b.Priority then
            return a.Priority < b.Priority
        else
            -- 第二优先级：当前有效的限时活动（新增规则）
            local aIsActive = false
            local bIsActive = false
            
            -- 只有限时活动才判断有效性
            if a.LimitTime == 1 then
                local aStartTime = 0
                if  a.StartTime ~= 0 and a.StartTime ~= "" then
                    aStartTime = OpsActivityMgr:GetTimeStampByTimeStr(a.StartTime)
                end
                local aEndTime = 0 
                if a.EndTime ~= 0 and a.EndTime ~= "" then
                    aEndTime = a.EndTime
                end
                aIsActive = (aEndTime > 0) and (CurrentTime >= aStartTime) and (CurrentTime <= aEndTime)
            end
            
            if b.LimitTime == 1 then
                local bStartTime = 0
                if b.StartTime ~= 0 and b.StartTime ~= ""  then
                    bStartTime = OpsActivityMgr:GetTimeStampByTimeStr(b.StartTime)
                end
                local bEndTime = 0
                if b.EndTime ~= 0 and b.EndTime ~= "" then
                    bEndTime = b.EndTime
                end
                bIsActive = (bEndTime > 0) and (CurrentTime >= bStartTime) and (CurrentTime <= bEndTime)
            end
            
            if aIsActive and not bIsActive then
                return true
            elseif not aIsActive and bIsActive then
                return false
            end
            
            -- 第三优先级：限时状态（限时活动优先）
            if a.LimitTime ~= b.LimitTime then
                return a.LimitTime > b.LimitTime
            else
                -- 第四优先级：开始时间（降序）
                local aStartTime = OpsActivityMgr:GetTimeStampByTimeStr(a.StartTime) or 0
                local bStartTime = OpsActivityMgr:GetTimeStampByTimeStr(b.StartTime) or 0
                return aStartTime > bStartTime
            end
        end
    end)

    for _, v in ipairs(Result) do
        if v.LimitTime == 1 then
            local aStartTime = 0
            if  v.StartTime ~= 0 and v.StartTime ~= "" then
                aStartTime = OpsActivityMgr:GetTimeStampByTimeStr(v.StartTime)
            end
            local aEndTime = 0 
            if v.EndTime ~= 0 and v.EndTime ~= "" then
                aEndTime = v.EndTime
            end
            local aIsActive = (aEndTime > 0) and (CurrentTime >= aStartTime) and (CurrentTime <= aEndTime) 
            _G.FLOG_INFO(string.format("OpsReturnMgr:GetContentsByTag Tag : %s, ID : %s  ContentPriority: %s Title : %s ,IsActive: (%s) StartTime : %s , StartTimeStamp : %s ", 
            tostring(v.TagID),  tostring(v.ID), tostring(v.Priority), tostring(v.Title), tostring(aIsActive), tostring(v.StartTime), tostring(OpsActivityMgr:GetTimeStampByTimeStr(v.StartTime))))
        else
            local IsMoreTime = ServerTimeStamp > OpsActivityMgr:GetTimeStampByTimeStr(v.StartTime)
            _G.FLOG_INFO(string.format("OpsReturnMgr:GetContentsByTag Tag : %s, ID : %s  ContentPriority: %s Title : %s , CurTime >= StartTime: (%s) StartTime : %s , StartTimeStamp : %s", 
            tostring(v.TagID),  tostring(v.ID), tostring(v.Priority), tostring(v.Title), tostring(IsMoreTime), tostring(v.StartTime), tostring(OpsActivityMgr:GetTimeStampByTimeStr(v.StartTime))))
        end
    end
    return Result

end

function OpsReturnMgr:GetSupplementContentsByTag(TagID, List)
    local Result = {}
    local ServerTimeStamp = TimeUtil.GetServerLogicTime()    
    local CfgList = OpsReturnCfg:FindAllCfg(string.format("TagID = %d", TagID))
    for _, cfg in ipairs(CfgList) do
            if  cfg.Version and _G.UE.UVersionMgr.IsBelowOrEqualGameVersion(cfg.Version) then
            -- 如果有限时的活动, 活动时间必须处于当前激活状态
            if not table.contain(List, cfg.ID) then
                if cfg.ActivityID == 0 or cfg.ActivityID == nil then
                    local Temp = table.deepcopy(cfg)
                    local StartTime = OpsActivityMgr:GetTimeStampByTimeStr(cfg.StartTime)
                    Temp.DistanceTime = ServerTimeStamp - StartTime
                     table.insert(Result, Temp)

                else
                    local Cfg1 = ActivityCfg:FindCfgByKey(cfg.ActivityID)
                    if Cfg1 ~= nil then
                        local IsActive = cfg.LimitTime == 0
                        local Temp = table.deepcopy(cfg)
                        Temp.EndTime = 0
                        local StartTime = OpsActivityMgr:GetActivityStartTime(Cfg1) 
                        local EndTime = OpsActivityMgr:GetActivityEndTime(Cfg1)
                        IsActive = (ServerTimeStamp >= StartTime) and (ServerTimeStamp <= EndTime)
                        Temp.EndTime = EndTime or 0
                        if true then
                            Temp.DistanceTime = ServerTimeStamp - StartTime
                            table.insert(Result, Temp)
                        end
                    end
                end
            end
        end
    end

    local CurrentTime = TimeUtil.GetServerLogicTime()

    table.sort(Result, function(a, b) 
        -- 第一优先级：配置优先级（升序）
        if a.Priority ~= b.Priority then
            return a.Priority < b.Priority
        else
            local aIsActive = false
            local bIsActive = false

            if a.DistanceTime ~= b.DistanceTime then
                return a.DistanceTime < b.DistanceTime
            end
            
            -- 只有限时活动才判断有效性
            if a.LimitTime == 1 then
                local aStartTime = 0
                if  a.StartTime ~= 0 and a.StartTime ~= "" then
                    aStartTime = OpsActivityMgr:GetTimeStampByTimeStr(a.StartTime)
                end
                local aEndTime = 0 
                if a.EndTime ~= 0 and a.EndTime ~= "" then
                    aEndTime = a.EndTime
                end
                aIsActive = (aEndTime > 0) and (CurrentTime >= aStartTime) and (CurrentTime <= aEndTime)
            end
            
            if b.LimitTime == 1 then
                local bStartTime = 0
                if b.StartTime ~= 0 and b.StartTime ~= ""  then
                    bStartTime = OpsActivityMgr:GetTimeStampByTimeStr(b.StartTime)
                end
                local bEndTime = 0
                if b.EndTime ~= 0 and b.EndTime ~= "" then
                    bEndTime = b.EndTime
                end
                bIsActive = (bEndTime > 0) and (CurrentTime >= bStartTime) and (CurrentTime <= bEndTime)
            end
            
            if aIsActive and not bIsActive then
                return true
            elseif not aIsActive and bIsActive then
                return false
            end
            
            -- 限时状态（限时活动优先）
            if a.LimitTime ~= b.LimitTime then
                return a.LimitTime > b.LimitTime
            else
                --开始时间（降序）
                local aStartTime = OpsActivityMgr:GetTimeStampByTimeStr(a.StartTime) or 0
                local bStartTime = OpsActivityMgr:GetTimeStampByTimeStr(b.StartTime) or 0
                return aStartTime > bStartTime
            end
        end
    end)

    for _, v in ipairs(Result) do
        if v.LimitTime == 1 then
            local aStartTime = 0
            if  v.StartTime ~= 0 and v.StartTime ~= "" then
                aStartTime = OpsActivityMgr:GetTimeStampByTimeStr(v.StartTime)
            end
            local aEndTime = 0 
            if v.EndTime ~= 0 and v.EndTime ~= "" then
                aEndTime = v.EndTime
            end
            local aIsActive = (aEndTime > 0) and (CurrentTime >= aStartTime) and (CurrentTime <= aEndTime) 
            _G.FLOG_INFO(string.format("OpsReturnMgr:GetSupplementContentsByTag Tag : %s, ID : %s  DistanceTime %s  ContentPriority: %s Title : %s ,IsActive: (%s) StartTime : %s , StartTimeStamp : %s ", 
            tostring(v.TagID),  tostring(v.ID), tostring(v.DistanceTime), tostring(v.Priority), tostring(v.Title), tostring(aIsActive), tostring(v.StartTime), tostring(OpsActivityMgr:GetTimeStampByTimeStr(v.StartTime))))
        else
            local IsMoreTime = ServerTimeStamp > OpsActivityMgr:GetTimeStampByTimeStr(v.StartTime)
            _G.FLOG_INFO(string.format("OpsReturnMgr:GetSupplementContentsByTag Tag : %s, ID : %s  DistanceTime %s ContentPriority: %s Title : %s , CurTime >= StartTime: (%s) StartTime : %s , StartTimeStamp : %s", 
            tostring(v.TagID),  tostring(v.ID), tostring(v.DistanceTime), tostring(v.Priority), tostring(v.Title), tostring(IsMoreTime), tostring(v.StartTime), tostring(OpsActivityMgr:GetTimeStampByTimeStr(v.StartTime))))
        end
    end

    for i = 1, #Result, 1 do
        if #List < 6 then
            List[#List + 1] = Result[i]
        end
    end

    return List
end

--请求任务奖励
---@param number ActivityNodeID  任务ID
function OpsReturnMgr:SendGetTaskRewardReq(ActivityNodeID)
    local MsgID = CS_CMD.CS_CMD_ACTIVITY_SYSTEM
	local SubMsgID = TASK_SUB_MSG_ID.Reward

	local MsgBody = {
        Cmd = SubMsgID,
		Reward = { NodeID = ActivityNodeID },
    }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

----- 红点逻辑
-- 如果活动开启的时候，打开3个页签红点
-- 如果每日签到可以领奖 打开任务红点
-- 如果阶段任务可领奖 打开任务红点
-- 如果阶段任务开启 打开任务红点
function OpsReturnMgr:SetRedDot()
    for index = 1, 2 do
        if self.PageRedDotTime[index] == 0 then
            RedDotMgr:AddRedDotByID(OpsReturnDefine.RedDotID[index])
        else
            RedDotMgr:DelRedDotByID(OpsReturnDefine.RedDotID[index])
        end
    end

    if self.PageRedDotTime[3] then
        if self.PageRedDotTime[3] == 0 then
            RedDotMgr:AddRedDotByID(OpsReturnDefine.RedDotID[4])
        else
            RedDotMgr:DelRedDotByID(OpsReturnDefine.RedDotID[4])
        end
    else
        RedDotMgr:DelRedDotByID(OpsReturnDefine.RedDotID[4])
    end

    local SignWeek = OpsReturnMgr:GetSignListRewardStatus()
    if SignWeek then
        RedDotMgr:AddRedDotByID(OpsReturnDefine.RedDotID[OpsReturnDefine.RedDotType.SignTask])
    else
        RedDotMgr:DelRedDotByID(OpsReturnDefine.RedDotID[OpsReturnDefine.RedDotType.SignTask])
    end

    for i = 1, 3 do
        local StageTimeStatus = OpsReturnMgr:GetStageOpenTimeStatus(i) 
        local StageTaskStatus =  OpsReturnMgr:GetStageTaskStatusByStageIndex(i)
        local RedDotID = OpsReturnMgr:GetStageTaskRedDotID(i)
        if StageTimeStatus or StageTaskStatus then
            RedDotMgr:AddRedDotByID(OpsReturnDefine.RedDotID[i + 3])
        else
            RedDotMgr:DelRedDotByID(OpsReturnDefine.RedDotID[i + 3])
        end

        if RedDotID ~= nil and StageTaskStatus then
            RedDotMgr:AddRedDotByID(RedDotID)
        else
            RedDotMgr:DelRedDotByID(RedDotID)
        end
    end
end


function OpsReturnMgr:GetStageTaskRedDotID(StageIndex)
    if type(StageIndex) ~= "number" then
        return nil
    end 

    if StageIndex == 1 then
        return OpsReturnDefine.RedDotID[OpsReturnDefine.RedDotType.StageTask1]
    elseif StageIndex == 2 then
        return OpsReturnDefine.RedDotID[OpsReturnDefine.RedDotType.StageTask2]
    elseif StageIndex == 3 then
        return OpsReturnDefine.RedDotID[OpsReturnDefine.RedDotType.StageTask3]
    end
end

-- 获取页签是否被打开过
function OpsReturnMgr:GetPageOpenTimeStatus()
    for _, pageID in ipairs(OpsReturnDefine.PageType) do
        if self.PageRedDotTime[pageID] == 0 then
            return true
        end
    end
    return false
end

-- 设置页签点击时间
function OpsReturnMgr:SetPageOpenTimeStatus(PageType, ServerTimeStamp)
    if self.PageRedDotTime[PageType] and self.PageRedDotTime[PageType] == 0 then
        self.PageRedDotTime[PageType] = ServerTimeStamp
        if PageType ~= 3 then
            RedDotMgr:DelRedDotByID(OpsReturnDefine.RedDotID[PageType])
        else
            RedDotMgr:DelRedDotByID(OpsReturnDefine.RedDotID[4])
        end
        OpsReturnMgr:SaveLocalOpenTime()
    end
end

-- 获取签到任务领取状态
function OpsReturnMgr:GetSignListRewardStatus()
    local NodeData = OpsActivityMgr:GetActivtyNodeInfo(_G.OpsReturnMgr:GetActivityID())
	if NodeData and NodeData.NodeList then
		local NodeList = NodeData.NodeList or {}
		for i = 1, #NodeList do
			if NodeList[i].Head and NodeList[i].Head.NodeID  then
				local CfgNode = ActivityNodeCfg:FindCfgByKey(NodeList[i].Head.NodeID)
				if CfgNode ~= nil then
					if CfgNode.NodeType == ProtoRes.Game.ActivityNodeType.ActivityNodeTypeAccumulativeLoginDay then
						if NodeList[i].Head.NodeID ~= OpsReturnDefine.ActivityNodeID[OpsReturnDefine.ActivityNodeType.MailNodeID] then
							local RewardsStatus = NodeList[i].Head.RewardStatus
                            if RewardsStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
                                return true
                            end
						end
					end
				end
			end
		end
	end

    return false
end

-- 获取当前阶段是否开启并判断是否有时间。
function OpsReturnMgr:GetStageOpenTimeStatus(StageIndex)
    local CurStage =  OpsReturnMgr:GetTaskStage()
    if CurStage >= StageIndex and self.StageRedDotTime[StageIndex] == 0 then
        return true
    end
    return false
end

-- 设置当前阶段点击时间
function OpsReturnMgr:SetStageOpenTimeStatus(StageIndex, ServerTimeStamp)
    local CurStage =  OpsReturnMgr:GetTaskStage()
    if CurStage >= StageIndex and self.StageRedDotTime[StageIndex] == 0 then
        self.StageRedDotTime[StageIndex] = ServerTimeStamp
        RedDotMgr:DelRedDotByID(OpsReturnDefine.RedDotID[StageIndex + 3])
        OpsReturnMgr:SaveLocalOpenTime()
    end
end

-- 检查本地打开时间
function OpsReturnMgr:CheckLocalOpenTime()
    local ReturningPageTimeStr = USaveMgr.GetString(SaveKey.ReturningPageTime, "", true)
    local ReturningStageTimeStr = USaveMgr.GetString(SaveKey.ReturningStageTime, "", true)

    if not string.isnilorempty(ReturningPageTimeStr) then
        self.PageRedDotTime = Json.decode(ReturningPageTimeStr) or {0, 0, 0}
    else
        self.PageRedDotTime  = {0, 0, 0}
    end

    if not string.isnilorempty(ReturningStageTimeStr) then
        self.StageRedDotTime = Json.decode(ReturningStageTimeStr) or {0, 0, 0}
    else
        self.StageRedDotTime = {0, 0, 0}
    end
end

-- 保存本地打开时间
function OpsReturnMgr:SaveLocalOpenTime()
    local ReturningPageTimeStr = Json.encode(self.PageRedDotTime or {0, 0, 0})
    local ReturningStageTimeStr = Json.encode(self.StageRedDotTime or {0, 0, 0})
    USaveMgr.SetString(SaveKey.ReturningPageTime, ReturningPageTimeStr, true)
    USaveMgr.SetString(SaveKey.ReturningStageTime, ReturningStageTimeStr, true)
end

-- 获取任务阶段是否可领奖状态
function OpsReturnMgr:GetStageTaskStatus()
    local CurStage = OpsReturnMgr:GetTaskStage()
    local ServerTaskID =  OpsReturnMgr:GetTaskIDList()
    local CurTag = OpsReturnMgr:GetCurTag()
    for i = 1, 3 do
        if CurStage >= i then
            if ServerTaskID[i] == nil then
                local TaskID = OpsReturnMgr:GetStaskTaskByTag(CurTag, i)
                local Data = _G.OpsReturnMgr:GetNodeHeadData(TaskID)
                if Data ~= nil and Data.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
                    return true
                end
            end
        end
    end

    return false
end

function OpsReturnMgr:GetStageTaskStatusByStageIndex(StageIndex)
    local CurStage = OpsReturnMgr:GetTaskStage()
    local ServerTaskID =  OpsReturnMgr:GetTaskIDList()
    local CurTag = OpsReturnMgr:GetCurTag()
    for i = 1, 3 do
        if CurStage >= i then
            if ServerTaskID[i] == nil then
                local TaskID = self:GetStaskTaskByTag(CurTag, StageIndex)
                local Data = self:GetNodeHeadData(TaskID)
                if Data ~= nil and Data.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
                    return true
                end
            end
        end
    end

    return false
end


-- 获取阶段任务
function OpsReturnMgr:GetStaskTaskByTag(Tag, StageIndex)
    local NodeID  = OpsReturnDefine.TagIDToNodeID[Tag]
    if NodeID == nil then
        _G.FLOG_INFO("OpsReturnMgr:GetTaskFinishedList NodeID == nil")
        return
    end

    local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)

    for index, taskID in ipairs(NodeCfg.Params or {}) do
        if index > 1 then
            local Cfg = ActivityNodeCfg:FindCfgByKey(taskID)
            if Cfg ~= nil and Cfg.NodeSort == StageIndex then
                return taskID
            end
        end
    end
    return 0
end

--要返回当前类
return OpsReturnMgr