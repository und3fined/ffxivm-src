---
--- Author: ccppeng
--- DateTime: 2024-11-1 19:53
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FashionDecoSlotItemVM : UIViewModel
local FashionDecoSlotItemVM = LuaClass(UIViewModel)

---Ctor
function FashionDecoSlotItemVM:Ctor( )
	--收藏
	self.AppearanceIcon = nil
	self.Equip = nil
	self.IsSelect = nil
	self.Title = nil
	self.ItemLevelVisible = nil
    self.NumVisible = nil
	self.RedDot2Visible = nil
	self.IconCollectVisible = nil
	self.ShowImgEmpty = nil
end

function FashionDecoSlotItemVM:IsEqualVM(Value)
	return false
end

function FashionDecoSlotItemVM:UpdateVM(Value,param)

	self.AppearanceIcon = Value.Icon
	if Value.Icon == "" then
		self.ShowImgEmpty = true
	else
		self.ShowImgEmpty = false
	end
	self.Equip = Value.Equip
	self.IsSelect = Value.IsSelect
	self.Title = Value.Title
	self.ID = Value.ID
	self.ItemLevelVisible = Value.ItemLevelVisible
    self.NumVisible = Value.NumVisible
	self.RedDot2Visible = Value.RedDot2Visible
	self.IconCollectVisible = Value.IconCollectVisible

end
function FashionDecoSlotItemVM:OnSelectedChange(IsSelected)
	self.IsSelect = IsSelected
	--if self.IsSelect == true  then
		--self.RedDot2Visible = false
	--end

end
function FashionDecoSlotItemVM:SetNextClickItem(ItemData)
	self.IsSelect = false
end

function FashionDecoSlotItemVM:SetName(Name)
	self.Name = Name or ""
end

function FashionDecoSlotItemVM:GetRawName()
	return self.Name or ""
end

function FashionDecoSlotItemVM:AdapterOnGetIsVisible()

	return true
end
function FashionDecoSlotItemVM:AdapterOnGetCanBeSelected()
	return not self.ShowImgEmpty
end
return FashionDecoSlotItemVM