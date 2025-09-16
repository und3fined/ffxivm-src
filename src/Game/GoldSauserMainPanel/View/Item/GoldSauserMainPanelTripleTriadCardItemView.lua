---
--- Author: Administrator
--- DateTime: 2023-12-29 20:14
--- Description:
---

local GoldSauserMainPanelBaseItemView = require("Game/GoldSauserMainPanel/View/Item/GoldSauserMainPanelBaseItemView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LSTR = _G.LSTR

---@class GoldSauserMainPanelTripleTriadCardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTripleTriadCard UFButton
---@field ImgTripleTriadCardNormal UFImage
---@field ImgTripleTriadCardTobeViewed UFImage
---@field PanelFocus UFCanvasPanel
---@field PanelTobeViewed UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextName UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelTripleTriadCardItemView = LuaClass(GoldSauserMainPanelBaseItemView, true)

function GoldSauserMainPanelTripleTriadCardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTripleTriadCard = nil
	--self.ImgTripleTriadCardNormal = nil
	--self.ImgTripleTriadCardTobeViewed = nil
	--self.PanelFocus = nil
	--self.PanelTobeViewed = nil
	--self.RedDot = nil
	--self.TextName = nil
	--self.AnimClick = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelTripleTriadCardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelTripleTriadCardItemView:InitConstStringInfo()
	self.TextName:SetText(LSTR(350062))
end

function GoldSauserMainPanelTripleTriadCardItemView:OnInit()
	self:InitConstStringInfo()
end

function GoldSauserMainPanelTripleTriadCardItemView:OnDestroy()

end

function GoldSauserMainPanelTripleTriadCardItemView:OnShow()

end

function GoldSauserMainPanelTripleTriadCardItemView:OnHide()

end

function GoldSauserMainPanelTripleTriadCardItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTripleTriadCard, self.OnBtnClicked)
end

function GoldSauserMainPanelTripleTriadCardItemView:OnRegisterGameEvent()

end

return GoldSauserMainPanelTripleTriadCardItemView