---
--- Author: Administrator
--- DateTime: 2023-09-25 14:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local UIViewModel = require("UI/UIViewModel")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

---@class CommJumpWayItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field ImgArrow UFImage
---@field ImgItemBg UFImage
---@field ImgItemBgSelect UFImage
---@field ImgItemIcon UFImage
---@field TextQuestName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommJumpWayItemView = LuaClass(UIView, true)

function CommJumpWayItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.ImgArrow = nil
	--self.ImgItemBg = nil
	--self.ImgItemBgSelect = nil
	--self.ImgItemIcon = nil
	--self.TextQuestName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommJumpWayItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommJumpWayItemView:OnInit()

end

function CommJumpWayItemView:OnDestroy()
end

function CommJumpWayItemView:OnShow()
	local Params = self.Params

	if Params == nil then
		return
	end

	self:UpdateItem(Params.Data)

end

function CommJumpWayItemView:OnHide()

end

function CommJumpWayItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickedGoBtn)
end

function CommJumpWayItemView:OnRegisterGameEvent()
end

function CommJumpWayItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.ViewModel

	if nil == self.ViewModel or not CommonUtil.IsA(self.ViewModel, UIViewModel) then
		return
	end

	local Binders = {
		{ "Icon", UIBinderSetImageBrush.New(self, self.ImgItemIcon)},
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgItemBgSelect)},
		{ "IconVisible", UIBinderSetIsVisible.New(self, self.ImgItemIcon) },
		{ "ArrowVisible", UIBinderSetIsVisible.New(self, self.ImgArrow) },
		{ "TextName", UIBinderSetText.New(self, self.TextQuestName)}
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function CommJumpWayItemView:UpdateItem(Data)
	if Data == nil then
		return
	end

	UIUtil.SetIsVisible(self.ImgItemIcon, Data.Icon ~= nil)
	UIUtil.SetIsVisible(self.ImgArrow, Data.ArrowVisible)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgItemIcon, Data.Icon)
	self.TextQuestName:SetText(Data.TextName)
	UIUtil.SetIsVisible(self.ImgItemBgSelect, Data.IsSelected)
end

-- function CommJumpWayItemView:OnSelectChanged(IsSelected)
-- 	UIUtil.SetIsVisible(self.ImgItemBgSelect, IsSelected)
-- end

function CommJumpWayItemView:OnClickedGoBtn()
	local Params = self.Params
	if Params and Params.Data and Params.Data.ClickItemCallback then
		Params.Data.ClickItemCallback(Params.Data.View, Params.Data)
	end

	if nil == self.ViewModel or not CommonUtil.IsA(self.ViewModel, UIViewModel) then
		return
	end

	if self.ViewModel.ClickItemCallback then
		self.ViewModel.ClickItemCallback(Params.Data.View, Params.Data)
	end
end

return CommJumpWayItemView