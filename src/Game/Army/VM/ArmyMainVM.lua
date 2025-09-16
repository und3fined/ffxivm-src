---
--- Author: daniel
--- DateTime: 2023-02-28 10:08
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ArmyInUIType = ArmyDefine.ArmyInUIType
local ArmyOutUIType = ArmyDefine.ArmyOutUIType
local ArmyInviteOutUIType = ArmyDefine.ArmyInviteOutUIType

local ArmyJoinPanelVM = require("Game/Army/VM/ArmyJoinPanelVM")
local ArmyCreatePanelVM = require("Game/Army/VM/ArmyCreatePanelVM")
local ArmyMemberPanelVM = require("Game/Army/VM/ArmyMemberPanelVM")
local ArmyInfoPageVM = require("Game/Army/VM/ArmyInfoPageVM")
local ArmyStatePanelVM = require("Game/Army/VM/ArmyStatePanelVM")
local ArmyWelfarePanelVM = require("Game/Army/VM/ArmyWelfarePanelVM")
local ArmyDepotPanelVM = require("Game/Army/VM/ArmyDepotPanelVM")
local ArmySpecialEffectsPanelVM = require("Game/Army/VM/ArmySpecialEffectsPanelVM")
local ArmySignPanelVM = require("Game/Army/VM/ArmySignPanelVM")
local ArmyInformationPanelVM = require("Game/Army/VM/ArmyInformationPanelVM")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCS = require("Protocol/ProtoCS")

local UIViewID = _G.UIViewID

local UIViewMgr



---@class ArmyMainVM : UIViewModel
---@field bCreatePanel boolean @是否显示创建面板
---@field bJoinPanel boolean @是否显示加入面板
---@field bMemberPanel boolean @是否显示申请/分组/部队成员面板
---@field bInfoPanel boolean @是否显示部队信息面板
---@field bStatePanel boolean @是否显示状态面板

local ArmyMainVM = LuaClass(UIViewModel)

---Ctor
function ArmyMainVM:Ctor()
end

function ArmyMainVM:OnInit()
    self.bCreatePanel = false
    self.bJoinPanel = false
    self.bMemberPanel = false
    self.bInfoPanel = false
    self.bStatePanel = false
    self.bWelfarePanel = false
    self.bSignDataPanel = false
    self.bSignInvitePanel = false
    self.bInformationPanel = false
    self.bEmptyPanel = false
    self.ArmyID = 0
    self.LastQuitTime = 0
    self.BGIcon = ""
    self.GrandCompanyType = 0
    self.BGMaskColor = "0000007f"
    self.IsMask = true
    self.IsShowChat = true
    UIViewMgr = _G.UIViewMgr

    self.ArmyJoinPanelVM = ArmyJoinPanelVM.New()
    self.ArmyJoinPanelVM:Init()

    self.ArmyCreatePanelVM = ArmyCreatePanelVM.New()
    self.ArmyCreatePanelVM:Init()

    self.ArmyMemberPanelVM = ArmyMemberPanelVM.New()
    self.ArmyMemberPanelVM:Init()

    self.ArmyInfoPageVM = ArmyInfoPageVM.New()
    self.ArmyInfoPageVM:Init()

    self.ArmyStatePanelVM = ArmyStatePanelVM.New()
    self.ArmyStatePanelVM:Init()

    self.ArmyWelfarePanelVM = ArmyWelfarePanelVM.New()
    self.ArmyWelfarePanelVM:Init()

    self.ArmyDepotPanelVM = ArmyDepotPanelVM.New()
    self.ArmyDepotPanelVM:Init() 

    self.ArmySpecialEffectsPanelVM = ArmySpecialEffectsPanelVM.New()
    self.ArmySpecialEffectsPanelVM:Init() 

    self.ArmySignPanelVM = ArmySignPanelVM.New()
    self.ArmySignPanelVM:Init() 

    self.ArmyInformationPanelVM = ArmyInformationPanelVM.New()
    self.ArmyInformationPanelVM:Init() 
end

function ArmyMainVM:OnReset()
    self.ArmyCreatePanelVM:OnReset()
end

