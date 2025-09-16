--
-- Author: sammrli
-- Date: 2023-11-17
-- Description:任务容错节点管理
-- 容错相关放到这个脚本处理
-- 容错任务ID = 触发容错的任务ID*100 + 1 （构建一个虚拟任务，因为一个任务可能触发多个容错）
-- 容错ID = 以上构建的容错任务的目标ID

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local QuestClass = require("Game/Quest/BasicClass/Quest")
local TargetClass = require("Game/Quest/QuestTarget/TargetFinishDialog")

local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local MapUtil = require("Game/Map/MapUtil")

local QuestDefine = require("Game/Quest/QuestDefine")
local QuestHelper = require("Game/Quest/QuestHelper")
local QuestMainVM = require("Game/Quest/VM/QuestMainVM")

local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")

local QuestFaultTolerantCfg = require("TableCfg/QuestFaultTolerantCfg")


local LSTR = _G.LSTR
local TARGET_STATUS =   ProtoCS.CS_QUEST_NODE_STATUS
local TARGET_TYPE   =   ProtoRes.QUEST_TARGET_TYPE
local EActorType = _G.UE.EActorType

---@class QuestFaultTolerantMgr : MgrBase
---@field ParamsListOnNpc table<number, FaultTolerantParamOnNpc> @<QuestID, FaultTolerantParamOnNpc>
local QuestFaultTolerantMgr = LuaClass(MgrBase)

function QuestFaultTolerantMgr:OnInit()
end

function QuestFaultTolerantMgr:OnBegin()
    self.ParamsListOnNpc = {}
    self.FaultTolerantQuestMap = {}
    self.IsInitParams = false
end

function QuestFaultTolerantMgr:OnEnd()
    self.ParamsListOnNpc = nil
    self.FaultTolerantQuestMap = nil
    self.IsInitParams = false
end

function QuestFaultTolerantMgr:OnRegisterGameEvent()
    --self:RegisterGameEvent(EventID.GetQuestTrack, self.OnQuestUpdateOver)
end

---获取任务名称
local function GetQuestNameLocal(FaultType)
    if FaultType == ProtoRes.QUEST_FAULT_TOLERANT_TYPE.QUEST_FAULT_TOLERANT_TYPE_ITEM then
        return LSTR(595001) --595001("物品丢失前往重获")
    elseif FaultType == ProtoRes.QUEST_FAULT_TOLERANT_TYPE.QUEST_FAULT_TOLERANT_TYPE_MOUNT then
        return LSTR(595002) --595002("坐骑离开前往重获")
    elseif FaultType == ProtoRes.QUEST_FAULT_TOLERANT_TYPE.QUEST_FAULT_TOLERANT_TYPE_BUFF then
        return LSTR(595003) --595003("buff失效前往重获")
    end
    return ""
end

---初始化
function QuestFaultTolerantMgr:InitParams()
    local AllCfg = QuestFaultTolerantCfg:FindAllCfg()
    for _,Cfg in pairs(AllCfg) do
        ---@class FaultTolerantParamOnNpc
        ---@field ChapterID number
        ---@field StartQuestID number
        ---@field EndQuestID number
        ---@field UnAcceptDialogID number
        local Param = {}
        local QuestCfgItem = QuestHelper.GetQuestCfgItem(Cfg.StartQuestID)
        Param.ChapterID = QuestCfgItem.ChapterID
        Param.StartQuestID = Cfg.StartQuestID
        Param.EndQuestID = Cfg.EndQuestID
        Param.UnAcceptDialogID = Cfg.UnAcceptDialogID
        if not self.ParamsListOnNpc[Cfg.NpcID] then
            self.ParamsListOnNpc[Cfg.NpcID] = {}
        end
        table.insert(self.ParamsListOnNpc[Cfg.NpcID], Param)
    end
end

---获取npc未接取容错任务对话
function QuestFaultTolerantMgr:GetNpcUnAcceptDialogID(NpcID)
    if not self.IsInitParams then
        self.IsInitParams = true
        self:InitParams()
    end
    local ParamList = self.ParamsListOnNpc[NpcID]
    if not ParamList then
        return 0
    end
    for _, Param in pairs(ParamList) do
        local ChapterInfo = _G.QuestMgr.ChapterMap[Param.ChapterID]
        if ChapterInfo and (ChapterInfo.Status == QuestDefine.CHAPTER_STATUS.IN_PROGRESS or
            ChapterInfo.Status == QuestDefine.CHAPTER_STATUS.CAN_SUBMIT) then
            return Param.UnAcceptDialogID --直接返回未接取对话,如果触发了容错,不会走到这里
        end
    end
    return 0
