---
--- Author: Administrator
--- DateTime: 2023-12-29 20:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LSTR = _G.LSTR

---@class GoldSauserMainPanelWonderSquareItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnWonderSquare UFButton
---@field ImgWonderSquareNormal UFImage
---@field ImgWonderSquareTobeViewed UFImage
---@field PanelFocus UFCanvasPanel
---@field PanelNormal UFCanvasPanel
---@field PanelTobeViewed UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextName UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelWonderSquareItemView = LuaClass(UIView, true)

function GoldSauserMainPanelWonderSquareItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnWonderSquare = nil
	--self.ImgWonderSquareNormal = nil
	--self.ImgWonderSquareTobeViewed = nil
	--self.PanelFocus = nil
	--self.PanelNormal = nil
	--self.PanelTobeViewed = nil
	--self.RedDot = nil
	--self.TextName = nil
	--self.AnimClick = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelWonderSquareItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelWonderSquareItemView:InitConstStringInfo()
	self.TextName:SetText(LSTR(350053))
end

function GoldSauserMainPanelWonderSquareItemView:OnInit()
	self:InitConstStringInfo()
end

function GoldSauserMainPanelWonderSquareItemView:OnDestroy()

end

function GoldSauserMainPanelWonderSquareItemView:OnShow()

end

function GoldSauserMainPanelWonderSquareItemView:OnHide()

end

function GoldSauserMainPanelWonderSquareItemView:OnRegisterUIEvent()

end

function GoldSauserMainPanelWonderSquareItemView:OnRegisterGameEvent()

end

function GoldSauserMainPanelWonderSquareItemView:OnRegisterBinder()

end

return GoldSauserMainPanelWonderSquareItemView