function ArmyMainVM:OnBegin()
    self.ArmyJoinPanelVM:OnBegin()
    self.ArmyCreatePanelVM:OnBegin()
    self.ArmyMemberPanelVM:OnBegin()
    self.ArmyInfoPageVM:OnBegin()
    self.ArmyStatePanelVM:OnBegin()
    self.ArmyWelfarePanelVM:OnBegin()
    self.ArmyDepotPanelVM:OnBegin()
    self.ArmySpecialEffectsPanelVM:OnBegin()
    self.ArmySignPanelVM:OnBegin()
    self.ArmyInformationPanelVM:OnBegin() 
end

function ArmyMainVM:OnEnd()
    self.ArmyJoinPanelVM:OnEnd()
    self.ArmyCreatePanelVM:OnEnd()
    self.ArmyMemberPanelVM:OnEnd()
    self.ArmyInfoPageVM:OnEnd()
    self.ArmyStatePanelVM:OnEnd()
    self.ArmyWelfarePanelVM:OnEnd()
    self.ArmyDepotPanelVM:OnEnd()
    self.ArmySpecialEffectsPanelVM:OnEnd()
    self.ArmySignPanelVM:OnEnd()
    self.ArmyInformationPanelVM:OnEnd() 
end

function ArmyMainVM:OnShutdown()
    self.ArmyID = nil
    self.LastQuitTime = nil
    self.ArmyJoinPanelVM:OnShutdown()
    self.ArmyCreatePanelVM:OnShutdown()
    self.ArmyMemberPanelVM:OnShutdown()
    self.ArmyInfoPageVM:OnShutdown()
    self.ArmyStatePanelVM:OnShutdown()
    self.ArmyWelfarePanelVM:OnShutdown()
    self.ArmyDepotPanelVM:OnShutdown()
    self.ArmySpecialEffectsPanelVM:OnShutdown()
    self.ArmySignPanelVM:OnShutdown()
    self.ArmyInformationPanelVM:OnShutdown() 
end

function ArmyMainVM:GetJoinPanelVM()
    return self.ArmyJoinPanelVM
end

function ArmyMainVM:GetCreatePanelVM()
    return self.ArmyCreatePanelVM
end

function ArmyMainVM:GetMemberPanelVM()
    return self.ArmyMemberPanelVM
end

function ArmyMainVM:GetArmyInfoPageVM()
    return self.ArmyInfoPageVM
end

function ArmyMainVM:GetStatePanelVM()
    return self.ArmyStatePanelVM
end

function ArmyMainVM:GetWelfarePanelVM()
    return self.ArmyWelfarePanelVM
end

function ArmyMainVM:GetDepotPanelVM()
    return self.ArmyDepotPanelVM
end

function ArmyMainVM:GetArmySpecialEffectsPanelVM()
    return self.ArmySpecialEffectsPanelVM
end

function ArmyMainVM:GetArmySignPanelVM()
    return self.ArmySignPanelVM
end

function ArmyMainVM:GetArmyInformationPanelVM()
    return self.ArmyInformationPanelVM
end

