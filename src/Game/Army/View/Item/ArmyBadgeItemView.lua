---
--- Author: daniel
--- DateTime: 2023-05-20 09:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GroupEmblemTotemCfg = require("TableCfg/GroupEmblemTotemCfg")
local GroupEmblemBackgroundCfg = require("TableCfg/GroupEmblemBackgroundCfg")
local GroupEmblemIconCfg = require("TableCfg/GroupEmblemIconCfg")

---@class ArmyBadgeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgPattern UFImage
---@field ImgShowBg UFImage
---@field ImgShowEmpty UFImage
---@field ImgSymbol UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyBadgeItemView = LuaClass(UIView, true)

function ArmyBadgeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgPattern = nil
	--self.ImgShowBg = nil
	--self.ImgShowEmpty = nil
	--self.ImgSymbol = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyBadgeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyBadgeItemView:OnInit()
	if self.ImgBadgeBg then
		UIUtil.SetIsVisible(self.ImgBadgeBg, false)
	end
end
function ArmyBadgeItemView:OnDestroy()

end

function ArmyBadgeItemView:OnShow()

end

function ArmyBadgeItemView:SetIsEmpty(IsEmpty)
	UIUtil.SetIsVisible(self.ImgShowEmpty, IsEmpty)
	UIUtil.SetIsVisible(self.ImgSymbol, not IsEmpty)
	UIUtil.SetIsVisible(self.ImgPattern, not IsEmpty)
end

function ArmyBadgeItemView:HideEmpty()
	local IsEmpty = UIUtil.IsVisible(self.ImgShowEmpty)
	if IsEmpty then
		UIUtil.SetIsVisible(self.ImgShowEmpty, false)
	end
end

--- 初始化队徽
---@param TotemID number @图腾ID
---@param IconID number @图标ID
---@param BackgroundID number @背景ID
function ArmyBadgeItemView:SetBadgeData(BadgeData)
	if BadgeData == nil or (BadgeData.TotemID == 0 and BadgeData.IconID == 0 and BadgeData.BackgroundID == 0) then
		UIUtil.ImageSetBrushTintColorHex(self.ImgPattern, "#FFFFFFFF")
		self:SetIsEmpty(true)
	else
		self:SetIsEmpty(false)
		self:SetSymbol(BadgeData.TotemID)
		self:SetShield(BadgeData.IconID)
		self:SetBackground(BadgeData.BackgroundID)
	end
end

--- 设置寓意物
function ArmyBadgeItemView:SetSymbol(TotemID)
	self:HideEmpty()
	if not UIUtil.IsVisible(self.ImgSymbol) then
		UIUtil.SetIsVisible(self.ImgSymbol, true)
	end
	local IconPath = GroupEmblemTotemCfg:GetEmblemTotemIconByID(TotemID)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgSymbol, IconPath)
end

--- 设置盾纹
function ArmyBadgeItemView:SetShield(IconID)
	self:HideEmpty()
	if not UIUtil.IsVisible(self.ImgPattern) then
		UIUtil.SetIsVisible(self.ImgPattern, true)
	end
	local IconPath = GroupEmblemIconCfg:GetEmblemIconByID(IconID)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgPattern, IconPath)
end

--- 设置盾纹颜色
function ArmyBadgeItemView:SetBackground(BackgroundID)
	local ColorHex = GroupEmblemBackgroundCfg:GetEmblemBgColorByID(BackgroundID)
	UIUtil.ImageSetBrushTintColorHex(self.ImgPattern, ColorHex) 
end


function ArmyBadgeItemView:OnHide()

end

function ArmyBadgeItemView:OnRegisterUIEvent()

end

function ArmyBadgeItemView:OnRegisterGameEvent()

end

function ArmyBadgeItemView:OnRegisterBinder()

end

return ArmyBadgeItemView