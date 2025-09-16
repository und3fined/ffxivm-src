---
--- Author: xingcaicao
--- DateTime: 2023-03-21 19:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local COLOR_NORMAL = "828282FF"
local COLOR_SELECTED = "FFF4D0FF"

---@class CommDropDownListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FBtnItem UFButton
---@field IconPanel UFCanvasPanel
---@field ImgIcon UFImage
---@field ImgIcon2 UFImage
---@field ImgLine UFImage
---@field ImgPlayingIcon UFImage
---@field ImgSelect UFImage
---@field RedDot CommonRedDotView
---@field RedDot2 CommonRedDot2View
---@field TextContent UFTextBlock
---@field TextNew UFTextBlock
---@field TextQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommDropDownListItemView = LuaClass(UIView, true)

function CommDropDownListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FBtnItem = nil
	--self.IconPanel = nil
	--self.ImgIcon = nil
	--self.ImgIcon2 = nil
	--self.ImgLine = nil
	--self.ImgPlayingIcon = nil
	--self.ImgSelect = nil
	--self.RedDot = nil
	--self.RedDot2 = nil
	--self.TextContent = nil
	--self.TextNew = nil
	--self.TextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommDropDownListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommDropDownListItemView:OnInit()

end

function CommDropDownListItemView:OnDestroy()

end

function CommDropDownListItemView:OnShow()
	self:UpdateItem(self.Params)
end

function CommDropDownListItemView:OnHide()

end

function CommDropDownListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FBtnItem, self.OnBtnClick)
end

function CommDropDownListItemView:OnBtnClick()
	local IsSelect = true
	local Index
	local Adapter
	local VM
	if self.Params then
		Adapter = self.Params.Adapter
		Index = self.Params.Index
		VM = self.Params.Data
	end
	if VM then
		if VM.ClickFunc then
			IsSelect = VM.ClickFunc(VM)
		elseif VM.IsSelectedFunc then
			IsSelect = VM.IsSelectedFunc(VM)
		end
	end
	if Adapter and IsSelect then
		Adapter:OnItemClicked(self, Index)
	end
end

function CommDropDownListItemView:OnRegisterGameEvent()

end

function CommDropDownListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	if not self.ViewModel.IsItemVM then
		return
	end
	self.Binders = {
		{"Name", UIBinderSetText.New(self, self.TextContent)},
		{"TextNewStr", UIBinderSetText.New(self, self.TextNew)},
		{"IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
		{"RightIconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon2)},
		{"IsNew", UIBinderSetIsVisible.New(self, self.TextNew)},
		{"IsShowIcon", UIBinderSetIsVisible.New(self, self.ImgIcon)},
		{"IsShowRightIcon", UIBinderSetIsVisible.New(self, self.ImgIcon2)},
		{"IsShowRightPanel", UIBinderSetIsVisible.New(self, self.IconPanel)},
		{"IconPath", UIBinderValueChangedCallback.New(self, nil, self.OnIconUpdata)},
		{"RightIconPath", UIBinderValueChangedCallback.New(self, nil, self.OnRightIconUpdata)},
		{"IsNew", UIBinderValueChangedCallback.New(self, nil, self.OnIsNewUpdata)},
	}
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function CommDropDownListItemView:OnIconUpdata(IconPath)
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	if nil == IconPath then
		VM.IsShowIcon = false
	end
end

function CommDropDownListItemView:OnRightIconUpdata(RightIconPath)
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	if nil == RightIconPath then
		VM.IsShowRightIcon = false
		if not VM.IsNew then
			VM.IsShowRightPanel = false
		end
	end
end

function CommDropDownListItemView:OnIsNewUpdata(IsNew)
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	if nil == IsNew then
		if not VM.RightIconPath then
			VM.IsShowRightPanel = false
		end
	end
end

function CommDropDownListItemView:OnSelectChanged(IsSelected)
	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)

	if IsSelected then
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextContent, COLOR_SELECTED)
	else
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextContent, COLOR_NORMAL)
	end
end

function CommDropDownListItemView:UpdateItem(Params)
	if nil == Params then
		return
	end

	local Index = Params.Index
	local Adapter = Params.Adapter
	local Data = Params.Data

	--- 发现有其他蓝图引用下拉列表Item，保持适配原有逻辑
	if Data and Data.IsItemVM then
		UIUtil.SetIsVisible(self.ImgLine, Index < Adapter:GetNum())
		return
	end

	self.TextContent:SetText(Data.Name)
	local IconPath = Data.IconPath
	if nil ~= IconPath then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, IconPath)
	end

	local RightIconPath = Data.RightIconPath
	if nil ~= RightIconPath then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon2, IconPath)
	end

	local IsNew = Data.IsNew

	local TextNewStr = Data.TextNewStr
	if nil ~= TextNewStr then
		self.TextNew:SetText(Data.TextNewStr)
	end

	UIUtil.SetIsVisible(self.ImgIcon, nil ~= IconPath)
	UIUtil.SetIsVisible(self.ImgIcon2, nil ~= RightIconPath)
	UIUtil.SetIsVisible(self.IconPanel, nil ~= RightIconPath or nil ~= IsNew )
	UIUtil.SetIsVisible(self.TextNew, IsNew)

	UIUtil.SetIsVisible(self.ImgLine, Index < Adapter:GetNum())
end

return CommDropDownListItemView