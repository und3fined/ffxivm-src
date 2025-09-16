---
--- Author: Administrator
--- DateTime: 2024-11-18 11:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class PVPOptionListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAction CommBtnSView
---@field RichTextDesc URichTextBox
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPOptionListItemView = LuaClass(UIView, true)

function PVPOptionListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAction = nil
	--self.RichTextDesc = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPOptionListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAction)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPOptionListItemView:OnInit()
	self.Binders = {
		{ "Title", UIBinderSetText.New(self, self.TextTitle) },
		{ "Desc", UIBinderSetText.New(self, self.RichTextDesc) },
		{ "IsShowBtn", UIBinderSetIsVisible.New(self, self.BtnAction, false, true) },
		{ "IsDone", UIBinderValueChangedCallback.New(self, nil, self.OnIsDoneChanged) },
	}
end

function PVPOptionListItemView:OnDestroy()

end

function PVPOptionListItemView:OnShow()

end

function PVPOptionListItemView:OnHide()

end

function PVPOptionListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAction, self.OnClickBtnAction)
end

function PVPOptionListItemView:OnRegisterGameEvent()

end

function PVPOptionListItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then return end

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	self:RegisterBinders(ViewModel, self.Binders)
end

function PVPOptionListItemView:OnClickBtnAction()
	local Params = self.Params
	if Params == nil then return end

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	local Callback = ViewModel.Callback
	if Callback then
		Callback()
	end
end

function PVPOptionListItemView:OnIsDoneChanged(NewValue, OldValue)
	if NewValue then
		self.BtnAction:SetIsDoneState(NewValue, _G.LSTR(130044))
	else
		self.BtnAction:SetText(_G.LSTR(130043))
		self.BtnAction:SetIsRecommendState(true)
	end
end

return PVPOptionListItemView