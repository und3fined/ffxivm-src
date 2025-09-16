---
--- Author: Administrator
--- DateTime: 2024-02-20 20:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local FashionEvaluationDefine = require("Game/FashionEvaluation/FashionEvaluationDefine")

---@class FashionEvaluationChallengeRecordItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRanKing UToggleButton
---@field ImgFocus UFImage
---@field ImgNormal UFImage
---@field TextNameFocus UFTextBlock
---@field TextNameNormal UFTextBlock
---@field TextRanKingFocus UFTextBlock
---@field TextRanKingNormal UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationChallengeRecordItemView = LuaClass(UIView, true)

function FashionEvaluationChallengeRecordItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRanKing = nil
	--self.ImgFocus = nil
	--self.ImgNormal = nil
	--self.TextNameFocus = nil
	--self.TextNameNormal = nil
	--self.TextRanKingFocus = nil
	--self.TextRanKingNormal = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationChallengeRecordItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationChallengeRecordItemView:OnInit()
	self.Binders = {
		{"EquipGroupIndex", UIBinderSetText.New(self, self.TextRanKingFocus)},
		{"EquipGroupIndex", UIBinderSetText.New(self, self.TextRanKingNormal)},
	}
	local Name = _G.LSTR(FashionEvaluationDefine.RecordTextUKey)
	self.TextNameFocus:SetText(Name)
	self.TextNameNormal:SetText(Name)
end

function FashionEvaluationChallengeRecordItemView:OnDestroy()

end

function FashionEvaluationChallengeRecordItemView:OnShow()

end

function FashionEvaluationChallengeRecordItemView:OnHide()

end

function FashionEvaluationChallengeRecordItemView:OnRegisterUIEvent()

end

function FashionEvaluationChallengeRecordItemView:OnRegisterGameEvent()

end

function FashionEvaluationChallengeRecordItemView:OnRegisterBinder()
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

function FashionEvaluationChallengeRecordItemView:OnSelectChanged(IsSelected)
	--UIUtil.SetIsVisible(self.ImgEquipeSelect, IsSelected)
	self.BtnRanKing:SetChecked(IsSelected, false)
end

return FashionEvaluationChallengeRecordItemView