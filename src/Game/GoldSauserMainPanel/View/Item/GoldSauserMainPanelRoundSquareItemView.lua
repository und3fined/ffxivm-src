---
--- Author: Administrator
--- DateTime: 2023-12-29 20:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LSTR = _G.LSTR

---@class GoldSauserMainPanelRoundSquareItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRoundSquare UFButton
---@field ImgRoundSquareNormal UFImage
---@field ImgRoundSquareTobeViewed UFImage
---@field PanelFocus UFCanvasPanel
---@field PanelTobeViewed UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextName UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelRoundSquareItemView = LuaClass(UIView, true)

function GoldSauserMainPanelRoundSquareItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRoundSquare = nil
	--self.ImgRoundSquareNormal = nil
	--self.ImgRoundSquareTobeViewed = nil
	--self.PanelFocus = nil
	--self.PanelTobeViewed = nil
	--self.RedDot = nil
	--self.TextName = nil
	--self.AnimClick = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelRoundSquareItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelRoundSquareItemView:InitConstStringInfo()
	self.TextName:SetText(LSTR(350059))
end

function GoldSauserMainPanelRoundSquareItemView:OnInit()
	self:InitConstStringInfo()
end

function GoldSauserMainPanelRoundSquareItemView:OnDestroy()

end


function GoldSauserMainPanelRoundSquareItemView:OnShow()

end

function GoldSauserMainPanelRoundSquareItemView:OnHide()

end

function GoldSauserMainPanelRoundSquareItemView:OnRegisterUIEvent()

end


function GoldSauserMainPanelRoundSquareItemView:OnRegisterGameEvent()

end

function GoldSauserMainPanelRoundSquareItemView:OnRegisterBinder()

end

return GoldSauserMainPanelRoundSquareItemView