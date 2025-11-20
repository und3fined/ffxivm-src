---
--- Author: Administrator
--- DateTime: 2025-07-15 20:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local ItemUtil = require("Utils/ItemUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class StarLightRhythmGameResultWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAgain CommBtnMView
---@field BtnClose CommonCloseBtnView
---@field BtnExit CommBtnLView
---@field BtnTheEnd CommBtnMView
---@field CommBackpack96Slot CommBackpack96SlotView
---@field EFFNewSatisfaction UFCanvasPanel
---@field EFFNewScore UFCanvasPanel
---@field FCanvasPanelReward UFCanvasPanel
---@field FCanvasPanel_149 UFCanvasPanel
---@field FImage_18 UFImage
---@field FImage_352 UFImage
---@field FTextBlock UFTextBlock
---@field FTextBlock_1 UFTextBlock
---@field FTextBlock_181 UFTextBlock
---@field FTextBlock_2 UFTextBlock
---@field FTextBlock_244 UFTextBlock
---@field FTextBlock_3 UFTextBlock
---@field FTextBlock_4 UFTextBlock
---@field FTextBlock_5 UFTextBlock
---@field ImgDifficultyBG UFImage
---@field ImgIconDifficuity UFImage
---@field PanelFail UFCanvasPanel
---@field PanelFailBtn UFCanvasPanel
---@field PanelHighest UFCanvasPanel
---@field PanelHighest_1 UFCanvasPanel
---@field PanelSuccess UFCanvasPanel
---@field TextDifficuity UFTextBlock
---@field TextHighest UFTextBlock
---@field TextHighest_1 UFTextBlock
---@field TextPerfect UFTextBlock
---@field TextReward_1 UFTextBlock
---@field TextScoreNormal UFTextBlock
---@field TextScoreNormal_1 UFTextBlock
---@field TextScoreNormal_2 UFTextBlock
---@field TextScoreNormal_3 UFTextBlock
---@field TextScoreNormal_4 UFTextBlock
---@field TextScoreNormal_5 UFTextBlock
---@field TextScoreNormal_6 UFTextBlock
---@field TextScoreNormal_7 UFTextBlock
---@field AnimFail UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimSuccess UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StarLightRhythmGameResultWinView = LuaClass(UIView, true)

function StarLightRhythmGameResultWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAgain = nil
	--self.BtnClose = nil
	--self.BtnExit = nil
	--self.BtnTheEnd = nil
	--self.CommBackpack96Slot = nil
	--self.EFFNewSatisfaction = nil
	--self.EFFNewScore = nil
	--self.FCanvasPanelReward = nil
	--self.FCanvasPanel_149 = nil
	--self.FImage_18 = nil
	--self.FImage_352 = nil
	--self.FTextBlock = nil
	--self.FTextBlock_1 = nil
	--self.FTextBlock_181 = nil
	--self.FTextBlock_2 = nil
	--self.FTextBlock_244 = nil
	--self.FTextBlock_3 = nil
	--self.FTextBlock_4 = nil
	--self.FTextBlock_5 = nil
	--self.ImgDifficultyBG = nil
	--self.ImgIconDifficuity = nil
	--self.PanelFail = nil
	--self.PanelFailBtn = nil
	--self.PanelHighest = nil
	--self.PanelHighest_1 = nil
	--self.PanelSuccess = nil
	--self.TextDifficuity = nil
	--self.TextHighest = nil
	--self.TextHighest_1 = nil
	--self.TextPerfect = nil
	--self.TextReward_1 = nil
	--self.TextScoreNormal = nil
	--self.TextScoreNormal_1 = nil
	--self.TextScoreNormal_2 = nil
	--self.TextScoreNormal_3 = nil
	--self.TextScoreNormal_4 = nil
	--self.TextScoreNormal_5 = nil
	--self.TextScoreNormal_6 = nil
	--self.TextScoreNormal_7 = nil
	--self.AnimFail = nil
	--self.AnimLoop = nil
	--self.AnimSuccess = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StarLightRhythmGameResultWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAgain)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnExit)
	self:AddSubView(self.BtnTheEnd)
	self:AddSubView(self.CommBackpack96Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StarLightRhythmGameResultWinView:OnInit()

end

function StarLightRhythmGameResultWinView:OnDestroy()

end

function StarLightRhythmGameResultWinView:OnShow()
	self.TextHighest:SetText(_G.LSTR(1710016)) -- 新纪录
	self.TextHighest_1:SetText(_G.LSTR(1710016))
	
	self.FTextBlock_244:SetText(_G.LSTR(1710017))  -- 观众满意度
	self.FTextBlock_1:SetText(_G.LSTR(1710001)) -- 得分
	self.FTextBlock_2:SetText(_G.LSTR(1710012))  -- 完美
	self.FTextBlock_3:SetText(_G.LSTR(1710013))  -- 很棒
	self.FTextBlock_4:SetText(_G.LSTR(1710014))  -- 不错
	self.FTextBlock_5:SetText(_G.LSTR(1710018))  -- 失误
	
	self.BtnExit:SetText(_G.LSTR(1710005))  -- 结束
	self.BtnTheEnd:SetText(_G.LSTR(1710005))  -- 结束
	self.BtnAgain:SetText(_G.LSTR(1710019))  -- 重新开始

	self.TextReward_1:SetText(_G.LSTR(1710020))  -- 奖励
	self:PlayAnimation(self.AnimLoop, 0, 0)
	
	if self.VM and self.VM.IsSuc then
		self:PlayAnimation(self.AnimSuccess)
	else
		self:PlayAnimation(self.AnimFail)
	end
end

function StarLightRhythmGameResultWinView:OnHide()
end

function StarLightRhythmGameResultWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnExit, self.OnClickBtnExit)
	UIUtil.AddOnClickedEvent(self, self.BtnTheEnd, self.OnClickBtnTheEnd)
	UIUtil.AddOnClickedEvent(self, self.BtnAgain, self.OnClickBtnAgain)
	self.CommBackpack96Slot:SetClickButtonCallback(self, self.OnBtnItemClicked)

	self.BtnClose:SetCallback(self, function()
		_G.RhythmGameMgr:EndGame()
	end)
