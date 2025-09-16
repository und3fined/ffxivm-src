---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UILayer = require("UI/UILayer")

---@class FishNotesSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnItem UFButton
---@field ImgClock UFImage
---@field ImgEmpty UFImage
---@field ImgIcon UFImage
---@field ImgQuality UFImage
---@field ImgSelect UFImage
---@field ImgUnknown UFImage
---@field ImgWin UFImage
---@field ImgX UFImage
---@field PanelEmpty UFCanvasPanel
---@field RichTextNum URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishNotesSlotItemView = LuaClass(UIView, true)

function FishNotesSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnItem = nil
	--self.ImgClock = nil
	--self.ImgEmpty = nil
	--self.ImgIcon = nil
	--self.ImgQuality = nil
	--self.ImgSelect = nil
	--self.ImgUnknown = nil
	--self.ImgWin = nil
	--self.ImgX = nil
	--self.PanelEmpty = nil
	--self.RichTextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishNotesSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishNotesSlotItemView:OnInit()
	self.Binders = {
		{ "UnknowIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgUnknown) },
		{ "bUnknowVisible", UIBinderSetIsVisible.New(self, self.ImgUnknown, false, true, false) },
		{ "FishIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "bIconVisible", UIBinderSetIsVisible.New(self, self.ImgIcon, false, true, false) },
		{ "ItemQualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgQuality) },
		{ "bQualityVisible", UIBinderSetIsVisible.New(self, self.ImgQuality, false, true, false) },
		{ "bClockVisible", UIBinderSetIsVisible.New(self, self.ImgClock, false, true, false) },
		{ "bClockActiveVisible", UIBinderSetIsVisible.New(self, self.ImgWin, false, true, false) },
		{ "bSelectXVisible", UIBinderSetIsVisible.New(self, self.ImgX, false, true, false) },
		{ "bSelectEnabled", UIBinderSetIsEnabled.New(self, self.ImgSelect) },
		{ "bNumTextVisible", UIBinderSetIsVisible.New(self, self.RichTextNum) },
		{ "NumText", UIBinderSetText.New(self, self.RichTextNum)}
	}
end

function FishNotesSlotItemView:OnDestroy()
end

function FishNotesSlotItemView:OnShow()
end

function FishNotesSlotItemView:OnHide()
end

function FishNotesSlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnItem, self.OnClickFishSlot)
end

function FishNotesSlotItemView:OnRegisterGameEvent()
end

function FishNotesSlotItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function FishNotesSlotItemView:OnSelectChanged(IsSelected)
	if self.Params and self.Params.Data then
		if self.Params.Data.bSelectEnabled == false then
			return
		end
	end

	UIUtil.SetIsVisible(self.ImgSelect, IsSelected, true, true)
end

function FishNotesSlotItemView:OnClickFishSlot()
	local Data = self.Params and self.Params.Data
	if Data and (Data.IsBait == true or _G.FishNotesMgr:CheckFishUnlockInFround(Data.ID)) then
		ItemTipsUtil.ShowTipsByResID(Data.ItemID, self)
		if _G.UIViewMgr:IsViewVisible(_G.UIViewID.FishReleaseTipsPanel) then
			_G.UIViewMgr:ChangeLayer(_G.UIViewID.ItemTips,UILayer.Tips)
		end
	end
end

return FishNotesSlotItemView