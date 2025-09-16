---
--- Author: Rock
--- DateTime: 2023-12-18
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local BagMgr = require("Game/Bag/BagMgr")
local ProtoCS = require("Protocol/ProtoCS")
local BagMainVM = require("Game/NewBag/VM/BagMainVM")
local ItemTipsFrameVM = require("Game/ItemTips/VM/ItemTipsFrameVM")
local FateItemSubmitInfoVM = require("Game/Fate/VM/FateItemSubmitInfoVM")

local NpcDialogMgr = nil
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_FATE_CMD

local FateItemSubmitVM = LuaClass(UIViewModel)

function FateItemSubmitVM:Ctor()
    self.RequiredItemVMList = UIBindableList.New(FateItemSubmitInfoVM)
    self.OwnedItemVMList = UIBindableList.New(FateItemSubmitInfoVM)
    self.ItemTipsVMData = ItemTipsFrameVM

    self.FateItemSubmitList = {}
    self.OwnedItemDataList = {}

    self.NpcDialogCfg = nil
    self.InteractiveFate = nil
    self.FateCfg = nil
    self.NPCEntityID = nil
    self.CurrentSumbitScore = 0 --本次所提交的总分值(Score)
end

function FateItemSubmitVM:OnBegin()
    NpcDialogMgr = _G.NpcDialogMgr
end

function FateItemSubmitVM:ShowItemSubmitView(
    InInteractiveFate,
    InTargetActionList,
    InNpcDialogCfg,
    InFateCfg,
    InNPCEntityID)
    self:ResetData(true)
    self.InteractiveFate = InInteractiveFate
    self.NpcDialogCfg = InNpcDialogCfg
    self.FateCfg = InFateCfg
    self.NPCEntityID = InNPCEntityID

    for i, TargetAction in ipairs(InTargetActionList) do
        local ItemId = TargetAction.Params
        local Item = BagMgr:GetItemByResID(ItemId)
        if Item then
            --所需物品列表
            local Params = {
                GID = Item.GID,
                ResID = ItemId,
                NumVisible = false, --任务需求栏：不需要数量
                SubMitNum = Item.Num,
                Num = Item.Num
            }

            table.insert(self.FateItemSubmitList, Params)

            --Owner物品
            table.insert(self.OwnedItemDataList, Item)

            self.CurrentSumbitScore = self.CurrentSumbitScore + TargetAction.Score * Item.Num
        end
    end

    --所需物品
    self.RequiredItemVMList:UpdateByValues(self.FateItemSubmitList, BagMainVM.SortBagItemVMPredicate)
    --更新Owner物品
    self.OwnedItemVMList:UpdateByValues(self.OwnedItemDataList, BagMainVM.SortBagItemVMPredicate)

    local Params = {ViewModel = self}

    for Key,Value in pairs (self.OwnedItemDataList) do
        self.ItemToSubmit = {}

        local DataInfo = {}
        local ResID = Value.ResID
        self.ItemToSubmit[ResID] = DataInfo
        DataInfo.RequiredNum = Value.Num
        DataInfo.SubmitNum = 0
        DataInfo.SubmitGIDMap = {}
    end

    --_G.UIViewMgr:ShowView(_G.UIViewID.FateItemSubmitPanel, Params)
    _G.UIViewMgr:ShowView(_G.UIViewID.NewQuestPropPanel, Params)
end

function FateItemSubmitVM:GetSubmitItemInfo()
end

function FateItemSubmitVM:CheckReadyToSubmit()
    if self.OwnedItemDataList == nil or #self.OwnedItemDataList < 1 then
        return false
    end
    local bReady = self.OwnedItemDataList[1].Num > 0
    return bReady
end

function FateItemSubmitVM:ResetData(bResetAll)
    self.CurrentSumbitScore = 0
    if bResetAll then
        self.FateItemSubmitList = {}
        self.OwnedItemDataList = {}
    end
    self.SelectedItemInfo = {
        GID = -1,
        ResID = -1
    }
end

---@param CollectItem table
function FateItemSubmitVM:SubmitItem()
    if self.InteractiveFate == nil then
        return
    end

    local NextProgress = self.InteractiveFate.Progress + self.CurrentSumbitScore
    if NextProgress < 100 then
        NpcDialogMgr:PlayDialogLib(self.NpcDialogCfg.ItemSumitFateProcess3, nil, false, nil)
    else
        NpcDialogMgr:PlayDialogLib(self.NpcDialogCfg.ItemSumitFateFinish3, nil, false, nil)
    end

    --提交物品气泡
    if self.FateCfg ~= nil and self.NPCEntityID ~= nil then
        if self.FateCfg.ItemSubmitYellId > 0 then
            _G.SpeechBubbleMgr:ShowBubbleByID(self.NPCEntityID, self.FateCfg.ItemSubmitYellId)
        end
    end

    local SubmitItemList = {}
    for i, ItemSubmitData in ipairs(self.FateItemSubmitList) do
        if nil ~= ItemSubmitData then
            table.insert(SubmitItemList, {ItemResID = ItemSubmitData.ResID, Num = ItemSubmitData.SubMitNum})
        end
    end
    local MsgID = CS_CMD.CS_CMD_FATE
    local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_SUBMIT_ITEM
    local MsgBody = {
        Cmd = SubMsgID,
        FateID = self.InteractiveFate.ID,
        FateSubmitItem = {
            Items = SubmitItemList
        }
    }

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

return FateItemSubmitVM
