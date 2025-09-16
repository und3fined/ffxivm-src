---
--- Author: sammrli
--- DateTime: 2024-12-17
--- 发放道具
---

local LuaClass = require("Core/LuaClass")
local ProtoCS = require("Protocol/ProtoCS")

local EventID = require("Define/EventID")
local MsgTipsID = require("Define/MsgTipsID")
local FaultTolerantBase = require("Game/Quest/BasicClass/FaultTolerantBase")

local DepotVM = require("Game/Depot/DepotVM")

local ItemUtil = require("Utils/ItemUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local QuestHelper = require("Game/Quest/QuestHelper")

local SysnoticeCfg = require("TableCfg/SysnoticeCfg")

---@class FaultTolerantItem
local FaultTolerantItem = LuaClass(FaultTolerantBase)

function FaultTolerantItem:OnInit(Params)
    self.ResIDList = Params
end

function FaultTolerantItem:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.InitQuest, self.OnInitQuest)
    self:RegisterGameEvent(EventID.UpdateQuest, self.OnUpdateQuest)
    self:RegisterGameEvent(EventID.BagUpdate, self.OnBagUpdate)
end

function FaultTolerantItem:OnDestroy()
    if self.CheckTimerID then
        _G.TimerMgr:CancelTimer(self.CheckTimerID)
        self.CheckTimerID = nil
    end
end

function FaultTolerantItem:OnInitQuest()
    self:CheckMissItem()
end

function FaultTolerantItem:OnUpdateQuest(Params)
    if not Params then
        return
    end

    if Params.QuestID then
        if self.QuestID == Params.QuestID then
            self:CheckMissItem()
            return
        end
    end

    local UpdatedRspQuests = Params.UpdatedRspQuests
    if UpdatedRspQuests then
        for _, RspQuest in pairs(UpdatedRspQuests) do
            if self.QuestID == RspQuest.QuestID then
                self:CheckMissItem()
                break
            end
        end
    end
end

function FaultTolerantItem:OnBagUpdate(UpdateItem)
    local IsStartCheck = false
    if UpdateItem then
        for _, Item in pairs(UpdateItem) do
            if Item.Type == ProtoCS.ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_DELETE then
                for _, ResID in pairs(self.ResIDList) do
                    if ResID == Item.PstItem.ResID then
                        IsStartCheck = true
                        break
                    end
                end
            elseif Item.Type == ProtoCS.ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_ADD then
                for _, ResID in pairs(self.ResIDList) do
                    if ResID == Item.PstItem.ResID then
                        IsStartCheck = true
                        break
                    end
                end
            end
        end
    end
    if IsStartCheck then
        if self.CheckTimerID then
            _G.TimerMgr:CancelTimer(self.CheckTimerID)
        end
        self.CheckTimerID = _G.TimerMgr:AddTimer(self, self.OnTimeCheckCurrentQuest, 0.6)
    end
end

function FaultTolerantItem:CheckMissItem()
    local IsStartFaultTolerant = false
    for i=1, #self.ResIDList do
        local ItemID = self.ResIDList[i]
        local NumFromBag = _G.BagMgr:GetItemNum(ItemID)
        local NumFromEquiped =  _G.EquipmentMgr:GetEquipedItemNum(ItemID)
        local NumFromDepot = DepotVM:GetDepotItemNum(ItemID)
        if NumFromBag + NumFromEquiped + NumFromDepot <= 0 then
            IsStartFaultTolerant = true
            break
        end
    end

    if IsStartFaultTolerant then
        self:StartFaultTolerant(self.QuestID, self.FaultTolerantID)
    else
        self:EndFaultTolerant(self.QuestID, self.FaultTolerantID)
    end
    return IsStartFaultTolerant
end

function FaultTolerantItem:OnTimeCheckCurrentQuest()
    if self:CheckMissItem() then
        self:ShowFaultTip()
    end
    self.CheckTimerID = nil
end

---获取物品数量（包括背包、仓库、身上）
local function GetItemNum(ItemID)
    local NumFromBag = _G.BagMgr:GetItemNum(ItemID)
    local NumFromEquiped =  _G.EquipmentMgr:GetEquipedItemNum(ItemID)
    local NumFromDepot = DepotVM:GetDepotItemNum(ItemID)
    return NumFromBag + NumFromEquiped + NumFromDepot
end

function FaultTolerantItem:ShowFaultTip()
    local FaultCfgItem = _G.QuestFaultTolerantMgr:GetCfg(self.FaultTolerantID)
    if not FaultCfgItem then
        return
    end

    local NeedNames = ""
    local MissIndex = 0
    for i=1,#FaultCfgItem.Params do
        local ItemResID = FaultCfgItem.Params[i]
        if GetItemNum(ItemResID) <= 0 then
            NeedNames = NeedNames.. (MissIndex == 0 and ItemUtil.GetItemName(ItemResID)
                or string.format(",%s", ItemUtil.GetItemName(ItemResID)))
            MissIndex = MissIndex + 1
        end
    end

    local TipsID = MsgTipsID.QuestFaultMssItem
    local TargetName = self:GetCfgTargetNpcOrEObjName(FaultCfgItem)

    MsgTipsUtil.ShowTipsByID(TipsID, nil, NeedNames, TargetName)
    local NoticeCfgItem = SysnoticeCfg:FindCfgByKey(TipsID)
    if NoticeCfgItem then
        _G.ChatMgr:AddQuestMsg(NeedNames, TargetName, FaultCfgItem.MapID, self.QuestID, FaultCfgItem)
    end
end

function FaultTolerantItem:CheckCanSubmit()
    local LootItemInfo = nil
    for _, ResID in ipairs(self.ResIDList) do
        if GetItemNum(ResID) == 0 then
            if not LootItemInfo then
                LootItemInfo = {}
            end
            LootItemInfo[ResID] = 1
        end
    end
    if not LootItemInfo then
        return true
    end
    local NeedCount = _G.BagMgr:CheckLootItemInfo(LootItemInfo)
    local HadCount = _G.BagMgr:GetBagLeftNum()
    if NeedCount > HadCount then
        local RestrictedDialog = QuestHelper.MakeRestrictedDialogLootCount(NeedCount - HadCount)
        _G.NpcDialogMgr:OverrideStateEnd()
        _G.NpcDialogMgr:PushDialog(RestrictedDialog, 8, _G.LSTR(10004))
        return false
    end
    return true
end


return FaultTolerantItem