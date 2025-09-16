---
--- Author: sammrli
--- DateTime: 2024-12-17
--- 发放buff
---

local LuaClass = require("Core/LuaClass")

local EventID = require("Define/EventID")
local MsgTipsID = require("Define/MsgTipsID")
local FaultTolerantBase = require("Game/Quest/BasicClass/FaultTolerantBase")

local BuffCfg = require("TableCfg/BuffCfg")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")

---@class FaultTolerantBuff
local FaultTolerantBuff = LuaClass(FaultTolerantBase)

function FaultTolerantBuff:OnInit(Params)
    self.BuffID = Params[1] or 0
end

function FaultTolerantBuff:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.UpdateBuff, self.OnUpdateBuff)
    self:RegisterGameEvent(EventID.RemoveBuff, self.OnUpdateBuff)
end

function FaultTolerantBuff:OnDestroy()
end

function FaultTolerantBuff:OnUpdateBuff()
    if not _G.SkillBuffMgr:IsBuffExist(self.BuffID) and not _G.LifeSkillBuffMgr:IsMajorContainBuff(self.BuffID) then
        self:StartFaultTolerant(self.QuestID, self.FaultTolerantID)
        self:ShowFaultTip()
    else
        self:EndFaultTolerant(self.QuestID, self.FaultTolerantID)
    end
end

function FaultTolerantBuff:ShowFaultTip()
    local FaultCfgItem = _G.QuestFaultTolerantMgr:GetCfg(self.FaultTolerantID)
    if not FaultCfgItem then
        return
    end

    local NeedNames = ""
    for i=1,#FaultCfgItem.Params do
        local BuffResID = FaultCfgItem.Params[i]
        local BuffCfgItem = BuffCfg:FindCfgByKey(BuffResID)
        if BuffCfgItem then
            NeedNames = BuffCfgItem.BuffName
        end
    end

    local TipsID = MsgTipsID.QuestFaultMssBuff
    local TargetName = self:GetCfgTargetNpcOrEObjName(FaultCfgItem)

    _G.MsgTipsUtil.ShowTipsByID(TipsID, nil, NeedNames, TargetName)
    local NoticeCfgItem = SysnoticeCfg:FindCfgByKey(TipsID)
    if NoticeCfgItem then
        _G.ChatMgr:AddQuestMsg(NeedNames, TargetName, FaultCfgItem.MapID, self.QuestID, FaultCfgItem)
    end
end

return FaultTolerantBuff