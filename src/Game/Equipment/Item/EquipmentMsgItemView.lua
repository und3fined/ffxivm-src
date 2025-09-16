---
--- Author: enqingchen
--- DateTime: 2021-12-27 15:48
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

---@class EquipmentMsgItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FBtn_Icon UFButton
---@field ItemTableView UTableView
---@field Text_Title UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentMsgItemView = LuaClass(UIView, true)

function EquipmentMsgItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FBtn_Icon = nil
	--self.ItemTableView = nil
	--self.Text_Title = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentMsgItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentMsgItemView:OnInit()
	self.AdapterTableView = UIAdapterTableView.CreateAdapter(self, self.ItemTableView)
end

function EquipmentMsgItemView:OnDestroy()

end

function EquipmentMsgItemView:OnShow()

end

function EquipmentMsgItemView:OnHide()

end

function EquipmentMsgItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FBtn_Icon, self.OnBtnClick)
end

function EquipmentMsgItemView:OnRegisterGameEvent()

end

function EquipmentMsgItemView:OnRegisterBinder()
	self.ViewModel = self.Params.Data
	local Binders = {
		{ "TitleText", UIBinderSetText.New(self, self.Text_Title) },
		--{ "RightIcon", UIBinderSetBrushFromAssetPath.New(self, self.Img_Icon) },
		{ "bHasIcon", UIBinderSetIsVisible.New(self, self.FBtn_Icon, false, true) },
		{ "lstEquipmentAttrItemVM", UIBinderUpdateBindableList.New(self, self.AdapterTableView) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function EquipmentMsgItemView:OnBtnClick()
	if self.ViewModel.IconClick ~= nil then
		self.ViewModel.IconClick()
	end
end

return EquipmentMsgItemView