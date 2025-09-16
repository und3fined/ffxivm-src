---
--- Author: lydianwang
--- DateTime: 2022-11-21
---

local LuaClass = require("Core/LuaClass")
local RestrictionBase = require("Game/Quest/BasicClass/RestrictionBase")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local GameEventRegister = require("Register/GameEventRegister")

local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")

local MajorUtil = require("Utils/MajorUtil")

local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")

local ITEM_UPDATE_TYPE = ProtoCS.ITEM_UPDATE_TYPE

---@class RestrictionEquip
local RestrictionEquip = LuaClass(RestrictionBase, true)

function RestrictionEquip:Ctor(_, Properties)
    self.EquipPartList = {}
    self.EquipIDList = {}
    self.EquipLevelList = {}

    self.PartRequirementMap = {} 
    self.MissEquipList = {}  --欠缺的装备列表
    self.MissOwnList = {}    --欠缺的拥有列表,用于商店标记判断

    local EquipPartStrList = string.split(Properties[1], "|")
    for _, Str in ipairs(EquipPartStrList) do
        table.insert(self.EquipPartList, tonumber(Str))
    end

    local EquipIDStrList = string.split(Properties[2], "|")
    for _, Str in ipairs(EquipIDStrList) do
        table.insert(self.EquipIDList, tonumber(Str))
    end

    local EquipLevelStrList = string.split(Properties[3], "|")
    for _, Str in ipairs(EquipLevelStrList) do
        table.insert(self.EquipLevelList, tonumber(Str))
    end

    self:UpdateQuestAtEvent(EventID.EquipUpdate)

    for i = 1, #self.EquipPartList do
        local Part = self.EquipPartList[i]
        self.PartRequirementMap[Part] = {
            ID = self.EquipIDList[i] or 0,
            Level = self.EquipLevelList[i] or 0,
        }
    end
    self:UpdateMissList()
    self:CheckAllAndNofity()
    if not self.GameEventRegister then
        self.GameEventRegister = GameEventRegister.New()
    end
    self.GameEventRegister:Register(EventID.BagUpdate, self, self.OnEventBagUpdate)
    self.GameEventRegister:Register(EventID.EquipUpdate, self, self.OnEventEquipUpdate)
    self.GameEventRegister:Register(EventID.FinishDialog, self, self.OnEventFinishDialog)
    self.GameEventRegister:Register(EventID.UpdateQuestTrack, self, self.OnEventUpdateQuestTrack)
    self.GameEventRegister:Register(EventID.QuestPlayRestrictedDialog, self, self.OnEventQuestPlayRestrictedDialog)
end

function RestrictionEquip:OnInit()
    _G.QuestMgr.QuestRegister:RegisterOwnItemData(self)
end

function RestrictionEquip:OnDestroy()
    _G.QuestMgr.QuestRegister:UnRegisterOwnItemData(self)
    if not self.GameEventRegister then
        self.GameEventRegister:UnRegisterAll()
    end
end

---@return boolean
function RestrictionEquip:CheckPassRestriction()
    for i = 1, #self.EquipPartList do
        local EquipPart = self.EquipPartList[i]
        local EquipID = self.EquipIDList[i]
        local EquipLevel = self.EquipLevelList[i]
        if not (EquipPart and (EquipID or EquipLevel)) then return false end

        local EquipedItem = EquipmentMgr:GetEquipedItemByPart(EquipPart)
        if EquipedItem == nil then return false end

        if EquipID or 0 > 0 then
            if (EquipedItem.ResID ~= EquipID) then
                return false
            end
        else
            local EquipedItemCfg = ItemCfg:FindCfgByKey(EquipedItem.ResID)
            if (EquipedItemCfg == nil) or (EquipedItemCfg.ItemLevel < EquipLevel) then
                return false
            end
        end
    end

    return true
end

