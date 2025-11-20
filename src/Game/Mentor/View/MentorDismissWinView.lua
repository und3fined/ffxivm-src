---
--- Author: Administrator
--- DateTime: 2025-08-13 16:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local EToggleButtonState = _G.UE.EToggleButtonState
local LSTR = _G.LSTR

---@class MentorDismissWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field CheckBox CommSingleBoxView
---@field Text1 UFTextBlock
---@field Text2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MentorDismissWinView = LuaClass(UIView, true)

function MentorDismissWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.CheckBox = nil
	--self.Text1 = nil
	--self.Text2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MentorDismissWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.CheckBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MentorDismissWinView:OnInit()

end

function MentorDismissWinView:OnDestroy()

end

function MentorDismissWinView:OnShow()
	local Params = self.Params
	if Params == nil then
		return 
	end
	local Title = Params.Title or ""
	local ContentText = Params.ContentText or ""
	local HintText = Params.HintText or ""
	self.LeftBtnCB = Params.LeftBtnCB
	self.CloseBtnCB = Params.CloseBtnCB
	self.RightBtnCB = Params.RightBtnCB
	self.CheckBox:SetText(LSTR(760053))
	self.BG:SetTitleText(Title)
	self.Text1:SetText(ContentText)
	self.Text2:SetText(HintText)
	self.BG.Btn2Right:SetBtnName(Params.RightBtnText or "")
    self.BG.Ben2Left:SetBtnName(Params.LeftBtnText or "")
	self.BG.Ben2Left:SetIsDisabledState(true)
	UIUtil.SetToggleButtonState(self.CheckBox.ToggleButton, EToggleButtonState.Unchecked)
end

function MentorDismissWinView:OnHide()

end

function MentorDismissWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BG.ButtonClose, self.OnClickBtnCancel)
	UIUtil.AddOnStateChangedEvent(self, self.CheckBox.ToggleButton, self.OnCheckBoxStateChange )
	UIUtil.AddOnClickedEvent(self, self.BG.Btn2Right, self.OnClickedBtnRight)
    UIUtil.AddOnClickedEvent(self, self.BG.Ben2Left, self.OnClickedBtnLeft)
end

function MentorDismissWinView:OnRegisterGameEvent()

end

function MentorDismissWinView:OnRegisterBinder()

end

function MentorDismissWinView:OnClickedBtnLeft()
	if self.LeftBtnCB ~= nil then
		self.LeftBtnCB(self)
	end
end

function MentorDismissWinView:OnClickedBtnRight()
	if self.RightBtnCB ~= nil then
		self.RightBtnCB(self)
	end
end

function MentorDismissWinView:OnClickBtnCancel()
	if self.CloseBtnCB ~= nil then
		self.CloseBtnCB(self)
	end
end

function MentorDismissWinView:OnCheckBoxStateChange(ToggleButton, State)
	local IsChecked = not UIUtil.IsToggleButtonChecked(State)
	self.BG.Ben2Left:SetIsDisabledState(IsChecked)
end


return MentorDismissWinView