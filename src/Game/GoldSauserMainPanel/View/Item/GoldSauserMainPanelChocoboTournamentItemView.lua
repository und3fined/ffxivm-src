---
--- Author: Administrator
--- DateTime: 2023-12-29 20:13
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local GoldSauserMainPanelBaseItemView = require("Game/GoldSauserMainPanel/View/Item/GoldSauserMainPanelBaseItemView")
local LSTR = _G.LSTR

---@class GoldSauserMainPanelChocoboTournamentItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChocoboTournament UFButton
---@field IconTobeViewed UFImage
---@field ImgChocoboTournamentNormal UFImage
---@field ImgChocoboTournamentTobeViewed UFImage
---@field PanelFlash UFCanvasPanel
---@field PanelFocus UFCanvasPanel
---@field PanelLock UFCanvasPanel
---@field PanelTobeViewed UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextName UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelChocoboTournamentItemView = LuaClass(GoldSauserMainPanelBaseItemView, true)

function GoldSauserMainPanelChocoboTournamentItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChocoboTournament = nil
	--self.IconTobeViewed = nil
	--self.ImgChocoboTournamentNormal = nil
	--self.ImgChocoboTournamentTobeViewed = nil
	--self.PanelFlash = nil
	--self.PanelFocus = nil
	--self.PanelLock = nil
	--self.PanelTobeViewed = nil
	--self.RedDot = nil
	--self.TextName = nil
	--self.AnimClick = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelChocoboTournamentItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelChocoboTournamentItemView:InitConstStringInfo()
	self.TextName:SetText(LSTR(350055))
end

function GoldSauserMainPanelChocoboTournamentItemView:OnInit()
	self:InitConstStringInfo()
end

function GoldSauserMainPanelChocoboTournamentItemView:OnDestroy()

end

function GoldSauserMainPanelChocoboTournamentItemView:OnShow()
	self.Super:OnShow()
end

function GoldSauserMainPanelChocoboTournamentItemView:OnHide()

end

function GoldSauserMainPanelChocoboTournamentItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnChocoboTournament, self.OnBtnClicked)
end

function GoldSauserMainPanelChocoboTournamentItemView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
end

return GoldSauserMainPanelChocoboTournamentItemView