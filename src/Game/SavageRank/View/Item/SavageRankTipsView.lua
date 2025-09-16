---
--- Author: Administrator
--- DateTime: 2023-07-31 10:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SavageRankTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AdvTutorialGestureTips TutorialGestureTipsSystemItemView
---@field PanelRecommendTaskTips UFCanvasPanel
---@field TextTips UFTextBlock
---@field TypeCarPanel UFCanvasPanel
---@field TypeRecPanel UFCanvasPanel
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SavageRankTipsView = LuaClass(UIView, true)
local TypeDefine = {
	Recommend = 1,
	Career = 2
}

function SavageRankTipsView:Ctor()
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

function SavageRankTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AdvTutorialGestureTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SavageRankTipsView:OnInit()
	self.Type = TypeDefine.Recommend
end

function SavageRankTipsView:OnDestroy()

end


function SavageRankTipsView:OnShow()
	UIUtil.SetIsVisible(self.TypeRecPanel, false)
	UIUtil.SetIsVisible(self.TypeCarPanel, true)

end

function SavageRankTipsView:OnHide()
end

function SavageRankTipsView:OnRegisterUIEvent()
end

function SavageRankTipsView:OnRegisterGameEvent()
end

function SavageRankTipsView:OnRegisterBinder()
end

function SavageRankTipsView:SetTipsPosition(Pos)
	UIUtil.CanvasSlotSetPosition(self.PanelRecommendTaskTips, Pos)
end

function SavageRankTipsView:SetType(Type, Callback, Tips)
	print("SavageRankTipsView SetType")
	print(Type)
	print(Tips)
	UIUtil.SetIsVisible(self.TypeRecPanel, TypeDefine.Recommend == Type)
	UIUtil.SetIsVisible(self.TypeCarPanel, TypeDefine.Career == Type)
	self.Type = Type
	self.AdvTutorialGestureTips:SetText(Tips)
	--local TutorialDefine = require("Game/Tutorial/TutorialDefine")
	self.AdvTutorialGestureTips:NearBy(3, {Type = 3})
	self.AdvTutorialGestureTips:StartCountDown(0, self, function ()
		Callback()
	end)
end

function SavageRankTipsView:SetTips(Tips)
	self.AdvTutorialGestureTips:SetText(Tips)
end

function SavageRankTipsView:GetType()
	return self.Type
end

return SavageRankTipsView