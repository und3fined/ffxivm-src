---
--- Author: daniel
--- DateTime: 2023-03-13 16:34
--- Description:分组权限编辑
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local ArmyDefine = require("Game/Army/ArmyDefine")
local GroupPermissionCfg = require("TableCfg/GroupPermissionCfg")
local GroupStoreUitextCfg = require("TableCfg/GroupStoreUitextCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")

local ArmyMemPowerEditItemVM = require("Game/Army/ItemVM/ArmyMemPowerEditItemVM")
local ArmyGroupingIconItemVM = require("Game/Army/ItemVM/ArmyGroupingIconItemVM")
local ArmyMemberClassInfoEditItemVM = require("Game/Army/ItemVM/ArmyMemberClassInfoEditItemVM")
local ArmyBatchGroupItemVM = require("Game/Army/ItemVM/ArmyBatchGroupItemVM")

local ProtoRes = require("Protocol/ProtoRes")
local GroupPermissionClass = ProtoRes.GroupPermissionClass
local GroupStoreCfg = require("TableCfg/GroupStoreCfg")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ProtoCommon = require("Protocol/ProtoCommon")
local GroupMemberCategoryCfg = require("TableCfg/GroupMemberCategoryCfg")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local TipsUtil = require("Utils/TipsUtil")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ArmyMgr

---@class ArmyMemEditPowerPageVM : UIViewModel
---@field ShowIndex number @ShowIndex
---@field CurCategoryName string @当前选中分组名称
---@field InfoTitle string @页签名称
---@field EditList any @编辑列表
---@field ClassIcon string @分组图标
---@field PermssionPageIndex number @Index
---@field CurCategoryNum number @当前阶级数量
---@field CurCategoryIconID number @当前阶级IconID
---@field CurPermisstionTypes number @当前阶级权限列表
---@field IsSaveBtnEnabled number @确认保存按钮状态
local ArmyMemEditPowerPageVM = LuaClass(UIViewModel)

--- 部队成员排序 在线>名字
---@param A any
---@param B any
local ArmyMemberSortFunc = function(A, B)
    if A.bOnline == B.bOnline then
        return A.RoleName > B.RoleName
    else
        return A.bOnline
    end
end

local MenuListData = 
{
    InfoPanel = 1,
    PermisstionPanel = 2,
    MemberPanel = 3,
}

local MaxCategoryNum 

---Ctor
function ArmyMemEditPowerPageVM:Ctor()
    self.ShowIndex = nil
    self.CurCategoryName = nil
    self.InfoTitle = nil
    self.CategoryList = nil
    self.EditList = nil
    self.ClassIcon = nil
    self.InternDesc = nil
    self.SelectedCategoryIndex = nil
    self.CurCategoryName = nil
    self.CurCategoryNum = nil
    self.bInfoPanel = nil
    self.bPermisstionPanel = nil
    self.bMemberPanel = nil
    self.CurCategoryIconID = nil
    self.CurPermisstionTypes =nil
    self.CurMemberList = nil
    self.CurCategoryID = nil
    self.IsSaveBtnEnabled = nil
    self.CategoryIconList = nil
    self.NameChangeList = nil
    self.IconChangeList = nil
    self.PermisstionChangeList = nil
    self.InfoEditPermisstionList = nil
    self.StorePermisstionList = nil
    self.MemberPermisstionList = nil
    self.SelectedMemberList = nil
    self.MemberEditCategoryList = nil
    self.BatchStr = nil
    self.BatchBtnEnable = nil
    self.UpdataMenuList = nil
    self.BGIcon = nil
    self.GrandCompanyType = nil
    self.IsDeleteBtnEnabled = nil
    self.IsAllMemberSelected = nil
    self.OldCategoryNum = nil
    self.DelCategories = nil
    self.ErrorNameList = nil
    self.BGMaskColor = nil
    self.SaveErrorStr = nil
    self.IsNoMember = nil
end

function ArmyMemEditPowerPageVM:OnInit()
    self.Categories = nil
    self.ChangedCategoryIDs = nil
    self.CategoryList = UIBindableList.New(ArmyMemPowerEditItemVM)
    ArmyMgr = require("Game/Army/ArmyMgr")
    self.InternDesc = ""
    self.BatchStr = ""
    self.BatchBtnEnable = false
    self.SelectedCategoryIndex = 1
    self.CategoryIconList = UIBindableList.New(ArmyGroupingIconItemVM)
    self.ErrorNameList = {}
    self.NameChangeList = {}
    self.IconChangeList = {}
    self.PermisstionChangeList = {}
    self.SelectedMemberList = {}
    self.InfoEditPermisstionList = UIBindableList.New(ArmyMemberClassInfoEditItemVM)
    self.StorePermisstionList = UIBindableList.New(ArmyMemberClassInfoEditItemVM)
    self.MemberPermisstionList = UIBindableList.New(ArmyMemberClassInfoEditItemVM)
    self.MemberEditCategoryList = UIBindableList.New(ArmyBatchGroupItemVM)
    self.UpdataMenuList = false
    self.BGIcon = ""
    self.GrandCompanyType = 0
    self.IsAllMemberSelected = false
    self.DelCategories = {}
    MaxCategoryNum = GroupGlobalCfg:GetValueByType(ProtoRes.GroupGlobalConfigType.GroupGlobalConfigType_MaxMemberCategoryCount)
    self.SaveErrorStr = ""
end

