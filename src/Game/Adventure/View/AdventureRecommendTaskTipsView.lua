---
--- Author: Administrator
--- DateTime: 2023-07-31 10:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class AdventureRecommendTaskTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AdvTutorialGestureTips TutorialGestureTipsSystemItemView
---@field PanelRecommendTaskTips UFCanvasPanel
---@field TextTips UFTextBlock
---@field TypeCarPanel UFCanvasPanel
---@field TypeRecPanel UFCanvasPanel
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureRecommendTaskTipsView = LuaClass(UIView, true)
local TypeDefine = {
	Recommend = 1,
	Career = 2
}

function AdventureRecommendTaskTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AdvTutorialGestureTips = nil
	--self.PanelRecommendTaskTips = nil
	--self.TextTips = nil
	--self.TypeCarPanel = nil
	--self.TypeRecPanel = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AdventureRecommendTaskTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AdvTutorialGestureTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureRecommendTaskTipsView:OnInit()
	self.Type = TypeDefine.Recommend
end

function AdventureRecommendTaskTipsView:OnDestroy()

end

function AdventureRecommendTaskTipsView:OnHide()
	self:HidePanel()
end

function AdventureRecommendTaskTipsView:HidePanel()
	self.AdvTutorialGestureTips:RemoveTimer()
	UIUtil.SetIsVisible(self.PanelRecommendTaskTips, false)
end

function AdventureRecommendTaskTipsView:OnRegisterUIEvent()
end

function AdventureRecommendTaskTipsView:OnRegisterGameEvent()
end

function AdventureRecommendTaskTipsView:OnRegisterBinder()
end

function AdventureRecommendTaskTipsView:SetTipsPosition(Pos)
	UIUtil.CanvasSlotSetPosition(self.PanelRecommendTaskTips, Pos)
end

function AdventureRecommendTaskTipsView:SetType(Type, Callback)
	UIUtil.SetIsVisible(self.PanelRecommendTaskTips, true)
	UIUtil.SetIsVisible(self.TypeRecPanel, TypeDefine.Recommend == Type)
	UIUtil.SetIsVisible(self.TypeCarPanel, TypeDefine.Career == Type)
	self.Type = Type
	if TypeDefine.Recommend == Type then
		self.TextTips:SetText(_G.LSTR(520047))
	else
		local RichTextUtil = require("Utils/RichTextUtil")
		local Text = string.format(_G.LSTR(860006), RichTextUtil.GetText(_G.LSTR(860007), "bd8213")) -- 860006 可以接取%s,请前往查看, 860007 职业任务
		self.AdvTutorialGestureTips:SetText(Text)
		local TutorialDefine = require("Game/Tutorial/TutorialDefine")
		self.AdvTutorialGestureTips:NearBy(TutorialDefine.TutorialArrowDir.Bottom, {Type = TutorialDefine.TutorialType.Tips})
		self.AdvTutorialGestureTips:StartCountDown(8, self, function ()
			Callback()
		end)
	end
end

function AdventureRecommendTaskTipsView:GetType()
	return self.Type
end

return AdventureRecommendTaskTipsView