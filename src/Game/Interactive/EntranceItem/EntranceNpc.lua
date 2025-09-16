local LuaClass = require("Core/LuaClass")
local EntranceBase = require("Game/Interactive/EntranceItem/EntranceBase")
local NpcCfg = require("TableCfg/NpcCfg")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local FunctionItemFactory = require("Game/Interactive/FunctionItemFactory")
local ProtoRes = require("Protocol/ProtoRes")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local QuestDefine = require("Game/Quest/QuestDefine")
local MsgTipsID = require("Define/MsgTipsID")
local DataReportUtil = require("Utils/DataReportUtil")

local CHAPTER_STATUS = QuestDefine.CHAPTER_STATUS
local QUEST_TYPE = ProtoRes.QUEST_TYPE
local INTERACT_FUCN_TYPE = ProtoRes.interact_func_type

local EntranceNpc = LuaClass(EntranceBase)
function EntranceNpc:Ctor()
    self.TargetType = _G.UE.EActorType.Npc
    self.IsRemoveFateStart = false
    self.InteractivePriority = 1
end

--计算Distance、入口的显示字符串
function EntranceNpc:OnInit()
	local Cfg = NpcCfg:FindCfgByKey(self.ResID)
    self.DisplayName = Cfg.Name
    self.TargetName = Cfg.Name
    self.Cfg = Cfg

    if not self.Distance or self.Distance <= 0 and self.EntityID then
        local Actor = ActorUtil.GetActorByEntityID(self.EntityID)
        if Actor then
            self.Distance = Actor:GetDistanceToMajor()
        end
    end

    self.InteractiveQuestEntranceItems = {}
    self.FunctionItemsList = {}

    self.DisplayName = _G.LSTR(90014)

    if nil ~= Cfg.InteractiveIDList and #Cfg.InteractiveIDList > 0 then
        local FisrtCfg = InteractivedescCfg:FindCfgByKey(Cfg.InteractiveIDList[1])

        if FisrtCfg and FisrtCfg.IsUseIconAndName == 1 then
            self.IconPath = FisrtCfg.IconPath
            self.DisplayName = FisrtCfg.DisplayName
        end
    end

    self.CustomFunctionList = {}
end

function EntranceNpc:OnUpdateDistance()
    if self.EntityID > 0 then
        local Actor = ActorUtil.GetActorByEntityID(self.EntityID)

        if Actor then
            self.Distance = Actor:GetDistanceToMajor()
        else
            self.EntityID = 0
        end
    end
end

--Entrance的响应逻辑
function EntranceNpc:OnClick()
    --这里没有直接弹出二级交互，可能是对话等，所以二级交互的弹出等交由NpcDialogMgr处理了
    -- 战斗状态下不支持交互操作
    -- if MajorUtil.IsMajorCombat() == true then
    --     _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.CombatStateCantInteraction)
    --     return
    -- end

    -- 检查主角当前的状态是否可以进行交互操作
    -- if not _G.InteractiveMgr:IsCanDoBehavior() then
    --     return
    -- end

    NpcDialogMgr:BeginInteraction(self)

    DataReportUtil.ReportData("NpcCommonInteractive", true, false, true,
        "NpcID", tostring(self.ResID),
        "NpcName", self.Cfg.Name,
        "NpcType", tostring(self.Cfg.Type))

    if _G.InteractiveMgr:IsMountRideNpc(self.ResID) then
        --_G.FLOG_INFO("Interactive EntranceNpc %d Click", self.ResID)
        DataReportUtil.ReportData("MountTestRidingFlow", true, false, true,
            "OpType", "1",
            "Opdetail", "0",
            "Arg1", "",
            "Arg2", "",
            "Arg3", "")
    end
end

function EntranceNpc:PrintCheckLog(LogStr)
    if nil ~= self.EnableCheckLog and self.EnableCheckLog == true then
        local NpcName = ActorUtil.GetActorName(self.EntityID) or ""
        _G.FLOG_INFO(string.format("%s-->(%s)", LogStr, NpcName))
    end
end

