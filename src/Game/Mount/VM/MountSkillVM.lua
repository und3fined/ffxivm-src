local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MountVM = require("Game/Mount/VM/MountVM")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local RideSkillCfg = require("TableCfg/RideSkillCfg")
local TimeUtil = require("Utils/TimeUtil")
local MajorUtil = require("Utils/MajorUtil")

---@class MountSkillVM : UIViewModel
local MountSkillVM = LuaClass(UIViewModel)

function MountSkillVM:Ctor()
    self.IconPath = nil
    self.CDFinishTime = 0
    self.SkillID = nil
    self.Index = nil
    self.SkillCD = nil
    self.SkillEnable = true
end

function MountSkillVM:UpdateVM(ViewModel)
    self.ActionType = ViewModel.ActionType
    self.Index = ViewModel.Index
    MountVM.MountSkillVMList[self.Index] = self

    local bValidSwimmingOrDivingOrFlying = true
    if self.ActionType == 1 then
        self.SkillID = ViewModel.Action
        self.SkillCD = SkillMainCfg:GetSkillCD(self.SkillID)
        self.IconPath = SkillMainCfg:FindValue(self.SkillID, "Icon")
        bValidSwimmingOrDivingOrFlying = SkillMainCfg:FindValue(self.SkillID, "ValidSwimmingOrDivingOrFlying") == 1
    elseif self.ActionType == 2 then
        local RideSkillID = ViewModel.Action
        local Cfg = RideSkillCfg:FindCfgByKey(RideSkillID)
        self.Timeline = Cfg.ActionTimeline
        self.SkillCD = 0
        self.IconPath = Cfg.Icon
        bValidSwimmingOrDivingOrFlying = Cfg.bValidSwimmingOrDivingOrFlying
    end

    if not bValidSwimmingOrDivingOrFlying then
        local Character = MajorUtil:GetMajor()
        local bSwimOrFly = Character:IsInFly() or Character:IsSwimming()
        self.SkillEnable = not bSwimOrFly
    else
        self.SkillEnable = true
    end
end

function MountSkillVM:UpdateCD()
    if TimeUtil.GetServerTimeMS() and self.SkillCD then
        self.CDFinishTime = TimeUtil.GetServerTimeMS() + self.SkillCD
    end
end

function MountSkillVM:IsInCD()
    return TimeUtil.GetServerTimeMS() < self.CDFinishTime
end

function MountSkillVM:UpdateSkillEnable(bEnbale)
    local bValidSwimmingOrDivingOrFlying = true
    if self.ActionType == 1 then
        bValidSwimmingOrDivingOrFlying = SkillMainCfg:FindValue(self.SkillID, "ValidSwimmingOrDivingOrFlying") == 1
    elseif self.ActionType == 2 then
        bValidSwimmingOrDivingOrFlying = Cfg.bValidSwimmingOrDivingOrFlying
    end

    if not bValidSwimmingOrDivingOrFlying then
        local Character = MajorUtil:GetMajor()
        local bSwimOrFly = Character:IsInFly() or Character:IsSwimming()
        self.SkillEnable = not bSwimOrFly
    else
        self.SkillEnable = true
    end
end
return MountSkillVM