---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local FishIngholeVM = require("Game/FishNotes/FishIngholeVM")
local LSTR = _G.LSTR

---@class FishIngholeInformationItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuff UFButton
---@field BtnCollect UFButton
---@field BtnFishInherit UFButton
---@field Clock UToggleButton
---@field FishSlot CommLight152SlotView
---@field TextName UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeInformationItemView = LuaClass(UIView, true)

function FishIngholeInformationItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuff = nil
	--self.BtnCollect = nil
	--self.BtnFishInherit = nil
	--self.Clock = nil
	--self.FishSlot = nil
	--self.TextName = nil
	--self.AnimIn = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeInformationItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.FishSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeInformationItemView:OnInit()
	self.Binders = {
		{"FishDetailsName", UIBinderSetText.New(self, self.TextName) },
		--{"FishDetailsNameColor", UIBinderSetColorAndOpacityHex.New(self, self.TextName)},
		{"bBtnBuffVisible", UIBinderSetIsVisible.New(self, self.BtnBuff, false, true)},
		{"FishDetailStatusBuffIcon", UIBinderSetBrushFromAssetPath.New(self, self.BtnBuff)},
		{"BtnCollectVisible", UIBinderSetIsVisible.New(self, self.BtnCollect, false, true)},
		{"bBtnFishInheritVisible", UIBinderSetIsVisible.New(self, self.BtnFishInherit, false, true)},
	}
end

function FishIngholeInformationItemView:OnDestroy()

end

function FishIngholeInformationItemView:OnShow()

end

function FishIngholeInformationItemView:OnHide()

end

function FishIngholeInformationItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBuff, self.OnClickBtnBtnBuff)
	UIUtil.AddOnClickedEvent(self, self.BtnCollect, self.OnClickBtnCollect)
end

function FishIngholeInformationItemView:OnClickBtnBtnBuff()
	--捕鱼人之识详情
	_G.UIViewMgr:ShowView(_G.UIViewID.FishIngHoleTips)
end

function FishIngholeInformationItemView:OnClickBtnCollect()
	--"该鱼类可作为收藏品"
	TipsUtil.ShowInfoTips(LSTR(180082), self.BtnCollect, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0), false)
end

function FishIngholeInformationItemView:OnRegisterGameEvent()
end

function FishIngholeInformationItemView:OnRegisterBinder()
	self:RegisterBinders(FishIngholeVM, self.Binders)
	self.FishSlot:SetParams({Data = FishIngholeVM.FishDetailsInfo})
end

return FishIngholeInformationItemView