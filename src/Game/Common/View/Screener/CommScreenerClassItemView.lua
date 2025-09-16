---
--- Author: Administrator
--- DateTime: 2023-06-26 10:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class CommScreenerClassItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field HorizontalBox UHorizontalBox
---@field ImgIcon1 UFImage
---@field ImgIcon2 UFImage
---@field ImgIcon3 UFImage
---@field ImgIcon4 UFImage
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field ImgSelectTag UFImage
---@field PanelIcon UFCanvasPanel
---@field PanelNum UFCanvasPanel
---@field PanelSelect UFCanvasPanel
---@field PanelTitleIcon UFCanvasPanel
---@field SizeBox1 USizeBox
---@field SizeBox2 USizeBox
---@field SizeBox3 USizeBox
---@field SizeBox4 USizeBox
---@field TextName UFTextBlock
---@field TextName2 UFTextBlock
---@field TextName3 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommScreenerClassItemView = LuaClass(UIView, true)

function CommScreenerClassItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.HorizontalBox = nil
	--self.ImgIcon1 = nil
	--self.ImgIcon2 = nil
	--self.ImgIcon3 = nil
	--self.ImgIcon4 = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.ImgSelectTag = nil
	--self.PanelIcon = nil
	--self.PanelNum = nil
	--self.PanelSelect = nil
	--self.PanelTitleIcon = nil
	--self.SizeBox1 = nil
	--self.SizeBox2 = nil
	--self.SizeBox3 = nil
	--self.SizeBox4 = nil
	--self.TextName = nil
	--self.TextName2 = nil
	--self.TextName3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommScreenerClassItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommScreenerClassItemView:OnInit()

end

function CommScreenerClassItemView:OnDestroy()

end

function CommScreenerClassItemView:OnShow()

end

function CommScreenerClassItemView:OnHide()

end

function CommScreenerClassItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickedItemBtn)
end

function CommScreenerClassItemView:OnRegisterGameEvent()

end

function CommScreenerClassItemView:OnRegisterBinder()
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

		{ "MultipleItemVisible", UIBinderSetIsVisible.New(self, self.PanelTitleIcon) }, 
		{ "MultipleText", UIBinderSetText.New(self, self.TextName2) },
		{ "MultipleIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon3) },

		{ "NumberTextVisible", UIBinderSetIsVisible.New(self, self.PanelNum) }, 
		{ "NumberText", UIBinderSetText.New(self, self.TextName3) },
	}

	self:RegisterBinders(ViewModel, Binders)
end

function CommScreenerClassItemView:OnClickedItemBtn()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)

	local ViewModel = Params.Data
	if nil == ViewModel then return end
	ViewModel:SetSelected()
end

return CommScreenerClassItemView