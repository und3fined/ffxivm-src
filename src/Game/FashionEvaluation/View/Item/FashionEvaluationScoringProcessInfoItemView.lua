---
--- Author: Administrator
--- DateTime: 2024-02-20 20:20
--- Description:弹幕Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class FashionEvaluationScoringProcessInfoItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field Text UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationScoringProcessInfoItemView = LuaClass(UIView, true)

function FashionEvaluationScoringProcessInfoItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PlayerHeadSlot = nil
	--self.Text = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationScoringProcessInfoItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerHeadSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationScoringProcessInfoItemView:OnInit()
	self.Binders = {
		{"NPCName", UIBinderSetText.New(self, self.TextName)},
		{"NPCComment", UIBinderSetText.New(self, self.Text)},
		{"NPCIcon", UIBinderSetBrushFromAssetPath.New(self, self.PlayerHeadSlot.ImageIcon)},
	}
end

function FashionEvaluationScoringProcessInfoItemView:OnDestroy()

end

function FashionEvaluationScoringProcessInfoItemView:OnShow()

end

function FashionEvaluationScoringProcessInfoItemView:OnHide()

end

function FashionEvaluationScoringProcessInfoItemView:OnRegisterUIEvent()

end

function FashionEvaluationScoringProcessInfoItemView:OnRegisterGameEvent()

end

function FashionEvaluationScoringProcessInfoItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end

	self:RegisterBinders(self.ViewModel, self.Binders)
end

return FashionEvaluationScoringProcessInfoItemView