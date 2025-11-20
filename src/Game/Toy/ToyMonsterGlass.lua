-- Author: MichaelYang_LightPaw
-- Date: 2025-07-28 20:45
-- Description:玩具-怪物眼镜，客户端表现，怪物都会变成同一个指定模型，怪物在进入战斗或者玩具时间到，变回原模型
--

local LuaClass = require("Core/LuaClass")
local ToyBase = require("Game/Toy/ToyBase")
local ActorUtil = require("Utils/ActorUtil")
local ProtoRes = require("Protocol/ProtoRes")

local FLOG_ERROR = _G.FLOG_ERROR

---@class GoldGameNewBase
local ToyMonsterGlass = LuaClass(ToyBase)

function ToyMonsterGlass:Ctor()
end

-- 子类继承函数 --
function ToyMonsterGlass:OnInit(InToyID)
    if (self.ToyCfg == nil) then
        FLOG_ERROR("OnInit 失败，ToyCfg 为空")
        return false
    end

    if(self.ToyCfg.ParamInt == nil or self.ToyCfg.ParamInt[1] == nil) then
        FLOG_ERROR("Onint 失败， ParamInt参数无效")
        return false
    end
    self.ToyType = ProtoRes.ToyType.ToyTypeMonsterEye
    return true
end

function ToyMonsterGlass:OnToyBegin(InSceneID)
    if (self.ToyCfg == nil) then
        return
    end
    local ChangeID = self.ToyCfg.ParamInt[1]
    local ActorManager = _G.UE.UActorManager.Get()
    local AllMonsters = ActorManager:GetAllMonsters()

    -- 添加
    for Key,Value in pairs(AllMonsters) do
        -- body
        local AvatarComp = Value:GetAvatarComponent()
        if (AvatarComp) then
            AvatarComp:ChangeRoleByID(ChangeID, _G.UE.EChangeRoleReason.Toy, true)
        else
            FLOG_ERROR("GetAvatarComponent 错误，无法获取, EntityID : %s", Key)
        end
    end
end

function ToyMonsterGlass:OnToyExit()
    -- 移除
    local ActorManager = _G.UE.UActorManager.Get()
    local AllMonsters = ActorManager:GetAllMonsters()
    for Key,Value in pairs(AllMonsters) do
        -- body
        -- body
        local AvatarComp = Value:GetAvatarComponent()
        if (AvatarComp) then
            AvatarComp:ResumeChangeRole(_G.UE.EChangeRoleReason.Toy)
        else
            FLOG_ERROR("GetAvatarComponent 错误，无法获取, EntityID : %s", Key)
        end
    end
end

function ToyMonsterGlass:OnVisionEnter(InEntityType, InEntityID)
    self:InternalChange(true, InEntityType, InEntityID)
end

function ToyMonsterGlass:OnVisionLeave(InEntityType, InEntityID)
    self:InternalChange(false, InEntityType, InEntityID)
end

function ToyMonsterGlass:InternalChange(InbChange, InEntityType, InEntityID)
    if (InEntityType ~= _G.UE.EActorType.Monster) then
        return
    end

    if (self.ToyCfg == nil) then
        FLOG_ERROR("当前 ToyCfg 为空，请检查")
        return
    end

    local TargetActor = ActorUtil.GetActorByEntityID(InEntityID)
    if (TargetActor == nil) then
        FLOG_ERROR("无法获取角色， ENTITYID : %s", InEntityID)
        return
    end

    local AvatarComp = TargetActor:GetAvatarComponent()
    if (AvatarComp == nil) then
        FLOG_ERROR("GetAvatarComponent 错误， EntityID : %s", InEntityID)
        return
    end

    if (InbChange) then
        local ChangeID = self.ToyCfg.ParamInt[1]
        AvatarComp:ChangeRoleByID(ChangeID, _G.UE.EChangeRoleReason.Toy, true)
    else
        AvatarComp:ResumeChangeRole(_G.UE.EChangeRoleReason.Toy)
    end
end
-- END --

return ToyMonsterGlass