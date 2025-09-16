---
--- Author: rock
--- DateTime: 2023-12-18
--- Description:
---

local LuaClass = require("Core/LuaClass")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local ItemCfg = require("TableCfg/ItemCfg")

local FLinearColor = _G.UE.FLinearColor

---@class FateItemSubmitInfoVM : UIViewModel
local FateItemSubmitInfoVM = LuaClass(BagSlotVM)

function FateItemSubmitInfoVM:Ctor()
	---注：要修改的[CommBackpackSlotView类]中的bind的属性，也需要在此初始化，否则显示后修改时 属性=nil
	self.bShowUnselect = false		--FateItemSubmitInfoView里BtnUnselect里面的选中效果
	self.IsSelect = false 			--FateItemSubmitInfoView里ItemSlot组件(CommBackpackSlotView类)里面的选中效果
	self.ItemColorAndOpacity = FLinearColor(1, 1, 1, 1)
end

function FateItemSubmitInfoVM:UpdateVM(Data)
	if (Data == nil) then
		_G.FLOG_ERROR("FateItemSubmitInfoVM:UpdateVM(Data) 出错，传入的 Data 为空，请检查")
		self.Num = 1
		self.ResID = 0
		self.GID = 0
		self.Icon = ""
		self.bOnlyShowHaveNum = true
		self.Name = ""
	else
		self.Num = Data.Num
		self.ResID = Data.ResID
		self.GID = Data.GID
		local ItemCfg = ItemCfg:FindCfgByKey(Data.ResID)
		if (ItemCfg == nil) then
			_G.FLOG_ERROR("ItemCfg:FindCfgByKey 出错，无法获取数据 , ID : %s", Data.ResID)
		else
			self.Icon = UIUtil.GetIconPath(ItemCfg.IconID)
			self.Name = ItemCfg.ItemName
		end
		self.bOnlyShowHaveNum = true
	end
end

function FateItemSubmitInfoVM:SetItemOpacity(Opacity)
	self.ItemColorAndOpacity = FLinearColor(1, 1, 1, Opacity)
end

return FateItemSubmitInfoVM