function ArmyMainVM:SetMenuSelectedIndex(ParentKey, ChildKey)
    if self.ArmyID > 0 then
        self.bCreatePanel = false
        self.bEmptyPanel = false
        self.bJoinPanel = false
        self.bSignInvitePanel = false
        self.bSignDataPanel = false
        self.bMemberPanel = ParentKey == ArmyInUIType.MemberPage
        --print("ArmyMainVM:SetMenuSelectedIndex", ParentKey, ChildKey, self.bMemberPanel, self.bInfoPanel, self.bStatePanel)
        self.bInfoPanel = ParentKey == ArmyInUIType.InfoPage
        self.bStatePanel = ParentKey == ArmyInUIType.StatePage
        self.bWelfarePanel = ParentKey == ArmyInUIType.WelfarePage
        self.bInformationPanel = ParentKey == ArmyInUIType.InformationPage
        self.IsShowChat = true
        if ParentKey == ArmyInUIType.MemberPage then
            self.ArmyMemberPanelVM:SetPageType(ChildKey)
            ArmyMainVM:SetIsMask(true)
        elseif ParentKey == ArmyInUIType.InfoPage then
            if self.IsOpenPanel then
                self:SetIsOpenPanel(false)
            else
                --_G.ArmyMgr:SendGroupQueryGroupBaseInfo()
                local RoleID = MajorUtil.GetMajorRoleID()
                _G.ArmyMgr:QueryArmyArmyBasePanelInfo(RoleID, ArmyDefine.ArmyInfoType.Info)
            end
            ArmyMainVM:SetIsMask(true)
        elseif ParentKey == ArmyInUIType.StatePage then
            ArmyMainVM:SetIsMask(true)
        elseif ParentKey == ArmyInUIType.WelfarePage then
            ArmyMainVM:SetIsMask(false)
        elseif ParentKey == ArmyInUIType.InformationPage then
            local RoleID = MajorUtil.GetMajorRoleID()
            _G.ArmyMgr:QueryArmyArmyBasePanelInfo(RoleID, ArmyDefine.ArmyInfoType.Profile)
            ArmyMainVM:SetIsMask(true)
        end
    else
        ---屏蔽加入部队界面
        self.bMemberPanel = false
        self.bInfoPanel = false
        self.bStatePanel = false
        self.bWelfarePanel = false
        self.bInformationPanel = false
        local IsRestricted = _G.ArmyMgr:GetIsRestrictedArmyPanel()
        ---被限制的解锁模式，只允许看邀请界面
        if IsRestricted then
            self.bJoinPanel = ParentKey == ArmyInviteOutUIType.ArmyInvite
            self.bCreatePanel = false
            self.bEmptyPanel = false
            self.bSignInvitePanel = false
            self.bSignDataPanel = false
            self.IsShowChat = false
            if ParentKey == ArmyInviteOutUIType.ArmyInvite then
                _G.ArmyMgr:SendArmyGetInviteListMsg()
                self.ArmyJoinPanelVM:ShowView(ArmyOutUIType.ArmyInvite)
                ArmyMainVM:SetIsMask(true)
            elseif ParentKey == ArmyInviteOutUIType.ArmySign then
                _G.ArmyMgr:SendGroupSignQueryInvites()
                ---等待服务器登录下发状态处理
                local IsGivePeition= self.ArmyCreatePanelVM:GetIsGivePeition()
                local IsSign = self.ArmySignPanelVM:GetIsSign()
                if IsGivePeition then
                    ---已领取组建书，显示空界面
                    self.bSignInvitePanel = true
                else
                    ---已署名，显示署名数据界面
                    self.bSignDataPanel = IsSign
                    ---未署名，显示署名邀请列表
                    self.bSignInvitePanel = not IsSign
                end
            end
        else
            local ArmyState = _G.ArmyMgr:GetArmyState()
            self.bCreatePanel = ParentKey == ArmyOutUIType.ArmyCreate and ArmyState ~= ProtoCS.RoleGroupState.RoleGroupStateSignedOtherPetition
            self.bEmptyPanel = ParentKey == ArmyOutUIType.ArmyCreate and ArmyState == ProtoCS.RoleGroupState.RoleGroupStateSignedOtherPetition
            self.bJoinPanel = ParentKey == ArmyOutUIType.ArmyJoin or ParentKey == ArmyOutUIType.ArmyInvite
            self.bSignInvitePanel = false
            self.bSignDataPanel = false
            self.IsShowChat = false
            if ParentKey == ArmyOutUIType.ArmyCreate then
                if ArmyState ~= ProtoCS.RoleGroupState.RoleGroupStateSignedOtherPetition then
                    ---署名其他部队时，创建界面显示空界面
                    _G.ArmyMgr:SendGroupPeitionQuery()
                    self.ArmyCreatePanelVM:SetData(self.ArmyID, self.LastQuitTime)
                end
                if  ArmyState ~= ProtoCS.RoleGroupState.RoleGroupStateSignedOtherPetition then
                    ArmyMainVM:SetIsMask(false)
                else
                    ArmyMainVM:SetIsMask(true)
                end
            elseif ParentKey == ArmyOutUIType.ArmyJoin then
                if self.IsOpenPanel then
                    self:SetIsOpenPanel(false)
                else
                    _G.ArmyMgr:SendArmySearchByInputMsg()
                end

                self.ArmyJoinPanelVM:ShowView(ArmyOutUIType.ArmyJoin)
                ArmyMainVM:SetIsMask(true)
            elseif ParentKey == ArmyOutUIType.ArmyInvite then
                _G.ArmyMgr:SendArmyGetInviteListMsg()
                self.ArmyJoinPanelVM:ShowView(ArmyOutUIType.ArmyInvite)
                ArmyMainVM:SetIsMask(true)
            elseif ParentKey == ArmyOutUIType.ArmySign then
                _G.ArmyMgr:SendGroupSignQueryInvites()
                ---等待服务器登录下发状态处理
                local IsGivePeition= self.ArmyCreatePanelVM:GetIsGivePeition()
                local IsSign = self.ArmySignPanelVM:GetIsSign()
                if IsGivePeition then
                    ---已领取组建书，显示空界面
                    self.bSignInvitePanel = true
                else
                    ---已署名，显示署名数据界面
                    self.bSignDataPanel = IsSign
                    ---未署名，显示署名邀请列表
                    self.bSignInvitePanel = not IsSign

                end
            end
        end
    end
    ---设置跳转数据，用于处理跳转后的选中之类的
    if self.bJoinPanel and self.SkipPanelID == ArmyDefine.ArmySkipPanelID.InvitePanel then
        local IsInvitePanel
        local IsRestricted = _G.ArmyMgr:GetIsRestrictedArmyPanel()
        if IsRestricted then
            IsInvitePanel = ParentKey == ArmyInviteOutUIType.ArmyInvite
        else
            IsInvitePanel = ParentKey == ArmyOutUIType.ArmyInvite
        end
        if IsInvitePanel and self.SkipParams then
            self.ArmyJoinPanelVM:SetInviteSkipArmyID(self.SkipParams.ArmyID, self.SkipParams.FailTipsID)
            self:SetSkipPanelData()
        end
    elseif self.bSignInvitePanel and self.SkipPanelID == ArmyDefine.ArmySkipPanelID.InviteSignPanel and self.SkipParams then
        self.ArmySignPanelVM:SetInviteSkipRoleID(self.SkipParams.RoleID, self.SkipParams.FailTipsID)
        self:SetSkipPanelData()
    end
