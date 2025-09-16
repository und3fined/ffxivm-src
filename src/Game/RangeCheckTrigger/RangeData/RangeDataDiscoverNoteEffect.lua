--
-- Author: Alex
-- Date: 2025-02-19 15:53
-- Description:范围检测数据
-- 进入视野后控制特效才有意义 所以EntityID不为nil
--


local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")
local ActorUtil = require("Utils/ActorUtil")
local DiscoverNoteHintCfg = require("TableCfg/DiscoverNoteHintCfg")
local DiscoverNoteClueEffectRangeCfg = require("TableCfg/DiscoverNoteHintEffectRangeCfg")
local RangeDataBase = require("Game/RangeCheckTrigger/RangeData/RangeDataBase")
local RangeCheckTriggerDefine = require("Game/RangeCheckTrigger/RangeCheckTriggerDefine")
local TriggerGamePlayType = RangeCheckTriggerDefine.TriggerGamePlayType
local HintEffectType = ProtoRes.DiscoverNote_Hint_Effect_Type
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR

---@class RangeDataDiscoverNoteEffect
local RangeDataDiscoverNoteEffect = LuaClass(RangeDataBase)

---Ctor
function RangeDataDiscoverNoteEffect:Ctor()
    self.NoteClueCache = nil --缓存用于快速获取Actor
end

--- 处理相关进入范围逻辑
function RangeDataDiscoverNoteEffect:OnEnterTheRange()
    local EntityID = self.EntityID
    if not EntityID then
        return
    end
    local EobjClue = ActorUtil.GetActorByEntityID(EntityID)
    if not EobjClue then
        return
    end
    FLOG_INFO("RangeOverlap RangeDataDiscoverNoteEffect:EnterTheRange %s", EntityID)
    --EobjClue:SetSharedGroupVisible(true, true)
    EobjClue:SetActorHiddenInGame(false)
    self.NoteClueCache = EobjClue
end

--- 处理相关离开范围逻辑
function RangeDataDiscoverNoteEffect:OnExitTheRange()
    local EobjClue = self.NoteClueCache
    if not EobjClue then
        local EntityID = self.EntityID
        if not EntityID then
            return
        end
        EobjClue = ActorUtil.GetActorByEntityID(EntityID)
        if not EobjClue then
            return
        end
    end
    
    FLOG_INFO("RangeOverlap RangeDataDiscoverNoteEffect:ExitTheRange")
    --EobjClue:SetSharedGroupVisible(false, true)
    EobjClue:SetActorHiddenInGame(true)
    self.NoteClueCache = nil
end

------ 必须实现 ------
--- 获取所属功能类型
function RangeDataDiscoverNoteEffect:OnGetGamePlayType()
    return TriggerGamePlayType.DiscoverNoteClueEffect
end

function RangeDataDiscoverNoteEffect:GetLocation()
    local EntityID = self.EntityID
    if EntityID then
        local Actor = ActorUtil.GetActorByEntityID(EntityID)
        if Actor then
            return Actor:FGetActorLocation()
        end
    end
end

--- 获取具体的胶囊体触发器数据
function RangeDataDiscoverNoteEffect:OnGetCylinderTriggerParams()
    local EntityID = self.EntityID
    if not EntityID then
        return
    end

    local PosInfo = self:GetLocation()
    if not PosInfo then
        return
    end

    local Cylinder = {
        Start = {
            X = PosInfo.X,
            Y = PosInfo.Y,
            Z = PosInfo.Z,
        },
        Radius = 100,
        Height = 10000, -- 默认胶囊体100m
    }

    local ResID = ActorUtil.GetActorResID(EntityID)
    if not ResID then
        return Cylinder
    end

    local HintCfg = DiscoverNoteHintCfg:FindCfg(string.format("PickEobjId = %d", ResID))
    if not HintCfg then
        return Cylinder
    end

    local EffectType = HintCfg.EffectType or HintEffectType.HINT_EFFECT_TYPE_NONE
    local EffectVisbleRangeCfg = DiscoverNoteClueEffectRangeCfg:FindCfgByKey(EffectType)
    if not EffectVisbleRangeCfg then
        return Cylinder
    end

    Cylinder.Radius = EffectVisbleRangeCfg.EffectRange or 0

    return Cylinder
end

return RangeDataDiscoverNoteEffect