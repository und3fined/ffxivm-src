---
--- Author: sammrli
--- DateTime: 2024-03-27
--- 目标：拥有购买物

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")

local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")

local ItemCfg = require("TableCfg/ItemCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")

local MajorUtil = require("Utils/MajorUtil")
local QuestHelper = require("Game/Quest/QuestHelper")

local ITEM_UPDATE_TYPE = ProtoCS.ITEM_UPDATE_TYPE

local BagMgr = _G.BagMgr
local QuestMgr = _G.QuestMgr

---@class TargetOwnItem
local TargetOwnItem = LuaClass(TargetBase, true)

function TargetOwnItem:Ctor(_, Properties)
    ---@type table<NeedItemData>
    self.NeedItemList = {}--总共需要的列表

    ---@type table<NeedItemData>
    self.MissItemList = {}--欠缺的列表

    ---@type table<uint64, int32>
    self.CollectItemList = {} --发送给服务器物品的GID和对应数量

    local EquipPartList = {}
    local ItemIDList = {}
    local ItemLevelList = {}
    local ItemNumList = {}

    local Num = 0
    local StrList = string.split(Properties[1], "|")
    Num = math.max(Num, #StrList)
    for _,Str in pairs(StrList) do
        table.insert(EquipPartList, tonumber(Str))
    end

    StrList = string.split(Properties[2], "|")
    Num = math.max(Num, #StrList)
    for _,Str in pairs(StrList) do
        table.insert(ItemIDList, tonumber(Str))
    end

    StrList = string.split(Properties[3], "|")
    Num = math.max(Num, #StrList)
    for _,Str in pairs(StrList) do
        table.insert(ItemLevelList, tonumber(Str))
    end

    StrList = string.split(Properties[4], "|")
    Num = math.max(Num, #StrList)
    for _,Str in pairs(StrList) do
        table.insert(ItemNumList, tonumber(Str))
    end

    for i=1, Num do
        ---@class NeedItemData
        ---@field EquipPart number
        ---@field ItemID number
        ---@field ItemLevel number
        ---@field ItemNum number
        local NeedItemData = {
            EquipPart = EquipPartList[i],
            ItemID = ItemIDList[i],
            ItemLevel = ItemLevelList[i],
            ItemNum = ItemNumList[i]
        }
        table.insert(self.NeedItemList, NeedItemData)
    end

    local TargetCfgItem = QuestHelper.GetTargetCfgItem(self.QuestID, self.TargetID)
    if TargetCfgItem then
        self.NpcID = TargetCfgItem.NaviObjID
    end
end

function TargetOwnItem:DoStartTarget()
    self:RegisterEvent(EventID.BagUpdate, self.OnEventBagUpdate)
    self:UpdateMissItemList()
    self:CheckFinish()
    QuestMgr.QuestRegister:RegisterOwnItemData(self)
end

function TargetOwnItem:DoClearTarget()
    QuestMgr.QuestRegister:UnRegisterOwnItemData(self)
end

function TargetOwnItem:GetNpcID()
    return self.NpcID or 0
end

function TargetOwnItem:CheckCanFinish()
    return #self.MissItemList == 0
end

---@param UpdateItem CsItemUpdateMsg
function TargetOwnItem:UpdateBag(UpdateItem)
    if not UpdateItem then
        return
    end
    if #UpdateItem == 2 then
        local PstItem1 = UpdateItem[1].PstItem
        local PstItem2 = UpdateItem[2].PstItem
        if PstItem1 and PstItem2 and PstItem1.GID == PstItem2.GID then --符合穿戴的情况
            return
        end
    end
    for _, v in ipairs(UpdateItem) do
        if v.Type ~= ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_DELETE and not v.IsTransfer then
            if v.PstItem then
                self:CheckAdaptCondition(v.PstItem)
            end
        elseif v.Type == ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_DELETE then
            if v.PstItem then
                if self.CollectItemList[v.PstItem.GID] then
                    --删除了任务目标物品,重新更新miss列表
                    self:UpdateMissItemList()
                    return
                end
            end
        end
	end
end

---是否符合条件，用于检查任务目标是否满足
---@param Item common.Item
function TargetOwnItem:CheckAdaptCondition(Item)
    local IsRemove = false
    for i=#self.MissItemList, 1, -1 do
        local NeedItemData = self.MissItemList[i]
        local NeedNum = NeedItemData.ItemNum or 1
        local OwnNum = 0
        local IsFind = true
        if NeedItemData.ItemID and NeedItemData.ItemID > 0 then
            if Item.ResID ~= NeedItemData.ItemID then
                IsFind = false
            end
        else
            if NeedItemData.EquipPart and NeedItemData.EquipPart > 0 then
                if not Item.Attr or not Item.Attr.Equip or Item.Attr.Equip.Part ~= NeedItemData.EquipPart then
                    IsFind = false
                end
            end
            if NeedItemData.ItemLevel and NeedItemData.ItemLevel > 0 then
                local ItemConfig = ItemCfg:FindCfgByKey(Item.ResID)
                if ItemConfig then
                    if ItemConfig.ItemLevel < NeedItemData.ItemLevel then
                        IsFind = false
                    end
                end
            end
        end
        if IsFind then
            local FindNum = math.min(NeedItemData.ItemNum, Item.Num)
            OwnNum = OwnNum + FindNum
            self.CollectItemList[Item.GID] = FindNum
        end
        if OwnNum >= NeedNum then
            table.remove(self.MissItemList, i)
            IsRemove = true
        end
    end
    if IsRemove then
        _G.EventMgr:SendEvent(EventID.UpdateQuestTargetOwnItem)
    end
end

function TargetOwnItem:CheckFinish()
    if #self.MissItemList == 0 then
        --没有缺失的物品,说明任务目标完成
        _G.QuestMgr:SendFinishTarget(self.QuestID, self.TargetID, nil, self.CollectItemList)
    end
end

function TargetOwnItem:UpdateMissItemList()
    self.MissItemList = {}
    self.CollectItemList = {}
    for i=1,#self.NeedItemList do
        table.insert(self.MissItemList, self.NeedItemList[i])
    end

    local AllItem = {}
    for _, Item in ipairs(BagMgr.ItemList) do
       table.insert(AllItem, Item)
    end
    local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
    if RoleDetail and RoleDetail.Equip and RoleDetail.Equip.EquipList then
        for _, Item in pairs(RoleDetail.Equip.EquipList) do
            if Item.ResID > 0 and Item.GID > 0 then
                table.insert(AllItem, Item)
            end
        end
    end

    for i=#self.MissItemList, 1, -1 do
        local NeedItemData = self.MissItemList[i]
        local NeedNum = NeedItemData.ItemNum or 1
        local OwnNum = 0
        for ItemIndex = 1, #AllItem do
            local IsFind = true
            local Item = AllItem[ItemIndex]
            local IsNeedEquip = false

            if NeedItemData.ItemID and NeedItemData.ItemID > 0 then
                if Item.ResID ~= NeedItemData.ItemID then
                    IsFind = false
                end
            else
                if NeedItemData.EquipPart and NeedItemData.EquipPart > 0 then
                    if not Item.Attr or not Item.Attr.Equip or Item.Attr.Equip.Part ~= NeedItemData.EquipPart then
                        IsFind = false
                    end
                    IsNeedEquip = true
                end
                if NeedItemData.ItemLevel and NeedItemData.ItemLevel > 0 then
                    local ItemConfig = ItemCfg:FindCfgByKey(Item.ResID)
                    if ItemConfig then
                        if ItemConfig.ItemLevel < NeedItemData.ItemLevel then
                            IsFind = false
                        end
                    end
                end
            end

            if IsFind and IsNeedEquip and not _G.EquipmentMgr:CanEquiped(Item.ResID, false, self.ProfID) then
                IsFind = false
            end
            if IsFind then
                local FindNum = math.min(NeedItemData.ItemNum, Item.Num)
                OwnNum = OwnNum + FindNum
                self.CollectItemList[Item.GID] = FindNum --理论上不会同一个GID符合多个条件
            end
            if OwnNum >= NeedNum then
                table.remove(self.MissItemList, i)
                break
            end
        end
    end
end


---是否匹配，用于检测界面标记是否显示，没有数量判断
---@param NeedItemData NeedItemData
---@param ItemResID number
function TargetOwnItem:CheckNeed(NeedItemData, ItemResID)
    local ItemCfgItem = ItemCfg:FindCfgByKey(ItemResID)
    if not ItemCfgItem then
        return false
    end

    -- 去掉数量的判断,如果数量足够,不会加入到miss列表
    --local NeedNum = NeedItemData.ItemNum or 1

    if NeedItemData.EquipPart and NeedItemData.EquipPart > 0 then
        local EquipmentCfgItem = EquipmentCfg:FindCfgByKey(ItemResID)
        if not EquipmentCfgItem or EquipmentCfgItem.Part ~= NeedItemData.EquipPart then
            return false
        end
    end
    if NeedItemData.ItemID and NeedItemData.ItemID > 0 then
        if ItemResID ~= NeedItemData.ItemID then
            return false
        end

        --if _G.BagMgr:GetItemNum(ItemResID) >= NeedNum then --已经拥有,不再需要
        --    return false
        --end
    end
    if NeedItemData.ItemLevel and NeedItemData.ItemLevel > 0 then
        if ItemCfgItem.ItemLevel < NeedItemData.ItemLevel then
            return false
        end


        --local OwnNum = _G.BagMgr:GetItemNumByCondition(function(Item)
        --    local ItemConfig = ItemCfg:FindCfgByKey(Item.ResID)
        --    if ItemConfig then
        --        return ItemConfig.ItemLevel >= NeedItemData.ItemLevel
        --    end
        --    return false
        --end)
        --if OwnNum >= NeedNum then --已经拥有,不再需要
        --    return false
        --end
    end

    -- 职业
    local MajorLevel = math.max(MajorUtil.GetTrueMajorLevel(), 5)
    if not _G.EquipmentMgr:CanEquiped(ItemResID, false, self.ProfID, MajorLevel) then --特殊处理,最低级装备也显示任务标记
        return false
    end

    return true
end

function TargetOwnItem:IsNeed(ResItemID)
    local Length = #self.MissItemList
    if Length == 0 then
        return false
    end

    self.ProfID = MajorUtil.GetMajorProfID()

    for i=1, Length do
        if self:CheckNeed(self.MissItemList[i], ResItemID) then
            return true
        end
    end

    return false
end

---@param UpdateItem CsItemUpdateMsg
function TargetOwnItem:OnEventBagUpdate(UpdateItem)
    self:UpdateBag(UpdateItem)
    self:CheckFinish()
end

return TargetOwnItem