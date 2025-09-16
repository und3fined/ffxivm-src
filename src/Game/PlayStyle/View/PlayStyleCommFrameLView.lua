---
--- Author: Administrator
--- DateTime: 2023-09-18 14:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PlayStyleCommFrameLView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonClose UFButton
---@field CanvasPanel UFCanvasPanel
---@field CommCurrency01_1 CommMoneySlotView
---@field CommCurrency02_1 CommMoneySlotView
---@field FText_Title UFTextBlock
---@field NamedSlotChild UNamedSlot
---@field PanelCurrency UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PlayStyleCommFrameLView = LuaClass(UIView, true)

function PlayStyleCommFrameLView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonClose = nil
	--self.CanvasPanel = nil
	--self.CommCurrency01_1 = nil
	--self.CommCurrency02_1 = nil
	--self.FText_Title = nil
	--self.NamedSlotChild = nil
	--self.PanelCurrency = nil
	--self.PopUpBG = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PlayStyleCommFrameLView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommCurrency01_1)
	self:AddSubView(self.CommCurrency02_1)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PlayStyleCommFrameLView:OnInit()

end

function PlayStyleCommFrameLView:OnDestroy()

end

function PlayStyleCommFrameLView:OnShow()

end

function PlayStyleCommFrameLView:OnHide()

end

function PlayStyleCommFrameLView:OnRegisterUIEvent()

end

function PlayStyleCommFrameLView:OnRegisterGameEvent()

end

function PlayStyleCommFrameLView:OnRegisterBinder()

end

function PlayStyleCommFrameLView:MoneySlot1UpdateView(ScoreID, bLinkToView, UIViewID, IsScore)
	self.CommCurrency01_1:UpdateView(ScoreID, bLinkToView, UIViewID, IsScore)
end

function PlayStyleCommFrameLView:MoneySlot2UpdateView(ScoreID, bLinkToView, UIViewID, IsScore)
	self.CommCurrency02_1:UpdateView(ScoreID, bLinkToView, UIViewID, IsScore)
end

function PlayStyleCommFrameLView:SetTitle(TitleText)
	if not TitleText or type(TitleText) ~= "string" then
		return
	end
	self.FText_Title:SetText(TitleText)
end

return PlayStyleCommFrameLView