function ArmyMemEditPowerPageVM:InitPermisstionList()
    	---排查ios界面显示失败bug
	    _G.FLOG_INFO("ArmyMemEditPowerPageVM:InitPermisstionList()")
        local InfoEditPermisstionTypes = {}
        local StorePermisstionTypes = {}
        local MemberPermisstionTypes = {}
        --- 权限读表初始化设置
        local PermssionCfg = GroupPermissionCfg:GetAllPermissionCfg()
        --- 金币储物柜显示走正常处理，和其他储物柜不一样
        local GoldItemData
        for _, PermisstionData in ipairs(PermssionCfg) do
            local PermisstionDataTemp = {Icon = PermisstionData.Icon, Desc = PermisstionData.Desc, Type = PermisstionData.Type, Class = PermisstionData.Class, Important = PermisstionData.Important}
            local ItemData = {}
            ItemData.bCanEdit = true
            ItemData.PermssionData = PermisstionDataTemp
            if PermisstionDataTemp.Class  == GroupPermissionClass.GRAND_PERMISSION_CLASS_InfoEdit then
                table.insert(InfoEditPermisstionTypes, ItemData)
            elseif PermisstionDataTemp.Class  == GroupPermissionClass.GRAND_PERMISSION_CLASS_STORE then
                ----仓库名特殊处理
                local StoreCfg = GroupStoreCfg:FindCfgByUsePermissionId(PermisstionData.Type)
                if StoreCfg then
                    local StoreIndex = StoreCfg.ID
                    local DescStr
                    if StoreIndex == nil then
                        StoreIndex = PermisstionData.Type % 100
                    end
                    local StoreName
                    if StoreIndex then
                        StoreName = ArmyMgr:GetStoreName(StoreIndex)
                    end
                    if nil == StoreName or StoreName == "" then
                        StoreName = StoreCfg.GroupDefaultName
                    end
                    DescStr = StoreName
                    PermisstionDataTemp.Desc = DescStr
                    --- 未解锁的不显示
                    --- 权限收敛，不用解散等级，按等级解锁数量，ID代表第几个仓库
                    if ArmyMgr:GetArmyStoreMaxCount() >= StoreCfg.ID then
                        table.insert(StorePermisstionTypes, ItemData)
                    end
                elseif PermisstionDataTemp.Type == ProtoRes.GroupPermissionType.GroupPermissionTypeMoneyBag then
                    ---金币储物柜需要放到最后
                    GoldItemData = ItemData
                end
            elseif PermisstionDataTemp.Class  == GroupPermissionClass.GRAND_PERMISSION_CLASS_MemberManage then
                table.insert(MemberPermisstionTypes, ItemData)
            end
        end
        if GoldItemData then
            ---金币储物柜需要放到最后
            table.insert(StorePermisstionTypes, GoldItemData)
        end
        self.InfoEditPermisstionList:UpdateByValues(InfoEditPermisstionTypes)
        self.StorePermisstionList:UpdateByValues(StorePermisstionTypes)
        self.MemberPermisstionList:UpdateByValues(MemberPermisstionTypes)
end

function ArmyMemEditPowerPageVM:OnBegin()
end

function ArmyMemEditPowerPageVM:OnEnd()
end

function ArmyMemEditPowerPageVM:OnShutdown()
    self.CategoryList:Clear()
    --self.CategoryList = nil
end

function ArmyMemEditPowerPageVM:ClearData()
    self:ClearChangeList()
    self.SelectedCategoryIndex = nil
end

function ArmyMemEditPowerPageVM:UpdateCategoryListByCategories(Categories)
    self.Categories = table.deepcopy(Categories)
    --- 清空缓存
    self.ChangedCategoryIDs = {}

    local CategoryList = self.CategoryList

    CategoryList:UpdateByValues(Categories, ArmyDefine.ArmyCategorySortFunc)

    -- if self.SelectedCategoryIndex == nil then
    --     local Items = CategoryList:GetItems()
    --     if #Items > 0 then
    --         self:ShowBasicData(1, Items[1])
    --     end
    -- end
end

function ArmyMemEditPowerPageVM:ClearChangeList()
    self.NameChangeList = {}
    self.IconChangeList = {}
    self.PermisstionChangeList = {}
    self.ErrorNameList = {}
    self.IsCategoryChange = false
    self:SetIsSaveBtnEnabled(false)
    -- LSTR string:没有需要保存的变更
    self.SaveErrorStr = LSTR(910172)
end

function ArmyMemEditPowerPageVM:UpdateInfo()
    local Categories = ArmyMgr:GetArmyCategories()
    self:UpdataEditCategoryPanelData(Categories, false)
end

