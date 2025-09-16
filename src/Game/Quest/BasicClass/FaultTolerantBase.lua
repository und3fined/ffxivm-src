---
--- Author: sammrli
--- DateTime: 2024-12-17
---

local LuaClass = require("Core/LuaClass")
local GameEventRegister = require("Register/GameEventRegister")

local NpcCfg = require("TableCfg/NpcCfg")
local EobjCfg = require("TableCfg/EobjCfg")

-- ==================================================
--
-- ==================================================

---@class FaultTolerantBase
local FaultTolerantBase = LuaClass()

function FaultTolerantBase:Ctor(QuestID, FaultTolerantID, Params)
    self.QuestID = QuestID
    self.FaultTolerantID = FaultTolerantID
    self:OnInit(Params)
    self:OnRegisterGameEvent()
end

function FaultTolerantBase:ClearFaultTolerant()
    if self.GameEventRegister then
        self.GameEventRegister:UnRegisterAll()
	end
    self:EndFaultTolerant(self.QuestID, self.FaultTolerantID)
    self:OnDestroy()
end

---触发容错机制
---@param QuestID number@触发容错的任务ID
---@param FaultTolerantID number@容错ID
function FaultTolerantBase:StartFaultTolerant(QuestID, FaultTolerantID)
    _G.QuestFaultTolerantMgr:StartFaultTolerant(QuestID, FaultTolerantID)
end

---结束容错机制
---@param QuestID number@触发容错的任务ID
---@param FaultTolerantID number@容错ID
function FaultTolerantBase:EndFaultTolerant(QuestID, FaultTolerantID)
    _G.QuestFaultTolerantMgr:EndFaultTolerant(QuestID, FaultTolerantID)
end

---获取重新获取物品的目标Npc/EObj的名字
---@return string
function FaultTolerantBase:GetCfgTargetNpcOrEObjName(QuestFaultTolerantCfgItem)
    if not QuestFaultTolerantCfgItem then
       return ""
    end
    if QuestFaultTolerantCfgItem.NpcID > 0 then
        local NpcCfgItem = NpcCfg:FindCfgByKey(QuestFaultTolerantCfgItem.NpcID)
        if NpcCfgItem then
            return NpcCfgItem.Name
        end
    elseif QuestFaultTolerantCfgItem.EobjID > 0 then
        local EobjCfgItem = EobjCfg:FindCfgByKey(QuestFaultTolerantCfgItem.EobjID)
        if EobjCfgItem then
            return EobjCfgItem.Name
        end
    end
    return ""
end

-- ==================================================
-- 事件注册
-- ==================================================

function FaultTolerantBase:RegisterGameEvent(EventID, Callback)
	if not self.GameEventRegister then
		self.GameEventRegister = GameEventRegister.New()
	end
    self.GameEventRegister:Register(EventID, self, Callback)
end

-- ==================================================
-- 子类接口
-- ==================================================

function FaultTolerantBase:OnInit(Params) end

function FaultTolerantBase:OnRegisterGameEvent() end

function FaultTolerantBase:OnDestroy() end

function FaultTolerantBase:CheckCanSubmit() return true end


return FaultTolerantBase