---
--- Author: xingcaicao
--- DateTime: 2023-08-04 10:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local CommPlayerDefine = require("Game/Common/Player/CommPlayerDefine")
local OperationUtil = require("Utils/OperationUtil")

local StateType = CommPlayerDefine.StateType
local StateIcon = CommPlayerDefine.StateIcon

---@class CommPlayerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnStart UFButton
---@field IconStart UFImage
---@field ImgLinkShellIdentify UFImage
---@field ImgOnlineStatus UFImage
---@field ImgStateIcon UFImage
---@field LinkShellPanel USizeBox
---@field PanelStart UFCanvasPanel
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field StateIconPanel USizeBox
---@field TextPlayerName URichTextBox
---@field TextStart UFTextBlock
---@field TextState UFTextBlock
---@field StyleType CommUIStyleType
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommPlayerItemView = LuaClass(UIView, true)

function CommPlayerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnStart = nil
	--self.IconStart = nil
	--self.ImgLinkShellIdentify = nil
	--self.ImgOnlineStatus = nil
	--self.ImgStateIcon = nil
	--self.LinkShellPanel = nil
	--self.PanelStart = nil
	--self.PlayerHeadSlot = nil
	--self.StateIconPanel = nil
	--self.TextPlayerName = nil
	--self.TextStart = nil
	--self.TextState = nil
	--self.StyleType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommPlayerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerHeadSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommPlayerItemView:OnInit()
	self.Binders = {
		{ "Name", 				UIBinderSetText.New(self, self.TextPlayerName) },

		{ "State", 				UIBinderSetText.New(self, self.TextState) },
		{ "StateType", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedSateType) },

		{ "OnlineStatusIcon",	UIBinderSetBrushFromAssetPath.New(self, self.ImgOnlineStatus) },
		{ "IdentifyIcon", 		UIBinderValueChangedCallback.New(self, nil, self.OnIdentifyIconChanged) },
	}

	self.BindersRoleVM = {
		{ "HeadInfo", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedHeadInfo) },
		{ "HeadFrameID", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedHeadFrameID) },
	}
end

function CommPlayerItemView:OnDestroy()

end

function CommPlayerItemView:OnShow()
	if nil ~= self.ViewModel and self.ViewModel.IsFriend and self.ViewModel.LaunchType == 2 and _G.LoginMgr:IsQQLogin() then
		local Cfg = OperationUtil.GetOperationChannelFuncConfig()
		if nil ~= Cfg and Cfg.IsEnableQQLaunchPrivileges == 0 then
			UIUtil.SetIsVisible(self.PanelStart, false)
		else
			self.TextStart:SetText(_G.LSTR(100004))
			UIUtil.ImageSetBrushFromAssetPath(self.IconStart, "PaperSprite'/Game/UI/Atlas/PersonInfo/Frames/UI_Profile_Icon_QQ2_png.UI_Profile_Icon_QQ2_png'")
			UIUtil.SetIsVisible(self.PanelStart, true, true)
		end
	else
		UIUtil.SetIsVisible(self.PanelStart, false)
	end
end

function CommPlayerItemView:OnHide()
	self.Params = nil
end

function CommPlayerItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnClickBtnStart)
end

function CommPlayerItemView:OnRegisterGameEvent()

end

function CommPlayerItemView:OnRegisterBinder()
	if self.Params == nil or self.Params.Data == nil then
		return
	end

	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)

	local RoleID = ViewModel.RoleID
	local RoleVM = _G.RoleInfoMgr:FindRoleVM(RoleID)
	if RoleVM then
		self.PlayerHeadSlot:SetBaseInfo(RoleID)

		self:RegisterBinders(RoleVM, self.BindersRoleVM)
	end
end

function CommPlayerItemView:OnValueChangedSateType(NewValue)
	NewValue = NewValue or StateType.None

	local Icon = StateIcon[NewValue]
	if string.isnilorempty(Icon) then
		UIUtil.SetIsVisible(self.StateIconPanel, false)
	else
		UIUtil.ImageSetBrushFromAssetPath(self.ImgStateIcon, Icon)
		UIUtil.SetIsVisible(self.StateIconPanel, true)
	end
end

function CommPlayerItemView:OnIdentifyIconChanged( IDIcon )
	if string.isnilorempty(IDIcon) then
		UIUtil.SetIsVisible(self.LinkShellPanel, false)
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.ImgLinkShellIdentify, IDIcon)
	UIUtil.SetIsVisible(self.LinkShellPanel, true)
end

function CommPlayerItemView:OnValueChangedHeadInfo(NewValue)
	if NewValue then
		self.PlayerHeadSlot:UpdateIcon()
	end
end

function CommPlayerItemView:OnValueChangedHeadFrameID(NewValue)
	self.PlayerHeadSlot:UpdateFrame()
end

function CommPlayerItemView:OnClickBtnStart()
	if _G.LoginMgr:IsQQLogin() then
		_G.AccountUtil.OpenUrl(LoginNewDefine.QQPrivilegeUrl, 1, false, true, "", false)
	end
end

return CommPlayerItemView