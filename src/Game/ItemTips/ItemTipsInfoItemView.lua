---
--- Author: anypkvcai
--- DateTime: 2022-03-22 20:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class ItemTipsInfoItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonIcon UFButton
---@field ImageIcon UFImage
---@field TableViewAttr UTableView
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ItemTipsInfoItemView = LuaClass(UIView, true)

function ItemTipsInfoItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonIcon = nil
	--self.ImageIcon = nil
	--self.TableViewAttr = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ItemTipsInfoItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ItemTipsInfoItemView:OnInit()
	self.AdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewAttr)
	self.Binders = {
		{ "TitleText", UIBinderSetText.New(self, self.TextTitle) },
		{ "RightIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImageIcon) },
		{ "bHasIcon", UIBinderSetIsVisible.New(self, self.ButtonIcon, false, true) },
		{ "lstEquipmentAttrItemVM", UIBinderUpdateBindableList.New(self, self.AdapterTableView) },
	}

end

function ItemTipsInfoItemView:OnDestroy()

end

function ItemTipsInfoItemView:OnShow()

end

function ItemTipsInfoItemView:OnHide()

end

function ItemTipsInfoItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonIcon, self.OnClickedIcon)
end

function ItemTipsInfoItemView:OnRegisterGameEvent()

end

function ItemTipsInfoItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data

	
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ItemTipsInfoItemView:OnClickedIcon()
	if self.ViewModel.IconClick ~= nil then
		self.ViewModel.IconClick()
	end
end

return ItemTipsInfoItemView