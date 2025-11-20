---
--- Author: rock
--- DateTime: 2025-09-03 14:55
--- Description: 翅膀改良-升级的本系列中的翅膀列表数据(右边4个翅膀)
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
---@class FashionDecoAmeliorateSlotVM : UIViewModel
local FashionDecoAmeliorateSlotVM = LuaClass(UIViewModel)
local LSTR = _G.LSTR
local MsgTipsUtil = _G.MsgTipsUtil

function FashionDecoAmeliorateSlotVM:Ctor()
	self.SeriesType = nil --所属的左边系列
	self.Id = nil
    self.LastName = "" --后缀名字
	self.ImgItemIcon = false --图标
	self.IsSelect = false
	self.IsUnlock = false --是否已解锁
	self.IsEquip = false --是否已装备(穿戴)

	self.AmeliorateWingData = nil --此ID涉及的改良数据
	self.IsClick = false --是否为点击
end

function FashionDecoAmeliorateSlotVM:IsEqualVM(Value)
	return nil ~= Value
end

function FashionDecoAmeliorateSlotVM:UpdateVM(Value)
    if Value == nil then
        FLOG_WARNING("FashionDecoAmeliorateSlotVM:InitVM, Value is nil")
        return
	end
	self.SeriesType = Value.SeriesType
    self.LastName = Value.LastName
	self.ImgItemIcon = Value.ImgItemIcon
	self.IsSelect = Value.IsSelect

	self.AmeliorateWingData = Value.AmeliorateWingData
	self.IsUnlock = self.AmeliorateWingData.IsUnlock
	self.IsEquip = self.AmeliorateWingData.IsEquip

	self.Id = Value.Id
end

function FashionDecoAmeliorateSlotVM:OnSelectedChange(IsSelect)
    self.IsSelect = IsSelect
end

function FashionDecoAmeliorateSlotVM:OnClickItem(IsClick)
    self.IsClick = IsClick
end

return FashionDecoAmeliorateSlotVM