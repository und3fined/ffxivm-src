---
--- Author: lydianwang
--- DateTime: 2022-04-01
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")

local ItemCfg = require("TableCfg/ItemCfg")
local QuestCfg = require("TableCfg/QuestCfg")

local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")

local MajorUtil = require("Utils/MajorUtil")

local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local TARGET_STATUS = ProtoCS.CS_QUEST_NODE_STATUS
local ITEM_UPDATE_TYPE = ProtoCS.ITEM_UPDATE_TYPE

---@class TargetEquip
local TargetEquip = LuaClass(TargetBase, true)

function TargetEquip:Ctor(_, Properties)
    self.PartRequirementMap = {} -- map< int Part, { int ID, int Level } >

    self.MissItemList = {}  --欠缺的列表

    local EquipPartStrList = string.split(Properties[1], "|") -- 必填
    local EquipIDStrList = string.split(Properties[2], "|") -- 选填，和EquipLevel冲突
    local EquipLevelStrList = string.split(Properties[3], "|") -- 选填，和EquipID冲突
    
    for i = 1, #EquipPartStrList do
        local Part = tonumber(EquipPartStrList[i])
        self.PartRequirementMap[Part] = {
            ID = tonumber(EquipIDStrList[i]),
            Level = tonumber(EquipLevelStrList[i]),
        }
    end

    self.NpcID = QuestCfg:FindValue(self.QuestID, "FinishNpc")

    --self:UpdateMissList()
end

function TargetEquip:DoStartTarget()
    --self:RegisterEvent(EventID.BagUpdate, self.OnEventBagUpdate)
    --self:RegisterEvent(EventID.EquipUpdate, self.OnEventEquipUpdate)
    --self:RegisterEvent(EventID.UpdateQuestTrack, self.OnEventUpdateQuestTrack)
end

function TargetEquip:DoClearTarget()
end

function TargetEquip:GetNpcID()
    return self.NpcID or 0
end

function TargetEquip:CheckCanFinish()
    -- 这里判断目标是否“已”完成，而非是否“能”完成，用于图标显示
    return self.Status == TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED
end

-- 更新欠缺列表
function TargetEquip:UpdateMissList()
    self.MissItemList = {}

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
            self.MissItemList[Part] = NeedItem
        end
    end
end

-- 检查所有满足穿戴的装备并通知
function TargetEquip:CheckAllAndNofity()
    local AllEquipItem = _G.BagMgr:FilterItemByCondition(function(Item)
        return Item.Attr and Item.Attr.Equip
    end)

    local ProfID = MajorUtil.GetMajorProfID()

    for Part, NeedItem in pairs(self.MissItemList) do
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
function TargetEquip:CheckAndNotify(UpdateItem)
    local ProfID = MajorUtil.GetMajorProfID()
    for _, V in ipairs(UpdateItem) do
        if not V.IsTransfer and V.Type == ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_ADD then --不是转移并且是新获得
            if V.PstItem and V.PstItem.Attr and V.PstItem.Attr.Equip then
                local FindMissItem = self.MissItemList[V.PstItem.Attr.Equip.Part]
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
function TargetEquip:ShowSidebarTaskEquipmentWinPanel(IsForceUpdate)
    if MajorUtil.IsMajorDead() then
        return
    end
    if _G.UIViewMgr:IsViewVisible(UIViewID.SidebarTaskEquipmentWin) then
        if IsForceUpdate then
            --_G.EventMgr:SendEvent(EventID.SidePopUpTaskEquipmentUpdate)
            _G.SidePopUpMgr:RemoveSidePopUp(UIViewID.SidebarTaskEquipmentWin)
        end
        --return
    end

    _G.SidePopUpMgr:AddSidePopUp(ProtoRes.side_popup_type.SIDE_POPUP_CLICK_WEAR, UIViewID.SidebarTaskEquipmentWin, {MissItemList = self.MissItemList}) 
end

---@param UpdateItem CsItemUpdateMsg
function TargetEquip:OnEventBagUpdate(UpdateItem)
    self:CheckAndNotify(UpdateItem)
end

function TargetEquip:OnEventEquipUpdate()
    self:UpdateMissList()
end

function TargetEquip:OnEventUpdateQuestTrack(Param)
    if self.QuestID == Param.QuestID then
        self:CheckAllAndNofity()
    end
end

return TargetEquip