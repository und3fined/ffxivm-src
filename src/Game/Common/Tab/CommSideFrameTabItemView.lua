---
--- Author: ccppeng
--- DateTime: 2025-02-26 15:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local  CommSideFrameTabItemVM = require("Game/Common/Tab/CommSideFrameTabItemVM")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
---@class CommSideFrameTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconSelect UFImage
---@field ImgNormal UFImage
---@field RedDot CommonRedDotView
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommSideFrameTabItemView = LuaClass(UIView, true)
local LSTR = _G.LSTR
function CommSideFrameTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconSelect = nil
	--self.ImgNormal = nil
	--self.RedDot = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommSideFrameTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommSideFrameTabItemView:OnInit()

end

function CommSideFrameTabItemView:OnDestroy()

end

function CommSideFrameTabItemView:OnShow()

end

function CommSideFrameTabItemView:OnHide()

end

function CommSideFrameTabItemView:OnRegisterUIEvent()

end

function CommSideFrameTabItemView:OnRegisterGameEvent()
	UIUtil.AddOnClickedEvent(self,  self.ToggleBtn, self.OnBtnSelectClick)
end
function CommSideFrameTabItemView:OnBtnSelectClick()
	self.ViewModel:OnVMSelect()
end
function CommSideFrameTabItemView:OnRegisterBinder()
	if self.Params ~= nil  then
		self.ViewModel = self.Params
	else
		self.ViewModel = CommSideFrameTabItemVM.New()
	end
	local Binders = {
		{ "IconIMG", UIBinderSetImageBrush.New(self, self.IconSelect, true) },
		{ "IconIMG", UIBinderSetImageBrush.New(self, self.ImgNormal, true) },
		{ "bEnable",UIBinderSetIsVisible.New(self, self)},
		{ "RedDotsStyle",UIBinderValueChangedCallback.New(self, nil, self.OnRedDotsRedDotsStyleChange)},
		{ "UpdateRedDot",UIBinderValueChangedCallback.New(self, nil, self.OnRedDotsVisibleChange)},
		{ "RedDotName",UIBinderValueChangedCallback.New(self, nil, self.OnRedDotNameChange)},
		{ "bSelect",UIBinderSetIsChecked.New(self, self.ToggleBtn, true)},
		{ "bSelect",UIBinderValueChangedCallback.New(self, nil, self.OnUpdateToSelect)  },
	}

	self:RegisterBinders(self.ViewModel, Binders)
	self.ViewModel:InitBindProperty()
end

function CommSideFrameTabItemView:OnRedDotsVisibleChange(NewValue,OldValue)
	self.RedDot:SetRedDotUIIsShow(self.ViewModel.bRedDotsVisible)
end

function CommSideFrameTabItemView:OnRedDotsRedDotsStyleChange(NewValue,OldValue)
	self.RedDot:SetStyle(NewValue)
	self.RedDot:SetRedDotText(LSTR(10030))
end

function CommSideFrameTabItemView:OnRedDotNameChange(String)
	if string.isnilorempty(String) then
		return
	end
	self.RedDot:SetRedDotNameByString(String)
end

function CommSideFrameTabItemView:OnUpdateToSelect(NewValue,OldValue)
	self.ViewModel:OnUpdateToSelect(NewValue,OldValue)
end

return CommSideFrameTabItemView