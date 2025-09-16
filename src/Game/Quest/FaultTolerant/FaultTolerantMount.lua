---
--- Author: sammrli
--- DateTime: 2024-12-17
--- 发放坐骑
---

local LuaClass = require("Core/LuaClass")

local EventID = require("Define/EventID")
local MsgTipsID = require("Define/MsgTipsID")
local FaultTolerantBase = require("Game/Quest/BasicClass/FaultTolerantBase")

local MajorUtil = require("Utils/MajorUtil")

local RideCfg = require("TableCfg/RideCfg")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")

---@class FaultTolerantMount
local FaultTolerantMount = LuaClass(FaultTolerantBase)

function FaultTolerantMount:OnInit(Params)
    self.MountResID = Params[1] or 0

    if MajorUtil.IsMajorCombat() then --战斗中不会上坐骑，判断是否触发容错
        self:CheckMount()
    end
end

function FaultTolerantMount:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MountCall, self.OnMountUpdate)
    self:RegisterGameEvent(EventID.MountBack, self.OnMountUpdate)
    self:RegisterGameEvent(EventID.InitQuest, self.OnInitQuest)
end

function FaultTolerantMount:OnDestroy()
end

function FaultTolerantMount:CheckMount()
    local Major = MajorUtil.GetMajor()
    if Major then
        local RideComp = Major:GetRideComponent()
        if RideComp then
            if RideComp:GetRideResID() ~= self.MountResID then
                self:StartFaultTolerant(self.QuestID, self.FaultTolerantID)
            else
                self:EndFaultTolerant(self.QuestID, self.FaultTolerantID)
            end
        end
    end
end

function FaultTolerantMount:OnInitQuest()
    self:CheckMount()
end

function FaultTolerantMount:OnMountUpdate(Params)
    if not Params then
        return
    end
	if not MajorUtil.IsMajor(Params.EntityID) then
		return
	end

    local Major = MajorUtil.GetMajor()
    if Major then
        local RideComp = Major:GetRideComponent()
        if RideComp then
            if RideComp:GetRideResID() ~= self.MountResID then
                if not Params.bIsEnteringWorld then
                    self:ShowFaultTip()
                end
                self:StartFaultTolerant(self.QuestID, self.FaultTolerantID)
            else
                self:EndFaultTolerant(self.QuestID, self.FaultTolerantID)
            end
        end
    end
end

function FaultTolerantMount:ShowFaultTip()
    local FaultCfgItem = _G.QuestFaultTolerantMgr:GetCfg(self.FaultTolerantID)
    if not FaultCfgItem then
        return
    end

    local NeedNames = ""
    for i=1,#FaultCfgItem.Params do
        local MountResID = FaultCfgItem.Params[i]
        local RideCfgItem = RideCfg:FindCfgByKey(MountResID)
        if RideCfgItem then
            NeedNames = RideCfgItem.Name
        end
    end

    local TipsID = MsgTipsID.QuestFaultMssMount
    local TargetName = self:GetCfgTargetNpcOrEObjName(FaultCfgItem)

    _G.MsgTipsUtil.ShowTipsByID(TipsID, nil, NeedNames, TargetName)
    local NoticeCfgItem = SysnoticeCfg:FindCfgByKey(TipsID)
    if NoticeCfgItem then
        _G.ChatMgr:AddQuestMsg(NeedNames, TargetName, FaultCfgItem.MapID, self.QuestID, FaultCfgItem)
    end
end

return FaultTolerantMount