end

function QuestFaultTolerantMgr:OnQuestUpdateOver()
    --self:CheckCurrentQuest(false)
end

function QuestFaultTolerantMgr:GetFaultTolerantQuestID(QuestID)
    return QuestID * 100 + 1
end


---创建容错任务
---更改了客户端的任务节点,服务器任务节点不变
function QuestFaultTolerantMgr:CreateFaultTolerantQuest(QuestID, FaultTolerantID)
    local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if not QuestCfgItem then
        return nil
    end
    local NewQuestID = self:GetFaultTolerantQuestID(QuestID) --构建容错任务,id是一个计算出来的值,为了处理多个容错目标并行的情况
    local NewTargetID = FaultTolerantID  --目标id就是容错id
    local NewQuest = QuestClass.New(NewQuestID, QuestCfgItem)
    NewQuest.Status = ProtoCS.CS_QUEST_STATUS.CS_QUEST_STATUS_IN_PROGRESS
    NewQuest.AcceptTimeMS = _G.TimeUtil.GetServerTimeMS()
    _G.QuestMgr.QuestMap[NewQuestID] = NewQuest

    local NewTarget = self:CreateTarget(NewQuestID, NewTargetID)
    NewQuest.Targets[NewTargetID] = NewTarget

    return NewQuest, NewTarget
end

function QuestFaultTolerantMgr:CreateTarget(NewQuestID, FaultTolerantID, FaultTolerantCfgItem, ChapterCfgItem)
    if not FaultTolerantCfgItem then
        FaultTolerantCfgItem = QuestFaultTolerantCfg:FindCfgByKey(FaultTolerantID)
        if not FaultTolerantCfgItem then
            FLOG_ERROR("[QuestFaultTolerantMgr] FaultTolerant cant find id="..tostring(FaultTolerantID))
            return nil
        end
    end
    if not ChapterCfgItem then
        ChapterCfgItem = QuestHelper.GetChapterCfgItem(FaultTolerantCfgItem.ChapterID)
        if not ChapterCfgItem then
            return nil
        end
    end
    local NewTargetID = FaultTolerantID
    local TargetCfg = {}
    TargetCfg.id = NewTargetID
    TargetCfg.MapID = FaultTolerantCfgItem.MapID
    TargetCfg.UIMapID = FaultTolerantCfgItem.UIMapID
    TargetCfg.m_szTargetDesc = FaultTolerantCfgItem.TargetText
    TargetCfg.m_iTargetType = TARGET_TYPE.QUEST_TARGET_TYPE_FINISH_DIALOG
    if FaultTolerantCfgItem.NpcID > 0 then
        TargetCfg.NaviType = QuestDefine.NaviType.NpcResID
        TargetCfg.NaviObjID = FaultTolerantCfgItem.NpcID
    elseif FaultTolerantCfgItem.EobjID > 0 then
        TargetCfg.NaviType = QuestDefine.NaviType.EObjResID
        TargetCfg.NaviObjID = FaultTolerantCfgItem.EobjID
    end
    local CtorParams = { QuestID = NewQuestID, TargetID = NewTargetID, Cfg = TargetCfg }
    local Properties = {FaultTolerantCfgItem.NpcID, FaultTolerantCfgItem.DialogID, FaultTolerantCfgItem.EobjID}
    --默认对话目标
    local NewTarget = TargetClass.New(CtorParams, Properties)
    NewTarget.Status = TARGET_STATUS.CS_QUEST_NODE_STATUS_IN_PROGRESS
    NewTarget.Desc = FaultTolerantCfgItem.TargetText
    return NewTarget
end

-- ==================================================
-- 外部系统接口
-- ==================================================

---检查任务是否失败(不满足条件)
---要配置了容错节点，才能检测是否失败
---@param QuestID number @任务ID
---@return boolean
function QuestFaultTolerantMgr:CheckQuestFault(QuestID)
    return self.FaultTolerantQuestMap[QuestID] ~= nil
end

---检测是否触发容错未接取对话
---@param NpcResID npc资源id
---@return boolean
function QuestFaultTolerantMgr:CheckStartUnAcceptDialog(NpcResID)
    local UnAcceptDialogID = self:GetNpcUnAcceptDialogID(NpcResID)
    if UnAcceptDialogID > 0 then
        QuestHelper.QuestPlaySequence(UnAcceptDialogID)
        return true
    end
    return false
