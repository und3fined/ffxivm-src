---
--- Author: lydianwang
--- DateTime: 2022-01-11
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")
local QuestHelper = require("Game/Quest/QuestHelper")
local ItemSubmitVM = require("Game/Quest/VM/PanelVM/ItemSubmitVM")
local BagMgr = require("Game/Bag/BagMgr")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")

local DialogueUtil = require("Utils/DialogueUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local CommonUtil = require("Utils/CommonUtil")
local ColorUtil = require("Utils/ColorUtil")

local ProtoCS = require("Protocol/ProtoCS")
local QuestDefine = require("Game/Quest/QuestDefine")

local ITEM_UPDATE_TYPE = ProtoCS.ITEM_UPDATE_TYPE

local QuestMgr = nil
local QuestRegister = nil

---@class TargetGetItem
local TargetGetItem = LuaClass(TargetBase, true)

function TargetGetItem:Ctor(_, Properties)
    self.RequiredItemList = {}
    self.RequiredItemHQList = {} -- 若需求物品为NQ且存在HQ，则填入此列表

    self.RequiredNumList = {}
    self.OwnedItemCountList = {}

    self.NpcID = tonumber(Properties[3])
    self.DialogID = tonumber(Properties[4])
    self.EObjID = tonumber(Properties[6])

    self.IsShowTips = tonumber(Properties[7]) == 1
    self.IsShowItemView = tonumber(Properties[8]) == 1

    self.MagicsparList = {}

    do
        local _ <close> = CommonUtil.MakeProfileTag("TargetGetItem:Ctor_parse")

        local RequiredItemStrList = string.split(Properties[1], "|")
        for _, Str in ipairs(RequiredItemStrList) do
            local RequiredResID = tonumber(Str)
            table.insert(self.RequiredItemList, RequiredResID)
            -- 策划说不再支持提交NQ物品选用HQ物品代替,这里先注释
            --table.insert(self.RequiredItemHQList, BagMgr:GetItemHQItemID(RequiredResID))
        end

        local RequiredNumStrList = string.split(Properties[2], "|")
        for _, Str in ipairs(RequiredNumStrList) do
            table.insert(self.RequiredNumList, tonumber(Str))
            table.insert(self.OwnedItemCountList, 0)
        end

        local MagicsparStrList = string.split(Properties[5], "|")
        for _, Str in ipairs(MagicsparStrList) do
            table.insert(self.MagicsparList, tonumber(Str))
        end
    end
    local _ <close> = CommonUtil.MakeProfileTag("TargetGetItem:Ctor_VM")

    self.ItemSubmitVMItem = ItemSubmitVM.CreateForQuestTarget(self)
    self.OwnedItemDataList = {}
    -- self.bRequiredItemUpdated = true

    self.ItemSubmitVMItem.IsMagicsparNeed = #self.MagicsparList > 0
    
    QuestMgr = _G.QuestMgr
    QuestRegister = QuestMgr.QuestRegister
end

function TargetGetItem:DoStartTarget()
    self:RegisterEvent(EventID.BagUpdate, self.OnEventBagUpdate)
    self:RegisterEvent(EventID.MagicsparInlaySucc, self.OnEventBagUpdate)
    self:RegisterEvent(EventID.MagicsparUnInlaySucc, self.OnEventBagUpdate)
    self:RegisterEvent(EventID.MajorHit, self.OnGameEventMajorHit)
    self:RegisterEvent(EventID.MajorDead, self.OnGameEventMajorDead)
    self:RegisterEvent(EventID.QuestClosePropPanel, self.OnGameEventClosePropPanel)

    local RequiredItemValues = {}
    self.OwnedItemDataList = {}

    local IsShowMoreOwned = self.ItemSubmitVMItem.IsMagicsparNeed --是否显示更多拥有物品

    for i, ItemResID in ipairs(self.RequiredItemList) do
        local RequiredNum = self.RequiredNumList[i] or 0

        local Params = {
            GID = -1,
            ResID = ItemResID,
            Num = RequiredNum,
        }
        table.insert(RequiredItemValues, Params)

        local OwnedNum = 0
        self:ProcessOnRequiredIndex(i, function(ItemData)
            if IsShowMoreOwned or OwnedNum < RequiredNum then
                table.insert(self.OwnedItemDataList, ItemData)
            end
            OwnedNum = OwnedNum + ItemData.Num
        end)

        QuestHelper.PrintQuestInfo("TargetGetItem %d init item %d, num %d/%d", self.TargetID, ItemResID, OwnedNum, RequiredNum)
        self.OwnedItemCountList[i] = math.min(OwnedNum, RequiredNum)
    end
    self.ItemSubmitVMItem:InitRequiredItem(RequiredItemValues)

    if self:CheckCanFinish() then
        if self.NpcID > 0 then
            QuestHelper.AddNpcQuestTarget(self.QuestID, self)
        elseif self.EObjID > 0 then
            QuestHelper.AddEObjQuestTarget(self.QuestID, self)
        end
    end

    local DialogID = self:GetDialogID()
    if DialogID ~= 0 then
        local NextTarget = self:GetNextTarget()
        if NextTarget and QuestHelper.CheckTargetPlaySeq(NextTarget) then
            QuestRegister:RegisterBlackScreenOnStopDialogOrSeq(DialogID)
        end
    end
end

function TargetGetItem:DoClearTarget()
    local DialogID = self:GetDialogID()
    if DialogID ~= 0 then
        QuestRegister:UnRegisterBlackScreenOnStopDialogOrSeq(DialogID)
    end
end

function TargetGetItem:OnEventBagUpdate(UpdateItem)
    local bCanFinishBefore = self:CheckCanFinish()
    self.OwnedItemDataList = {}

    local ItemSubmitVMItem = self.ItemSubmitVMItem
    local IsShowMoreOwned = ItemSubmitVMItem.IsMagicsparNeed --是否显示更多拥有物品
    local IsUpdateMarkList = {}
    local IsAddMarkList = {}

    for i, ItemResID in ipairs(self.RequiredItemList) do -- 任务需求的物品
        local OwnedNum = 0
        local RequiredNum = self.RequiredNumList[i] or 0
        self:ProcessOnRequiredIndex(i, function(ItemData)
            if IsShowMoreOwned or OwnedNum < RequiredNum then
                table.insert(self.OwnedItemDataList, ItemData)
            end
            OwnedNum = OwnedNum + ItemData.Num
        end)

        local OldNum = self.OwnedItemCountList[i]
        -- if OwnedNum > 0 then
            QuestHelper.PrintQuestInfo("TargetGetItem %d update item %d, num %d/%d", self.TargetID, ItemResID, OwnedNum, RequiredNum)
            local NewNum = math.min(OwnedNum, RequiredNum)
            self.OwnedItemCountList[i] = NewNum
            IsUpdateMarkList[i] = OldNum ~= NewNum  --这个方式需要镶嵌魔晶石的物品不会标记update，但需要镶嵌魔晶石的物品不显示数量，就无所谓了
            IsAddMarkList[i] = OldNum < NewNum
            -- self.bRequiredItemUpdated = true
            -- 这个优化项暂时关闭，OwnedNum==0 不能说明物品没更新，需要新的判断依据
        -- end
	end

    local bCanFinishAfter = self:CheckCanFinish()

    if bCanFinishAfter then
        if self.NpcID > 0 then
            QuestHelper.AddNpcQuestTarget(self.QuestID, self)
        elseif self.EObjID > 0 then
            QuestHelper.AddEObjQuestTarget(self.QuestID, self)
        end
    end

    if bCanFinishBefore ~= bCanFinishAfter then
        if self.NpcID > 0 then
            QuestRegister:RegisterNpcQuestListToSort(self.NpcID)
        elseif self.EObjID > 0 then
            QuestRegister:RegisterEObjQuestListToSort(self.EObjID)
        end
        QuestMgr:OnQuestConditionUpdate()
        QuestMgr:SendEventOnConditionUpdate(self.QuestID)

        self:BreakTargetGetItem()
    end

    if self.IsShowTips and not bCanFinishBefore then
        for Index, IsAddMark in ipairs(IsAddMarkList) do
            if IsAddMark then
                self:ShowTips(Index)
                break
            end
        end
    end

    if self.IsShowItemView then
        for _, IsUpdateMark in ipairs(IsUpdateMarkList) do
            if IsUpdateMark then
                if self.OwnerChapterVM then
                    _G.QuestMainVM:UpdateChapterVM(self.OwnerChapterVM.ChapterID)
                end
                break
            end
        end

        -- 找到targetvm并更新item list
        local QuestCfgItem = QuestHelper.GetQuestCfgItem(self.QuestID)
        if QuestCfgItem then
            local TargetVM = _G.QuestMainVM:GetTargetVM(QuestCfgItem.ChapterID, self.TargetID)
            if TargetVM then
                TargetVM:UpdateItemList()
            end
        end
    end

    if _G.UIViewMgr:IsViewVisible(UIViewID.NewQuestPropPanel) then --如果提交界面正在显示，刷新数据
        if self.IsCurrentQuesttPropPanel then --判断是否任务目标打开的提交界面
            ItemSubmitVMItem:UpdateOwnedItem(self.OwnedItemDataList) --刷新ViewModel
            local NewQuestPropPanelView = _G.UIViewMgr:FindView(UIViewID.NewQuestPropPanel)
            if NewQuestPropPanelView then
                if ItemSubmitVMItem.IsMagicsparNeed then
                    NewQuestPropPanelView:OnClickedDelete() --取消选中
                else
                    ItemSubmitVMItem:ResetData() --清空上次填充的物品gid
                    NewQuestPropPanelView:AutoFillItem() --重新填充
                end
            end
        end
    end
end

function TargetGetItem:ShowTips(Index)
    local QuestCfgItem = QuestHelper.GetQuestCfgItem(self.QuestID)
    if QuestCfgItem then
        local ChapterVM = _G.QuestMainVM:GetChapterVM(QuestCfgItem.ChapterID)
        if ChapterVM then
            local TargetVM = ChapterVM:GetTargetVM(self.TargetID)
            if TargetVM then
                local Content = TargetVM.Desc
                if string.isnilorempty(Content) then
                    if self.Cfg then
                        Content = self.Cfg.m_szTargetDesc
                    end
                end
                Content = DialogueUtil.ParseLabel(Content)
			    Content = CommonUtil.GetTextFromStringWithSpecialCharacter(Content)
                Content = ColorUtil.ParseItemNameSceneStyle(Content)
                _G.UIViewMgr:HideView(UIViewID.ActiveSystemErrorTips)

                local TipParams = 
                {
                    bTargetFinish = self:CheckCanFinish(),
                    Count = self.OwnedItemCountList[Index] or 0,
                    MaxCount = self.RequiredNumList[Index] or 1,
                }
                MsgTipsUtil.ShowActiveTips(Content, 3, QuestDefine.TargetSound, TipParams)
            end
        end
    end
end

function TargetGetItem:CheckCanFinish()
    for i = 1, #self.RequiredItemList do
        if (self.OwnedItemCountList[i] or 0) < (self.RequiredNumList[i] or 0) then
            return false
        end
    end
    return true
end

---对每堆物品做魔晶石和HQ检查，通过检查的会调用回调
---@param Index int32 需求物品索引
---@param Callback function 回调函数，以ItemVM为参数
function TargetGetItem:ProcessOnRequiredIndex(Index, Callback)
    local ItemResID = self.RequiredItemList[Index] or 0
    if ItemResID == 0 then return end
    local ItemList = BagMgr:FilterItemByCondition(function(Item)
        return Item.ResID == ItemResID
    end)

    for _, ItemData in ipairs(ItemList) do
        if self:CheckMagicsparByProtoItem(ItemData) then
            Callback(ItemData)
        end
    end

    local RequiredItemHQ = self.RequiredItemHQList[Index] or 0
    if RequiredItemHQ == 0 then return end
    local HQItemList = BagMgr:FilterItemByCondition(function(Item)
        return Item.ResID == RequiredItemHQ
    end)

    for _, ItemData in ipairs(HQItemList) do
        if self:CheckMagicsparByProtoItem(ItemData) then
            Callback(ItemData)
        end
    end
end

function TargetGetItem:ShowItemSubmitView(DialogOrSequenceID)
    -- if self.bRequiredItemUpdated then
        self.ItemSubmitVMItem:UpdateOwnedItem(self.OwnedItemDataList)
        -- self.bRequiredItemUpdated = false
    -- end

    self.IsCurrentQuesttPropPanel = true
    local Params = {
        ViewModel = self.ItemSubmitVMItem,
        DialogOrSequenceID = DialogOrSequenceID
    }

    _G.UIViewMgr:ShowView(UIViewID.NewQuestPropPanel, Params)
end

function TargetGetItem:OnGameEventMajorHit()
    --被攻击
    self:BreakTargetGetItem()
end

function TargetGetItem:OnGameEventMajorDead()
    --死亡
    self:BreakTargetGetItem()
end

function TargetGetItem:OnGameEventClosePropPanel()
    self.IsCurrentQuesttPropPanel = nil
end

function TargetGetItem:BreakTargetGetItem()
    local ViewID = UIViewID.NewQuestPropPanel
    if (_G.UIViewMgr:IsViewVisible(ViewID)) then
        local Params = {IsBreakTargetGetItem = true}
        _G.UIViewMgr:HideView(ViewID, true, Params)
    end
end


---不要求镶嵌魔晶石，或镶嵌了对应魔晶石
function TargetGetItem:CheckMagicsparByProtoItem(Item)
    if not next(self.MagicsparList) then return true end

	if (Item == nil) or (Item.Attr == nil) then return false end
	if (Item.Attr.Equip == nil) then return true end

    local CarryList = Item.Attr.Equip.GemInfo.CarryList or {}

    for _, RequiredMagicspar in ipairs(self.MagicsparList) do
        local bFound = false

        if RequiredMagicspar == 0 then
            for _, OwnedMagicspar in pairs(CarryList) do
                if OwnedMagicspar ~= 0 then
                    bFound = true
                    break
                end
            end

        else
            for _, OwnedMagicspar in pairs(CarryList) do
                if RequiredMagicspar == OwnedMagicspar then
                    bFound = true
                    break
                end
            end
        end

        if not bFound then return false end
    end
    return true
end

function TargetGetItem:GetNpcID()
    return self.NpcID or 0
end

function TargetGetItem:SendFinish(CollectItem)
    if (self:GetNpcID() > 0) then
        QuestMgr:SendFinishTarget(self.QuestID, self.TargetID, self:GetNpcID(), CollectItem)
    elseif (self:GetEObjID() > 0) then
        QuestMgr:SendFinishTarget(self.QuestID, self.TargetID, self:GetEObjID(), CollectItem, _G.UE.EActorType.EObj)
    end
end

function TargetGetItem:GetDialogID()
    return self.DialogID or 0
end

function TargetGetItem:GetEObjID()
    return self.EObjID or 0
end

return TargetGetItem