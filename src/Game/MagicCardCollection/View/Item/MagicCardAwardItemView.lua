---
--- Author: Administrator
--- DateTime: 2023-12-18 16:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ItemCfg = require("TableCfg/ItemCfg")
local MagicCardCollectionMgr = require("Game/MagicCardCollection/MagicCardCollectionMgr")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class MagicCardAwardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field FCanvasPanel UFCanvasPanel
---@field ImgBgNormal UFImage
---@field ImgBgReceive UFImage
---@field ImgIcon UFImage
---@field ImgIconReceived UFImage
---@field ImgWpBgNormal UFImage
---@field ImgWpBgReceived UFImage
---@field TextQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicCardAwardItemView = LuaClass(UIView, true)

function MagicCardAwardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.FCanvasPanel = nil
	--self.ImgBgNormal = nil
	--self.ImgBgReceive = nil
	--self.ImgIcon = nil
	--self.ImgIconReceived = nil
	--self.ImgWpBgNormal = nil
	--self.ImgWpBgReceived = nil
	--self.TextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicCardAwardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicCardAwardItemView:OnInit()
	self.Binders = {
		{"CollectTargetNum", UIBinderSetText.New(self, self.TextQuantity)},
		{"IsGetProgress", UIBinderSetIsVisible.New(self, self.ImgBgReceive)},
		{"IsCollectedAward", UIBinderSetIsVisible.New(self, self.ImgIconReceived)},
		{"IsCollectedAward", UIBinderSetIsVisible.New(self, self.ImgWpBgReceived)},
		{"IsCollectedAward", UIBinderSetIsVisible.New(self, self.ImgWpBgNormal, true)},
		{"AwardID", UIBinderValueChangedCallback.New(self, nil, self.OnAwardIDChanged)},
		--{ "AwardIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
	}
end

function MagicCardAwardItemView:OnDestroy()

end

function MagicCardAwardItemView:OnShow()
	UIUtil.CanvasSlotSetZOrder(self.ImgIconReceived, 1)
end

function MagicCardAwardItemView:OnHide()

end

function MagicCardAwardItemView:OnRegisterUIEvent()
end

function MagicCardAwardItemView:OnRegisterGameEvent()

end

function MagicCardAwardItemView:OnRegisterBinder()
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

function MagicCardAwardItemView:OnAwardIDChanged(AwardID)
	if AwardID == nil then
		return
	end
	local Cfg = ItemCfg:FindCfgByKey(AwardID)
	if Cfg == nil then
		return
	end

	local ItemIconPath = UIUtil.GetIconPath(Cfg.IconID)
	if nil == ItemIconPath then
		return
	end
	
	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, ItemIconPath)
end

return MagicCardAwardItemView