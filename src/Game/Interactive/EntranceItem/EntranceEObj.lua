local LuaClass = require("Core/LuaClass")
local EntranceBase = require("Game/Interactive/EntranceItem/EntranceBase")
local EObjCfg = require("TableCfg/EobjCfg")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local FunctionItemFactory = require("Game/Interactive/FunctionItemFactory")

local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local ConditionMgr = require("Game/Interactive/ConditionMgr")
local ProtoRes = require("Protocol/ProtoRes")
local QuestDefine = require("Game/Quest/QuestDefine")
local CustomDialogOptionCfg = require("TableCfg/CustomDialogOptionCfg")
local CHAPTER_STATUS = QuestDefine.CHAPTER_STATUS
local QUEST_TYPE = ProtoRes.QUEST_TYPE

local EntranceEObj = LuaClass(EntranceBase)

function EntranceEObj:Ctor()
    self.TargetType = _G.UE.EActorType.EObj
end

function EntranceEObj:OnInit()
	local Cfg = EObjCfg:FindCfgByKey(self.ResID)
    self.Cfg = Cfg
    self.DisplayName = Cfg.Name
    --self.TargetName = Cfg.Name

    if not self.Distance or self.Distance <= 0 and self.EntityID then
        local Actor = ActorUtil.GetActorByEntityID(self.EntityID)
        if Actor then
            self.Distance = Actor:GetDistanceToMajor()
        end
    end

    self.FunctionItemsList = {}
    
    local IdList = self.Cfg.InteractID
    local FisrtCfg = nil

    if #IdList > 0 then
        FisrtCfg = InteractivedescCfg:FindCfgByKey(IdList[1])
    end

    --风脉泉
    if self.Cfg.EObjType == ProtoRes.ClientEObjType.ClientEObjTypeAetherCurrent then
        if FisrtCfg then
            self.IconPath = FisrtCfg.IconPath
            self.DisplayName = FisrtCfg.DisplayName
        end
    else
        if FisrtCfg and FisrtCfg.IsUseIconAndName == 1 then
            self.IconPath = FisrtCfg.IconPath
            self.DisplayName = FisrtCfg.DisplayName
        end
    end

    self.InteractiveQuestEntranceItems = {}
    self.CustomFunctionList = {}
end

function EntranceEObj:OnUpdateDistance()
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
function EntranceEObj:OnClick()
    local FunctionList = self:GenFunctionList()
    if #FunctionList == 0 then return end
    --打断当前技能(如果有)
    local CombatComponent = MajorUtil.GetMajorCombatComponent()
    if CombatComponent then
        CombatComponent:BreakSkill()
    end

    -- 如果只有一个离开+唯一的功能选项
    if #FunctionList <= 2 then
        FunctionList[1]:Click()
    else
        _G.InteractiveMgr:SetFunctionList(FunctionList)
    end
end

function EntranceEObj:CheckInterative(EnableCheckLog)
    if not self:CheckEyeLineBlock() then
        return false
    end

    --如果是部队物件, 判断一下是否已加入部队
    if self.Cfg.EObjType == ProtoRes.ClientEObjType.ClientEObjTypeGroup and not _G.ArmyMgr:IsInArmy() then
        return false
    end

    local QuestParamsList = _G.QuestMgr:GetEObjQuestParamsList(self.ResID)
    if #QuestParamsList > 0 then
        for _, value in ipairs(QuestParamsList) do
            if value.bShowQuestFunction then
                return true
            end
        end
    end

    local ResID = ActorUtil.GetActorResID(self.EntityID)
    local HintTalkData =  _G.QuestMgr:GetHintTalk(nil, ResID)
    if HintTalkData and next (HintTalkData) then
        return true
    end
    
    local FunItem = {}
    local ConditionParams = {}
    ConditionParams.EntityCreateCreateTime = ActorUtil.GetActorCreateTime(self.EntityID)
    FunItem.ConditionParams = ConditionParams

    local function CheckInteractiveDescFunc(InteractID)
        FunItem.FuncValue = InteractID
        FunItem.EntityID = self.EntityID
        FunItem.ResID = self.ResID
        FunItem.ListID = self.ListID
        return nil ~= FunctionItemFactory:CreateInteractiveDescFunc(FunItem, true)
    end

    local QuestFollowInteractIDList = _G.QuestMgr:GetFollowTargetInteract(self.TargetType, self.ResID)
    for i = 1, #QuestFollowInteractIDList do
        local InteractID = QuestFollowInteractIDList[i]
        if CheckInteractiveDescFunc(InteractID) then
            return true
        end
    end

    if self.Cfg ~= nil and self.Cfg.InteractID ~= nil and #self.Cfg.InteractID > 0 then
        for i = 1, #self.Cfg.InteractID do
            local InteractID = self.Cfg.InteractID[i]
            if CheckInteractiveDescFunc(InteractID) then
                return true
            end
        end
    end

    if self.Cfg ~= nil and self.Cfg.CustomTalkIDList ~= nil and #self.Cfg.CustomTalkIDList > 0 then
        for i = 1, #self.Cfg.CustomTalkIDList do
            local Cfg = CustomDialogOptionCfg:FindCfgByKey(self.Cfg.CustomTalkIDList[i])
            if Cfg and next(Cfg) then
                return true
            end
        end
    end
    return false
