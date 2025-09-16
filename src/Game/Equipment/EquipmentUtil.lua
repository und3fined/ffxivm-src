local EquipmentDefine = require("Game/Equipment/EquipmentDefine")

local EquipmentUtil = {}

---GenRepairPrice 计算装备修理原价 消耗数量=Roundup(恢复的耐久值百分比*装备修理权重系数*装备物品品级/50)
---@param EndureDeg number 耐久度，百分数
---@param RepairWeight number 修理部位权重
---@param ItemLevel number 品级
function EquipmentUtil.GenRepairPrice(EndureDeg, RepairWeight, ItemLevel)
    if EndureDeg == 100 then return 0 end
    return math.ceil((100 - EndureDeg) * RepairWeight / 100.0)
end

---SortComparison 装备显示排序对比
---@param LeftPart ProtoCommon.equip_part
---@param RightPart ProtoCommon.equip_part
function EquipmentUtil.SortComparison(LeftPart, RightPart)
	return EquipmentDefine.EquipPartOrderMap[LeftPart] < EquipmentDefine.EquipPartOrderMap[RightPart]
end

return EquipmentUtil