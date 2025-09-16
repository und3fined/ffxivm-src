---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class FriendGroupManageTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelect UFImage
---@field PanelAdd UFCanvasPanel
---@field PanelGroup UFCanvasPanel
---@field TextAdd UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FriendGroupManageTabItemView = LuaClass(UIView, true)

function FriendGroupManageTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect = nil
	--self.PanelAdd = nil
	--self.PanelGroup = nil
	--self.TextAdd = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FriendGroupManageTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FriendGroupManageTabItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "ID", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedID) },
	}

	self.TextAdd:SetText(_G.LSTR(30046)) -- "新增分组"
end

function FriendGroupManageTabItemView:OnDestroy()

end

function FriendGroupManageTabItemView:OnShow()

end

function FriendGroupManageTabItemView:OnHide()

end

function FriendGroupManageTabItemView:OnRegisterUIEvent()

end

function FriendGroupManageTabItemView:OnRegisterGameEvent()

end

function FriendGroupManageTabItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function FriendGroupManageTabItemView:OnValueChangedID(NewValue)
	local IsAdd = NewValue == nil
	UIUtil.SetIsVisible(self.PanelGroup, not IsAdd)
	UIUtil.SetIsVisible(self.PanelAdd, IsAdd)
end

function FriendGroupManageTabItemView:OnSelectChanged(IsSelected)
	local IsNotAdd = (self.ViewModel or {}).ID ~= nil
	UIUtil.SetIsVisible(self.ImgSelect, IsNotAdd and IsSelected)
end

return FriendGroupManageTabItemView