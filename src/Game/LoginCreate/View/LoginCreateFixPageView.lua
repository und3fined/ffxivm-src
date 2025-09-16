---
--- Author: chriswang
--- DateTime: 2023-10-18 10:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginCreateFixPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack LoginCreateBackPageView
---@field BtnClose UFButton
---@field BtnStart UFButton
---@field ButtonDownloadPak UButton
---@field MorePage LoginCreateMorePageView
---@field ProgressPage LoginCreateProgressPageView
---@field TextStart UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimUIHidden UWidgetAnimation
---@field AnimUIShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateFixPageView = LuaClass(UIView, true)

function LoginCreateFixPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnClose = nil
	--self.BtnStart = nil
	--self.ButtonDownloadPak = nil
	--self.MorePage = nil
	--self.ProgressPage = nil
	--self.TextStart = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimUIHidden = nil
	--self.AnimUIShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateFixPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.MorePage)
	self:AddSubView(self.ProgressPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateFixPageView:OnInit()

end

function LoginCreateFixPageView:OnDestroy()

end

function LoginCreateFixPageView:OnShow()
	_G.LoginUIMgr.FixPageView = self

	if _G.LoginUIMgr.bFirstShowRaceGenderView then
		self:PlayAnimation(self.AnimDelayIn)
	else
		self:PlayAnimation(self.AnimInCode)
	end
end

function LoginCreateFixPageView:OnHide()
	_G.LoginUIMgr.FixPageView = nil
end

function LoginCreateFixPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBack.BtnBack, self.OnBackBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnNextBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnBtnCloseClick)
end

function LoginCreateFixPageView:OnRegisterGameEvent()

end

function LoginCreateFixPageView:OnRegisterBinder()

end

function LoginCreateFixPageView:OnBackBtnClick()
	FLOG_INFO("LoginCreateFixPageView:OnBackBtnClick")
	_G.LoginUIMgr:SwitchToPrePhase()
end

function LoginCreateFixPageView:OnNextBtnClick()
	FLOG_INFO("LoginCreateFixPageView:OnNextBtnClick")

	local function NewComformCallback()
		_G.LoginUIMgr:SwitchToNextPhase()
		self:PlayAnimation(self.AnimBtnStart)
	end
	if _G.LoginUIMgr:IsShowFaceTips() then
		local Content = _G.LSTR(980102)
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(980022), Content, NewComformCallback, nil, _G.LSTR(980007), _G.LSTR(980035), nil)
	else
		NewComformCallback()
	end
end

function LoginCreateFixPageView:OnBtnCloseClick()
	_G.LoginUIMgr:ExitCreateRole()
end

function LoginCreateFixPageView:OnPhaseChage(CurPhase)
	local PhaseConfig = _G.LoginUIMgr:GetCurPhaseConfig()
	if PhaseConfig then
		if PhaseConfig.Title then
			self.BtnBack.TextTitle:SetText(PhaseConfig.Title)
		end

		if PhaseConfig.NextBtnText then
			self.TextStart:SetText(PhaseConfig.NextBtnText)
		else
			self.TextStart:SetText(_G.LSTR(980001))
		end

		--幻想药模式下，选择种族页面不显示返回
		self.BtnBack.ImgBtn:SetVisibility(_G.UE.ESlateVisibility.SelfHitTestInvisible)
		self.BtnBack.BtnBack:SetVisibility(_G.UE.ESlateVisibility.Visible)
		if _G.LoginMapMgr.CurLoginMapType == _G.LoginMapType.Fantasia then
			if CurPhase == _G.LoginRolePhase.RaceGender then
				self.BtnBack.ImgBtn:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
				self.BtnBack.BtnBack:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
			end
		end

		-- local CurPhase = _G.LoginUIMgr:GetCurRolePhase()
		if CurPhase == _G.LoginRolePhase.Birthday or CurPhase == _G.LoginRolePhase.God then
			UIUtil.SetIsVisible(self.MorePage, false)
		else
			UIUtil.SetIsVisible(self.MorePage, true)
			
			if CurPhase == _G.LoginRolePhase.Prof
				or CurPhase == _G.LoginRolePhase.CustomAppearance then
				UIUtil.SetIsVisible(self.MorePage.SpacerBar, true)
			else
				UIUtil.SetIsVisible(self.MorePage.SpacerBar, false)
			end

			if CurPhase > _G.LoginRolePhase.Tribe and CurPhase < _G.LoginRolePhase.Birthday then	--选择外貌、自定义外貌
				UIUtil.SetIsVisible(self.MorePage.BtnSetting, false)


				if CurPhase == _G.LoginRolePhase.Avatar then
					UIUtil.SetIsVisible(self.MorePage.BtnAction, false)
					UIUtil.SetIsVisible(self.MorePage.BtnHideUI, true, true)
				else
					UIUtil.SetIsVisible(self.MorePage.BtnAction, true, true)
					UIUtil.SetIsVisible(self.MorePage.BtnHideUI, false)
				end

				UIUtil.SetIsVisible(self.MorePage.BtnGaze, true, true)
				UIUtil.SetIsVisible(self.MorePage.BtnTieUpHair, true, true)
				UIUtil.SetIsVisible(self.MorePage.BtnShare, false)--true, true)

				UIUtil.SetIsVisible(self.MorePage.BtnMore, true, true)
				_G.LoginUIMgr.IsFixPageClickBtnMore = false
				UIUtil.SetIsVisible(self.MorePage.PanelMoreTips, false)

			else
				UIUtil.SetIsVisible(self.MorePage.BtnAction, true, true)
				UIUtil.SetIsVisible(self.MorePage.BtnGaze, true, true)
				UIUtil.SetIsVisible(self.MorePage.BtnMore, true, true)

				UIUtil.SetIsVisible(self.MorePage.BtnSetting, false)
				UIUtil.SetIsVisible(self.MorePage.BtnTieUpHair, false)
				UIUtil.SetIsVisible(self.MorePage.BtnShare, false)
				UIUtil.SetIsVisible(self.MorePage.BtnHideUI, false)

				_G.LoginUIMgr.IsFixPageClickBtnMore = false
				UIUtil.SetIsVisible(self.MorePage.PanelMoreTips, false)

				_G.LoginAvatarMgr:TieUpHair(false) -- 关闭束发，束发功能只在有束发按钮界面生效
			end
		end
	end
end

-- function LoginCreateFixPageView:EnableStartBtn(IsEnable)
-- 	self.BtnStart:SetIsEnable(IsEnable)
-- end

return LoginCreateFixPageView