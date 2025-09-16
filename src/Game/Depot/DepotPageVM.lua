---
--- Author: anypkvcai
--- DateTime: 2021-08-23 19:00
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local DepotConfig = require("Game/Depot/DepotConfig")
local EToggleButtonState = _G.UE.EToggleButtonState

---@class DepotPageVM : UIViewModel
local DepotPageVM = LuaClass(UIViewModel)

---Ctor
function DepotPageVM:Ctor()
	self.PageIndex = 0
	self.ItemNum = 0
	self.PageType = 0
	self.PageName = ""
	self.PageIcon = ""
	self.IconColor = "ffffffff"
	self.PageChecked = EToggleButtonState.Unchecked
end

---UpdateVM
---@param Value DepotSimple
function DepotPageVM:UpdateVM(Value)
	self.PageIndex = Value.Index
	self.ItemNum = Value.ItemNum

	self:UpdateInfo(Value.Type, Value.DepotName)
	self:UpdateIconColor()
end

function DepotPageVM:SetSelelctIndex(Index)
	if Index == self.PageIndex then
		self.PageChecked = EToggleButtonState.Checked
	else
		self.PageChecked = EToggleButtonState.Unchecked
	end
end

function DepotPageVM:IsEqualVM(Value)
	return nil ~= Value and Value.PageIndex == Value.Index
end


function DepotPageVM:UpdateInfo(Type, Name)
	self.PageType = Type
	self.PageName = Name
	self.PageIcon = DepotConfig.FindDepotIcon(Type + 1)
end

function DepotPageVM:GetItemCount()
	return self.ItemNum
end

function DepotPageVM:UpdateIconColor()
	self.IconColor = self:GetIconColor()
end

function DepotPageVM:GetIconColor()
	--绿色：66efa0
	--黄色：cdb271
	--红色：d05758

	local ItemNum = self.ItemNum
	if ItemNum <= 10 then
		return "66efa0ff"
	elseif ItemNum <= 20 then
		return "cdb271ff"
	else
		return "d05758"
	end
end



return DepotPageVM