--[[
Date: 2024-03-14 15:42:13
LastEditors: moody
LastEditTime: 2024-03-14 15:42:13
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BindableVector2D = require("UI/BindableObject/BindableVector2D")

---@class PerformanceAssistNewItemVM : UIViewModel
local PerformanceAssistNewItemVM = LuaClass(UIViewModel)

---Ctor
function PerformanceAssistNewItemVM:Ctor()
	self.ImgAllBlackVisible = false --全音阶短按黑键
	self.ImgAllBlackLongVisible = false --全音阶长按黑键
	self.ImgAllBlackLong2Visible = false --全音阶长按黑键(掉落中音符底部的菱形小方块)

	self.ImgAllWhiteVisible = false --全音阶短按白键
	self.ImgAllWhiteLongVisible = false --全音阶长按白键
	self.ImgAllWhiteLong2Visible = false --全音阶长按白键(掉落中音符底部的菱形小方块)

	self.ImgUPLongBarBVisible = false --单音阶长按黑键
	self.ImgUPLongBarB2Visible = false --单音阶长按黑键(掉落中音符底部的菱形小方块)
	self.ImgUPLongBarWVisible = false --单音阶长按白键
	self.ImgUPLongBarW2Visible = false --单音阶长按白键(掉落中音符底部的菱形小方块)

	self.ImgUpPointBVisible = false --单音阶短按白键
	self.ImgUpPointWVisible = false --单音阶短按黑键

	self.ImgAllBlackImgPath = ""
	self.ImgAllBlackLongImgPath = ""
	self.ImgAllBlackLong2ImgPath = ""
	self.ImgAllWhiteImgPath = ""
	self.ImgAllWhiteLongImgPath = ""
	self.ImgAllWhiteLong2ImgPath = ""
	self.ImgUPLongBarBImgPath = ""
	self.ImgUPLongBarB2ImgPath = ""
	self.ImgUPLongBarWImgPath = ""
	self.ImgUPLongBarW2ImgPath = ""
	self.ImgUpPointBImgPath = ""
	self.ImgUpPointWImgPath = ""

	self.Size = BindableVector2D.New()
	self.Position = BindableVector2D.New()
	self.Position2 = BindableVector2D.New()	-- 拖尾的位置
	self.EffectPosition = BindableVector2D.New()	-- 特效的位置

	self.CostTime = 0	-- 决定位置
	self.Duration = 0	-- 决定长度
	self.IsAllKey = false	-- 全音阶
	self.IsBlackKey = false
	self.IsLongClick = false
	self.KeyOffset = 0
	self.UIState = 0
end

function PerformanceAssistNewItemVM:OnInit()
end

function PerformanceAssistNewItemVM:OnBegin()
end

function PerformanceAssistNewItemVM:OnEnd()
end

function PerformanceAssistNewItemVM:OnShutdown()
end

return PerformanceAssistNewItemVM