function RestrictionEquip:IsNeed(ItemResID)
    if not next(self.MissOwnList) then
        return false
    end

    local EquipmentCfgItem = EquipmentCfg:FindCfgByKey(ItemResID)
    if not EquipmentCfgItem then
        return false
    end

    local MissItem = self.MissOwnList[EquipmentCfgItem.Part]
    if MissItem then
        local ItemCfgItem = ItemCfg:FindCfgByKey(ItemResID)
        if not ItemCfgItem then
            return false
        end
        if ItemCfgItem.ItemLevel >= MissItem.Level then
            -- 职业不在配置中
            if not _G.EquipmentMgr:CanEquiped(ItemResID, false) then
                return false
            end
           return true
        end
    end

    return false
end

-- 更新欠缺列表
function RestrictionEquip:UpdateMissList()
    local OldMissNum = table.length(self.MissOwnList)

    self.MissEquipList = {}
    self.MissOwnList = {}

    local EquipList = nil
    local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
    if RoleDetail then
        local Equip = RoleDetail.Equip
        if Equip then
            EquipList = Equip.EquipList
        end
    end
    for Part, NeedItem in pairs(self.PartRequirementMap) do
        local MeetID = false
        local MeetLevel = false
        if EquipList then
            local EquipItem = EquipList[Part]
            if EquipItem and EquipItem.ResID > 0 and EquipItem.GID > 0 then
                if NeedItem.ID and NeedItem.ID > 0 then
                    MeetID = EquipItem.ResID == NeedItem.ID
                else
                    MeetID = true
                end
                if NeedItem.Level then
                    local ItemCfgItem = ItemCfg:FindCfgByKey(EquipItem.ResID)
                    if ItemCfgItem then
                        MeetLevel = ItemCfgItem.ItemLevel >= NeedItem.Level
                    end
                else
                    MeetLevel = true
                end
            end
        end
        if not MeetID or not MeetLevel then
            self.MissEquipList[Part] = NeedItem
        end
    end

    if next(self.MissEquipList) then
        for Part, NeedItem in pairs(self.MissEquipList) do
            self.MissOwnList[Part] = NeedItem
        end
        local AllItem = _G.BagMgr:FilterItemByCondition(function(Item)
            return Item.Attr and Item.Attr.Equip
        end)
        for Part, NeedItem in pairs(self.MissOwnList) do
            for ItemIndex=1, #AllItem do
                local Item = AllItem[ItemIndex]
                if Item.Attr.Equip.Part == Part then
                    local ItemConfig = ItemCfg:FindCfgByKey(Item.ResID)
                    if ItemConfig then
                        if ItemConfig.ItemLevel >= NeedItem.Level then
                            self.MissOwnList[Part] = nil
                            break
                        end
                    end
                end
            end
        end
    end
    return OldMissNum ~= table.length(self.MissOwnList)
end

-- 检查所有满足穿戴的装备并通知
function RestrictionEquip:CheckAllAndNofity()
    local AllEquipItem = _G.BagMgr:FilterItemByCondition(function(Item)
        return Item.Attr and Item.Attr.Equip
    end)

    local ProfID = MajorUtil.GetMajorProfID()

    for Part, NeedItem in pairs(self.MissEquipList) do
        for i=1, #AllEquipItem do
            local EquipItem = AllEquipItem[i]
            if EquipItem.Attr.Equip.Part == Part then
                if _G.EquipmentMgr:CanEquiped(EquipItem.ResID, false, ProfID) then
                    local MeetID = false
                    local MeetLevel = false
                    if NeedItem.ID and NeedItem.ID > 0 then
                        MeetID = EquipItem.ResID == NeedItem.ID
                    else
                        MeetID = true
                    end
                    if NeedItem.Level then
                        local ItemCfgItem = ItemCfg:FindCfgByKey(EquipItem.ResID)
                        if ItemCfgItem then
                            MeetLevel = ItemCfgItem.ItemLevel >= NeedItem.Level
                        end
                    else
                        MeetLevel = true
                    end
                    if MeetID and MeetLevel then
                        -- 背包内容没变更,不用强制刷新
                        self:ShowSidebarTaskEquipmentWinPanel(false)
                        return
                    end
                end
            end
        end
    end