end

-- function EntranceEObj:OnGenFunctionList()
--     local FunctionList = {}
--     local EObjResID = self.ResID

--     -- 通过QuestMgr生成的任务选项
--     local QuestParamsList = _G.QuestMgr:GetEObjQuestParamsList(EObjResID)
--     for index, value in ipairs(QuestParamsList) do
--         if value.bShowQuestFunction then
--             local ReUse = false
--             for idx = 1, #self.FunctionItemsList do
--                 local FunctionItem = self.FunctionItemsList[idx]
--                 if FunctionItem.QuestID == value.QuestID then
--                     ReUse = true
--                     FunctionItem.FuncParams.FuncValue = index
--                     table.insert(FunctionList, FunctionItem)
--                     table.remove(self.FunctionItemsList, idx)
--                     break
--                 end
--             end

--             if not ReUse then
--                 local QuestFunctionUnit = FunctionItemFactory:CreateQuestFunc(value.QuestName,
--                     { FuncValue = index, EntityID = self.EntityID, ResID = EObjResID, QuestParams = value })

--                 if QuestFunctionUnit then
--                     table.insert(FunctionList, QuestFunctionUnit)
--                 end
--             end
--         end
--     end

--     -- 按任务目标TargetInteract进度显示的功能选项
--     local QuestFollowInteractIDList = QuestMgr:GetFollowTargetInteract(self.TargetType, self.ResID)
--     -- EObj表中的功能选项
--     local IdList = table.array_concat(QuestFollowInteractIDList, self.Cfg.InteractID)

--     for i = 1, #IdList do
--         local ReUse = false
--         for idx = 1, #self.FunctionItemsList do
--             local FunctionItem = self.FunctionItemsList[idx]
--             if FunctionItem.FuncParams.FuncValue == IdList[i] then
--                 ReUse = true
--                 table.insert(FunctionList, FunctionItem)
--                 table.remove(self.FunctionItemsList, idx)
--                 break
--             end
--         end

--         if not ReUse then
--             local InteractFunctionUnit = FunctionItemFactory:CreateInteractiveDescFunc(
--                 {FuncValue = IdList[i], EntityID = self.EntityID, ResID = EObjResID, IsEObj = true, ListID = self.ListID})
--             if InteractFunctionUnit then
--                 table.insert(FunctionList, InteractFunctionUnit)
--             end
--         end
--     end

--     --CustomTalk选项
--     local CustomTalkIDList = self:GetCustomTalkIDList(EObjResID)
--     --这里对话Mgr取不到eobj的前置对话，所以只用在这里控制前置对话
--     local IngnoreDialog = #IdList + #CustomTalkIDList >= 2
--     for i = 1, #CustomTalkIDList do
--         local ReUse = false
--         for idx = 1, #self.FunctionItemsList do
--             local FunctionItem = self.FunctionItemsList[idx]
--             if FunctionItem.FuncParams.FuncValue == CustomTalkIDList[i] then
--                 ReUse = true
--                 table.insert(FunctionList, FunctionItem)
--                 table.remove(self.FunctionItemsList, idx)
--                 break
--             end
--         end

