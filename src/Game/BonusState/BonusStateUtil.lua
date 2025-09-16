--
--Author: loiafeng
--Date: 2024-06-12 14:24:31
--Description: 
--

local ActorUtil = require("Utils/ActorUtil")

local MajorUtil = require("Utils/MajorUtil")
local BuffUIUtil = require("Game/Buff/BuffUIUtil")
local BuffDefine = require("Game/Buff/BuffDefine")
local BonusStateBuffCfg = require("TableCfg/BonusStateBuffCfg")

local BonusStateUtil = {}

function BonusStateUtil.IsBuddyBonusState(ID)
    return BonusStateBuffCfg:FindValue(ID or 0, "IsBuddyState") == 1
end

---IsRelatedEntityID 判断RoleID是否为Entity（或其Owner）的RoleID
---@return boolean
function BonusStateUtil.IsRelatedEntityID(RoleID, EntityID)
    return ActorUtil.GetRoleIDByEntityID(EntityID) == RoleID or
        (ActorUtil.IsBuddy(EntityID) and ActorUtil.GetOwnerRoleID(EntityID) == RoleID)
end

return BonusStateUtil