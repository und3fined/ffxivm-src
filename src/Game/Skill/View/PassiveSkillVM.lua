
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local SkillUtil = require("Utils/SkillUtil")
local MajorUtil = require("Utils/MajorUtil")

local Normal_ImgSize = _G.UE.FVector2D(58, 58)
local Normal_IconSize = _G.UE.FVector2D(40, 40)
local Normal_MaskSize = _G.UE.FVector2D(45, 45)

local Select_ImgSize = _G.UE.FVector2D(92, 92)
local Select_IconSize = _G.UE.FVector2D(64, 64)
local Select_MaskSize = _G.UE.FVector2D(71, 71)

---@class PassiveSkillVM : UIViewModel
local PassiveSkillVM = LuaClass(UIViewModel)

function PassiveSkillVM:Ctor()
    self.SkillIcon = ""
    self.SkillID = 0
    self.bSelected = false
    self.bLearned = false

    self.ImgSize = nil
    self.IconSize = nil
    self.MaskSize = nil
    self.RedDotNum = nil
end

function PassiveSkillVM:OnInit()

end

function PassiveSkillVM:OnBegin()
end

function PassiveSkillVM:OnEnd()
end

function PassiveSkillVM:OnShutdown()
end

function PassiveSkillVM:UpdateVM(Value)
    self:SetSkillID(Value)
    --self:SetLearnedStatus(Value)
end

function PassiveSkillVM:UpdateSeriesVM(SkillID, bSelected)
    self:SetSkillID(SkillID)
    self:SetSelectedStatus(bSelected)
end

function PassiveSkillVM:SetSkillID(SkillID)
    self.SkillID = SkillID
    if SkillID ~= 0 then
        self.SkillIcon = SkillMainCfg:FindValue(SkillID, "Icon")
    end
end

function PassiveSkillVM:SetLearnedStatus(SkillID)
    local ProfID = MajorUtil.GetMajorProfID()
    local Level = SkillUtil.GetSkillLearnLevel(SkillID, ProfID)
    local MajorLevel = MajorUtil.GetMajorLevelByProf(ProfID)
    self.bLearned = Level <= MajorLevel
end

function PassiveSkillVM:SetSelectedStatus(bSelected)
    self.bSelected = bSelected
    if bSelected then
        self.ImgSize = Select_ImgSize
        self.IconSize = Select_IconSize
        self.MaskSize = Select_MaskSize
    else
        self.ImgSize = Normal_ImgSize
        self.IconSize = Normal_IconSize
        self.MaskSize = Normal_MaskSize
    end
end

function PassiveSkillVM:IsEqualVM(Value)
    return self.SkillID == Value
end

return PassiveSkillVM