---
--- Author: Administrator
--- DateTime: 2024-01-17 16:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class CommScreenerClassSItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgIcon1 UFImage
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field ImgSelectTag UFImage
---@field PanelIcon UFCanvasPanel
---@field PanelSelect UFCanvasPanel
---@field SizeBox1 USizeBox
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommScreenerClassSItemView = LuaClass(UIView, true)

function CommScreenerClassSItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.ImgIcon1 = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.ImgSelectTag = nil
	--self.PanelIcon = nil
	--self.PanelSelect = nil
	--self.SizeBox1 = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommScreenerClassSItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommScreenerClassSItemView:OnInit()

end

function CommScreenerClassSItemView:OnDestroy()

end

function CommScreenerClassSItemView:OnShow()

end

function CommScreenerClassSItemView:OnHide()

end

function CommScreenerClassSItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickedItemBtn)
end

function CommScreenerClassSItemView:OnRegisterGameEvent()

end

function CommScreenerClassSItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	local Binders = {
		{ "SelectedNodeVisible", UIBinderSetIsVisible.New(self, self.PanelSelect) },
		{ "SelectedTagVisible", UIBinderSetIsVisible.New(self, self.ImgSelectTag) }, --多选增加的tag显示

		{ "SingleTextVisible", UIBinderSetIsVisible.New(self, self.TextName) }, 
		{ "SingleText", UIBinderSetText.New(self, self.TextName) },

		{ "SingleIconVisible", UIBinderSetIsVisible.New(self, self.PanelIcon) }, 
		{ "SingleIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon1) },

	}

	self:RegisterBinders(ViewModel, Binders)
end

function CommScreenerClassSItemView:OnClickedItemBtn()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)
end

return CommScreenerClassSItemView