--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-10-10 17:07:14
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-10-10 17:12:19
FilePath: \Client\Source\Script\Game\CraftingLog\ItemVM\CraftingLogMaterialListItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BagMgr = require("Game/Bag/BagMgr")
local CraftingLogDefine = require("Game/CraftingLog/CraftingLogDefine")
local ItemUtil = require("Utils/ItemUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local UIUtil = require("Utils/UIUtil")

---@class CraftingLogMaterialListItemVM : UIViewModel
local CraftingLogMaterialListItemVM = LuaClass(UIViewModel)

---Ctor
function CraftingLogMaterialListItemVM:Ctor()
	self.IsValid = true
	self.ItemID = nil
	self.ItemData = nil
	self.Icon = nil
	self.ItemQualityIcon = nil
	self.Num = ""
	self.HideItemLevel = true
	self.IconChooseVisible = false
end

function CraftingLogMaterialListItemVM:OnInit()
end

function CraftingLogMaterialListItemVM:UpdateVM(Params)
	self.IsValid = Params.ItemID ~= 0
	self.ItemID = Params.ItemID
	self.ItemData = Params

	self.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(Params.ItemID))
    self.ItemQualityIcon = ItemUtil.GetSlotColorIcon(Params.ItemID, ItemDefine.ItemSlotType.Item96Slot)
end

function CraftingLogMaterialListItemVM:IsEqualVM(Value)
	return self.ItemID == Value.ItemID
end


function CraftingLogMaterialListItemVM:UpdataTextNum(MakeCount)
	if self.ItemID == 0 or self.ItemID == nil then
		return
	end
    if MakeCount == 0 then
        MakeCount = CraftingLogDefine.NormalLowestMakeCount
    end

	local ItemData = self.ItemData
	local SpendNumber = ItemData.ItemNum * MakeCount
	local HaveCount
	if ItemData.IsHQ then
		HaveCount = BagMgr:GetItemHQNum(ItemData.ItemID)
	else
		HaveCount = BagMgr:GetItemNumWithHQ(ItemData.ItemID)
	end
	local LabelInfo
	if SpendNumber > HaveCount then
		LabelInfo =string.format("<span color=\"#FF0000FF\">%s</>", HaveCount)
	else
		LabelInfo =string.format("<span color=\"#FFFFFFFF\">%s</>", HaveCount)
	end
	self.Num = string.format("%s/%d", LabelInfo, SpendNumber)
end

return CraftingLogMaterialListItemVM