end

---检测容错节点是否可接取
---@param QuestID number
---@return boolean
function QuestFaultTolerantMgr:CheckCanProceed(QuestID)
    local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem == nil then return false end
    local ChapterCfgItem = QuestHelper.GetChapterCfgItem(QuestCfgItem.ChapterID)
    if ChapterCfgItem == nil then  return false end
    local RoleSimple = MajorUtil.GetMajorRoleSimple()
    if RoleSimple == nil then return false end

    -- 等级限制
    --local bLowLevel = RoleSimple.Level < (ChapterCfgItem.MinLevel or 1)
    --if bLowLevel then return false end

    -- 职业(类)限制
    local bProfNotMatched = false
    local CurrProf = RoleSimple.Prof
    if QuestCfgItem.Profession ~= 0 then
        bProfNotMatched = (CurrProf ~= QuestCfgItem.Profession)
    elseif QuestCfgItem.ProfessionClass ~= 0 then
        bProfNotMatched = not _G.ProfMgr.CheckProfClass(CurrProf, QuestCfgItem.ProfessionClass)
    end
    if bProfNotMatched then return false end

    return true
end

---获取容错任务ID
---@param QuestID number
---@return number
function QuestFaultTolerantMgr:GetFaultTolerantID(QuestID)
    local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem then
        return QuestCfgItem.FaultTolerantNodeID
    end
    return 0
end

---容错任务名称
---@param QuestID number
---@return string | nil
function QuestFaultTolerantMgr:GetQuestName(QuestID)
    local FaultParam = self.FaultTolerantQuestMap[QuestID]
    if FaultParam then
        return GetQuestNameLocal(FaultParam.FaultType)
    end
    return ""
end

---获得任务章节名称
---@param FaultQuestID number
---@return string | nil
function QuestFaultTolerantMgr:GetChapterName(FaultQuestID)
    local Cfg = QuestFaultTolerantCfg:FindCfgByKey(FaultQuestID)
    if Cfg then
        local ChapterCfgItem = QuestHelper.GetChapterCfgItem(Cfg.ChapterID)
        if ChapterCfgItem == nil then return nil end
        return ChapterCfgItem.QuestName
    end
    return nil
end

---获取目标文本
function QuestFaultTolerantMgr:GetTargetName(QuestID)
    local FaultParam = self.FaultTolerantQuestMap[QuestID]
    if FaultParam then
        local FaultTolerantID =  self:GetFaultTolerantID(QuestID)
        if FaultTolerantID > 0 then
            local FaultCfgItem = QuestFaultTolerantMgr:GetCfg(FaultTolerantID)
            if FaultCfgItem then
                return FaultCfgItem.TargetText
            end
        end
    end
    return ""
end

---容错任务地图ID
---@param QuestID number
---@return number
function QuestFaultTolerantMgr:GetMapID(QuestID)
    local FaultParam = self.FaultTolerantQuestMap[QuestID]
    if FaultParam then
        return FaultParam.MapID
    end
    return 0
end

---获取容错配置
---@param FaultQuestID number
---@return QuestFaultTolerantCfg
function QuestFaultTolerantMgr:GetCfg(FaultQuestID)
    return QuestFaultTolerantCfg:FindCfgByKey(FaultQuestID)
end

---是否容错任务
---@param FaultQuestID number
---@return boolean
function QuestFaultTolerantMgr:IsFaultTolerantQuest(FaultQuestID)
    --local Cfg = QuestFaultTolerantCfg:FindCfgByKey(FaultQuestID)
    --return Cfg ~= nil
    --FLOG_ERROR("[FaultTolerant] IsFaultTolerantQuest Find="..tostring(FaultQuestID))
    for _, FaultTolerantQuest in pairs(self.FaultTolerantQuestMap) do
        --FLOG_ERROR("[FaultTolerant] "..tostring(FaultQuestID).." == "..tostring(FaultTolerantQuest.QuestID))
        if FaultQuestID == FaultTolerantQuest.QuestID then
            return true
        end
    end
    return false
end

---是否容错任务目标
---@param TargetID number
---@return boolean
function QuestFaultTolerantMgr:IsFaultTolerantTarget(TargetID)
    for _, FaultTolerantQuest in pairs(self.FaultTolerantQuestMap) do
        local Targets = FaultTolerantQuest.Targets
        if Targets then
            for K,_ in pairs(Targets) do
                if K == TargetID then
                    return true
                end
            end
        end
    end
    return false
