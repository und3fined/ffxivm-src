---
--- Author: Administrator
--- DateTime: 2023-03-30 16:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MentorMgr = require("Game/Mentor/MentorMgr")

local LSTR = _G.LSTR

---@class MentorUpdateNoticePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommBtnLView
---@field SingleBoxDontShow CommSingleBoxView
---@field TextContent URichTextBox
---@field TextTitle UFTextBlock
---@field TextWarning URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MentorUpdateNoticePanelView = LuaClass(UIView, true)

function MentorUpdateNoticePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.SingleBoxDontShow = nil
	--self.TextContent = nil
	--self.TextTitle = nil
	--self.TextWarning = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MentorUpdateNoticePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.SingleBoxDontShow)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MentorUpdateNoticePanelView:OnInit()
end

function MentorUpdateNoticePanelView:OnDestroy()

end

function MentorUpdateNoticePanelView:TranslatedText()
	self.SingleBoxDontShow:SetText(LSTR(760038))
	self.TextTitle:SetText(LSTR(760035))
	self.TextContent:SetText(LSTR(760036))
	self.TextWarning:SetText(LSTR(760037))
	self.BtnClose:SetText(LSTR(760040))
end

function MentorUpdateNoticePanelView:OnShow()
	self:TranslatedText()
	self.SingleBoxDontShow:SetChecked(false)
end

function MentorUpdateNoticePanelView:OnHide()

end

function MentorUpdateNoticePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClose.Button, self.OnClickBtnCancel)
end

function MentorUpdateNoticePanelView:OnRegisterGameEvent()

end

function MentorUpdateNoticePanelView:OnRegisterBinder()

end

function MentorUpdateNoticePanelView:OnClickBtnCancel()
	if self.SingleBoxDontShow:GetChecked() then
		MentorMgr:UnpromptedMentorUpdate()
	end
	self:Hide()
end

return MentorUpdateNoticePanelView