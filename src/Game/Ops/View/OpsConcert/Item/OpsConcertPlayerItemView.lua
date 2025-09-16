---
--- Author: usakizhang
--- DateTime: 2025-03-25 22:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local TeamDefine = require("Game/Team/TeamDefine")
local InviteItemBgEnum = TeamDefine.InviteItemBgEnum
---@class OpsConcertPlayerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgBg UFImage
---@field ImgOnlineStatus UFImage
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field ProfSlot CommPlayerSimpleJobSlotView
---@field TextLocation UFTextBlock
---@field TextPlayerName URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsConcertPlayerItemView = LuaClass(UIView, true)

function OpsConcertPlayerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.ImgBg = nil
	--self.ImgOnlineStatus = nil
	--self.PlayerHeadSlot = nil
	--self.ProfSlot = nil
	--self.TextLocation = nil
	--self.TextPlayerName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsConcertPlayerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerHeadSlot)
	self:AddSubView(self.ProfSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsConcertPlayerItemView:OnInit()
	self.Binders = {
		{ "ProfID", UIBinderValueChangedCallback.New(self, nil, self.OnProfIDChanged) },
	}
	---绑定角色VM
	self.RoleVMBinders = {
		{ "MapResName", 		UIBinderSetText.New(self, self.TextLocation) },
		{ "OnlineStatusIcon", 	UIBinderSetImageBrush.New(self, self.ImgOnlineStatus) },
		{ "Name", 		UIBinderSetText.New(self, self.TextPlayerName) },
	}
end

function OpsConcertPlayerItemView:OnDestroy()

end

function OpsConcertPlayerItemView:OnShow()

end

function OpsConcertPlayerItemView:OnHide()

end

function OpsConcertPlayerItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickChatBtn)
end

function OpsConcertPlayerItemView:OnRegisterGameEvent()

end

function OpsConcertPlayerItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	--职业
	self.ProfSlot:SetParams({ Data = ViewModel.ProfInfoVM })
	--玩家头像
	self.PlayerHeadSlot:SetInfo(self:GetRoleID())
	self:RegisterBinders(ViewModel, self.Binders)
	local RVM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true) 
	if RVM then
		self:RegisterBinders(RVM, self.RoleVMBinders)
	end
end

function OpsConcertPlayerItemView:GetRoleID()
	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	return ViewModel.RoleID
end

function OpsConcertPlayerItemView:OnProfIDChanged(ProfID)
	if nil == ProfID then
		return
	end

    local ProfFunc = RoleInitCfg:FindFunction(ProfID)
	if nil == ProfFunc then
		return
	end

	local Bg = InviteItemBgEnum[ProfFunc]
	if string.isnilorempty(Bg) then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.ImgBg, Bg)
end

function OpsConcertPlayerItemView:OnClickChatBtn()
	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	_G.ChatMgr:GoToPlayerChatView(ViewModel.RoleID)
end
return OpsConcertPlayerItemView