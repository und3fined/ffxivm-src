---
---@Author: ZhengJanChuan
---@Date: 2024-07-08 15:48:15
---@Description: 新手教程管理类
---
--package.cpath = package.cpath .. ';C:/Users/skysong/AppData/Roaming/JetBrains/IntelliJIdea2023.3/plugins/EmmyLua/debugger/emmy/windows/x64/?.dll'
--local dbg = require('emmy_core')
--.tcpConnect('localhost', 9966)

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIViewID = require("Define/UIViewID")
local TutorialCfg = require("TableCfg/TutorialCfg")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local TutorialGroupCfg = require("TableCfg/TutorialGroupCfg")
local TutorialUtil = require("Game/Tutorial/TutorialUtil")
local MajorUtil = require("Utils/MajorUtil")
local SettingsUtils = require("Game/Settings/SettingsUtils")
local MainPanelVM = require("Game/Main/MainPanelVM")
local QuestMgr = require("Game/Quest/QuestMgr")
local SaveKey = require("Define/SaveKey")
local ProtoRes = require("Protocol/ProtoRes")
local Json = require("Core/Json")
local ObjectGCType = require("Define/ObjectGCType")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local SkillUtil = require("Utils/SkillUtil")
local LogMgr = require("Log/LogMgr")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local DataReportUtil = require("Utils/DataReportUtil")
local ProfMgr = require("Game/Profession/ProfMgr")
local DirectUpgradeGlobalCfg = require("TableCfg/DirectUpgradeGlobalCfg")
local ClientSetupMgr = require("Game/ClientSetup/ClientSetupMgr")
local TutorialCheckConfig = require("Game/Tutorial/TutorialCheckConfig")

local USaveMgr = _G.UE.USaveMgr

local CondFuncRelate = ProtoRes.CondFuncRelate
local TutorialStartHandleType = ProtoRes.TutorialStartHandleType

local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS
local QUEST_TYPE = ProtoRes.QUEST_TYPE
local CS_CMD = ProtoCS.CS_CMD
local CS_SUB_CMD = ProtoCS.CS_LIFE_SKILL_CMD

local UIViewMgr
local EventMgr
local EventID

local TutorialGroupType = {
    TutorialNewBie1 = 1,
    TutorialNewBie2 = 4,
}

---@class NewTutorialMgr : MgrBase
local NewTutorialMgr = LuaClass(MgrBase)

function NewTutorialMgr:OnInit()
    self.TutorialCfgTree = {}           ---数据
    self.TutorialState = true           --- 新手引导开关
    self.CurRunningGuideGroupID = nil   ---当前执行的引导ID
    self.CurRunningGuideSubGroupID = nil ---当前执行的子Group ID
    self.TutorialCurID = nil            ---当前播放ID
    self.TutorialForceCloseNum = 0      --- 新手引导强制关闭计数器，如果跳转到下一个界面，需重置为0
    self.LastMiniMapStatus = true       --- 记录播放新手引导前的主界面地图状态
    self.TutorialFirstPlay = true       --- 是否第一次进入游戏标志
    self.TutorialNewbeeReady = false
    self.TutorialSpecialData = {}
    self.TutorialSpecialData.ActorVelocityUpdate = 0
    self.TimerHdl = nil
    self.NetMsgStack = {}
    self.WaitNetMsgResp = false
    self.PausePlay = false
end

function NewTutorialMgr:OnBegin()
    UIViewMgr = _G.UIViewMgr
    EventMgr = _G.EventMgr
    EventID = _G.EventID

    --self.HandleFunctionMap = {
        --[TutorialStartHandleType.FirstPlay] = function ()
            --return (self.TutorialFirstPlay and self.TutorialNewbeeReady)
        --end,
        --[TutorialStartHandleType.StartMove] = function()
            --local Major = MajorUtil.GetMajor()
            --if Major then
              -- local Velocity = Major.CharacterMovement.Velocity
              -- return Velocity.X ~= 0 or Velocity.Y ~= 0
            --end
           -- return false
       -- end,
        --位于指定地图
        --[TutorialStartHandleType.InTargetMap] = function(TargetID)
            --local CurrentMapID = _G.PWorldMgr:GetCurrMapResID()
            --return CurrentMapID == TargetID
       -- end,
   -- }
end

function NewTutorialMgr:OnEnd()
    if self.TimerHdl then
        self:UnRegisterTimer(self.TimerHdl)
        self.TimerHdl = nil
    end

    self.PausePlay = false
end

function NewTutorialMgr:OnShutdown()
end

function NewTutorialMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_GATHER_START_CMD, self.OnEnterGaterState)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_DIRECT_UPGRADE, ProtoCS.Role.DirectUpgrade.Cmd.Upgrade, self.OnDirectUpgrade)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_DIRECT_UPGRADE, ProtoCS.Role.DirectUpgrade.Cmd.ReadyUpgrade, self.OnReadyUpgrade)
end

function NewTutorialMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)

    ---主界面重新ACTIVE
    self:RegisterGameEvent(EventID.TutorialMainPanelReActive, self.OnCheckUIMatchCondition)

    --- 监听LOADING结束更新界面事件
    self:RegisterGameEvent(EventID.TutorialLoadingFinish, self.OnLoadingFinishMainViewActive)

    --- 监听打开界面事件
    self:RegisterGameEvent(EventID.TutorialShowView, self.OnCheckUIMatchCondition)

    --- 监听打开界面事件
    self:RegisterGameEvent(EventID.TutorialHideView, self.OnCheckUIMatchEndCondition)

    --- 监听查询保存在服务器上的值。
    self:RegisterGameEvent(EventID.ClientSetupPost, self.ClientSetupPost)

    --- 监听游戏登录事件 
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)

    --- 监听定时器结束
    self:RegisterGameEvent(EventID.TutorialTimerEnd, self.OnTutorialTimerEnd)

    --- 监听结束事件(点击了对应引导按扭或者事件回调)
    self:RegisterGameEvent(EventID.TutorialEnd, self.OnCheckTutorialEndCondition)

    --- 监听任务事件
    self:RegisterGameEvent(EventID.UpdateQuest, self.CheckQuestUpdateEvent)

    ---转职
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnMajorProfSwitch)

    ---职业解锁
    self:RegisterGameEvent(EventID.MajorProfActivate, self.OnMajorProfActivate)

    ---技能解锁
    self:RegisterGameEvent(EventID.SkillUnlock, self.OnSkillUnlock)

    --耐久度低于40
    self:RegisterGameEvent(EventID.EnduredegChange, self.OnEnduredegChange)

    ---量谱解锁
    self:RegisterGameEvent(EventID.SpectrumsUnlock, self.OnSpectrumsUnlock)

    ---收藏品采集
    self:RegisterGameEvent(EventID.EnterGatherCollectionState, self.OnEnterGatherCollection)

    ---进入制作状态
    self:RegisterGameEvent(EventID.CrafterEnterRecipeState , self.OnEnterRecipeState)

    ---使用技能初次抛竿
    self:RegisterGameEvent(EventID.SkillBtnClick, self.OnFirstThrowRod)

    ---使用技能初次抛竿
    self:RegisterGameEvent(EventID.ForceCloseTutorial, self.ForceCloseTutorial)

    --- 监听移动
    self:RegisterGameEvent(EventID.ActorVelocityUpdate, self.OnActorVelocityUpdate)

    --- 监听职业随机事件
    self:RegisterGameEvent(EventID.MajorCrafterRandomEvent, self.OnDealCrafterRandomEvent)

    --按技能关疾疾跑引导
    self:RegisterGameEvent(EventID.SkillGenAttack, self.OnSkillGenAttack)

    --主界面隐藏则关闭正在播的新手引导
    self:RegisterGameEvent(EventID.TutorialMainPanelInActive, self.OnMainPanelInActive)

    --动画播完触发指引
    self:RegisterGameEvent(EventID.EndPlaySequence, self.OnEndPlaySequence)

    self:RegisterGameEvent(EventID.JumpAndEndSequence, self.OnEndPlaySequence)

    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventPWorldExit)

    --能工巧匠事件
    ---self:RegisterGameEvent(EventID.CrafterRandomEventSkill, self.OnRandomEventSkill)

    --进入区域
    ---self:RegisterGameEvent(EventID.AreaTriggerBeginOverlap, self.OnAreaTriggerBeginOverlap)
end

------------------------- 网络相关 ----------------------
function NewTutorialMgr:OnGameEventLoginRes(Params)
    local QueryParams = {}
    QueryParams.ULongParam1 = MajorUtil.GetMajorRoleID()

    local bReconnect = Params and Params.bReconnect

    if bReconnect then
        --重连不需要重新更新数据
        self:ReconnectTutorialSchedule()
    else
        -- EventMgr:SendEvent(EventID.ClientSetupQueryAll, QueryParams)
        ClientSetupMgr:SendQueryReq({TutorialDefine.TutorialStateKey})
        if table.length(self.TutorialCfgTree) == 0 then
            self:LoadTutorialCfg()
        end
    end
end

function NewTutorialMgr:ClientSetupPost(EventParams)
    local Params = EventParams

    if Params == nil then
        return
    end

    local Key = Params.IntParam1
	local Value = Params.StringParam1

    self:CheckTutorialState()

    ---新手引导进程数据
    if Key == TutorialDefine.TutorialNetSyncKey then
        self:ParseTutorialNetSyncData(Value)
    end

    if Key == TutorialDefine.TutorialStateKey then
        if Value == nil or Value == "" then
            self:CheckTutorialState()
        else
            self:ParseTutorialStateKey(Value)
        end
    end

    --新手引导储存数据
    if Key == ClientSetupID.TutorialSpecialData then
        self:ParseTutorialData(Value)
    end

    if self.WaitNetMsgResp then
        self.WaitNetMsgResp = false
    end

    if #self.NetMsgStack > 0 then
        _G.ClientSetupMgr:OnGameEventSet(self.NetMsgStack[1])
        self.WaitNetMsgResp = false
        --这里只需要发送最后一次加入队列的数据因为发送的数据都是全量的以最后一次为准
        self.NetMsgStack = {}
    end

    ---if Key == TutorialDefine.SoftTutorialKey then
        ---self:ParseTutorialSoft(Value)
    ---end

    ---if Key == TutorialDefine.ForceTutorialKey then
        ---self:ParseTutorialForce(Value)
    ---end

end

--- 检查是否保存过新手引导开关，如果没有读取设置界面中的新手引导开关默认属性。
function NewTutorialMgr:CheckTutorialState()
    local RoleID = MajorUtil:GetMajorRoleID()
    local TutorialStateValue = _G.ClientSetupMgr:GetSetupValue(RoleID, TutorialDefine.TutorialStateKey)
    --- 服务器上没有存该状态 直接就调用设置
    if TutorialStateValue == nil then
        local State = USaveMgr.GetInt(SaveKey.TutorialState, 1, true)
        self.TutorialState = State == TutorialDefine.TutorialSwitchType.On and true or false
        SettingsUtils.SettingsTabUnCategory:SetTutorialState(State, true)
    end
end

--- 解析新手引导开关
function NewTutorialMgr:ParseTutorialStateKey(Value)
    self.TutorialState = tonumber(Value) == TutorialDefine.TutorialSwitchType.On and true or false
    EventMgr:SendEvent(EventID.TutorialSwitch, {Value = tonumber(Value)})
end

--- 解析特殊数据
function NewTutorialMgr:ParseTutorialData(value)
    local TutorialSpecialData = Json.decode(value)

    if TutorialSpecialData == nil then
        return
    end

    self.TutorialSpecialData.ActorVelocityUpdate = TutorialSpecialData.ActorVelocityUpdate
end

function NewTutorialMgr:PrintTable(t, indent)
    indent = indent or 0
    local formatting = string.rep("  ", indent)
    for key, value in pairs(t) do
        if type(value) == "table" then
            FLOG_INFO(formatting .. tostring(key) .. ":")
            self:PrintTable(value, indent + 1)
        else
            FLOG_INFO(formatting .. tostring(key) .. ": " .. tostring(value))
        end
    end
end

