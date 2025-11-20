---
--- Author: anypkvcai
--- DateTime: 2022-01-23 15:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIDefine = require("Define/UIDefine")

---@class Comm2FrameLView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Ben2Left CommBtnLView
---@field Btn1 CommBtnLView
---@field Btn2Right CommBtnLView
---@field Btn3Left CommBtnLView
---@field Btn3Mid CommBtnLView
---@field Btn3Right CommBtnLView
---@field ButtonClose UFButton
---@field FText_Title UFTextBlock
---@field NamedSlotChild UNamedSlot
---@field Panel2Btn UFCanvasPanel
---@field Panel3Btn UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field SkillHandleCloseBtn SkillHandleCloseBtnView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field HideOnClick bool
---@field bAutoAddSpace bool
---@field NameOfBtnType CommFrameBtn
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Comm2FrameLView = LuaClass(UIView, true)

function Comm2FrameLView:Ctor()
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
	--self.SkillHandleCloseBtn = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.HideOnClick = nil
	--self.bAutoAddSpace = nil
	--self.NameOfBtnType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Comm2FrameLView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Ben2Left)
	self:AddSubView(self.Btn1)
	self:AddSubView(self.Btn2Right)
	self:AddSubView(self.Btn3Left)
	self:AddSubView(self.Btn3Mid)
	self:AddSubView(self.Btn3Right)
	self:AddSubView(self.PopUpBG)
	self:AddSubView(self.SkillHandleCloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Comm2FrameLView:OnInit()
	self.PopUpBG:SetHideOnClick(self.HideOnClick)
end

function Comm2FrameLView:OnDestroy()
	self.CloseCallback = nil
	self.CloseCallbackWidget = nil
end

function Comm2FrameLView:OnShow()
	if(self.bAutoAddSpace == true) then
		UIUtil.AutoAddSpaceForTwoWords(self.FText_Title)
	end
end

function Comm2FrameLView:OnHide()

end

function Comm2FrameLView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ButtonClose, self.OnClickButtonClose)
end

function Comm2FrameLView:OnRegisterGameEvent()

end

function Comm2FrameLView:OnRegisterBinder()

end

function Comm2FrameLView:OnClickButtonClose()
	if self.CloseCallback then
		self.CloseCallback(self.CloseCallbackWidget)
		return
	end
	if self.ViewID == _G.UIViewID.CraftingLogShopWin then
		_G.UIViewMgr:HideView(self.ViewID, true)
		return
	end
	if self.ViewID == _G.UIViewID.BagTidyWin then
		return
	end
	self:Hide(self.ViewID)
end

function Comm2FrameLView:SetTitleText(Text)
	self.FText_Title:SetText(Text)
end

function Comm2FrameLView:SetCloseCallback(Widget, CloseCallback)
	self.CloseCallback = CloseCallback
	self.CloseCallbackWidget = Widget
end

--- @params NameOfBtnType UIDefine.NameOfBtnType
function Comm2FrameLView:ChangeBtnShowByType(NameOfBtnType)
	local BtnShowType = UIDefine.NameOfBtnType
	UIUtil.SetIsVisible(self.Btn1, false)
	UIUtil.SetIsVisible(self.Panel2Btn, false)
	UIUtil.SetIsVisible(self.Panel3Btn, false)

	if NameOfBtnType == BtnShowType.Btn1 then
		UIUtil.SetIsVisible(self.Btn1, true)
	elseif NameOfBtnType == BtnShowType.Btn2 then
		UIUtil.SetIsVisible(self.Panel2Btn, true)
	elseif NameOfBtnType == BtnShowType.Btn3 then
		UIUtil.SetIsVisible(self.Panel3Btn, true)
	end

	FLOG_INFO("Comm2FrameMView:ChangeBtnShowByType(%s)" , NameOfBtnType)
end

return Comm2FrameLView