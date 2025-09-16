---
--- Author: peterxie
--- DateTime:
--- Description: 水晶冲突提示
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")


---@class PVPColosseumTipsView : InfoTipsBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgS1 UFImage
---@field ImgV1 UFImage
---@field PanelVS1 UFCanvasPanel
---@field RichTextContent URichTextBox
---@field Root UCanvasPanel
---@field AniFly UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AniOffset UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumTipsView = LuaClass(InfoTipsBaseView, true)

function PVPColosseumTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgS1 = nil
	--self.ImgV1 = nil
	--self.PanelVS1 = nil
	--self.RichTextContent = nil
	--self.Root = nil
	--self.AniFly = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AniOffset = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumTipsView:OnInit()

end

function PVPColosseumTipsView:OnDestroy()

end

function PVPColosseumTipsView:OnShow()
	self.Super:OnShow()

	local Params = self.Params
	if Params then
		self.RichTextContent:SetText(Params.Content)
	end
end

function PVPColosseumTipsView:OnHide()

end

function PVPColosseumTipsView:OnRegisterUIEvent()

end

function PVPColosseumTipsView:OnRegisterGameEvent()

end

function PVPColosseumTipsView:OnRegisterBinder()

end

function PVPColosseumTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

return PVPColosseumTipsView