--解析新手引导进程数据
function NewTutorialMgr:ParseTutorialNetSyncData(value)
    local TutorialList = Json.decode(value)
    local NeedReSave = false

    if self.TutorialCurID ~= nil then
        return
    end

    FLOG_INFO("ParseTutorialNetSyncData")
    --self:PrintTable(TutorialList)

    --如果这里没有被初始化则需要先初始化列表
    if table.length(self.TutorialCfgTree) == 0 then
        self:LoadTutorialCfg()
    end

    for groupID,SubGroupInfo in pairs(TutorialList) do
        for k,v in pairs(self.TutorialCfgTree) do
            if k == tonumber(groupID) then
                local TutorialBranch = v

                --整个大GROUP完成了
                if (SubGroupInfo["Finish"] ~= nil and SubGroupInfo["Finish"] == 0) or (SubGroupInfo["F"] ~= nil and SubGroupInfo["F"] == 0) then
                    TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Finish
                    --如果有新手指引则要播新手指引
                    if TutorialBranch["Content"].GuideID > 0 then
                        local Params = {}
                        Params.Type = TutorialDefine.TutorialConditionType.GuideComplete
                        Params.Param1 = TutorialBranch["Content"].GuideID
                        _G.TutorialGuideMgr:OnCheckTutorialStartCondition(Params)
                    end
                    break
                elseif (SubGroupInfo.FinishCondition ~= nil and SubGroupInfo.FinishCondition > 0) or (SubGroupInfo.FC ~= nil and SubGroupInfo.FC > 0) then
                    if SubGroupInfo.FC ~= nil then
                        TutorialBranch["FinishCondition"] = SubGroupInfo.FC
                    else
                        TutorialBranch["FinishCondition"] = SubGroupInfo.FinishCondition
                    end
                else
                    --只要有数据先把当前GROUP设成开始如果后面发现所有的子GROUP都完成了则就是完成了
                    TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running

                    for m,n in pairs(TutorialBranch["Leaf"]) do
                        for tutorialID,Progress in pairs(SubGroupInfo) do
                            --子组ID相同
                            if m == tonumber(tutorialID) then
                                --这晨已经完成了
                                if Progress == 0 then
                                    n["Status"] = TutorialDefine.TutorialNodeStatus.Finish
                                    n["Progress"] = 0
                                else
                                    n["Progress"] = Progress
                                    n["Status"] = TutorialDefine.TutorialNodeStatus.Running

                                    local CurrGroup = self:GetRunningSubGroup()

                                    --当前正在运行的组与后台发下来的数据的组相同则不做跳过或者重播操作
                                    if CurrGroup == nil or CurrGroup["Content"][1].GroupID ~= m then
                                        --这里要判断是否是跳过或者重新播
                                        --如果是跳过则直接完成整个或者则回到组开头并发后台保存结果
                                        if n["Content"][1].Offline == TutorialDefine.OfflineType.Skip then
                                            --不能跳过第一个结点都没有完成的组，这样的组说明才打开的，都没有播过
                                            if n["Progress"] ~= -n["Content"][1].TutorialID then
                                                n["Status"] = TutorialDefine.TutorialNodeStatus.Finish
                                                n["Progress"] = 0
                                                DataReportUtil.ReportTutorialData(tostring(n["Content"][1].GroupID),"0")
                                                NeedReSave = true
                                            end
                                        else
                                            if Progress ~= -n["Content"][1].TutorialID then
                                                n["Progress"] = -n["Content"][1].TutorialID
                                                NeedReSave = true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if self:CheckGroupAllFinish(TutorialBranch) then
                        TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Finish

                        --如果有新手指引则要播新手指引
                        if TutorialBranch["Content"].GuideID > 0 then
                            local Params = {}
                            Params.Type = TutorialDefine.TutorialConditionType.GuideComplete
                            Params.Param1 = TutorialBranch["Content"].GuideID
                            _G.TutorialGuideMgr:OnCheckTutorialStartCondition(Params)
                        end
                    end

                    break
                end
            end
        end
    end

    --这里要重新刷一下数据有可能之前因为跳过这个组已经完成了
    if NeedReSave then
        --保存数据到后台
        self:SendTutorialProgress()
    end
end

---变更保存进度
function NewTutorialMgr:SendTutorialProgress()

    local ParamContent = {}
    local Params = {}

    ---只保存那些已经开始和结束的
    for k,v in pairs(self.TutorialCfgTree) do
        if v["Status"] == TutorialDefine.TutorialNodeStatus.Running then
            ParamContent[tostring(k)] = {}
            for m,n in pairs(v["Leaf"]) do
                if n["Status"] == TutorialDefine.TutorialNodeStatus.Running then
                    ParamContent[tostring(k)][tostring(m)] = n["Progress"]
                elseif n["Status"] == TutorialDefine.TutorialNodeStatus.Finish then
                    ParamContent[tostring(k)][tostring(m)] = 0
                end
            end
        --如果大组完成了则直接记这个大组ID为0代表完成不用记它的小组进度了
        elseif v["Status"] == TutorialDefine.TutorialNodeStatus.Finish then
            ParamContent[tostring(k)] = {}
            ParamContent[tostring(k)]["F"] = 0
        elseif v["Status"] == TutorialDefine.TutorialNodeStatus.None then
            if v["FinishCondition"] ~= nil and v["FinishCondition"] > 0 then
                ParamContent[tostring(k)] = {}
                ParamContent[tostring(k)].FC= v["FinishCondition"]
            end
        end
    end

    --FLOG_WARNING("SendTutorialProgress")
    --self:PrintTable(ParamContent)
    --FLOG_WARNING(debug.traceback())

    Params.IntParam1 = TutorialDefine.TutorialNetSyncKey
    Params.StringParam1 = Json.encode(ParamContent)

    if not self.WaitNetMsgResp then
        _G.ClientSetupMgr:OnGameEventSet(Params)
        self.WaitNetMsgResp = true
    else
        table.insert(self.NetMsgStack,1,Params)
    end

    --_G.ClientSetupMgr:OnGameEventSet(Params)
end

--- 特殊数据服务器保存
function NewTutorialMgr:SendTutorialDataToServer()
    local Params = {}
    Params.IntParam1 = ClientSetupID.TutorialSpecialData
    Params.StringParam1 = Json.encode(self.TutorialSpecialData)
    _G.ClientSetupMgr:OnGameEventSet(Params)
end

--- 发送给服务器保存下来
function NewTutorialMgr:SendTutorialState()
    local Params = {}
    Params.IntParam1 = TutorialDefine.TutorialStateKey
    Params.StringParam1 = tostring( self.TutorialState and 1 or 2)
    _G.ClientSetupMgr:OnGameEventSet(Params)

    if not self.TutorialState then
        self:ForceCloseTutorial()
    end
end

---------------------------- 逻辑相关 -----------------------
function NewTutorialMgr:LoadTutorialCfg()

    FLOG_INFO("LoadTutorialCfg")
    self.TutorialCfgTree = {}
    local Cfgs = TutorialCfg:GetTutorialCfg()
    local GroupCfgs = TutorialGroupCfg:GetTutorialCfg()

    for _,GroupCfg in ipairs(GroupCfgs) do
        local TutorialBranch = {}
        TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.None ---默认都未开始等收到服务器数据再更新
        TutorialBranch["Content"] = GroupCfg
        TutorialBranch["FinishCondition"] = 0
        TutorialBranch["Leaf"] = {}

        --如果是默认打开，在建立TREE的时候就打开了
        if GroupCfg.Start[1].Condition == TutorialDefine.TutorialConditionType.DefaultGuide then
            TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
        end

        if GroupCfg.Start[1].Condition == TutorialDefine.TutorialConditionType.UnlockGameplay and
                GroupCfg.Start[2].Condition == TutorialDefine.TutorialConditionType.DefaultGuide then
            TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
        end

        local SubGroupIDs = GroupCfg.SubGroupID

        for _,GId in ipairs(SubGroupIDs) do
            TutorialBranch["Leaf"][GId] = {["Status"] = TutorialDefine.TutorialNodeStatus.None,["Content"] = {},["Progress"] = 0}
        end

        for _, Cfg in ipairs(Cfgs) do
            for k,v in pairs(TutorialBranch["Leaf"]) do
                if k == Cfg.GroupID then
                    table.insert(v["Content"],Cfg)
                end
            end
        end

        for k,v in pairs(TutorialBranch["Leaf"]) do
            table.sort(v["Content"],function(a,b)
                return a.TutorialID < b.TutorialID
            end)

            ---默认打开的则所有小组都打开进度为第一个结点后面收到服务器数据后再变更
            if TutorialBranch["Status"] == TutorialDefine.TutorialNodeStatus.Running then
                if table.length(v["Content"]) > 0 then
                    --如果有启动条件则不打开
                    if v["Content"][1].Start.Condition == 0 then
                        v["Status"] = TutorialDefine.TutorialNodeStatus.Running
                        v["Progress"] = -v["Content"][1].TutorialID
                    end
                end
            end
        end

        --检查一下是否有子组是空的
        local IsLegal = true
        for k,v in pairs(TutorialBranch["Leaf"]) do
            if table.length(v["Content"]) == 0 then
                IsLegal = false
                FLOG_ERROR("Empty SubGroup ID is %d",k)
            end
        end

        if IsLegal then
            self.TutorialCfgTree[GroupCfg.GuideGroupID] = TutorialBranch
        end
    end

    --清空做测试用
    --self:SendTutorialProgress()
end

function NewTutorialMgr:IsGroupComplete(GroupID)
    if self.TutorialCfgTree[GroupID] ~= nil then
        if self.TutorialCfgTree[GroupID]["Status"] == TutorialDefine.TutorialNodeStatus.Finish then
            return true
        end
    end

    return false
end

function NewTutorialMgr:GetRunningSubGroup()
    if self.CurRunningGuideSubGroupID ~= nil and self.CurRunningGuideGroupID ~= nil then
        if self.TutorialCfgTree[self.CurRunningGuideGroupID] ~= nil then
            return self.TutorialCfgTree[self.CurRunningGuideGroupID]["Leaf"][self.CurRunningGuideSubGroupID]
        end
    end

    return nil
end

function NewTutorialMgr:GetRunningCfg(TutorialID)
    if TutorialID == self.TutorialCurID then
        local Group = self:GetRunningSubGroup()

        if Group ~= nil then
            for _,Cfg in ipairs(Group["Content"]) do
                if Cfg.TutorialID == TutorialID then
                    return Cfg
                end
            end
        end
    end

    return nil
end

function NewTutorialMgr:SetTutorialReady()
    self.TutorialReady = true
end

function NewTutorialMgr:CheckQuestUpdateEvent(Params)
    if Params.UpdatedRspQuests ~= nil then
        local EventParams = _G.EventMgr:GetEventParams()

        for _,QuestInfo in pairs(Params.UpdatedRspQuests) do
            local QuestType = QuestMgr:GetQuestType(QuestInfo.QuestID)

            --不是主线并且接取任务
            if QuestType ~= QUEST_TYPE.QUEST_TYPE_MAIN and QuestInfo.Status == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS then
                EventParams.Type = TutorialDefine.TutorialConditionType.ExcludeMainQuestTaskStart --新手引导触发类型
                self:OnCheckTutorialStartCondition(EventParams)
                return
            end
        end

        EventParams.Type = TutorialDefine.TutorialConditionType.TutorialTaskStart --新手引导触发类型
        EventParams.Param1 = Params.UpdatedRspQuests
        self:OnCheckTutorialStartCondition(EventParams)
        --local Config = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = function(...) return self:OnCheckTutorialStartCondition(...) end, Params = EventParams}
        --_G.TipsQueueMgr:AddPendingShowTips(Config)
    end
end

--在播放时要判断下当前是否可播放新手引导
function NewTutorialMgr:CanPlayTutorial()
    --_G.LoadingMgr:IsLoadingView()
    if self.TutorialCurID ~= nil then
        return false
    end

    return true
end

