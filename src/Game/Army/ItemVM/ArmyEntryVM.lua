--@author daniel
--@date 2023-03-08
--Model ArmyArmyListItem

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")

---@class ArmyEntryVM : UIViewModel
---@field ID number @ArmyID
---@field Name string @名称
---@field ShortName string @简称
---@field ArmyLevel number @等级
---@field MemberAmount string @人数 -/-
---@field IsSelected boolean @是否选中
---@field RecruitSlogan string @招募标语
---@field RecruitStatus number @招募状态
---@field GrandCompanyType number @联盟类别
local ArmyEntryVM = LuaClass(UIViewModel)

function ArmyEntryVM:Ctor()
    self.Name = nil
    self.ShortName = nil
    self.ArmyLevel = nil
    self.MemberAmount = nil
    self.IsSelected = nil
    self.Emblem = nil
    self.RecruitSlogan = nil
    self.RecruitStatus = nil
    self.GrandCompanyType = nil
    self.ApplyHistories = nil
    self.IsFull = nil
    self.IsJoinItem = nil
end

function ArmyEntryVM:OnInit()
    self.ID = 0
    self.LeaderID = 0
    self.CacheTime = 0
    self.MemberCount = 0
    self.MemberTotal = 0
end

function ArmyEntryVM:OnBegin()
end

function ArmyEntryVM:OnEnd()
end

function ArmyEntryVM:OnShutdown()
    self.ID = nil
    self.LeaderID = nil
    self.CacheTime = nil
    self.MemberCount = nil
    self.MemberTotal = nil
    self.IsFull = nil
end

function ArmyEntryVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

function ArmyEntryVM:UpdateVM(Value)
    if nil == Value then
        return
    end
    self.CacheTime = TimeUtil.GetServerTime()
    self.ID = Value.ID
    self.Name = Value.Name
    self.ShortName = Value.Alias
    local ArmyLevel = Value.Level
    self.ArmyLevel = ArmyLevel
    self.Emblem = Value.Emblem
    self.RecruitSlogan = Value.RecruitSlogan
    self.RecruitStatus = Value.RecruitStatus
    self.GrandCompanyType = Value.GrandCompanyType
    self.LeaderID = Value.Leader.RoleID
    self.ApplyHistories = Value.ApplyHistories
    self.IsJoinItem = Value.IsJoinItem
    local MemTotal = _G.ArmyMgr:GetArmyMemberMaxCount(self.ArmyLevel)
    ---解决lua异常报错
    if MemTotal == nil then
        MemTotal = 0
    end
    self.MemberTotal = MemTotal
    local MemberCount = Value.MemberCount
    ---解决lua异常报错
    if MemberCount == nil then
        MemberCount = 0
    end
    self.MemberCount = MemberCount
    if MemberCount == MemTotal then
        self.IsFull = true
    else
        self.IsFull = false
    end
    self.MemberAmount = string.format("%d/%d", MemberCount, MemTotal)
end

function ArmyEntryVM:AdapterOnGetCanBeSelected()
    return false
end

function ArmyEntryVM:AdapterOnGetWidgetIndex()
    return self.ID
end

--- 设置选中状态
function ArmyEntryVM:SetSelectState(IsSelected)
    self.IsSelected = IsSelected
end

function ArmyEntryVM:GetSelectState()
    return self.IsSelected
end

return ArmyEntryVM