end

--- 根据Type显示对应Panel
---@param Type menu @ArmyOutUIType
function ArmyMainVM:SetPageIndex(Type)
    if self.ArmyID > 0 then
        self.bCreatePanel = false
        self.bJoinPanel = false
        self.bMemberPanel = true
        self.ArmyMemberPanelVM:SetPageType(Type)
    else
        self.bCreatePanel = Type == ArmyDefine.ArmyOutUIType.ArmyCreate
        self.bJoinPanel = Type == ArmyDefine.ArmyOutUIType.ArmyJoin or Type == ArmyDefine.ArmyOutUIType.ArmyInvite
        self.bMemberPanel = false
        if Type == ArmyDefine.ArmyOutUIType.ArmyCreate then
            self.ArmyCreatePanelVM:SetData(self.ArmyID, self.LastQuitTime)
        elseif Type == ArmyDefine.ArmyOutUIType.ArmyJoin then
            self.ArmyJoinPanelVM:ShowView(ArmyDefine.ArmyOutUIType.ArmyJoin)
        elseif Type == ArmyDefine.ArmyOutUIType.ArmyInvite then
            self.ArmyJoinPanelVM:ShowView(ArmyDefine.ArmyOutUIType.ArmyInvite)
        end
    end
end

--- 设置部队基础信息{ArmyID, QuitTime}
---@param ArmyID number @部队ID
---@param LastQuitTime number @最后退出部队时间, 默认为0
function ArmyMainVM:SetMyArmyBasicInfo(ArmyID, LastQuitTime)
    self.ArmyID = ArmyID
    self.LastQuitTime = LastQuitTime
    ---更新一下创建界面的时间判断
    self.ArmyCreatePanelVM:SetData(self.ArmyID, self.LastQuitTime)
end

--- 离开部队 重置ArmyID和离开部队时间
function ArmyMainVM:ArmyQuit()
    self.ArmyID = 0
    self.LastQuitTime = _G.TimeUtil.GetServerTime()
    self.bCreatePanel = false
    self.bJoinPanel = false
    self.bMemberPanel = false
    self.bInfoPanel = false
    self.bStatePanel = false
end

