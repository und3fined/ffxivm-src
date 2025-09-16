---
--- Author: jususchen
--- DateTime: 2024-08-12 19:05
--- Description
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PWorldExitTaskWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field LeftBtnOp CommBtnLView
---@field Panel2Btns UFHorizontalBox
---@field RichTextBoxDesc_1 URichTextBox
---@field RichTextExtraHint URichTextBox
---@field RightBtnOp CommBtnLView
---@field SpacerMid USpacer
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldExitTaskWinView = LuaClass(UIView, true)

function PWorldExitTaskWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.LeftBtnOp = nil
	--self.Panel2Btns = nil
	--self.RichTextBoxDesc_1 = nil
	--self.RichTextExtraHint = nil
	--self.RightBtnOp = nil
	--self.SpacerMid = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldExitTaskWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.LeftBtnOp)
	self:AddSubView(self.RightBtnOp)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldExitTaskWinView:OnInit()
	self.BG:SetTitleText(_G.LSTR(1320171))
	self.LeftBtnOp:SetText(_G.LSTR(1320172))
	self.RightBtnOp:SetText(_G.LSTR(1320173))
end

function PWorldExitTaskWinView:OnShow()
	if self.Params == nil then
		return
	end

	local TextTitle = self.Params.TextTitle or ""
	local TextContent = self.Params.TextContent or ""
	self.RichTextBoxDesc_1:SetText(TextTitle)
	self.RichTextExtraHint:SetText(TextContent)
end

function PWorldExitTaskWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.LeftBtnOp, function ()
		if self.Params then
			if type(self.Params.CancelCallback) == "function" then
				self.Params.CancelCallback()
			end
		end
		self:Hide()
	end)

	UIUtil.AddOnClickedEvent(self,self.RightBtnOp, function ()
		if self.Params then
			if type(self.Params.OKCallback) == "function" then
				self.Params.OKCallback()
			end
		end
		self:Hide()
	end)
end

return PWorldExitTaskWinView