end

-- 检查是否有满足穿戴的装备并通知
---@param UpdateItem CsItemUpdateMsg
function RestrictionEquip:CheckAndNotify(UpdateItem)
    if not next(self.MissEquipList) then
        self:TryRemoveAllSidePopUp()
        return
    end
    local ProfID = MajorUtil.GetMajorProfID()
    for _, V in ipairs(UpdateItem) do
        if not V.IsTransfer and V.Type == ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_ADD then --不是转移并且是新获得
            if V.PstItem and V.PstItem.Attr and V.PstItem.Attr.Equip then
                local FindMissItem = self.MissEquipList[V.PstItem.Attr.Equip.Part]
                if FindMissItem then
                    if _G.EquipmentMgr:CanEquiped(V.PstItem.ResID, false, ProfID) then
                        if FindMissItem.ID and FindMissItem.ID > 0 then --装备id或装备等级,一般都是互斥关系
                            if FindMissItem.ID == V.PstItem.ResID then
                                self:ShowSidebarTaskEquipmentWinPanel(true)
                                return
                            end
                        else
                            local NeedLevel = FindMissItem.Level or 0
                            local ItemCfgItem = ItemCfg:FindCfgByKey(V.PstItem.ResID)
                            if ItemCfgItem then
                                if ItemCfgItem.ItemLevel >= NeedLevel then
                                    self:ShowSidebarTaskEquipmentWinPanel(true)
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- 显示一键装备侧边栏
---@param IsForceUpdate boolean @强制刷新(如果为true,会刷新进度条和装备列表)
function RestrictionEquip:ShowSidebarTaskEquipmentWinPanel(IsForceUpdate)
    if MajorUtil.IsMajorDead() then
        return
    end
    local CurDisplayed = _G.SidePopUpMgr:GetCurDisplayed()
    if CurDisplayed and CurDisplayed.UIID == UIViewID.SidebarTaskEquipmentWin then
        if IsForceUpdate then
            --_G.EventMgr:SendEvent(EventID.SidePopUpTaskEquipmentUpdate)
            _G.SidePopUpMgr:RemoveSidePopUp(UIViewID.SidebarTaskEquipmentWin)
        else
            return
        end
    end

    _G.SidePopUpMgr:AddSidePopUp(ProtoRes.side_popup_type.SIDE_POPUP_CLICK_WEAR, UIViewID.SidebarTaskEquipmentWin, {MissItemList = self.MissEquipList}) 
end

function RestrictionEquip:TryRemoveAllSidePopUp()
    local CurDisplayed = _G.SidePopUpMgr:GetCurDisplayed()
    if CurDisplayed and CurDisplayed.UIID == UIViewID.SidebarTaskEquipmentWin then
        _G.SidePopUpMgr:RemoveSidePopUp(UIViewID.SidebarTaskEquipmentWin)
    end
    _G.SidePopUpMgr:RemoveToBeDisplayed(UIViewID.SidebarTaskEquipmentWin)
end

---@param UpdateItem CsItemUpdateMsg
function RestrictionEquip:OnEventBagUpdate(UpdateItem)
    if self:UpdateMissList() then
        _G.EventMgr:SendEvent(EventID.UpdateQuestTargetOwnItem)
    end
    self:CheckAndNotify(UpdateItem)
end

function RestrictionEquip:OnEventEquipUpdate()
    self:UpdateMissList()
end

function RestrictionEquip:OnEventFinishDialog(_)
    if self.IsPlayRestrictedDialog then
        self:CheckAllAndNofity()
        self.IsPlayRestrictedDialog = false
    end
end

function RestrictionEquip:OnEventUpdateQuestTrack(Param)
    if self.QuestID == Param.QuestID then
        self:CheckAllAndNofity()
    end
end

function RestrictionEquip:OnEventQuestPlayRestrictedDialog(Param)
    if self.QuestID == Param.QuestID then
        self.IsPlayRestrictedDialog = true
    end
end

return RestrictionEquip