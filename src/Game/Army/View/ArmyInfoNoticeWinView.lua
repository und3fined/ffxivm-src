---
--- Author: daniel
--- DateTime: 2023-03-18 10:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType
local LSTR = _G.LSTR
---@class ArmyInfoNoticeWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG CommMsgTipsView
---@field BtnCancel CommBtnLView
---@field BtnSave CommBtnLView
---@field MulitiLineInputBox CommMultilineInputBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyInfoNoticeWinView = LuaClass(UIView, true)

function ArmyInfoNoticeWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnSave = nil
	--self.MulitiLineInputBox = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.SaveCallback = nil
end

function ArmyInfoNoticeWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.MulitiLineInputBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyInfoNoticeWinView:OnInit()
	self.MulitiLineInputBox:SetCallback(self, self.OnTextChanged)
end

function ArmyInfoNoticeWinView:OnDestroy()

end

function ArmyInfoNoticeWinView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	self.BtnCancel:UpdateImage(CommBtnColorType.Normal)
	self.BtnSave:UpdateImage(CommBtnColorType.Recommend)
	-- LSTR string:取消
	self.BtnCancel.TextContent:SetText(LSTR(910083))
	-- LSTR string:保存更改
	self.BtnSave.TextContent:SetText(LSTR(910043))
	self.MulitiLineInputBox:SetMaxNum(Params.MaxNum)
	self.MulitiLineInputBox:SetHintText(Params.HintText)
	self.MulitiLineInputBox:SetText(Params.Text)
	self.MulitiLineInputBox.EnableLineBreak = true
	self.BtnSave:SetIsEnabled(false)
	self.SaveCallback = Params.Callback
end

function ArmyInfoNoticeWinView:OnHide()

end

function ArmyInfoNoticeWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickedSave)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.Hide)
end

function ArmyInfoNoticeWinView:OnRegisterGameEvent()

end

function ArmyInfoNoticeWinView:OnRegisterBinder()

end

function ArmyInfoNoticeWinView:OnTextChanged( Text )
	local Params = self.Params
	if nil == Params then
		return
	end
	self.BtnSave:SetIsEnabled(Text ~= Params.Text)
end

function ArmyInfoNoticeWinView:OnClickedSave()
	local Text = self.MulitiLineInputBox:GetText()
	if self.SaveCallback then
		self.SaveCallback(Text)
	end
	self:Hide()
end

return ArmyInfoNoticeWinView