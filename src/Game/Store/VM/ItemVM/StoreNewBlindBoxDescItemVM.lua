
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local HairUnlockCfg = require("TableCfg/HairUnlockCfg")

---@class StoreNewBlindBoxDescItemVM : UIViewModel
local StoreNewBlindBoxDescItemVM = LuaClass(UIViewModel)
---Ctor
function StoreNewBlindBoxDescItemVM:Ctor()
    self.ID = 0
	self.bIsOwned = false
	--- 显示概率/已拥有
	self.TextProbability = ""
    self.Icon = ""

	--- 通用物品里需要隐藏的节点
	self.NumVisible = false
	self.HideItemLevel = true
	self.IconChooseVisible = false
	self.ItemLevelVisible = false
end

function StoreNewBlindBoxDescItemVM:UpdateVM(Value)
	self.ID = Value.ID
	self.bIsOwned = Value.bIsOwned
	local HairUnlockCfg = HairUnlockCfg:FindCfgByItemID(Value.ID)

	if HairUnlockCfg ~= nil then
		self.Icon = _G.StoreMgr:GetHairIconByHairID(HairUnlockCfg.HairID)
	end

	--- 显示概率/已拥有
	self.TextProbability = Value.bIsOwned and RichTextUtil.GetText(LSTR(950022), "#89bd88") or string.format("%.1f%s", (Value.DropWeight / Value.AllDropWeight) * 100, "%")
end
function StoreNewBlindBoxDescItemVM:IsEqualVM(Value)
	return true
end

return StoreNewBlindBoxDescItemVM