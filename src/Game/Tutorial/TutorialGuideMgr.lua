---
---@Author: ZhengJanChuan
---@Date: 2024-07-04 19:07:13
---@Description: 新手指南管理类

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local MajorUtil = require("Utils/MajorUtil")
local Json = require("Core/Json")
local GuideCfg = require("TableCfg/GuideCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local QuestMgr = require("Game/Quest/QuestMgr")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ActorUtil = require("Utils/ActorUtil")
local MonsterCfg = require("TableCfg/MonsterCfg")
local EnmityCfg = require("TableCfg/EnmityCfg")
local SettingsUtils = require("Game/Settings/SettingsUtils")
local SaveKey = require("Define/SaveKey")
local DirectUpgradeGlobalCfg = require("TableCfg/DirectUpgradeGlobalCfg")
local ClientSetupMgr = require("Game/ClientSetup/ClientSetupMgr")
local USaveMgr = _G.UE.USaveMgr

local CondFuncRelate = ProtoRes.CondFuncRelate
local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local TutorialHandleType = ProtoRes.TutorialStartHandleType

local EventMgr
local EventID

---@class TutorialGuideMgr : MgrBase
local TutorialGuideMgr = LuaClass(MgrBase)

---OnInit
function TutorialGuideMgr:OnInit()
    self.GuideCfgList = {}          --指南表
    self.GuideTutorialList = {}     --获取的说明指南列表  负数为获取，但未看。 正数为已经看过
    self.GuideTutorialSpecialList = {} --特别数据
    self.GuideQueue = {}            --播放的说明指南队列
    self.GuideTutorialDoing = false
    self.GuideRedList = {}
    self.CheckMonsterTimer = nil --专门用于查询附近是否有怪
    self.CheckMonsterRecord = {}
    self.CheckMonsterRecord.PassiveMonster = 0
    self.CheckMonsterRecord.ActiveMonster = 0
    self.UseSkillList = {}
    self.ReceiveSaveData = false
    self.GuideState = true
end

---OnBegin
function TutorialGuideMgr:OnBegin()
    EventMgr = _G.EventMgr
    EventID = _G.EventID

    self:LoadCfg()

    self.CheckMonsterTimer = self:RegisterTimer(function()
        self:OnCheckMonster()
    end,0,1,0)
end

function TutorialGuideMgr:OnEnd()
    if self.CheckMonsterTimer ~= nil then
        self:UnRegisterTimer(self.CheckMonsterTimer)
        self.CheckMonsterTimer = nil
    end

    self:ClearGuideQueue()
end

function TutorialGuideMgr:OnShutdown()
end

function TutorialGuideMgr:OnRegisterNetMsg()
end

function TutorialGuideMgr:OnRegisterGameEvent()
    --- 监听游戏登录事件
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    --- 监听查询保存在服务器上的值。
    self:RegisterGameEvent(EventID.ClientSetupPost, self.ClientSetupPost)
    --- 监听倒计时结束
    self:RegisterGameEvent(EventID.TutorialGuideCountDownEnd, self.OnTutorialGuideCountDownEnd)

    --- 监听LOADING结束更新界面事件
    self:RegisterGameEvent(EventID.TutorialLoadingFinish, self.OnLoadingFinish)

    --- 监听模块解锁
    -- self:RegisterGameEvent(EventID.ModuleOpenAllMotionOverEvent, self.OnCheckGuideCondition)

end

function TutorialGuideMgr:OnCheckMonster()
    if self.CheckMonsterRecord.ActiveMonster == 1 and self.CheckMonsterRecord.PassiveMonster == 1 then
        return
    end

    --副本中不判断
    local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon()
    local IsInMainCity = _G.PWorldMgr:CurrIsInMainCity()
    if IsInDungeon or IsInMainCity then
        return
    end

    --获取阵营
    local function GetCamp(Target)
        if (Target == nil) then
            return ProtoRes.camp_type.camp_type_none
        end

        local AttributeComp = Target:GetAttributeComponent()
        if AttributeComp then
            return AttributeComp.Camp
        end

        return ProtoRes.camp_type.camp_type_none
    end

    local MajorActor = MajorUtil.GetMajor()

    if MajorActor == nil then
        return
    end

    local ActorManager = _G.UE.UActorManager.Get()
    local AllMonsters = ActorManager:GetAllMonsters()
    local MajorPos = MajorActor:FGetActorLocation()
    local Length = AllMonsters:Length()

    local _ <close> = CommonUtil.MakeProfileTag(string.format("TutorialGuideMgr_OnCheckMonster monsterlen=%d", Length))

    for i = 1, Length do
        local Monster = AllMonsters:GetRef(i)
        local MonsterPos = Monster:FGetActorLocation()
        local Camp = GetCamp(Monster)

        --必须是怪物阵营
        if Camp == ProtoRes.camp_type.camp_type_monster then
            local Dis = ((MonsterPos.X - MajorPos.X) ^ 2) + ((MonsterPos.Y - MajorPos.Y) ^ 2) + ((MonsterPos.Z - MajorPos.Z) ^ 2)

            if Dis < 4000000 then
                local EntityID = Monster:GetAttributeComponent().EntityID
                local ResID = ActorUtil.GetActorResID(EntityID)
                local _ <close> = CommonUtil.MakeProfileTag("TutorialGuideMgr_OnCheckMonster_MonsterCfg_FindCfgByKey")
                local Cfg = MonsterCfg:FindCfgByKey(ResID)
                local _ <close> = CommonUtil.MakeProfileTag("TutorialGuideMgr_OnCheckMonster_EnmityCfg_FindValue")
                local IsActive = EnmityCfg:FindValue(Cfg.EnmityID, "IsActiveEnmity")

                --第一次遇到主动怪
                if IsActive == 1 then
                    if self.CheckMonsterRecord.ActiveMonster == 0 then
                        self.CheckMonsterRecord.ActiveMonster = 1
                        local EventParams = _G.EventMgr:GetEventParams()
                        EventParams.Type = TutorialDefine.TutorialConditionType.MonsterNearMajor --新手引导触发类型
                        EventParams.Param1 = 1
                        self:OnCheckTutorialStartCondition(EventParams)
                        self:SendCheckMonsterRecord()

                    end
                else
                    --第一次遇到被动怪
                    if IsActive == 0 and self.CheckMonsterRecord.PassiveMonster == 0 and Dis < 1000000 then
                        self.CheckMonsterRecord.PassiveMonster = 1
                        local EventParams = _G.EventMgr:GetEventParams()
                        EventParams.Type = TutorialDefine.TutorialConditionType.MonsterNearMajor --新手引导触发类型
                        EventParams.Param1 = 0
                        self:OnCheckTutorialStartCondition(EventParams)
                        self:SendCheckMonsterRecord()
                    end
                end
            end
        end
    end
end

--- 监听是否满足引导开始条件
function TutorialGuideMgr:OnCheckTutorialStartCondition(Params)
    local Type = Params.Type
    local Param1 = Params.Param1 ~= nil and Params.Param1 or 0
    local Param2 = Params.Param2 ~= nil and Params.Param2 or 0

    if Type == TutorialDefine.TutorialConditionType.UseSkill then
        local LegalId = false

        for k,v in ipairs(self.GuideTutorialSpecialList) do
            if v == Param1 then
                LegalId = true
                break
            end
        end

        if not LegalId then
            return false
        end
    end

    local Skilllist = {}
    local TaskStartIDList = {}
    local TaskEndIDList = {}
    local List = self.GuideCfgList
    local PlayCount = 0

    local _ <close> = CommonUtil.MakeProfileTag("TutorialGuideMgr_OnCheckTutorialStartCondition")

    --技能这里是个列表要特殊处理
    if Type == TutorialDefine.TutorialConditionType.SkillUnlock then
        for k,v in ipairs(Param1) do
            table.insert(Skilllist,v.SkillID)
        end
    elseif Type == TutorialDefine.TutorialConditionType.TutorialTaskStart or Type == TutorialDefine.TutorialConditionType.TutorialTaskEnd then
        for k,v in pairs(Param1) do
            if v.Status == QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS then
                table.insert(TaskStartIDList,v.QuestID)
            elseif v.Status == QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
                table.insert(TaskEndIDList,v.QuestID)
            end
        end
    end

    for _, cfg in ipairs(List) do
        -- 判断是否已经被看过
        if not self:CheckGuide(cfg.GuideID) then
            --- 没有完成过的, 进行条件判断
            if table.length(Skilllist) > 0 then
                for k,SkillID in ipairs(Skilllist) do
                    local Cond = self:DoCheckGuideCondition(cfg,Type,SkillID,Param2)
                    if Cond then
                        --- 条件满足，播放条件
                        self:PlayGuide(cfg.GuideID)
                        PlayCount = PlayCount + 1
                    end
                end
            elseif table.length(TaskStartIDList) > 0  or table.length(TaskEndIDList) > 0 then
                for k,QuestID in ipairs(TaskStartIDList) do
                    local Cond = self:DoCheckGuideCondition(cfg,TutorialDefine.TutorialConditionType.TutorialTaskStart,QuestID,Param2)
                    if Cond then
                        --- 条件满足，播放条件
                        self:PlayGuide(cfg.GuideID)
                        PlayCount = PlayCount + 1
                    end
                end

                for k,QuestID in ipairs(TaskEndIDList) do
                    local Cond = self:DoCheckGuideCondition(cfg,TutorialDefine.TutorialConditionType.TutorialTaskEnd,QuestID,Param2)
                    if Cond then
                        --- 条件满足，播放条件
                        self:PlayGuide(cfg.GuideID)
                        PlayCount = PlayCount + 1
                    end
                end
            else
                local Cond
                if Type == TutorialDefine.TutorialConditionType.ProfLevel then
                    local Type1 = TutorialDefine.TutorialConditionType.ClassLevel
                    local ProfClass = RoleInitCfg:FindProfClass(Param1)
                    Cond = self:DoCheckGuideCondition(cfg,Type1,ProfClass,Param2)

                    if not Cond then
                        Cond = self:DoCheckGuideCondition(cfg,Type,Param1,Param2)
                    end
                else
                    Cond = self:DoCheckGuideCondition(cfg,Type,Param1,Param2)
                end

                if Cond then
                    --- 条件满足，播放条件
                    self:PlayGuide(cfg.GuideID)
                    PlayCount = PlayCount + 1
                end
            end
        end
    end

    if PlayCount > 0 then
        return true
    end

    return false
end

-- 监听游戏登录事件
function TutorialGuideMgr:OnGameEventLoginRes(Params)
    local bReconnect = Params and Params.bReconnect

    --登陆时才拉一次数据
    if not bReconnect then
        ClientSetupMgr:SendQueryReq({TutorialDefine.TutorialGuideStateKey})
        ClientSetupMgr:SendQueryReq({TutorialDefine.GuideTutorialKey})
    end
end

--- 监听存放在服务器上的数据
function TutorialGuideMgr:ClientSetupPost(EventParams)
    local Params = EventParams
    local Key = Params.IntParam1
    local Value = Params.StringParam1 or "{}"

    self:CheckTutorialGuideState()

    if Key == TutorialDefine.GuideTutorialKey then
        --self.GuideTutorialList = {}
        local GuideTutorials = Json.decode(Value)
        local NeedSaveData = false

        --说明收到保存数据前就已经在PLAY了，这样合并完数据要保存到后台
        if not self.ReceiveSaveData and #self.GuideTutorialList > 0 then
            NeedSaveData = true
        end

        if GuideTutorials ~= nil then
            FLOG_INFO("TutorialGuideMgr Value is %s",Value)
            for k,v in pairs(GuideTutorials) do
                self.GuideTutorialList[tostring(k)] = v
            end
        end

        self.ReceiveSaveData = true

        if NeedSaveData then
            self:SendCurrentGuideSchedule()
        end
    elseif Key == TutorialDefine.TutorialGuideStateKey then
        if Value == "{}" or Value == "" then
            self:CheckTutorialGuideState()
        else
            self.GuideState = tonumber(Value) == TutorialDefine.TutorialSwitchType.On and true or false
            EventMgr:SendEvent(EventID.TutorialGuideSwitch, {Value = tonumber(Value)})
        end
    elseif Key == TutorialDefine.GuideTutorialSpecialKey then
        local GuideTutorialSpecialList = Json.decode(Value)
        self.GuideTutorialSpecialList = {}

        if GuideTutorialSpecialList ~= nil then
            for k,v in pairs(GuideTutorialSpecialList) do
                self.GuideTutorialSpecialList[k] = v
            end
        else
            FLOG_ERROR("Error Value is %s",Value)
        end
    elseif Key == TutorialDefine.TutorialMonsterGuide then
        local SpecialData = Json.decode(Value)
        self.CheckMonsterRecord.ActiveMonster = SpecialData.ActiveMonster
        self.CheckMonsterRecord.PassiveMonster = SpecialData.PassiveMonster
    end
end

--- 检查是否保存过指南开关，如果没有读取设置界面中的指南开关默认属性。
function TutorialGuideMgr:CheckTutorialGuideState()
    local RoleID = MajorUtil:GetMajorRoleID()
    local TutorialStateValue = _G.ClientSetupMgr:GetSetupValue(RoleID, TutorialDefine.TutorialGuideStateKey)
    --- 服务器上没有存该状态 直接就调用设置
    if TutorialStateValue == nil then
        local State = USaveMgr.GetInt(SaveKey.TutorialGuideState, 1, true)
        self.GuideState = State == TutorialDefine.TutorialSwitchType.On and true or false
        SettingsUtils.SettingsTabUnCategory:SetTutorialGuideState(State, true)
    end
end

--- 关闭新手教程
function TutorialGuideMgr:DisableTutorialGuide()
    self.GuideState = false
    USaveMgr.SetInt(SaveKey.TutorialGuideState, TutorialDefine.TutorialSwitchType.Off, true)
end

--- 开启新手教程
function TutorialGuideMgr:EnableTutorialGuide()
    self.GuideState = true
    USaveMgr.SetInt(SaveKey.TutorialGuideState, TutorialDefine.TutorialSwitchType.On, true)
end

--- 发送给服务器保存下来
function TutorialGuideMgr:SendTutorialGuideState()
    local Params = {}
    Params.IntParam1 = TutorialDefine.TutorialGuideStateKey
    Params.StringParam1 = tostring( self.GuideState and 1 or 2)
    _G.ClientSetupMgr:OnGameEventSet(Params)
end

function TutorialGuideMgr:SendCheckMonsterRecord()
    local Params = {}
    Params.IntParam1 = TutorialDefine.TutorialMonsterGuide
    Params.StringParam1 = Json.encode(self.CheckMonsterRecord, { empty_table_as_array = true })
    _G.ClientSetupMgr:OnGameEventSet(Params)
end

--- 发送到服务器上保存数据
function TutorialGuideMgr:SendGuideSchedule(GuideID, Done)
    if GuideID == nil then
        return
    end

    if Done == nil then
        Done = true
    end

    local FinishList = self.GuideTutorialList
    local AbsGuideID = GuideID

    if Done then
        for key, value in pairs(FinishList) do
            if math.abs(value) == AbsGuideID then
                self.GuideTutorialList[tostring(key)] = AbsGuideID
            end
        end
    else
        if self.GuideTutorialList[tostring(AbsGuideID)] == nil then
            self.GuideTutorialList[tostring(AbsGuideID)] = -GuideID
        end
    end

    --没有收到第一次获取数据协议不保存数据
    if self.ReceiveSaveData then
        self:SendCurrentGuideSchedule()
    end

    --[[
    Params = {}
    local SpecialParams = {}

    for k,v in pairs(self.GuideTutorialSpecialList) do
        SpecialParams[tostring(k)] = v
    end

    Params.IntParam1 = TutorialDefine.GuideTutorialSpecialKey
    Params.GuideTutorialSpecialList = Json.encode(SpecialParams)
    _G.ClientSetupMgr:OnGameEventSet(Params)
    --]]
end

function TutorialGuideMgr:SendGuideSpecialData()
    local Params = {}
    local SpecialParams = {}

    for k,v in pairs(self.GuideTutorialSpecialList) do
        SpecialParams[k] = v
    end

    Params.IntParam1 = TutorialDefine.GuideTutorialSpecialKey
    Params.StringParam1 = Json.encode(SpecialParams,{empty_table_as_array = true})

    _G.ClientSetupMgr:OnGameEventSet(Params)
end

function TutorialGuideMgr:SendAllGuideSchedule()
    local FinishList = self.GuideTutorialList
    for k,v in pairs(FinishList) do
        if v < 0 then
            self.GuideTutorialList[tostring(k)] = math.abs(v)
        end
    end

    self:SendCurrentGuideSchedule()
end

function TutorialGuideMgr:SendCurrentGuideSchedule()
    local Params = {}
    Params.IntParam1 = TutorialDefine.GuideTutorialKey
    Params.StringParam1 = Json.encode(self.GuideTutorialList,{empty_table_as_array = true})
    _G.ClientSetupMgr:OnGameEventSet(Params)
end

--- 载入新手指南表
function TutorialGuideMgr:LoadCfg()
    local GuideCfgs = GuideCfg:FindAllCfg()
    local GuideList = {}
    local GuideUseSkillList = {}
    --- 只需要GuideID, 触发条件, 触发参数
    for _, cfg in ipairs(GuideCfgs) do
        local Data = {GuideID = cfg.GuideID, Relation = cfg.Relation, Open = cfg.Open}
        table.insert(GuideList, Data)

        if cfg.Open[1].Condition == TutorialDefine.TutorialConditionType.UseSkill then
            table.insert(GuideUseSkillList,cfg.Open[1].Param1)
        end

    end
    self.GuideCfgList = GuideList
    self.GuideTutorialSpecialList = GuideUseSkillList
end

--- 检查条件List
function TutorialGuideMgr:DoCheckGuideCondition(Cfg,Type,Param1,Param2)
    local _ <close> = CommonUtil.MakeProfileTag("TutorialGuideMgr_DoCheckGuideCondition")

    local Relation = Cfg.Relation
    if Relation == CondFuncRelate.OR then
        for _, value in ipairs(Cfg.Open) do
            if value.Condition == Type and value.Param1 == Param1 and value.Param2 == Param2 then
                return true
            end
        end
    elseif Relation == CondFuncRelate.AND then
        if Cfg.Open[1].Condition == Type and Cfg.Open[1].Param1 == Param1 and Cfg.Open[1].Param2 == Param2 then
            if self.GuideTutorialSpecialList[tostring(Cfg.GuideID)] == nil then
                self.GuideTutorialSpecialList[tostring(Cfg.GuideID)] = 1
                self:SendGuideSpecialData()
            elseif self.GuideTutorialSpecialList[tostring(Cfg.GuideID)] == 2 then
                self.GuideTutorialSpecialList[tostring(Cfg.GuideID)] = 0
                self:SendGuideSpecialData()
                return true
            end
        elseif Cfg.Open[2].Condition == Type and Cfg.Open[2].Param1 == Param1 and Cfg.Open[2].Param2 == Param2 then
            if self.GuideTutorialSpecialList[tostring(Cfg.GuideID)] == nil then
                self.GuideTutorialSpecialList[tostring(Cfg.GuideID)] = 2
                self:SendGuideSpecialData()
            elseif self.GuideTutorialSpecialList[tostring(Cfg.GuideID)] == 1 then
                self.GuideTutorialSpecialList[tostring(Cfg.GuideID)] = 0
                self:SendGuideSpecialData()
                return true
            end
        end
    end

    return false
end

--- 检查是否完成
function TutorialGuideMgr:CheckGuide(GuideID)
    local _ <close> = CommonUtil.MakeProfileTag(string.format("TutorialGuideMgr_CheckGuide guidenum=%d", #self.GuideTutorialList))

    for _, guideID in pairs(self.GuideTutorialList) do
        if math.abs(guideID) == GuideID then
            return true
        end
    end
    return false
end

function TutorialGuideMgr:IsViewShow()
    local View = UIViewMgr:FindView(UIViewID.TutorialEntrancePanel)

    if View ~= nil then
        if not View:GetIsHiding() then
            return true
        end
    end

    View = UIViewMgr:FindView(UIViewID.TutorialGuideShowPanel)

    if View ~= nil then
        if not View:GetIsHiding() then
            return true
        end
    end

    return false
end

--- 播放新手指南
function TutorialGuideMgr:PlayGuide(GuideID)
    if type(GuideID) ~= 'number' or not self.ReceiveSaveData then
        return
    end

    local _ <close> = CommonUtil.MakeProfileTag("TutorialGuideMgr_PlayGuide")

    --_G.TipsQueueMgr:Pause(true)

    local Cfg = GuideCfg:FindCfgByKey(GuideID)
    if Cfg ~= nil then
        if self.GuideState then
            if Cfg.IsTrigger ~= nil and Cfg.IsTrigger == 1 then
                if #self.GuideQueue == 0 and not self:IsViewShow() and _G.NewTutorialMgr:GetTutorialCurID() == nil and not _G.LoadingMgr:IsLoadingView() then
                    FLOG_INFO("PlayGuide %d",GuideID)
                    if Cfg.IsTips ~= nil and Cfg.IsTips == 1 then
                        local AudioUtil = require("Utils/AudioUtil")
                        local Path = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_Tips.Play_FM_Tips'"
                        local ID = AudioUtil.SyncLoadAndPlaySoundEvent(MajorUtil.GetMajorEntityID(), Path, true)

                        local Params = {}
                        Params.ID = GuideID
                        Params.CountDown = Cfg.TipsTime or 10
                        UIViewMgr:ShowView(UIViewID.TutorialEntrancePanel, Params)
                    else
                        local Params = {}
                        Params.ID = GuideID
                        Params.CountDown = Cfg.TipsTime or 10
                        UIViewMgr:ShowView(UIViewID.TutorialGuideShowPanel, Params)
                    end

                    table.insert(self.GuideQueue, GuideID)
                else
                    table.insert(self.GuideQueue, GuideID)
                    FLOG_INFO("PlayGuide %d and insert GuideQueue direct",GuideID)
                end

                self:SendGuideSchedule(GuideID, false)
                self.GuideTutorialDoing = true
            else
                self:SendGuideSchedule(GuideID, false)
            end
        else
            self:SendGuideSchedule(GuideID, false)
        end

        local ProtoCommon = require("Protocol/ProtoCommon")
        local OpenModuleCfg = _G.ModuleOpenMgr:GetCfgByModuleID(ProtoCommon.ModuleID.ModuleIDNewbie)
        if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDNewbie) and OpenModuleCfg then
            _G.EventMgr:SendEvent(_G.EventID.ModuleOpenNewBieGuideEvent, OpenModuleCfg.ID, true)
        end
    end
end

function TutorialGuideMgr:IsPlayQueueEmpty()
    return  #self.GuideQueue <= 0
end

function TutorialGuideMgr:PlayNextGuide()
    local Params = {}
    Params.ID = self.GuideQueue[1]
    local Cfg1 =GuideCfg:FindCfgByKey(self.GuideQueue[1])
    if Cfg1 ~= nil then
        local NewViewID
        if Cfg1.IsTips ~= nil and Cfg1.IsTips == 1 then
            Params.CountDown = 5.0
            NewViewID = UIViewID.TutorialEntrancePanel
        else
            NewViewID = UIViewID.TutorialGuideShowPanel
        end

        UIViewMgr:ShowView(NewViewID, Params)
    end
end

--- 新手指南主界面倒计时结束
function TutorialGuideMgr:OnTutorialGuideCountDownEnd()
    local GuideID = self.GuideQueue[1]
    table.remove(self.GuideQueue, 1)
    local ViewID = 0

    --_G.TipsQueueMgr:Pause(false)

    local Cfg = GuideCfg:FindCfgByKey(GuideID)

    if Cfg ~= nil then
        if Cfg.IsTips ~= nil and Cfg.IsTips == 1 then
            ViewID = UIViewID.TutorialEntrancePanel
        else
            ViewID = UIViewID.TutorialGuideShowPanel
        end

        if ViewID > 0 then
            UIViewMgr:HideView(ViewID)
        end

    end

    ---风脉泉结束需要通知触发快捷打开风脉泉功能
    if GuideID == 40 then
        EventMgr:SendEvent(EventID.TutorialGuideFenMaiQuanFinish)
    elseif GuideID == 59 then ---巡回乐团结束需要通知打开应援按钮界面
        EventMgr:SendEvent(EventID.TutorialGuideTouringBandFinish)
    end

    if #self.GuideQueue <= 0 then
        if _G.TutorialGuideMgr:IsPlayQueueEmpty() then
            if _G.UIViewMgr:IsViewVisible(UIViewID.MainPanel) then
                --关闭新手指引的时候如果主界面是显示的那么更新一下主界面播放主界面的引导
                _G.EventMgr:SendEvent(_G.EventID.TutorialMainPanelReActive,UIViewID.MainPanel)
            end
        end

        return
    end

    self:PlayNextGuide()
end

function TutorialGuideMgr:ClearGuideQueue()
    self.GuideQueue = {}
end

function TutorialGuideMgr:GetGuideQueue()
    return self.GuideQueue
end


function TutorialGuideMgr:SetGuideTutorialDoing(IsDoing)
    self.GuideTutorialDoing = IsDoing
end

function TutorialGuideMgr:InsertRedDotDataList(GuideID, RedDotName)
    if self.GuideRedList[tostring(GuideID)] == nil then
        self.GuideRedList[tostring(GuideID)] = RedDotName
    end
end

function TutorialGuideMgr:OnLoadingFinish()
    if #self.GuideQueue > 0 then
        self:PlayNextGuide()
    end
end

function TutorialGuideMgr:DelRedDotDataList(GuideID)
    self.GuideRedList[tostring(GuideID)] = nil
end

function TutorialGuideMgr:GetRedDotName(GuideID)
    return self.GuideRedList[tostring(GuideID)]
end

function TutorialGuideMgr:AddRedDot(GuideID)
    local RedDotName = self:GetRedDotName(GuideID)
    if RedDotName == nil then
        RedDotName = RedDotMgr:AddRedDotByParentRedDotID(11001, nil, false)
        self:InsertRedDotDataList(GuideID, RedDotName)
    end
end

function TutorialGuideMgr:DelRedDot(GuideID)
    local RedDotName = self:GetRedDotName(GuideID)
    if RedDotName ~= nil then
        RedDotMgr:DelRedDotByName(RedDotName)
        self:DelRedDotDataList(GuideID)
        self:SendGuideSchedule(GuideID, true)
    end
end

------------------------------ 对外接口 -----------------------------
--- 获取玩家获得的新手指南
function TutorialGuideMgr:GetGuideTutorial()
    return self.GuideTutorialList or {}
end

function TutorialGuideMgr:CheckIsRead(GuideID)
    for _, value in pairs(self.GuideTutorialList) do
        if GuideID == math.abs(value) then
            return value > 0
        end
    end

    return false
end

--- 搜索新手指南标题
function TutorialGuideMgr:SearchGuideTutorialTitle(Title)
    local GuideList = self:GetGuideTutorial()
    local Result = {}
    for _, guideID in pairs(GuideList) do
        local GuideID = math.abs(guideID)
        local Cfg = GuideCfg:FindCfgByGuideID(GuideID)
        if Cfg ~= nil then
            if string.find(Cfg.Title, Title) then
                table.insert(Result, Cfg)
            end
        end
    end
    -- table.sort(Result, function(a, b) return a.ID > b.ID end)
    return Result
end

--- 搜索新手指南内容
function TutorialGuideMgr:SearchGuideTutorialContent(Content)
    local GuideList = self:GetGuideTutorial()
    local Result = {}
    for _, guideID in pairs(GuideList) do
        local GuideID = math.abs(guideID)
        local Cfg = GuideCfg:FindCfgByGuideID(GuideID)
        if Cfg ~= nil then
            for _, data in ipairs(Cfg.Content) do
                if string.find(data, Content) then
                    table.insert(Result, Cfg)
                    break
                end
            end
        end
    end
    -- table.sort(Result, function(a, b) return a.ID > b.ID end)
    return Result
end

-----------------------DoGM-------------------

function TutorialGuideMgr:EnableGMTutorial(Enable)
    self.GuideState = Enable == 1 and true or false
end

function TutorialGuideMgr:ClearTutorialGuide()
    self.GuideTutorialList = {}

    local Params = {}
    Params.IntParam1 = TutorialDefine.GuideTutorialKey
    Params.StringParam1 = Json.encode(self.GuideTutorialList, {empty_table_as_array = true})
    _G.ClientSetupMgr:OnGameEventSet(Params)

    self.GuideTutorialSpecialList = {}
    Params = {}
    Params.IntParam1 = TutorialDefine.GuideTutorialSpecialKey
    Params.StringParam1 = Json.encode(self.GuideTutorialSpecialList,{empty_table_as_array = true})
    _G.ClientSetupMgr:OnGameEventSet(Params)
end

--- 查看新手指南id
function TutorialGuideMgr:PlayGMGuide(GuideID)
    self:PlayGuide(GuideID)
end

function TutorialGuideMgr:OpenGMGuide()
    self.GuideTutorialList = {-1,-2,-3,-4}

    UIViewMgr:ShowView(UIViewID.TutorialGuidePanel)
end

function TutorialGuideMgr:ParseStringToArray(InString)
    local result = {}
    InString = InString:sub(2,-2)
    for word in string.gmatch(InString, '([^,]+)') do
        table.insert(result, word)
    end
    return result
end

function TutorialGuideMgr:OnDirectUpgrade()
    local FinishList = self.GuideTutorialList
    local Exist = false

    local Cfg = DirectUpgradeGlobalCfg:GetDirectUpgradeCfg(ProtoRes.DIRECT_UPGRADE_ID.DIRECT_UPGRADE_ID_BEGINNERSGUIDE)
    local JumpList = self:ParseStringToArray(Cfg._SkipIDList)

    for key,value in pairs(JumpList) do
        Exist = false
        for k,v in pairs(FinishList) do
            if math.abs(v) == tonumber(value) then
                self.GuideTutorialList[tostring(k)] = tonumber(value)
                Exist = true
                break
            end
        end

        if not Exist then
            self.GuideTutorialList[tostring(value)] = tonumber(value)
        end
    end

    local Params = {}
    Params.IntParam1 = TutorialDefine.GuideTutorialKey
    Params.StringParam1 = Json.encode(self.GuideTutorialList, {empty_table_as_array = true})
    _G.ClientSetupMgr:OnGameEventSet(Params)
end

return TutorialGuideMgr
