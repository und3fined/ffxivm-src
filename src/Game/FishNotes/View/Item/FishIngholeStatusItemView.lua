---
--- Author: Administrator
--- DateTime: 2023-03-29 12:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local FishIngholeVM = require("Game/FishNotes/FishIngholeVM")

---@class FishIngholeStatusItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Fish UFCanvasPanel
---@field IconStatus UFImage
---@field TableViewSlot UTableView
---@field TextFish UFTextBlock
---@field TextLevel UFTextBlock
---@field TextStatus UFTextBlock
---@field AnimUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeStatusItemView = LuaClass(UIView, true)

function FishIngholeStatusItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Fish = nil
	--self.IconStatus = nil
	--self.TableViewSlot = nil
	--self.TextFish = nil
	--self.TextLevel = nil
	--self.TextStatus = nil
	--self.AnimUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeStatusItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeStatusItemView:OnInit()
	self.FishDetailStatusFishIoreList = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.TableViewSelected, true, false)
	self.Binders = {
		{ "FishDetailStatusBuffIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconStatus) },
		{ "FishDetailStatusBuffTime", UIBinderSetText.New(self, self.TextLevel) },
		{ "FishDetailStatusFishIoreList", UIBinderUpdateBindableList.New(self, self.FishDetailStatusFishIoreList) },
		{ "bFishDetailStatusBuffVisible", UIBinderSetIsVisible.New(self, self.Status) },
		{ "bFishDetailStatusFishIoreVisible", UIBinderSetIsVisible.New(self, self.Fish) },
	}
end

function FishIngholeStatusItemView:OnDestroy()

end

function FishIngholeStatusItemView:OnShow()

end

function FishIngholeStatusItemView:OnHide()
	self.TextStatus:SetText(_G.LSTR(180049))--所需状态
	self.TextFish:SetText(_G.LSTR(180050))--捕鱼人之识前置鱼
end

function FishIngholeStatusItemView:OnRegisterUIEvent()

end

function FishIngholeStatusItemView:OnRegisterGameEvent()

end

function FishIngholeStatusItemView:OnRegisterBinder()
	self:RegisterBinders(FishIngholeVM, self.Binders)
end

function FishIngholeStatusItemView:TableViewSelected(Index, ItemData, ItemView)
	ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView)
end

return FishIngholeStatusItemView