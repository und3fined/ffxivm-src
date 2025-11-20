
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local HairUnlockCfg = require("TableCfg/HairUnlockCfg")
local ProtoRes = require("Protocol/ProtoRes")

local MysteryBoxTypes = ProtoRes.SpecialMysteryBoxTypes

---@class StoreNewBlindBoxDescItemVM : UIViewModel
local StoreNewBlindBoxDescItemVM = LuaClass(UIViewModel)
---Ctor
function StoreNewBlindBoxDescItemVM:Ctor()
    self.ID = 0
	self.bIsOwned = false
	--- 显示概率/已拥有
	self.TextProbability = ""
    self.Icon = ""
    self.ResID = 0

	--- 通用物品里需要隐藏的节点
	self.NumVisible = false
	self.HideItemLevel = true
	self.IconChooseVisible = false
	self.ItemLevelVisible = false
end

function StoreNewBlindBoxDescItemVM:UpdateVM(Value)
	self.ID = Value.ID
    self.ResID = Value.ID
	self.bIsOwned = Value.bIsOwned
	if _G.StoreMysteryBoxVM.CurBoxType == MysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_HAIRSTYLE  then
		local HairUnlockCfg = HairUnlockCfg:FindCfgByItemID(Value.ID)
		if HairUnlockCfg ~= nil then
			self.Icon = _G.StoreMysteryBoxMgr:GetHairIconByHairID(HairUnlockCfg.HairID)
		end
	else
		self.Icon = _G.StoreMysteryBoxMgr:GetItemCfgIconByResID(self.ResID)
	end

	--- 显示概率/已拥有
	self.TextProbability = Value.bIsOwned and RichTextUtil.GetText(LSTR(950022), "#89bd88") or string.format("%.1f%s", (Value.DropWeight / Value.AllDropWeight) * 100, "%")
end

function StoreNewBlindBoxDescItemVM:IsEqualVM(Value)
	return true
end

return StoreNewBlindBoxDescItemVM