local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MajorUtil = require("Utils/MajorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")

local RoleInitCfg = require("TableCfg/RoleInitCfg")
local AttrSortShowCfg = require("TableCfg/AttrSortShowCfg")
local GlobalCfg = require("TableCfg/GlobalCfg")

local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")

local AttributeSummaryItemVM = require("Game/Attribute/VM/AttributeSummaryItemVM")

local LevelExpCfg = require("TableCfg/LevelExpCfg")
local ScoreMgr = require("Game/Score/ScoreMgr")
local EquipmentMgr = _G.EquipmentMgr

---@class AttributeMainPageVM : UIViewModel
local AttributeMainPageVM = LuaClass(UIViewModel)

function AttributeMainPageVM:Ctor()
    self.Level = 0
    self.ExpProgress = 0
    self.ExpText = ""
    self.ProfID = 0
	self.bInLevelSync = false
    self.bHasMaxLevelProf = false

    self.ListAttrKey = {}
    self.Map_AttributeSummaryItemVM = {}
end

--计算属性显示类 
---@return ProtoRes.ProfClassShowType
function AttributeMainPageVM.GenClassShowType(Prof)
    local ProfFunc = RoleInitCfg:FindFunction(Prof)
    local ProfClass = RoleInitCfg:FindProfSpecialization(Prof)

    --计算ShowType
    local ShowType = ProtoRes.ProfClassShowType.COMBAT
    if ProfClass == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT then
        --战斗类
        ShowType = ProtoRes.ProfClassShowType.COMBAT
    elseif ProfClass == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION and ProfFunc == ProtoCommon.function_type.FUNCTION_TYPE_GATHER then
        --采集类
        ShowType = ProtoRes.ProfClassShowType.GATHER
    elseif ProfClass == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION and ProfFunc == ProtoCommon.function_type.FUNCTION_TYPE_PRODUCTION then
        --制造类
        ShowType = ProtoRes.ProfClassShowType.PRODUCTION
    end
    return ShowType
end

function AttributeMainPageVM:InitAttr()
    local AttributeComponent = MajorUtil.GetMajorAttributeComponent()
    if AttributeComponent == nil then
        return
    end
    
	self:UpdateProfID()
    self:UpdateLevelValue()
    self:UpdateExpValue()
    self:CheckOtherProfLevel()
	self.bInLevelSync = MajorUtil.IsInLevelSync()

    local ShowType = AttributeMainPageVM.GenClassShowType(AttributeComponent.ProfID)

    --根据属性排序显示表填充ListAttrKey
    local MainList = AttrSortShowCfg:GetAttrSortList(ShowType, ProtoRes.AttrShowSheet.ALL, ProtoRes.AttrShowTag.BASE)
    local SubList = AttrSortShowCfg:GetAttrSortList(ShowType, ProtoRes.AttrShowSheet.ALL, ProtoRes.AttrShowTag.SUB)

	self.ListAttrKey = {}
    for _,v in ipairs(MainList) do
        self.ListAttrKey[#self.ListAttrKey + 1] = v.AttrName
    end
    for _,v in ipairs(SubList) do
        self.ListAttrKey[#self.ListAttrKey + 1] = v.AttrName
    end

	self.Map_AttributeSummaryItemVM = {}
    --填充Map_AttributeSummaryItemVM
    for _,AttrKey in pairs(self.ListAttrKey) do
        local AttributeSummaryItemVM = AttributeSummaryItemVM.New()
        AttributeSummaryItemVM.AttrKey = EquipmentMgr:GetAttributeRealType(AttrKey)
        AttributeSummaryItemVM.AttrValue = AttributeComponent:GetAttrValue(AttrKey)

        self.Map_AttributeSummaryItemVM[AttrKey] = AttributeSummaryItemVM
    end
end

function AttributeMainPageVM:UpdateAttrValue()
    local AttributeComponent = MajorUtil.GetMajorAttributeComponent()
    if AttributeComponent == nil then
        return
    end

    for AttrKey,AttributeSummaryItemVM in pairs(self.Map_AttributeSummaryItemVM) do
        AttributeSummaryItemVM.AttrValue = AttributeComponent:GetAttrValue(AttrKey)
    end
end

function AttributeMainPageVM:UpdateLevelValue(Params)
    local Level = MajorUtil.GetMajorLevel()
	if Params then Level = Params.RoleDetail.Simple.Level end
    self.Level = Level
end

function AttributeMainPageVM:UpdateExpValue(Params)
    local EquipmentPorfExp = ProfUtil.GetProfTrueExp(MajorUtil.GetMajorProfID())
    local CurExp = EquipmentPorfExp and EquipmentPorfExp or ScoreMgr:GetExpScoreValue()
    if Params then CurExp = Params.ULongParam3 end

    local LevelCfg = LevelExpCfg:FindCfgByKey(MajorUtil.GetTrueMajorLevel())
    if LevelCfg == nil then
        self.ExpProgress = 1
        self.ExpText = string.format("<span color=\"#d1ba8eFF\">%s</>", LSTR(1050190))  -- 没配就是满级
    else
        local MaxExp = LevelCfg.NextExp
        self.ExpText = string.format("<span color=\"#d1ba8eFF\">%d/</><span color=\"#C8C3C3FF\">%d</>", CurExp, MaxExp)
        self.ExpProgress = CurExp < MaxExp and CurExp/MaxExp or 1
    end
end

function AttributeMainPageVM:UpdateProfID(ProfID)
	self.ProfID = nil ~= ProfID and ProfID or MajorUtil.GetMajorProfID()
end

function AttributeMainPageVM:CheckOtherProfLevel()
    local MaxLevelCfg = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_MAX_LEVEL) or {}
    local MaxLevel = MaxLevelCfg.Value[1] or 50
    local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
    local Tmp = false
    if RoleDetail and RoleDetail.Prof and RoleDetail.Prof.ProfList then
        for k, v in pairs(RoleDetail.Prof.ProfList) do
            local IsCombatProf = ProfUtil.IsCombatProf(v.ProfID)
            local SelfIsCombatProf = ProfUtil.IsCombatProf(self.ProfID)
            if IsCombatProf and SelfIsCombatProf and v.Level and v.Level >= MaxLevel and self.ProfID ~= v.ProfID then
                Tmp = true
            end
        end
    end
    self.bHasMaxLevelProf = Tmp
end

return AttributeMainPageVM