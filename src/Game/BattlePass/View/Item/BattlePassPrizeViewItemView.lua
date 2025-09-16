---
--- Author: Administrator
--- DateTime: 2024-12-11 16:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class BattlePassPrizeViewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSlotTips UFButton
---@field BtnView UFButton
---@field ImgIcon UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassPrizeViewItemView = LuaClass(UIView, true)

function BattlePassPrizeViewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSlotTips = nil
	--self.BtnView = nil
	--self.ImgIcon = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassPrizeViewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassPrizeViewItemView:OnInit()
	self.Binders = {
		{ "ItemName", UIBinderSetText.New(self, self.TextName)},
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
	}
end

function BattlePassPrizeViewItemView:OnDestroy()

end

function BattlePassPrizeViewItemView:OnShow()

end

function BattlePassPrizeViewItemView:OnHide()

end

function BattlePassPrizeViewItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSlotTips, self.OnClickedItemTips)
	UIUtil.AddOnClickedEvent(self, self.BtnView, self.OnClickedGotoPreview)
end

function BattlePassPrizeViewItemView:OnRegisterGameEvent()

end

function BattlePassPrizeViewItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function BattlePassPrizeViewItemView:OnClickedItemTips()
	if self.ViewModel == nil then
		return
	end

	local VM = self.ViewModel
	if VM.ResID ~= nil then
	ItemTipsUtil.ShowTipsByResID(VM.ResID, self.ImgIcon)
	end
end

function BattlePassPrizeViewItemView:OnClickedGotoPreview()
	if self.ViewModel == nil then
		return
	end

	local VM = self.ViewModel
	if VM.ResID ~= nil then
	_G.PreviewMgr:OpenPreviewView(VM.ResID)
	end
end

return BattlePassPrizeViewItemView