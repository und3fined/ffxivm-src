---
--- Author: Administrator
--- DateTime: 2023-12-29 20:13
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSauserMainPanelBaseItemView = require("Game/GoldSauserMainPanel/View/Item/GoldSauserMainPanelBaseItemView")
local LSTR = _G.LSTR

---@class GoldSauserMainPanelJumboCactpotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnJumboCactpot UFButton
---@field IconTobeViewed UFImage
---@field ImgJumboCactpotNormal UFImage
---@field ImgJumboCactpotTobeViewed UFImage
---@field PanelFocus UFCanvasPanel
---@field PanelTobeViewed UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextName UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelJumboCactpotItemView = LuaClass(GoldSauserMainPanelBaseItemView, true)

function GoldSauserMainPanelJumboCactpotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnJumboCactpot = nil
	--self.IconTobeViewed = nil
	--self.ImgJumboCactpotNormal = nil
	--self.ImgJumboCactpotTobeViewed = nil
	--self.PanelFocus = nil
	--self.PanelTobeViewed = nil
	--self.RedDot = nil
	--self.TextName = nil
	--self.AnimClick = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelJumboCactpotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelJumboCactpotItemView:InitConstStringInfo()
	self.TextName:SetText(LSTR(350058))
end

function GoldSauserMainPanelJumboCactpotItemView:OnInit()
	self:InitConstStringInfo()
end

function GoldSauserMainPanelJumboCactpotItemView:OnDestroy()

end

function GoldSauserMainPanelJumboCactpotItemView:OnShow()

end

function GoldSauserMainPanelJumboCactpotItemView:OnHide()

end

function GoldSauserMainPanelJumboCactpotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnJumboCactpot, self.OnBtnClicked)
end

function GoldSauserMainPanelJumboCactpotItemView:OnRegisterGameEvent()

end

return GoldSauserMainPanelJumboCactpotItemView