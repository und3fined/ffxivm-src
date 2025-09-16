---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local UIBinderSetText = require("Binder/UIBinderSetText")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

---@class LinkShellActivityItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field SingleBox CommSingleBoxView
---@field TextDescribe UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellActivityItemView = LuaClass(UIView, true)

function LinkShellActivityItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.SingleBox = nil
	--self.TextDescribe = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellActivityItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellActivityItemView:OnInit()
	self.Binders = {
		{ "Icon", UIBinderSetImageBrush.New(self, self.ImgIcon) },
		{ "Name", UIBinderSetText.New(self, self.TextDescribe) },
	}
end

function LinkShellActivityItemView:OnDestroy()

end

function LinkShellActivityItemView:OnShow()
	self:UpdateSingleBoxState()
end

function LinkShellActivityItemView:OnHide()

end

function LinkShellActivityItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnToggleStateChanged)
end

function LinkShellActivityItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.LinkShellMgSelectedActIDsUpdate, self.OnGameEventSelectedActIDsUpdate)
end

function LinkShellActivityItemView:OnRegisterBinder()
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

function LinkShellActivityItemView:UpdateSingleBoxState( )
	local EntryVM = self.ViewModel
	if EntryVM then
		local b = LinkShellVM:IsInMgSelectedAct(EntryVM.ID)
		self.SingleBox:SetChecked(b, false)
	end
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function LinkShellActivityItemView:OnGameEventSelectedActIDsUpdate( )
	self:UpdateSingleBoxState()
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function LinkShellActivityItemView:OnToggleStateChanged(ToggleButton, State)
	local EntryVM = self.ViewModel
	if nil == EntryVM then
		return
	end

	local IsSuc = LinkShellVM:UpdateMgSelectedActIDs(EntryVM.ID)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if IsChecked and not IsSuc then
		self.SingleBox:SetChecked(false, false)
	end
end

return LinkShellActivityItemView