--         if not ReUse then
--             local InteractFunctionUnit = FunctionItemFactory:CreateCustomTalkFunc(nil, 
--                 {FuncValue = CustomTalkIDList[i], EntityID = self.EntityID, ResID = EObjResID, IgnorePreDialog = IngnoreDialog, IsCustomTalk = true})
--             if InteractFunctionUnit then
--                 table.insert(FunctionList, InteractFunctionUnit)
--             end
--         end

--     end

--     local ReUse = false
--     for idx = 1, #self.FunctionItemsList do
--         local FunctionItem = self.FunctionItemsList[idx]
--         if FunctionItem.FuncType == LuaFuncType.NPCQUIT_FUNC then
--             ReUse = true
--             table.insert(FunctionList, FunctionItem)
--             table.remove(self.FunctionItemsList, idx)
--             break
--         end
--     end

--     -- 默认的离开选项
--     if not ReUse then
--         local QuitFunctionUnit = FunctionItemFactory:CreateFunction(LuaFuncType.NPCQUIT_FUNC
--             , "离开", { FuncValue = self.Cfg.EndDialogID, EntityID = self.EntityID, ResID = EObjResID})
--         table.insert(FunctionList, QuitFunctionUnit)
--     end

--     self.FunctionItemsList = FunctionList
--     return FunctionList
-- end

function EntranceEObj:ResetParams()
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

function EntranceEObj:SetEntranceItemIcon(EntranceItem)
    local TrackingQuestParam = _G.QuestTrackMgr:GetTrackingQuestParam()
    if nil ~= TrackingQuestParam and #TrackingQuestParam > 0 then
        local QuestID = TrackingQuestParam[1].QuestID
        local IconPath = _G.QuestMgr:GetQuestIconAtHUD(QuestID)
        EntranceItem:SetIconPath(IconPath)
    end
end

function EntranceEObj:GetQuestAndCustomFunctionList()
    self:ResetParams()
    local EObjResID = self.ResID

    -- 按任务目标TargetInteract进度显示的功能选项
    local QuestFollowInteractIDList = _G.QuestMgr:GetFollowTargetInteract(self.TargetType, EObjResID)
    --local IdList = table.array_concat(QuestFollowInteractIDList, self.Cfg.InteractID)
    --local 
    local IdList = self:MergeIdList(QuestFollowInteractIDList, self.Cfg.InteractID)

    -- 通过QuestMgr生成的任务选项
    local QuestParamsList = _G.QuestMgr:GetEObjQuestParamsList(EObjResID)
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
        for Index = 1, #self.CustomFunctionList do
            local FunctionItem = self.CustomFunctionList[Index]
            if nil ~= FunctionItem.FuncParams and FunctionItem.FuncParams.FuncValue == IdList[i] then
                ReUse = true
                if NavInteractiveID ~= 0 and IdList[i] == NavInteractiveID then
                    self:SetEntranceItemIcon(FunctionItem)
                end
                table.insert(NewCustomFunctionList, FunctionItem)
                table.remove(self.CustomFunctionList, Index)
                break
            end
        end

        if not ReUse then
            local InteractFunctionUnit = FunctionItemFactory:CreateInteractiveDescFunc(
                { FuncValue = IdList[i], EntityID = self.EntityID, ResID = EObjResID, IsEObj = true, ListID = self.ListID })
            if InteractFunctionUnit then
                if NavInteractiveID ~= 0 and IdList[i] == NavInteractiveID then
                    self:SetEntranceItemIcon(InteractFunctionUnit)
                end
                table.insert(NewCustomFunctionList, InteractFunctionUnit)
            end
        end
    end

    -- CustomTalk选项
    local CustomTalkIDList = self:GetCustomTalkIDList(EObjResID)
    --这里对话Mgr取不到eobj的前置对话，所以只用在这里控制前置对话
    local IngnoreDialog = #IdList + #CustomTalkIDList >= 2
    for i = 1, #CustomTalkIDList do
        local ReUse = false
        for Index = 1, #self.CustomFunctionList do
            local FunctionItem = self.CustomFunctionList[Index]
            if type(FunctionItem) ~= "userdata" and FunctionItem.FuncParams.FuncValue == CustomTalkIDList[i] then
                ReUse = true
                table.insert(NewCustomFunctionList, FunctionItem)
                table.remove(self.CustomFunctionList, Index)
                break
            end
        end

        if not ReUse then
            local InteractFunctionUnit = FunctionItemFactory:CreateCustomTalkFunc(nil, 
                { FuncValue = CustomTalkIDList[i], EntityID = self.EntityID, ResID = EObjResID, IgnorePreDialog = IngnoreDialog, IsCustomTalk = true })
            if InteractFunctionUnit then
                table.insert(NewCustomFunctionList, InteractFunctionUnit)
            end
        end
    end

    local ResID = ActorUtil.GetActorResID(self.EntityID)
    local HintTalkData =  _G.QuestMgr:GetHintTalk(nil, ResID)
    if HintTalkData and next (HintTalkData) then
        local InteractFunctionUnit = FunctionItemFactory:CreateDeafaultTalkFunc(LSTR(1280015), 
        { FuncValue = HintTalkData.DialogID, EntityID = self.EntityID})
        if InteractFunctionUnit then
            table.insert(NewCustomFunctionList, InteractFunctionUnit)
        end
    end

    self.CustomFunctionList = NewCustomFunctionList