end

---打开地图,并以容错任务点为中心
---@param MapID number
---@param QuestID number
function QuestFaultTolerantMgr:ShowWorldMap(MapID, QuestID)
    local UIMapID = MapUtil.GetUIMapID(MapID)
    local FaultTolerantID = self:GetFaultTolerantID(QuestID)
    _G.WorldMapMgr:ShowWorldMapQuest(MapID, UIMapID, FaultTolerantID)
end

---开始容错机制
---@param QuestID number
---@param FaultTolerantID number
function QuestFaultTolerantMgr:StartFaultTolerant(QuestID, FaultTolerantID)
    FLOG_INFO("[FaultTolerant] StartFaultTolerant "..tostring(QuestID).. " " ..tostring(FaultTolerantID))
    local FaultTolerantQuest = nil
    local FaultTolerantTarget = nil
    local IsNeedPostEvent = true
    local NewTargetID = FaultTolerantID
    if self.FaultTolerantQuestMap[QuestID] then
        FaultTolerantQuest = self.FaultTolerantQuestMap[QuestID]
        if FaultTolerantQuest.Targets[NewTargetID] then
            FaultTolerantTarget = FaultTolerantQuest.Targets[NewTargetID]
            FaultTolerantTarget.Status = TARGET_STATUS.CS_QUEST_NODE_STATUS_IN_PROGRESS
            IsNeedPostEvent = false
        else
            local NewQuestID = FaultTolerantQuest.QuestID
            FaultTolerantTarget = self:CreateTarget(NewQuestID, NewTargetID)
            FaultTolerantQuest.Targets[NewTargetID] = FaultTolerantTarget
        end
    else
        FaultTolerantQuest, FaultTolerantTarget = self:CreateFaultTolerantQuest(QuestID, FaultTolerantID)
        if FaultTolerantQuest then
            self.FaultTolerantQuestMap[QuestID] = FaultTolerantQuest
        end
    end
    if not FaultTolerantQuest or not FaultTolerantTarget then
        return
    end

    local QuestCfgItem = QuestHelper.GetQuestCfgItem(QuestID)
    if QuestCfgItem == nil then return false end
    local ChapterID = QuestCfgItem.ChapterID

    local Chapter = _G.QuestMgr.ChapterMap[ChapterID]
    if not Chapter then
        return
    end

    local FaultTolerantCfgItem = QuestFaultTolerantCfg:FindCfgByKey(FaultTolerantID)
    if not FaultTolerantCfgItem then
        FLOG_ERROR("[QuestFaultTolerantMgr] FaultTolerant cant find id="..tostring(FaultTolerantID))
        return nil
    end
    local ChapterCfgItem = QuestHelper.GetChapterCfgItem(FaultTolerantCfgItem.ChapterID)
    if not ChapterCfgItem then
        return nil
    end
    --注册
    if FaultTolerantCfgItem.NpcID > 0 then
        if not _G.QuestMgr:IsTargetRegisteredOnActor(NewTargetID, EActorType.Npc, FaultTolerantCfgItem.NpcID) then
            QuestHelper.AddNpcFaultTolerantQuest(FaultTolerantCfgItem.NpcID, FaultTolerantQuest.QuestID, FaultTolerantTarget, FaultTolerantCfgItem.MapID,
            ChapterCfgItem.QuestType, FaultTolerantCfgItem.DialogID, ChapterCfgItem.QuestName, FaultTolerantCfgItem.UIMapID)
        end
    elseif FaultTolerantCfgItem.EobjID > 0 then
        if not _G.QuestMgr:IsTargetRegisteredOnActor(NewTargetID, EActorType.EObj, FaultTolerantCfgItem.EobjID) then
            QuestHelper.AddEObjFaultTolerantQuest(FaultTolerantCfgItem.EobjID, FaultTolerantQuest.QuestID, FaultTolerantTarget, FaultTolerantCfgItem.MapID,
            ChapterCfgItem.QuestType, ChapterCfgItem.QuestName, FaultTolerantCfgItem.UIMapID)
        end
    end

    Chapter:UpdateStatusByQuest(FaultTolerantQuest)

    -- 更新追踪
    -- 更新下个目标（主界面左上角任务描述）
    -- 更新地图marker
    QuestMainVM:UpdateChapterVM(ChapterID)
    --FLOG_ERROR("[FaultTolerant] CurrTrackChapterID="..tostring(QuestMainVM.QuestTrackVM.CurrTrackChapterID)..
    --    " , ChapterID="..tostring(ChapterID))
    if QuestMainVM.QuestTrackVM.CurrTrackChapterID == ChapterID then
        QuestMainVM.QuestTrackVM:OnQuestUpdate(ChapterID)
    end

    -- 刷新NPC HUD图标
    if IsNeedPostEvent then
        _G.EventMgr:PostEvent(EventID.UpdateQuest, {
            bOnConditionUpdate = true,
        })
    end
