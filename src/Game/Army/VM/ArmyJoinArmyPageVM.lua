---
--- Author: daniel
--- DateTime: 2023-03-08 11:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ArmyEntryVM = require("Game/Army/ItemVM/ArmyEntryVM")
local ArmyShowInfoVM = require("Game/Army/VM/ArmyShowInfoVM")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ArmyMgr = require("Game/Army/ArmyMgr")

---@class ArmyJoinArmyPageVM : UIViewModel
---@field ArmyList any @部队集合
---@field bInfoPage boolean @是否显示部队简介
---@field bEmptyPanel boolean @是否显示空提示面板
---@field bApplyBtn boolean @是否显示申请按钮
local ArmyJoinArmyPageVM = LuaClass(UIViewModel)

--- 部队排序 部队等级>人数>名字>简称(只进行名称排序, 简称不作判断)
---@param A any
---@param B any
---客户端不做排序
-- local ArmySortFunc = function(A, B)
--     if A.ArmyLevel ~= B.ArmyLevel then
--         return A.ArmyLevel > B.ArmyLevel
--     else
--         if A.MemberCount ~= B.MemberCount then
--             return A.MemberCount > B.MemberCount
--         else
--             return A.Name < B.Name
--         end
--     end
-- end

---Ctor
function ArmyJoinArmyPageVM:Ctor()
    self.bInfoPage = nil
    self.bEmptyPanel = nil
    self.bApplyBtn = nil
    self.IsApplyCD = nil
    self.IsFull = nil
    self.CurIsFull = nil
    self.Armys = nil
    self.SaveArmys = nil
    self.SaveSelectedArmyID = nil
    self.IsSearch = nil
    self.RecoverIndex = nil
end

function ArmyJoinArmyPageVM:OnInit()
    self.ArmyList = UIBindableList.New(ArmyEntryVM)
    self.CurSelectedItemData = nil
    self.ArmyShowInfoVM = ArmyShowInfoVM.New()
    self.ArmyShowInfoVM:OnInit()
    self.ArmyShowInfoVM:SetIsShowArmyLeader(true)
    self.IsApplyCD = false
    self.IsFull = false
    self.CurIsFull = false
    self.Armys = {}
    self.SaveArmys = nil
    self.SaveSelectedArmyID = nil
    self.IsSearch = false
    self.RecoverIndex = nil
end

function ArmyJoinArmyPageVM:OnBegin()
    self.ArmyShowInfoVM:OnBegin()
end

function ArmyJoinArmyPageVM:OnEnd()
    self.ArmyShowInfoVM:OnEnd()
    self.ArmyList:Clear()
end

function ArmyJoinArmyPageVM:OnShutdown()
    self.ArmyShowInfoVM:OnShutdown()
    if self.CurSelectedItemData ~= nil then
        self.CurSelectedItemData:SetSelectState(false)
    end
    self.CurSelectedItemData = nil
end

--- 更新部队列表
---@param Armys any 部队列表
function ArmyJoinArmyPageVM:UpdateArmyList(Armys)
    self.Armys = Armys
    for _, ArmyItem in ipairs(self.Armys) do
        ArmyItem.IsJoinItem = true
    end
    self.ArmyList:UpdateByValues(self.Armys)
    self:OnDefaultSelection()
end

--- 合并添加部队列表
function ArmyJoinArmyPageVM:AddArmysToList(Armys)
    for _, ArmyData in ipairs(Armys) do
        local ViewModel = self.ArmyList:Find(function(Element)
            return Element.ID == ArmyData.ID
        end)
        if ViewModel == nil then
            ArmyData.IsJoinItem = true
            table.insert(self.Armys, ArmyData)
            self.ArmyList:AddByValue(ArmyData)
            --self.ArmyList:Sort(ArmySortFunc)
        else
            ViewModel:UpdateVM(ArmyData)
            local Num = ArmyMgr:GetSearchArmyCount()
            ArmyMgr:SetSearchArmyCount(Num - 1)
        end
    end
end

--- 是否显示满员集合
function ArmyJoinArmyPageVM:ShowListByIsFull(IsFull)
    if IsFull ~= self.IsFull then
        self.IsFull = IsFull
    end
end

--- 默认选择
function ArmyJoinArmyPageVM:OnDefaultSelection()
    local Items = self.ArmyList:GetItems()
    local bEmpty = #Items == 0
    self.bEmptyPanel = bEmpty
    self.bInfoPage = not bEmpty
    self.bApplyBtn = not bEmpty
    if #Items > 0 then
        self:OnSelectedItem(nil, Items[1])
    end
end

--- 通过ID设置默认选择
function ArmyJoinArmyPageVM:OnDefaultSelectionByArmyID(ArmyID)
    local Items = self.ArmyList:GetItems()
    local bEmpty = #Items == 0
    self.bEmptyPanel = bEmpty
    self.bInfoPage = not bEmpty
    self.bApplyBtn = not bEmpty
    local ReIndex
    if #Items > 0 then
        local SelectedItem
        for Index, ItemData in ipairs(Items) do
            if ItemData.ID == ArmyID then
                SelectedItem = ItemData
                ReIndex = Index
                break
            end
        end
        self:OnSelectedItem(nil, SelectedItem)
    end
    return ReIndex
