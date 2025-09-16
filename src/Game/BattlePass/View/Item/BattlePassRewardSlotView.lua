---
--- Author: Administrator
--- DateTime: 2024-12-11 16:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class BattlePassRewardSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field EffectSelect UFCanvasPanel
---@field FCanvasPanel_42 UFCanvasPanel
---@field ImgBG UFImage
---@field ImgGot UFImage
---@field ImgIcon UFImage
---@field ImgMask UFImage
---@field ImgUnlock UFImage
---@field PanelGot UFCanvasPanel
---@field TextLevel UFTextBlock
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassRewardSlotView = LuaClass(UIView, true)

function BattlePassRewardSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.EffectSelect = nil
	--self.FCanvasPanel_42 = nil
	--self.ImgBG = nil
	--self.ImgGot = nil
	--self.ImgIcon = nil
	--self.ImgMask = nil
	--self.ImgUnlock = nil
	--self.PanelGot = nil
	--self.TextLevel = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassRewardSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassRewardSlotView:OnInit()

end

function BattlePassRewardSlotView:OnDestroy()

end

function BattlePassRewardSlotView:OnShow()

end

function BattlePassRewardSlotView:OnHide()

end

function BattlePassRewardSlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickedItem)
end

function BattlePassRewardSlotView:OnRegisterGameEvent()

end

function BattlePassRewardSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self.Binders = {
		{"Num", UIBinderSetText.New(self, self.TextNum)},
		{"IsAvailable", UIBinderSetIsVisible.New(self, self.ImgSelect)},
		{"IsAvailable", UIBinderSetIsVisible.New(self, self.EffectSelect)},
		{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
		{"IsGot", UIBinderSetIsVisible.New(self, self.ImgMask)},
		{"IsGot", UIBinderSetIsVisible.New(self, self.ImgGot)},
		{"LvText",UIBinderSetText.New(self, self.TextLevel)},
		{"IsShowLevel",UIBinderSetIsVisible.New(self, self.TextLevel)},
		{"IsShow", UIBinderSetIsVisible.New(self, self.FCanvasPanel_42)},
		{"IsUnlock", UIBinderSetIsVisible.New(self, self.ImgUnlock)},
		{"ItemQualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgBG)},
	}

	self:RegisterBinders(ViewModel, self.Binders)
end

function BattlePassRewardSlotView:OnClickedItem()
	local Params = self.Params
	if nil == Params then
		return
	end
	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	if ViewModel.IsAvailable then
		--Todo 领取
		_G.BattlePassMgr:SendBattlePassGetLevelReawrdReq(ViewModel.Lv, ViewModel.Grade)
		return
	end

	if ViewModel.ResID ~= nil then
		ItemTipsUtil.ShowTipsByResID(ViewModel.ResID, self.ImgIcon)
	end
end

return BattlePassRewardSlotView