---
--- Author: star
--- DateTime: 2025-01-22 10:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ArmyDefine = require("Game/Army/ArmyDefine")
local GlobalCfgType = ArmyDefine.GlobalCfgType

local ArmyEditArmyInformationItemVM = require("Game/Army/ItemVM/ArmyEditArmyInformationItemVM")
local BitUtil = require("Utils/BitUtil")
local ProtoCS = require("Protocol/ProtoCS")
local GroupRecruitStatus = ProtoCS.GroupRecruitStatus

local GroupActivityDataCfg = require("TableCfg/GroupActivityDataCfg")
local GroupRecruitProfCfg = require("TableCfg/GroupRecruitProfCfg")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")

---@class ArmyEditArmyInformationWinVM : UIViewModel
local ArmyEditArmyInformationWinVM = LuaClass(UIViewModel)

local TabPanel = 
{
    ActivityInfo = 1,
    RecuritInfo = 2,
}

---Ctor
function ArmyEditArmyInformationWinVM:Ctor()
    self.ActivityList = nil
    self.JobList = nil
	self.IsRecurit = nil
	self.RecruitSlogan = nil
	self.ActivityTimeType = nil
    self.bRecruitPanel = nil
    self.bActivityPanel = nil
    self.OldActivitysState = nil
    self.ActivitysState = nil
    self.OldJobsState = nil
    self.JobsState = nil
    self.IsChanged = nil
end

function ArmyEditArmyInformationWinVM:OnInit()
    self.ActivityList = UIBindableList.New( ArmyEditArmyInformationItemVM )
    self.JobList = UIBindableList.New( ArmyEditArmyInformationItemVM )
	self.CreateTime = 0
	self.ReputationProgressValue = 0
    self.ActivitysState = {}
    self.JobsState = {}
    self:InitCfgData()
end

function ArmyEditArmyInformationWinVM:OnMenuSelectedChanged(PanelKey)
    self.bActivityPanel = PanelKey == TabPanel.ActivityInfo
    self.bRecruitPanel = PanelKey == TabPanel.RecuritInfo
end

function ArmyEditArmyInformationWinVM:OnBegin()

end

function ArmyEditArmyInformationWinVM:OnEnd()

end

function ArmyEditArmyInformationWinVM:OnShutdown()

end
----------------------------------------列表处理 Start----------------------------------------

---处理默认表格数据
function ArmyEditArmyInformationWinVM:InitCfgData()
    ---活动数据
    self:InitActivitysData()
    ---招募职业数据
    self:InitRecruitProfsData()
end

---处理默认活动数据
function ArmyEditArmyInformationWinVM:InitActivitysData()
    ---活动数据
    local ActivitysData = {}
    local ActivitysCfg = GroupActivityDataCfg:FindAllCfg()
    for _, ActivityCfg in ipairs(ActivitysCfg) do
        local ActivityData ={
            ID = ActivityCfg.ID,
            Icon = ActivityCfg.Icon,
            Text = ActivityCfg.EditText,
            IsCheck = false,
            IsEnabled = true,
        }
        table.insert(ActivitysData, ActivityData)
    end
    self.ActivityList:UpdateByValues(ActivitysData)
end

---处理默认招募职业数据
function ArmyEditArmyInformationWinVM:InitRecruitProfsData()
    ---招募职业数据
    local RecruitProfsData = {}
    local RecruitProfsCfg = GroupRecruitProfCfg:FindAllCfg()
    for _, RecruitProfCfg in ipairs(RecruitProfsCfg) do
        local RecruitProfData ={
            ID = RecruitProfCfg.ID,
            Icon = RecruitProfCfg.Icon,
            Text = RecruitProfCfg.EditText,
            IsCheck = false,
            IsEnabled = true,
        }
        table.insert(RecruitProfsData, RecruitProfData)
    end
    self.JobList:UpdateByValues(RecruitProfsData)
end

---活动列表全部取消选中
function ArmyEditArmyInformationWinVM:SetActivityListNoChecked()
    local Items = self.ActivityList:GetItems()
    for _, Item in ipairs(Items) do
        Item:SetIsChecked(false)
    end
end

---招募职业列表全部取消选中
function ArmyEditArmyInformationWinVM:SetJobListNoChecked()
    local Items = self.JobList:GetItems()
    for _, Item in ipairs(Items) do
        Item:SetIsChecked(false)
    end
end

---活动列表全部置灰
function ArmyEditArmyInformationWinVM:SetActivityListIsEnabled(IsEnabled)
    local Items = self.ActivityList:GetItems()
    for _, Item in ipairs(Items) do
        Item:SetIsEnabled(IsEnabled)
    end
end

