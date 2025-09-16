---
--- Author: Administrator
--- DateTime: 2023-12-29 20:14
--- Description:
---

local GoldSauserMainPanelBaseItemView = require("Game/GoldSauserMainPanel/View/Item/GoldSauserMainPanelBaseItemView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LSTR = _G.LSTR

---@class GoldSauserMainPanelNextTripleTriadTournamentItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnNextTripleTriadTournament UFButton
---@field IconTobeViewed UFImage
---@field ImgNextTripleTriadTournamentNormal UFImage
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
local GoldSauserMainPanelNextTripleTriadTournamentItemView = LuaClass(GoldSauserMainPanelBaseItemView, true)

function GoldSauserMainPanelNextTripleTriadTournamentItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnNextTripleTriadTournament = nil
	--self.IconTobeViewed = nil
	--self.ImgNextTripleTriadTournamentNormal = nil
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

function GoldSauserMainPanelNextTripleTriadTournamentItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelNextTripleTriadTournamentItemView:InitConstStringInfo()
	self.TextName:SetText(LSTR(350061))
end

function GoldSauserMainPanelNextTripleTriadTournamentItemView:OnInit()
	self:InitConstStringInfo()
end

function GoldSauserMainPanelNextTripleTriadTournamentItemView:OnDestroy()

end

function GoldSauserMainPanelNextTripleTriadTournamentItemView:OnShow()
	self.Super:OnShow()
end

function GoldSauserMainPanelNextTripleTriadTournamentItemView:OnHide()

end

function GoldSauserMainPanelNextTripleTriadTournamentItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnNextTripleTriadTournament, self.OnBtnClicked)
end

function GoldSauserMainPanelNextTripleTriadTournamentItemView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
end

return GoldSauserMainPanelNextTripleTriadTournamentItemView