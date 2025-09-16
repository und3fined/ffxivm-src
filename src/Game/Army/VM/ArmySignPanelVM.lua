---
--- Author: star
--- DateTime: 2023-12-31 10:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ArmySignItemVM = require("Game/Army/ItemVM/ArmySignItemVM")
local MajorUtil = require("Utils/MajorUtil")
local ArmyEditInfoHeadSlotVM = require("Game/Army/ItemVM/ArmyEditInfoHeadSlotVM")
local ArmyDefine = require("Game/Army/ArmyDefine")
local GlobalCfgType = ArmyDefine.GlobalCfgType
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TimeUtil = require("Utils/TimeUtil")
local ArmyShowInfoVM = require("Game/Army/VM/ArmyShowInfoVM")
local GrandCompanyCfg = require("TableCfg/GrandCompanyCfg")
local ProtoCS = require("Protocol/ProtoCS")
local MsgTipsUtil = require("Utils/MsgTipsUtil")


---@class ArmySignPanelVM : UIViewModel
---@field ArmySignList any @部队集合
---@field bInfoPage boolean @是否显示部队简介
---@field bAccepBtn boolean @是否显示同意按钮
---@field bRefuseBtn boolean @是否显示按钮
local ArmySignPanelVM = LuaClass(UIViewModel)

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
function ArmySignPanelVM:Ctor()
    self.bInfoPage = nil
    self.bAccepBtn = nil
    self.bRefuseBtn = nil
    self.bEmptyPanel = nil
    self.IsSign = nil
    ---已署名数据
    self.ArmyName = nil
    self.ArmyShortName = nil
    self.Emblem = nil
    self.SignList = nil
    self.GrandCompanyType = nil
    self.CreateRoleID = nil
    self.GainTime = nil
    self.MemberAmount = nil
    self.GainTimeStr = nil
    self.UnionBGIcon = nil
    self.UnionEditIcon = nil
    self.CaptainName = nil
    self.IsRoleQueryFinish = nil
    self.IsSignFull = nil
end

function ArmySignPanelVM:OnInit()
    self.CurSelectedArmyID = 0
    self.CurSelectedItemData = nil
    self.ArmySignItemVMList = {}
    self.ArmyShowInfoVM = ArmyShowInfoVM.New()
    self.ArmySignList = UIBindableList.New(ArmySignItemVM)
    self.ArmyShowInfoVM:OnInit()
    self.ArmyShowInfoVM:SetIsShowArmyLeader(true)
    self.GrandCompanyType = nil
    self.IsSign = nil
    self.ArmyName = ""
    self.ArmyShortName = ""
    self.GainTime = 0
    self.GainTimeStr = ""
    self.MemberAmount = ""
    self.SignList = UIBindableList.New( ArmyEditInfoHeadSlotVM )
    self.UnionIcon = nil
end

function ArmySignPanelVM:OnBegin()
    self.ArmyShowInfoVM:OnBegin()
end

function ArmySignPanelVM:OnEnd()
    self.ArmyShowInfoVM:OnEnd()
end

function ArmySignPanelVM:OnShutdown()
    self.ArmyShowInfoVM:OnShutdown()
    self.CurSelectedArmyID = 0
    self.CurSelectedItemData = nil
    self.ArmySignItemVMList = nil
    if self.ArmySignList then
        self.ArmySignList:Clear()
        self.ArmySignList = nil
    end
end

