local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")

local FLinearColor = _G.UE.FLinearColor

---@class ChocoboCodexArmorSlotVM : UIViewModel
local ChocoboCodexArmorSlotVM = LuaClass(UIViewModel)

---Ctor
function ChocoboCodexArmorSlotVM:Ctor()
	self.Icon = ""
	self.IsMask = false
    self.IsIcon = false
    self.IsNoOpen = false
	self.ItemID = 0
	self.ChocoboArmorPos = 0
	self.NumVisible = false
	self.ItemLevelVisible = false
	--self.ItemColorAndOpacity = FLinearColor(1, 1, 1, 1)
	self.RedDotName = ""
end

function ChocoboCodexArmorSlotVM:OnInit()
end

function ChocoboCodexArmorSlotVM:OnBegin()
end

function ChocoboCodexArmorSlotVM:Clear()
end

function ChocoboCodexArmorSlotVM:IsEqualVM(Value)
	return nil ~= Value and Value.ItemID == self.ItemID
end

function ChocoboCodexArmorSlotVM:UpdateVM(Value)
	if Value == nil then return end 

	if Value.ItemID ~= nil and Value.IconID ~= 0 then 
		if Value.IsSpoiler == 1 then 
            self.IsIcon = false
            self.IsNoOpen = true
		else
            self.IsIcon = true
            self.IsNoOpen = false
			self.Icon = UIUtil.GetIconPath(Value.IconID)
		end	
		--[[if Value.IsMask then 
			self.ItemColorAndOpacity = FLinearColor(1, 1, 1, 1)
		else
			self.ItemColorAndOpacity = FLinearColor(1, 1, 1, 0.6)
		end]]
		self.IsMask = not Value.IsMask
		self.ItemID = Value.ItemID
		self.ChocoboArmorPos = Value.ChocoboArmorPos
		self.RedDotName = string.format("Root/ChocoboArmorNew/%s", tostring(self.ItemID))
	end
end

return ChocoboCodexArmorSlotVM