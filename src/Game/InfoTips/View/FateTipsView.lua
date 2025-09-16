---
--- Author: chunfengluo
--- DateTime: 2023-05-19 14:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class FateTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPlaySound_UIBP CommonPlaySoundView
---@field HorizontalTitle UFHorizontalBox
---@field ItemTips CommonTipsView
---@field PanelFateTips UFCanvasPanel
---@field PanelFateTips1 UFCanvasPanel
---@field RichTextTips URichTextBox
---@field TextExtra UFTextBlock
---@field AnimFateTips UWidgetAnimation
---@field AnimRichTextTips UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateTipsView = LuaClass(UIView, true)

function FateTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonPlaySound_UIBP = nil
	--self.HorizontalTitle = nil
	--self.ItemTips = nil
	--self.PanelFateTips = nil
	--self.PanelFateTips1 = nil
	--self.RichTextTips = nil
	--self.TextExtra = nil
	--self.AnimFateTips = nil
	--self.AnimRichTextTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonPlaySound_UIBP)
	self:AddSubView(self.ItemTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateTipsView:OnInit()

end

function FateTipsView:OnDestroy()

end

function FateTipsView:OnShow()

end

function FateTipsView:OnHide()

end

function FateTipsView:OnRegisterUIEvent()

end

function FateTipsView:OnRegisterGameEvent()

end

function FateTipsView:OnRegisterBinder()

end

function FateTipsView:ShowMissionTips(ErrorTip, bFateTips, bRichTestTips, bExtraExp)
	if ErrorTip ~= nil then
		self.RichTextTips:SetText(ErrorTip)
	else
		self.RichTextTips:SetText("")
	end

	UIUtil.SetIsVisible(self.PanelFateTips, bFateTips)
	UIUtil.SetIsVisible(self.PanelFateTips1, bRichTestTips)
	UIUtil.SetIsVisible(self.HorizontalTitle, bFateTips)
	UIUtil.SetIsVisible(self.TextExtra, bExtraExp)

	if bFateTips then
		local AnimEndTime = self.AnimFateTips:GetEndTime()
		self:PlayAnimation(self.AnimFateTips)
		self.CommonPlaySound_UIBP:ActiveView()
		local function OnAnimFateTipsEnd()
			self:UnRegisterTimer(self.FateTipsTimerID)
			self.FateTipsTimerID = nil
			self:Hide()
		end
		self.FateTipsTimerID = self:RegisterTimer(OnAnimFateTipsEnd, AnimEndTime) 
	end
	
	if bRichTestTips then
		local AnimEndTime = self.AnimRichTextTips:GetEndTime()
		self:PlayAnimation(self.AnimRichTextTips)
		local function OnAnimRichTextTipsEnd()
			self:UnRegisterTimer(self.RichTestTipsTimerID)
			self.RichTestTipsTimerID = nil
			self:Hide()
		end
		self.RichTestTipsTimerID = self:RegisterTimer(OnAnimRichTextTipsEnd, AnimEndTime) 
	end
end
return FateTipsView