---招募职业列表全部置灰
function ArmyEditArmyInformationWinVM:SetJobListIsEnabled(IsEnabled)
    local Items = self.JobList:GetItems()
    for _, Item in ipairs(Items) do
        Item:SetIsEnabled(IsEnabled)
    end
end

----------------------------------------列表处理 End----------------------------------------


----------------------------------------数据更新 Start----------------------------------------
--- 更新情报数据
function ArmyEditArmyInformationWinVM:UpdateCurData(InformationData)
    if InformationData then
        --self.OldData = InformationData ---旧数据，用于对比变更
        ---活动数据
        self.OldActivitysState = {}
        self.ActivitysState = {}
		if InformationData.ActivityIcons then
            self:SetActivityListNoChecked()
            for Index = 0, 64 do
                local ActivityIsOn = BitUtil.IsBitSetByInt64(InformationData.ActivityIcons, Index, false)
				if ActivityIsOn then
					--local Item = {ID = Index, IsOn = true}
                	table.insert(self.ActivitysState, Index + 1)
                    local ItemVM = self.ActivityList:GetItemByPredicate(function(VM)
                        return VM.ID == Index + 1
                    end)
                    ItemVM:SetIsChecked(true)
				end
            end
        end
        self.OldActivitysState = table.clone(self.ActivitysState)
        ---招募职业数据
        self.OldJobsState = {}
        self.JobsState = {}
		if InformationData.RecruitProfs then
            self:SetJobListNoChecked()
            for Index = 0, 64 do
                local JobIsOn = BitUtil.IsBitSetByInt64(InformationData.RecruitProfs, Index, false)
				if JobIsOn then
					--local Item = {ID = Index, IsOn = true}
                	table.insert(self.JobsState, Index + 1)
                    local ItemVM = self.JobList:GetItemByPredicate(function(VM)
                        return VM.ID == Index + 1
                    end)
                    ItemVM:SetIsChecked(true)
				end
            end
        end
        self.OldJobsState = table.clone(self.JobsState)

        self.ActivityTimeType = InformationData.ActivityTimeType or InformationData.ActivityTime --- 活动时间
        if self.ActivityTimeType == 0 then --默认给1，后续看是否配表
            self.ActivityTimeType = 1
        end
		self.IsRecurit =  InformationData.RecruitStatus  == GroupRecruitStatus.GROUP_RECRUIT_STATUS_Open ---招募状态
		self.RecruitSlogan = InformationData.RecruitSlogan ---招募标语
        self.OldActivityTimeType =  self.ActivityTimeType
        self.OldIsRecurit =  self.IsRecurit
        self.OldRecruitSlogan =  self.RecruitSlogan

        ---关闭招募时不给设置招募职业
        self:SetJobListIsEnabled(self.IsRecurit)
        ---策划要求关闭招募时活动这边也不能设置
        self:SetActivityListIsEnabled(self.IsRecurit)
        ---清理改变状态
        self:ClearChangedState()
	end
end
----------------------------------------数据更新 End----------------------------------------

----------------------------------------变更检查 Start----------------------------------------
function ArmyEditArmyInformationWinVM:CheckActivitysChanged()
    self.ActivitysChanged = false
    if #self.ActivitysState == #self.OldActivitysState then
        for _, ID in ipairs(self.ActivitysState) do
            local IsFind = table.find_by_predicate(self.OldActivitysState, function(A)
                return A == ID
            end)
            if IsFind == nil then
                self.ActivitysChanged = true
                break
            end
        end
    else
        self.ActivitysChanged = true
    end
    self:CheckChanged()
    return self.ActivitysChanged
end

function ArmyEditArmyInformationWinVM:CheckJobsChanged()
    self.JobsChanged = false
    if #self.JobsState == #self.OldJobsState then
        for _, ID in ipairs(self.JobsState) do
            local IsFind = table.find_by_predicate(self.OldJobsState, function(A)
                return A == ID
            end)
            if IsFind == nil then
                self.JobsChanged = true
                break
            end
        end
    else
        self.JobsChanged = true
    end
    self:CheckChanged()
    return self.JobsChanged
end

function ArmyEditArmyInformationWinVM:CheckRecuritChanged()
    self.RecuritChanged = false
    if self.IsRecurit == self.OldIsRecurit then
        self.RecuritChanged = self.OldRecruitSlogan ~= self.RecruitSlogan
    else
        self.RecuritChanged = true
    end
    self:CheckChanged()
    return self.RecuritChanged
end

function ArmyEditArmyInformationWinVM:CheckActivityTimeChanged()
    self.ActivityTimeChanged = self.ActivityTimeType ~= self.OldActivityTimeType
    self:CheckChanged()
    return self.ActivityTimeChanged
end