function EntranceNpc:CheckInterative(EnableCheckLog)
    self.EnableCheckLog = EnableCheckLog

    if not self.Cfg then
        self:PrintCheckLog("EntranceNpc:CheckInterative, npc cfg is invalid!")
        return false
    end

    -- if self.Distance > self.Cfg.InteractionRange then
    --     self:PrintCheckLog("EntranceNpc:CheckInterative, too far from npc!")
    --     return false
    -- end

    local Cfg = self.Cfg

    if self.EntityID > 0 then
        local Actor = ActorUtil.GetActorByEntityID(self.EntityID)
        if nil == Actor then
            self:PrintCheckLog("EntranceNpc:CheckInterative, npc actor is nil!")
            return false
        end

        if self:IsOutOfInteractionRange(Actor) then
            self:PrintCheckLog("EntranceNpc:CheckInterative, npc is out of interaction range!")
            return false
        end

        -- local VisionLoadMeshState = Actor:GetVisionLoadMeshState()
        -- if VisionLoadMeshState ~= _G.UE.EVisionLoadMeshState.E_LOADED_SHOW then
        --     return false
        -- end
        -- if Actor.IsTurning and Actor:IsTurning() then
        --     return false
        -- end
    end

    if not self:CheckEyeLineBlock() then
        self:PrintCheckLog("EntranceNpc:CheckInterative, npc is blocked by eyeline!")
        return false
    end
    
    local ResID = ActorUtil.GetActorResID(self.EntityID)
    local HintTalkData =  _G.QuestMgr:GetHintTalk(ResID)
    if HintTalkData and next (HintTalkData) then
        return true
    end

    if _G.TouringBandMgr:CheckIsTouringBandNPC(self.EntityID) then
        if not _G.TouringBandMgr:CheckTouringBandNPCCanInteract(self.EntityID) then
            self:PrintCheckLog("EntranceNpc:CheckInterative, touring band npc Can not interact!")
            return false
        end
    end

    if Cfg.SwitchTalkID and Cfg.SwitchTalkID > 0 then
        local DialogID = 0
        DialogID = _G.NpcDialogMgr:FindDeafalutIDBySwitchTalk(Cfg.SwitchTalkID)
        if DialogID ~= 0 then
            return true
        end
    end

    if #_G.NpcDialogMgr:GetCustomTalkIDList(self.ResID) > 0 then
        return true
    end

    local NPCQuestParamsList = _G.QuestMgr:GetNPCQuestParamsList(self.ResID)
    if #NPCQuestParamsList > 0 then
        for _, value in ipairs(NPCQuestParamsList) do
            if value.bShowQuestFunction then
                return true
            end
        end
    end

    if _G.FateMgr:CheckIsFateNPC(self.EntityID) then
        if _G.FateMgr:CheckIsItemCollectFateNPC(self.EntityID) then
            return true
        end
        
        -- local FunctionList = self:OnGenFunctionList()
        -- return not (#FunctionList == 0
        -- or #FunctionList == 1 and (FunctionList[1].FuncType == LuaFuncType.QUIT_FUNC or FunctionList[1].FuncType == LuaFuncType.NPCQUIT_FUNC))
    end

    if (_G.FateMgr:GetCurrentFateType() == ProtoRes.Game.FATE_TYPE.FATE_TYPE_DANCE) then
        -- 如果当前的FATE是跳舞类型，那么去检测一下，看是不是在可用交互的范围内
        if (not _G.FateMgr:IsDanceFateInTimeRange()) then
            return false
        end

        if (_G.FateMgr:IsFateNpcDanced(self.EntityID)) then
            return false
        end
    end

    local FunItem = {}
    local ConditionParams = {}
    ConditionParams.EntityCreateCreateTime = ActorUtil.GetActorCreateTime(self.EntityID)
    FunItem.ConditionParams = ConditionParams

    local function CheckInteractiveDescFunc(InteractID)
        FunItem.FuncValue = InteractID
        FunItem.EntityID = self.EntityID
        FunItem.ResID = self.ResID
        local CheckResult = FunctionItemFactory:CreateInteractiveDescFunc(FunItem, true)
        if nil == CheckResult then
            self:PrintCheckLog("EntranceNpc:CheckInterative, CreateInteractiveDescFunc is nil!")
        end
        return nil ~= CheckResult
    end

    local QuestFollowInteractIDList = _G.QuestMgr:GetFollowTargetInteract(self.TargetType, self.ResID)
    for i = 1, #QuestFollowInteractIDList do
        local InteractID = QuestFollowInteractIDList[i]
        if CheckInteractiveDescFunc(InteractID) then
            return true
        end
    end

    if nil ~= Cfg.InteractiveIDList and #Cfg.InteractiveIDList > 0 then
        for i = 1, #Cfg.InteractiveIDList do
            local InteractID = Cfg.InteractiveIDList[i]
            if CheckInteractiveDescFunc(InteractID) then
                return true
            end
        end
    end

    self:PrintCheckLog("EntranceNpc:CheckInterative, no quest! no dialog! no interaction function!")
    return false
end

function EntranceNpc:IsOutOfInteractionRange(NPCActor)
    local MajorActor = MajorUtil.GetMajor()
    if nil ~= MajorActor then
        local MajorPos = MajorActor:FGetActorLocation()
        local NPCPos = NPCActor:FGetActorLocation()
        local NPCDistanceToMajor = ((NPCPos.X - MajorPos.X) ^ 2) + ((NPCPos.Y - MajorPos.Y) ^ 2) + ((NPCPos.Z - MajorPos.Z) ^ 2)
        --local ActorName = ActorUtil.GetActorName(self.EntityID) or ""
        --_G.FLOG_INFO("EntranceNpc:CheckInterative, ActorName:%s, Distance: %f", ActorName, NPCDistanceToMajor)
        if NPCDistanceToMajor > self.Cfg.InteractionRange ^ 2 then
            --_G.FLOG_INFO("EntranceNpc:IsOutOfInteractionRange")
            --self:LeaveInteractionRange()
            return true
        end
    end

    return false
end

function EntranceNpc:LeaveInteractionRange()
    --_G.FLOG_INFO("EntranceNpc:LeaveInteractionRange")
    local Params = {}
    Params.IntParam1 = _G.UE.EActorType.Npc
    Params.ULongParam1 = self.EntityID
    _G.InteractiveMgr:OnGameEventLeaveInteractionRange(Params)
end

function EntranceNpc:ResetParams()
    self.bHasTrackedQuest = false

    --已完成任务
    self.FinishedQuestList = {}
    --可接取任务
    self.AcceptableQuestList = {}
    --可直接交互的任务
    self.InteractableQuestList = {}
    --不能直接交互的进行中的任务
    self.InProgressQuestList = {}
    --不满足条件的任务
    self.LockedQuestList = {}
end

function EntranceNpc:GetInteractiveIDList()
    if self.Cfg.Type == ProtoRes.NPC_TYPE.ARMY then
        local IdList = {}
        for _, ID in ipairs(self.Cfg.InteractiveIDList) do
            local FisrtCfg = InteractivedescCfg:FindCfgByKey(ID)
            if nil ~= FisrtCfg then
                local FuncType = FisrtCfg.FuncType
                if (FuncType == INTERACT_FUCN_TYPE.INTERACT_FUNC_ARMY_RANK) or
                    (FuncType == INTERACT_FUCN_TYPE.INTERACT_FUNC_ARMY_TRANSFER and _G.CompanySealMgr:IsShowTransfer(self.EntityID)) or
                    ((FuncType == INTERACT_FUCN_TYPE.INTERACT_FUNC_ARMY_RANK_PROMOTION or 
                    FuncType == INTERACT_FUCN_TYPE.INTERACT_FUNC_ARMY_PREPARATORY) and _G.CompanySealMgr:IsShowTaskAndPromotion(self.EntityID)) then
                    --"查看军衔信息": 按钮一直显示，无条件判断
                    --"军队调动": 当玩家属于非当前NPC的军队时，显示交互项；当玩家属于当前NPC的军队或未加入任何军队，不显示交互项
                     --"筹备任务"和"军衔晋升": 若玩家属于当前NPC的军队，显示交互项；若玩家不属于当前NPC的军队或未加入军队，不显示交互项。
                    table.insert(IdList, ID)
                end
            end
        end
        return IdList
    end
    return self.Cfg.InteractiveIDList
end

function EntranceNpc:SetEntranceItemIcon(EntranceItem)
    local TrackingQuestParam = _G.QuestTrackMgr:GetTrackingQuestParam()
    if nil ~= TrackingQuestParam and #TrackingQuestParam > 0 then
        local QuestID = TrackingQuestParam[1].QuestID
        local IconPath = _G.QuestMgr:GetQuestIconAtHUD(QuestID)
        EntranceItem:SetIconPath(IconPath)
    end
end

function EntranceNpc:GetQuestAndCustomFunctionList()
    self:ResetParams()
    local NpcResID = self.ResID

    -- 按任务目标TargetInteract进度显示的功能选项
    local QuestFollowInteractIDList = _G.QuestMgr:GetFollowTargetInteract(self.TargetType, NpcResID)
    local InteractiveIDList = self:GetInteractiveIDList()
    local IdList = self:MergeIdList(QuestFollowInteractIDList, InteractiveIDList)

    -- 通过QuestMgr生成的任务选项
    local QuestParamsList = _G.QuestMgr:GetNPCQuestParamsList(NpcResID)
    for _, Value in ipairs(QuestParamsList) do
        local QuestParams = table.deepcopy(Value)
        if QuestParams.LockMask == 0 then
            --满足条件的任务
            if QuestParams.bDirectInteract then
                --可直接交互任务
                table.insert(self.InteractableQuestList, QuestParams)
                if nil ~= QuestParams.InteractID then
                    --从需要创建通用交互项的列表中排除需要创建QuestFunc的项
                    for Index, ID in ipairs(IdList) do
                        if ID == QuestParams.InteractID then
                            table.remove(IdList, Index)
                            break
                        end
                    end
                end
            else
                if QuestParams.bShowQuestFunction then
                    --非可直接交互任务
                    if QuestParams.ChapterStatus == CHAPTER_STATUS.CAN_SUBMIT then
                        --已完成任务
                        table.insert(self.FinishedQuestList, QuestParams)
                    elseif QuestParams.ChapterStatus == CHAPTER_STATUS.NOT_STARTED then
                        --可接取任务
                        table.insert(self.AcceptableQuestList, QuestParams)
                    elseif QuestParams.ChapterStatus == CHAPTER_STATUS.IN_PROGRESS then
                        --不能直接交互的进行中的任务
                        table.insert(self.InProgressQuestList, QuestParams)
                    end
                end
            end
        else
            --不满足条件的任务
            if QuestParams.bShowQuestFunction then
                table.insert(self.LockedQuestList, QuestParams)
            else
                if QuestParams.bDirectInteract then
                    -- 最新改动：不满足也显示交互按钮，只是交互的时候弹出不满足对话
                    table.insert(self.InteractableQuestList, QuestParams)
                end
                if nil ~= QuestParams.InteractID and QuestParams.InteractID ~= 0 then
                    --从需要创建通用交互项的列表中排除需要创建QuestFunc的项
                    for Index, ID in ipairs(IdList) do
                        if ID == QuestParams.InteractID then
                            table.remove(IdList, Index)
                            break
                        end
                    end
                end
            end
        end
    end

    local NavInteractiveID = 0
    local CurrNavPath = _G.QuestTrackMgr:GetCurrNavPath()
    if nil ~= CurrNavPath and nil ~= CurrNavPath.EndPosInteractiveID then
        NavInteractiveID = CurrNavPath.EndPosInteractiveID
    end

    local NewCustomFunctionList = {}
    for i = 1, #IdList do
        local ReUse = false
        for idx = 1, #self.CustomFunctionList do
            local FunctionItem = self.CustomFunctionList[idx]
            if nil ~= FunctionItem.FuncParams and FunctionItem.FuncParams.FuncValue == IdList[i] then
                ReUse = true
                if NavInteractiveID ~= 0 and IdList[i] == NavInteractiveID then
                    self:SetEntranceItemIcon(FunctionItem)
                end
                table.insert(NewCustomFunctionList, FunctionItem)
                table.remove(self.CustomFunctionList, idx)
                break
            end
        end

        if not ReUse then
            local InteractFunctionUnit = FunctionItemFactory:CreateInteractiveDescFunc(
                { FuncValue = IdList[i], EntityID = self.EntityID, ResID = NpcResID })
            if InteractFunctionUnit then
                if NavInteractiveID ~= 0 and IdList[i] == NavInteractiveID then
                    self:SetEntranceItemIcon(InteractFunctionUnit)
                end
                table.insert(NewCustomFunctionList, InteractFunctionUnit)
            end
        end
    end

    -- NPC表中的CustomTalk选项
    local CustomTalkIDList = _G.NpcDialogMgr:GetCustomTalkIDList(NpcResID)
    local IgnorePre = _G.NpcDialogMgr:CheckHasComplexInteractiveID(NpcResID)
    local QuestNum = #self.FinishedQuestList+ #self.AcceptableQuestList + #self.InProgressQuestList + #CustomTalkIDList
    local SkipPreDialog
    --先看有几个CustomTalkID
    if #CustomTalkIDList == 1 then
        --有一个，
    end
    if IgnorePre then
        --两个以上交互，CustomTalk不折叠
        SkipPreDialog = false
    else
        --QuestNum包括CustomTalk本身，只有一个CustomTalk的时候，前置对话已经在默认对话播放
        if QuestNum >= 2 then
            SkipPreDialog = false
        else
            SkipPreDialog = true
        end
    end

    for i = 1, #CustomTalkIDList do
        local ReUse = false
        for idx = 1, #self.CustomFunctionList do
            local FunctionItem = self.CustomFunctionList[idx]
            if type(FunctionItem) ~= "userdata" and FunctionItem.FuncParams.FuncValue == CustomTalkIDList[i] then
                ReUse = true
                FunctionItem.FuncParams.IgnorePreDialog = SkipPreDialog
                FunctionItem:UpdateData()
                table.insert(NewCustomFunctionList, FunctionItem)
                table.remove(self.CustomFunctionList, idx)
                break
            end
        end

        if not ReUse then
            local InteractFunctionUnit = FunctionItemFactory:CreateCustomTalkFunc(nil, 
                { FuncValue = CustomTalkIDList[i], EntityID = self.EntityID, ResID = NpcResID, IgnorePreDialog = SkipPreDialog, IsCustomTalk = true })
            if InteractFunctionUnit then
                table.insert(NewCustomFunctionList, InteractFunctionUnit)
            end
        end
    end

    self.CustomFunctionList = NewCustomFunctionList
end

function EntranceNpc:GenInteractiveQuestEntranceItems(EntranceItem)
    self:GetQuestAndCustomFunctionList()
    local EntranceItems = {}
    if #self.InteractableQuestList > 0 then
        for Index, Value in pairs(self.InteractableQuestList) do
            local ReUse = false
            local IsCommonFunc = false
            for i = 1, #self.InteractiveQuestEntranceItems do
                local Item = self.InteractiveQuestEntranceItems[i]
                if nil ~= Value.InteractID and nil == Item.QuestParams then
                    if Item.FuncParams.FuncValue == Value.InteractID then
                        ReUse = true
                        IsCommonFunc = true
                        Item.LockMask = Value.LockMask
                        table.insert(EntranceItems, Item)
                        table.remove(self.InteractiveQuestEntranceItems, i)
                        break
                    end
                end

                if nil == Value.InteractID and (Item.QuestParams ~= nil)
                    and (Item.QuestParams.QuestID == Value.QuestID)
                    and (Item.QuestParams.TargetID == Value.TargetID) then
                    ReUse = true
                    Item.FuncParams.FuncValue = Index
                    Item.LockMask = Value.LockMask
                    table.insert(EntranceItems, Item)
                    table.remove(self.InteractiveQuestEntranceItems, i)
                    break
                end
            end

            if not ReUse then
                if nil ~= Value.InteractID then
                    IsCommonFunc = true
                end

                if IsCommonFunc then
                    --读条不进镜头
                    local InteractiveCfg = InteractivedescCfg:FindCfgByKey(Value.InteractID)
                    local IsEntranceItem = InteractiveCfg.SingStateID[1] == 0
                    local Item = FunctionItemFactory:CreateInteractiveDescFunc(
                        { FuncValue = Value.InteractID, EntityID = EntranceItem.EntityID, ResID = EntranceItem.ResID, CameraData = {EntityID = EntranceItem.EntityID,
                        ResID = EntranceItem.ResID}, IsEntranceItem = IsEntranceItem})
                    if Item then
                        Item.LockMask = Value.LockMask
                        Item.QuestID = Value.QuestID
                        Item.TargetID = Value.TargetID
                        table.insert(EntranceItems, Item)
                    end
                else
                    local Item = FunctionItemFactory:CreateQuestFunc(Value.QuestName,
                        { FuncValue = Index, EntityID = self.EntityID, ResID = EntranceItem.ResID, QuestParams = Value, CameraData = {EntityID = EntranceItem.EntityID,
                        ResID = EntranceItem.ResID}, IsEntranceItem = true})
                    if Item then
                        Item.LockMask = Value.LockMask
                        Item.QuestID = Value.QuestID
                        Item.TargetID = Value.TargetID
                        table.insert(EntranceItems, Item)
                    end
                end
            end
        end
    end

    self.InteractiveQuestEntranceItems = EntranceItems

    return EntranceItems
end

function EntranceNpc:GenQuestEntranceItem(QuestParams, Index)
    for i = 1, #self.FunctionItemsList do
        local Item = self.FunctionItemsList[i]
        if nil == QuestParams.InteractID and (nil ~= Item.QuestParams)
            and (Item.QuestParams.QuestID == QuestParams.QuestID)
            and (Item.QuestParams.TargetID == QuestParams.TargetID) 
            and (Item.QuestParams.Icon == QuestParams.Icon) then
            --升级后任务图标会变化                       
            Item.FuncParams.FuncValue = Index
            return Item
        end
    end

    return FunctionItemFactory:CreateQuestFunc(QuestParams.QuestName, { FuncValue = Index, EntityID = self.EntityID, ResID = self.ResID, QuestParams = QuestParams })
end

function EntranceNpc:GenQuestEntranceItems(QuestParamsList)
    local EntranceItems = {}

    for Index, QuestParams in ipairs(QuestParamsList) do
        local EntranceItem = self:GenQuestEntranceItem(QuestParams, Index)
        if EntranceItem then
            table.insert(EntranceItems, EntranceItem)
        end
    end

    return EntranceItems
end

function EntranceNpc:GenBranchQuestEntranceItems(QuestList)
    local EntranceItems = self:GenQuestEntranceItems(QuestList)

    if self:HasFunctionItems() then
        for _, Item in ipairs(self.CustomFunctionList) do
            table.insert(EntranceItems, Item)
        end
    end

    return EntranceItems
end

function EntranceNpc:GenLockedQuestEntranceItems()
    local EntranceItems = self:GenQuestEntranceItems(self.LockedQuestList)
    -- for Index, QuestParam in ipairs(self.LockedQuestList) do
    --     local EntranceItem = FunctionItemFactory:CreateQuestFunc(QuestParam.QuestName,
    --                 { FuncValue = Index, EntityID = self.EntityID, ResID = self.ResID, QuestParams = QuestParam })
    --     if EntranceItem then
    --         table.insert(EntranceItems, EntranceItem)
    --     end
    -- end

    if self:HasFunctionItems() then
        for _, Item in ipairs(self.CustomFunctionList) do
            table.insert(EntranceItems, Item)
        end
    end

    return EntranceItems
end

function EntranceNpc:GetMainQuestIndex(QuestParamsList)
    if nil ~= QuestParamsList and #QuestParamsList > 0 then
        for Index, QuestParams in ipairs(QuestParamsList) do
            if QuestParams.QuestType == QUEST_TYPE.QUEST_TYPE_MAIN then
                return Index
            end
        end
    end
    return nil
end

function EntranceNpc:CheckWithMainQuest()
    local HasMainQuest = false
    -- 通过QuestMgr生成的任务选项
    local QuestParamsList = _G.QuestMgr:GetNPCQuestParamsList(self.ResID)
    for _, Value in ipairs(QuestParamsList) do
        if Value.LockMask == 0 and
            (Value.bDirectInteract or Value.bShowQuestFunction) and
            Value.QuestType == QUEST_TYPE.QUEST_TYPE_MAIN then
            HasMainQuest = true
            break
        end
    end

    self.IsWithMainQuest = HasMainQuest and 1 or 0
end

function EntranceNpc:OnGenFunctionList()
    self:GetQuestAndCustomFunctionList()
    local FunctionList = {}

    if self:IsNoQuest() then
        --NPC身上没挂任何任务
        if self:HasFunctionItems() then
            --有功能项，显示二级交互选项：功能1，功能2，……
            FunctionList = self.CustomFunctionList
        else
            --无反应，返回空列表
            _G.FLOG_WARNING("EntranceNpc:OnGenFunctionList, no quest and no function!")
        end
    elseif self:IsOnlyHasInteractableQuest() then
        --只挂了可直接交互任务
        if self:HasFunctionItems() then
            --有功能项，显示二级交互选项：功能1，功能2，……
            FunctionList = self.CustomFunctionList
        else
            --已经都提到一级交互列表里了，正常情况下，没有二级交互了，不会走到这里
            _G.FLOG_WARNING("EntranceNpc:OnGenFunctionList, has interactable quest but no function!")
        end
    elseif self:IsOnlyHasFinishedQuest() or #self.FinishedQuestList > 0 then
        --只挂了已完成任务，直接进入第一个任务流程
        local EntranceItem = self:GenQuestEntranceItem(self.FinishedQuestList[1], 1)
        if EntranceItem then
            table.insert(FunctionList, EntranceItem)
        end
    elseif self:IsOnlyHasAcceptableQuest() then
        --只挂了可接取任务，如果是主线任务直接进入第一个任务流程，非主线任务显示二级任务交互列表
        local Index = self:GetMainQuestIndex(self.AcceptableQuestList)
        if nil ~= Index then
            local EntranceItem = self:GenQuestEntranceItem(self.AcceptableQuestList[Index], Index)
            if EntranceItem then
                table.insert(FunctionList, EntranceItem)
            end
        else
            --FunctionList = self:GenQuestEntranceItems(self.AcceptableQuestList)
            FunctionList = self:GenBranchQuestEntranceItems(self.AcceptableQuestList)
        end
    elseif self:IsOnlyHasInProgressQuest() then
        --只挂了不能直接交互的进行中的任务，显示二级任务交互列表
        local Index = self:GetMainQuestIndex(self.InProgressQuestList)
        if nil ~= Index then
            local EntranceItem = self:GenQuestEntranceItem(self.InProgressQuestList[Index], Index)
            if EntranceItem then
                table.insert(FunctionList, EntranceItem)
            end
        else
            FunctionList = self:GenBranchQuestEntranceItems(self.InProgressQuestList)
        end
    elseif self:IsOnlyHasLockedQuest() then
        --只挂了不满足条件的任务, 显示二级交互选项：任务名1+上锁状态，任务名2+上锁状态，……
        --如果有功能项，在二级交互选项上追加：功能1，功能2，……
        FunctionList = self:GenLockedQuestEntranceItems()
    else
        --包含以上多种任务
        local AcceptableMainQuestIndex = self:GetMainQuestIndex(self.AcceptableQuestList)
        local InProgressMainQuestIndex = self:GetMainQuestIndex(self.InProgressQuestList)
        if nil ~= AcceptableMainQuestIndex then
            local EntranceItem = self:GenQuestEntranceItem(self.AcceptableQuestList[AcceptableMainQuestIndex], AcceptableMainQuestIndex)
            if EntranceItem then
                table.insert(FunctionList, EntranceItem)
            end
        elseif nil ~= InProgressMainQuestIndex then
            local EntranceItem = self:GenQuestEntranceItem(self.InProgressQuestList[InProgressMainQuestIndex], InProgressMainQuestIndex)
            if EntranceItem then
                table.insert(FunctionList, EntranceItem)
            end
        else
            --显示二级交互选项：任务名1，任务名2，……，任务名x+上锁状态，任务名x+上锁状态，……
            --如果有功能项，在二级交互选项上追加：功能1，功能2，……
            if #self.AcceptableQuestList > 0 then
                local EntranceItems = self:GenQuestEntranceItems(self.AcceptableQuestList)
                for _, EntranceItem in ipairs(EntranceItems) do
                    table.insert(FunctionList, EntranceItem)
                end
            end
            if #self.InProgressQuestList > 0 then
                local EntranceItems = self:GenQuestEntranceItems(self.InProgressQuestList)
                for _, EntranceItem in ipairs(EntranceItems) do
                    table.insert(FunctionList, EntranceItem)
                end
            end
            if #self.LockedQuestList > 0 then
                local EntranceItems = self:GenQuestEntranceItems(self.LockedQuestList)
                for _, EntranceItem in ipairs(EntranceItems) do
                    table.insert(FunctionList, EntranceItem)
                end
            end

            if self:HasFunctionItems() then
                for _, Item in ipairs(self.CustomFunctionList) do
                    table.insert(FunctionList, Item)
                end
            end
        end
    end

    local ReUse = false
    for Index = 1, #self.FunctionItemsList do
        local FunctionItem = self.FunctionItemsList[Index]
        if FunctionItem.FuncType == LuaFuncType.NPCQUIT_FUNC then
            ReUse = true
            table.insert(FunctionList, FunctionItem)
            table.remove(self.FunctionItemsList, Index)
            break
        end
    end

    -- 默认的离开选项
    if not ReUse then
        local QuitFunctionUnit = FunctionItemFactory:CreateFunction(LuaFuncType.NPCQUIT_FUNC
            , _G.LSTR(90003), { FuncValue = self.Cfg.EndDialogID, EntityID = self.EntityID, ResID = self.ResID })
        table.insert(FunctionList, QuitFunctionUnit)
    end

    if self.IsRemoveFateStart then
        for idx = 1, #FunctionList do
            local FunctionItem = FunctionList[idx]
            if FunctionItem.InteractivedescCfg ~= nil and FunctionItem.InteractivedescCfg.FuncType == ProtoRes.interact_func_type.INTERACT_FUNC_START_FATE then
                table.remove(FunctionList, idx)
                break
            end
        end
    end

    self.FunctionItemsList = FunctionList

    return FunctionList
end

--[[function EntranceNpc:OnGenFunctionList()
    local FunctionList = {}

    local NpcResID = self.ResID
    -- 通过QuestMgr生成的任务选项
    local QuestParamsList = _G.QuestMgr:GetNPCQuestParamsList(NpcResID)
    for index, value in ipairs(QuestParamsList) do
        if value.bShowQuestFunction then
            local ReUse = false
            for idx = 1, #self.FunctionItemsList do
                local FunctionItem = self.FunctionItemsList[idx]
                if (FunctionItem.QuestParams ~= nil)
                and (FunctionItem.QuestParams.QuestID == value.QuestID)
                and (FunctionItem.QuestParams.TargetID == value.TargetID) then
                    ReUse = true
                    FunctionItem.FuncParams.FuncValue = index
                    table.insert(FunctionList, FunctionItem)
                    table.remove(self.FunctionItemsList, idx)
                    break
                end
            end

            if not ReUse then
                local QuestFunctionUnit = FunctionItemFactory:CreateQuestFunc(value.QuestName,
                    { FuncValue = index, EntityID = self.EntityID, ResID = NpcResID, QuestParams = value })

                if QuestFunctionUnit then
                    table.insert(FunctionList, QuestFunctionUnit)
                end
            end
        end
    end

    -- 按任务目标TargetInteract进度显示的功能选项
    local QuestFollowInteractIDList = _G.QuestMgr:GetFollowTargetInteract(self.TargetType, self.ResID)
    -- NPC表中的功能选项
    local Cfg = self.Cfg
    local IdList = table.array_concat(QuestFollowInteractIDList, Cfg.InteractiveIDList)

    for i = 1, #IdList do
        local ReUse = false
        for idx = 1, #self.FunctionItemsList do
            local FunctionItem = self.FunctionItemsList[idx]
            if FunctionItem.FuncParams.FuncValue == IdList[i] then
                ReUse = true
                table.insert(FunctionList, FunctionItem)
                table.remove(self.FunctionItemsList, idx)
                break
            end
        end

        if not ReUse then
            local InteractFunctionUnit = FunctionItemFactory:CreateInteractiveDescFunc(
                        {FuncValue = IdList[i], EntityID = self.EntityID, ResID = NpcResID}) 
            if InteractFunctionUnit then
                table.insert(FunctionList, InteractFunctionUnit)
            end
        end
    end

    -- NPC表中的CustomTalk选项
    local CustomTalkIDList = _G.NpcDialogMgr:GetCustomTalkIDList(NpcResID)
    local IgnorePre = _G.NpcDialogMgr:CheckHasComplexInteractiveID(NpcResID)
    for i = 1, #CustomTalkIDList do
        local ReUse = false
        for idx = 1, #self.FunctionItemsList do
            local FunctionItem = self.FunctionItemsList[idx]
            if FunctionItem.FuncParams.FuncValue == CustomTalkIDList[i] then
                ReUse = true
                table.insert(FunctionList, FunctionItem)
                table.remove(self.FunctionItemsList, idx)
                break
            end
        end

        if not ReUse then
            local InteractFunctionUnit = FunctionItemFactory:CreateCustomTalkFunc(nil, 
                {FuncValue = CustomTalkIDList[i], EntityID = self.EntityID, ResID = NpcResID, IgnorePreDialog = not IgnorePre, IsCustomTalk = true})
            if InteractFunctionUnit then
                table.insert(FunctionList, InteractFunctionUnit)
            end
        end

    end

    local ReUse = false
    for idx = 1, #self.FunctionItemsList do
        local FunctionItem = self.FunctionItemsList[idx]
        if FunctionItem.FuncType == LuaFuncType.NPCQUIT_FUNC then
            ReUse = true
            table.insert(FunctionList, FunctionItem)
            table.remove(self.FunctionItemsList, idx)
            break
        end 
    end

    -- 默认的离开选项
    if not ReUse then
        local QuitFunctionUnit = FunctionItemFactory:CreateFunction(LuaFuncType.NPCQUIT_FUNC
            , "离开", { FuncValue = Cfg.EndDialogID, EntityID = self.EntityID, ResID = NpcResID})
        table.insert(FunctionList, QuitFunctionUnit)
    end

    ReUse = false
    --将来有别的功能的话，继续类似这种重用的处理，否则点击对话的时候functionitem的ui会重新执行淡入动画

    self.FunctionItemsList = FunctionList

    return FunctionList
end]]

function EntranceNpc:UpdateListByFateStart()
    self.IsRemoveFateStart = true
end

function EntranceNpc:HasTrackedQuest()
    --暂无表现需求，先不处理
    return self.bHasTrackedQuest
end

function EntranceNpc:HasFunctionItems()
    return #self.CustomFunctionList > 0
end


function EntranceNpc:IsOnlyHasFinishedQuest()
    return #self.FinishedQuestList > 0 and
        #self.AcceptableQuestList == 0 and
        #self.InteractableQuestList == 0 and
        #self.InProgressQuestList == 0 and
        #self.LockedQuestList == 0
end

function EntranceNpc:IsOnlyHasAcceptableQuest()
    return #self.FinishedQuestList == 0 and
        #self.AcceptableQuestList > 0 and
        #self.InteractableQuestList == 0 and
        #self.InProgressQuestList == 0 and
        #self.LockedQuestList == 0
end

function EntranceNpc:IsOnlyHasInteractableQuest()
    return #self.FinishedQuestList == 0 and
        #self.AcceptableQuestList == 0 and
        #self.InteractableQuestList > 0 and
        #self.InProgressQuestList == 0 and
        #self.LockedQuestList == 0
end

function EntranceNpc:IsOnlyHasInProgressQuest()
    return #self.FinishedQuestList == 0 and
        #self.AcceptableQuestList == 0 and
        #self.InteractableQuestList == 0 and
        #self.InProgressQuestList > 0 and
        #self.LockedQuestList == 0
end

function EntranceNpc:IsOnlyHasLockedQuest()
    return #self.FinishedQuestList == 0 and
        #self.AcceptableQuestList == 0 and
        #self.InteractableQuestList == 0 and
        #self.InProgressQuestList == 0 and
        #self.LockedQuestList > 0
end

function EntranceNpc:IsNoQuest()
    return #self.FinishedQuestList == 0 and
        #self.AcceptableQuestList == 0 and
        #self.InteractableQuestList == 0 and
        #self.InProgressQuestList == 0 and
        #self.LockedQuestList == 0
end

function EntranceNpc:IsNeedShowArmyExchangeEntrance()
    return false
end

---GetIconPath
---@return string
function EntranceNpc:GetIconPath()
    -- local ResID = self.ResID
    -- local Icon = _G.GoldSauserMgr:GetDialogIcon(ResID)
    -- if Icon ~= nil then
    --     return Icon
    -- end
    return self.IconPath
end

return EntranceNpc
