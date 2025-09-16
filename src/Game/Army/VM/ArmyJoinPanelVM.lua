---
--- Author: daniel
--- DateTime: 2023-03-08 11:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ArmyJoinArmyPageVM = require("Game/Army/VM/ArmyJoinArmyPageVM")
local ArmyInvitationPageVM = require("Game/Army/VM/ArmyInvitationPageVM")

local ArmyDefine = require("Game/Army/ArmyDefine")

---@class ArmyJoinPanelVM : UIViewModel
---@field bJoinPage boolean @是否显示加入部队UI
---@field bInvitationPage boolean @是否显示邀请UI
local ArmyJoinPanelVM = LuaClass(UIViewModel)
---Ctor
function ArmyJoinPanelVM:Ctor()
    self.bJoinPage = true
    self.bInvitationPage = false
end

function ArmyJoinPanelVM:OnInit()
    self.ArmyJoinArmyPageVM = ArmyJoinArmyPageVM.New()
    self.ArmyJoinArmyPageVM:OnInit()

    self.ArmyInvitationPageVM = ArmyInvitationPageVM.New()
    self.ArmyInvitationPageVM:OnInit()
end

function ArmyJoinPanelVM:OnBegin()
    self.ArmyJoinArmyPageVM:OnBegin()
    self.ArmyInvitationPageVM:OnBegin()
end

function ArmyJoinPanelVM:OnEnd()
    self.ArmyJoinArmyPageVM:OnEnd()
    self.ArmyInvitationPageVM:OnEnd()
end

function ArmyJoinPanelVM:OnShutdown()
    self.ArmyJoinArmyPageVM:OnShutdown()
    self.ArmyInvitationPageVM:OnShutdown()
end

function ArmyJoinPanelVM:GetArmyJoinPageVM()
    return self.ArmyJoinArmyPageVM
end

function ArmyJoinPanelVM:GetArmyInvitationPageVM()
    return self.ArmyInvitationPageVM
end

--- 显示UI
function ArmyJoinPanelVM:ShowView(Type)
    --- 设置所有部队信息
    if Type == ArmyDefine.ArmyOutUIType.ArmyJoin then
        self.bJoinPage = true
        self.bInvitationPage = false
    elseif Type == ArmyDefine.ArmyOutUIType.ArmyInvite then
        self.bJoinPage = false
        self.bInvitationPage = true
    end
end

function ArmyJoinPanelVM:RemoveArmyInviteListByArmyIDs(ArmyIDs)
    self.ArmyInvitationPageVM:RemoveArmyDataByIDs(ArmyIDs)
end

function ArmyJoinPanelVM:UpdateJoinArmyList(Armys)
    self.ArmyJoinArmyPageVM:UpdateArmyList(Armys)
end

function ArmyJoinPanelVM:AddJoinArmysToList(Armys)
    self.ArmyJoinArmyPageVM:AddArmysToList(Armys)
end

function ArmyJoinPanelVM:UpdateInviteRoleArmyList(ArmyVMList)
    self.ArmyInvitationPageVM:UpdateInviteRoleArmyList(ArmyVMList)
end

function ArmyJoinPanelVM:AdAddInviteRoleJoinArmysToList(Armys)
    self.ArmyInvitationPageVM:AddInviteArmysToList(Armys)
end

function ArmyJoinPanelVM:SetArmyHideData()
    self.ArmyJoinArmyPageVM:SetArmyHideData()
    self.ArmyInvitationPageVM:SetArmyHideData()
end

function ArmyJoinPanelVM:SetInviteSkipArmyID(ArmyID, FailTipsID)
    self.ArmyInvitationPageVM:SetInviteSkipArmyID(ArmyID, FailTipsID)

end

function ArmyJoinPanelVM:GetbJoinPage()
    return self.bJoinPage
end

function ArmyJoinPanelVM:GetbInvitationPage()
    return self.bInvitationPage
end

return ArmyJoinPanelVM
