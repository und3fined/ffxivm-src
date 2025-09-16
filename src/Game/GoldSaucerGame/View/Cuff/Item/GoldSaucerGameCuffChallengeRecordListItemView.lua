---
--- Author: Administrator
--- DateTime: 2024-02-04 11:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class GoldSaucerGameCuffChallengeRecordListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelTimes UFCanvasPanel
---@field TextNewRecord UFTextBlock
---@field TextQuantity UFTextBlock
---@field TextTitle UFTextBlock
---@field TextUnfinished UFTextBlock
---@field AnimaNew UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerGameCuffChallengeRecordListItemView = LuaClass(UIView, true)

function GoldSaucerGameCuffChallengeRecordListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelTimes = nil
	--self.TextNewRecord = nil
	--self.TextQuantity = nil
	--self.TextTitle = nil
	--self.TextUnfinished = nil
	--self.AnimaNew = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerGameCuffChallengeRecordListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerGameCuffChallengeRecordListItemView:OnInit()
	self.Binders = {
		{"VarName", UIBinderSetText.New(self, self.TextTitle)},
		{"Value", UIBinderSetText.New(self, self.TextQuantity)},
		{"bIsNewRecord", UIBinderSetIsVisible.New(self, self.TextNewRecord)},
		{"bShowUnfinished", UIBinderSetIsVisible.New(self, self.TextUnfinished)},
		{"bShowUnfinished", UIBinderSetIsVisible.New(self, self.TextQuantity, true)},
		{"bIsPerfectChallenge", UIBinderValueChangedCallback.New(self, nil, self.OnNotifyAnimPlay)},
        -- {"AnimNum", UIBinderValueChangedCallback.New(self, nil, self.OnValueChange)}

	}
end

function GoldSaucerGameCuffChallengeRecordListItemView:OnDestroy()

end

function GoldSaucerGameCuffChallengeRecordListItemView:OnShow()
	local LSTR = _G.LSTR
	self.TextNewRecord:SetText(LSTR(250026)) -- 新纪录！
	self.TextUnfinished:SetText(LSTR(250027)) -- 未通关
end

function GoldSaucerGameCuffChallengeRecordListItemView:OnHide()

end

function GoldSaucerGameCuffChallengeRecordListItemView:OnRegisterUIEvent()

end

function GoldSaucerGameCuffChallengeRecordListItemView:OnRegisterGameEvent()

end

function GoldSaucerGameCuffChallengeRecordListItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

function GoldSaucerGameCuffChallengeRecordListItemView:OnNotifyAnimPlay(bIsPerfectChallenge)
	if bIsPerfectChallenge then
		self:PlayAnimation(self.AnimaNew)
	else
		local AnimLength = self.AnimaNew:GetEndTime()
		self:PlayAnimation(self.AnimaNew, AnimLength - 0.05, 1, _G.UE.EUMGSequencePlayMode.Reverse)
	end
end

--- @type 投篮，重击，水晶塔复用
function GoldSaucerGameCuffChallengeRecordListItemView:CheckPlayAnim()
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	local Value = ViewModel.Value
	if tonumber(string.sub(Value, 1, 1)) > 0 then
		-- UIUtil.SetIsVisible(self.TextQuantity, true)
		self:PlayAnimation(self.AnimaNew)
		self:PlayAnimation(self.AnimIn)
	end
end

function GoldSaucerGameCuffChallengeRecordListItemView:Reset()
	local AnimLength = self.AnimaNew:GetEndTime()
	self:PlayAnimation(self.AnimaNew, AnimLength - 0.05, 1, _G.UE.EUMGSequencePlayMode.Reverse)

	UIUtil.SetIsVisible(self.TextQuantity, false)
end

return GoldSaucerGameCuffChallengeRecordListItemView