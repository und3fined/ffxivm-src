
local ProfUtil = {}
-- 现默认Prof等同ID
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProfDefine = require("Game/Profession/ProfDefine")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
-- local FUNCTION_TYPE = ProtoCommon.function_type
local SPE_TYPE = ProtoCommon.specialization_type
local LevelExpCfg = require("TableCfg/LevelExpCfg")


function ProfUtil.Prof2ClassIcon(Prof)
    return ProfDefine.ProfClassIconMap[Prof]
end

function ProfUtil.Prof2ClassName(Prof)
    return ProfDefine.ProfFuncNameMap[Prof]
end

function ProfUtil.Prof2Icon(Prof)
    return RoleInitCfg:FindRoleInitProfIcon(Prof)
    
end

function ProfUtil.Prof2Name(Prof)
    return RoleInitCfg:FindRoleInitProfName(Prof)
end

function ProfUtil.Prof2Func(Prof)
    return RoleInitCfg:FindFunction(Prof)
end

function ProfUtil.Prof2FuncIcon(Prof)
    local Func = ProfUtil.Prof2Func(Prof)
    if Func then
        return ProfDefine.ProfFuncIconMap[Func]
    end
end

function ProfUtil.Prof2FuncName(Prof)
    local Func = ProfUtil.Prof2Func(Prof)
    if Func then
        return ProfDefine.ProfFuncNameMap[Func]
    end
end

function ProfUtil.ProfFunc2Icon(Func)
    if Func then
        return ProfDefine.ProfFuncIconMap[Func]
    end
end

function ProfUtil.LackProfFunc2Icon(F)
    return F and ProfDefine.LackProfFuncIconMap[F] or nil
end

function ProfUtil.LackProfFunc2IconForMatch(F)
    return F and ProfDefine.LackProfFuncIconMapForMatch[F] or nil
end

function ProfUtil.IsCombatProf(Prof)
    local ProfSpe = RoleInitCfg:FindProfSpecialization(Prof)
    return ProfSpe == SPE_TYPE.SPECIALIZATION_TYPE_COMBAT
end

function ProfUtil.IsProductionProf(Prof)
    local ProfSpe = RoleInitCfg:FindProfSpecialization(Prof)
    return ProfSpe == SPE_TYPE.SPECIALIZATION_TYPE_PRODUCTION
end

local ProfFuncPriority = {
    [ProtoCommon.function_type.FUNCTION_TYPE_GUARD] = 1,
    [ProtoCommon.function_type.FUNCTION_TYPE_RECOVER] = 2,
    [ProtoCommon.function_type.FUNCTION_TYPE_ATTACK] = 3,
}

local GetProfOrder = function(ProfID)
    local Cfg = RoleInitCfg:FindCfgByKey(ProfID)
    return Cfg and ProfFuncPriority[Cfg.Function or ProfFuncPriority] or 999, Cfg and Cfg.SortOrder or 999
end

--- 根据职能进行排序 (职能 -> sort order -> profid -> name)
function ProfUtil.SortByProfID(a, b)
    if a and b then
        if a.ProfID and b.ProfID then
            local OrderA, SA = GetProfOrder(a.ProfID)
            local OrderB, SB = GetProfOrder(b.ProfID)
            if OrderA ~= OrderB then
               return OrderA < OrderB 
            end
            if a.ProfID ~= b.ProfID then
                if SA ~= SB then
                   return SA < SB 
                end
                return a.ProfID < b.ProfID
            end
            return (a.Name or "") < (b.Name or "")
        end

        return a.ProfID and not b.ProfID
    end

    return a and not b
end

--是否生活职业(在策划眼里都是生产职业中的采集职业)
function ProfUtil.IsGpProf(ProfID)
    if ProfID == ProtoCommon.prof_type.PROF_TYPE_MINER
        or ProfID == ProtoCommon.prof_type.PROF_TYPE_BOTANIST
        or ProfID == ProtoCommon.prof_type.PROF_TYPE_FISHER then
            return true
    end

    return false
