--
-- Author: enqingchen
-- Date: 2020-12-10 20:04:06
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")

local MessageBoxView = LuaClass(UIView, true)

local LSTR = _G.LSTR

function MessageBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AcceptBtn = nil
	--self.BtnSwitcher = nil
	--self.ButtonCancel = nil
	--self.ButtonConfirm = nil
	--self.ButtonOK = nil
	--self.CheckBoxNotAgain = nil
	--self.CommonMaskPanel = nil
	--self.CommonPlaySound_UIBP = nil
	--self.KeepBtn = nil
	--self.MsgBgPanel = nil
	--self.RefuseBtn = nil
	--self.RichText_Line01 = nil
	--self.RichText_Line02 = nil
	--self.TwoBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MessageBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AcceptBtn)
	self:AddSubView(self.ButtonCancel)
	self:AddSubView(self.ButtonConfirm)
	self:AddSubView(self.ButtonOK)
	self:AddSubView(self.CheckBoxNotAgain)
	self:AddSubView(self.CommonMaskPanel)
	self:AddSubView(self.CommonPlaySound_UIBP)
	self:AddSubView(self.KeepBtn)
	self:AddSubView(self.MsgBgPanel)
	self:AddSubView(self.RefuseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MessageBoxView:OnInit()
	_G.UIUtil.AddOnClickedEvent(self, self.ButtonCancel.Button, self.OnClickBtnCancel)
	_G.UIUtil.AddOnClickedEvent(self, self.ButtonConfirm.Button, self.OnClickBtnConfirm)
	_G.UIUtil.AddOnClickedEvent(self, self.ButtonOK.Button, self.OnClickBtnConfirm)
end

function MessageBoxView:OnDestroy()

end

function MessageBoxView:OnShow()
	self.RichText_Line01:SetText("")
	self.RichText_Line02:SetText("")
	self.MsgBgPanel:SetTitleText(LSTR(10063)) --10063("注 意")
	if nil ~= self.Params then 
		if nil ~= self.Params.Content then
			self.RichText_Line01:SetText(self.Params.Content)
		end

		if nil ~= self.Params.ConfirmBtnText then
			self.ButtonConfirm:SetText(self.Params.ConfirmBtnText)
		end
		if nil ~= self.Params.CancelBtnText then
			self.BtnSwitcher:SetActiveWidgetIndex(1)
			self.ButtonCancel:SetText(self.Params.CancelBtnText)
		else
			self.BtnSwitcher:SetActiveWidgetIndex(2)
		end
		if self.Params.HideCheckBoxNotAgain then
			_G.UIUtil.SetIsVisible(self.CheckBoxNotAgain, false)
		end

		self.ConfirmBtnCallback = self.Params.ConfirmBtnCallback
		self.CancelBtnCallback = self.Params.CancelBtnCallback

		self.MsgBgPanel:SetHideOnClick(self.Params.HideOnClick)
	end
end

function MessageBoxView:OnHide()

end

function MessageBoxView:OnRegisterUIEvent()

end

function MessageBoxView:OnRegisterGameEvent()

end

function MessageBoxView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
	
	local ShowTime = self.Params.ShowTime
	--local EndTime = self.AniFadeOut:GetEndTime()
	--local DelayTime = math.max(ShowTime - EndTime, 0)
	if (ShowTime ~= nil and tonumber(ShowTime) ~= nil) then
		self.CountDownEndTime = _G.TimeUtil.GetServerTime() + ShowTime
		self:RegisterTimer(self.OnTimer, 0, 1, 0)
	end
end

function MessageBoxView:OnTimer()
	if (self.CountDownEndTime ~= nil) then
		local LeftTime = self.CountDownEndTime - _G.TimeUtil.GetServerTime()
		LeftTime = LeftTime > 0 and LeftTime or 0
		self.RichText_Line02:SetText(string.format("(%d秒)"), LeftTime)
		if (LeftTime == 0) then
			self:Hide()
		end
	end
end

function MessageBoxView:OnRegisterBinder()

end

function MessageBoxView:OnClickBtnConfirm()
	if nil ~= self.ConfirmBtnCallback then
		self.ConfirmBtnCallback()
	end
	_G.UIViewMgr:HideView(self.ViewID)
end

function MessageBoxView:OnClickBtnCancel()
	if nil ~= self.CancelBtnCallback then
		self.CancelBtnCallback()
	end
	_G.UIViewMgr:HideView(self.ViewID)
end

return MessageBoxView