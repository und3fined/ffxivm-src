---
--- Author: lydianwang
--- DateTime: 2022-05-30
---

local LuaClass = require("Core/LuaClass")

local CommonUtil = require("Utils/CommonUtil")

-- ==================================================
--
-- ==================================================

---@class ClientBehaviorBase
local ClientBehaviorBase = LuaClass()

function ClientBehaviorBase:Ctor(CtorParams, _)
    self.BehaviorID = CtorParams.BehaviorID
    self.TargetID = CtorParams.TargetID
    self.BehaviorType = CtorParams.BehaviorType
end

function ClientBehaviorBase:StartBehavior()
    local _ <close> = CommonUtil.MakeProfileTag("StartBehavior_DoStartBehavior")
    self:DoStartBehavior()
end

-- ==================================================
-- 子类接口
-- ==================================================

function ClientBehaviorBase:DoStartBehavior() end

-- 被动执行
function ClientBehaviorBase:PassiveStartBehavior() end

return ClientBehaviorBase