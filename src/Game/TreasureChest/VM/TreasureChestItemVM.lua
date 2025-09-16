
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemDefine = require("Game/Item/ItemDefine")

---@class TreasureChestItemVM : UIViewModel
local TreasureChestItemVM = LuaClass(UIViewModel)

local EnableStateIconPath = "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Tag_MulitChoice_XS_png.UI_Tag_MulitChoice_XS_png'"
local UnEnableStateIconPath = "PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Tag_MulitChoice_XS_Normal_png.UI_Tag_MulitChoice_XS_Normal_png'"

---Ctor
function TreasureChestItemVM:Ctor()
	self.IsSelected = false		--- 选中态
	self.ResID = 0				--- 物品ID
	self.SelectedNum = 0		--- 当前Item所选择的数量
	self.ItemName = nil			--- 包含物品的名称
	self.LimitTipsStr = LSTR(1230008)	--- "已达选择上限"

	--- 右上角对勾图标路径
	self.Selected2Icon = UnEnableStateIconPath
	--- Item
	self.Num = 0				--- 包含子Item的数量
	self.Icon = nil				--- ItemIcon
	self.ItemLevelVisible = false
	self.IconChooseVisible = false
	self.ItemQualityIcon = nil	--- 物品底色
end

function TreasureChestItemVM:OnInit()
	self.IsSelected = false
	self.Selected2Icon = UnEnableStateIconPath
	self.SelectedNum = 0
end

function TreasureChestItemVM:UpdateVM(Value)
	self.ResID = Value.ItemID
	self.Num = Value.ItemNum

	local Cfg = ItemCfg:FindCfgByKey(self.ResID)
	if Cfg == nil then
		return
	end
	if Cfg.IsHQ == 1 then
		self.ItemQualityIcon = ItemDefine.HQItemIconColorType[Cfg.ItemColor]
	else
		self.ItemQualityIcon = ItemDefine.ItemIconColorType[Cfg.ItemColor]
	end

	self.Icon = ItemCfg.GetIconPath(Cfg.IconID)
	self.ItemName = Cfg.ItemName
end

function TreasureChestItemVM:OnShutdown()
	
end

function TreasureChestItemVM:SetNum(Num)
	if Num <= 0 or Num == nil then
		Num = 0
	end
	if (Num == 0 and self.IsSelected) then
		self.IsSelected = false
		self.Selected2Icon = UnEnableStateIconPath
	end
	self.SelectedNum = Num
end

function TreasureChestItemVM:GetNum()
	return self.SelectedNum
end

function TreasureChestItemVM:OnSetIsSelected(IsSelected)
	if IsSelected == nil then
		IsSelected = false
	end
	if IsSelected then
		self:SetNum(1)
	else
		self:SetNum(0)
	end
	self.Selected2Icon = IsSelected and EnableStateIconPath or UnEnableStateIconPath
	self.IsSelected = IsSelected
end

return TreasureChestItemVM