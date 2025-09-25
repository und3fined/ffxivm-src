---
--- Author: daniel
--- DateTime: 2023-03-13 16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyMemberPageType = ArmyDefine.ArmyMemberPageType
local CategoryUIType = ArmyDefine.CategoryUIType
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local GroupPermissionCfg = require("TableCfg/GroupPermissionCfg")
local ProtoCS = require("Protocol/ProtoCS")
local GroupPermissionType = ProtoCS.GroupPermissionType
local ProtoRes = require("Protocol/ProtoRes")
local GroupPermissionClass = ProtoRes.GroupPermissionClass
local ProtoCommon = require("Protocol/ProtoCommon")
local GroupStoreCfg = require("TableCfg/GroupStoreCfg")
local GroupStoreUitextCfg = require("TableCfg/GroupStoreUitextCfg")
local GroupDefine = require("Game/Group/GroupDefine")
local MSDKDefine = require("Define/MSDKDefine")

local ArmyMgr
local ArmyMemEditPowerPageVM = require("Game/Army/VM/ArmyMemEditPowerPageVM")
--local ArmyMemEditPartPageVM = require("Game/Army/VM/ArmyMemEditPartPageVM")
--local ArmyMemEditSortPageVM = require("Game/Army/VM/ArmyMemEditSortPageVM")
local ArmyMemListItemVM = require("Game/Army/ItemVM/ArmyMemListItemVM")
local ArmyJoinMsgItemVM = require("Game/Army/ItemVM/ArmyJoinMsgItemVM")
local ArmyMemClassListItemVM = require("Game/Army/ItemVM/ArmyMemClassListItemVM")
local ArmyClassAuthorityItemVM = require("Game/Army/ItemVM/ArmyClassAuthorityItemVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local CommPlayerDefine = require("Game/Common/Player/CommPlayerDefine")
local StateType = CommPlayerDefine.StateType
local MajorUtil = require("Utils/MajorUtil")

local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local LSTR = _G.LSTR


---@class ArmyMemberPageVM : UIViewModel
---@field bMemberPanel boolean @成员列表面板
---@field MemberOnLinenNum string @成员在线数量
---@field bApplyPanel boolean @入队申请列表面板
---@field bEditPowerPage boolean @权限编辑面板
---@field bEditPartPage boolean @编辑面板
---@field bEditSortPage boolean @面板
---@field CategoryOnLinenNum string @成员在线数量
---@field bApplyEmpty boolean @是否没有入队申请
---@field bCategoryPanel boolean @分组设定面板
---@field MemberList any @成员列表
---@field JoinApplyList any @入队申请列表
---@field CategoryList any @分组列表
---@field SelectedClassItemIndex number @选中的分组索引
---@field PageIndex number @索引
---@field PermissionsPageIndex number @权限信息索引
---@field MoreList any @更多列表
---@field CInfoTitle string @权限信息标题
---@field CInfoDisplay string @权限信息描述
---@field bPmssEditEnabled boolean @权限编辑按钮是否可用
---@field bMemEditEnabled boolean @成员编辑按钮是否可用
---@field bCategoryEditEnabled boolean @分组编辑按钮是否可用
---@field CategoryPmssTitle stirng 分组权限标题
---@field PermissionsList any @权限列表

local ArmyMemberPageVM = LuaClass(UIViewModel)

--- 部队成员排序 在线>名字
---@param A any
---@param B any
local ArmyMemberSortFunc = function(A, B)
    if A.bOnline == B.bOnline then
        if A.CategoryShowIndex == B.CategoryShowIndex then
            return A.JobName > B.JobName
        else
            return A.CategoryShowIndex < B.CategoryShowIndex
        end
    else
        return A.bOnline
    end
end

--- 入队申请排序,策划要特殊处理，不按在线离线来
local ApplyRolesSortFunc = function(A, B)
    return A.ApplyTime < B.ApplyTime
end

local CategoryPageDec1 = nil
local CategoryPageDec2 = nil
local CategoryPageDec3 = nil
local bLoadingRoleInfo = false
local SortMode = 
{
    Level = 1,
    Category = 2,
}
---Ctor
function ArmyMemberPageVM:Ctor()
    self.bMemberPanel = nil
    self.MemberOnLinenNum = nil
    self.bApplyPanel = nil
    self.bEditPowerPage = nil
    --self.bEditPartPage = nil
    --self.bEditSortPage = nil
    self.CategoryOnLinenNum = nil
    self.bApplyEmpty = nil
    self.bCategoryPanel = nil
    self.MemberList = nil
    self.JoinApplyList = nil
    self.CategoryList = nil
    self.SelectedClassItemIndex = nil
    self.ExitBtnText = nil
    self.CInfoTitle = nil
    self.CInfoDisplay = nil
    --- endregion
    self.PermissionsEditIsEnable = nil
    self.MemberEditIsEnable = nil
    self.IsIntern = false
    self.CTraineeInfoTitle = nil
    self.CTraineeInfoDisplay =nil
    self.CategoryPmssTitle = nil
    self.PermissionsList = nil
    self.CategoryPmssTitleIcon = nil
    self.bCategoryEditEnabled = nil
    self.bSortMode = nil
    self.IsShowInviteBtn = nil

    -- 一键建群
    self.GroupIconPath = nil
    self.GroupBtnText = nil
end

function ArmyMemberPageVM:OnInit()
    bLoadingRoleInfo = false
    ArmyMgr = _G.ArmyMgr
    self.MyArmyInfo = nil
    self.Members = nil
    self.bAcceptJoin = nil
    self.bKickMember = nil
    self.OnlineNum = nil
    self.TotalMemNum = nil
    self.MoreTab = nil
    self.MyPermissionTypes = nil

    self.MemberList = UIBindableList.New(ArmyMemListItemVM)
    self.JoinApplyList = UIBindableList.New(ArmyJoinMsgItemVM)
    self.CategoryList = UIBindableList.New(ArmyMemClassListItemVM)
    self.PermissionsList = UIBindableList.New(ArmyClassAuthorityItemVM)

    self.ArmyMemEditPowerPageVM = ArmyMemEditPowerPageVM.New()
    self.ArmyMemEditPowerPageVM:OnInit()

    --self.ArmyMemEditPartPageVM = ArmyMemEditPartPageVM.New()
    --self.ArmyMemEditPartPageVM:OnInit()

    --self.ArmyMemEditSortPageVM = ArmyMemEditSortPageVM.New()
    --self.ArmyMemEditSortPageVM:OnInit()

    self.IsPriorityHighCategory = true
    self.IsPriorityHighLevel = true
    ---默认分组排序
    self.bSortMode = SortMode.Category
end

function ArmyMemberPageVM:OnBegin()
    self.ArmyMemEditPowerPageVM:OnBegin()
    --self.ArmyMemEditPartPageVM:OnBegin()
    --self.ArmyMemEditSortPageVM:OnBegin()
end

function ArmyMemberPageVM:OnEnd()
    self.ArmyMemEditPowerPageVM:OnEnd()
    --self.ArmyMemEditPartPageVM:OnEnd()
    --self.ArmyMemEditSortPageVM:OnEnd()
end

function ArmyMemberPageVM:OnShutdown()
    self.MyArmyInfo = nil
    self.Members = nil
    self.bAcceptJoin = nil
    self.bKickMember = nil
    self.OnlineNum = nil
    self.TotalMemNum = nil
    self.MoreTab = nil
    self.MyPermissionTypes = nil
    self.ArmyMemEditPowerPageVM:OnShutdown()
    --self.ArmyMemEditPartPageVM:OnShutdown()
    --self.ArmyMemEditSortPageVM:OnShutdown()
    self.MemberList:Clear()
    self.JoinApplyList:Clear()
    self.CategoryList:Clear()
    self.PermissionsList:Clear()
    self.MemberList = nil
    self.JoinApplyList = nil
    self.CategoryList = nil
    self.PermissionsList = nil
end

function ArmyMemberPageVM:GetMemEditPowerPageVM()
    return self.ArmyMemEditPowerPageVM
end

function ArmyMemberPageVM:GetMemEditPartPageVM()
    --return self.ArmyMemEditPartPageVM
end

function ArmyMemberPageVM:GetMemEditSortPageVM()
    --return self.ArmyMemEditSortPageVM
end

function ArmyMemberPageVM:SetPageIndex(Index)
    self.PageIndex = Index
    if self.PageIndex == nil then
        self.PageIndex = ArmyDefine.One
    end
    self.bEditPowerPage = false
    --self.bEditPartPage = false
    --self.bEditSortPage = false
    self.bMemberPanel = self.PageIndex == ArmyMemberPageType.MemberPage
    if self.bMemberPanel then
        self:ClearbLoadingRoleInfoState()
        ArmyMgr:SendQuerySelfMember()
        local IsHaveInvitePermissions = ArmyMgr:GetSelfIsHavePermisstion(ProtoRes.GroupPermissionType.GROUP_PERMISSION_TYPE_SendInvite)
        self.IsShowInviteBtn = IsHaveInvitePermissions
    end
    self.bApplyPanel = self.PageIndex == ArmyMemberPageType.ApplyJoinPage
    if self.bApplyPanel then
        ArmyMgr:SendGetArmyQueryApplyListMsg()
        self.SelectedClassItemIndex = nil
        self.CategoryIndex = nil
        self:UpdateAskForPermissionsState()
    end
    self.bCategoryPanel = self.PageIndex == ArmyMemberPageType.CategorySettingPage
    if self.bCategoryPanel then
        if self.MyArmyInfo then
            local SelfRoleInfo = ArmyMgr:GetSelfRoleInfo()
            if SelfRoleInfo then
                self:UpdateCategoryPermissionsState()
                local CategoryID = SelfRoleInfo.CategoryID or ArmyDefine.One
                local Categories = self.MyArmyInfo.Categories
                local CurCategoryIndex = nil
                if Categories then
                    local CategoryData, CategoryIndex = table.find_by_predicate(Categories, function(A)
                        return A.ID == CategoryID
                    end)
                    CurCategoryIndex = CategoryIndex
                end
                self.SelectedClassItemIndex =  CurCategoryIndex or ArmyDefine.One
            else
                self.SelectedClassItemIndex = ArmyDefine.One
            end
        else
            self.SelectedClassItemIndex = ArmyDefine.One
        end
        self.ArmyMemEditPowerPageVM:SetSelectedCategoryIndex(self.SelectedClassItemIndex)
    end
    if  self.bMemberPanel then
        self:UpdateMemberList()
        self.SelectedClassItemIndex = nil
        self.CategoryIndex = nil
    end
end


function ArmyMemberPageVM:OpenCategoryTab(Type)
    self.bCategoryPanel = false
    self.bEditPowerPage = Type == CategoryUIType.Power
    --self.bEditPartPage = Type == CategoryUIType.Part
    --self.bEditSortPage = Type == CategoryUIType.Sort
end

function ArmyMemberPageVM:CloseCategoryEdit()
    self.bEditPowerPage = false
    --self.bEditPartPage = false
    --self.bEditSortPage = false
    self.bCategoryPanel = true
end

--- 选中分组显示该分组权限
function ArmyMemberPageVM:SelectedCategoryPermissionsInfo(Index, ItemData)
    if nil == ItemData then
        return
    end
    if Index ~= self.CategoryIndex then
        self.CategoryIndex = Index
        self.ArmyMemEditPowerPageVM:SetSelectedCategoryIndex(self.CategoryIndex)
        if ItemData.Name then
            -- LSTR string:权限
            self.CategoryPmssTitle = string.format("%s %s",ItemData.Name, LSTR(910165) )
        end
        if ItemData.CategoryIcon then
            self.CategoryPmssTitleIcon = ItemData.CategoryIcon
        end
        --self:UpdateInfoDec(ItemData.PermisstionTypes)
        self:SetPermissionsPageIndex(self.PermissionsPageIndex)
        self.IsIntern = false
        local PermissionsItemDatas = {}
        for _, PermissionsClass in pairs(GroupPermissionClass) do
            if PermissionsClass ~= 0 then
                local PermissionsItemData = self:CreatePermissionsItemData(PermissionsClass, ItemData.PermisstionTypes)
                table.insert(PermissionsItemDatas, PermissionsItemData)
            end
        end
        table.sort(PermissionsItemDatas, function(A, B) 
            return A.PermissionsClass < B.PermissionsClass
        end)
        self.PermissionsList:UpdateByValues(PermissionsItemDatas)
    end
end

function ArmyMemberPageVM:CreatePermissionsItemData(PermissionsClass, PermissionsTypes)
    local PermissionsItemData = {}
    PermissionsItemData.PermissionsClass = PermissionsClass
    ---权限分类名设置 todo 看看后面要不要走部队UI文本表
    PermissionsItemData.Name = ArmyDefine.ArmyPermissionsClassData[PermissionsClass].Name
    PermissionsItemData.Icon = ArmyDefine.ArmyPermissionsClassData[PermissionsClass].Icon
    --local PermissionsList = {}
    --- 权限描述文本设置
    local Str
    local DescList = {}
    local GoldStoreDesc
    for _, ID in ipairs(PermissionsTypes) do
        local PermissionsData = GroupPermissionCfg:GetPermissionByType(ID)
        if PermissionsData == nil then
            return PermissionsItemData
        end
        if PermissionsData.Class == PermissionsClass then
            --table.insert(PermissionsList, PermissionsData)
            --- 仓库特殊处理
            if PermissionsClass == GroupPermissionClass.GRAND_PERMISSION_CLASS_STORE then
                local StoreCfg = GroupStoreCfg:FindCfgByUsePermissionId(ID)
                if StoreCfg then
                    ---获取仓库ID
                    local StoreIndex = StoreCfg.ID
                    if StoreIndex == nil then
                        break
                    end
                    ---获取仓库名，没有就用默认
                    local StoreName
                    if StoreIndex then
                        StoreName = ArmyMgr:GetStoreName(StoreIndex)
                    end
                    if StoreName then
                        if StoreName == "" then
                            -- LSTR string:默认
                            StoreName = StoreCfg.GroupDefaultName or LSTR(910276)
                        end
                        local StoreData = {ID = StoreIndex, Name = StoreName}
                        table.insert(DescList, StoreData)
                    end
                elseif PermissionsData.Type == ProtoRes.GroupPermissionType.GroupPermissionTypeMoneyBag then
                --- 金币储物柜显示走正常处理，和其他储物柜不一样
                    GoldStoreDesc = PermissionsData.Desc
                end
            else
                local DescData = {}
                DescData.ID = ID
                DescData.Desc = PermissionsData.Desc
                table.insert(DescList, DescData)
                -- if nil == Str then
                --     Str = PermissionsData.Desc
                -- else
                --     --- 是读表文本，不用LSTR
                --     Str = string.format("%s、%s", Str, PermissionsData.Desc)
                -- end
            end
        end
    end
    table.sort(DescList, function(A, B) 
        return A.ID < B.ID
    end)
    --- 仓库特殊处理
    if PermissionsClass == GroupPermissionClass.GRAND_PERMISSION_CLASS_STORE then
        for _, StoreData in ipairs(DescList) do
            ---仓库权限文本特殊合并处理
            if nil == Str then
                Str = StoreData.Name
            else
                Str = string.format("%s、%s", Str, StoreData.Name)
            end
        end
        if GoldStoreDesc then
            if nil == Str then
                Str = GoldStoreDesc
            else
                Str = string.format("%s、%s", Str, GoldStoreDesc)
            end
        end
        if Str then
            -- LSTR string:储物柜
            Str = string.format("%s %s", Str, LSTR(910051))
        end
    else
        for _, DescData in ipairs(DescList) do
            if nil == Str then
                Str = DescData.Desc
            else
                --- 是读表文本，不用LSTR
                Str = string.format("%s、%s", Str, DescData.Desc)
            end
        end
    end
    -- LSTR string:暂无权限
    PermissionsItemData.PermissionsStr = Str or LSTR(910154)
    return PermissionsItemData
end

--- 更新权限描述文字 
--function ArmyMemberPageVM:UpdateInfoDec(PermissionTypes)
    -- CategoryPageDec1 = ""
    -- CategoryPageDec2 = ""
    -- CategoryPageDec3 = ""
    -- --- 仓库权限描述需要排序
    -- local StoreDescList = {}
    -- local GoldStoreDesc
    -- for _, ID in ipairs(PermissionTypes or {}) do
    --     local PermissionsData = GroupPermissionCfg:GetPermissionByType(ID)
    --     if PermissionsData == nil then
    --         return
    --     end
    --     if PermissionsData.Class == GroupPermissionClass.GRAND_PERMISSION_CLASS_InfoEdit then
    --         if string.isnilorempty(CategoryPageDec1) then
    --             CategoryPageDec1 = string.format("·%s", PermissionsData.Desc)
    --         else
    --             CategoryPageDec1 = string.format("%s\t\n·%s", CategoryPageDec1, PermissionsData.Desc)
    --         end
    --     elseif PermissionsData.Class  == GroupPermissionClass.GRAND_PERMISSION_CLASS_STORE then
    --         local StoreCfg = GroupStoreCfg:FindCfgByUsePermissionId(ID)
    --         if StoreCfg then
    --             local StoreIndex = StoreCfg.ID
    --             if StoreIndex == nil then
    --                 StoreIndex = ID % 100
    --             end
    --             local StoreName
    --             if StoreIndex then
    --                 StoreName = ArmyMgr:GetStoreName(StoreIndex)
    --             end
    --             if nil == StoreName or StoreName == "" then
    --                 StoreName = StoreCfg.GroupDefaultName or "默认"
    --             end
    --             local StoreDesc = {}
    --             StoreDesc.Str = StoreName..PermissionsData.Desc
    --             StoreDesc.ID = StoreIndex
    --             table.insert(StoreDescList, StoreDesc)
    --         else
    --             GoldStoreDesc = PermissionsData.Desc
    --         end
    --     elseif PermissionsData.Class  == GroupPermissionClass.GRAND_PERMISSION_CLASS_MemberManage then
    --         if string.isnilorempty(CategoryPageDec3) then
    --             CategoryPageDec3 = string.format("·%s", PermissionsData.Desc)
    --         else
    --             CategoryPageDec3 = string.format("%s\t\n·%s", CategoryPageDec3, PermissionsData.Desc)
    --         end
    --     end
    -- end
    -- table.sort(StoreDescList, function(A,B) 
    --     return A.ID < B.ID 
    -- end)
    -- for _, StoreDesc in ipairs(StoreDescList) do
    --     if string.isnilorempty(CategoryPageDec2) then
    --         CategoryPageDec2 = string.format("·%s", StoreDesc.Str)
    --     else
    --         CategoryPageDec2 = string.format("%s\t\n·%s", CategoryPageDec2, StoreDesc.Str)
    --     end
    -- end
    -- ---金币储物柜放最后
    -- if string.isnilorempty(CategoryPageDec2) then
    --     CategoryPageDec2 = string.format("·%s", GoldStoreDesc)
    -- else
    --     CategoryPageDec2 = string.format("%s\t\n·%s", CategoryPageDec2, GoldStoreDesc)
    -- end
--end

function ArmyMemberPageVM:SetPermissionsPageIndex(Index)
    -- local CategoryPageDec
    -- if Index == GroupPermissionClass.GRAND_PERMISSION_CLASS_InfoEdit then
    --     CategoryPageDec = CategoryPageDec1
    -- LSTR string:信息权限编辑
    --     self.CInfoTitle = LSTR(910044)
    -- elseif Index == GroupPermissionClass.GRAND_PERMISSION_CLASS_STORE then
    --     CategoryPageDec = CategoryPageDec2
    -- LSTR string:仓库权限
    --     self.CInfoTitle = LSTR(910035)
    -- elseif Index == GroupPermissionClass.GRAND_PERMISSION_CLASS_MemberManage then
    --     CategoryPageDec = CategoryPageDec3
    -- LSTR string:成员管理权限
    --     self.CInfoTitle = LSTR(910130)
    -- end
    -- if string.isnilorempty(CategoryPageDec) then
    -- LSTR string:无
    --     self.CInfoDisplay = LSTR(910150)
    -- else
    --     self.CInfoDisplay = CategoryPageDec
    -- end
    self.PermissionsPageIndex = Index
end

function ArmyMemberPageVM:UpdateMyArmyInfo(MyArmyInfo, bLeader)
    self.MyArmyInfo = MyArmyInfo
    self.Members = MyArmyInfo.Members
    local Categories = MyArmyInfo.Categories
    --self.ArmyMemEditSortPageVM:UpdateCategoryList(Categories)
    ---分组编辑界面打开时再更新数据
    --self.ArmyMemEditPowerPageVM:UpdateCategoryList(Categories)
    --self.ArmyMemEditPartPageVM:UpdateCategoryList(Categories)
    self:UpdateSetIsLeader(bLeader)
    self:UpdateSelfData()
    self:SetPageIndex(self.PageIndex)
    self:UpdateMemberList()
    self:UpdateMemberCategoryTreeList()
end

function ArmyMemberPageVM:UpdateMemberCategoryTreeList()
    local Categories = ArmyMgr:GetArmyCategories()
    --self.ArmyMemEditSortPageVM:UpdateCategoryList(Categories)
    ---分组编辑界面打开时再更新数据
    --self.ArmyMemEditPowerPageVM:UpdateCategoryList(Categories)
    --self.ArmyMemEditPartPageVM:UpdateCategoryList(Categories)
    ---不排序，使用服务器发送数据顺序
    local CategoryData = {}
    for Index, Value in pairs(Categories) do
        if Value ~= nil then
            local Data = {
                ShowIndex = Index,
                ID = Value.ID,
                Name = Value.Name,
                PermisstionTypes = Value.PermisstionTypes,
                IconID = Value.IconID
            }
            table.insert(CategoryData, Data)
        end
    end
    self.CategoryList:UpdateByValues(CategoryData)
    ---刷新权限数据
    if self.CategoryIndex then
        local ItemData = self.CategoryList:Get(self.CategoryIndex)
        local Index = self.CategoryIndex
        ---防止被重复判断拦截
        self.CategoryIndex = 0
        self:SelectedCategoryPermissionsInfo(Index, ItemData)
    end

end

function ArmyMemberPageVM:UpdateCategoryByAddMember(CategoryID)
    local CategoryVM = self.CategoryList:Find(function(Element)
        return Element.ID == CategoryID
    end)
    if CategoryVM ~= nil then
        CategoryVM:UpdateMemberNum(CategoryID)
    end
end

--- 更新部队长状态
function ArmyMemberPageVM:UpdateSetIsLeader(bLeader)
    self.bLeader = bLeader
    self:UpdateExitBtnText()
end

--- 更新自己数据
function ArmyMemberPageVM:UpdateSelfData()
    local MyCategoryData = ArmyMgr:GetSelfCategoryData()
    if MyCategoryData == nil then
        return
    end
    local PermissionTypes = MyCategoryData.PermisstionTypes
    self:UpdatePermissionsState()
    self.MyPermissionTypes = PermissionTypes
    self:UpdateFullCapacity()
end

--- 更新权限状态
function ArmyMemberPageVM:UpdatePermissionsState()
    self.bAcceptJoin = ArmyMgr:GetSelfIsHavePermisstion( GroupPermissionType.GROUP_PERMISSION_TYPE_AcceptJoin)
    self.bKickMember = ArmyMgr:GetSelfIsHavePermisstion( GroupPermissionType.GROUP_PERMISSION_TYPE_KickMember)
    self.PermissionsEditIsEnable = ArmyMgr:GetSelfIsHavePermisstion( GroupPermissionType.GROUP_PERMISSION_TYPE_SetMemberCategory)
    self.MemberEditIsEnable = self.PermissionsEditIsEnable
    self.CategoryEdit = ArmyMgr:GetSelfIsHavePermisstion( GroupPermissionType.GROUP_PERMISSION_TYPE_EditCategory)
end

--- 更新分组相关权限数据
function ArmyMemberPageVM:UpdateCategoryPermissionsState()
    self.CategoryEdit = ArmyMgr:GetSelfIsHavePermisstion( GroupPermissionType.GROUP_PERMISSION_TYPE_EditCategory)
end

--- 更新申请相关权限数据
function ArmyMemberPageVM:UpdateAskForPermissionsState()
    self.bAcceptJoin = ArmyMgr:GetSelfIsHavePermisstion( GroupPermissionType.GROUP_PERMISSION_TYPE_AcceptJoin)
    self:UpdateFullCapacity()
end

function ArmyMemberPageVM:UpdateExitBtnText()
    if self.bLeader and #self.Members == ArmyDefine.One then
        -- LSTR string:解散部队
        self.ExitBtnText = _G.LSTR(910216)
    else
        -- LSTR string:退出部队
        self.ExitBtnText = _G.LSTR(910241)
    end
end

function ArmyMemberPageVM:UpdateFullCapacity()
    local MaxMemberCount = ArmyMgr:GetArmyMemberMaxCount()
    if self.Members then
        self.bFullCapacity = #self.Members == MaxMemberCount
    else
        self.bFullCapacity = false
    end
end

function ArmyMemberPageVM:UpdateMemberList()
    if bLoadingRoleInfo then 
        return 
    end
    -- 由于其他管理移除或添加成员，导致成员列表发生变化，需要重新刷新（或者判断不同，移除不存在的Item）
    self.MemberList:Clear()
    bLoadingRoleInfo = true
    ---计时2s后清理，防止bLoadingRoleInfo阻碍逻辑
    if self.LoadingRoleInfoTimer then
        _G.TimerMgr:CancelTimer(self.LoadingRoleInfoTimer)
        self.LoadingRoleInfoTimer = nil
    end
    self.LoadingRoleInfoTimer = _G.TimerMgr:AddTimer(self, function()
        bLoadingRoleInfo = false
    end, 2.0, 0, 1)
    local Members = self.Members or {}
    self.OnlineNum = 0
    self.TotalMemNum = #Members
    local RoleIDs = {}
    for _, v in ipairs(Members) do
        local RoleSimData = v.Simple
        table.insert(RoleIDs, RoleSimData.RoleID)
    end
    RoleInfoMgr:QueryRoleSimples(RoleIDs, function()
        bLoadingRoleInfo = false
        if self.LoadingRoleInfoTimer then
            _G.TimerMgr:CancelTimer(self.LoadingRoleInfoTimer)
            self.LoadingRoleInfoTimer = nil
        end
        self:AddMemVMByMemberDatas(RoleIDs)
        -- 刷新完统计在线人数
        self:UpdateOnlineState()
        self:UpdateFullCapacity()
    end, nil, false)
end

--- 添加MemberViewModel
function ArmyMemberPageVM:AddMemberItem(RoleData)
    local RoleID = RoleData.Simple.RoleID
    RoleInfoMgr:QueryRoleSimple(RoleID, function(_, RoleVM)
        -- 特殊处理，屏蔽掉无效玩家
        if RoleVM.Name ~= "" then
            if RoleVM.IsOnline then
                self.OnlineNum = self.OnlineNum + 1
            end
            self.TotalMemNum = self.TotalMemNum + 1
            self:AddMemVMByMemberData(RoleID, RoleVM)
            self:UpdateOnlineState()
            self:UpdateFullCapacity()
        end
    end, nil, false)
    self:UpdateCategoryByAddMember(RoleData.Simple.CategoryID)
end

function ArmyMemberPageVM:AddMemVMByMemberData(RoleID, RoleVM)
    local MemberVM = self.MemberList:Find(function(Element)
        return Element.RoleID == RoleID
    end)
    local MemberData = self:CreateMemberData(RoleID, RoleVM)
    if MemberVM ~= nil then
        MemberVM:UpdateVM(MemberData)
    else
        self.MemberList:AddByValue(MemberData)
        local SortFunc = self:GetSortFunc(self.bSortMode)
        self.MemberList:Sort(SortFunc)
    end
end

function ArmyMemberPageVM:AddMemVMByMemberDatas(RoleIDs)
    for _, RoleID in ipairs(RoleIDs) do
        local Role = RoleInfoMgr:FindRoleVM(RoleID, true)
        -- 特殊处理，屏蔽掉无效玩家
        if Role.Name ~= "" then
            ---统一添加
            ---self:AddMemVMByMemberData(RoleID, Role)
            local MemberVM = self.MemberList:Find(function(Element)
                return Element.RoleID == RoleID
            end)
            local MemberData = self:CreateMemberData(RoleID, Role)
            if MemberVM ~= nil then
                MemberVM:UpdateVM(MemberData)
            else
                self.MemberList:AddByValue(MemberData)
            end
            if Role.IsOnline then
                self.OnlineNum = self.OnlineNum + 1
            end
        end
    end
    local SortFunc = self:GetSortFunc(self.bSortMode)
    ---按当前排序模式排序
    self.MemberList:Sort(SortFunc)
end

function ArmyMemberPageVM:CreateMemberData(RoleID, RoleVM)
    local Member = table.find_by_predicate(self.Members, function(Element)
        return Element.Simple.RoleID == RoleID
    end)
    if Member == nil then
        return
    end
    local MemberData = table.clone(Member)
    if MemberData.Simple and nil == MemberData.Simple.CategoryID then
        --- 如果是新增的成员默认为最下层分组/成员分组，等回包修正
        local NewCategoryID = ArmyMgr:GetNewMemberCategoryID()
        MemberData.Simple.CategoryID = NewCategoryID
        ArmyMgr:GetMemberDataByRoleID(RoleID, function(MemberSimpleData) 
            self:UpdataMemberItemData(MemberSimpleData)
        end)
    end
    MemberData.RoleName = RoleVM.Name
    MemberData.MapResName = RoleVM.MapResName
    MemberData.IsOnline = RoleVM.IsOnline
    MemberData.Level = RoleVM.Level
    MemberData.OnlineStatusIcon = RoleVM.OnlineStatusIcon
    MemberData.LogoutTime = RoleVM.LogoutTime
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
    local CurWorldID = _G.PWorldMgr:GetCurrWorldID()
    local RoleCurWorldID = RoleVM.CurWorldID
    ---如果没有跨界
    if RoleCurWorldID == 0 then
        RoleCurWorldID = RoleVM.WorldID
    end
    if RoleCurWorldID ~= CurWorldID then
        MemberData.MapResName = _G.LoginMgr:GetMapleNodeName(RoleCurWorldID)
        MemberData.IsShowCrossIcon = true
    end
    return MemberData
end

function ArmyMemberPageVM:RemoveMemberItem(RoleID)
    local MemberVM = self:FindMemberItem(RoleID)
    if MemberVM ~= nil then
        self.MemberList:Remove(MemberVM)
        self.TotalMemNum = self.TotalMemNum - 1
        if MemberVM.bOnline then
            self.OnlineNum = self.OnlineNum - 1
        end
        self:UpdateOnlineState()
        self:UpdateFullCapacity()
    end
    return MemberVM
end

function ArmyMemberPageVM:FindMemberItem(RoleID)
    local MemberVM = self.MemberList:Find(function(Element)
        return Element.RoleID == RoleID
    end)
    return MemberVM
end

function ArmyMemberPageVM:UpdateOnlineState()
    -- 刷新完统计在线人数
    self.MemberOnLinenNum = string.format("%d/%d", self.OnlineNum, self.TotalMemNum)
    self.CategoryOnLinenNum = self.MemberOnLinenNum
    -- LSTR string:在线成员：
    local MemberOLStr = LSTR(910091)
    self.MemberOnLinenNum = string.format("%s%s", MemberOLStr, self.MemberOnLinenNum)
end

function ArmyMemberPageVM:RemoveCategoryByID(DelCategoryID, MemberTargetID, MemberIDs)
    if #MemberIDs > 0 then
        self:EditMemClassNameByRoleIDs(MemberIDs, MemberTargetID)
        self:UpdateMemberCategoryTreeList()
    end
    self:RemoveCategoryVMByID(DelCategoryID)
    --- 刷新TreeView
    --self.ArmyMemEditPartPageVM:UpdateCategoryList(self.MyArmyInfo.Categories)
    ---分组编辑界面打开时再更新数据
    --self.ArmyMemEditPowerPageVM:UpdateCategoryList(self.MyArmyInfo.Categories)
    --- 需要刷新ShowIndex
    --self.ArmyMemEditSortPageVM:UpdateCategoryList(self.MyArmyInfo.Categories)
end

--- 修改成员分组
---@param RoleIDs Array @成员ID
---@param TClassID number @目标分组ID
function ArmyMemberPageVM:EditMemClassNameByRoleIDs(RoleIDs, TClassID)
    for _, RoleID in ipairs(RoleIDs) do
        local MemberVM = self.MemberList:Find(function(Element)
            return Element.RoleID == RoleID
        end)
        if MemberVM ~= nil then
            MemberVM:UpdateCategoryID(TClassID)
        end
    end
end

--- 修改分组名称变动成员员分组名称
---@param CategoryID number @分组ID
---@param Name string @修改后名称
function ArmyMemberPageVM:UpdateMemberCategoryName(CategoryID, Name)
    local Result = self.MemberList:FindAll(function(Element)
        return Element.CategoryID == CategoryID
    end)
    for _, MemberVM in pairs(Result) do
        MemberVM.CategoryName = Name
    end
    local MemberCategoryVM = self.CategoryList:Find(function(Element)
        return Element.ID == CategoryID
    end)
    if MemberCategoryVM then
        MemberCategoryVM.Name = Name
    end
    self:UpdateCateGoryName(CategoryID, Name)

    --self.ArmyMemEditSortPageVM:UpdateCategoryName(CategoryID, Name)
end

--- 调整成员分组
function ArmyMemberPageVM:UpdateMemberCategory(RoleID, CategoryID)
    local CategoryList = self.CategoryList
    local MemberVM = self.MemberList:Find(function(Element)
        return Element.RoleID == RoleID
    end)
    if nil == MemberVM then
        return
    end
    local OldCategoryID = MemberVM.CategoryID
    if MemberVM then
        MemberVM:UpdateCategoryID(CategoryID)
    end
    local OldMemberCategoryVM = CategoryList:Find(function(Element)
        return Element.ID == OldCategoryID
    end)
    local OldMemberNum
    ---旧阶级被删除，数量置为0
    if OldMemberCategoryVM and OldMemberCategoryVM.MemberNum then
        OldMemberNum = OldMemberCategoryVM.MemberNum
        OldMemberNum = OldMemberNum - 1
    else
        OldMemberNum = 0
    end
    local MemberCategoryVM = CategoryList:Find(function(Element)
        return Element.ID == CategoryID
    end)
    if OldMemberNum < 0 then
        OldMemberNum = 0
        _G.FLOG_ERROR("[ArmyMemberPageVM] UpdateMemberCategory OldMemberCategoryVM.MemberNum < 0")
    end
    if OldMemberCategoryVM and OldMemberCategoryVM.MemberNum then
        OldMemberCategoryVM.MemberNum = OldMemberNum
    end
    if nil == MemberCategoryVM then
        return
    end
    MemberCategoryVM.MemberNum = MemberCategoryVM.MemberNum + 1

    local SelfMemInfo = ArmyMgr:GetSelfRoleInfo()
    if RoleID == SelfMemInfo.RoleID then
        self:UpdateSelfData()
    end
    --self.ArmyMemEditPartPageVM:UpdateCategoryList(self.MyArmyInfo.Categories)
end

function ArmyMemberPageVM:UpdateCateGoryName(CategoryID, Name)
    local CategoryData = table.find_by_predicate(self.MyArmyInfo.Categories, function(Element)
        return Element.ID == CategoryID
    end)
    if CategoryData ~= nil then
        CategoryData.Name = Name
    end
end

--- 修改分组Icon
function ArmyMemberPageVM:UpdateCategoryIcon(CategoryData)
    -- 更新分组列表
    --self.ArmyMemEditSortPageVM:UpdateCategoryList(self.MyArmyInfo.Categories)
    -- 更新分组权限编辑分组Icon
    ---分组编辑界面打开时再更新数据
    --self.ArmyMemEditPowerPageVM:UpdateVMByCategoryData(CategoryData)
    local CategoryID = CategoryData.ID
    local CategoryIconID = CategoryData.IconID
    -- 更新分组成员列表Icon
    --self.ArmyMemEditPartPageVM:UpdateClassIconByID(CategoryID, CategoryIconID)
    local MemberVMs = self.MemberList:FindAll(function(Element)
        return Element.CategoryID == CategoryID
    end)
    for _, VM in ipairs(MemberVMs or {}) do
        VM:UpdateCategoryID(CategoryID)
    end
    local CategoryVM = self.CategoryList:Find(function(Element)
        return Element.ID == CategoryID
    end)
    if CategoryVM then
        CategoryVM:SetIcon(CategoryIconID)
    end
end

--- 删除分组
function ArmyMemberPageVM:RemoveCategoryVMByID(ID)
    self.CategoryList:RemoveByPredicate(function(Element)
        return Element.ID == ID
    end)
    local Items = self.CategoryList:GetItems()
    local LastCIndex = self.CategoryIndex
    local SelectedItem = Items[LastCIndex]
    self.CategoryIndex = -1
    local NewSelectedItem
    if SelectedItem == nil then
        LastCIndex = #Items
    end
    NewSelectedItem = Items[LastCIndex]
    if nil ~= NewSelectedItem then
        self:SelectedCategoryPermissionsInfo(LastCIndex, NewSelectedItem)
        NewSelectedItem.bSelected = true
    end
end

--- 更新入队申请列表
function ArmyMemberPageVM:UpdateJoinArmyRoleList(Roles)
    if Roles == nil or #Roles < ArmyDefine.One then
        --self.JoinApplyList:UpdateList()
        self.bApplyEmpty = true
        self.JoinApplyList:Clear()
    else
        self.bApplyEmpty = false
        self.JoinApplyList:EmptyItems()
        self:UpdateApplyJoinList(Roles)
    end
end

--- 添加分页数据
function ArmyMemberPageVM:AddApplyJoinArmyRoleList(Roles)
    for _, RoleData in ipairs(Roles) do
        self:AddApplyRoleJoinItem(RoleData)
    end
end

function ArmyMemberPageVM:UpdateApplyJoinList(Roles)
    local RoleIDs = {}
    for _, RoleData in ipairs(Roles) do
        table.insert(RoleIDs, RoleData.RoleID)
    end
    RoleInfoMgr:QueryRoleSimples(
        RoleIDs,
        function()
            for i, RoleID in ipairs(RoleIDs) do
                local Role = RoleInfoMgr:FindRoleVM(RoleID, false)
                -- 特殊处理，屏蔽掉无效玩家
                if Role.Name ~= "" then
                    self:AddJoinApplyVM(Roles[i], Role)
                end
            end
        end,
        nil,
        false
    )
end

--- 添加入队申请记录
function ArmyMemberPageVM:AddApplyRoleJoinItem(Role)
    RoleInfoMgr:QueryRoleSimple(
        Role.RoleID,
        function(_, RoleVM)
            self:AddJoinApplyVM(Role, RoleVM)
        end,
        nil,
        false
    )
end

function ArmyMemberPageVM:AddJoinApplyVM(ApplyJoinData, RoleVM)
    ApplyJoinData.VM = RoleVM
    ApplyJoinData.RoleID = RoleVM.RoleID
    ApplyJoinData.Name = RoleVM.Name
    ApplyJoinData.OnlineStatusName = RoleVM.OnlineStatusName
    ApplyJoinData.OnlineStatusIcon = RoleVM.OnlineStatusIcon
    ApplyJoinData.IsOnline = RoleVM.IsOnline
    ApplyJoinData.HeadIcon = RoleVM.HeadIcon
    --需要考虑跨界情况
    --ApplyJoinData.MapResName = RoleVM.MapResName
    ApplyJoinData.LogoutTime = RoleVM.LogoutTime
    ApplyJoinData.Level = RoleVM.Level

    ---跨界处理
    local CurWorldID = _G.PWorldMgr:GetCurrWorldID()
    local RoleCurWorldID = RoleVM.CurWorldID
    ---如果没有跨界
    if RoleCurWorldID == 0 then
        RoleCurWorldID = RoleVM.WorldID
    end
    if RoleCurWorldID ~= CurWorldID then
        ApplyJoinData.MapResName = _G.LoginMgr:GetMapleNodeName(RoleCurWorldID)
        ApplyJoinData.StateType = StateType.DiffServer
    else
        ApplyJoinData.MapResName = RoleVM.MapResName
        ApplyJoinData.StateType = StateType.None
    end

    local ProfIcon = RoleInitCfg:FindRoleInitProfIcon(RoleVM.Prof)
    if ProfIcon then
        ApplyJoinData.ProfIcon = ProfIcon
    else
        ApplyJoinData.ProfIcon = ""
    end
    local ItemVM = self.JoinApplyList:Find(function(Element)
        return Element.RoleID == ApplyJoinData.RoleID
    end)
    if ItemVM == nil then
        self.JoinApplyList:AddByValue(ApplyJoinData)
        self.JoinApplyList:Sort(ApplyRolesSortFunc)
    else
        ItemVM:UpdateVM(ApplyJoinData)
        self.JoinApplyList:Sort(ApplyRolesSortFunc)
    end
    local Items = self.JoinApplyList:GetItems()
    self.bApplyEmpty = table.length(Items) == ArmyDefine.Zero
end

--- 删除入队申请记录
---@param RoleID integer @玩家自己的角色ID
function ArmyMemberPageVM:RemoveApplyRoleJoinItem(RoleID)
    self.JoinApplyList:RemoveByPredicate(function(Element)
        return Element.RoleID == RoleID
    end)
    local Len = #self.JoinApplyList:GetItems()
    if Len == ArmyDefine.Zero then
        self.bApplyEmpty = true
    end
end

function ArmyMemberPageVM:UpdateJoinListByRemoveRoleIds(RoleIDs)
    for _, RoleID in ipairs(RoleIDs) do
        self:RemoveApplyRoleJoinItem(RoleID)
    end
end

--- 同意入队申请处理
function ArmyMemberPageVM:AcceptRoleJoinForRoleData(RoleData)
    self:AddMemberItem(RoleData)
    --self.ArmyMemEditPartPageVM:UpdateCategoryList(self.MyArmyInfo.Categories)
    --- 判断是否有同意申请权限
    self:RemoveApplyRoleJoinItem(RoleData.Simple.RoleID)
end

--- 拒绝入队申请处理
function ArmyMemberPageVM:RefuseRoleJoinForRoleIds(RoleIds)
    for _, RoleID in ipairs(RoleIds) do
        self:RemoveApplyRoleJoinItem(RoleID)
    end
end

--- 修改分组权限
function ArmyMemberPageVM:EditCategoryPermission(CategoryID, Types)
    local Categories = self.MyArmyInfo.Categories
    local CategoryData = ArmyMgr:GetCategoryDataByID(CategoryID)
    local CategoryVM = self.CategoryList:Find(function(Element)
        return Element.ID == CategoryID
    end)
    CategoryVM:UpdateVM(CategoryData)
    -- if CategoryID == Categories[self.CategoryIndex].ID then
    --     self:UpdateInfoDec(Types)
    -- end
    ---分组编辑界面打开时再更新数据
    --self.ArmyMemEditPowerPageVM:UpdateEntryList(CategoryData.ShowIndex + 1)
    --self.ArmyMemEditPowerPageVM:SetPermissionsInfo(ArmyDefine.One)
    self:SetPermissionsPageIndex(self.PermissionsPageIndex)
    self:UpdateSelfData()
    self:CloseCategoryEdit()
end

--- 修改分组权限
function ArmyMemberPageVM:EditCategoryPermissions(CategoryPermissions)
    local Categories = self.MyArmyInfo.Categories
    for _, CategoryPermission in ipairs(CategoryPermissions) do
        local CategoryData = ArmyMgr:GetCategoryDataByID(CategoryPermission.CategoryID)
        local CategoryVM = self.CategoryList:Find(function(Element)
            return Element.ID == CategoryPermission.CategoryID
        end)
        if CategoryVM == nil then
            break
        end
        CategoryVM:UpdateVM(CategoryData)
        -- if Categories[self.CategoryIndex] and CategoryPermission.CategoryID == Categories[self.CategoryIndex].ID then
        --     self:UpdateInfoDec(CategoryPermission.Types)
        -- end
        ---分组编辑界面打开时再更新数据
        --self.ArmyMemEditPowerPageVM:UpdateEntryList(CategoryData.ShowIndex + 1)
    end
    ---分组编辑界面打开时再更新数据
    --self.ArmyMemEditPowerPageVM:SetPermissionsInfo(ArmyDefine.One)
    --self.ArmyMemEditPowerPageVM:SetPermissionsInfo(ArmyDefine.One)
    self:SetPermissionsPageIndex(self.PermissionsPageIndex)
    self:UpdateSelfData()
    self:CloseCategoryEdit()
end

--- 添加新的分组:
function ArmyMemberPageVM:AddCategoryData(CategoryData)
    self.CategoryList:AddByValue(CategoryData)
    self.CategoryList:Sort(ArmyDefine.ArmyCategorySortFunc)
end

--- 移除成员
---@param RoleID Array @成员ID
function ArmyMemberPageVM:RemoveArmyMember(RoleID)
    local MemberVM = self:RemoveMemberItem(RoleID)
    if MemberVM == nil then
        return
    end
    local MemberCategoryVM = self.CategoryList:Find(function(Element)
        return Element.ID == MemberVM.CategoryID
    end)
    if MemberCategoryVM and MemberCategoryVM.MemberNum then
        MemberCategoryVM.MemberNum = MemberCategoryVM.MemberNum - 1
    end

    self:UpdateExitBtnText()
end

--- 转移部队长
function ArmyMemberPageVM:RefreshTransferLeaderData(NewLeaderData, OldLeaderData)
    local MemberList = self.MemberList
    local NewLeaderMemberVM = MemberList:Find(function(Element)
        return Element.RoleID == NewLeaderData.RoleID
    end)
    if NewLeaderMemberVM then
        NewLeaderMemberVM:UpdateCategoryID(NewLeaderData.CategotyID)
    end
    if OldLeaderData then
        local OldLeaderMemberVM = MemberList:Find(function(Element)
            return Element.RoleID == OldLeaderData.RoleID
        end)
        if OldLeaderMemberVM then
            OldLeaderMemberVM:UpdateCategoryID(OldLeaderData.CategotyID)
        end
    end
    self:UpdateSetIsLeader(NewLeaderData.RoleID == MajorUtil.GetMajorRoleID())


    self:UpdateSelfData()
end

--- 分组排序
function ArmyMemberPageVM:MembersCategorySort()
    --local Items = self.MemberList:GetItems()
    self.bSortMode = SortMode.Category
    self.IsPriorityHighCategory = not self.IsPriorityHighCategory
    -- local SortFunc = function(A, B)
    --     if A.bOnline == B.bOnline then
    --         if A.CategoryShowIndex == B.CategoryShowIndex then
    --             return A.JobName > B.JobName
    --         else
    --             if self.IsPriorityHighCategory then
    --                 return A.CategoryShowIndex < B.CategoryShowIndex
    --             else
    --                 return A.CategoryShowIndex > B.CategoryShowIndex
    --             end
    --         end
    --     else
    --         return A.bOnline
    --     end
    -- end
    local SortFunc = self:GetSortFunc(self.bSortMode)
    self.MemberList:Sort(SortFunc)
    if self.IsPriorityHighCategory then
        -- LSTR string:已切换分组高到低排序
        MsgTipsUtil.ShowTips(LSTR(910104))
    else
        -- LSTR string:已切换分组低到高排序
        MsgTipsUtil.ShowTips(LSTR(910103))
    end
end

--- 等级排序
function ArmyMemberPageVM:MembersLevelSort()
    self.IsPriorityHighLevel = not self.IsPriorityHighLevel
    self.bSortMode = SortMode.Level
    -- local SortFunc = function(A, B)
    --     if A.bOnline == B.bOnline then
    --         if A.JobName == B.JobName then
    --             return A.CategoryShowIndex < B.CategoryShowIndex
    --         else
    --             if self.IsPriorityHighLevel then
    --                 return A.JobName > B.JobName
    --             else
    --                 return A.JobName < B.JobName
    --             end
    --         end
    --     else
    --         return A.bOnline
    --     end
    -- end
    local SortFunc = self:GetSortFunc(self.bSortMode)
    self.MemberList:Sort(SortFunc)
    if self.IsPriorityHighLevel then
        -- LSTR string:已切换等级高到低排序
        MsgTipsUtil.ShowTips(LSTR(910106))
    else
        -- LSTR string:已切换等级低到高排序
        MsgTipsUtil.ShowTips(LSTR(910105))
    end
end

function ArmyMemberPageVM:ReSetSort()
    self.IsPriorityHighCategory = true
    self.IsPriorityHighLevel = true   
end

function ArmyMemberPageVM:OpenCategoryEditPanel()
    self.ArmyMemEditPowerPageVM:UpdateInfo()
    UIViewMgr:ShowView(UIViewID.ArmyCategoryEditPanel)
end

function ArmyMemberPageVM:UpdataEditCategoryPanelData(Categories)
    self.ArmyMemEditPowerPageVM:UpdataEditCategoryPanelData(Categories, true)
end

function ArmyMemberPageVM:UpdataEditCategoryPanelMemberData()
    self.ArmyMemEditPowerPageVM:UpdataEditCategoryPanelMemberData()
end

function ArmyMemberPageVM:GetCurEditCategoryID()
    return self.ArmyMemEditPowerPageVM:GetCurCategoryID()
end

function ArmyMemberPageVM:UpdataCurEditMemberList(Members, CategoryID)
    self.ArmyMemEditPowerPageVM:UpdataMemberDataAndSaveCheckItem(Members, CategoryID)
end

---获取新增成员的数据，用于修正分组数据
function ArmyMemberPageVM:UpdataMemberItemData(MemberSimpleData)
    local MemberData = table.clone(table.find_by_predicate(self.Members, function(Element)
        return Element.Simple.RoleID == MemberSimpleData.Simple.RoleID
    end))
    MemberData.Simple = MemberSimpleData.Simple
    self:AddMemberItem(MemberData)
end

function ArmyMemberPageVM:ClearbLoadingRoleInfoState()
    ---防止bLoadingRoleInfo阻碍更新逻辑
    if self.LoadingRoleInfoTimer then
        _G.TimerMgr:CancelTimer(self.LoadingRoleInfoTimer)
        self.LoadingRoleInfoTimer = nil
    end
    bLoadingRoleInfo = false
end

--- 只更新成员公会数据(目前只有阶级，加入时间无需更新)，增/删走其他协议主动下发
function ArmyMemberPageVM:UpdataMemberListByViewSwitch(Members)
    self.Members = Members
    for _, Member in ipairs(Members) do
        local RoleID = Member.Simple.RoleID
        local MemberVM = self.MemberList:Find(function(Element)
            return Element.RoleID == RoleID
        end)
        if MemberVM and MemberVM:GetCategoryID() ~= Member.CategoryID then
            MemberVM:UpdateCategoryID()
        end
    end
end

---@param CurSortMode SortMode --当前排序模式
---@param IsHighToLow boolean --IsHighToLow不能传nil做为bool值，传nil会使用VM中缓存的高低排序顺序
function ArmyMemberPageVM:GetSortFunc(CurSortMode, IsHighToLow)
    local bNegation = IsHighToLow
    local SortFunc 
    if CurSortMode == SortMode.Level then
        if bNegation == nil then
            bNegation = self.IsPriorityHighLevel
        end
        SortFunc = function(A, B)
            if A.bOnline == B.bOnline then
                if A.JobName == B.JobName then
                    return A.CategoryShowIndex < B.CategoryShowIndex
                else
                    if bNegation then
                        return A.JobName > B.JobName
                    else
                        return A.JobName < B.JobName
                    end
                end
            else
                return A.bOnline
            end
        end
    elseif CurSortMode == SortMode.Category then
        if bNegation == nil then
            bNegation = self.IsPriorityHighCategory
        end
        SortFunc = function(A, B)
            if A.bOnline == B.bOnline then
                if A.CategoryShowIndex == B.CategoryShowIndex then
                    return A.JobName > B.JobName
                else
                    if bNegation then
                        return A.CategoryShowIndex < B.CategoryShowIndex
                    else
                        return A.CategoryShowIndex > B.CategoryShowIndex
                    end
                end
            else
                return A.bOnline
            end
        end
    end
    return SortFunc
end

function ArmyMemberPageVM:SetGroupBtnState()
    local ChannelID = _G.LoginMgr:GetChannelID()
    _G.FLOG_INFO("[ArmyMemberPageVM:SetGroupBtnState] ChannelID:%d", ChannelID)

    if ChannelID == MSDKDefine.ChannelID.WeChat then
        self.GroupIconPath = GroupDefine.WxIconPath
    elseif ChannelID == MSDKDefine.ChannelID.QQ then
        self.GroupIconPath = GroupDefine.QQIconPath
    else
        self.GroupIconPath = ""
    end
end

function ArmyMemberPageVM:SetGroupBtnText(TextStr)
    _G.FLOG_INFO("[ArmyMemberPageVM:SetGroupBtnText] %s", TextStr)
    self.GroupBtnText = TextStr or ""
end

return ArmyMemberPageVM
