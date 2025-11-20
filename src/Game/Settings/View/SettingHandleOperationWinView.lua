---
--- Author: kanohchen
--- DateTime: 2025-06-03 20:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SettingHandleOperationWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingHandleOperationWinView = LuaClass(UIView, true)

function SettingHandleOperationWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameM_UIBP = nil
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingHandleOperationWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingHandleOperationWinView:OnInit()
	self.Comm2FrameM_UIBP:SetTitleText(_G.LSTR(110080))
	self.Text:SetText(_G.LSTR(110081))
	self.Comm2FrameM_UIBP.Btn1:SetButtonText(_G.LSTR(110032))
end

function SettingHandleOperationWinView:OnDestroy()

end

function SettingHandleOperationWinView:OnShow()
	UIUtil.SetIsVisible(self.Comm2FrameM_UIBP.Btn1.ProBarLongPress, false)
end

function SettingHandleOperationWinView:OnHide()

end

function SettingHandleOperationWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Comm2FrameM_UIBP.Btn1.Button, self.OnClickButtonClose)
end

function SettingHandleOperationWinView:OnRegisterGameEvent()

end

function SettingHandleOperationWinView:OnRegisterBinder()

end

function  SettingHandleOperationWinView:OnClickButtonClose()
	if nil == self.ClickCloseCallback then
		self:Hide(self.ViewID)
	else
		self.ClickCloseCallback(self.View)
	end
end

return SettingHandleOperationWinView