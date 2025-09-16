---
--- Author: Administrator
--- DateTime: 2023-12-29 20:13
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local GoldSauserMainPanelBaseItemView = require("Game/GoldSauserMainPanel/View/Item/GoldSauserMainPanelBaseItemView")
local LSTR = _G.LSTR

---@class GoldSauserMainPanelChocoboRacesItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChocoboRaces UFButton
---@field ImgChocoboRacesNormal UFImage
---@field ImgChocoboRacesTobeViewed UFImage
---@field PanelFocus UFCanvasPanel
---@field PanelLock UFCanvasPanel
---@field PanelTobeViewed UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextName UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop_Backup UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelChocoboRacesItemView = LuaClass(GoldSauserMainPanelBaseItemView, true)

function GoldSauserMainPanelChocoboRacesItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChocoboRaces = nil
	--self.ImgChocoboRacesNormal = nil
	--self.ImgChocoboRacesTobeViewed = nil
	--self.PanelFocus = nil
	--self.PanelLock = nil
	--self.PanelTobeViewed = nil
	--self.RedDot = nil
	--self.TextName = nil
	--self.AnimClick = nil
	--self.AnimIn = nil
	--self.AnimLoop_Backup = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelChocoboRacesItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelChocoboRacesItemView:InitConstStringInfo()
	self.TextName:SetText(LSTR(350054))
end

function GoldSauserMainPanelChocoboRacesItemView:OnInit()
	self:InitConstStringInfo()
end

function GoldSauserMainPanelChocoboRacesItemView:OnDestroy()

end

function GoldSauserMainPanelChocoboRacesItemView:OnShow()
   	self.Super:OnShow()
end

function GoldSauserMainPanelChocoboRacesItemView:OnHide()

end

function GoldSauserMainPanelChocoboRacesItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnChocoboRaces, self.OnBtnClicked)
end

function GoldSauserMainPanelChocoboRacesItemView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
end

return GoldSauserMainPanelChocoboRacesItemView