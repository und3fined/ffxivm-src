-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ItemCfg : CfgBase
local ItemCfg = {
	TableName = "c_item_cfg",
    LruKeyType = "integer",
	KeyName = "ItemID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'ItemName',
            },
            {
                Name = 'ItemDesc',
            },
            {
                Name = 'EffectDesc',
            },
            {
                Name = 'CustomText',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ItemCfg, { __index = CfgBase })

ItemCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

local CommonUtil = require("Utils/CommonUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIUtil = require("Utils/UIUtil")
--- 通过IconID获取图标路径
--- 建议直接在VM中保存IconID，View中使用UIBinderSetBrushFromIconID
function ItemCfg.GetIconPath(IconID)
	return UIUtil.GetIconPath(IconID)
end

function ItemCfg:GetItemName(ResID)
	local Cfg = self:FindCfgByKey(ResID)
	if Cfg == nil then
		return ""
	end

	return CommonUtil.GetTextFromStringWithSpecialCharacter(Cfg.ItemName) 
end

function ItemCfg:GetItemDesc(ResID)
	local Cfg = self:FindCfgByKey(ResID)
	if Cfg == nil then
		return ""
	end
	return CommonUtil.GetTextFromStringWithSpecialCharacter(Cfg.ItemDesc) 
end

function ItemCfg:GetItemEffectDesc(ResID)
	local Cfg = self:FindCfgByKey(ResID)
	if Cfg == nil then
		return ""
	end
	return CommonUtil.GetTextFromStringWithSpecialCharacter(Cfg.EffectDesc) 
end

return ItemCfg
