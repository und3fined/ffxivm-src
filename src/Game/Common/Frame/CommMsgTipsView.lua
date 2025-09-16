---
--- Author: enqingchen
--- DateTime: 2022-03-28 14:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommMsgTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field NamedSlotChild UNamedSlot
---@field PopUpBG CommonPopUpBGView
---@field RichTextBox_Title URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field TextTitle text
---@field HideOnClick bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommMsgTipsView = LuaClass(UIView, true)

function CommMsgTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.NamedSlotChild = nil
	--self.PopUpBG = nil
	--self.RichTextBox_Title = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.TextTitle = nil
	--self.HideOnClick = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommMsgTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommMsgTipsView:OnInit()
	self.PopUpBG:SetHideOnClick(self.HideOnClick)
end

function CommMsgTipsView:OnDestroy()

end

function CommMsgTipsView:OnShow()

end

function CommMsgTipsView:OnHide()

end

function CommMsgTipsView:OnRegisterUIEvent()

end

function CommMsgTipsView:OnRegisterGameEvent()

end

function CommMsgTipsView:OnRegisterBinder()

end

function CommMsgTipsView:SetCallback(View, Callback)
	self.PopUpBG:SetCallback(View, Callback)
end

function CommMsgTipsView:SetHideOnClick(HideOnClick)
	self.PopUpBG:SetHideOnClick(HideOnClick)
end

function CommMsgTipsView:SetTitleText(Text)
	self.RichTextBox_Title:SetText(Text)
end

return CommMsgTipsView