---
--- Author: lydianwang
--- DateTime: 2023-05-16
--- Description:
---

local LuaClass = require("Core/LuaClass")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")

local FLinearColor = _G.UE.FLinearColor

---@class QuestSubmitItemVM : UIViewModel
local QuestSubmitItemVM = LuaClass(BagSlotVM)

function QuestSubmitItemVM:Ctor()
    self.bShowUnselect = false
end

function QuestSubmitItemVM:SetItemOpacity(Opacity)
	self.ItemColorAndOpacity = FLinearColor(1, 1, 1, Opacity)
end

function QuestSubmitItemVM:OnSelectedChange(IsSelected)
    self.IsSelect = IsSelected
end

return QuestSubmitItemVM