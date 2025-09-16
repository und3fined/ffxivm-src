---
--- Author: anypkvcai
--- DateTime: 2022-05-17 14:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class Comm2FrameXSView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonClose UFButton
---@field NamedSlotChild UNamedSlot
---@field RichTextBox_Title URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field TextTitle text
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Comm2FrameXSView = LuaClass(UIView, true)

function Comm2FrameXSView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonClose = nil
	--self.NamedSlotChild = nil
	--self.RichTextBox_Title = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Comm2FrameXSView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Comm2FrameXSView:OnInit()

end

function Comm2FrameXSView:OnDestroy()

end

function Comm2FrameXSView:OnShow()

end

function Comm2FrameXSView:OnHide()

end

function Comm2FrameXSView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonClose, self.OnClickButtonClose)
end

function Comm2FrameXSView:OnRegisterGameEvent()

end

function Comm2FrameXSView:OnRegisterBinder()

end

function Comm2FrameXSView:OnClickButtonClose()
	self:Hide(self.ViewID)
end

return Comm2FrameXSView