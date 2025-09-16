---
--- Author: daniel
--- DateTime: 2023-03-07 16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ArmyMemberPageVM = require("Game/Army/VM/ArmyMemberPageVM")

---@class ArmyMemberPanelVM : UIViewModel
---@field bMemberPage boolean @是否显示成员面板
local ArmyMemberPanelVM = LuaClass(UIViewModel)

--- 部队里PageType
local ArmyInPageType = {
    Member = 2,
    Class = 3,
}

---Ctor
function ArmyMemberPanelVM:Ctor()
    self.bMemberPage = nil
end

function ArmyMemberPanelVM:OnInit()
    self.MyArmyInfo = nil
    self.CurPageType = nil
    self.bMemberPage = false
    self.ArmyMemberPageVM = ArmyMemberPageVM.New()
    self.ArmyMemberPageVM:OnInit()

end

function ArmyMemberPanelVM:OnBegin()
    self.ArmyMemberPageVM:OnBegin()
end

function ArmyMemberPanelVM:OnEnd()
    self.ArmyMemberPageVM:OnEnd()
end

function ArmyMemberPanelVM:OnShutdown()
    self.MyArmyInfo = nil
    self.CurPageType = nil
    self.ArmyMemberPageVM:OnShutdown()
end

function ArmyMemberPanelVM:GetArmyMemberPageVM()
    return self.ArmyMemberPageVM
end

function ArmyMemberPanelVM:SetPageType(ChildKey)
    self.bMemberPage = true
    self.ArmyMemberPageVM:SetPageIndex(ChildKey)
end

--- 更新部队信息
function ArmyMemberPanelVM:UpdateMyArmyInfo(MyArmyInfo, MyCategoryData, bLeader)
    self.MyArmyInfo = MyArmyInfo
    self.ArmyMemberPageVM:UpdateMyArmyInfo(MyArmyInfo, bLeader)
end

--- 更新入队申请列表
function ArmyMemberPanelVM:UpdateApplyJoinArmyRoleList(Roles)
    self.ArmyMemberPageVM:UpdateJoinArmyRoleList(Roles)
end

function ArmyMemberPanelVM:AddApplyJoinArmyRoleList(Roles)
    self.ArmyMemberPageVM:AddApplyJoinArmyRoleList(Roles)
end

function ArmyMemberPanelVM:AcceptRoleJoinForRoleData(Role)
    self.ArmyMemberPageVM:AcceptRoleJoinForRoleData(Role)
end

--- 拒绝入队申请
---@param RoleIds number[] 角色ID集合
function ArmyMemberPanelVM:RefuseRoleJoinForRoleIds(RoleIds)
    self.ArmyMemberPageVM:RefuseRoleJoinForRoleIds(RoleIds)
end

function ArmyMemberPanelVM:ShowArmyInfoPage()
    self:SetPageType(ArmyInPageType.ArmyInfoPage)
end

function ArmyMemberPanelVM:ShowMemberPage()
    self:SetPageType(ArmyInPageType.MemberPage)
end


--- 修改分组编辑权限Rsp
function ArmyMemberPanelVM:EditCategoryPermission(CategoryID, Types)
    self.ArmyMemberPageVM:EditCategoryPermission(CategoryID, Types)
end

--- 修改分组编辑权限Rsp
function ArmyMemberPanelVM:EditCategoryPermissions(CategoryPermissions)
    if self.ArmyMemberPageVM.bEditPowerPage == true or self.ArmyMemberPageVM.bCategoryPanel then
        self.ArmyMemberPageVM:EditCategoryPermissions(CategoryPermissions)
    end
end

--- 刷新分组
function ArmyMemberPanelVM:AddCategoryData(Categories, NewCategory)
    -- 删除更新有问题
    self.ArmyMemberPageVM:UpdateMemberCategoryTreeList(Categories)
end

--- 更新转让部队数据
---@param NewLeaderData GroupMemberFullInfo @新部队长信息
---@param OldLeaderData GroupMemberFullInfo @旧部队长信息
function ArmyMemberPanelVM:RefreshTransferLeaderData(NewLeaderData, OldLeaderData)
    self.ArmyMemberPageVM:RefreshTransferLeaderData(NewLeaderData, OldLeaderData)
end

function ArmyMemberPanelVM:UpdateMemberCategory(RoleId, CategoryID)
    self.ArmyMemberPageVM:UpdateMemberCategory(RoleId, CategoryID)
end

function ArmyMemberPanelVM:UpdateCategoryName(CategoryID, Name)
    self.ArmyMemberPageVM:UpdateMemberCategoryName(CategoryID, Name)
end

function ArmyMemberPanelVM:UpdateCategoryIcon(CategoryData)
    -- 修改部队分组数据源
    if CategoryData ~= nil then
        -- 更新分组Icon(成员列表、分组设定)
        self.ArmyMemberPageVM:UpdateCategoryIcon(CategoryData)
    else
        _G.FLOG_ERROR("CategoryID not find by ArmyData.Categories.")
    end
end

function ArmyMemberPanelVM:RemoveArmyMember(RoleID)
    self.ArmyMemberPageVM:RemoveArmyMember(RoleID)
end

function ArmyMemberPanelVM:RemoveCategoryByID(DelCategoryID, MemberTargetID, MemberIDs)
    self.ArmyMemberPageVM:RemoveCategoryByID(DelCategoryID, MemberTargetID, MemberIDs)
end

function ArmyMemberPanelVM:UpdateCategoryTree()
    --- 刷新所有 待优化self.MyArmyInfo.Categories
    self.ArmyMemberPageVM:UpdateMemberCategoryTreeList()
end

function  ArmyMemberPanelVM:UpdateJoinListByRemoveRoleIds(RoleIDs)
    self.ArmyMemberPageVM:UpdateJoinListByRemoveRoleIds(RoleIDs)
end

function ArmyMemberPanelVM:UpdataEditCategoryPanelData(Categories)
    self.ArmyMemberPageVM:UpdataEditCategoryPanelData(Categories)
end

function ArmyMemberPanelVM:UpdataEditCategoryPanelMemberData()
    self.ArmyMemberPageVM:UpdataEditCategoryPanelMemberData()
end

---获取当前正在编辑的分组ID
function ArmyMemberPanelVM:GetCurEditCategoryID()
    return self.ArmyMemberPageVM:GetCurEditCategoryID()
end
function ArmyMemberPanelVM:UpdataCurEditMemberList(Members, CategoryID)
    self.ArmyMemberPageVM:UpdataCurEditMemberList(Members, CategoryID)
end

---界面请求刷新
function ArmyMemberPanelVM:UpdataMemberListByViewSwitch(Members)
    self.ArmyMemberPageVM:UpdataMemberListByViewSwitch(Members)
end

return ArmyMemberPanelVM
