---
--- Author: Administrator
--- DateTime: 2023-10-08 10:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PlayStyleCommFrameSView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonClose UFButton
---@field NamedSlotChild UNamedSlot
---@field PopUpBG CommonPopUpBGView
---@field RichTextBox_Title URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field TextTitle text
---@field HideOnClick bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PlayStyleCommFrameSView = LuaClass(UIView, true)

function PlayStyleCommFrameSView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonClose = nil
	--self.NamedSlotChild = nil
	--self.PopUpBG = nil
	--self.RichTextBox_Title = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.TextTitle = nil
	--self.HideOnClick = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PlayStyleCommFrameSView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PlayStyleCommFrameSView:OnInit()

end

function PlayStyleCommFrameSView:OnDestroy()

end

function PlayStyleCommFrameSView:OnShow()

end

function PlayStyleCommFrameSView:OnHide()

end

function PlayStyleCommFrameSView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonClose, self.OnButtonCloseClick)
end

function PlayStyleCommFrameSView:OnRegisterGameEvent()

end

function PlayStyleCommFrameSView:OnRegisterBinder()

end

function PlayStyleCommFrameSView:OnButtonCloseClick()
	local CloseCallback = self.CloseCallback
	if CloseCallback then
		CloseCallback()
	end
	self:Hide()
end

function PlayStyleCommFrameSView:SetBtnCloseEnable(bEnable)
	self.ButtonClose:SetIsEnabled(bEnable)
end

function PlayStyleCommFrameSView:SetTitle(TextTitle)
	if not TextTitle or type(TextTitle) ~= "string" then
		return
	end
	self.RichTextBox_Title:SetText(TextTitle)
end

function PlayStyleCommFrameSView:SetCloseCallback(Func)
	self.CloseCallback = Func
end

return PlayStyleCommFrameSView