end

function EntranceEObj:GenInteractiveQuestEntranceItems(EntranceItem)
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
                    and (Item.QuestParams.QuestID == Value.QuestID) then
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
                    local Item = FunctionItemFactory:CreateInteractiveDescFunc(
                        { FuncValue = Value.InteractID, EntityID = EntranceItem.EntityID, ResID = EntranceItem.ResID, IsEObj = true, ListID = EntranceItem.ListID})
                          --CameraData = {EntityID = EntranceItem.EntityID, ResID = EntranceItem.ResID}, IsEntranceItem = true})
                    if Item then
                        Item.LockMask = Value.LockMask
                        Item.QuestID = Value.QuestID
                        Item.TargetID = Value.TargetID
                        table.insert(EntranceItems, Item)
                    end
                else
                    local Item = FunctionItemFactory:CreateQuestFunc(Value.QuestName,
                        { FuncValue = Index, EntityID = EntranceItem.EntityID, ResID = EntranceItem.ResID, QuestParams = Value})
                         --CameraData = {EntityID = EntranceItem.EntityID, ResID = EntranceItem.ResID}, IsEntranceItem = true})
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

function EntranceEObj:GenQuestEntranceItem(QuestParams, Index)
    for i = 1, #self.FunctionItemsList do
        local Item = self.FunctionItemsList[i]
        if nil == QuestParams.InteractID and (nil ~= Item.QuestParams)
            and (Item.QuestParams.QuestID == QuestParams.QuestID) then
            Item.FuncParams.FuncValue = Index
            return Item
        end
    end

    return FunctionItemFactory:CreateQuestFunc(QuestParams.QuestName, { FuncValue = Index, EntityID = self.EntityID, ResID = self.ResID, QuestParams = QuestParams })
end

function EntranceEObj:GenQuestEntranceItems(QuestParamsList)
    local EntranceItems = {}

    for Index, QuestParams in ipairs(QuestParamsList) do
        local EntranceItem = self:GenQuestEntranceItem(QuestParams, Index)
        if EntranceItem then
            table.insert(EntranceItems, EntranceItem)
        end
    end

    return EntranceItems
end

function EntranceEObj:GenBranchQuestEntranceItems(QuestList)
    local EntranceItems = self:GenQuestEntranceItems(QuestList)

    if self:HasFunctionItems() then
        for _, Item in ipairs(self.CustomFunctionList) do
            table.insert(EntranceItems, Item)
        end
    end

    return EntranceItems
end

function EntranceEObj:GenLockedQuestEntranceItems()
    local EntranceItems = self:GenQuestEntranceItems(self.LockedQuestList)

    if self:HasFunctionItems() then
        for _, Item in ipairs(self.CustomFunctionList) do
            table.insert(EntranceItems, Item)
        end
    end

    return EntranceItems
end

