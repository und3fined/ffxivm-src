---
--- Author: daniel
--- DateTime: 2023-03-13 10:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ArmyEntryVM = require("Game/Army/ItemVM/ArmyEntryVM")
local ArmyShowInfoVM = require("Game/Army/VM/ArmyShowInfoVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

---@class ArmyInvitationPageVM : UIViewModel
---@field ArmyList any @部队集合
---@field bInfoPage boolean @是否显示部队简介
---@field bAccepBtn boolean @是否显示同意按钮
---@field bRefuseBtn boolean @是否显示按钮
local ArmyInvitationPageVM = LuaClass(UIViewModel)

--- 部队排序 部队等级>人数>名字>简称(只进行名称排序, 简称不作判断)
---@param A any
---@param B any
local ArmySortFunc = function(A, B)
    if A.InviteTime and B.InviteTime and A.InviteTime ~= B.InviteTime then
        return A.InviteTime < B.InviteTime
    else
        if A.ArmyLevel and B.ArmyLevel and A.ArmyLevel ~= B.ArmyLevel then
            return A.ArmyLevel > B.ArmyLevel
        else
            if A.MemberCount and B.MemberCount and A.MemberCount ~= B.MemberCount then
                return A.MemberCount > B.MemberCount
            else
                if A.Name and B.Name then
                    return A.Name < B.Name
                else
                    return A.Name
                end
            end
        end
    end
end

---Ctor
function ArmyInvitationPageVM:Ctor()
    self.bInfoPage = nil
    self.bAccepBtn = nil
    self.bRefuseBtn = nil
    self.bEmptyPanel = nil
end

function ArmyInvitationPageVM:OnInit()
    self.CurSelectedArmyID = 0
    self.CurSelectedItemData = nil
    self.ArmyEntryVMList = {}
    self.ArmyShowInfoVM = ArmyShowInfoVM.New()
    self.ArmyList = UIBindableList.New(ArmyEntryVM)
    self.ArmyShowInfoVM:OnInit()
    self.ArmyShowInfoVM:SetIsShowArmyLeader(true)
    self.GrandCompanyType = nil
end

function ArmyInvitationPageVM:OnBegin()
    self.ArmyShowInfoVM:OnBegin()
end

function ArmyInvitationPageVM:OnEnd()
    self.ArmyShowInfoVM:OnEnd()
end

function ArmyInvitationPageVM:OnShutdown()
    self.ArmyShowInfoVM:OnShutdown()
    self.CurSelectedArmyID = 0
    self.CurSelectedItemData = nil
    self.ArmyEntryVMList = nil
    if self.ArmyList then
        self.ArmyList:Clear()
        self.ArmyList = nil
    end
end

--- 更新受邀部队列表
---@param Armys any @部队列表
function ArmyInvitationPageVM:UpdateInviteRoleArmyList(ArmyVMList)
    if nil == ArmyVMList then
        if self.ArmyList then
            self.ArmyList:Clear()
        end
        self:OnDefaultSelection()
        self.bEmptyPanel = true
        return
    end
    for _, VM in ipairs(ArmyVMList or {}) do
        if self.ArmyList == nil then
            self.ArmyList = UIBindableList.New(ArmyEntryVM)
        end
        local bHave = self.ArmyList:Find(function(Element) return Element.ID == VM.ID end)
        if not bHave then
            self.ArmyList:Add(VM)
        end
    end
    if nil ~= self.ArmyList then
        self.ArmyList:Sort(ArmySortFunc)
        self.bEmptyPanel = self.ArmyList:Length() == 0
    else
        self.bEmptyPanel = true
    end
    if not self.bEmptyPanel then
        self:OnDefaultSelection()
    else
        if self.SkipArmyID and self.ErrorTipsID then
            MsgTipsUtil.ShowTipsByID(self.ErrorTipsID)  
            ---清理跳转选中数据
            self:ClearSkipData()
        end
    end
end

--- 默认选择
function ArmyInvitationPageVM:OnDefaultSelection()
    local Items = {}
    if nil ~= self.ArmyList then
        Items = self.ArmyList:GetItems()
    end
    local bHavInvite = #Items > 0
    self.bAccepBtn = bHavInvite
    self.bRefuseBtn = bHavInvite
    self.bInfoPage = bHavInvite
    if bHavInvite then
        ---选中跳转部队
        if self.SkipArmyID then
            self:SetCurSelectedItemByArmyID(self.SkipArmyID, self.ErrorTipsID)
        elseif nil == self.CurSelectedItemData then
            ---无选中，默认选中第一个
            self:OnSelectedItem(nil, Items[1])
        else
            self:SetCurSelectedItemByArmyID(self.CurSelectedItemData.ID)
        end
    else
        if self.SkipArmyID and self.ErrorTipsID then
            MsgTipsUtil.ShowTipsByID(self.ErrorTipsID)  
        end
    end
    ---清理跳转选中数据
    self:ClearSkipData()
end

--- 删除部队
---@param ArmyIDs any @移除的部队Id列表
function ArmyInvitationPageVM:RemoveArmyDataByIDs(ArmyIDs)
    if nil == self.ArmyList then
        return
    end
    for _, ArmyID in ipairs(ArmyIDs) do
        local ItemData =
            self.ArmyList:Find(
            function(Element)
                return Element.ID == ArmyID
            end
        )
        if ItemData then
            ItemData:SetSelectState(false)
        end
        if nil ~= self.CurSelectedItemData and ItemData == self.CurSelectedItemData then
            self.CurSelectedItemData = nil
        end
        self.ArmyList:Remove(ItemData)
    end
    local Items = self.ArmyList:GetItems()
    if #Items > 0 then
        self:OnDefaultSelection()
    else
        self.bInfoPage = false
        self.bAccepBtn = false
        self.bRefuseBtn = false
    end
end

--- 设置部队选中的VM
function ArmyInvitationPageVM:OnSelectedItem(Index, ItemData)
    if ItemData ~= self.CurSelectedItemData then
        self.ArmyShowInfoVM:SetData(
            ItemData.LeaderID,
            ItemData.GrandCompanyType,
            ItemData.ID,
            ItemData.RecruitSlogan,
            ItemData.Emblem
        )
        if self.CurSelectedItemData ~= nil then
            self.CurSelectedItemData:SetSelectState(false)
        end
        self.CurSelectedItemData = ItemData
        ItemData:SetSelectState(true)
    end
    ---同一个部队也可能换国防联军
    self.GrandCompanyType = ItemData.GrandCompanyType
end

function ArmyInvitationPageVM:SetArmyHideData()
    if self.CurSelectedItemData ~= nil then
        self.CurSelectedItemData:SetSelectState(false)
    end
    self.CurSelectedItemData = nil
end

function ArmyInvitationPageVM:GetCurSelectedItemData()
    return self.CurSelectedItemData
end

function ArmyInvitationPageVM:SetCurSelectedItemByArmyID(ArmyID, ErrorTipsID)
    local Items
    if nil ~= self.ArmyList then
        Items = self.ArmyList:GetItems()
    else
        return
    end
    local SelectedItem
    ---有选中，默认选中之前的选中
    for _, Item in ipairs(Items) do
        if Item.ID == ArmyID then
            SelectedItem = Item
            break
        end
    end
    if #Items < 1 then
        if ErrorTipsID then
            MsgTipsUtil.ShowTipsByID(ErrorTipsID)  
        end
        return
    end
    if SelectedItem then
        --self.CurSelectedItemData = nil
        self:OnSelectedItem(nil, SelectedItem)
    elseif Items[1] then
        self:OnSelectedItem(nil, Items[1])
    end
end

function ArmyInvitationPageVM:SetInviteSkipArmyID(ArmyID, ErrorTipsID)
    self.SkipArmyID = ArmyID
    self.ErrorTipsID = ErrorTipsID
end

function ArmyInvitationPageVM:ClearSkipData()
    self.SkipArmyID = nil
    self.ErrorTipsID = nil
end

return ArmyInvitationPageVM