end

function StarLightRhythmGameResultWinView:OnRegisterGameEvent()

end

function StarLightRhythmGameResultWinView:OnRegisterBinder()
	local Binders = {
		{ "IsSuc", UIBinderSetIsVisible.New(self, self.FCanvasPanelReward) },
		{ "IsSuc", UIBinderSetIsVisible.New(self, self.PanelFailBtn, true) },

		{ "IsFullCombo", UIBinderSetIsVisible.New(self, self.FCanvasPanel_149) },
		{ "FullComboText", UIBinderSetText.New(self, self.TextPerfect) },
		
		{ "IsNewSatisfaction", UIBinderSetIsVisible.New(self, self.PanelHighest) },
		{ "IsNewSatisfaction", UIBinderSetIsVisible.New(self, self.EFFNewSatisfaction) },
		{ "IsNewSatisfaction", UIBinderSetIsVisible.New(self, self.TextScoreNormal, true) },
		
		{ "IsNewSScore", UIBinderSetIsVisible.New(self, self.EFFNewScore) },
		{ "IsNewSScore", UIBinderSetIsVisible.New(self, self.PanelHighest_1) },
		{ "IsNewSScore", UIBinderSetIsVisible.New(self, self.TextScoreNormal_2, true) },
		
		{ "SatisfactionText", UIBinderSetText.New(self, self.TextScoreNormal) },
		{ "SatisfactionText", UIBinderSetText.New(self, self.TextScoreNormal_1) },
		{ "SScore", UIBinderSetText.New(self, self.TextScoreNormal_2) },
		{ "SScore", UIBinderSetText.New(self, self.TextScoreNormal_3) },
		{ "PerfectHits", UIBinderSetText.New(self, self.TextScoreNormal_4) },
		{ "GreatHits", UIBinderSetText.New(self, self.TextScoreNormal_5) },
		{ "GoodHits", UIBinderSetText.New(self, self.TextScoreNormal_6) },
		{ "Misses", UIBinderSetText.New(self, self.TextScoreNormal_7) },
		
		{ "CurModeText", UIBinderSetText.New(self, self.TextDifficuity) },
		{ "CurModePath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIconDifficuity) },
		
		{ "LootID", UIBinderValueChangedCallback.New(self, nil, self.OnLootIDChange) }
	}
	self.VM = _G.RhythmGameMgr:GetRhythmGameVM()
	self:RegisterBinders(self.VM, Binders)
end

function StarLightRhythmGameResultWinView:OnLootIDChange(Value)
	if Value <= 0 then
		return
	end
	local LootCfg = LootMappingCfg:FindCfg(string.format("ID=%d", Value))
	if LootCfg then
		--默认只采取第一个方案
		if LootCfg.Programs and LootCfg.Programs[1] then
			local RewardItemList = ItemUtil.GetLootItems(LootCfg.Programs[1].ID)
			if RewardItemList[1] then
				self.AwardItemID = RewardItemList[1].ResID
				local Cfg = ItemCfg:FindCfgByKey(self.AwardItemID)
				self.CommBackpack96Slot:SetIconImg(UIUtil.GetIconPath(Cfg.IconID))
				self.CommBackpack96Slot:SetNumVisible(true)
				self.CommBackpack96Slot:SetNum(RewardItemList[1].Num)
				self.CommBackpack96Slot:SetQualityImg(ItemUtil.GetItemColorIcon(self.AwardItemID))
				self.CommBackpack96Slot:CommSetVisible(self.CommBackpack96Slot.RedDot2, false)
				self.CommBackpack96Slot:CommSetVisible(self.CommBackpack96Slot.RichTextLevel, false)
				self.CommBackpack96Slot:CommSetVisible(self.CommBackpack96Slot.IconChoose, false)
			end
		end
	end
end

function StarLightRhythmGameResultWinView:OnBtnItemClicked(ItemView)
	if self.AwardItemID and self.AwardItemID > 0 then
		local ItemTipsUtil = require("Utils/ItemTipsUtil")
		local UILayer = require("UI/UILayer")
		ItemTipsUtil.ShowTipsByResID(self.AwardItemID, ItemView, _G.UE4.FVector2D(0, 0))
		_G.UIViewMgr:ChangeLayer(_G.UIViewID.ItemTips, UILayer.BelowHigh)
	end
end

function StarLightRhythmGameResultWinView:OnClickBtnExit()
	_G.RhythmGameMgr:EndGame()
end

function StarLightRhythmGameResultWinView:OnClickBtnTheEnd()
	_G.RhythmGameMgr:EndGame()
end

function StarLightRhythmGameResultWinView:OnClickBtnAgain()
	_G.RhythmGameMgr:ReStartGame()
end

return StarLightRhythmGameResultWinView