function EntranceEObj:GetMainQuestIndex(QuestParamsList)
    if nil ~= QuestParamsList and #QuestParamsList > 0 then
        for Index, QuestParams in ipairs(QuestParamsList) do
            if QuestParams.QuestType == QUEST_TYPE.QUEST_TYPE_MAIN then
                return Index
            end
        end
    end
    return nil
end

function EntranceEObj:CheckWithMainQuest()
    local HasMainQuest = false
    -- 通过QuestMgr生成的任务选项
    local QuestParamsList = _G.QuestMgr:GetEObjQuestParamsList(self.ResID)
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

function EntranceEObj:OnGenFunctionList()
    self:GetQuestAndCustomFunctionList()
    local FunctionList = {}

    if self:IsNoQuest() then
        --EObj身上没挂任何任务
        if self:HasFunctionItems() then
            --有功能项，显示二级交互选项：功能1，功能2，……
            FunctionList = self.CustomFunctionList
        else
            --无反应，返回空列表
            _G.FLOG_WARNING("EntranceEObj:OnGenFunctionList, no quest and no function!")
        end
    elseif self:IsOnlyHasInteractableQuest() then
        --只挂了可直接交互任务
        if self:HasFunctionItems() then
            --有功能项，显示二级交互选项：功能1，功能2，……
            FunctionList = self.CustomFunctionList
        else
            --已经都提到一级交互列表里了，正常情况下，没有二级交互了，不会走到这里
            _G.FLOG_WARNING("EntranceEObj:OnGenFunctionList, has interactable quest but no function!")
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

    self.FunctionItemsList = FunctionList

    return FunctionList
end

function EntranceEObj:HasFunctionItems()
    return #self.CustomFunctionList > 0
end

function EntranceEObj:IsOnlyHasFinishedQuest()
    return #self.FinishedQuestList > 0 and
        #self.AcceptableQuestList == 0 and
        #self.InteractableQuestList == 0 and
        #self.InProgressQuestList == 0 and
        #self.LockedQuestList == 0
end

function EntranceEObj:IsOnlyHasAcceptableQuest()
    return #self.FinishedQuestList == 0 and
        #self.AcceptableQuestList > 0 and
        #self.InteractableQuestList == 0 and
        #self.InProgressQuestList == 0 and
        #self.LockedQuestList == 0
end

function EntranceEObj:IsOnlyHasInteractableQuest()
    return #self.FinishedQuestList == 0 and
        #self.AcceptableQuestList == 0 and
        #self.InteractableQuestList > 0 and
        #self.InProgressQuestList == 0 and
        #self.LockedQuestList == 0
end

function EntranceEObj:IsOnlyHasInProgressQuest()
    return #self.FinishedQuestList == 0 and
        #self.AcceptableQuestList == 0 and
        #self.InteractableQuestList == 0 and
        #self.InProgressQuestList > 0 and
        #self.LockedQuestList == 0
end

function EntranceEObj:IsOnlyHasLockedQuest()
    return #self.FinishedQuestList == 0 and
        #self.AcceptableQuestList == 0 and
        #self.InteractableQuestList == 0 and
        #self.InProgressQuestList == 0 and
        #self.LockedQuestList > 0
end

function EntranceEObj:IsNoQuest()
    return #self.FinishedQuestList == 0 and
        #self.AcceptableQuestList == 0 and
        #self.InteractableQuestList == 0 and
        #self.InProgressQuestList == 0 and
        #self.LockedQuestList == 0
end

function EntranceEObj:GetCustomTalkIDList(EObjResID)
    local Cfg = EObjCfg:FindCfgByKey(EObjResID)
    if Cfg == nil then return false end

    local CustomTalkIDList = {}
    for _, Str in ipairs(Cfg.CustomTalkIDList) do
        local Strs = string.split(Str, ';')
        if #Strs == 2 then
            local DialogID = tonumber(Strs[1])
            local ConditionID = tonumber(Strs[2])
            if ConditionMgr:CheckConditionByID(ConditionID) then
                table.insert(CustomTalkIDList, DialogID)
            end
        elseif #Strs > 0 then
            local DialogID = tonumber(Strs[1])
            table.insert(CustomTalkIDList, DialogID)
        end
    end
    return CustomTalkIDList
end

return EntranceEObj