end

--- 设置部队选中的VM
function ArmyJoinArmyPageVM:OnSelectedItem(Index, ItemData)
    if ItemData == nil then
        self.bInfoPage = false
        return
    end
    self.bInfoPage = true
    if ItemData ~= self.CurSelectedItemData then
        self.ArmyShowInfoVM:SetData(
            ItemData.LeaderID,
            ItemData.GrandCompanyType,
            ItemData.ID,
            ItemData.RecruitSlogan,
            ItemData.Emblem
        )
        if self.CurSelectedItemData ~= nil then
            if self.CurSelectedItemData:GetSelectState() then
                self.CurSelectedItemData:SetSelectState(false)
            end
        end
        self.CurSelectedItemData = ItemData
        if not ItemData:GetSelectState() then
            ItemData:SetSelectState(true)
        end
        ---校验是否在申请CD
        local ApplyHistories = ItemData.ApplyHistories
        local SelfRoleID = MajorUtil.GetMajorRoleID()
        local CurTime = TimeUtil.GetServerTime()
        self.CurIsFull = ItemData.IsFull
        self.IsApplyCD = false
        for _, ApplyHistory in ipairs(ApplyHistories) do
            if ApplyHistory.RoleID == SelfRoleID then
                local WaitTime = CurTime - ApplyHistory.Time
                local WaitCD = GroupGlobalCfg:FindCfgByKey(ProtoRes.GroupGlobalConfigType.GlobalCfgGroupApplyCD).Value[1]
                if WaitCD then
                    WaitCD = WaitCD * 60
                    if WaitTime < WaitCD then
                        self.IsApplyCD = true
                        break
                    end
                end
            end
        end
    end
end

--- 返回是否在申请CD
function ArmyJoinArmyPageVM:GetIsApplyCD()
    return self.IsApplyCD
end

function ArmyJoinArmyPageVM:GetCurSelectedItemData()
    return self.CurSelectedItemData
end

function ArmyJoinArmyPageVM:SetArmyHideData()
    if self.CurSelectedItemData ~= nil then
        self.CurSelectedItemData:SetSelectState(false)
    end
    self.CurSelectedItemData = nil
end

---保存列表，等搜索返回恢复
function ArmyJoinArmyPageVM:SaveArmyList()
    if self.IsSearch then
        return
    end
    self.IsSearch = true
    self.SaveArmys = table.clone(self.Armys)
    if self.CurSelectedItemData then
        self.SaveSelectedArmyID = self.CurSelectedItemData.ID
    end
end

---搜索返回恢复列表
function ArmyJoinArmyPageVM:RecoverArmyList()
    if self.IsSearch == false then
        self.RecoverIndex = nil
        return
    end
    self.RecoverIndex = nil
    self.IsSearch = false
    if self.SaveArmys then
        self.ArmyList:UpdateByValues(self.SaveArmys)
        if self.SaveSelectedArmyID then
            self.RecoverIndex = self:OnDefaultSelectionByArmyID(self.SaveSelectedArmyID)
        else
            self:OnDefaultSelection()
        end
    end
    self.Armys = self.SaveArmys
    self.SaveArmys = nil
end

---搜索状态
function ArmyJoinArmyPageVM:SetIsSearch(IsSearch)
    self.IsSearch = IsSearch
end

---搜索状态
function ArmyJoinArmyPageVM:GetIsSearch(IsSearch)
    return self.IsSearch
end

---非搜索状态下是否展示满员
function ArmyJoinArmyPageVM:SetIsFull(IsFull)
    self.IsFull = IsFull
end

---非搜索状态下是否展示满员
function ArmyJoinArmyPageVM:GetIsFull()
    return self.IsFull
end

---恢复选中下标
function ArmyJoinArmyPageVM:GetRecoverIndex()
    return self.RecoverIndex
end

function ArmyJoinArmyPageVM:SetIsSearchFullList(IsSearchFull)
    if IsSearchFull then
        self.ArmyList:UpdateByValues(self.Armys)
    else
        --self:SaveSearchArmys()
        local Items = self.ArmyList:GetItems()
        local RemoveIndexs = {}
        for Index, ArmyItemVM in ipairs(Items) do
            if ArmyItemVM.IsFull then
                table.insert(RemoveIndexs, Index)
            end
        end
        for _, RemoveIndex in ipairs(RemoveIndexs) do
            self.ArmyList:RemoveAt(RemoveIndex)
        end
    end
end

---保存列表，等搜索满员勾选恢复
-- function ArmyJoinArmyPageVM:SaveSearchArmys()
--     self.SaveSearchArmys = table.clone(self.Armys)
-- end

---搜索满员勾选恢复
-- function ArmyJoinArmyPageVM:RecoverSearchArmys()
--     if self.SaveSearchArmys then
--         self.ArmyList:UpdateByValues(self.SaveSearchArmys)
--         self.Army = self.SaveSearchArmys
--         self.SaveSearchArmys = nil
--     else

--     end
-- end

return ArmyJoinArmyPageVM
