---
--- Author: chriswang
--- DateTime: 2023-10-17 09:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local HeadPortraitCfg = require("TableCfg/HeadPortraitCfg")
local RaceCfg = require("TableCfg/RaceCfg")
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")

local PersonPortraitHeadDefine = require("Game/PersonPortraitHead/PersonPortraitHeadDefine")
local LoginCreateDefaultRolePath = "Texture2D'/Game/Assets/Icon/Head/UI_Icon_Head_MR_Blue.UI_Icon_Head_MR_Blue'"
---@class LoginCreateAccountItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCreate UFButton
---@field ImgAvatar UFImage
---@field PanelRoleCreate UFCanvasPanel
---@field TextNameCheck UFTextBlock
---@field TextNameUncheck UFTextBlock
---@field ToggleBtnRole UToggleButton
---@field AnimChecked UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateAccountItemView = LuaClass(UIView, true)

function LoginCreateAccountItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCreate = nil
	--self.ImgAvatar = nil
	--self.PanelRoleCreate = nil
	--self.TextNameCheck = nil
	--self.TextNameUncheck = nil
	--self.ToggleBtnRole = nil
	--self.AnimChecked = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateAccountItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateAccountItemView:OnInit()
	UIUtil.SetIsVisible(self.CommPlayerHeadSlot_UIBP.ImgBkg, false)
	self.CommPlayerHeadSlot_UIBP:SetIsHideFrame(true)
end

function LoginCreateAccountItemView:OnDestroy()

end

function LoginCreateAccountItemView:OnShow()
	if self.Params and self.Params.Data then
		local RoleSimple = self.Params.Data
		if RoleSimple.RoleID then

			UIUtil.SetIsVisible(self.ToggleBtnRole, true, true)
			UIUtil.SetIsVisible(self.PanelRoleCreate, false)

			self.TextNamecheck:SetText(RoleSimple.Name)
			self.TextNameUncheck:SetText(RoleSimple.Name)

			local VM =_G.RoleInfoMgr:FindRoleVM(RoleSimple.RoleID)
			if VM then
				VM:UpdateVM(RoleSimple)
				self.CommPlayerHeadSlot_UIBP:SetInfo(RoleSimple.RoleID)
				self.CommPlayerHeadSlot_UIBP:SetClickEnable(false)

				local HeadInfo = VM.HeadInfo
				-- FLOG_INFO("pcw HeadInfo.HeadType:%s", tostring(HeadInfo.HeadType))
				local Type = HeadInfo.HeadType or PersonPortraitHeadDefine.HeadType.Default
				if Type == PersonPortraitHeadDefine.HeadType.Custom then
					UIUtil.SetIsVisible(self.CommPlayerHeadSlot_UIBP.IconSilhouette, false)
					UIUtil.SetIsVisible(self.CommPlayerHeadSlot_UIBP.ImageIcon, true)
				else
					UIUtil.SetIsVisible(self.CommPlayerHeadSlot_UIBP.ImageIcon, false)

					UIUtil.SetIsVisible(self.CommPlayerHeadSlot_UIBP.IconSilhouette, true)
					UIUtil.ImageSetBrushFromAssetPath(self.CommPlayerHeadSlot_UIBP.IconSilhouette, LoginCreateDefaultRolePath)
				end
				UIUtil.SetIsVisible(self.CommPlayerHeadSlot_UIBP.SpecialFrameSize, false)
			end
		else
			UIUtil.SetIsVisible(self.ToggleBtnRole, false)
			UIUtil.SetIsVisible(self.PanelRoleCreate, true)
			self.TextCreate:SetText(_G.LSTR(980100)) -- "新增角色"
		end
	end

end

function LoginCreateAccountItemView:OnHide()

end

function LoginCreateAccountItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnRole, self.OnToggleBtnRoleClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCreate, self.OnBtnCreateClick)

end

function LoginCreateAccountItemView:OnRegisterGameEvent()

end

function LoginCreateAccountItemView:OnRegisterBinder()

end

function LoginCreateAccountItemView:OnSelectChanged(IsSelected)
	if IsSelected then
		self.ToggleBtnRole:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
		self:PlayAnimation(self.AnimChecked)
	else
		self:StopAllAnimations()
		self.ToggleBtnRole:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
		self:PlayAnimation(self.AnimUnchecked)
	end
end

function LoginCreateAccountItemView:OnToggleBtnRoleClick(ToggleButton, ButtonState)
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)
end

function LoginCreateAccountItemView:OnBtnCreateClick()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	
	local NodeInfo = _G.LoginMgr:GetMapleNodeInfo(_G.LoginMgr:GetWorldID())
	if NodeInfo and NodeInfo.State == LoginNewDefine.ServerStateEnum.Full then
		_G.MsgTipsUtil.ShowTipsByID(120007)
		return
	end

	Adapter:OnItemClicked(self, Params.Index)
end

return LoginCreateAccountItemView