--- 监听是否满足引导开始条件
function NewTutorialMgr:OnCheckTutorialStartCondition(Params)
    local Type = Params.Type
    local Param1 = Params.Param1 ~= nil and Params.Param1 or 0
    local Param2 = Params.Param2 ~= nil and Params.Param2 or 0

    ---如果直升状态中则不进行任何引导指南的触发
    if self.PausePlay then
        return
    end

    local GuidePlay = false

    if Type == TutorialDefine.TutorialConditionType.SpectrumsUnlock or
            Type == TutorialDefine.TutorialConditionType.ProfLevel or
            Type == TutorialDefine.TutorialConditionType.GamePlayCondition or
            Type == TutorialDefine.TutorialConditionType.SystemUnlock or
            Type == TutorialDefine.TutorialConditionType.UnlockGameplay then
        FLOG_INFO("CheckTutorialStartCondition Type = %d,Param1 = %d,Parma2 = %d",Type,Param1,Param2)
    end

    --新手指引触发，早先新手指引
    if _G.TutorialGuideMgr:OnCheckTutorialStartCondition(Params) then
        GuidePlay = true
    end

    --玩法节点只关心那些已经开了玩法的组中对应节点。触发时直接播放指引(因为那些组在玩法解锁时应该已经都打开了)
    local function CheckGameplayCondition(TutorialBranch)
        for k,v in pairs(TutorialBranch["Leaf"]) do
            if v["Status"] == TutorialDefine.TutorialNodeStatus.Running or v["Status"] == TutorialDefine.TutorialNodeStatus.None then
                if v["Content"][1].Start.Condition == TutorialDefine.TutorialConditionType.GamePlayCondition then
                    if v["Content"][1].Start.Param1 == Param1 and v["Content"][1].Start.Param2 == Param2 then
                        v["Progress"] = -v["Content"][1].TutorialID

                        if v["Status"] == TutorialDefine.TutorialNodeStatus.None then
                            v["Status"] = TutorialDefine.TutorialNodeStatus.Running
                            self:SendTutorialProgress()
                        end

                        self.CurRunningGuideGroupID = TutorialBranch["Content"].GuideGroupID
                        self.CurRunningGuideSubGroupID = v["Content"][1].GroupID
                        self:PlayTutorial(v["Content"][1])
                        return
                    end
                end
            end
        end
    end

    if Type == TutorialDefine.TutorialConditionType.GamePlayCondition then
        local Group = self:GetRunningSubGroup()

        --先判断当前运行到的节点满足条件
        if Group ~= nil then
            FLOG_INFO("The Running Group id is %d",self.CurRunningGuideSubGroupID)
            for _,Cfg in pairs(Group["Content"]) do
                if Cfg.TutorialID == math.abs(Group["Progress"]) then
                    if Cfg.Start.Condition == TutorialDefine.TutorialConditionType.GamePlayCondition then
                        if Cfg.Start.Param1 == Param1 and Cfg.Start.Param2 == Param2 then
                            self:PlayTutorial(Cfg)
                            return
                        end
                    end
                end
            end
        else
            for k,v in pairs(self.TutorialCfgTree) do
                --必须玩法相冭的而且是打开的
                if v["Status"] == TutorialDefine.TutorialNodeStatus.Running then
                    if v["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.UnlockGameplay then
                        CheckGameplayCondition(v)
                    end
                end
            end
        end

        return
    end

    --速度变化时
    if Type == TutorialDefine.TutorialConditionType.ActorVelocityUpdate then
        local Group = self:GetRunningSubGroup()

        if Group == nil then
            for k,v in pairs(self.TutorialCfgTree) do
                --必须打开的
                if v["Status"] == TutorialDefine.TutorialNodeStatus.Running then
                    for m,n in pairs(v["Leaf"]) do
                        if n["Content"][1].Start.Condition == TutorialDefine.TutorialConditionType.ActorVelocityUpdate then
                            n["Progress"] = -n["Content"][1].TutorialID
                            self.CurRunningGuideGroupID = v["Content"].GuideGroupID
                            self.CurRunningGuideSubGroupID = n["Content"][1].GroupID
                            self:PlayTutorial(n["Content"][1])
                            self.SpecialTutorialData.ActorVelocityUpdate = 1
                            self:SendTutorialDataToServer()
                            return
                        end
                    end
                end
            end
        end
    end

    local PlayTutorialGroup = nil
    local NeedSave = false

    local function CheckTaskCondition(TutorialBranch)
        if TutorialBranch["Content"].Relation == CondFuncRelate.AND then
            if TutorialBranch["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.TutorialTaskStart or
                    TutorialBranch["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.TutorialTaskEnd then
                for _,QuestInfo in pairs(Param1) do
                    --任务ID相同
                    if QuestInfo.QuestID == TutorialBranch["Content"].Start[1].Param1 and
                            ((TutorialBranch["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.TutorialTaskStart and
                                    QuestInfo.Status == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS) or (TutorialBranch["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.TutorialTaskEnd
                            and QuestInfo.Status == QUEST_STATUS.CS_QUEST_STATUS_FINISHED)) then
                        --条件1满足，条件2如果有并且已经满足了
                        if TutorialBranch["Content"].Start[2].Condition > 0 and TutorialBranch["FinishCondition"] == 2 then
                            TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                            for m,n in pairs(TutorialBranch["Leaf"]) do
                                if n["Content"][1].Start.Condition == 0 then
                                    n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                    n["Progress"] = -n["Content"][1].TutorialID
                                end
                            end
                            PlayTutorialGroup = TutorialBranch
                            NeedSave = true
                            --条件2并没有满足，则条件1满足了要记下来
                        elseif TutorialBranch["Content"].Start[2].Condition > 0 and TutorialBranch["FinishCondition"] == 0 then
                            TutorialBranch["FinishCondition"] = 1
                            NeedSave = true
                        else
                            TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                            for m,n in pairs(TutorialBranch["Leaf"]) do
                                if n["Content"][1].Start.Condition == 0 then
                                    n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                    n["Progress"] = -n["Content"][1].TutorialID
                                end
                            end
                            PlayTutorialGroup = TutorialBranch
                            NeedSave = true
                        end
                    end
                end
            elseif TutorialBranch["Content"].Start[2].Condition == TutorialDefine.TutorialConditionType.TutorialTaskStart or
                    TutorialBranch["Content"].Start[2].Condition == TutorialDefine.TutorialConditionType.TutorialTaskEnd then
                for _,QuestInfo in ipairs(Param1) do
                    --条件2满足，条件1已经满足了
                    if QuestInfo.Quest.QuestID == TutorialBranch["Content"].Start[2].Param1 and ((TutorialBranch["Content"].Start[2].Condition == TutorialDefine.TutorialConditionType.TutorialTaskStart and
                            QuestInfo.Status == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS) or (TutorialBranch["Content"].Start[2].Condition == TutorialDefine.TutorialConditionType.TutorialTaskEnd
                            and QuestInfo.Status == QUEST_STATUS.CS_QUEST_STATUS_FINISHED)) then
                        if TutorialBranch["FinishCondition"] == 1 then
                            TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                            for m,n in pairs(TutorialBranch["Leaf"]) do
                                if n["Content"][1].Start.Condition == 0 then
                                    n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                    n["Progress"] = -n["Content"][1].TutorialID
                                end
                                PlayTutorialGroup = TutorialBranch
                                NeedSave = true
                            end
                        else
                            TutorialBranch["FinishCondition"] = 2
                            NeedSave = true
                        end
                    end
                end
            end
        else
            if TutorialBranch["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.TutorialTaskStart or
                    TutorialBranch["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.TutorialTaskEnd or
                    TutorialBranch["Content"].Start[2].Condition == TutorialDefine.TutorialConditionType.TutorialTaskStart or
                    TutorialBranch["Content"].Start[2].Condition == TutorialDefine.TutorialConditionType.TutorialTaskEnd then
                local Match = false

                for _,QuestInfo in pairs(Param1) do
                    if QuestInfo.Status == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS and TutorialBranch["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.TutorialTaskStart then
                        if QuestInfo.QuestID == TutorialBranch["Content"].Start[1].Param1 then
                            Match = true
                            break
                        end
                    end

                    if QuestInfo.Status == QUEST_STATUS.CS_QUEST_STATUS_FINISHED and TutorialBranch["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.TutorialTaskEnd then
                        if QuestInfo.QuestID == TutorialBranch["Content"].Start[1].Param1 then
                            Match = true
                            break
                        end
                    end

                    if QuestInfo.Status == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS and TutorialBranch["Content"].Start[2].Condition == TutorialDefine.TutorialConditionType.TutorialTaskStart then
                        if QuestInfo.QuestID == TutorialBranch["Content"].Start[2].Param1 then
                            Match = true
                            break
                        end
                    end

                    if QuestInfo.Status == QUEST_STATUS.CS_QUEST_STATUS_FINISHED and TutorialBranch["Content"].Start[2].Condition == TutorialDefine.TutorialConditionType.TutorialTaskStart then
                        if QuestInfo.QuestID == TutorialBranch["Content"].Start[2].Param1 then
                            Match = true
                            break
                        end
                    end
                end

                if Match then
                    TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                    FLOG_INFO("%d",TutorialBranch["Content"].GuideID)
                    for m,n in pairs(TutorialBranch["Leaf"]) do
                        if n["Content"][1].Start.Condition == 0 then
                            n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                            n["Progress"] = -n["Content"][1].TutorialID
                        end
                    end

                    if PlayTutorialGroup == nil then
                        PlayTutorialGroup = TutorialBranch
                    end

                    NeedSave = true
                end
            end
        end
    end

    local function CheckUnlockSkillCondition(TutorialBranch)
        local Skilllist = {}
        for k,v in ipairs(Param1) do
            table.insert(Skilllist,v.SkillID)
        end

        if TutorialBranch["Content"].Relation == CondFuncRelate.AND then
            if TutorialBranch["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.SkillUnlock then
                for _,SkillID in ipairs(Skilllist) do
                    --任务ID相同
                    if TutorialBranch["Content"].Start[1].Param1 == SkillID then
                        --条件1满足，条件2如果有并且已经满足了
                        if TutorialBranch["Content"].Start[2].Condition > 0 and TutorialBranch["FinishCondition"] == 2 then
                            TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                            for m,n in pairs(TutorialBranch["Leaf"]) do
                                if n["Content"][1].Start.Condition == 0 then
                                    n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                    n["Progress"] = -n["Content"][1].TutorialID
                                end
                            end
                            PlayTutorialGroup = TutorialBranch
                            NeedSave = true
                            --条件2并没有满足，则条件1满足了要记下来
                        elseif TutorialBranch["Content"].Start[2].Condition > 0 and TutorialBranch["FinishCondition"] == 0 then
                            TutorialBranch["FinishCondition"] = 1
                        else
                            TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                            for m,n in pairs(TutorialBranch["Leaf"]) do
                                if n["Content"][1].Start.Condition == 0 then
                                    n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                    n["Progress"] = -n["Content"][1].TutorialID
                                end
                            end
                            PlayTutorialGroup = TutorialBranch
                            NeedSave = true
                        end
                    end
                end
            elseif TutorialBranch["Content"].Start[2].Condition == TutorialDefine.TutorialConditionType.SkillUnlock then
                for _,SkillID in ipairs(Skilllist) do
                    --条件2满足，条件1已经满足了
                    if TutorialBranch["Content"].Start[2].Param1 == SkillID then
                        if TutorialBranch["FinishCondition"] == 1 then
                            TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                            for m,n in pairs(TutorialBranch["Leaf"]) do
                                if n["Content"][1].Start.Condition == 0 then
                                    n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                    n["Progress"] = -n["Content"][1].TutorialID
                                end
                            end
                            PlayTutorialGroup = TutorialBranch
                            NeedSave = true
                        else
                            TutorialBranch["FinishCondition"] = 2
                            NeedSave = true
                        end
                    end
                end
            end
        else
            if TutorialBranch["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.UnlockSkill or TutorialBranch["Content"].Start[2].Condition == TutorialDefine.TutorialConditionType.UnlockSkill then
                for _,SkillID in ipairs(Skilllist) do
                    if  TutorialBranch["Content"].Start[1].Param1  == SkillID or TutorialBranch["Content"].Start[2].Param1 == SkillID then
                        TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                        for m,n in pairs(TutorialBranch["Leaf"]) do
                            n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                            n["Progress"] = -n["Content"][1].TutorialID
                        end
                        PlayTutorialGroup = TutorialBranch
                        NeedSave = true
                    end
                end
            end
        end
    end

    local function CheckProfClassCondition(TutorialBranch,ProfClass)
        if TutorialBranch["Content"].Relation == CondFuncRelate.AND then
            if TutorialBranch["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.ClassLevel then
                if  TutorialBranch["Content"].Start[1].Param1 == ProfClass and TutorialBranch["Content"].Start[1].Param2 == Param2 then
                    --条件1满足，条件2如果有并且已经满足了
                    if TutorialBranch["Content"].Start[2].Condition > 0 and TutorialBranch["FinishCondition"] == 2 then
                        TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                        for m,n in pairs(TutorialBranch["Leaf"]) do
                            if n["Content"][1].Start.Condition == 0 then
                                n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                n["Progress"] = -n["Content"][1].TutorialID
                            end
                        end
                        PlayTutorialGroup = TutorialBranch
                        NeedSave = true
                        --条件2并没有满足，则条件1满足了要记下来
                    elseif TutorialBranch["Content"].Start[2].Condition > 0 and TutorialBranch["FinishCondition"] == 0 then
                        TutorialBranch["FinishCondition"] = 1
                    else
                        TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                        for m,n in pairs(TutorialBranch["Leaf"]) do
                            if n["Content"][1].Start.Condition == 0 then
                                n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                n["Progress"] = -n["Content"][1].TutorialID
                            end
                        end
                        PlayTutorialGroup = TutorialBranch
                        NeedSave = true
                    end
                end
            elseif TutorialBranch["Content"].Start[2].Condition == TutorialDefine.TutorialConditionType.ClassLevel then
                --条件2满足，条件1已经满足了
                if TutorialBranch["Content"].Start[2].Param1 == ProfClass and TutorialBranch["Content"].Start[2].Param2 == Param2 then
                    if TutorialBranch["FinishCondition"] == 1 then
                        TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                        for m,n in pairs(TutorialBranch["Leaf"]) do
                            if n["Content"][1].Start.Condition == 0 then
                                n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                n["Progress"] = -n["Content"][1].TutorialID
                            end
                            PlayTutorialGroup = TutorialBranch
                            NeedSave = true
                        end
                    else
                        TutorialBranch["FinishCondition"] = 2
                        NeedSave = true
                    end
                end
            end
        else
            if TutorialBranch["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.ClassLevel or TutorialBranch["Content"].Start[2].Condition == TutorialDefine.TutorialConditionType.ClassLevel then
                if (TutorialBranch["Content"].Start[1].Param1 == ProfClass and TutorialBranch["Content"].Start[1].Param2 == Param2)
                        or (TutorialBranch["Content"].Start[2].Param1 == ProfClass and TutorialBranch["Content"].Start[2].Param2 == Param2) then
                    TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                    for m,n in pairs(TutorialBranch["Leaf"]) do
                        if n["Content"][1].Start.Condition == 0 then
                            n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                            n["Progress"] = -n["Content"][1].TutorialID
                        end
                    end
                    PlayTutorialGroup = TutorialBranch
                    NeedSave = true
                end
            end
        end
    end

    local function CheckProfLevelupCondition(TutorialBranch)
        if TutorialBranch["Content"].Relation == CondFuncRelate.AND then
            if TutorialBranch["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.ProfLevel then
                if  TutorialBranch["Content"].Start[1].Param1 == Param1 and TutorialBranch["Content"].Start[1].Param2 == Param2 then
                    --条件1满足，条件2如果有并且已经满足了
                    if TutorialBranch["Content"].Start[2].Condition > 0 and TutorialBranch["FinishCondition"] == 2 then
                        TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                        for m,n in pairs(TutorialBranch["Leaf"]) do
                            if n["Content"][1].Start.Condition == 0 then
                                n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                n["Progress"] = -n["Content"][1].TutorialID
                            end
                        end
                        PlayTutorialGroup = PlayTutorialGroup == nil and TutorialBranch or PlayTutorialGroup
                        NeedSave = true
                        --条件2并没有满足，则条件1满足了要记下来
                    elseif TutorialBranch["Content"].Start[2].Condition > 0 and TutorialBranch["FinishCondition"] == 0 then
                        TutorialBranch["FinishCondition"] = 1
                    else
                        TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                        for m,n in pairs(TutorialBranch["Leaf"]) do
                            if n["Content"][1].Start.Condition == 0 then
                                n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                n["Progress"] = -n["Content"][1].TutorialID
                            end
                        end
                        PlayTutorialGroup = PlayTutorialGroup == nil and TutorialBranch or PlayTutorialGroup
                        NeedSave = true
                    end
                end
            elseif TutorialBranch["Content"].Start[2].Condition == TutorialDefine.TutorialConditionType.ProfLevel then
                --条件2满足，条件1已经满足了
                if TutorialBranch["Content"].Start[2].Param1 == Param1 and TutorialBranch["Content"].Start[2].Param2 == Param2 then
                    if TutorialBranch["FinishCondition"] == 1 then
                        TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                        for m,n in pairs(TutorialBranch["Leaf"]) do
                            if n["Content"][1].Start.Condition == 0 then
                                n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                n["Progress"] = -n["Content"][1].TutorialID
                            end
                            PlayTutorialGroup = PlayTutorialGroup == nil and TutorialBranch or PlayTutorialGroup
                            NeedSave = true
                        end
                    else
                        TutorialBranch["FinishCondition"] = 2
                        NeedSave = true
                    end
                end
            end
        else
            if TutorialBranch["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.ProfLevel or TutorialBranch["Content"].Start[2].Condition == TutorialDefine.TutorialConditionType.ProfLevel then
                if (TutorialBranch["Content"].Start[1].Param1 == Param1 and TutorialBranch["Content"].Start[1].Param2 == Param2)
                        or (TutorialBranch["Content"].Start[2].Param1 == Param1 and TutorialBranch["Content"].Start[2].Param2 == Param2) then
                    TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                    for m,n in pairs(TutorialBranch["Leaf"]) do
                        if n["Content"][1].Start.Condition == 0 then
                            n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                            n["Progress"] = -n["Content"][1].TutorialID
                        end
                    end
                    PlayTutorialGroup = PlayTutorialGroup == nil and TutorialBranch or PlayTutorialGroup
                    NeedSave = true
                end
            end
        end
    end

    --坐骑野外特殊处理
    local function CheckRiderSystemCondition(TutorialBranch)
        local Group = self:GetRunningSubGroup()

        if Group == nil then
            if _G.ModuleOpenMgr:CheckOpenState(44) then
                if TutorialBranch["Status"] == TutorialDefine.TutorialNodeStatus.None then
                    TutorialBranch["Status"] = TutorialDefine.TutorialNodeStatus.Running
                    for m,n in pairs(TutorialBranch["Leaf"]) do
                        if n["Content"][1].Start.Condition == 0 then
                            n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                            n["Progress"] = -n["Content"][1].TutorialID
                        end
                        PlayTutorialGroup = TutorialBranch
                        NeedSave = true
                    end
                elseif TutorialBranch["Status"] == TutorialDefine.TutorialNodeStatus.Running then
                    --打开那些需要条件打开的子组
                    for m,n in pairs(TutorialBranch["Leaf"]) do
                        if n["Status"] == TutorialDefine.TutorialNodeStatus.None then
                            if n["Content"][1].Start.Condition == Type and n["Content"][1].Start.Param1 == Param1 and n["Content"][1].Start.Param2 == Param2 then
                                n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                n["Progress"] = -n["Content"][1].TutorialID
                                PlayTutorialGroup = TutorialBranch
                                NeedSave = true
                            end
                        end
                    end
                end
            end
        end
    end

    --触发打开相关GROUP
    for k,v in pairs(self.TutorialCfgTree) do
        if v["Status"] == TutorialDefine.TutorialNodeStatus.None then
            if Type == TutorialDefine.TutorialConditionType.TutorialTaskStart or Type == TutorialDefine.TutorialConditionType.TutorialTaskEnd then
                CheckTaskCondition(v)
            elseif Type == TutorialDefine.TutorialConditionType.SkillUnlock then
                CheckUnlockSkillCondition(v)
            elseif Type == TutorialDefine.TutorialConditionType.ProfLevel then
                local ProfClass = RoleInitCfg:FindProfClass(Param1)
                CheckProfClassCondition(v,ProfClass)
                CheckProfLevelupCondition(v)
            elseif Type ==  TutorialDefine.TutorialConditionType.RiderSystem then
                CheckRiderSystemCondition(v)
            else
                if v["Content"].Relation == CondFuncRelate.AND then
                    if v["Content"].Start[1].Condition == Type and Param1 == v["Content"].Start[1].Param1 and Param2 == v["Content"].Start[1].Param2 then
                        --条件1满足，条件2如果有并且已经满足了
                        if v["Content"].Start[2].Condition > 0 and v["FinishCondition"] == 2 then
                            v["Status"] = TutorialDefine.TutorialNodeStatus.Running
                            for m,n in pairs(v["Leaf"]) do
                                if n["Content"][1].Start.Condition == 0 then
                                    n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                    n["Progress"] = -n["Content"][1].TutorialID
                                end
                            end
                            PlayTutorialGroup = v
                            NeedSave = true
                            --条件2并没有满足，则条件1满足了要记下来
                        elseif v["Content"].Start[2].Condition > 0 and v["FinishCondition"] == 0 then
                            v["FinishCondition"] = 1
                            NeedSave = true
                        else
                            v["Status"] = TutorialDefine.TutorialNodeStatus.Running
                            for m,n in pairs(v["Leaf"]) do
                                if n["Content"][1].Start.Condition == 0 then
                                    n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                    n["Progress"] = -n["Content"][1].TutorialID
                                end
                            end
                            PlayTutorialGroup = v
                            NeedSave = true
                        end
                        --条件2满足，条件1已经满足了
                    elseif v["Content"].Start[2].Condition == Type and Param1 == v["Content"].Start[2].Param1 and Param2 == v["Content"].Start[2].Param2 then
                        if v["FinishCondition"] == 1 then
                            v["Status"] = TutorialDefine.TutorialNodeStatus.Running
                            for m,n in pairs(v["Leaf"]) do
                                if n["Content"][1].Start.Condition == 0 then
                                    n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                    n["Progress"] = -n["Content"][1].TutorialID
                                    NeedSave = true
                                end
                            end
                        else
                            v["FinishCondition"] = 2
                            NeedSave = true
                        end
                    end
                else
                    if (v["Content"].Start[1].Condition == Type and Param1 == v["Content"].Start[1].Param1 and Param2 == v["Content"].Start[1].Param2) or
                            (v["Content"].Start[2].Condition == Type and Param1 == v["Content"].Start[2].Param1 and Param2 == v["Content"].Start[2].Param2) then
                        v["Status"] = TutorialDefine.TutorialNodeStatus.Running
                        for m,n in pairs(v["Leaf"]) do
                            if n["Content"][1].Start.Condition == 0 then
                                n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                                n["Progress"] = -n["Content"][1].TutorialID
                            end
                        end
                        PlayTutorialGroup = v
                        NeedSave = true
                    end
                end
            end

        elseif v["Status"] == TutorialDefine.TutorialNodeStatus.Running then
        --打开那些需要条件打开的子组
            for m,n in pairs(v["Leaf"]) do
                if n["Status"] == TutorialDefine.TutorialNodeStatus.None then
                    if n["Content"][1].Start.Condition == Type and n["Content"][1].Start.Param1 == Param1 and n["Content"][1].Start.Param2 == Param2 then
                        n["Status"] = TutorialDefine.TutorialNodeStatus.Running
                        n["Progress"] = -n["Content"][1].TutorialID
                        PlayTutorialGroup = v
                        NeedSave = true
                    end
                end
            end
        end
    end

    if NeedSave then
        self:SendTutorialProgress()
    end

    --触发播放具体某个引导结点
    for k,v in pairs(self.TutorialCfgTree) do
        --判断当前运行组内的节点如果有运行条件并且条件满足则直接运行（比如在获得物品播宛动画后会触发某个指引）
        if self.CurRunningGuideSubGroupID ~= nil and self.CurRunningGuideGroupID ~= nil and GuidePlay == false then
            if v["Status"] == TutorialDefine.TutorialNodeStatus.Running then
                if self.CurRunningGuideGroupID == k then
                    for m,n in pairs(v["Leaf"]) do
                        if self.CurRunningGuideSubGroupID == m then
                            local Progress = math.abs(n["Progress"])
                            for _,Cfg in ipairs(n["Content"]) do
                                if Cfg.TutorialID == Progress then
                                    if Cfg.Start.Condition == Type and Param1 == Cfg.Start.Param1 and Param2 == Cfg.Start.Param2 then
                                        self:PlayTutorial(Cfg)
                                        return
                                    end
                                end
                            end
                        end
                    end
                end
            end
            --[[
        else
            --这里处理这种情况，前一个引导中节点的endnext为0，中间播了其它引导并结束了，然后又满足了之前那个引导的下一个节点条件，则接着播之前的引导看上去现在没有这个需求除了玩法节点，玩法节点单独处理了
            if PlayTutorialGroup == nil and self.CurRunningGuideSubGroupID == nil and self.CurRunningGuideGroupID == nil and GuidePlay == false then
                if v["Status"] == TutorialDefine.TutorialNodeStatus.Running then
                    if self.CurRunningGuideGroupID == k then
                        for m,n in pairs(v["Leaf"]) do
                            local Progress = math.abs(n["Progress"])
                            for _,Cfg in ipairs(n["Content"]) do
                                if Cfg.TutorialID == Progress then
                                    if Cfg.Start.Condition == Type and Param1 == Cfg.Start.Param1 and Param2 == Cfg.Start.Param2 then
                                        self:PlayTutorial(Cfg)
                                        return
                                    end
                                end
                            end
                        end
                    end
                end
            end--]]
        end
    end

    --上面主要处理像endnext为0的情况，如果上一个播放的组不是当前可播放的组，那么就按正常处理
    for k,v in pairs(self.TutorialCfgTree) do
        --如果没有任何可播的情况下，这里要判断下是否播之前可播的那个组
        if self:CanPlayTutorial() and PlayTutorialGroup ~= nil and GuidePlay == false and not _G.TutorialGuideMgr:IsViewShow() then
            for _,SubGroup in pairs(PlayTutorialGroup["Leaf"]) do
                --当前subgroup没有条件则直接播或者已经打开了
                if SubGroup["Content"][1].Start.Condition == 0 or SubGroup["Status"] == TutorialDefine.TutorialNodeStatus.Running then
                    local UIBPName = SubGroup["Content"][1].BPName
                    local ViewID = UIViewMgr:GetViewIDByName(UIBPName)
                    local View = UIViewMgr:FindVisibleView(ViewID)

                    --如果view不为空但是不显示也当他是空的
                    if View ~= nil then
                        local Visibility = View:GetVisibility()
                        if Visibility == _G.UE.ESlateVisibility.Collapsed or Visibility == _G.UE.ESlateVisibility.Hidden then
                            View = nil
                        end
                    end

                    if View ~= nil then
                        self.CurRunningGuideGroupID = PlayTutorialGroup["Content"].GuideGroupID
                        self.CurRunningGuideSubGroupID = _
                        self:PlayTutorial(SubGroup["Content"][1])
                        return
                    end
                end
            end
        end
    end
end

--- 监听界面关闭时
function NewTutorialMgr:OnCheckUIMatchEndCondition(ViewID)
    if ViewID == nil then
        return
    end

    if self.TutorialCurID ~= nil then
        local Cfg = self:GetRunningCfg(self.TutorialCurID)

        if Cfg ~= nil then
            if Cfg.Type == TutorialDefine.TutorialType.Soft or Cfg.Type == TutorialDefine.TutorialType.Tips or Cfg.Type == TutorialDefine.TutorialType.NoFuncSoft then
                local Group = self:GetRunningSubGroup()

                --判断当前闭的界面是不是新手引导作用的界面
                if Group ~= nil and Group.ViewID ~= nil and Group.ViewID == ViewID then
                    local GuideUIBPName = Cfg.GuideBPName
                    local GuideViewID = UIViewMgr:GetViewIDByName(GuideUIBPName)
                    self.TutorialCurID = nil
                    self.CurRunningGuideGroupID = nil
                    self.CurRunningGuideSubGroupID = nil
                    UIViewMgr:HideView(GuideViewID)
                end
            end
        end
    else
        UIViewMgr:HideView(UIViewID.TutorialGestureTips1Item)
    end
end

function NewTutorialMgr:OnLoadingFinishMainViewActive()
    self:OnCheckUIMatchCondition(UIViewID.MainPanel)
end

--- 监听是否满足引导开始条件
function NewTutorialMgr:OnCheckUIMatchCondition(ViewID)
    --指南播放时不会播引导
    if self.TutorialCurID ~= nil or _G.LoadingMgr:IsLoadingView() or _G.TutorialGuideMgr:IsViewShow() then
        return
    end

    local function CheckPlayTutorial(Group,k,m)
        --只能播那些没有参数的，有参数的说明要特殊触发
        if Group["Content"][1].Start.Condition == 0 then
            Group["Progress"] = -Group["Content"][1].TutorialID
            if self:CanPlayTutorial() and TutorialCheckConfig.IsPassTutorialCheck(Group["Content"][1]) then
                self.CurRunningGuideGroupID = k
                self.CurRunningGuideSubGroupID = m
                self:PlayTutorial(Group["Content"][1])
            end
            return true
        end

        return false
    end

    --界面打开后查询基本规则是：只判断那些已打开的组，如果组当前组第一个结点的BPName符合当前界面并且第一个节点属于需要全组完成才完成的结点则将当前播放结点ID变为第一个结点ID，并播放第一个结点
    --这里的意思其实就是当回到结点1界面并且需要重播。不然则判断当前播放到的结点的绑定BPName是否和打开界面一致，如果一致帖播放对应结点的动画
    if ViewID and ViewID > 0 then
        local ViewInfo = UIViewMgr:FindConfig(ViewID)

        if ViewInfo ~= nil then
            local BPName = ViewInfo.BPName
            local View = UIViewMgr:FindVisibleView(ViewID)

            --如果view不为空但是不显示也当他是空的
            if View ~= nil then
                local Visibility = View:GetVisibility()
                if Visibility == _G.UE.ESlateVisibility.Collapsed or Visibility == _G.UE.ESlateVisibility.Hidden then
                    View = nil
                end
            end

            --比对当前正在运行的组
            local RunningGroup = self:GetRunningSubGroup()
            if RunningGroup ~= nil then
                for k,v in pairs(RunningGroup["Content"]) do
                    if v.TutorialID == math.abs(RunningGroup["Progress"]) then
                        if v.BPName == BPName then
                            if View ~= nil then
                                if v.Type == TutorialDefine.TutorialType.Tips then
                                    if self:CanPlayTutorial() then
                                        self:PlayTutorial(v)
                                        return
                                    end
                                else
                                    local WidgetPath = v.WidgetPath
                                    local Widget = TutorialUtil:GetTutorialWidget(View, WidgetPath)

                                    --判断一下这个控件必须存在且是可见的不然不能运行
                                    if Widget ~= nil then
                                        local Visibility = Widget:GetVisibility()

                                        if Visibility ~= _G.UE.ESlateVisibility.Collapsed and Visibility ~= _G.UE.ESlateVisibility.Hidden then
                                            if self:CanPlayTutorial() then
                                                self:PlayTutorial(v)
                                            end
                                            return
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                return
            end


            for k,v in pairs(self.TutorialCfgTree) do
                --只判断那些已经触发的组
                if v["Status"] == TutorialDefine.TutorialNodeStatus.Running then
                    --这里对FATE触发的组要做特殊判断
                    if v["Content"].Start[1].Condition == TutorialDefine.TutorialConditionType.Fate then
                        if ViewID == UIViewID.FateArchiveMainPanel then
                            --确定FATE界面右边是有内容的
                            if _G.FateMgr:IsFateArchiveCurSelectActive() then
                                for m,n in pairs(v["Leaf"]) do
                                    CheckPlayTutorial(n,k,m)
                                    return
                                end
                            end
                        end
                    end

                    for m,n in pairs(v["Leaf"]) do
                        --这里只处理那些正在运行中的GROUP，对于没有开的GROUP和SUBGROUP不处理，GROUP和SUBGROUP由启动条件触发时触发
                        if n["Status"] == TutorialDefine.TutorialNodeStatus.Running then
                            --如果设置为没有结束则回到开始界面重播的
                            --全组完成才真的完成意味着只要当前界面和组第一个结点绑定界面相同则可以播
                            if n["Content"][1].FinishUntilPlayEnd == 1 then
                                if n["Content"][1].BPName == BPName then
                                    if View ~= nil then
                                        local WidgetPath = n["Content"][1].WidgetPath

                                        if WidgetPath ~= "" then
                                            local Widget = TutorialUtil:GetTutorialWidget(View, WidgetPath)
                                            --判断一下这个控件必须存在且是可见的不然不能运行
                                            if Widget ~= nil then
                                                local Visibility = Widget:GetVisibility()

                                                if Visibility ~= _G.UE.ESlateVisibility.Collapsed and Visibility ~= _G.UE.ESlateVisibility.Hidden then
                                                    if CheckPlayTutorial(n,k,m) then
                                                        return
                                                    end
                                                end
                                            end
                                        else
                                            if CheckPlayTutorial(n,k,m) then
                                                return
                                            end
                                        end
                                    end
                                end
                            end

                            --查找当前进度的Node是否在当前界面展示
                            local Progress = n["Progress"]

                            for _,Cfg in ipairs(n["Content"]) do
                                if Cfg.TutorialID == math.abs(Progress) then
                                    --FLOG_WARNING("Progress %d",Progress)
                                    --FLOG_WARNING(Cfg.BPName)
                                    --FLOG_WARNING(BPName)
                                    if Cfg.BPName == BPName then
                                        if View ~= nil then
                                            if Cfg.Type == TutorialDefine.TutorialType.Tips then
                                                if self:CanPlayTutorial() then
                                                    self.CurRunningGuideGroupID = k
                                                    self.CurRunningGuideSubGroupID = m
                                                    self:PlayTutorial(Cfg)
                                                end
                                            else
                                                local WidgetPath = Cfg.WidgetPath
                                                local Widget = TutorialUtil:GetTutorialWidget(View, WidgetPath)

                                                --判断一下这个控件必须存在且是可见的不然不能运行
                                                if Widget ~= nil then
                                                    local Visibility = Widget:GetVisibility()

                                                    if Visibility ~= _G.UE.ESlateVisibility.Collapsed and Visibility ~= _G.UE.ESlateVisibility.Hidden then
                                                        if self:CanPlayTutorial() then
                                                            self.CurRunningGuideGroupID = k
                                                            self.CurRunningGuideSubGroupID = m
                                                            self:PlayTutorial(Cfg)
                                                        end
                                                        return
                                                    else
                                                        break
                                                    end
                                                else
                                                    break
                                                end
                                            end
                                        else
                                            break
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

--- 监听是否触发引导结束条件
function NewTutorialMgr:OnCheckTutorialEndCondition(Params)
    local TutorialID = Params.TutorialID
    local Cfg = self:GetRunningCfg(TutorialID)

    if Cfg ~= nil then
        if Cfg.Type == TutorialDefine.TutorialType.Soft or Cfg.Type == TutorialDefine.TutorialType.Tips or Cfg.Type == TutorialDefine.TutorialType.NoFuncSoft then
            self:EndSoftTutorial(Cfg)
        else
            self:EndForceTutorial(Cfg)
        end
    end
end

--- 检查是否满足条件
function NewTutorialMgr:DoCheckCondition(Cfg, Value)
    local Relation = Cfg.Relation
    if Relation == CondFuncRelate.OR then
        if Cfg.Start ~= nil then
            for _, value in ipairs(Cfg.Start) do
                if value.Condition ~= 0 then
                    _G.FLOG_ERROR(string.format("NewTutorialMgr:DoCheckCondition "))
                    local Rlt = self:CheckSubCondition(value.Condition, value.Param, Value)
                    if Rlt then
                        return true
                    end
                end
            end
        end
    elseif Relation == CondFuncRelate.AND then
        local Rlt = false
        if Cfg.Start ~= nil then
            for _, value in ipairs(Cfg.Start) do
                if value.Condition ~= 0 then
                    Rlt = self:CheckSubCondition(value.Condition, value.Param)
                    if not Rlt then
                        return
                    end
                end
            end
            return true
        end
    end
end

--- 播放引导
function NewTutorialMgr:PlayTutorial(Cfg)
    if Cfg == nil then
        FLOG_INFO(string.format("NewTutorialMgr:PlayTutorial TutorialID is Nil "))
        return 
    end

    if not self.TutorialState then
        --直接完成当前引导
        local Group = self:GetRunningSubGroup()

        if Group ~= nil then
            Group["Status"] = TutorialDefine.TutorialNodeStatus.Finish
            Group["Progress"] = 0

            if self:CheckGroupAllFinish(self.TutorialCfgTree[self.CurRunningGuideGroupID]) then
                self.TutorialCfgTree[self.CurRunningGuideGroupID]["Status"] = TutorialDefine.TutorialNodeStatus.Finish
            end

            self.CurRunningGuideGroupID = nil
            self.CurRunningGuideSubGroupID = nil
            self.TutorialCurID = nil
            self:SendTutorialProgress()
        end
        --_G.FLOG_INFO("TutorialState Close")
        return
    end

    --FLOG_WARNING("PlayTutorial ID = %d",Cfg.TutorialID)

    ---如果是系统界面，则需要对其进行上下移动
    if Cfg.BPName == "Main2nd/Main2ndPanelNew_UIBP" then
        if Cfg.StartParam > 20 then
            local UIBPName = Cfg.BPName
            local ViewID = UIViewMgr:GetViewIDByName(UIBPName)
            local View = UIViewMgr:FindVisibleView(ViewID)

            if View ~= nil then
                View.TableView_Menu:SetScrollOffset(21)
            end
        end
    end

    --非野外不显示
    if Cfg.WidgetPath == "MiniMapPanel/BtnSkill" then
        if not _G.PWorldMgr:CurrIsInField() then
            self.CurRunningGuideGroupID = nil
            self.CurRunningGuideSubGroupID = nil
            self.TutorialCurID = nil
            return
        end
    end

    --金碟主界面只能在金碟地图解发
    if Cfg.WidgetPath == "MiniMapPanel/BtnGoldSauser" then
        if _G.PWorldMgr:GetCurrMapResID() ~= 12060 and _G.PWorldMgr:GetCurrMapResID() ~= 12061 then
            self.CurRunningGuideGroupID = nil
            self.CurRunningGuideSubGroupID = nil
            self.TutorialCurID = nil
            return
        end
    end

    --打开小地图
    if string.find(Cfg.WidgetPath, "MiniMapPanel")  then
        _G.MainPanelVM:SetMiniMapPanelVisible(true)
    elseif string.find(Cfg.WidgetPath, "ButtonSwitch") then
        _G.MainPanelVM:SetMiniMapPanelVisible(true)
        --还要显示这个按扭的界面
        EventMgr:SendEvent(EventID.SelectMainStageButtonSwitch)
    elseif string.find(Cfg.WidgetPath, "MainFunctionList") then
        _G.MainPanelVM:SetMiniMapPanelVisible(true)
        --还要显示这个按扭的界面
        EventMgr:SendEvent(EventID.SelectMainStageButtonSwitch)
    --打开轮盘
    elseif Cfg.WidgetPath == "ControlPanel/Sprint" then
        EventMgr:SendEvent(EventID.SwitchPeacePanel, 0)
    elseif Cfg.WidgetPath == "MainTeamPanel/MainQuestPanel/MainlineQuest/BtnQuest" or
            Cfg.WidgetPath == "MainTeamPanel/MainQuestPanel/MainlineQuest/TableViewAdapter/IconSpanCoordinate" then
        EventMgr:SendEvent(EventID.SelectMainTeamPanelQuest)
    end

    --侧边栏全部隐藏
    local Group = self:GetRunningSubGroup()

    if Group ~= nil then
        if Group["Content"][1].TutorialID == Cfg.TutorialID and Group["Content"][1].IsSystemUI == 1 then
            self:HideBorderView()
        end
    end

    if Cfg.Type == TutorialDefine.TutorialType.Soft or Cfg.Type == TutorialDefine.TutorialType.Tips or Cfg.Type == TutorialDefine.TutorialType.NoFuncSoft then
        self:PlaySoftTutorial(Cfg)
    elseif Cfg.Type == TutorialDefine.TutorialType.Force or Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
        self:PlayForceTutorial(Cfg)
    end
end

--- 播放软引导
function NewTutorialMgr:PlaySoftTutorial(Cfg)
    if nil == Cfg then
        _G.FLOG_ERROR(string.format("TutorialMgr:PlaySoftTutorial Cfg is nil"))
        return
    end

    self.TutorialCurID = Cfg.TutorialID

    FLOG_INFO("PlaySoftTutorial %d",self.TutorialCurID)

    local Group = self:GetRunningSubGroup()

    if Group ~= nil then
        Group["Progress"] = Cfg.TutorialID

        --最后一个结点是软引用并且已经看过了这里可以将组设置为完成了不然永远结束不了了
        if Cfg.TutorialID == Cfg.FinishedID and Cfg.IsShownNodeFinish == 1 then
            Group["Status"] = TutorialDefine.TutorialNodeStatus.Finish
            Group["Progress"] = 0

            DataReportUtil.ReportTutorialData(tostring(Cfg.GroupID),"1")

            if Group.ViewID and Group.ViewID > 0 then
                Group.ViewID = nil
            end

            --说明是Tips引导
            if Cfg.Type == TutorialDefine.TutorialType.Tips or Cfg.WidgetPath == "" then
                --判断是否都结束了
                if self.TutorialCfgTree[self.CurRunningGuideGroupID] ~= nil then
                    if self:CheckGroupAllFinish(self.TutorialCfgTree[self.CurRunningGuideGroupID]) then
                        self.TutorialCfgTree[self.CurRunningGuideGroupID]["Status"] = TutorialDefine.TutorialNodeStatus.Finish
                        self.CurRunningGuideGroupID = nil
                        self.CurRunningGuideSubGroupID = nil
                        self.TutorialCurID = nil
                    end
                end
            end

            self:SendTutorialProgress()
        end
    else
        FLOG_ERROR("Running Group is nil")
    end

    local UIBPName = Cfg.BPName
    local ViewID = UIViewMgr:GetViewIDByName(UIBPName)
    Group["ViewID"] = ViewID

    if self.TimerHdl ~= nil then
        self:UnRegisterTimer(self.TimerHdl)
        self.TimerHdl = nil
    end

    local RunningGuideGroupID = self.CurRunningGuideGroupID
    local RunningGuideSubGroupID = self.CurRunningGuideSubGroupID

    if self.TutorialCurID ~= nil or Cfg.Type == TutorialDefine.TutorialType.Tips then
        if Cfg.Type ~= TutorialDefine.TutorialType.Tips then
            UIViewMgr:ShowView(_G.UIViewID.TutorialGestureBG, {})
        end

        self.TimerHdl = self:RegisterTimer(function()
            local View = UIViewMgr:FindVisibleView(ViewID)
            UIViewMgr:HideView(_G.UIViewID.TutorialGestureBG, {})

            --如果当前的UI不存在则不能播应该出错了直接结束当前引导组并打印错误日志
            if View == nil then
                FLOG_ERROR("Play Current TutorialView is not Exist,BPName=%s",UIBPName)
                --直接结束当前引导组
                self:FinishCurrentRunningGroup()
                return
            end

            --中间被设成nil了
            if self.TutorialCurID == nil then
                if Cfg.Type ~= TutorialDefine.TutorialType.Tips then
                    self.TutorialCurID = Cfg.TutorialID
                    self.CurRunningGuideGroupID = RunningGuideGroupID
                    self.CurRunningGuideSubGroupID = RunningGuideSubGroupID
                end
            end

            --- 引导界面
            local GuideUIBPName = Cfg.GuideBPName
            local GuideViewID = UIViewMgr:GetViewIDByName(GuideUIBPName)

            --_G.TipsQueueMgr:Pause(true)

            if Cfg.Type == TutorialDefine.TutorialType.Tips then
                UIViewMgr:ShowView(GuideViewID, {Cfg = Cfg})
            else
                UIViewMgr:ShowView(GuideViewID, {TutorialID = Cfg.TutorialID})
            end

            self:UnRegisterTimer(self.TimerHdl)
        end,0.5 + Cfg.AnimTime,0,1)
    end
end

--- 创建引导层
function NewTutorialMgr:CreateGuideView(Cfg, ParentView, GuideUIBPName, GuideViewID)
    if GuideViewID ~= nil then
        local GuideView = UIViewMgr:CreateViewByName(GuideUIBPName, ObjectGCType.LRU, ParentView, true, true, {TutorialID = Cfg.TutorialID})
        local ParentView = self:GetGuideParentWidget(Cfg)
        ParentView:AddChild(GuideView)
        GuideView:SetGuidePanelSize(ParentView)
    end
end

--- 获取父节点 根据不同类型父节点不一样
function NewTutorialMgr:GetGuideParentWidget(Cfg)
    local UIBPName = Cfg.BPName
    local ViewID = UIViewMgr:GetViewIDByName(UIBPName)
    local View = UIViewMgr:FindVisibleView(ViewID)
    local WidgetPath = Cfg.WidgetPath
    local Widget = TutorialUtil:GetTutorialWidget(View, WidgetPath)
    --local EndParam =  TutorialCfg:GetTutorialEndParam(TutorialID)

   -- if HandleType == TutorialDefine.TutorialHandleType.Map then
        --local MapMarker, ParentView = TutorialUtil:GetMapItemAndParent(View, WidgetPath, tonumber(EndParam))
       -- return ParentView
   -- end

    local ParentView = Widget:GetParent()
    return ParentView
end

function NewTutorialMgr:OnTutorialTimerEnd(Params)
    FLOG_INFO("OnTutorialTimerEnd")
    local TutorialID = Params.TutorialID

    --_G.TipsQueueMgr:Pause(false)

    local Cfg = self:GetRunningCfg(TutorialID)

    if Cfg ~= nil then
        local Type =  Cfg.Type
        local AutoPlay = Cfg.AutoPlay
        local FinishedID = Cfg.FinishedID

        self.TutorialCurID = nil

        local GuideUIName = Cfg.GuideBPName
        local GuideUIViewID = UIViewMgr:GetViewIDByName(GuideUIName)

        UIViewMgr:HideView(GuideUIViewID)

        --不是AUTOPLAY结束整个引导段
        if AutoPlay ~= TutorialDefine.AutoPlayType.Auto then
            local Group = self:GetRunningSubGroup()

            if Group ~= nil then
                if Group["Status"] ~= TutorialDefine.TutorialNodeStatus.Finish then
                    Group["Status"] = TutorialDefine.TutorialNodeStatus.Finish
                    Group["Progress"] = 0

                    DataReportUtil.ReportTutorialData(tostring(Cfg.GroupID),"0")
                end

                if self:CheckGroupAllFinish(self.TutorialCfgTree[self.CurRunningGuideGroupID]) then
                    self.TutorialCfgTree[self.CurRunningGuideGroupID]["Status"] = TutorialDefine.TutorialNodeStatus.Finish
                end
            end

            self.CurRunningGuideSubGroupID = nil
            self.CurRunningGuideGroupID = nil
            self.TutorialCurID = nil
            self:SendTutorialProgress()
            ---MainPanelVM:SetMiniMapPanelVisible(self.LastMiniMapStatus)
            --MainPanelVM:SetTutorialVisible(true)
        else
            local Group = self:GetRunningSubGroup()
            local NextID = Cfg.NextID

            for k,v in pairs(Group["Content"]) do
                if v.TutorialID == NextID then
                    --直接下一条
                    self:PlayTutorial(v)
                    return
                end
            end
        end
    else
        if TutorialID ~= nil then
            LogMgr.Info(string.format("找不到对应的引导行 %d", TutorialID))
        end
    end
end

local function IsMoveCondition(Cfg)
    for i=1, #Cfg.Start do
        if Cfg.Start[i].Condition == TutorialStartHandleType.StartMove then
            return true
        end
    end
    return false
end

function NewTutorialMgr:OnActorVelocityUpdate(Params)
    if not self.TutorialSpecialData then
        return
    end
    if self.TutorialSpecialData.ActorVelocityUpdate == 0 then
        local Major = MajorUtil.GetMajor()

        if Major ~= nil then
            local Velocity = Major.CharacterMovement.Velocity
            if Velocity.X ~= 0 or Velocity.Y ~= 0 then
                --发送新手引导触发消息
                local EventParams = _G.EventMgr:GetEventParams()
                EventParams.Type = TutorialDefine.TutorialConditionType.ActorVelocityUpdate --新手引导触发类型
                ---_G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
            end
        end
    end
end

--进入收藏品采集状态
function NewTutorialMgr:OnEnterGatherCollection()
    --发送新手引导触发获得物品触发消息
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.Type = TutorialDefine.TutorialConditionType.CollectionGatheringStatus --新手引导触发类型
    _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
end

--进入采集状态
function NewTutorialMgr:OnEnterGaterState()

end

--直升开始
function NewTutorialMgr:OnReadyUpgrade()
    FLOG_INFO("OnReadyUpgrade")
    self.PausePlay = true
end

function NewTutorialMgr:ParseStringToArray(InString)
    local result = {}
    InString = InString:sub(2,-2)
    for word in string.gmatch(InString, '([^,]+)') do
        table.insert(result, word)
    end
    return result
end

--直升成功
function NewTutorialMgr:OnDirectUpgrade()
    ---完成相冭指南
    _G.TutorialGuideMgr:OnDirectUpgrade()

    local Cfg = DirectUpgradeGlobalCfg:GetDirectUpgradeCfg(ProtoRes.DIRECT_UPGRADE_ID.DIRECT_UPGRADE_ID_NEWBIEGUIDE)
    local JumpList = self:ParseStringToArray(Cfg._SkipIDList)

    for k,v in pairs(JumpList) do
        if self.TutorialCfgTree[tonumber(v)] ~= nil then
            local group = self.TutorialCfgTree[tonumber(v)]
            group["Status"] = TutorialDefine.TutorialNodeStatus.Finish
            group["Progress"] = 0
        end
    end

    self:SendTutorialProgress()
    self.PausePlay = false
end

--进入制作状态
function NewTutorialMgr:OnEnterRecipeState()
    local ProfID = MajorUtil.GetMajorProfID()

    --发送新手引导触发进入制作状态
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.Type = TutorialDefine.TutorialConditionType.ProductStatus --新手引导触发类型
    EventParams.Param1 = ProfID
    _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
end

--能工巧匠随机事件
function NewTutorialMgr:OnRandomEventSkill(Params)
    local EventType = Params
    local FristCrafterRandomEvent = TutorialDefine.TutorDataTypeEnum.FristCrafterRandomEvent
    if self.SpecialTutorialData and next(self.SpecialTutorialData) then
        local IsFristTable = self.SpecialTutorialData[FristCrafterRandomEvent]
        if IsFristTable and next(IsFristTable) then
            local IsFrist = IsFristTable[EventType]
            if not IsFrist or IsFrist == 0 then
                self.SpecialTutorialData[FristCrafterRandomEvent][EventType] = 1
                self:SendTutorialDataToServer()
                self:DoPlayTutorialCheck(TutorialStartHandleType.FirstEnterCraftStateProf, EventType)
            end
        else
            self.SpecialTutorialData[FristCrafterRandomEvent] = {}
            self.SpecialTutorialData[FristCrafterRandomEvent][EventType] = 1
            self:SendTutorialDataToServer()
            self:DoPlayTutorialCheck(TutorialStartHandleType.FirstEnterCraftStateProf, EventType)
        end
    else
        self.SpecialTutorialData[FristCrafterRandomEvent] = {}
        self.SpecialTutorialData[FristCrafterRandomEvent][EventType] = 1
        self:SendTutorialDataToServer()
        self:DoPlayTutorialCheck(TutorialStartHandleType.FirstEnterCraftStateProf, EventType)
    end
end

--技能解锁
function NewTutorialMgr:OnSkillUnlock(Params)
    local UnSkillList = Params.Value

    local function UnlockSkillFunc(Param)
        --这里是转成特定职业只传转后的职业ID
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.SkillUnlock --新手引导触发类型
        EventParams.Param1 = Param
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = UnlockSkillFunc, Params = UnSkillList}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end

--耐久度变动
function NewTutorialMgr:OnEnduredegChange(Params)
    local function EnduredegChangeFunc(Param)
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.BattleEquipDurabilityValue --新手引导触发类型
        EventParams.Param1 = Params
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = EnduredegChangeFunc}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end

--量谱解锁
function NewTutorialMgr:OnSpectrumsUnlock(SpectrumID)
    local function ShowSpectrumsUnlockFunc(Param)
        --这里是转成特定职业只传转后的职业ID
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.SpectrumsUnlock --新手引导触发类型
        EventParams.Param1 = SpectrumID
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowSpectrumsUnlockFunc, Params = {} }
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end

--转职成功
function NewTutorialMgr:OnMajorProfSwitch(Param)
    local ProfID = Param.ProfID
    local Type = RoleInitCfg:FindProfSpecialization(ProfID) --职业类型
    local ProfLevel = RoleInitCfg:FindProfLevel(ProfID) --当前职业(基职，特职)

    local function ProfChangeTutorial(Params)
        --发送新手引导触发获得物品触发消息
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.ProfChange --新手引导触发类型
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    -- 必须转职后，且转职的职业必须是全新解锁的战斗职业
    if Type == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT and
            ProfLevel == ProtoRes.prof_level.PROF_LEVEL_BASE then
        local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ProfChangeTutorial, Params = {}}
        _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
    end

    local function SpecialProfChangeTutorial(Params)
        --这里是转成特定职业只传转后的职业ID
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.SpecialProfChange --新手引导触发类型
        EventParams.Param1 = ProfID
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = SpecialProfChangeTutorial, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end


function NewTutorialMgr:OnMajorProfActivate(Params)
    local ProfID = Params.ActiveProf.ProfID
    local Type = RoleInitCfg:FindProfSpecialization(ProfID) --职业类型
    local ProfLevel = RoleInitCfg:FindProfLevel(ProfID) --当前职业(基职，特职)

    local function UnlockAdvanceProfTutorial(Params)
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.AdvanceProf
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end
    local HasNorMalProfNum = ProfMgr:MajorHasNorMalProfNum()

    -- 首次转职就行
    if HasNorMalProfNum == 2 then
        local TutorialConfig = {
            Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE,
            Callback = UnlockAdvanceProfTutorial,
            Params = {}
        }
        _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
    end
end


--使用技能(这里先只针对指南不触发引导)
function NewTutorialMgr:OnFirstThrowRod(Params)
    local SkillID = Params.SkillID

    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.Type = TutorialDefine.TutorialConditionType.UseSkill --新手引导触发类型
    EventParams.Param1 = SkillID
    _G.TutorialGuideMgr:OnCheckTutorialStartCondition(EventParams)
end

function NewTutorialMgr:OnAreaTriggerBeginOverlap(EventParam)
    self:DoPlayTutorialCheck(TutorialStartHandleType.TriggerArea, EventParam.AreaID)
end

--- 移除引导层
function NewTutorialMgr:RemoveGuideView(TutorialID)
    EventMgr:SendEvent(EventID.TutorialRemoveGuideView, {TutorialID = TutorialID})
end

--- 移除引导层
function NewTutorialMgr:HideBorderView()
    EventMgr:SendEvent(EventID.TutorialCloseBorderView)
end

--- 播放强制引导
function NewTutorialMgr:PlayForceTutorial(Cfg)
    if nil == Cfg then
         FLOG_INFO("TutorialMgr:PlayForceTutorial Cfg is nil")
        return
    end

    FLOG_INFO("PlayForceTutorial %d",Cfg.TutorialID)

    local UIBPName = Cfg.BPName
    local ViewID = UIViewMgr:GetViewIDByName(UIBPName)

    self.TutorialCurID = Cfg.TutorialID
    self.TutorialForceCloseNum = 0

    local GuideUIBPName = Cfg.GuideBPName
    local GuideViewID = UIViewMgr:GetViewIDByName(GuideUIBPName)

    if self.TimerHdl ~= nil then
        self:UnRegisterTimer(self.TimerHdl)
        self.TimerHdl = nil
    end

    local RunningGuideGroupID = self.CurRunningGuideGroupID
    local RunningGuideSubGroupID = self.CurRunningGuideSubGroupID

    if GuideViewID > 0 then
        --- 引导界面
        --MainPanelVM:SetMiniMapPanelVisible(true)
        --self:CreateGuideView(Cfg, View, GuideUIBPName, GuideViewID)

        UIViewMgr:ShowView(_G.UIViewID.TutorialGestureBG, {})

        self.TimerHdl = self:RegisterTimer(function()
            local View = UIViewMgr:FindVisibleView(ViewID)
            UIViewMgr:HideView(_G.UIViewID.TutorialGestureBG, {})

            --如果当前的UI不存在则不能播应该出错了直接结束当前引导组并打印错误日志
            if View == nil then
                FLOG_ERROR("Play Current TutorialView is not Exist,BPName=%s",UIBPName)
                --直接结束当前引导组
                self:FinishCurrentRunningGroup()
                return
            end

            --中间被设成nil了
            if self.TutorialCurID == nil then
                self.TutorialCurID = Cfg.TutorialID
                self.CurRunningGuideGroupID = RunningGuideGroupID
                self.CurRunningGuideSubGroupID = RunningGuideSubGroupID
            end

            if self.TutorialCurID ~= nil then
                --_G.TipsQueueMgr:Pause(true)
                UIViewMgr:ShowView(UIViewID.TutorialGestureMainPanel, {TutorialID = Cfg.TutorialID})
            end

            self:UnRegisterTimer(self.TimerHdl)
        end,0.5 + Cfg.AnimTime,0,1)
    end
end

function NewTutorialMgr:CheckGroupAllFinish(Group)
    local AllFinish = true

    for m,n in pairs(Group["Leaf"]) do
        if n["Status"] ~= TutorialDefine.TutorialNodeStatus.Finish then
            AllFinish = false
            break
        end
    end

    return AllFinish
end

--检查并判断设置整个大组结束，主要用于非正常关闭引导的逻辑数据(只针对最后一个组点节界面被关闭时，因为最后一个组节点显示时组已经完成了)
function NewTutorialMgr:CheckAndSetGroupFinish(SubGroup)
    if SubGroup["Progress"] ~= nil then
        if self.CurRunningGuideGroupID ~= nil and self.CurRunningGuideSubGroupID ~= nil and SubGroup["Progress"] == 0 then
            local v = self.TutorialCfgTree[self.CurRunningGuideGroupID]

            if self:CheckGroupAllFinish(v) then
                v["Status"] = TutorialDefine.TutorialNodeStatus.Finish

                --组结束时要保存到后台
                self:SendTutorialProgress()
            end
        end
    end
end

--- 结束软引导
function NewTutorialMgr:EndSoftTutorial(Cfg)
    local TutorialID = Cfg.TutorialID
    local FinishedID = Cfg.FinishedID
    local NextID = Cfg.NextID
    local GuideUIName = Cfg.GuideBPName
    local GuideUIViewID = UIViewMgr:GetViewIDByName(GuideUIName)

    --_G.TipsQueueMgr:Pause(false)

    self.TutorialCurID = nil
    UIViewMgr:HideView(GuideUIViewID)

    if self.TutorialCfgTree[self.CurRunningGuideGroupID] ~= nil then
        local v = self.TutorialCfgTree[self.CurRunningGuideGroupID]

        if v["Leaf"][self.CurRunningGuideSubGroupID] ~= nil then
            local n = v["Leaf"][self.CurRunningGuideSubGroupID]
            n["Progress"] = -NextID

            --一个组结束了不会直接播下个组
            if FinishedID == TutorialID then
                self.CurRunningGuideGroupID = nil
                self.CurRunningGuideSubGroupID = nil

                if n["Status"] ~= TutorialDefine.TutorialNodeStatus.Finish then
                    n["Status"] = TutorialDefine.TutorialNodeStatus.Finish
                    n["Progress"] = 0

                    DataReportUtil.ReportTutorialData(tostring(Cfg.GroupID),"1")
                else
                    n["Progress"] = 0
                end

                if self:CheckGroupAllFinish(v) then
                    v["Status"] = TutorialDefine.TutorialNodeStatus.Finish
                    --结束时需要将新手指引加入到指引中
                    if v["Content"].GuideID > 0 then
                        local Params = {}
                        Params.Type = TutorialDefine.TutorialConditionType.GuideComplete
                        Params.Param1 = v["Content"].GuideID
                        _G.TutorialGuideMgr:OnCheckTutorialStartCondition(Params)
                    end
                end
                --组结束时要保存到后台
                self:SendTutorialProgress()

                --结束时如果当时有指南就开始播指南
                if not _G.TutorialGuideMgr:IsPlayQueueEmpty() then
                    _G.TutorialGuideMgr:PlayNextGuide()
                end
            else
                --组结束时要保存到后台
                self:SendTutorialProgress()

                --结束时如果直接下一步就直接播放下一步
                if Cfg.EndNext == 1 then
                    for _,cfg in pairs(n["Content"]) do
                        if cfg.TutorialID == NextID then
                            self:PlayTutorial(cfg)
                            break
                        end
                    end
                end
            end
        end
    end
end

--- 结束强引导
function NewTutorialMgr:EndForceTutorial(Cfg)
    local TutorialID = Cfg.TutorialID
    local FinishedID = Cfg.FinishedID
    local GuideUIName = Cfg.GuideBPName
    local GuideUIViewID = UIViewMgr:GetViewIDByName(GuideUIName)
    local NextID = Cfg.NextID
    self.TutorialCurID = nil

    --_G.TipsQueueMgr:Pause(false)
    --self:RemoveGuideView(TutorialID)

    UIViewMgr:HideView(GuideUIViewID)

    for k,v in pairs(self.TutorialCfgTree) do
        if k == self.CurRunningGuideGroupID then
            for m,n in pairs(v["Leaf"]) do
                if m == self.CurRunningGuideSubGroupID then
                    n["Progress"] = -NextID

                    if FinishedID == TutorialID then
                        self.CurRunningGuideGroupID = nil
                        self.CurRunningGuideSubGroupID = nil

                        if n["Status"] ~= TutorialDefine.TutorialNodeStatus.Finish then
                            n["Status"] = TutorialDefine.TutorialNodeStatus.Finish
                            n["Progress"] = 0

                            DataReportUtil.ReportTutorialData(tostring(Cfg.GroupID), "1")
                        else
                            n["Progress"] = 0
                        end

                        if self:CheckGroupAllFinish(v) then
                            v["Status"] = TutorialDefine.TutorialNodeStatus.Finish

                            --结束时需要将新手指引加入到指引中
                            if v["Content"].GuideID > 0 then
                                local Params = {}
                                Params.Type = TutorialDefine.TutorialConditionType.GuideComplete
                                Params.Param1 = v["Content"].GuideID
                                _G.TutorialGuideMgr:OnCheckTutorialStartCondition(Params)
                            end
                        end
                        --组结束时要保存到后台
                        self:SendTutorialProgress()

                        --结束时如果当时有指南就开始播指南
                        if not _G.TutorialGuideMgr:IsPlayQueueEmpty() then
                            _G.TutorialGuideMgr:PlayNextGuide()
                        end
                    else
                        --组改变的时候保存
                        self:SendTutorialProgress()

                        --结束时如果直接下一步就直接播放下一步
                        if Cfg.EndNext == 1 then
                            for _,cfg in pairs(n["Content"]) do
                                if cfg.TutorialID == NextID then
                                    self:PlayTutorial(cfg)
                                    break
                                end
                            end
                        end
                    end

                    break
                end
            end
            break
        end
    end
end

function NewTutorialMgr:FinishCurrentRunningGroup()
    local TutorialID = self.TutorialCurID
    local Cfg = nil
    if TutorialID ~= nil then
        Cfg = self:GetRunningCfg(TutorialID)

        if Cfg ~= nil then
            local GuideUIBPName = Cfg.GuideBPName
            local GuideViewID = UIViewMgr:GetViewIDByName(GuideUIBPName)
            UIViewMgr:HideView(GuideViewID)
        end
    end

    if self.CurRunningGuideGroupID ~= nil and self.CurRunningGuideSubGroupID ~= nil then
        for k,v in pairs(self.TutorialCfgTree) do
            if k == self.CurRunningGuideGroupID then
                for m,n in pairs(v["Leaf"]) do
                    if m == self.CurRunningGuideSubGroupID then
                        self.CurRunningGuideSubGroupID = nil
                        n["Status"] = TutorialDefine.TutorialNodeStatus.Finish
                        n["Progress"] = 0

                        if Cfg then
                            DataReportUtil.ReportTutorialData(tostring(Cfg.GroupID), "0")
                        end

                        if self:CheckGroupAllFinish(v) then
                            v["Status"] = TutorialDefine.TutorialNodeStatus.Finish
                            self.CurRunningGuideGroupID = nil
                            --结束时需要将新手指引加入到指引中
                            if v["Content"].GuideID > 0 then
                                local Params = {}
                                Params.Type = TutorialDefine.TutorialConditionType.GuideComplete
                                Params.Param1 = v["Content"].GuideID
                                _G.TutorialGuideMgr:OnCheckTutorialStartCondition(Params)
                            end
                        end

                        self.CurRunningGuideGroupID = nil
                        self.TutorialCurID = nil
                        self:SendTutorialProgress()
                        break
                    end
                end
                break
            end
        end
    end
end

---强制跳过当前强引导
function NewTutorialMgr:ForceCloseTutorial()
    self.TutorialForceCloseNum = self.TutorialForceCloseNum + 1
    if self.TutorialForceCloseNum >= TutorialDefine.SkipTutorialClickNum then
        self:FinishCurrentRunningGroup();
        self.TutorialForceCloseNum = 0
    end
end

--- 掉线重连 重现回到该引导的第一步
function NewTutorialMgr:ReconnectTutorialSchedule()
    --- local TutorialLocalStep = USaveMgr.GetInt(SaveKey.TutorialLocalStep, 0, false)
    if self.CurRunningGuideGroupID ~= nil then
        if self.TutorialCfgTree[self.CurRunningGuideGroupID] ~= nil and
                self.TutorialCfgTree[self.CurRunningGuideGroupID]["Status"] == TutorialDefine.TutorialNodeStatus.Running then

            if self.CurRunningGuideSubGroupID ~= nil then
                if self.TutorialCfgTree[self.CurRunningGuideGroupID]["Leaf"][self.CurRunningGuideSubGroupID] ~= nil and
                        self.TutorialCfgTree[self.CurRunningGuideGroupID]["Leaf"][self.CurRunningGuideSubGroupID]["Status"] == TutorialDefine.TutorialNodeStatus.Running then
                    self.TutorialCfgTree[self.CurRunningGuideGroupID]["Leaf"][self.CurRunningGuideSubGroupID]["Progress"] = -self.TutorialCfgTree[self.CurRunningGuideGroupID]["Leaf"][self.CurRunningGuideSubGroupID]["Content"][1].TutorialID
                    self:PlayTutorial(self.TutorialCfgTree[self.CurRunningGuideGroupID]["Leaf"][self.CurRunningGuideSubGroupID]["Content"][1])
                end
            end
        end
    end
end

function NewTutorialMgr:GetPlayingTutorialMapItem(MapMarkerID)
    return false
end

function NewTutorialMgr:InterceptMapClickEvent()
    return
end

function NewTutorialMgr:OnDealCrafterRandomEvent(Params)
    local EventType = Params.EventType

    local function CrafterRandomEventTutorial(Param)
        --这里是转成特定职业只传转后的职业ID
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.ProductProfSpecialEvent --新手引导触发类型
        EventParams.Param1 = EventType
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = CrafterRandomEventTutorial, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end

function NewTutorialMgr:OnSkillGenAttack(Param)
    if self.TutorialCurID ~= nil and self.TutorialCurID == 77 then
        local RunningCfg = self:GetRunningCfg(self.TutorialCurID)
        self:EndSoftTutorial(RunningCfg)
    end
end

function NewTutorialMgr:OnMainPanelInActive(Param)

    if self.TutorialCurID ~= nil then
        local RunningCfg = self:GetRunningCfg(self.TutorialCurID)

        if RunningCfg ~= nil and RunningCfg.Type ~= TutorialDefine.TutorialType.Force then
            local GuideUIName = RunningCfg.GuideBPName
            local GuideUIViewID = UIViewMgr:GetViewIDByName(GuideUIName)
            --_G.TipsQueueMgr:Pause(false)
            UIViewMgr:HideView(GuideUIViewID)

            self.TutorialCurID = nil
            self.CurRunningGuideSubGroupID = nil
            self.CurRunningGuideGroupID = nil

            FLOG_INFO("OnMainPanelInActive ViewID is %d",GuideUIViewID)
        end
    end
end

function NewTutorialMgr:OnEndPlaySequence(Params)
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.Type = TutorialDefine.TutorialConditionType.CutFinish --新手引导触发类型
    EventParams.Param1 = Params.SequenceID
    self:OnCheckTutorialStartCondition(EventParams)
end

function NewTutorialMgr:OnGameEventPWorldMapEnter(Params)
    local IsInField = _G.PWorldMgr:CurrIsInField()
    --仅野外支持
    if IsInField then
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.RiderSystem --新手引导触发类型
        self:OnCheckTutorialStartCondition(EventParams)
    end
end

function NewTutorialMgr:OnGameEventPWorldExit(Params)
    if self.TutorialCurID ~= nil then

        FLOG_INFO("ForceEndTutorialPanel TutorialCurID = %d",self.TutorialCurID)

        --离开PWORLD就强制结束当前引导
        local Group = self:GetRunningSubGroup()

        if Group ~= nil then
            self:OnForceFinishTutorial()
        end

        self.CurRunningGuideSubGroupID = nil
        self.CurRunningGuideGroupID = nil
        self.TutorialCurID = nil
    end
end

function NewTutorialMgr:OnForceFinishTutorial(Params)
    self:FinishCurrentRunningGroup()
    self.TutorialForceCloseNum = 0
end

-------------------------------------------------------------

--- 关闭新手教程
function NewTutorialMgr:DisableTutorial()
    self.TutorialState = false
    USaveMgr.SetInt(SaveKey.TutorialState, TutorialDefine.TutorialSwitchType.Off, true)
end

--- 开启新手教程
function NewTutorialMgr:EnableTutorial()
    self.TutorialState = true
    USaveMgr.SetInt(SaveKey.TutorialState, TutorialDefine.TutorialSwitchType.On, true)
end

--- 新手第一次进入标志
function NewTutorialMgr:SetTutorialFirstPlay(State)
    self.TutorialFirstPlay = State
end

function NewTutorialMgr:GetTutorialFirstPlay()
    return self.TutorialFirstPlay
end

function NewTutorialMgr:GetTutorialCurID()
    return self.TutorialCurID
end

function NewTutorialMgr:GetTutorialState()
    return self.TutorialState
end

function NewTutorialMgr:IsSubGroupComplete(GroupID)
    ---只保存那些已经开始和结束的
    for k,v in pairs(self.TutorialCfgTree) do
        if v["Status"] == TutorialDefine.TutorialNodeStatus.Running then
            for m,n in pairs(v["Leaf"]) do
                if n["Status"] == TutorialDefine.TutorialNodeStatus.Finish then
                    if m == GroupID then
                        return true
                    end
                end
            end
            --如果大组完成了则直接记这个大组ID为0代表完成不用记它的小组进度了
        elseif v["Status"] == TutorialDefine.TutorialNodeStatus.Finish then
            for m,n in pairs(v["Leaf"]) do
                if m == GroupID then
                    return true
                end
            end
        end
    end

    return false
end

----------------------- DoGM -------------------
function NewTutorialMgr:PlayGMTutorial(GroupID)
    if type(GroupID) ~= 'number' then
        return
    end

    self.CurRunningGuideGroupID = GroupID
    self.TutorialCfgTree[GroupID]["Status"] = TutorialDefine.TutorialNodeStatus.Running

    for m,n in pairs(self.TutorialCfgTree[GroupID]["Leaf"]) do
        n["Status"] = TutorialDefine.TutorialNodeStatus.Running
        n["Progress"] = -n["Content"][1].TutorialID
    end

    local GMList = {}
    for m,n in pairs(self.TutorialCfgTree[GroupID]["Leaf"]) do
        table.insert(GMList,m)
    end

    table.sort(GMList)

    for m,n in pairs(self.TutorialCfgTree[GroupID]["Leaf"]) do
        if m == GMList[1] then
            self.CurRunningGuideSubGroupID = m
            self:PlayTutorial(n["Content"][1])
            return
        end
    end

end

function NewTutorialMgr:ClearTutorialSchedule()
    --重新生成TREE，清除所有数据
    self:LoadTutorialCfg()
    self:SendTutorialProgress()

    self.CurRunningGuideGroupID = nil
    self.CurRunningGuideSubGroupID = nil
    self.TutorialCurID = nil
end

function NewTutorialMgr:EnableGMTutorial(Enable)
    self.TutorialState = Enable == 1 and true or false
end

return NewTutorialMgr