
-- local ESkillCastType = _G.UE.ESkillCastType
-- local RoleInitCfg = require("TableCfg/RoleInitCfg")
-- local SkillMainCfg = require("TableCfg/SkillMainCfg")
-- local MajorUtil = require("Utils/MajorUtil")
-- local LifeSkillConfig = require("Game/Skill/LifeSkillConfig")
-- local ActorUtil = require("Utils/ActorUtil")
local SkillUtil = require("Utils/SkillUtil")
local BuffCfg  = require("TableCfg/BuffCfg")
local ProtoRes = require("Protocol/ProtoRes")
local BuffDefine = require("Game/Buff/BuffDefine")
local MajorBuffVM = require("Game/Buff/VM/MajorBuffVM")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local BonusStateBuffCfg = require("TableCfg/BonusStateBuffCfg")
-- local BuffDefine = require("Game/Buff/BuffDefine")


---@class BuffUtil
local BuffUtil = {

}

function BuffUtil.GetBuffTime(ExpdTime, AdjustValue)
	local BuffTime = SkillUtil.StampToTime(ExpdTime)
	local AdjustCount = BuffTime / AdjustValue
	local AdjustFloat = AdjustCount % 1
	if AdjustFloat < 0.5 then
		BuffTime = (AdjustCount - AdjustFloat) * AdjustValue
	else
		BuffTime = (AdjustCount - AdjustFloat + 1) * AdjustValue
	end

	return  BuffTime
end

--从buff列表中查找Buff并返回索引和Buff实例
function BuffUtil.FindBuff(BuffID, GiverID, BuffList)
	for index, value in ipairs(BuffList) do
		if value.BuffID == BuffID and (value.GiverID == 0 or value.GiverID == GiverID) then
			return value, index
		end
	end

	return nil
end

function BuffUtil.IsPositiveBuffByID(ID)
	local DB = BuffCfg:FindCfgByKey(ID)
	if nil == DB then return end
	return BuffUtil.IsPositiveBuffByCfg(DB)
end

function BuffUtil.IsPositiveBuffByCfg(DB)
	local BuffType = DB.Type
	return ProtoRes.buff_showtype.BUFF_SHOWTYPE_POSITIVE == BuffType
end

function BuffUtil.IsNegativeBuffByID(ID)
	local DB = BuffCfg:FindCfgByKey(ID)
	if nil == DB then return end
	return BuffUtil.IsNegativeBuffByCfg(DB)
end

function BuffUtil.IsNegativeBuffByCfg(DB)
	local BuffType = DB.Type
	return ProtoRes.buff_showtype.BUFF_SHOWTYPE_NEGATIVE == BuffType
end


--- @param BuffID number
--- @param BuffType Buff类型，不填默认战斗buf
function BuffUtil.IsMajorBuffExist(BuffID, BuffType)
	BuffType = BuffType or BuffDefine.BuffSkillType.Combat
	if BuffType == BuffDefine.BuffSkillType.Combat then
		return _G.SkillBuffMgr:IsBuffExist(BuffID)
	else
		return _G.LifeSkillBuffMgr:IsMajorContainBuff(BuffID)
	end
end

---BuffUtil.GetBuffBonusStateValueByScoreID 获取目前自身对传入货币有加成的BUFF数量
---@param InScoreID int32 Description
---@return  table 返回一个table , key是BonusStateEffectSubType, value 是int32，后续自行计算
function BuffUtil.GetBuffBonusStateValueByScoreID(InScoreID)
	if (InScoreID == nil) then
		_G.FLOG_ERROR("BuffUtil.GetBuffBonusStateValueByScoreID 出错，传入的InScoreID无效")
		return nil
	end

	local ItemTableData = ItemCfg:FindCfgByKey(InScoreID)
	if (ItemTableData == nil) then
		_G.FLOG_ERROR("ItemCfg:FindCfgByKey 出错，无法获取数据，ID是:%s", InScoreID)
		return nil
	end

	if (ItemTableData.ItemType ~= ProtoCommon.ITEM_TYPE_DETAIL.MISCELLANY_CURRENCY) then
		return nil
	end

	if (MajorBuffVM == nil or MajorBuffVM.BuffList == nil or MajorBuffVM.BuffList.Items == nil) then
		return nil
	end

	local ResultTable = {}
	-- 显示的BUFF
	do
		for Key, BuffVM in pairs(MajorBuffVM.BuffList.Items) do
			local BuffStateCfg = BonusStateBuffCfg:FindCfgByKey(BuffVM.BuffID)
			if (BuffStateCfg ~= nil) then
				for _, EffectData in pairs(BuffStateCfg.EffectItems) do
					for Index = 1, #EffectData.Values, 2 do
						if (EffectData.Values[Index] == InScoreID) then
							local TempValue = (ResultTable[EffectData.SubType] or 0) + EffectData.Values[Index + 1]
							ResultTable[EffectData.SubType] = TempValue
						end
					end
				end
			end
		end
	end

	-- 不显示的BUFF
	do
		for Key, BuffID in pairs(MajorBuffVM.UnShowBuffTable) do
			local BuffStateCfg = BonusStateBuffCfg:FindCfgByKey(BuffID)
			if (BuffStateCfg ~= nil) then
				for _, EffectData in pairs(BuffStateCfg.EffectItems) do
					for Index = 1, #EffectData.Values, 2 do
						if (EffectData.Values[Index] == InScoreID) then
							local TempValue = (ResultTable[EffectData.SubType] or 0) + EffectData.Values[Index + 1]
							ResultTable[EffectData.SubType] = TempValue
						end
					end
				end
			end
		end
	end

	return ResultTable
end

return BuffUtil