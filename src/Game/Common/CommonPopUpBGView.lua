--
-- Author: anypkvcai
-- Date: 2020-11-23 15:31:54
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")

---@class CommonPopUpBGView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonMask UFButton
---@field ImageMask UImage
---@field HideOnClick bool
---@field Alpha float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonPopUpBGView = LuaClass(UIView, true)

function CommonPopUpBGView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonMask = nil
	--self.ImageMask = nil
	--self.HideOnClick = nil
	--self.Alpha = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.View = nil
	self.Callback = nil
end

function CommonPopUpBGView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonPopUpBGView:OnInit()

end

function CommonPopUpBGView:OnDestroy()

end

function CommonPopUpBGView:OnShow()
	UIUtil.SetIsVisible(self.ImageMask, true)
end

function CommonPopUpBGView:OnHide()
	UIUtil.SetIsVisible(self.ImageMask, false)
end

function CommonPopUpBGView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonMask, self.OnClickButtonMask)
end

function CommonPopUpBGView:OnRegisterGameEvent()

end

function CommonPopUpBGView:OnRegisterTimer()

end

function CommonPopUpBGView:OnRegisterBinder()

end

function CommonPopUpBGView:OnClickButtonMask()
	if nil ~= self.Callback then
		self.Callback(self.View)
	end

	if self.HideOnClick then
		self:Hide()
	end
end

function CommonPopUpBGView:SetCallback(View, Callback)
	self.View = View
	self.Callback = Callback
end

function CommonPopUpBGView:SetHideOnClick(HideOnClick)
	self.HideOnClick = HideOnClick == true
end

return CommonPopUpBGView