end

---结束容错
---@param QuestID number
---@param FaultTolerantID number
function QuestFaultTolerantMgr:EndFaultTolerant(QuestID, FaultTolerantID)
    FLOG_INFO("[FaultTolerant] EndFaultTolerant  "..tostring(QuestID).. " " ..tostring(FaultTolerantID))
    if not self.FaultTolerantQuestMap then
        return
    end
    if self.FaultTolerantQuestMap[QuestID] then
        local FaultTolerantQuest = self.FaultTolerantQuestMap[QuestID]
        local IsAllFinish = true
        for TargetID, Target in pairs(FaultTolerantQuest.Targets) do
            if TargetID == FaultTolerantID then
                Target.Status = TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED
            else
                if Target.Status ~= TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED then
                    IsAllFinish = false
                end
            end
        end

        local NewQuestID = FaultTolerantQuest.QuestID
        local RemoveTargetID = FaultTolerantID
        local FaultCfgItem = QuestFaultTolerantCfg:FindCfgByKey(FaultTolerantID)
        if FaultCfgItem then
            if FaultCfgItem.NpcID > 0 then
                QuestHelper.RemoveNpcFaultTolerantQuest(FaultCfgItem.NpcID, NewQuestID, RemoveTargetID, FaultCfgItem.MapID)
            elseif FaultCfgItem.EobjID > 0 then
                QuestHelper.RemoveEObjFaultTolerantQuest(FaultCfgItem.EobjID, NewQuestID, RemoveTargetID, FaultCfgItem.MapID)
            end
            if IsAllFinish then
                self.FaultTolerantQuestMap[QuestID] = nil
                NewQuestID = self:GetFaultTolerantQuestID(QuestID)
                _G.QuestMgr.QuestMap[NewQuestID] = nil
                --恢复任务
                local Chapter = _G.QuestMgr.ChapterMap[FaultCfgItem.ChapterID]
                if Chapter then
                    local Quest = _G.QuestMgr.QuestMap[QuestID]
                    if Quest then
                        Chapter:UpdateStatusByQuest(Quest)
                    else
                        FLOG_ERROR("[FaultTolerant] Quest cant found in QuestMap, id="..tostring(QuestID))
                    end
                end
            else
                local Chapter = _G.QuestMgr.ChapterMap[FaultCfgItem.ChapterID]
                if Chapter then
                    Chapter:UpdateStatusByQuest(FaultTolerantQuest)
                end
            end
            -- 更新追踪
            -- 更新下个目标（主界面左上角任务描述）
            -- 更新地图marker
            QuestMainVM:UpdateChapterVM(FaultCfgItem.ChapterID)
            if QuestMainVM.QuestTrackVM.CurrTrackChapterID == FaultCfgItem.ChapterID then
                QuestMainVM.QuestTrackVM:OnQuestUpdate(FaultCfgItem.ChapterID)
            end
            -- 刷新NPC HUD图标
            _G.EventMgr:PostEvent(EventID.UpdateQuest, {
                bOnConditionUpdate = true,
            })
        end
    end
end

---检查是否能提交补发请求
---@param FaultQuestID number@容错任务ID（虚构ID=任务IDx100+1）
---@param FaultTolerantID number@容错ID
---@return boolean
function QuestFaultTolerantMgr:CheckCanSubmit(FaultQuestID, FaultTolerantID)
    for QuestID, FaultTolerantQuest in pairs(self.FaultTolerantQuestMap) do
        if FaultQuestID == FaultTolerantQuest.QuestID then
            local Quest = _G.QuestMgr.QuestMap[QuestID]
            if Quest then
                local FaultTolerant = Quest.FaultTolerants[FaultTolerantID]
                if FaultTolerant then
                    return FaultTolerant:CheckCanSubmit()
                end
            end
        end
    end
    return true
end

return QuestFaultTolerantMgr