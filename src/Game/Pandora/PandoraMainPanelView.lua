---
--- Author: saintzhao
--- DateTime: 2024-11-12 16:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")
local UIUtil = require("Utils/UIUtil")
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")
local UIViewID = require("Define/UIViewID")

---@class PandoraMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Common_PopUpBG_UIBP CommonPopUpBGView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PandoraMainPanelView = LuaClass(UIView, true)

function PandoraMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Common_PopUpBG_UIBP = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PandoraMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_PopUpBG_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PandoraMainPanelView:OnInit()
	self.AppId = ""
	self.TimerID = nil
end

function PandoraMainPanelView:OnDestroy()

end

function PandoraMainPanelView:OnShow()
	self.AppId = self.Params.AppId
	-- if self.AppId == _G.PandoraMgr.FaceSlapAppId then
	-- 	if nil == self.TimerID then
	-- 		self:SetViewVisibility(false)
	-- 		self:OpenAppWithWidget()
	-- 		self.TimerID = self:RegisterTimer( function()
	-- 			self:SetViewVisibility(true)
	-- 		end, 5, 1, 1)
	-- 	end
	-- else
	-- 	self:OpenAppWithWidget()
	-- end

	self:OpenAppWithWidget()
	self:OnInputActionTypeChange()
end

function PandoraMainPanelView:SetViewVisibility(bVisible)
	if bVisible then
		UIUtil.SetIsVisible(self, true, true)
	else
		UIUtil.SetIsVisible(self, false)
	end
end

function PandoraMainPanelView:OpenAppWithWidget()
	local OpenArgs = self.Params.OpenArgs
	_G.FLOG_INFO("PandoraMainPanelView:OnShow, AppId: %s, OpenArgs: %s", self.AppId, OpenArgs)
	_G.PandoraMgr:OpenAppWithWidget(self, self.AppId, OpenArgs)
	local LinearColor = _G.UE.FLinearColor.FromHex("FFFFFF00")
	self.Common_PopUpBG_UIBP:SetColorAndOpacity(LinearColor)
end

function PandoraMainPanelView:OnHide()
	_G.FLOG_INFO("PandoraMainPanelView:OnHide, AppId: %s", self.AppId)
	_G.PandoraMgr:CloseApp(self.AppId)
	if nil ~= self.TimerID then
		self:UnRegisterTimer(self.TimerID)
		self.TimerID = nil
	end
	_G.SettingsHandleMgr:UnRegisterHandleKeyDownData(SettingsHandleDefine.HandleCustomActionType.SpeedSkill)
end

function PandoraMainPanelView:OnRegisterUIEvent()

end

function PandoraMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PandoraPayment, self.OnPandoraPayment)
	self:RegisterGameEvent(EventID.GamePadClose, self.OnGamePadClose)
	self:RegisterGameEvent(EventID.InputActionTypeChange, self.OnInputActionTypeChange)
end

function PandoraMainPanelView:OnRegisterBinder()

end

function PandoraMainPanelView:OnPandoraPayment(Params)
	if nil ~= Params then
		_G.PandoraMgr:InvokeMidasPay(Params, self)
	end
end

function PandoraMainPanelView:OnInputActionTypeChange(IsHandleAttached)
    if nil == IsHandleAttached then
		IsHandleAttached = _G.SettingsHandleMgr:GetIsHandleAttached()
	end
    if IsHandleAttached then
		_G.SettingsHandleMgr:RegisterHandleKeyDownData(SettingsHandleDefine.HandleCustomActionType.SpeedSkill)
	else
		_G.SettingsHandleMgr:UnRegisterHandleKeyDownData(SettingsHandleDefine.HandleCustomActionType.SpeedSkill)
	end
end

function PandoraMainPanelView:OnGamePadClose()
	_G.UIViewMgr:HideView(UIViewID.PandoraMainPanelView)
end

return PandoraMainPanelView