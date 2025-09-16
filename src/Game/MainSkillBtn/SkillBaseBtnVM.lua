local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")

---@class SkillBaseBtnVM : UIViewModel
local SkillBaseBtnVM = LuaClass(UIViewModel)

local MPColor = "FFAFE9FF"
local GatherColor = "A7E7FFFF"
local ProductionColor = "CE89FFFF"
local ShortColor = "DC5868FF"

---Ctor
function SkillBaseBtnVM:Ctor()
    self.SkillID = 0

    self.SkillIcon = nil
    --self.bSkillIcon = true

    self.SkillCDText = nil
    self.bNormalCD = false
    self.NormalCDPercent = 0

    self.bCommonMask = false
    self.bChargeProcessVisible = false
    self.bTextRechargeTimes = false
    self.bAnimSkillLimitLoop = false
    self.RechargeTimeText = nil
    self.RechargeTimesColorAndOpacity = _G.UE.FLinearColor(1, 1, 1, 1)
    self.ChargeCDPercent = 0

    self.ImgLockIcon = nil
    local BindProperty = self:FindBindableProperty("ImgLockIcon")
    if BindProperty then
        BindProperty:SetNoCheckValueChange(true)
    end

    self.SkillCostText = nil
    self.SkillCostColor = ShortColor
    self.bSkillCost = false
    rawset(self, "bAttrSkillCost", false)
    rawset(self, "bMultiSkill", false)
end

function SkillBaseBtnVM:OnInit()

end

function SkillBaseBtnVM:SetMultiSkillFlag(bMultiSkill)
    rawset(self, "bMultiSkill", bMultiSkill)
end

function SkillBaseBtnVM:SetSkillID(SkillID)
    if self.SkillID == SkillID then
        return
    end
    self.SkillID = SkillID
    local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
    
    if Cfg then
        local SkillFirstClass = ProtoRes.skill_first_class
        local AssetIDMatch = ProtoCommon.attr_type.attr_mp
        local SkillCostValidColor = MPColor
        if Cfg.SkillFirstClass == SkillFirstClass.LIFE_SKILL then
            SkillCostValidColor = GatherColor
            AssetIDMatch = ProtoCommon.attr_type.attr_gp
        elseif Cfg.SkillFirstClass == SkillFirstClass.PRODUCTION_SKILL then
            SkillCostValidColor = ProductionColor
            --制造蓝图与通用蓝图不同，暂不匹配
            AssetIDMatch = 0
        end
        rawset(self, "CostAttr", AssetIDMatch)
        rawset(self, "SkillCostValidColor", SkillCostValidColor)

        local bSkillCost = false
        local CostList = Cfg.CostList
        for _, value in pairs(CostList) do
            if value.AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_ATTR then
                local AssetID = value.AssetId
                local AdditionAssetID = value.AdditionAssetId
                if AdditionAssetID == 0 then
                    AdditionAssetID = AssetID
                end

                if AdditionAssetID == AssetIDMatch then
                    bSkillCost = true
                end
            end
        end

        rawset(self, "bAttrSkillCost", bSkillCost)
    end
end

function SkillBaseBtnVM:CanUpdateSkillCost()
    return rawget(self, "bAttrSkillCost") and not self.ImgLockIcon and not rawget(self, "bMultiSkill")
end

function SkillBaseBtnVM:SetSkillCostFlag(bValid)
    self.bSkillCost = bValid
end

function SkillBaseBtnVM:SetSkillCost( RequireValid, RequireCost)
    self.SkillCostText = tostring(math.floor(RequireCost or 0))
    self.SkillCostColor = RequireValid and rawget(self, "SkillCostValidColor") or ShortColor
end

function SkillBaseBtnVM:GetCostAttr()
    return rawget(self, "CostAttr")
end

function SkillBaseBtnVM:SetLockIcon(LockIcon)
    self.ImgLockIcon = LockIcon

end

return SkillBaseBtnVM