---
--- Author: anypkvcai
--- DateTime: 2022-04-29 15:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class Comm2FrameSView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Ben2Left CommBtnLView
---@field Btn1 CommBtnLView
---@field Btn2Right CommBtnLView
---@field ButtonClose UFButton
---@field FText_Title UFTextBlock
---@field NamedSlotChild UNamedSlot
---@field Panel2Btn UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field HideOnClick bool
---@field bAutoAddSpace bool
---@field Number of buttons CommFrameBtn
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Comm2FrameSView = LuaClass(UIView, true)

function Comm2FrameSView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Ben2Left = nil
	--self.Btn1 = nil
	--self.Btn2Right = nil
	--self.ButtonClose = nil
	--self.FText_Title = nil
	--self.NamedSlotChild = nil
	--self.Panel2Btn = nil
	--self.PopUpBG = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.HideOnClick = nil
	--self.bAutoAddSpace = nil
	--self.Number of buttons = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Comm2FrameSView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Ben2Left)
	self:AddSubView(self.Btn1)
	self:AddSubView(self.Btn2Right)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Comm2FrameSView:OnInit()
	self.PopUpBG:SetHideOnClick(self.HideOnClick)
end

function Comm2FrameSView:OnDestroy()
end

function Comm2FrameSView:OnShow()
	if(self.bAutoAddSpace == true) then
		UIUtil.AutoAddSpaceForTwoWords(self.FText_Title)
	end
end

function Comm2FrameSView:OnHide()

end

function Comm2FrameSView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonClose, self.OnClickButtonClose)
end

function Comm2FrameSView:OnRegisterGameEvent()

end

function Comm2FrameSView:OnRegisterBinder()

end

function Comm2FrameSView:OnClickButtonClose()
	self:Hide(self.ViewID)
end

function Comm2FrameSView:SetTitleText(Text)
	self.FText_Title:SetText(Text)
end

return Comm2FrameSView