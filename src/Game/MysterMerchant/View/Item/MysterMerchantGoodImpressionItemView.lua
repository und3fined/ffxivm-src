---
--- Author: Administrator
--- DateTime: 2024-05-20 15:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MysterMerchantVM = require("Game/MysterMerchant/VM/MysterMerchantVM")

---@class MysterMerchantGoodImpressionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconHeartRed UFImage
---@field IconHeartYellow UFImage
---@field ImgProgressFull URadialImage
---@field ImgTexture UFImage
---@field PanelProgressLight UFCanvasPanel
---@field TextLv UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLevelMax UWidgetAnimation
---@field AnimLevelNormal UWidgetAnimation
---@field AnimLevelUp UWidgetAnimation
---@field AnimLevelUpToMax UWidgetAnimation
---@field AnimProgressUp UWidgetAnimation
---@field ValueProgressStart float
---@field ValueProgressEnd float
---@field CurveProgressUp CurveFloat
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MysterMerchantGoodImpressionItemView = LuaClass(UIView, true)

function MysterMerchantGoodImpressionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconHeartRed = nil
	--self.IconHeartYellow = nil
	--self.ImgProgressFull = nil
	--self.ImgTexture = nil
	--self.PanelProgressLight = nil
	--self.TextLv = nil
	--self.AnimIn = nil
	--self.AnimLevelMax = nil
	--self.AnimLevelNormal = nil
	--self.AnimLevelUp = nil
	--self.AnimLevelUpToMax = nil
	--self.AnimProgressUp = nil
	--self.ValueProgressStart = nil
	--self.ValueProgressEnd = nil
	--self.CurveProgressUp = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MysterMerchantGoodImpressionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MysterMerchantGoodImpressionItemView:OnInit()

end

function MysterMerchantGoodImpressionItemView:OnDestroy()

end

function MysterMerchantGoodImpressionItemView:OnShow()

end

function MysterMerchantGoodImpressionItemView:OnHide()

end

function MysterMerchantGoodImpressionItemView:OnRegisterUIEvent()

end

function MysterMerchantGoodImpressionItemView:OnRegisterGameEvent()

end

function MysterMerchantGoodImpressionItemView:OnRegisterBinder()

end

---@type 更新等级
function MysterMerchantGoodImpressionItemView:UpdateLevel(NewLevel)
	self.TextLv:SetText(NewLevel)
	local IsMaxLevel = MysterMerchantVM:IsMaxLevel(NewLevel)
	if IsMaxLevel then
		self:PlayAnimation(self.AnimLevelUpToMax)
	end
end

---@type 播放经验增长动效
function MysterMerchantGoodImpressionItemView:PlayProgressUpAnim(StartPercent, EndPercent)
	self:PlayAnimProgressUp(StartPercent, EndPercent)
	return self.AnimProgressUp:GetEndTime()
end

---@type 播放升级动效
function MysterMerchantGoodImpressionItemView:PlayLevelUpAnim(StartPercent, EndPercent)
	self:PlayAnimation(self.AnimLevelUp)
	return self.AnimLevelUp:GetEndTime()
end

return MysterMerchantGoodImpressionItemView