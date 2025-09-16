--
-- Author: loiafeng
-- Date: 2023-03-28 14:50
-- Description: 在线状态设置界面主VM
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SettingsItemVM = require("Game/OnlineStatus/SettingsVM/OnlineStatusSettingsItemVM")

local UIBindableList = require("UI/UIBindableList")

local TeamHelper = require("Game/Team/TeamHelper")
local MajorUtil = require("Utils/MajorUtil")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
local OnlineStatusSetCfg = require("TableCfg/OnlineStatusSetCfg")
local ProtoRes = require("Protocol/ProtoRes")

---@class OnlineStatusSettingsVM : UIViewModel
---@field SettingsItemList UIBindableList 设置选项列表
---@field CurrStatus number 在设置界面显示的当前状态
---@field CurrName string 当前状态名称
---@field CurrIcon string 当前状态图标
---@field SelectedItemVM OnlineStatusSettingsItemVM 选中的ItemVM
local OnlineStatusSettingsVM = LuaClass(UIViewModel)

---Ctor
function OnlineStatusSettingsVM:Ctor()
    self.SettingsItemList = UIBindableList.New(SettingsItemVM)
    self.CurrStatus = nil
    self.CurrName = nil
    self.CurrIcon = nil
    self.SelectedItemVM = nil
end

function OnlineStatusSettingsVM:Update()
    local RoleVM = MajorUtil.GetMajorRoleVM()
    if nil == RoleVM then
        return
    end

    -- 减少非必要的更新
    if self.Status == RoleVM.OnlineStatus and 
        self.CustomStatusID == RoleVM.OnlineStatusCustomID and 
        self.Identity == RoleVM.Identity then
        return
    end
    
    self.Status = RoleVM.OnlineStatus
    self.CustomStatusID = RoleVM.OnlineStatusCustomID
    self.Identity = RoleVM.Identity

    -- 判断是否为离开状态并更新当前状态
    local LeaveStatusID = ProtoRes.OnlineStatus.OnlineStatusLeave
    if OnlineStatusUtil.CheckBit(self.Status, LeaveStatusID) then
        self.CurrStatus = LeaveStatusID
    else
        self.CurrStatus = self.CustomStatusID
    end

    local CurrStatusID = self.CurrStatus
    if CurrStatusID == ProtoRes.OnlineStatus.OnlineStatusJoinNewbieChannel then
        CurrStatusID = ProtoRes.OnlineStatus.OnlineStatusNewHand
    end
    self.CurrIcon, self.CurrName =  OnlineStatusUtil.GetStatusRes(CurrStatusID)

    -- 筛选出身份合适的选项
    local CustomStatusCfgs = OnlineStatusSetCfg:FindAllCfg()
    local SettableCfgs = {}
    for _, Cfg in ipairs(CustomStatusCfgs) do
        if self:FilterDisplayedSetting(Cfg) then
            _G.table.insert(SettableCfgs, Cfg)
        end
    end
    -- 按界面优先级排序
    _G.table.sort(SettableCfgs, function(A, B) return A.Priority < B.Priority end)

    -- 更新ItemVM
    self.SettingsItemList:UpdateByValues(SettableCfgs)

    -- 验证选中的VM是否仍然有效
    if not self.SettingsItemList:Find(function(VM) return VM == self.SelectedItemVM end) then
        self:SetSelectedItemVM(self.SettingsItemList:Get(1))
    end
end

---选中当前状态
function OnlineStatusSettingsVM:SelectedCurrStatusItem()
    self:SetSelectedItemVM(self.SettingsItemList:Find(
        function(VM) 
            if VM.StatusID ~= self.CurrStatus then
                if (VM.StatusID == ProtoRes.OnlineStatus.OnlineStatusJoinNewbieChannel 
                or VM.StatusID == ProtoRes.OnlineStatus.OnlineStatusNewHand) 
                and 
                (self.CurrStatus == ProtoRes.OnlineStatus.OnlineStatusJoinNewbieChannel 
                or self.CurrStatus == ProtoRes.OnlineStatus.OnlineStatusNewHand) then
                    return true
                end
                return false
            end
            return true
        end)
    )
end

function OnlineStatusSettingsVM:SetSelectedItemVM(SelectedVM)
    if self.SelectedItemVM == SelectedVM then
        return
    end

    if self.SelectedItemVM ~= nil then
        self.SelectedItemVM:SetIsSelected(false)
    end

    if SelectedVM ~= nil then
        SelectedVM:SetIsSelected(true)
    end

    self.SelectedItemVM = SelectedVM
end

-- 显示的筛选规则
function OnlineStatusSettingsVM:FilterDisplayedSetting(Cfg)
    if not OnlineStatusUtil.CheckBit(self.Identity, Cfg.Identity) then
        return false
    end

    if TeamHelper.GetTeamMgr():IsInTeam() and Cfg.ID == 16 then
        return false
    end
    return true
end

return OnlineStatusSettingsVM