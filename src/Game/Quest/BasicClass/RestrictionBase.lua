---
--- Author: lydianwang
--- DateTime: 2022-11-21
---

local LuaClass = require("Core/LuaClass")
local GameEventRegister = require("Register/GameEventRegister")

-- ==================================================
--
-- ==================================================

---@class RestrictionBase
local RestrictionBase = LuaClass()

function RestrictionBase:Ctor(CtorParams, _)
    self.QuestID = CtorParams.QuestID
    self.LogicID = CtorParams.LogicID
    
    self.RestrictedDialogType = nil

    self:OnInit()
end

function RestrictionBase:ClearRestriction()
	if nil ~= self.GameEventRegister then
        self.GameEventRegister:UnRegisterAll()
	end
    self:OnDestroy()
end

-- ==================================================
-- 事件注册
-- ==================================================

function RestrictionBase:UpdateQuestAtEvent(EventID)
	if nil == self.GameEventRegister then
		self.GameEventRegister = GameEventRegister.New()
	end
    -- 在指定事件被触发时，通过任务事件更新图标，后续可考虑分离任务/图标更新事件
	self.GameEventRegister:Register(EventID, self, self.SendUpdateQuest)
end

function RestrictionBase:SendUpdateQuest(Params)
    if self:CheckNeedUpdateQuest(Params) then
        local QuestMgr = _G.QuestMgr
        QuestMgr:OnQuestConditionUpdate(true)
        QuestMgr:SendEventOnConditionUpdate(self.QuestID)
    end
end

-- ==================================================
-- 子类接口
-- ==================================================

---@return boolean
function RestrictionBase:CheckPassRestriction() return true end

---@return boolean
function RestrictionBase:CheckNeedUpdateQuest(_) return true end

function RestrictionBase:OnInit() end

function RestrictionBase:OnDestroy() end

---@return string
function RestrictionBase:MakeRestrictedDialog() return "" end

return RestrictionBase