---
--- Author: Administrator
--- DateTime: 2023-12-29 20:13
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSauserMainPanelBaseItemView = require("Game/GoldSauserMainPanel/View/Item/GoldSauserMainPanelBaseItemView")
local LSTR = _G.LSTR

---@class GoldSauserMainPanelFashionReportItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFashionReport UFButton
---@field IconTobeViewed UFImage
---@field ImgFashionReportNormal UFImage
---@field ImgFashionReportTobeViewed UFImage
---@field PanelFocus UFCanvasPanel
---@field PanelTobeViewed UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextName UFTextBlock
---@field AnimClick UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelFashionReportItemView = LuaClass(GoldSauserMainPanelBaseItemView, true)

function GoldSauserMainPanelFashionReportItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFashionReport = nil
	--self.IconTobeViewed = nil
	--self.ImgFashionReportNormal = nil
	--self.ImgFashionReportTobeViewed = nil
	--self.PanelFocus = nil
	--self.PanelTobeViewed = nil
	--self.RedDot = nil
	--self.TextName = nil
	--self.AnimClick = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelFashionReportItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelFashionReportItemView:InitConstStringInfo()
	self.TextName:SetText(LSTR(350017))
end

function GoldSauserMainPanelFashionReportItemView:OnInit()
	self:InitConstStringInfo()
end

function GoldSauserMainPanelFashionReportItemView:OnDestroy()

end

function GoldSauserMainPanelFashionReportItemView:OnShow()

end

function GoldSauserMainPanelFashionReportItemView:OnHide()

end

function GoldSauserMainPanelFashionReportItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnFashionReport, self.OnBtnClicked)
end

function GoldSauserMainPanelFashionReportItemView:OnRegisterGameEvent()

end

return GoldSauserMainPanelFashionReportItemView