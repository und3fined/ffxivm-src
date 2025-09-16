--
-- Author: haialexzhou
-- Date: 2020-11-19 10:52:03
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")

local MessageBox_TempView = LuaClass(UIView, true)

function MessageBox_TempView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichText_Line01 = nil
	--self.Common_CloseBtn_UIBP = nil
	--self.BtnSwitcher = nil
	--self.ButtonCancel = nil
	--self.ButtonConfirm = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MessageBox_TempView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_CloseBtn_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MessageBox_TempView:OnInit()
	self.RichText_Line01:SetText("x, 确定要这样吗？")
end

function MessageBox_TempView:OnDestroy()

end

function MessageBox_TempView:OnShow()
	if nil ~= self.RichText_Line01 then
		self.RichText_Line01:SetText(self.Params.Content)
	end
	self.OkBtnCallback = self.Params.OkBtnCallback
end

function MessageBox_TempView:OnHide()

end

function MessageBox_TempView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonCancel, self.OnClickBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.ButtonConfirm, self.OnClickBtnConfirm)
end

function MessageBox_TempView:OnRegisterGameEvent()

end

function MessageBox_TempView:OnRegisterTimer()

end

function MessageBox_TempView:OnRegisterBinder()

end

function MessageBox_TempView:OnClickBtnCancel()
	UIViewMgr:HideView(self.ViewID)
end

function MessageBox_TempView:OnClickBtnConfirm()
	if (self.OkBtnCallback) then
		self.OkBtnCallback()
	end
	UIViewMgr:HideView(self.ViewID)
end

return MessageBox_TempView