--- 更新部队信息
---@param ArmyInfo any @部队所有信息
function ArmyMainVM:UpdateMyArmyInfo(ArmyInfo, MyCategoryData, LeaderRoleID, bLeader)
    self.ArmyInfoPageVM:UpdateArmyInfo(ArmyInfo, MyCategoryData, LeaderRoleID, bLeader)
    self:SetBGIcon(ArmyInfo.Simple.GrandCompanyType)
    self.ArmyMemberPanelVM:UpdateMyArmyInfo(ArmyInfo, MyCategoryData, bLeader)
    self.ArmyStatePanelVM:UpdateArmyStateInfo()
    self.ArmyWelfarePanelVM:UpdateArmyWelfareInfo(ArmyInfo.Simple.Level)
    if ArmyInfo.Score and ArmyInfo.Score.Count then
        self.ArmySpecialEffectsPanelVM:UpdateArmyGainNum(ArmyInfo.Score.Count)
    else
        self.ArmySpecialEffectsPanelVM:UpdateArmyGainNum(0)
    end
end

--- 更新公告信息
---@param Notice string @公告
function ArmyMainVM:UpdateNoticeInfo(Notice)
    self.ArmyInfoPageVM:SetNotice(Notice)
end

--- 更新招募状态
---@param RecruitSlogan string @招募标语
---@param RecruitStatus number @招募状态
function ArmyMainVM:UpdateRecruitInfo(RecruitSlogan, RecruitStatus)
    self.ArmyInfoPageVM:SetRecruitInfo(RecruitSlogan, RecruitStatus)
end

--- 更新部队动态信息
---@param ArmyLogs any @部队动态列表
function ArmyMainVM:UpdateArmyLogs(ArmyLogs)
    self.ArmyInfoPageVM:UpdateArmyLogs(ArmyLogs)
end

function ArmyMainVM:UpdateDynamicLogs(ArmyLogs)
    self.ArmyInfoPageVM:UpdateDynamicLogs(ArmyLogs)
end

function ArmyMainVM:AddArmyLogs(ArmyLogs)
    self.ArmyInfoPageVM:AddArmyLogs(ArmyLogs)
end

--- 更新部队集合
---@param Armys any @部队集合
function ArmyMainVM:UpdateArmyList(Offset, Armys)
    local JoinPanelVM = self.ArmyJoinPanelVM
    if JoinPanelVM == nil then
        return
    end
    if Offset == ArmyDefine.Zero then
        JoinPanelVM:UpdateJoinArmyList(Armys)
        local JoinPageVM = JoinPanelVM:GetArmyJoinPageVM()
        local ItemData = JoinPageVM:GetCurSelectedItemData()
        ---需要保证还在加入界面，否则不进行切换,防止覆盖其他界面的背景设置
        if ItemData and self.bJoinPanel and JoinPanelVM:GetbJoinPage() then
            ArmyMainVM:SetBGIcon(ItemData.GrandCompanyType)
        end
    else
        JoinPanelVM:AddJoinArmysToList(Armys)
    end
end

function ArmyMainVM:UpdateInviteRoleArmyList(ArmyVMList)
    local JoinPanelVM = self.ArmyJoinPanelVM
    if JoinPanelVM == nil then
        return
    end
    JoinPanelVM:UpdateInviteRoleArmyList(ArmyVMList)
end

function ArmyMainVM:AddInviteRoleArmyEntryVM(ArmyEntryVM, Count)
    self.ArmyJoinPanelVM:AddInviteRoleArmyEntryVM(ArmyEntryVM, Count)
end

--- 删除部队邀请列表中部队信息
function ArmyMainVM:RemoveArmyInviteListByArmyIDs(ArmyIDs)
    self.ArmyJoinPanelVM:RemoveArmyInviteListByArmyIDs(ArmyIDs)
end

--- 更新申请加入部队的Role集合
---@param Roles any @Role集合
function ArmyMainVM:UpdateApplyJoinArmyRoleList(Roles)
    self.ArmyMemberPanelVM:UpdateApplyJoinArmyRoleList(Roles)
end

function ArmyMainVM:AddApplyJoinArmyRoleList(Roles)
    self.ArmyMemberPanelVM:AddApplyJoinArmyRoleList(Roles)
end

function ArmyMainVM:AcceptRoleJoinForRoleData(Role)
    self.ArmyMemberPanelVM:AcceptRoleJoinForRoleData(Role)
    self.ArmyInfoPageVM:UpdateMemberNum()
end

function ArmyMainVM:RefuseRoleJoinForRoleIds(RoleIds)
    self.ArmyMemberPanelVM:RefuseRoleJoinForRoleIds(RoleIds)
end

function ArmyMainVM:EditCategoryPermission(CategoryID, Types)
    self.ArmyMemberPanelVM:EditCategoryPermission(CategoryID, Types)
