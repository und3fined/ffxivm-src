---
--- Author: xingcaicao
--- DateTime: 2025-04-03 17:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local UIBinderSetText = require("Binder/UIBinderSetText")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

---@class LinkShellCreateActivityItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field SingleBox CommSingleBoxView
---@field TextDescribe UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellCreateActivityItemView = LuaClass(UIView, true)

function LinkShellCreateActivityItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.SingleBox = nil
	--self.TextDescribe = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellCreateActivityItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellCreateActivityItemView:OnInit()
	self.Binders = {
		{ "Icon", UIBinderSetImageBrush.New(self, self.ImgIcon) },
		{ "Name", UIBinderSetText.New(self, self.TextDescribe) },
	}
end

function LinkShellCreateActivityItemView:OnDestroy()

end

function LinkShellCreateActivityItemView:OnShow()

end

function LinkShellCreateActivityItemView:OnHide()

end

function LinkShellCreateActivityItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnToggleStateChanged)
end

function LinkShellCreateActivityItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.LinkShellCreateSelectedActIDsUpdate, self.OnGameEventSelectedActIDsUpdate)
end

function LinkShellCreateActivityItemView:OnRegisterBinder()
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

function LinkShellCreateActivityItemView:UpdateSingleBoxState( )
	local EntryVM = self.ViewModel
	if EntryVM then
		local b = LinkShellVM:IsInCreateSelectedAct(EntryVM.ID)
		self.SingleBox:SetChecked(b, false)
	end
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function LinkShellCreateActivityItemView:OnGameEventSelectedActIDsUpdate( )
	self:UpdateSingleBoxState()
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function LinkShellCreateActivityItemView:OnToggleStateChanged(ToggleButton, State)
	local EntryVM = self.ViewModel
	if nil == EntryVM then
		return
	end

	local IsSuc = LinkShellVM:UpdateCreateSelectedActIDs(EntryVM.ID)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if IsChecked and not IsSuc then
		self.SingleBox:SetChecked(false, false)
	end
end

return LinkShellCreateActivityItemView