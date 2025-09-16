---
--- Author: Administrator
--- DateTime: 2024-04-18 15:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")

---@class MainTeamChatTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelChatTips UFCanvasPanel
---@field TextChatTips UFTextBlock
---@field AnimGuideLoop UWidgetAnimation
---@field AnimRollBtnIn UWidgetAnimation
---@field AnimRollBtnLoop UWidgetAnimation
---@field AnimRollBtnNormal UWidgetAnimation
---@field AnimRollBtnOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainTeamChatTipsView = LuaClass(UIView, true)

function MainTeamChatTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelChatTips = nil
	--self.TextChatTips = nil
	--self.AnimGuideLoop = nil
	--self.AnimRollBtnIn = nil
	--self.AnimRollBtnLoop = nil
	--self.AnimRollBtnNormal = nil
	--self.AnimRollBtnOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainTeamChatTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainTeamChatTipsView:OnInit()

end

function MainTeamChatTipsView:OnDestroy()

end

function MainTeamChatTipsView:OnShow()
	if self.Params then
		local Anchor = self.Params.Anchor
		local Text = self.Params.Text
		local Offset = self.Params.Offset
		self.TextChatTips:SetText(Text)
		TipsUtil.AdjustTipsPosition(self, Anchor,  _G.UE.FVector2D(Offset.X, Offset.Y), _G.UE.FVector2D(0, 0))
	end
end

function MainTeamChatTipsView:OnHide()

end

function MainTeamChatTipsView:OnRegisterUIEvent()

end

function MainTeamChatTipsView:OnRegisterGameEvent()

end

function MainTeamChatTipsView:OnRegisterBinder()

end

return MainTeamChatTipsView