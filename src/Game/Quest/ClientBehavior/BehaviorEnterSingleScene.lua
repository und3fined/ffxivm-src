---
--- Author: lydianwang
--- DateTime: 2021-12-14
---

local LuaClass = require("Core/LuaClass")
local BehaviorBase = require("Game/Quest/BasicClass/ClientBehaviorBase")
local QuestHelper = require("Game/Quest/QuestHelper")
local FunctionItemFactory = require("Game/Interactive/FunctionItemFactory")
local PWorldMgr = require("Game/PWorld/PWorldMgr")
local TargetCfg = require("TableCfg/QuestTargetCfg")
local ActorUtil = require("Utils/ActorUtil")

---@class BehaviorEnterSingleScene
local BehaviorEnterSingleScene = LuaClass(BehaviorBase, true)

function BehaviorEnterSingleScene:Ctor(_, Properties)
    self.InteractID = tonumber(Properties[1]) or 0
end

function BehaviorEnterSingleScene:DoStartBehavior()
    if self.InteractID == 0 then
        QuestHelper.PrintQuestError("BehaviorEnterSingleScene InteractID==0")
        return
    end

    local EntityID = nil
    local TargetItemCfg = TargetCfg:FindCfgByKey(self.TargetID)
    if TargetItemCfg then
        local NpcResID = tonumber(TargetItemCfg.Properties[1])
        if NpcResID then
            local Actor = ActorUtil.GetActorByResID(NpcResID)
            if Actor then
                local AttrComp = Actor:GetAttributeComponent()
                EntityID = AttrComp.EntityID
            end
        end
    end

    local FunctionUnit = FunctionItemFactory:CreateInteractiveDescFunc({ FuncValue = self.InteractID, EntityID = EntityID })
    if FunctionUnit == nil then
        QuestHelper.PrintQuestError("BehaviorEnterSingleScene CreateInteractiveDescFunc failed")
        return
    end

    -- 2种情况上报回退：点击取消，断线重连时未显示单人本界面
    -- 2种情况注销回退目标记录：离开副本，收到回退消息
    _G.QuestMgr.QuestRegister:RegisterTargetNeedRevert(self.TargetID)

	if not PWorldMgr:CurrIsInDungeon() then
        -- 只复用逻辑，不显示Function
        FunctionUnit.FromTargetID = self.TargetID
        FunctionUnit:OnClick()
    end
end

return BehaviorEnterSingleScene