function ArmyEditArmyInformationWinVM:CheckChanged()
    self.IsChanged = self.ActivitysChanged  or self.JobsChanged or self.RecuritChanged or  self.ActivityTimeChanged
    return self.IsChanged
end

function ArmyEditArmyInformationWinVM:ClearChangedState()
    self.ActivitysChanged = false
    self.JobsChanged = false
    self.RecuritChanged = false
    self.ActivityTimeChanged = false
    self.IsChanged = false
end
----------------------------------------变更检查 End----------------------------------------

----------------------------------------获取和设置变量 Start----------------------------------------
---获取是否开放招募
function ArmyEditArmyInformationWinVM:GetIsRecurit()
    return self.IsRecurit
end

---设置是否开放招募
function ArmyEditArmyInformationWinVM:SetIsRecurit(IsRecurit)
    self.IsRecurit = IsRecurit
    self:SetJobListIsEnabled(self.IsRecurit)
    ---策划要求关闭招募时活动这边也不能设置
    self:SetActivityListIsEnabled(self.IsRecurit)
end

---获取招募标语
function ArmyEditArmyInformationWinVM:GetRecruitSlogan()
    return self.RecruitSlogan
end

---设置招募标语
function ArmyEditArmyInformationWinVM:SetRecruitSlogan(RecruitSlogan)
    self.RecruitSlogan = RecruitSlogan
end

---获取活动时间
function ArmyEditArmyInformationWinVM:GetActivityTimeType()
    return self.ActivityTimeType
end

---设置活动时间
function ArmyEditArmyInformationWinVM:SetActivityTimeType(ActivityTimeType)
    self.ActivityTimeType = ActivityTimeType
end

---更新启用活动列表
function ArmyEditArmyInformationWinVM:UpdaActivitysStateByItemCilcked(ID, IsOn)
    if IsOn then
        local IsFind = table.find_by_predicate(self.ActivitysState, function(A)
           return A == ID
        end)
        if IsFind == nil then
            table.insert(self.ActivitysState, ID)
        end
    else
        local IsFind, Index = table.find_by_predicate(self.ActivitysState, function(A)
            return A == ID
        end)
        if IsFind then
            table.remove(self.ActivitysState, Index)
        end
    end
end

---更新启用招募职业列表
function ArmyEditArmyInformationWinVM:UpdaJobsStateByItemCilcked(ID, IsOn)
    if IsOn then
        local IsFind = table.find_by_predicate(self.JobsState, function(A)
            return A == ID
        end)
        if IsFind == nil then
            table.insert(self.JobsState, ID)
        end
    else
        local IsFind, Index = table.find_by_predicate(self.JobsState, function(A)
            return A == ID
        end)
        if IsFind then
            table.remove(self.JobsState, Index)
        end
    end
end
----------------------------------------获取和设置变量 End----------------------------------------
---编辑数据发送
function ArmyEditArmyInformationWinVM:Save()
    local RecruitStatus = self.IsRecurit and GroupRecruitStatus.GROUP_RECRUIT_STATUS_Open or GroupRecruitStatus.GROUP_RECRUIT_STATUS_Closed---招募状态
    local ActivityIcons = self:ToNumberByIDList(self.ActivitysState)
    local RecruitProfs = self:ToNumberByIDList(self.JobsState)
    local EditeData = {
        RecruitStatus = RecruitStatus,          ---招募状态
        RecruitSlogan = self.RecruitSlogan,          --- 招募标语
        RecruitProfs = RecruitProfs,            ---招募职业按位存储状态
        ActivityTime = self.ActivityTimeType,            --- 活动时间
        ActivityIcons = ActivityIcons,          ---活动ICON按位存储状态
    }
    _G.ArmyMgr:SendGroupRecruitSetProf(EditeData)
end

---ID表转Byte值数据
function ArmyEditArmyInformationWinVM:ToNumberByIDList(IDList)
    table.sort(IDList, function(A, B)
        return A < B
    end)
    local BitTable = {}
    local Len = #IDList
    local MaxNum = 0
    if Len and Len > 0 then
        MaxNum = IDList[Len]
    end
    for Index = 1, MaxNum do
        local IsFind = table.find_by_predicate(IDList, function(A)
            return A == Index
        end)
        if IsFind then
            table.insert(BitTable, 1)
        else
            table.insert(BitTable, 0)
        end
    end
    local ByteValue = BitUtil.ToNumber(BitTable)
    return ByteValue
end

---编辑成功更新数据
function ArmyEditArmyInformationWinVM:UpdateDataByEdit(GroupProfileEdite)
    ---用到的字段名是一样的，直接复用
    self:UpdateCurData(GroupProfileEdite)
end

return ArmyEditArmyInformationWinVM
