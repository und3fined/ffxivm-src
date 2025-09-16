---
--- Author: anypkvcai
--- DateTime: 2022-01-23 15:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class Comm2FrameMView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Ben2Left CommBtnLView
---@field Btn1 CommBtnLView
---@field Btn2Right CommBtnLView
---@field Btn3Left CommBtnMView
---@field Btn3Mid CommBtnMView
---@field Btn3Right CommBtnMView
---@field ButtonClose UFButton
---@field FText_Title UFTextBlock
---@field NamedSlotChild UNamedSlot
---@field Panel2Btn UFCanvasPanel
---@field Panel3Btn UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field HideOnClick bool
---@field bAutoAddSpace bool
---@field Number of buttons CommFrameBtn
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Comm2FrameMView = LuaClass(UIView, true)

function Comm2FrameMView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Ben2Left = nil
	--self.Btn1 = nil
	--self.Btn2Right = nil
	--self.Btn3Left = nil
	--self.Btn3Mid = nil
	--self.Btn3Right = nil
	--self.ButtonClose = nil
	--self.FText_Title = nil
	--self.NamedSlotChild = nil
	--self.Panel2Btn = nil
	--self.Panel3Btn = nil
	--self.PopUpBG = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.HideOnClick = nil
	--self.bAutoAddSpace = nil
	--self.Number of buttons = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Comm2FrameMView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Ben2Left)
	self:AddSubView(self.Btn1)
	self:AddSubView(self.Btn2Right)
	self:AddSubView(self.Btn3Left)
	self:AddSubView(self.Btn3Mid)
	self:AddSubView(self.Btn3Right)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Comm2FrameMView:OnInit()
	self.ClickCloseCallback = nil
	self.PopUpBG:SetHideOnClick(self.HideOnClick)
end

function Comm2FrameMView:OnDestroy()

end

function Comm2FrameMView:OnShow()
	if(self.bAutoAddSpace == true) then
		UIUtil.AutoAddSpaceForTwoWords(self.FText_Title)
	end
end

function Comm2FrameMView:OnHide()

end

function Comm2FrameMView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonClose, self.OnClickButtonClose)
end

function Comm2FrameMView:OnRegisterGameEvent()

end

function Comm2FrameMView:OnRegisterBinder()

end

function Comm2FrameMView:OnClickButtonClose()
	if nil == self.ClickCloseCallback then
		self:Hide(self.ViewID)
	else
		self.ClickCloseCallback(self.View)
	end
end

function Comm2FrameMView:SetTitleText(Text)
	self.FText_Title:SetText(Text)
end

function Comm2FrameMView:SetClickCloseCallback(View, CallBack)
	self.View = View
	self.ClickCloseCallback = CallBack
end
return Comm2FrameMView