---
--- Author: rock
--- DateTime: 2025-09-03 14:55
--- Description: 翅膀改良-系列数据(左边系列)
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
---@class FashionDecoAmeliorateTabItemVM : UIViewModel
local FashionDecoAmeliorateTabItemVM = LuaClass(UIViewModel)
local LSTR = _G.LSTR
local MsgTipsUtil = _G.MsgTipsUtil

function FashionDecoAmeliorateTabItemVM:Ctor()
	self.SeriesType = nil
	self.ImgItemIcon = false --图标
	self.IsSelect = false
	self.IsUnlocked = false --是否已解锁
	self.IsShowRedDot = false --是否显示红点(感叹号样式)
end

function FashionDecoAmeliorateTabItemVM:IsEqualVM(Value)
	return nil ~= Value
end

function FashionDecoAmeliorateTabItemVM:UpdateVM(Value)
    if Value == nil then
        FLOG_WARNING("FashionDecoAmeliorateTabItemVM:InitVM, Value is nil")
        return
	end
	self.SeriesType = Value.SeriesType
	self.ImgItemIcon = Value.ImgItemIcon
	self.IsSelect = Value.IsSelect
	self.IsUnlocked = Value.IsUnlocked
	self.IsShowRedDot = Value.IsShowRedDot
end

function FashionDecoAmeliorateTabItemVM:OnSelectedChange(IsSelect)
    self.IsSelect = IsSelect
end

function FashionDecoAmeliorateTabItemVM:OnShowRedDotChange(IsShowRedDot)
    self.IsShowRedDot = IsShowRedDot
end

return FashionDecoAmeliorateTabItemVM