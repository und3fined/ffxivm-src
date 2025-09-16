local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoRes = require("Protocol/ProtoRes")
-- local ProtoCommon = require("Protocol/ProtoCommon")
-- local SkillMainCfg = require("TableCfg/SkillMainCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
-- local SkillUtil = require("Utils/SkillUtil")
-- local EffectUtil = require("Utils/EffectUtil")
local ActorUtil = require("Utils/ActorUtil")
-- local ProtoCS = require("Protocol/ProtoCS")
-- local CS_CMD = ProtoCS.CS_CMD
-- local CS_SUB_CMD = ProtoCS.CS_LIFE_SKILL_CMD

-- local LifeSkillConfig = require("Game/Skill/LifeSkillConfig")
-- local RPNGenerator = require("Game/Skill/SelectTarget/RPNGenerator")
-- local LifeSkillConditionCfg = require("TableCfg/LifeSkillConditionCfg")

-- local AlchemistVM = require("Game/Crafter/Alchemist/AlchemistVM")
local LSTR = _G.LSTR

--目前是废弃的

---@class AlchemistMgr : MgrBase
local AlchemistMgr = LuaClass(MgrBase)

-- 炼金术士特有部分
function AlchemistMgr:OnInit()
end

function AlchemistMgr:OnBegin()

end

function AlchemistMgr:OnEnd()
end

function AlchemistMgr:OnShutdown()

end

function AlchemistMgr:OnRegisterNetMsg()
    --todo

end

function AlchemistMgr:OnRegisterGameEvent()
    -- self:RegisterGameEvent(_G.EventID.CrafterSkillRsp, self.OnEventCrafterSkillRsp)
end

function AlchemistMgr:OnEventCrafterSkillRsp(MsgBody)
    if MsgBody and MsgBody.CrafterSkill and MsgBody.CrafterSkill.EventIDs then
        local MajorEntityID = MajorUtil.GetMajorEntityID()

        local EventIDs = MsgBody.CrafterSkill.EventIDs
        local EventID = nil
        for index = 1, #EventIDs do
            EventID = EventIDs[index]
            if EventID == ProtoRes.EVENT_TYPE.EVENT_TYPE_BOOM then  --爆炸，只有炼金才有
                --爆炸失败的表现，这里可能是major，也可能是第三方
                if MajorEntityID == MsgBody.ObjID then
                    MsgTipsUtil.ShowTips(LSTR(150061))  -- 发生了炼金事故···
                end

                --爆炸特效资源到位后，再播放，所有人都看的到
            end
        end
    end

    -- AlchemistVM:UpdateSkillRsp(MsgBody)
end

-- --处理特殊的部分，比如炼金的爆炸相关
-- function AlchemistMgr:OnNetMsgResult(MsgBody)
--     local Result = MsgBody.Result
-- end

function AlchemistMgr:ClearData()
end

return AlchemistMgr