---
--- Author: Administrator
--- DateTime: 2023-12-29 20:13
--- Description:
---

local GoldSauserMainPanelBaseItemView = require("Game/GoldSauserMainPanel/View/Item/GoldSauserMainPanelBaseItemView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LSTR = _G.LSTR

---@class GoldSauserMainPanelMiniCactpotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnMiniCactpot UFButton
---@field IconTobeViewed UFImage
---@field ImgMiniCactpotNormal UFImage
---@field ImgMiniCactpotTobeViewed UFImage
---@field PanelFocus UFCanvasPanel
---@field PanelTobeViewed UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextName UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelMiniCactpotItemView = LuaClass(GoldSauserMainPanelBaseItemView, true)

function GoldSauserMainPanelMiniCactpotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnMiniCactpot = nil
	--self.IconTobeViewed = nil
	--self.ImgMiniCactpotNormal = nil
	--self.ImgMiniCactpotTobeViewed = nil
	--self.PanelFocus = nil
	--self.PanelTobeViewed = nil
	--self.RedDot = nil
	--self.TextName = nil
	--self.AnimClick = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelMiniCactpotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelMiniCactpotItemView:InitConstStringInfo()
	self.TextName:SetText(LSTR(350060))
end

function GoldSauserMainPanelMiniCactpotItemView:OnInit()
	self:InitConstStringInfo()
end

function GoldSauserMainPanelMiniCactpotItemView:OnDestroy()

end

function GoldSauserMainPanelMiniCactpotItemView:OnShow()

end

function GoldSauserMainPanelMiniCactpotItemView:OnHide()

end

function GoldSauserMainPanelMiniCactpotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMiniCactpot, self.OnBtnClicked)
end

function GoldSauserMainPanelMiniCactpotItemView:OnRegisterGameEvent()

end

return GoldSauserMainPanelMiniCactpotItemView