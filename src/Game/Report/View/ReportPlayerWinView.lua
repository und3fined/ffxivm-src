---
--- Author: xingcaicao
--- DateTime: 2023-05-06 21:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LSTR = _G.LSTR

---@class ReportPlayerWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field BtnCancel CommBtnLView
---@field BtnReport CommBtnLView
---@field CheckBox_1 CommSingleBoxView
---@field CheckBox_2 CommSingleBoxView
---@field CheckBox_3 CommSingleBoxView
---@field CheckBox_4 CommSingleBoxView
---@field CheckBox_5 CommSingleBoxView
---@field CommMulInputBox CommMultilineInputBoxView
---@field TextPlayerName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ReportPlayerWinView = LuaClass(UIView, true)

function ReportPlayerWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnReport = nil
	--self.CheckBox_1 = nil
	--self.CheckBox_2 = nil
	--self.CheckBox_3 = nil
	--self.CheckBox_4 = nil
	--self.CheckBox_5 = nil
	--self.CommMulInputBox = nil
	--self.TextPlayerName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ReportPlayerWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnReport)
	self:AddSubView(self.CheckBox_1)
	self:AddSubView(self.CheckBox_2)
	self:AddSubView(self.CheckBox_3)
	self:AddSubView(self.CheckBox_4)
	self:AddSubView(self.CheckBox_5)
	self:AddSubView(self.CommMulInputBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ReportPlayerWinView:OnInit()

end

function ReportPlayerWinView:OnDestroy()

end

function ReportPlayerWinView:OnShow()
	self.RoleVM = self.Params
	if nil == self.RoleVM then
		return
	end

	--玩家名
	self.TextPlayerName:SetText(self.RoleVM.Name or "")
end

function ReportPlayerWinView:OnHide()
	self.TextPlayerName:SetText("")
	self.CommMulInputBox:SetText("")

	self.CheckBox_1:SetChecked(false, false)
	self.CheckBox_2:SetChecked(false, false)
	self.CheckBox_3:SetChecked(false, false)
	self.CheckBox_4:SetChecked(false, false)
	self.CheckBox_5:SetChecked(false, false)
end

function ReportPlayerWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, 		self.OnClickButtonCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnReport, 		self.OnClickButtonReport)
end

function ReportPlayerWinView:OnRegisterGameEvent()

end

function ReportPlayerWinView:OnRegisterBinder()

end

function ReportPlayerWinView:GetOptionList()
	local Ret = {}

	for i = 1, 5 do
		local CheckBox = self["CheckBox_" .. i]
		if CheckBox and CheckBox:GetChecked() then
			table.insert(Ret, i)
		end
	end

	return Ret
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function ReportPlayerWinView:OnClickButtonCancel()
	self:Hide()
end

function ReportPlayerWinView:OnClickButtonReport()
	local OptionList = self:GetOptionList()
	if #OptionList <= 0 then
		MsgTipsUtil.ShowTips(LSTR(780010))
		return
	end

	MsgBoxUtil.ShowMsgBoxOneOpRight(nil, LSTR(780002), LSTR(780011))

	self:Hide()
end

return ReportPlayerWinView