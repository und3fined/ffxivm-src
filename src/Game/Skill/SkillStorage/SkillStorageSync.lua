
local StorageSkillCfg = require("TableCfg/StorageSkillCfg")
local ActorUtil = require("Utils/ActorUtil")

local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ProtoCommon = require("Protocol/ProtoCommon")

local SkillStorageSync = {

}

local StorageEffectList = {}



function SkillStorageSync.PlayStorageEffect(EntityID, EffectID, PlayRate)
    if EffectID == nil then
        return
    end

	StorageEffectList[EntityID] = _G.SkillSingEffectMgr:PlaySingEffect(EntityID, EffectID, nil, PlayRate)
end

function SkillStorageSync.PlayStorageEffectbySkillID(EntityID, SkillID)
	local SingID = StorageSkillCfg:FindValue(SkillID, "SingID")

    local QuickAttrInvalid = SkillMainCfg:FindValue(SkillID, "QuickAttrInvalid")
	local ShortenTimeCoefficient = 1
	if QuickAttrInvalid == 0 then
        local AttributeComponent = ActorUtil.GetActorAttributeComponent(EntityID)
        if AttributeComponent then
            ShortenTimeCoefficient = 1 - AttributeComponent:GetAttrValue(ProtoCommon.attr_type.attr_shorten_action_time) / 10000
        end
    end

    SkillStorageSync.PlayStorageEffect(EntityID, SingID, ShortenTimeCoefficient)
end

function SkillStorageSync.BreakStorageEffect(EntityID)
    if StorageEffectList[EntityID] then
	    _G.SkillSingEffectMgr:BreakSingEffect(EntityID, StorageEffectList[EntityID])
	    StorageEffectList[EntityID] = nil
    end
end

return SkillStorageSync