--- 更新受邀署名列表
function ArmySignPanelVM:UpdateSignData(Invites)
    self.IsSign = false
    ---更新部队侧边信息显隐
    local InvitesLength = 0
    if Invites then
        InvitesLength = #Invites
    end
    local bHavInvite = InvitesLength > 0
    self.bAccepBtn = bHavInvite
    self.bRefuseBtn = bHavInvite
    self.bInfoPage = bHavInvite
    ---做是否已署名判断,已署名只会有一个署名邀请（已署名）
    if InvitesLength == 1 then
        local Invite = Invites[1]
        local Signs = Invite.Signs
        local SelfRoleID = MajorUtil.GetMajorRoleID()
        for _, RoleID in ipairs(Signs) do
            if RoleID == SelfRoleID then
                self.IsSign = true
                break
            end
        end
    end
    if self.IsSign then
        _G.ArmyMgr:SetArmyState(ProtoCS.RoleGroupState.RoleGroupStateSignedOtherPetition)
        local Invite = Invites[1]
        self.ArmyName = Invite.GroupPetition.Name
        self.ArmyShortName = Invite.GroupPetition.Alias
        self.Emblem = Invite.GroupPetition.Emblem
        self.GrandCompanyType = Invite.GroupPetition.GrandCompanyType
        self.CreateRoleID = Invite.RoleID
        self.GainTime = Invite.GainTime
        ---时间文本
        local GainTimeStr = TimeUtil.GetTimeFormat("%Y/%m/%d", self.GainTime or 0)
        self.GainTimeStr =  LocalizationUtil.GetTimeForFixedFormat(GainTimeStr)


        local MemTotal = GroupGlobalCfg:GetValueByType(GlobalCfgType.GlobalCfgGroupSignNum) or 0
        self.MemberTotal = MemTotal
        local SignCount = 0
        if Invite.Signs then
            SignCount = #Invite.Signs
        end
        self.SignCount = SignCount
        if SignCount == MemTotal then
            self.IsSignFull = true
        else
            self.IsSignFull = false
        end
        local Signs = {}
        ---署名人数设置
        if Invite.Signs then
            for Index, RoleID in ipairs(Invite.Signs) do
                local Item = {RoleID = RoleID, ID = Index}
                table.insert(Signs, Item)
            end
        end
        local EmptyNum =  MemTotal - SignCount
        for i = 1, EmptyNum do
            local Item = {IsEmpty = true, ID = i}
            table.insert(Signs, Item)
        end
        -- LSTR string:署名人
        self.MemberAmount = string.format("%s %d/%d", LSTR(910335), SignCount, MemTotal)
        if self.SignList == nil then
            self.SignList = UIBindableList.New( ArmyEditInfoHeadSlotVM )
        end
        ---署名列表更新
        self.SignList:UpdateByValues(Signs)
        ---队徽更新
        self.ArmyShowInfoVM:SetData(
            self.CreateRoleID,
            self.GrandCompanyType,
            0,
            "",
            self.Emblem
        )
        ---部队长更新
        self:SetIsRoleQueryFinish(false)
        -- LSTR string:查询中...
        local function Callback(_, RoleVM)
            self.CaptainName = RoleVM.Name
            self:SetIsRoleQueryFinish(true)
        end
        _G.RoleInfoMgr:QueryRoleSimple(self.CreateRoleID, Callback, self, false)
        ---旗帜更新
        local Cfg = GrandCompanyCfg:FindCfgByKey(self.GrandCompanyType)
        if Cfg then
            self.UnionBGIcon = Cfg.BgIcon
            self.UnionEditIcon = Cfg.EditIcon
        end
    else
        if _G.ArmyMgr:GetArmyState() == ProtoCS.RoleGroupState.RoleGroupStateSignedOtherPetition then
            _G.ArmyMgr:SetArmyState(ProtoCS.RoleGroupState.RoleGroupStateInit)
        end
        self.ArmySignList:UpdateByValues(Invites)
        if nil ~= Invites then
            self.bEmptyPanel = #Invites == 0
        else
            self.bEmptyPanel = true
        end
        if not self.bEmptyPanel then
            -- 默认选中逻辑
            self:OnDefaultSelection()
        else
            if self.SkipRoleID and self.ErrorTipsID then
                MsgTipsUtil.ShowTipsByID(self.ErrorTipsID)  
                ---清理跳转选中数据
                self:ClearSkipData()
            end
        end
    end
    if self.bEmptyPanel == true then
        self:ClearData()
    end
end

--- 默认选择
function ArmySignPanelVM:OnDefaultSelection()
    local Items = {}
    if nil ~= self.ArmySignList then
        Items = self.ArmySignList:GetItems()
    end
    local bHavInvite = #Items > 0
    self.bAccepBtn = bHavInvite
    self.bRefuseBtn = bHavInvite
    self.bInfoPage = bHavInvite
    if bHavInvite then
         ---选中跳转部队
         if self.SkipRoleID then
            self:SetCurSelectedItemByRoleID(self.SkipRoleID, self.ErrorTipsID)
        elseif nil == self.CurSelectedItemData then
            ---无选中，默认选中第一个
            self:OnSelectedItem(nil, Items[1])
        else
            self:SetCurSelectedItemByRoleID(self.CurSelectedItemData.RoleID)
        end
    else
        if self.SkipRoleID and self.ErrorTipsID then
            MsgTipsUtil.ShowTipsByID(self.ErrorTipsID)  
        end
    end
    ---清理跳转选中数据
    self:ClearSkipData()
end

--- 设置部队选中的VM
function ArmySignPanelVM:OnSelectedItem(Index, ItemData)
    if ItemData ~= self.CurSelectedItemData then
        self.ArmyShowInfoVM:SetData(
            ItemData.RoleID,
            ItemData.GrandCompanyType,
            0,
            "",
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

function ArmySignPanelVM:SetArmyHideData()
    if self.CurSelectedItemData ~= nil then
        self.CurSelectedItemData:SetSelectState(false)
    end
    self.CurSelectedItemData = nil
end

function ArmySignPanelVM:GetCurSelectedItemData()
    return self.CurSelectedItemData
end

function ArmySignPanelVM:GetIsSign()
    return self.IsSign
end


function ArmySignPanelVM:GetCreateRoleID()
    return self.CreateRoleID
end

function ArmySignPanelVM:SetIsRoleQueryFinish(IsRoleQueryFinish)
    self.IsRoleQueryFinish = IsRoleQueryFinish
end


function ArmySignPanelVM:GetIsRoleQueryFinish()
    return self.IsRoleQueryFinish
end

function ArmySignPanelVM:GetCaptainName()
    return self.CaptainName or ""
end

function ArmySignPanelVM:SetCurSelectedItemByRoleID(RoleID, ErrorTipsID)
    local Items = {}
    if nil ~= self.ArmySignList then
        Items = self.ArmySignList:GetItems()
    end
    local SelectedItem
    for _, Item in ipairs(Items) do
        if Item.RoleID == RoleID then
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
    else
        if ErrorTipsID then
            MsgTipsUtil.ShowTipsByID(ErrorTipsID)  
        end
        self:OnSelectedItem(nil, Items[1])
    end
end

function ArmySignPanelVM:SetInviteSkipRoleID(RoleID, ErrorTipsID)
    self.SkipRoleID = RoleID
    self.ErrorTipsID = ErrorTipsID
end

function ArmySignPanelVM:ClearSkipData()
    self.SkipRoleID = nil
    self.ErrorTipsID = nil
end

function ArmySignPanelVM:GetGrandCompanyType()
    return self.GrandCompanyType
end

---空界面清理数据，目前只有背景图需要
function ArmySignPanelVM:ClearData()
    self.GrandCompanyType = nil
end

return ArmySignPanelVM
