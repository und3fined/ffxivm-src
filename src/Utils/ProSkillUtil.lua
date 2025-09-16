--
-- Author: henghaoli
-- Date: 2025-03-03 15:01:00
-- Description: 量谱相关接口
--

local SpectrumCfg = require("TableCfg/SpectrumCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local RoleSkillInitCfg = require("TableCfg/RoleSkillInitCfg")


---@class ProSkillUtil
local ProSkillUtil = {

}


--- 读表获取量谱最大值
--- MainProSkillMgr里的同名接口仅适用主角, 有修正
---@param SpectrumID number
---@return number
function ProSkillUtil.GetSpectrumMaxValue(SpectrumID)
    return SpectrumCfg:FindValue(SpectrumID, "SpectrumMax")
end

--- 读表获取对应职业对应Index的量谱ID
---@param ProfID number
---@param MapType number - 区分PVP还是PVE, 对应SkillUtil.MapType
---@param Index number - 量谱编号, 默认获取第1个量谱的ID
---@return number - SpectrumID
function ProSkillUtil.GetProfSpectrumID(ProfID, MapType, Index)
    local SkillGroupList = RoleInitCfg:FindValue(ProfID, "SkillGroup")
    if not SkillGroupList then
        return
    end

    local SkillGroupID = SkillGroupList[MapType]
    local Cfg = RoleSkillInitCfg:FindCfgByKey(SkillGroupID)
    if not Cfg then
        return
    end

    return Cfg.Spectrum[Index or 1]
end


return ProSkillUtil