end

function ArmyMainVM:EditCategoryPermissions(CategoryPermissions)
    self.ArmyMemberPanelVM:EditCategoryPermissions(CategoryPermissions)
    if UIViewMgr:IsViewVisible(UIViewID.ArmyDepotPanel) then
        self.ArmyDepotPanelVM:UpdateDepotPermissionsStatus()
    end
end

function ArmyMainVM:AddCategoryData(Categories, NewCategory)
    self.ArmyMemberPanelVM:AddCategoryData(Categories, NewCategory)
end

--- 更新转让部队数据
function ArmyMainVM:RefreshTransferLeaderData(NewLeaderData, OldLeaderData)
    self.ArmyInfoPageVM:SetLeaderID(NewLeaderData.Simple.RoleID)
    self.ArmyMemberPanelVM:RefreshTransferLeaderData(NewLeaderData, OldLeaderData)
end

function ArmyMainVM:UpdateMemberCategory(RoleId, CategoryID)
    self.ArmyMemberPanelVM:UpdateMemberCategory(RoleId, CategoryID)
    if UIViewMgr:IsViewVisible(UIViewID.ArmyDepotPanel) then
        self.ArmyDepotPanelVM:UpdateDepotPermissionsStatus()
    end
end

function ArmyMainVM:UpdateCategoryName(CategoryID, Name)
    if CategoryID == ArmyDefine.LeaderCID then
        self.ArmyInfoPageVM:SetCaptainCategoryName(Name)
    end
    self.ArmyMemberPanelVM:UpdateCategoryName(CategoryID, Name)
end

function ArmyMainVM:UpdateCategoryIcon(CategoryData)
    self.ArmyMemberPanelVM:UpdateCategoryIcon(CategoryData)
end

function ArmyMainVM:UpdateArmyName(Name, EditTime)
    ---界面名称更新只响应自己编辑/界面切换更新，不响应名称变化推送
    if EditTime then
        self.ArmyInfoPageVM:SetName(Name, EditTime)
    end
end

function ArmyMainVM:UpdateArmyShortName(Alias, EditTime)
    ---界面简称更新只响应自己编辑/界面切换更新，不响应简称变化推送
    if EditTime then
        self.ArmyInfoPageVM:SetShortName(Alias, EditTime)
    end
end

function ArmyMainVM:UpdateArmyEmblem(Emblem, EditTime)
    self.ArmyInfoPageVM:SetBadgeData(Emblem, EditTime)
end

function ArmyMainVM:UpdateCategory()
    self.ArmyMemberPanelVM:UpdateCategoryTree()
end
---更新数据（除成员数据，成员数据实时）
function ArmyMainVM:UpdataEditCategoryPanelData(Categories)
    self.ArmyMemberPanelVM:UpdataEditCategoryPanelData(Categories)
end
---更新分组编辑界面成员数据
function ArmyMainVM:UpdataEditCategoryPanelMemberData()
    self.ArmyMemberPanelVM:UpdataEditCategoryPanelMemberData()
end

function ArmyMainVM:RemoveCategoryByID(CategoryID, MemberTargetID, MemberIDs)
    self.ArmyMemberPanelVM:RemoveCategoryByID(CategoryID, MemberTargetID, MemberIDs)
end

function ArmyMainVM:RemoveArmyMember(RoleID)
    self.ArmyMemberPanelVM:RemoveArmyMember(RoleID)
    self.ArmyInfoPageVM:UpdateMemberNum()
end

function ArmyMainVM:UpdateJoinListByRemoveRoleIds(RoleIDs)
    self.ArmyMemberPanelVM:UpdateJoinListByRemoveRoleIds(RoleIDs)
end

function ArmyMainVM:SetCreatePanelRecruitSlogan(Text)
    self.ArmyCreatePanelVM:SetRecruitSlogan(Text)
end

--- 更新公会战绩
---@param ArmyInfo any @公会战绩
function ArmyMainVM:UpdateGroupScore(GroupScore)
    --信息界面不显示公会战绩了
    --self.ArmyInfoPageVM:UpdateArmyGainNum(GroupScore)
    self.ArmySpecialEffectsPanelVM:UpdateArmyGainNum(GroupScore)
end