function ArmyMemEditPowerPageVM:UpdataEditCategoryPanelData(Categories, UpdataMenuList)
    local SelfCategoryData = ArmyMgr:GetSelfCategoryData()
    self.OldCategoryNum = #Categories
    ---保存一份独立的阶级信息
    self.Categories = {}
    for Index, CategoryData in ipairs(Categories) do
        local NewCategoryData = table.clone(CategoryData)
        NewCategoryData.ShowIndex = Index
        NewCategoryData.PermisstionTypes = table.clone(CategoryData.PermisstionTypes)
        if SelfCategoryData and SelfCategoryData.ID == NewCategoryData.ID and nil == self.SelectedCategoryIndex then
            self.SelectedCategoryIndex = Index
        end
        table.insert(self.Categories, NewCategoryData)
    end
    ---保存一下初始数据用于对比
    self:OldDataSave()
    self:ClearChangeList()
    self:UpdateCurCategoryNum(#self.Categories)
    self:UpdateCategoryList()
    local CategoryItemData = self.CategoryList:Get(self.SelectedCategoryIndex)
    if CategoryItemData then
        CategoryItemData.bSelected = true
    end
    --self:OnCategorySelectChanged(self.SelectedCategoryIndex, self.Categories[self.SelectedCategoryIndex])
    ---处理非点击选中更新，页签更新问题
    if UpdataMenuList then
        self:OnCategorySelectChanged(self.SelectedCategoryIndex, self.Categories[self.SelectedCategoryIndex])
    end
    self.UpdataMenuList = UpdataMenuList
end

function ArmyMemEditPowerPageVM:OldDataSave()
    local Len = #self.Categories
    for i = 1, Len do
        self.Categories[i].OldPermisstionTypes = table.clone(self.Categories[i].PermisstionTypes)
        self.Categories[i].OldName = self.Categories[i].Name
        self.Categories[i].OldIconID = self.Categories[i].IconID
    end
end

function ArmyMemEditPowerPageVM:UpdateCurCategoryNum(Num)
    self.CurCategoryNum = Num
end

function ArmyMemEditPowerPageVM:RemoveCategoryByID(ID)
    self.CategoryList:RemoveByPredicate(function(Element)
        return Element.ID == ID
    end)
end

function ArmyMemEditPowerPageVM:UpdateCategoryList()
    if self.CategoryList == nil then
        return
    end
    self.CategoryList:UpdateByValues(self.Categories)
    if self.CurCategoryNum >= MaxCategoryNum then
        return
    end
     ---添加新增按钮
     local AddItem = 
     {
         ID = -1,
         IconID = 1,
         Name = "",
         ShowIndex = 999,
         IsAddItem = true,
     }
     self.CategoryList:AddByValue(AddItem)
end

function ArmyMemEditPowerPageVM:OpenArmyPanel()
    ArmyMgr:OpenArmyMainPanel()
end

---阶级选项变更处理
function ArmyMemEditPowerPageVM:OnCategorySelectChanged(Index, ItemData, ItemView)
    if ItemData.ID == -1 then
        --点击到新增
        return
    end
    ---重名和空文本不会输入到分组名数据里，切换时恢复下错误状态
    local OldIndex = self.SelectedCategoryIndex
    local OldData = self.Categories[OldIndex]
	-- LSTR string:未命名新分组
	if OldData.Name ~= "" and OldData.Name ~= LSTR(910158) then
        self:SetIsErrorName(false, OldData.ID)
    end
    --- 不是部队长和满足最小分组配置
    local MinNum = ArmyMgr:GetDefaultCategoryNum()
    if ItemData.ID == ProtoCommon.group_category_type.GROUP_CATEGORY_TYPE_PRESIDENT or self.CurCategoryNum <= MinNum then
        self.IsDeleteBtnEnabled = false
    else
        self.IsDeleteBtnEnabled = true
    end
    if self.SelectedCategoryIndex ~= 0 and self.SelectedCategoryIndex ~= Index then
        local OldeSelectedItemData = self.CategoryList:Get(self.SelectedCategoryIndex)
        OldeSelectedItemData:SetIsSelected(false)
    end
    if ItemData.SetIsSelected then
        ItemData:SetIsSelected(true)
    end
    self.SelectedCategoryIndex = Index
    self.CurCategoryID = ItemData.ID
    self:UpdateRightPanelData(self.SelectedCategoryIndex)
end

---阶级图标变更处理
function ArmyMemEditPowerPageVM:OnCategoryIconSelectChanged(Index, ItemData, ItemView)
    local SelectedIndex = self:GetSelectedCategoryIndex()
    if ItemData.ID == self.Categories[SelectedIndex].IconID then
        ItemData.bSelected = true
    else
        local Items = self.CategoryIconList:GetItems()
        local OldIconItem
        for _, Item in ipairs(Items) do
            if self.Categories[SelectedIndex].IconID == Item.ID then
                OldIconItem = Item
            end
        end
        if OldIconItem ~= nil then
            OldIconItem.bSelected = false
        end
        ItemData.bSelected = true
        if ItemData.bUsed then
            if OldIconItem ~= nil then
                OldIconItem.bUsed = true
            end
            ItemData.bUsed = false
            local SwitchIndex 
            for Index, CategoryDat in ipairs(self.Categories) do
                if CategoryDat.IconID == ItemData.ID then
                    SwitchIndex = Index
                end
            end
            self.Categories[SelectedIndex].IconID = ItemData.ID
            if SwitchIndex and OldIconItem then
                self.Categories[SwitchIndex].IconID = OldIconItem.ID
            end
            if self.CategoryList then
                local SelectedItemVM = self.CategoryList:Get(SelectedIndex)
                SelectedItemVM:SetIcon(ItemData.ID)
                if SwitchIndex then
                    local SwitchItemVM = self.CategoryList:Get(SwitchIndex)
                    if SwitchItemVM and OldIconItem then
                        SwitchItemVM:SetIcon(OldIconItem.ID)
                    end
                end
            end
        else
            self.Categories[SelectedIndex].IconID = ItemData.ID
            if self.CategoryList then
                local SelectedItemVM = self.CategoryList:Get(SelectedIndex)
                SelectedItemVM:SetIcon(ItemData.ID)
            end
        end
        self:CheckIconChange(SelectedIndex)
        --self:UpdateCategoryList()

    end
end

--- 更新右边界面显示数据
function ArmyMemEditPowerPageVM:UpdateRightPanelData(SelectedCategoryIndex)
    if nil == self.Categories[SelectedCategoryIndex] then
        return
    end
    self.CurCategoryName = self.Categories[SelectedCategoryIndex].Name
    self.CurCategoryIconID = self.Categories[SelectedCategoryIndex].IconID
    self.CurPermisstionTypes = self.Categories[SelectedCategoryIndex].PermisstionTypes
    self:UpdateCategoryIconList(SelectedCategoryIndex)
    self:UpdatePermisstionList(SelectedCategoryIndex)
    self:UpdateMemberList(SelectedCategoryIndex)
    --- 清空成员选中数据
    --self.IsAllMemberSelected = false
    self.SelectedMemberList = {}
    --- 当没有成员时，是否可以全选，目前默认可以，所以不在UpdataAllSelectedData对0做特殊处理，在这里清除一下全选
    self:UpdataAllSelectedData()
    self.IsAllMemberSelected = false
end

function ArmyMemEditPowerPageVM:UpdataEditCategoryPanelMemberData()
    self:UpdateMemberList(self.SelectedCategoryIndex)
    self:UpdataBatchStr()
    --- 清空成员选中数据
    self.SelectedMemberList = {}
    --self.IsAllMemberSelected = self:GetIsAllMemberSelected()
end

---- 出错时更新成员数据（转移阶级时，成员已经不存在）
function ArmyMemEditPowerPageVM:UpdataMemberDataAndSaveCheckItem(Memberlist, CategoryID)
    if self.CurCategoryID ~= CategoryID then
        return
    end
    self.CurMemberList = Memberlist
    local MemberItems = self.MemberEditCategoryList:GetItems()
    local CheckedList = {}
    self.SelectedMemberList = {}
    for _, Item in ipairs(MemberItems) do
        if Item.bChecked then
            table.insert(CheckedList, Item.RoleID)
        end
    end
    self:UpdateMemberList(self.SelectedCategoryIndex ,Memberlist, CheckedList)
end

---设置Iconlist
function ArmyMemEditPowerPageVM:UpdateCategoryIconList(SelectedCategoryIndex)
    local IconCfg = GroupMemberCategoryCfg:GetAllCategoryCfg()
    local IconList = {}
    for _, IconData in ipairs(IconCfg) do
        local IconItem = {}
        IconItem.ID = IconData.ID
        IconItem.Icon = IconData.Icon
        IconItem.bUsed = false
        if IconItem.ID == self.Categories[SelectedCategoryIndex].IconID then
            IconItem.bSelected = true
        else
            IconItem.bSelected = false
        end
        for _, CategoryData in ipairs(self.Categories) do
            if IconItem.ID == CategoryData.IconID then
                if CategoryData.ID ~= self.Categories[SelectedCategoryIndex].ID then
                    IconItem.bUsed = true
                    break
                end
            end
        end
        table.insert(IconList, IconItem)
    end
    self.CategoryIconList:UpdateByValues(IconList)
end

---设置权限列表
function ArmyMemEditPowerPageVM:UpdatePermisstionList(SelectedCategoryIndex)
    local InfoEditPermisstionTypes = self.InfoEditPermisstionList:GetItems()
    local StorePermisstionTypes = self.StorePermisstionList:GetItems()
    local MemberPermisstionTypes = self.MemberPermisstionList:GetItems()
    self:SetPermisstionTypesBaseState(SelectedCategoryIndex, InfoEditPermisstionTypes)
    self:SetPermisstionTypesBaseState(SelectedCategoryIndex, StorePermisstionTypes)
    self:SetPermisstionTypesBaseState(SelectedCategoryIndex, MemberPermisstionTypes)

    ---部队长权限不可变更
    if self.CurCategoryID == ProtoCommon.group_category_type.GROUP_CATEGORY_TYPE_PRESIDENT then
        return
    end

    local PermisstionTypes =  self.Categories[SelectedCategoryIndex].PermisstionTypes
    for _, PermisstionType in pairs(PermisstionTypes) do
        local PermisstionData = GroupPermissionCfg:GetPermissionByType(PermisstionType) 
        local PermisstionItemList
        if PermisstionData.Class  == GroupPermissionClass.GRAND_PERMISSION_CLASS_InfoEdit then
            PermisstionItemList = InfoEditPermisstionTypes
        elseif PermisstionData.Class  == GroupPermissionClass.GRAND_PERMISSION_CLASS_STORE then
            PermisstionItemList = StorePermisstionTypes
        elseif PermisstionData.Class  == GroupPermissionClass.GRAND_PERMISSION_CLASS_MemberManage then
            PermisstionItemList = MemberPermisstionTypes
        end
        for _, PermisstionItem in ipairs(PermisstionItemList) do
            --PermisstionItem.bChecked = false
            if PermisstionItem.PermssionData.Type == PermisstionType then
                PermisstionItem.bChecked = true
            end
        end
    end
end

---更新成员列表
function ArmyMemEditPowerPageVM:UpdateMemberList(SelectedCategoryIndex, MemberList, CheckedList)

    self.CurMemberList = MemberList or ArmyMgr:GetArmyMembersByCategotyID(self.Categories[SelectedCategoryIndex].ID)
    self.MemberEditCategoryList:Clear()
    local Members = self.CurMemberList
    if Members == nil then
        self.IsNoMember = true
    elseif Members and #Members == 0 then
        self.IsNoMember = true
    else
        self.IsNoMember = false
    end

    local RoleIDs = {}
    for _, v in ipairs(Members) do
        local RoleSimData = v.Simple
        table.insert(RoleIDs, RoleSimData.RoleID)
    end
    RoleInfoMgr:QueryRoleSimples(RoleIDs, function()
        for _, RoleID in ipairs(RoleIDs) do
            local Role = RoleInfoMgr:FindRoleVM(RoleID, true)
            local IsChecked = false
            if CheckedList then
                for _, ID in ipairs(CheckedList) do
                    if RoleID == ID then
                        IsChecked = true
                        break
                    end
                end
            end
            -- 特殊处理，屏蔽掉无效玩家
            if Role.Name ~= "" then
                self:AddMemVMByMemberData(RoleID, Role, IsChecked)
            end
        end
        self.MemberEditCategoryList:Sort(ArmyMemberSortFunc)
    end, nil, false)
end

--- 一个一个加，所有角色信息没法一次拿到
function ArmyMemEditPowerPageVM:AddMemVMByMemberData(RoleID, RoleVM, IsChecked)
    if IsChecked then
        self:AddMembertoSelectedMemberList(RoleID)
        self:UpdataAllSelectedData()
    end
    local MemberVM = self.MemberEditCategoryList:Find(function(Element)
        return Element.RoleID == RoleID
    end)
    local MemberData = self:CreateMemberData(RoleID, RoleVM, IsChecked)
    if MemberVM ~= nil then
        MemberVM:UpdateVM(MemberData)
    else
        self.MemberEditCategoryList:AddByValue(MemberData)
    end
        ---如果只有一项的，多添加一个假Item防止拉伸
    local Length = self.MemberEditCategoryList:Length()
    if Length == 1 then
        local EmptyMemberData
        if MemberData then
            EmptyMemberData = table.clone(MemberData)
            if MemberData.Simple then
                EmptyMemberData.Simple = table.clone(MemberData.Simple)
            else
                EmptyMemberData.Simple = {}
            end
        else
            EmptyMemberData = {}
            EmptyMemberData.Simple = {}
        end
        EmptyMemberData.Simple.RoleID = 0
        EmptyMemberData.IsEmpty = true
        self.MemberEditCategoryList:AddByValue(EmptyMemberData)
    else
        local MemberVM = self.MemberEditCategoryList:Find(function(Element)
            return Element.IsEmpty == true
        end)
        self.MemberEditCategoryList:Remove(MemberVM)
    end
end

function ArmyMemEditPowerPageVM:CreateMemberData(RoleID, RoleVM, IsChecked)
    local MemberData 
    if self.CurMemberList then
        local CloneData = table.find_by_predicate(self.CurMemberList, function(Element)
            return Element.Simple.RoleID == RoleID
        end)
        if CloneData then
            MemberData = table.clone(CloneData)
        else
            MemberData = {}
        end
    else
        MemberData = {}
    end
    MemberData.RoleName = RoleVM.Name
    MemberData.MapResName = RoleVM.MapResName
    MemberData.IsOnline = RoleVM.IsOnline
    MemberData.Level = RoleVM.Level
    MemberData.OnlineStatusIcon = RoleVM.OnlineStatusIcon
    MemberData.OnClickedSwitchCategory = self.OnClickedSwitchCategory
    MemberData.LogoutTime = RoleVM.LogoutTime
    if IsChecked then
        MemberData.bChecked = IsChecked
    else
        MemberData.bChecked = false
    end
    MemberData.Owner = self
    local ProfName = RoleInitCfg:FindRoleInitProfName(RoleVM.Prof)
    local ProfIcon = RoleInitCfg:FindRoleInitProfIcon(RoleVM.Prof)
    if ProfName then
        MemberData.ProfName = ProfName
    else
        MemberData.ProfName = ""
    end
    if ProfIcon then
        MemberData.ProfIcon = ProfIcon
    else
        MemberData.ProfIcon = ""
    end
    return MemberData
end

function ArmyMemEditPowerPageVM:SetPermisstionTypesBaseState(SelectedCategoryIndex, PermisstionTypes)
    for _, PermisstionItem in ipairs(PermisstionTypes) do
        --- 部队长有所有权限
        if self.CurCategoryID == ProtoCommon.group_category_type.GROUP_CATEGORY_TYPE_PRESIDENT then
            PermisstionItem.bChecked = true
        else
            PermisstionItem.bChecked = false
        end
       ---部队长权限不可变更
        if self.CurCategoryID == ProtoCommon.group_category_type.GROUP_CATEGORY_TYPE_PRESIDENT then
            PermisstionItem.bCanEdit = false
        else
            PermisstionItem.bCanEdit = true
        end
    end
end

--- 设置右侧显示
function ArmyMemEditPowerPageVM:SetRightPanelShow(Index)
    self.bInfoPanel = false
    self.bPermisstionPanel = false
    self.bMemberPanel = false
    if Index == MenuListData.InfoPanel then
        self.bInfoPanel = true
    elseif Index == MenuListData.PermisstionPanel then
        self.bPermisstionPanel = true
    elseif Index == MenuListData.MemberPanel then
        self.bMemberPanel = true
    end
end
---------------------------------- Get Data start --------------------------------------------
function ArmyMemEditPowerPageVM:GetCurCategoryName()
    return self.CurCategoryName
end

function ArmyMemEditPowerPageVM:GetCurCategoryID()
    return self.CurCategoryID
end

function ArmyMemEditPowerPageVM:GetSelectedCategoryIndex()
    return self.SelectedCategoryIndex
end

function ArmyMemEditPowerPageVM:GetCurCategories()
    return self.Categories
end

function ArmyMemEditPowerPageVM:GetCurCategoryNum()
    return self.CurCategoryNum
end

function ArmyMemEditPowerPageVM:GetSelectedMemberList()
    return self.SelectedMemberList
end

function ArmyMemEditPowerPageVM:GetCurMemberList()
    return self.CurMemberList
end

function ArmyMemEditPowerPageVM:GetSaveErrorStr()
    return self.SaveErrorStr
end

function ArmyMemEditPowerPageVM:GetIsSaveBtnEnabled()
    return self.IsSaveBtnEnabled
end
---------------------------------- Get Data end ----------------------------------------------

function ArmyMemEditPowerPageVM:SetSelectedCategoryIndex(Index)
    self.SelectedCategoryIndex = Index
end

function ArmyMemEditPowerPageVM:CheckErrorName(CategoryIndex)
    local IsErrorName = self.Categories[CategoryIndex].Name == ""
    self:SetIsErrorName(IsErrorName, self.Categories[CategoryIndex].ID, true)
end

function ArmyMemEditPowerPageVM:SetIsErrorName(IsErrorName, CategoryID, IsEmpty)
    local SelectedID = CategoryID or self:GetCurCategoryID()
    if IsErrorName then
        if IsEmpty then
            -- LSTR string:分组名不能为空
            self.SaveErrorStr = LSTR(910061)
        else
            -- LSTR string:已有分组名
            self.SaveErrorStr = LSTR(910109)
        end
        for _, ErrorID in pairs(self.ErrorNameList) do
            if SelectedID == ErrorID then
                return
            end
        end
        table.insert(self.ErrorNameList, SelectedID)
    else
        local DelKey
        for Key, ErrorID in pairs(self.ErrorNameList) do
            if SelectedID == ErrorID then
                DelKey = Key
            end
        end
        if DelKey then
            table.remove(self.ErrorNameList, DelKey)
        end
    end
    self:CheckDataChange()
end

function ArmyMemEditPowerPageVM:SetIsNameChange(IsNameChange, CategoryIID)
    local SelectedID = CategoryIID or self:GetCurCategoryID()
    if IsNameChange then
        for _, ChangeID in pairs(self.NameChangeList) do
            if SelectedID == ChangeID then
                return
            end
        end
        table.insert(self.NameChangeList, SelectedID)
    else
        local DelKey
        for Key, ChangeID in pairs(self.NameChangeList) do
            if SelectedID == ChangeID then
                DelKey = Key
            end
        end
        if DelKey then
            table.remove(self.NameChangeList, DelKey)
        end
        --self.NameChangeList[DelKey] = nil
    end
    self:CheckDataChange()
end

function ArmyMemEditPowerPageVM:CheckIconChange(CategoryIndex)
    local IconID = self.Categories[CategoryIndex].IconID
    local OldIconID = self.Categories[CategoryIndex].OldIconID
    self:SetIsIconChange(IconID ~= OldIconID, self.Categories[CategoryIndex].ID)
end

function ArmyMemEditPowerPageVM:SetIsIconChange(IsIconChange, CategoryIID)
    local SelectedID = CategoryIID or self:GetCurCategoryID()
    if IsIconChange then
        for _, ChangeID in pairs(self.IconChangeList) do
            if SelectedID == ChangeID then
                return
            end
        end
        table.insert(self.IconChangeList, SelectedID)
    else
        local DelKey
        for Key, ChangeID in pairs(self.IconChangeList) do
            if SelectedID == ChangeID then
                DelKey = Key
                break
            end
        end
        --self.IconChangeList[DelKey] = nil
        if DelKey then
            table.remove(self.IconChangeList, DelKey)
        end
    end
    self:CheckDataChange()
end

---检查变更
function ArmyMemEditPowerPageVM:CheckPermisstionChange(CategoryIndex)
    local PermisstionTypes = self.Categories[CategoryIndex].PermisstionTypes
    local OldPermisstionTypes = self.Categories[CategoryIndex].OldPermisstionTypes
    local Len = 0
    local OldLen = 0
    if PermisstionTypes then
        Len = table.length(PermisstionTypes)
    end
    if OldPermisstionTypes then
        OldLen = table.length(OldPermisstionTypes)
    end
    if Len ~= OldLen then
        self:SetIsPermisstionChange(true, self.Categories[CategoryIndex].ID)
        return true
    end
    for _, PermisstionType in pairs(PermisstionTypes) do
        local IsExist = false
        for _, OldPermisstionType in pairs(OldPermisstionTypes) do
            if PermisstionType == OldPermisstionType then
                IsExist = true
                break
            end
        end
        if not IsExist then
            self:SetIsPermisstionChange(true, self.Categories[CategoryIndex].ID)
            return true
        end
    end
    self:SetIsPermisstionChange(false, self.Categories[CategoryIndex].ID)
    return false
end

function ArmyMemEditPowerPageVM:SetIsPermisstionChange(IsPermisstionChange, CategoryIID)
    local SelectedID = CategoryIID or self:GetCurCategoryID()
    if IsPermisstionChange then
        for _, ChangeID in pairs(self.PermisstionChangeList) do
            if SelectedID == ChangeID then
                return
            end
        end
        table.insert(self.PermisstionChangeList, SelectedID)
    else
        local DelKey
        for Key, ChangeID in pairs(self.PermisstionChangeList) do
            if SelectedID == ChangeID then
                DelKey = Key
            end
        end
        table.remove(self.PermisstionChangeList, DelKey)
    end
    self:CheckDataChange()
end
function ArmyMemEditPowerPageVM:SetIsSaveBtnEnabled(InIsSaveBtnEnabled)
    self.IsSaveBtnEnabled = InIsSaveBtnEnabled
end

function ArmyMemEditPowerPageVM:CheckOrderChange()
    self.IsOrderChange = false
    for Index, CategoryData in ipairs(self.Categories) do
        --CategoryData.ShowIndex = Index
        if CategoryData.ShowIndex ~= Index then
            self.IsOrderChange = true
            break
        end
    end
    self:CheckDataChange()
end

function ArmyMemEditPowerPageVM:CheckCategoryChange()
    if self.OldCategoryNum ~= self.CurCategoryNum then
        self.IsCategoryChange = true
    else
        if #self.DelCategories > 0 then
            self.IsCategoryChange = true
        else
            self.IsCategoryChange = false
        end
    end
    self:CheckDataChange()
end

--- 检查变更,是否可以保存
function ArmyMemEditPowerPageVM:CheckDataChange()
    self.IsSaveBtnEnabled = false
    --- 检查错误项
    local IsErrorName = not table.is_nil_empty(self.ErrorNameList)
    if IsErrorName then
        self:SetIsSaveBtnEnabled(false)
        return
    end
    local IsNameChange = not table.is_nil_empty(self.NameChangeList)
    local IsIconChange = not table.is_nil_empty(self.IconChangeList)
    local IsPermisstionChange =  not table.is_nil_empty(self.PermisstionChangeList)
    --- 检查变更
    if IsNameChange or self.IsOrderChange or IsIconChange or IsPermisstionChange or self.IsCategoryChange then
        self:SetIsSaveBtnEnabled(true)
    else
        self:SetIsSaveBtnEnabled(false)
        -- LSTR string:没有需要保存的变更
        self.SaveErrorStr = LSTR(910172)
    end
end

function ArmyMemEditPowerPageVM:SaveAndSendData()
    ArmyMgr:SendGroupEditCategory(self.Categories)
end

function ArmyMemEditPowerPageVM:DelCurCategory()
    local SelectedIndex = self:GetSelectedCategoryIndex()
    ---清空记录的变更标记
    self:SetIsIconChange(false, self.Categories[SelectedIndex].ID)
    self:SetIsNameChange(false, self.Categories[SelectedIndex].ID)
    self:SetIsPermisstionChange(false, self.Categories[SelectedIndex].ID)
    self:SetIsErrorName(false, self.Categories[SelectedIndex].ID)
    if not self.Categories[SelectedIndex].IsClientNew then
        table.insert(self.DelCategories, self.Categories[SelectedIndex])
    end
    --- 删除最后一项的时候，需要往上调整选中，防止选中到新增按钮触发新增逻辑
    if SelectedIndex == #self.Categories then
        self:SetSelectedCategoryIndex(SelectedIndex - 1)
    end
    table.remove(self.Categories, SelectedIndex)
    self:UpdateCurCategoryNum(#self.Categories)
    self:UpdateCategoryList()
    self:CheckCategoryChange()
end

function ArmyMemEditPowerPageVM:AddCategory()
    if self.CurCategoryNum >= MaxCategoryNum then
        -- LSTR string:分组数量已达上限
        MsgTipsUtil.ShowTips(LSTR(910064))
        return
    end
    local NewID = 1
    local NewIconID = 0
    local IsExist = true
    while IsExist do
        IsExist = false
        NewID = NewID + 1
        for _, Categoriy in ipairs(self.Categories) do
            if NewID == Categoriy.ID then
                IsExist = true
                break
            end
        end
    end
    IsExist = true
    while IsExist do
        IsExist = false
        NewIconID = NewIconID + 1
        for _, Categoriy in ipairs(self.Categories) do
            if NewIconID == Categoriy.IconID then
                IsExist = true
                break
            end
        end
    end
    local Len = #self.Categories
    local DefaultPermisstionTypes = GroupGlobalCfg:FindCfgByKey(ProtoRes.GroupGlobalConfigType.GroupGlobalConfigType_DefaultPermissions)
    local PermisstionTypes = table.clone(DefaultPermisstionTypes.Value)
    local NewCategory = {
        ID = NewID,
        IconID = NewIconID,
        PermisstionTypes = PermisstionTypes,
        Name = "",
        ShowIndex = Len + 1,
        IsClientNew = true,
    }
    -- if self.Categories and self.Categories[Len] then
    --     self.Categories[Len].ShowIndex = Len + 1
    -- end
    local DelIndex
    for Index, Category in ipairs(self.DelCategories) do
        if NewCategory.ID == Category.ID then
            DelIndex = Index
            NewCategory.OldPermisstionTypes = Category.OldPermisstionTypes
            NewCategory.OldName = Category.OldName
            NewCategory.OldIconID = Category.OldIconID
        end
    end
    table.insert(self.Categories,NewCategory)
    self:UpdateCurCategoryNum(#self.Categories)
    self:SetSelectedCategoryIndex(Len + 1)
    --- 默认名字为空
    self:SetIsErrorName( true, NewCategory.ID, true)
    if DelIndex then
        table.remove(self.DelCategories, DelIndex)
        self:CheckIconChange(self.SelectedCategoryIndex)
        self:SetIsNameChange(self.SelectedCategoryIndex)
        self:CheckPermisstionChange(self.SelectedCategoryIndex)
    end
    self:UpdateCategoryList()
    self:CheckCategoryChange()
end

--- 成员阶级切换
function ArmyMemEditPowerPageVM:OnClickedSwitchCategory(RoleIDs, Btn)
    local Params = {}
    Params.Data = {}
    for Index, CategoryData in ipairs(self.Categories) do
        local Name = CategoryData.Name
        local Members = ArmyMgr:GetArmyMembersByCategotyID(CategoryData.ID)
        local MemberNum = 0
        if Members then
            MemberNum = #Members
        end
        --- 会长不可设置
        if CategoryData.ID ~= ArmyDefine.LeaderCID then
            table.insert(Params.Data, {
                TextName = string.format("%d %s (%d)", Index, Name, MemberNum),
                Icon = GroupMemberCategoryCfg:GetCategoryIconByID(CategoryData.IconID),
                Data = CategoryData,
                RoleIDs = table.clone(RoleIDs),
                IsSelected = self.CurCategoryID == CategoryData.ID,
                ClickItemCallback = self.OnClickedMemEditItem,
                View = self,
            })
        end
    end

    if Btn ~= nil then
        local BtnSize = UIUtil.GetLocalSize(Btn)
        TipsUtil.ShowJumpToTips(Params, Btn, _G.UE.FVector2D(0, BtnSize.Y * 0.12),  _G.UE.FVector2D(0, 0), false)
    end
end

function ArmyMemEditPowerPageVM:OnClickedMemEditItem(ItemData)
    local Params = ItemData
	if nil ~= Params then
		local CategoryID = Params.Data.ID
        local CategoryData = table.find_by_predicate(self.Categories, function(Value)
            return Value.ID == CategoryID
        end)
        if CategoryData.IsClientNew then
            -- LSTR string:移入新增分组需要先保存修改
            MsgTipsUtil.ShowTips(LSTR(910197))
            return
        end
		if not Params.IsSelected then
			ArmyMgr:SendArmySetMemberCategoryMsg(ItemData.RoleIDs, CategoryID)
            for _, RoleID in ipairs(ItemData.RoleIDs) do
                self:DelMembertoSelectedMemberList(RoleID)
            end
            --- 当没有成员时，是否可以全选，目前默认可以，所以不在UpdataAllSelectedData对0做特殊处理，在这里清除一下全选
            self:UpdataAllSelectedData()
            self.IsAllMemberSelected = false
		end
	end
	
    if UIViewMgr:IsViewVisible(UIViewID.CommJumpWayTipsView) then
        UIViewMgr:HideView(UIViewID.CommJumpWayTipsView)
    end
end

function ArmyMemEditPowerPageVM:PermisstionTypeDataChange(CategoryIndex, ChangedPermisstionType, IsAdd)
    if self.Categories and self.Categories[CategoryIndex] then
        local PermisstionTypes = self.Categories[CategoryIndex].PermisstionTypes
        if PermisstionTypes then
            if IsAdd then
                local IsExist = false
                for _, PermisstionType in pairs(PermisstionTypes) do
                    if ChangedPermisstionType == PermisstionType then
                        IsExist = true
                        break
                    end
                end
                if not IsExist then
                    table.insert(PermisstionTypes, ChangedPermisstionType)
                end
            else
                local DelKey
                for Key, PermisstionType in pairs(PermisstionTypes) do
                    if ChangedPermisstionType == PermisstionType then
                        DelKey = Key
                        break
                    end
                end
                if DelKey then
                    table.remove(PermisstionTypes, DelKey)
                    --PermisstionTypes[DelKey] = nil
                end
            end
            self:CheckPermisstionChange(CategoryIndex)
        end
    elseif self.Categories == nil then
        _G.FLOG_WARNING("ArmyMemEditPowerPageVM:PermisstionTypeDataChange self.Categories is nil")
    elseif self.Categories[CategoryIndex] == nil then
        local LogStirng = tostring(CategoryIndex)
        _G.FLOG_WARNING(string.format("ArmyMemEditPowerPageVM:PermisstionTypeDataChange self.Categories[CategoryIndex] is nil, CategoryIndex:%s", LogStirng))
    end
end

function ArmyMemEditPowerPageVM:AddMembertoSelectedMemberList(RoleID)
    ---拦截占位空格
    if RoleID == 0 then
        return
    end
    local IsExist = table.find_by_predicate(self.SelectedMemberList, function(Value)
        return Value == RoleID
    end)
    if not IsExist then
        table.insert(self.SelectedMemberList, RoleID)
    end
    --self:UpdataAllSelectedData()
end

function ArmyMemEditPowerPageVM:DelMembertoSelectedMemberList(RoleID)
    local IsExist, Index = table.find_by_predicate(self.SelectedMemberList, function(Value)
        return Value == RoleID
    end)
    if Index then
        table.remove(self.SelectedMemberList, Index)
    end
    --self:UpdataAllSelectedData()
end

function ArmyMemEditPowerPageVM:UpdataBatchStr()
    -- LSTR string:批量调整 %d/%d
    self.BatchStr = LSTR(910132)
    self.BatchStr = string.format(self.BatchStr, #self.SelectedMemberList, #self.CurMemberList)
end

function ArmyMemEditPowerPageVM:AllMemberSelected(IsChecked)
    self.SelectedMemberList = {}
    local Items = self.MemberEditCategoryList:GetItems()
    for _, Item in ipairs(Items) do
        Item.bChecked = IsChecked
        if IsChecked then
            self:AddMembertoSelectedMemberList(Item.RoleID)
        end
    end
    if not IsChecked then
        self.SelectedMemberList = {}
		--local Items = self.MemberEditCategoryList:GetItems()
        -- for index, Item in ipairs(Items) do
        --     Item.bChecked = false
        --     self:DelMembertoSelectedMemberList(Item.RoleID)
        -- end
        --self.MemberEditCategoryList:UpdateList()
	end
    self:UpdataAllSelectedData()
end

function ArmyMemEditPowerPageVM:UpdataAllSelectedData()
    self:UpdataBatchStr()
    self.BatchBtnEnable = #self.SelectedMemberList > 0
    self.IsAllMemberSelected = #self.SelectedMemberList == #self.CurMemberList
end

function ArmyMemEditPowerPageVM:GetIsAllMemberSelected()
    --self.IsAllMemberSelected = #self.SelectedMemberList == #self.CurMemberList
    return self.IsAllMemberSelected
end


function ArmyMemEditPowerPageVM:SetBGIcon(Type)
    self.GrandCompanyType = Type
    self.BGIcon = ArmyDefine.UnitedArmyTabs[Type].BigBGIcon
    self.BGMaskColor = ArmyDefine.UnitedArmyTabs[Type].MaskColor
end

return ArmyMemEditPowerPageVM
