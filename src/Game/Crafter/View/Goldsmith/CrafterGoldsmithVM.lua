local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local CrafterConfig = require("Define/CrafterConfig")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

---@class CrafterGoldsmithVM : UIViewModel
local CrafterGoldsmithVM = LuaClass(UIViewModel)

function CrafterGoldsmithVM:Ctor()
    self:ResetParams()
end

function CrafterGoldsmithVM:ResetParams()
    self.GoldsmithConfig = CrafterConfig.ProfConfig[ProtoCommon.prof_type.PROF_TYPE_GOLDSMITH]
    local GoldsmithConfig = self.GoldsmithConfig
    self.TensionValue = GoldsmithConfig.TensionValueDefault
    self.TensionSliderPercent = self.TensionValue /GoldsmithConfig.TensionValueMax
    self.TensionState = nil
    self.bIsTensionInRedZone = false
    self.bIsTensionInBlueZone = false
    self.bIsTensionInRightPurpleZone = false
    self.bIsTensionInLeftPurpleZone = false

    self.bHasBuffRed = false
    self.bHasBuffBlue = false

    self.bIsPurpleZoneVisible = false
end

local TensionZoneList = {
    "bIsTensionInLeftPurpleZone",
    "bIsTensionInRightPurpleZone",
    "bIsTensionInRedZone",
    "bIsTensionInBlueZone"
}

-- 四个数字分别表示是否在红区, 是否在蓝区, Percent是否在左侧, 是否在眼力的效果范围内
local BuffEffectMap = {
    bIsTensionInLeftPurpleZone  = {["0111"] = true},
    bIsTensionInRightPurpleZone = {["1001"] = true},
    bIsTensionInRedZone         = {["1000"] = true},
    bIsTensionInBlueZone        = {["0110"] = true},
}

local function Bool2Char(Value)
    return Value and "1" or "0" 
end

local function Bool2String(...)
    local Ret = ""
    for _, Value in ipairs({...}) do
        Ret = Ret .. Bool2Char(Value)
    end
    return Ret
end

function CrafterGoldsmithVM:UpdateBuffEffects()
    self.bIsPurpleZoneVisible = self.bIsPurpleZoneVisibleCached or false
    local State = Bool2String(self.bHasBuffRed, self.bHasBuffBlue, self.TensionSliderPercent < 0.5, self.bIsPurpleZoneVisible)
    self.TensionState = State
    for _, ZoneName in pairs(TensionZoneList) do
        if BuffEffectMap[ZoneName][State] then
            self[ZoneName] = true
        else
            self[ZoneName] = false
        end
    end
end

function CrafterGoldsmithVM:UpdateFeatures(Features)
    if not Features then
		return
	end

    self.TensionValue = Features[ProtoCS.FeatureType.FEATURE_TYPE_TENSION] or self.TensionValue
    local GoldsmithConfig = self.GoldsmithConfig
    self.TensionSliderPercent = self.TensionValue / GoldsmithConfig.TensionValueMax
end

function CrafterGoldsmithVM:OnBuffChanged(BuffID, bHasBuff)
    -- 检查紧张相关的Buff
    local GoldsmithConfig = self.GoldsmithConfig
    local TensionType = GoldsmithConfig.BuffID_TensionTypeMap[BuffID]
    if TensionType then
        self[TensionType] = bHasBuff
    end

    -- 检查眼力的Buff
    if BuffID == GoldsmithConfig.PurpleZoneBuffID then
        self.bIsPurpleZoneVisibleCached = bHasBuff
    end
end

return CrafterGoldsmithVM