--- 更新公会仓库页面
function ArmyMainVM:UpdateStorePanel()
    self.ArmyDepotPanelVM:UpdatePanelInfo()
end

--- 更新公会仓库页面
function ArmyMainVM:GetLastQuitTime()
    return self.LastQuitTime
end

function ArmyMainVM:SetBGIcon(Type)
    if Type == nil then
        return
    end
    self.GrandCompanyType = Type
    self.BGIcon = ArmyDefine.UnitedArmyTabs[Type].BigBGIcon
    self.BGMaskColor = ArmyDefine.UnitedArmyTabs[Type].MaskColor
    self.ArmySpecialEffectsPanelVM:SetGrandTypeIcon(Type)
end

function ArmyMainVM:SetArmyHideData()
    self.ArmyJoinPanelVM:SetArmyHideData()
    self:SetIsMask(true)
    ArmyMainVM:SetbCreatePanel(false)
end

function ArmyMainVM:GetCurEditMemberCategoryID()
    return self.ArmyMemberPanelVM:GetCurEditCategoryID()
end

function ArmyMainVM:UpdataCurEditMemberList(Members, CategoryID)
    self.ArmyMemberPanelVM:UpdataCurEditMemberList(Members, CategoryID)
end

function ArmyMainVM:UpdateBonusStateData(BonusStateData)
    self.ArmySpecialEffectsPanelVM:UpdateBonusStateData(BonusStateData)
    self.ArmyInfoPageVM:UpdateSEList(BonusStateData.Ups)
end

function ArmyMainVM:UpdateArmyMoneyStoreData(TotalNum, IsAnimPlay)
    self.ArmyDepotPanelVM:UpdateArmyMoneyStoreData(TotalNum, IsAnimPlay)
end

function ArmyMainVM:SetIsMask(IsMask)
    self.IsMask = IsMask
end
function ArmyMainVM:GetIsMask()
    return  self.IsMask
end

function ArmyMainVM:ArmyCreateAnimPlay(CallBack)
    self.ArmyCreatePanelVM:ArmyCreateAnimPlay(CallBack)
end

function ArmyMainVM:GetbCreatePanel()
    return self.bCreatePanel
end

function ArmyMainVM:SetbCreatePanel(bCreatePanel)
    self.bCreatePanel = bCreatePanel
end

function ArmyMainVM:GetIsOpenPanel()
    return self.IsOpenPanel
end

function ArmyMainVM:SetIsOpenPanel(IsOpenPanel)
    self.IsOpenPanel = IsOpenPanel
end

function ArmyMainVM:UpdateArmyInfoPanel(Info)
    self.ArmyInfoPageVM:UpdateArmyInfoPanelData(Info)
end

function ArmyMainVM:SetSkipPanelID(ID)
    self.SkipPanelID = ID
end

function ArmyMainVM:GetSkipPanelID()
    return self.SkipPanelID
end

function ArmyMainVM:SetSkipPanelData(ID, Params)
    self.SkipPanelID = ID
    self.SkipParams = Params
end

function ArmyMainVM:GetSkipParams()
    return self.SkipParams
end

function ArmyMainVM:SetInfoPanelIsOpenEditWin(IsOpen)
    self.ArmyInfoPageVM:SetIsOpenEditWin(IsOpen)
end

function ArmyMainVM:UpdataMembersByViewSwitch(Members)
    self.ArmyMemberPanelVM:UpdataMemberListByViewSwitch(Members)
end

function ArmyMainVM:UpdataArmyCreatePeitionData(PetitionData)
    self.ArmyCreatePanelVM:UpdataPeitionData(PetitionData)
end

function ArmyMainVM:UpdateSignData(Invites)
    self.ArmySignPanelVM:UpdateSignData(Invites)
    ---切换界面/需要加判断是否是在署名界面显示
    if self.bSignInvitePanel or self.bSignDataPanel then
        self.bSignInvitePanel = not self.ArmySignPanelVM:GetIsSign()
        self.bSignDataPanel = self.ArmySignPanelVM:GetIsSign()
    end
end

function ArmyMainVM:UpdateInformationData(Data)
    self.ArmyInformationPanelVM:UpdateInformationData(Data)
end

function ArmyMainVM:UpdateInformationByEdit(GroupProfileEdite)
    self.ArmyInformationPanelVM:UpdateDataByEdit(GroupProfileEdite)
end
return ArmyMainVM