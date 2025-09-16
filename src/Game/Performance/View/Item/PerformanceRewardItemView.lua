---
--- Author: moodliu
--- DateTime: 2023-11-24 16:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MusicPerformanceUtil = require("Game/MusicPerformance/Util/MusicPerformanceUtil")
local MPDefines = require("Game/MusicPerformance/MusicPerformanceDefines")

local MusicPerformanceRewardSlotVM = require("Game/Performance/VM/MusicPerformanceRewardSlotVM")
local PerformanceRewardItemVM = require("Game/Performance/VM/PerformanceRewardItemVM")
local ProtoRes = require("Protocol/ProtoRes")

---@class PerformanceRewardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNextBg UFImage
---@field ImgNormalBg UFImage
---@field ImgScore UFImage
---@field Reward1 CommRewardsSlotView
---@field Reward2 CommRewardsSlotView
---@field Reward3 CommRewardsSlotView
---@field TextDescription UFTextBlock
---@field AnimLight UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceRewardItemView = LuaClass(UIView, true)

function PerformanceRewardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgNextBg = nil
	--self.ImgNormalBg = nil
	--self.ImgScore = nil
	--self.Reward1 = nil
	--self.Reward2 = nil
	--self.Reward3 = nil
	--self.TextDescription = nil
	--self.AnimLight = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceRewardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Reward1)
	self:AddSubView(self.Reward2)
	self:AddSubView(self.Reward3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceRewardItemView:OnInit()
	self.VM = PerformanceRewardItemVM.New()
	
	self.VM1 = MusicPerformanceRewardSlotVM.New()
	self.Reward1:SetParams({Data = self.VM1, OnClick = self.OnClick})

	self.VM2 = MusicPerformanceRewardSlotVM.New()
	self.Reward2:SetParams({Data = self.VM2, OnClick = self.OnClick})

	self.VM3 = MusicPerformanceRewardSlotVM.New()
	self.Reward3:SetParams({Data = self.VM3, OnClick = self.OnClick})
end

function PerformanceRewardItemView:OnDestroy()

end

function PerformanceRewardItemView:OnShow()
end

function PerformanceRewardItemView.OnClick(View, Params)
	ItemTipsUtil.ShowTipsByResID(Params.Data.ID, View)
end

function PerformanceRewardItemView:OnHide()

end

function PerformanceRewardItemView:OnRegisterUIEvent()

end

function PerformanceRewardItemView:OnRegisterGameEvent()

end

function PerformanceRewardItemView:OnScoreLevelChanged(NewValue)
	local ThisScoreLevel = self.Params.Data.ScoreLevel or 0

	local InvalidScore = NewValue == nil or NewValue == 0
	local HasGot = not InvalidScore and ThisScoreLevel >= NewValue

	self.VM1:UpdateVM({ID = 19000002, HasGot = HasGot, Count = 1000})
	self.VM2:UpdateVM({ID = 60100001, HasGot = HasGot, Count = 2})
	self.VM3:UpdateVM({ID = 19000002, HasGot = HasGot, Count = 1})

	local IsNextLevel = (InvalidScore and ThisScoreLevel == ProtoRes.MusicAwardRank.MusicAwardRank_C) or (not InvalidScore and ThisScoreLevel == NewValue - 1)	-- 若没有分数，则下一目标是C级
	self.VM.ImgNextBgVisible = IsNextLevel

	if IsNextLevel then
		self.VM.TextDescription = LSTR(830005)
		self.VM.TextDescriptionColor = "D1BA8EFF"
	elseif InvalidScore or ThisScoreLevel < NewValue then
		self.VM.TextDescription = LSTR(830036)
		self.VM.TextDescriptionColor = "D5D5D5FF"
	else
		self.VM.TextDescription = LSTR(830026)
		self.VM.TextDescriptionColor = "828282FF"
	end

	self.VM.ImgScoreVisible = true
	self.VM.ImgScorePtah = MusicPerformanceUtil.GetScoreLevelIconPath(ThisScoreLevel)
end

function PerformanceRewardItemView:OnRegisterBinder()
	local Binders = {
		{ "TextDescription", UIBinderSetText.New(self, self.TextDescription)},
		{ "TextDescriptionVisible", UIBinderSetIsVisible.New(self, self.TextDescription)},
		{ "TextDescriptionColor", UIBinderSetColorAndOpacityHex.New(self, self.TextDescription, true) },
		{ "ImgNextBgVisible", UIBinderSetIsVisible.New(self, self.ImgNextBg)},
		{ "ImgScoreVisible", UIBinderSetIsVisible.New(self, self.ImgScore)},
		{ "ImgScorePtah", UIBinderSetImageBrush.New(self, self.ImgScore)},
	}

	self:RegisterBinders(self.VM, Binders)
	
	if self.Params.Data.SongVM then
		local SongBinders = {
			{ "ScoreLevel", UIBinderValueChangedCallback.New(self, nil, self.OnScoreLevelChanged)},
		}
		self:RegisterBinders(self.Params.Data.SongVM, SongBinders)
	end
end

return PerformanceRewardItemView