end

--是否制造职业
function ProfUtil.IsCrafterProf(ProfID)
    if not ProfID then
        _G.FLOG_ERROR("ProfUtil.IsCrafterProf ProfID = NIL")
        return false
    end
    if ProfID >= ProtoCommon.prof_type.PROF_TYPE_BLACKSMITH and ProfID <= ProtoCommon.prof_type.PROF_TYPE_CULINARIAN then
		return true
	end

	return false
end

---GetProfClassIcon 获取当前职业类型Icon
---@param InProfClass ProtoCommon.class_type
function ProfUtil.GetProfClassIcon(InProfClass)
	return ProfDefine.ProfClassIconMap[InProfClass]
end

---GetProfClassColor 获取当前职业类型Color
---@param InProfClass ProtoCommon.class_type
function ProfUtil.GetProfClassColor(InProfClass)
	return ProfDefine.ProfClassColorMap[InProfClass]
end

---GetProfClassColor 获取当前职业底板图
---@param InProfClass ProtoCommon.class_type
function ProfUtil.GetProfClassColorBgPath(InProfClass)
    return ProfDefine.ProfClassBgPathMap[InProfClass]
end

---GetProfBgColor 获取当前职业底板Color
---@param InProfClass ProtoCommon.class_type
function ProfUtil.GetProfBgColor(InProfClass)
    local BgColor = ProfDefine.ProfBgColor[InProfClass]
    if not BgColor then
        return ProfDefine.ProfBgColor[ProtoCommon.function_type.FUNCTION_TYPE_NULL]
    end
    return BgColor
end

---IsAdvancedProf 判断当前职业是否为特职
---@param ProfID ProtoCommon.prof_type
function ProfUtil.IsAdvancedProf(ProfID)
    return ProtoRes.prof_level.PROF_LEVEL_ADVANCED == (RoleInitCfg:FindValue(ProfID, "ProfLevel") or 0)
end


---GetAdvancedProf 获取当前职业的特职职业
---@param ProfID ProtoCommon.prof_type
function ProfUtil.GetAdvancedProf(ProfID)
    local Cfg = RoleInitCfg:FindCfgByKey(ProfID)
    if not Cfg or Cfg.ProfLevel == ProtoRes.prof_level.PROF_LEVEL_ADVANCED then
        return ProfID
    end
    return Cfg.AdvancedProf
end

local ColorActive = "D5D5D5FF"
local ColorInactive = "828282FF"
local ColorMaxLevel = "D1906DFF"

local function IsMaxLevel(Level)
	return Level >= LevelExpCfg:GetMaxLevel()
end

function ProfUtil.GetLevelUniformColor(Level)
    local LevelColor
    if IsMaxLevel(Level) then
        LevelColor = ColorMaxLevel
    else
        LevelColor = ColorActive
    end

    return LevelColor
end

function ProfUtil.GetProfClass(ProfID)
    local Cfg = RoleInitCfg:FindCfgByKey(ProfID)
    if Cfg then
       return Cfg.Class 
    end
end

function ProfUtil.GetProfTrueExp(ProfID)
	local MajorRoleDetail = _G.ActorMgr:GetMajorRoleDetail()
	if nil == MajorRoleDetail or not MajorRoleDetail.Prof or not MajorRoleDetail.Prof.ProfList then
		return
	end

	local ProfInfo = MajorRoleDetail.Prof.ProfList[ProfID]
	if nil == ProfInfo then
		return
	end

	return ProfInfo.Exp
end

function ProfUtil.GetProfIconBySelected(ProfID, IsSelected)
    local Cfg = RoleInitCfg:FindCfgByKey(ProfID)
    if Cfg then
        local ProfAssetAbbr = Cfg.ProfAssetAbbr
        local SelectStr = IsSelected and "Select" or "Normal"
        return string.format("Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Job_%s_%s.UI_Icon_Tab_Job_%s_%s'",
        ProfAssetAbbr, SelectStr, ProfAssetAbbr, SelectStr)
    end
end

return ProfUtil