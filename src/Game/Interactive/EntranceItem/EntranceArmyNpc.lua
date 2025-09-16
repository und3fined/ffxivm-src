local LuaClass = require("Core/LuaClass")
local NpcCfg = require("TableCfg/NpcCfg")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local EntranceNpc = require("Game/Interactive/EntranceItem/EntranceNpc")
local ActorUtil = require("Utils/ActorUtil")


local EntranceArmyNpc = LuaClass(EntranceNpc)

function EntranceArmyNpc:OnInit()
    local Cfg = NpcCfg:FindCfgByKey(self.ResID)
    self.Cfg = Cfg
    self.NpcID = Cfg.ID or 0

    if not self.Distance or self.Distance <= 0 and self.EntityID then
        local Actor = ActorUtil.GetActorByEntityID(self.EntityID)
        if Actor then
            self.Distance = Actor:GetDistanceToMajor()
        end
    end

    self.DisplayName = _G.LSTR(90001)
end

function EntranceArmyNpc:Update()
end

function EntranceArmyNpc:OnClick()
    FLOG_INFO("EntranceArmyNpc:OnClick, EntityId:%d", self.EntityID)
end

function EntranceArmyNpc:OnGenFunctionList()
    local FunctionList = {}
    return FunctionList
end

return EntranceArmyNpc