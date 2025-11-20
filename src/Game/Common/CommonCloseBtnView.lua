--
-- Author: anypkvcai
-- Date: 2020-09-15 19:15:35
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")

local CommonCloseBtnView = LuaClass(UIView, true)

---@class CommonCloseBtnView
function CommonCloseBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn_Close = nil
	--self.IconClose = nil
	--self.PanelBright = nil
	--self.SkillHandleCloseBtn = nil
	--self.AnimIn = nil
	--self.AnimNewPressed = nil
	--self.AnimNewReleased = nil
	--self.AnimPressed = nil
	--self.BtnBright = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.View = nil
	self.Callback = nil
end

function CommonCloseBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SkillHandleCloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonCloseBtnView:OnInit()

end

function CommonCloseBtnView:OnDestroy()

end

function CommonCloseBtnView:OnShow()
end

function CommonCloseBtnView:OnHide()

end

function CommonCloseBtnView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn_Close, self.OnClickButtonClose)
	--UIUtil.AddOnPressedEvent(self, self.Btn_Close, self.OnPressedButtonClose)
end

function CommonCloseBtnView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.TutorialCloseBorderView, self.OnClickButtonClose)
end

function CommonCloseBtnView:OnRegisterTimer()

end

function CommonCloseBtnView:OnRegisterBinder()

end

function CommonCloseBtnView:OnClickButtonClose()
	if nil ~= self.Callback then
		self.Callback(self.View)
	else
		UIViewMgr:HideView(self.ViewID)
	end
	_G.SettingsHandleMgr:SwitchOpenCloseVirtualCursor(false)
end

--function CommonCloseBtnView:OnPressedButtonClose()
--	self:PlayAnimation(self.AnimPressed)
--end

function CommonCloseBtnView:SetCallback(View, Callback)
	self.View = View
	self.Callback = Callback
end

return CommonCloseBtnView