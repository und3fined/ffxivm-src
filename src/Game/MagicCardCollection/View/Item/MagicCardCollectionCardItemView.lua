---
--- Author: Administrator
--- DateTime: 2023-12-18 16:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CardCfg = require("TableCfg/FantasyCardCfg")
local CardRaceCfg = require("TableCfg/FantasyCardRaceCfg")
local CardStarCfg = require("TableCfg/FantasyCardStarCfg")

---@class MagicCardCollectionCardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field CardDisable UFImage
---@field CardsNumber MagicCardNumberItemView
---@field ImgCardBG UFImage
---@field ImgCardOrdary UFImage
---@field ImgCardSelect UFImage
---@field ImgCardShadow UFImage
---@field ImgCardSpecial UFImage
---@field ImgFrame UFImage
---@field ImgFrame_Silver UFImage
---@field ImgIcon UFImage
---@field ImgRace UFImage
---@field ImgStar UFImage
---@field PanelCard UFCanvasPanel
---@field PanelContent UFCanvasPanel
---@field RedDot2 CommonRedDot2View
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicCardCollectionCardItemView = LuaClass(UIView, true)

function MagicCardCollectionCardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.CardDisable = nil
	--self.CardsNumber = nil
	--self.ImgCardBG = nil
	--self.ImgCardOrdary = nil
	--self.ImgCardSelect = nil
	--self.ImgCardShadow = nil
	--self.ImgCardSpecial = nil
	--self.ImgFrame = nil
	--self.ImgFrame_Silver = nil
	--self.ImgIcon = nil
	--self.ImgRace = nil
	--self.ImgStar = nil
	--self.PanelCard = nil
	--self.PanelContent = nil
	--self.RedDot2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicCardCollectionCardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CardsNumber)
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicCardCollectionCardItemView:OnInit()
	self.Binders = {
		{"IsUnLock", UIBinderSetIsVisible.New(self, self.ImgCardOrdary, true)},
		{"IsUnLock", UIBinderSetIsVisible.New(self, self.ImgCardSpecial, true)},
		{"IsUnLock", UIBinderSetIsVisible.New(self, self.PanelContent)},
		{"IsNewUnlock", UIBinderSetIsVisible.New(self, self.RedDot2)},
		{"IsNewUnlock", UIBinderValueChangedCallback.New(self, nil, self.OnIsNewUnlockChanged)},
		{"CardID", UIBinderValueChangedCallback.New(self, nil, self.OnCardIDChanged)},
		{"FrameType", UIBinderValueChangedCallback.New(self, nil, self.OnCardFrameTypeChanged)},
	}
	UIUtil.SetIsVisible(self.CardDisable, false)
	self.RedDot2:SetIsCustomizeRedDot(true)
end

function MagicCardCollectionCardItemView:OnDestroy()

end

function MagicCardCollectionCardItemView:OnShow()
	
end

function MagicCardCollectionCardItemView:OnHide()

end

function MagicCardCollectionCardItemView:OnRegisterUIEvent()

end

function MagicCardCollectionCardItemView:OnRegisterGameEvent()

end

function MagicCardCollectionCardItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self.IsUnLock = ViewModel.IsUnLock
	self:RegisterBinders(ViewModel, self.Binders)
end

function MagicCardCollectionCardItemView:OnLockStateChanged(IsUnLock)
	if IsUnLock == nil then
		return
	end

	UIUtil.SetIsVisible(self.ImgCardOrdary, not IsUnLock)
	UIUtil.SetIsVisible(self.ImgCardSpecial, not IsUnLock)
	UIUtil.SetIsVisible(self.PanelContent, IsUnLock)
end

function MagicCardCollectionCardItemView:OnCardIDChanged(CardID)
	if CardID == 0 then
		return
	end

	local ItemCfg = CardCfg:FindCfgByKey(CardID)
	if nil == ItemCfg then
		Log.E("MagicCardCardItemView:OnCardIdChanged CardId error: [%d]", CardID)
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, ItemCfg.ShowImage)
	self.CardsNumber:UpDateNumberText(ItemCfg)
	local StarCfg = CardStarCfg:FindCfgByKey(ItemCfg.Star)
	if StarCfg ~= nil then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgStar, StarCfg.StarImage)
	end

	if ItemCfg.Race == 0 then
		UIUtil.SetIsVisible(self.ImgRace, false)
	else
		local RaceCfg = CardRaceCfg:FindCfgByKey(ItemCfg.Race)
		if RaceCfg ~= nil then
			UIUtil.SetIsVisible(self.ImgRace, true)
			UIUtil.ImageSetBrushFromAssetPath(self.ImgRace, RaceCfg.RaceImage)
		end
	end
end

function MagicCardCollectionCardItemView:OnCardFrameTypeChanged(NewFrameType)
	self:UpdateFrameType(self.IsUnLock, NewFrameType)
end

function MagicCardCollectionCardItemView:OnIsNewUnlockChanged(IsNewUnlock)
	if IsNewUnlock then
		self.RedDot2.ItemVM:SetIsVisible(true)
	else
		self.RedDot2.ItemVM:SetIsVisible(false)
	end
end

function MagicCardCollectionCardItemView:UpdateFrameType(IsUnLock, NewFrameType)
	if IsUnLock == nil then
		return
	end

	self:OnLockStateChanged(IsUnLock)
	if NewFrameType == ProtoRes.fantasy_card_frame_type.FRAME_TYPE_PLATINUM then -- 铂金框
		UIUtil.SetIsVisible(self.ImgCardOrdary, not IsUnLock)
		UIUtil.SetIsVisible(self.ImgCardSpecial,false)
		UIUtil.SetIsVisible(self.ImgFrame, false)
		UIUtil.SetIsVisible(self.ImgFrame_Silver, true)
	elseif NewFrameType == ProtoRes.fantasy_card_frame_type.FRAME_TYPE_COPPER then -- 铜框
		UIUtil.SetIsVisible(self.ImgCardSpecial,not IsUnLock)
		UIUtil.SetIsVisible(self.ImgCardOrdary, false)
		UIUtil.SetIsVisible(self.ImgFrame,  true)
		UIUtil.SetIsVisible(self.ImgFrame_Silver, false)
	end
end

function MagicCardCollectionCardItemView:OnSelectChanged(IsSelect)
	UIUtil.SetIsVisible(self.ImgCardSelect,IsSelect)
end

return MagicCardCollectionCardItemView