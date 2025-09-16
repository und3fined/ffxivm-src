---
--- Author: Administrator
--- DateTime: 2023-12-29 17:12
--- Description:
---

--local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")

---@class AetherCurrentTips02PanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextContent URichTextBox
---@field Root UCanvasPanel
---@field AniFly UWidgetAnimation
---@field AniOffset UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AetherCurrentTips02PanelView = LuaClass(InfoTipsBaseView, true)

function AetherCurrentTips02PanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextContent = nil
	--self.Root = nil
	--self.AniFly = nil
	--self.AniOffset = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AetherCurrentTips02PanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AetherCurrentTips02PanelView:OnInit()

end

function AetherCurrentTips02PanelView:OnDestroy()

end

function AetherCurrentTips02PanelView:OnShow()
	self.Super:OnShow()
	self.RichTextContent:SetText(self.Params.Content)
end

function AetherCurrentTips02PanelView:OnHide()

end

function AetherCurrentTips02PanelView:OnRegisterUIEvent()

end

function AetherCurrentTips02PanelView:OnRegisterGameEvent()

end

function AetherCurrentTips02PanelView:OnRegisterBinder()
	self.Super:OnRegisterTimer()
end

return AetherCurrentTips02PanelView