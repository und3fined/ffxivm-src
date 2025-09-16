--@author daniel
--@date 2023-03-08
--Model ArmyArmyListItem

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local ArmyDefine = require("Game/Army/ArmyDefine")
local UIBindableList = require("UI/UIBindableList")
local ArmyEditInfoHeadSlotVM = require("Game/Army/ItemVM/ArmyEditInfoHeadSlotVM")
local GlobalCfgType = ArmyDefine.GlobalCfgType


---@class ArmySignItemVM : UIViewModel
---@field ID number @ArmyID
---@field Name string @名称
---@field ShortName string @简称
---@field ArmyLevel number @等级
---@field MemberAmount string @人数 -/-
---@field IsSelected boolean @是否选中
---@field RecruitSlogan string @招募标语
---@field RecruitStatus number @招募状态
---@field GrandCompanyType number @联盟类别
local ArmySignItemVM = LuaClass(UIViewModel)

function ArmySignItemVM:Ctor()
    self.Name = nil
    self.ShortName = nil
    self.MemberAmount = nil
    self.IsSelected = nil
    self.Emblem = nil
    self.GrandCompanyType = nil
    self.IsFull = nil
    self.SignList = nil
end

function ArmySignItemVM:OnInit()
    self.RoleID = 0
    self.LeaderID = 0
    self.CacheTime = 0
    self.SignCount = 0
    self.MemberTotal = 0
    self.SignList = UIBindableList.New( ArmyEditInfoHeadSlotVM )
end

function ArmySignItemVM:OnBegin()
end

function ArmySignItemVM:OnEnd()
end

function ArmySignItemVM:OnShutdown()
    self.RoleID = nil
    self.LeaderID = nil
    self.CacheTime = nil
    self.SignCount = nil
    self.MemberTotal = nil
    self.IsFull = nil
end

function ArmySignItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.RoleID == self.RoleID
end

function ArmySignItemVM:UpdateVM(Value)
    if nil == Value then
        return
    end

    self.CacheTime = TimeUtil.GetServerTime()
    self.RoleID = Value.RoleID
    --self.GroupPetition = Value.GroupPetition
    if Value.GroupPetition == nil then
        return
    end
    self.Name = Value.GroupPetition.Name
    self.ShortName = Value.GroupPetition.Alias
    self.Emblem = Value.GroupPetition.Emblem
    self.GrandCompanyType = Value.GroupPetition.GrandCompanyType
    self.LeaderID = Value.RoleID

    local MemTotal = GroupGlobalCfg:GetValueByType(GlobalCfgType.GlobalCfgGroupSignNum) or 0
    self.MemberTotal = MemTotal
    local SignCount = 0
    if Value.Signs then
        SignCount = #Value.Signs
    end
    self.SignCount = SignCount
    if SignCount == MemTotal then
        self.IsFull = true
    else
        self.IsFull = false
    end
    local Signs = {}
    ---署名人数设置
    if Value.Signs then
       for Index, RoleID in ipairs(Value.Signs) do
          local Item = {RoleID = RoleID, ID = Index}
          table.insert(Signs, Item)
       end
   end
   local EmptyNum =  MemTotal - SignCount
   for i = 1, EmptyNum do
       local Item = {IsEmpty = true, ID = i}
       table.insert(Signs, Item)
   end
    self.MemberAmount = string.format("%d/%d", SignCount, MemTotal)
    if self.SignList == nil then
        self.SignList = UIBindableList.New( ArmyEditInfoHeadSlotVM )
    end
    self.SignList:UpdateByValues(Signs)
end

function ArmySignItemVM:AdapterOnGetCanBeSelected()
    return false
end

function ArmySignItemVM:AdapterOnGetWidgetIndex()
    return self.ID
end

--- 设置选中状态
function ArmySignItemVM:SetSelectState(IsSelected)
    self.IsSelected = IsSelected
end

function ArmySignItemVM:GetSelectState()
    return self.IsSelected
end

return ArmySignItemVM