---
--- Author: daniel
--- DateTime: 2023-03-18 16:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ArmyDefine = require("Game/Army/ArmyDefine")
local GlobalCfgType = ArmyDefine.GlobalCfgType
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UTF8Util = require("Utils/UTF8Util")
local LSTR = _G.LSTR
local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType
local ProtoCS = require("Protocol/ProtoCS")
local ArmyMgr = require("Game/Army/ArmyMgr")

local GroupRecruitStatus = ProtoCS.GroupRecruitStatus

---@class ArmyInfoRecruitWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field BtnSave CommBtnLView
---@field MulitiLineInputBox CommMultilineInputBoxView
---@field RecruitTitle1 UFTextBlock
---@field RecruitTitle2 UFTextBlock
---@field TextContent1 UFTextBlock
---@field TextContent2 UFTextBlock
---@field TextNoPrivilege UFTextBlock
---@field ToggleBtnStart UToggleButton
---@field ToggleBtnStop UToggleButton
---@field ToggleGroupCheck UToggleGroup
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyInfoRecruitWinView = LuaClass(UIView, true)

--- 招募标语最小长度
local Slogin_Min_Limit = nil
--- 招募标语
local Slogin_Max_Limit = nil

local RecruitStatus = nil
local RecruitSlogan = nil
local bNormRecruitSlogan = false

function ArmyInfoRecruitWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnSave = nil
	--self.MulitiLineInputBox = nil
	--self.RecruitTitle1 = nil
	--self.RecruitTitle2 = nil
	--self.TextContent1 = nil
	--self.TextContent2 = nil
	--self.TextNoPrivilege = nil
	--self.ToggleBtnStart = nil
	--self.ToggleBtnStop = nil
	--self.ToggleGroupCheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyInfoRecruitWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.MulitiLineInputBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyInfoRecruitWinView:OnInit()
    self.MulitiLineInputBox:SetCallback(self, nil, self.OnSloginTextComitted)
	-- LSTR string:招募设置
	self.BG:SetTitleText(LSTR(910141))
end

function ArmyInfoRecruitWinView:OnDestroy()

end

function ArmyInfoRecruitWinView:OnShow()
	---固定文本设置
	-- LSTR string:招募状态
	self.RecruitTitle1:SetText(LSTR(910298))
	-- LSTR string:招募标语
	self.RecruitTitle2:SetText(LSTR(910301))
	-- LSTR string:公开招募
	self.TextContent1:SetText(LSTR(910299))
	-- LSTR string:停止公开招募
	self.TextContent2:SetText(LSTR(910300))
	-- LSTR string:公开招募
	self.TextNoPrivilege:SetText(LSTR(910299))

	UIUtil.SetIsVisible(self.MulitiLineInputBox, true, true)
	local Params = self.Params
	if nil == Params then
		return
	end
	self.BtnCancel:UpdateImage(CommBtnColorType.Normal)
	self.BtnSave:UpdateImage(CommBtnColorType.Recommend)
	Slogin_Min_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.RecruitSloganMinLimit)
    Slogin_Max_Limit = GroupGlobalCfg:GetValueByType(GlobalCfgType.RecruitSloganMaxLimit)
	RecruitStatus, RecruitSlogan = _G.ArmyMgr:GetRecruitInfo()
	if RecruitStatus then
		self.ToggleGroupCheck:SetCheckedIndex(RecruitStatus)
	end
	if RecruitSlogan then
		self.MulitiLineInputBox:SetText(RecruitSlogan)
	end
	self.MulitiLineInputBox:SetHintText(Params.HintText)
	local bOpen = RecruitStatus == GroupRecruitStatus.GROUP_RECRUIT_STATUS_Open
	--self.MulitiLineInputBox:SetIsEnabled(bOpen)
	self.MulitiLineInputBox.MaxNum = Slogin_Max_Limit
	self.MulitiLineInputBox:UpdateDescText()
	self.MulitiLineInputBox.EnableLineBreak = true
	self.Callback = Params.Callback
	self.IsHavePermission = Params.IsHavePermission
	self.MulitiLineInputBox:SetIsEnabled(self.IsHavePermission and bOpen)
	UIUtil.SetIsVisible(self.BtnCancel, self.IsHavePermission)
	UIUtil.SetIsVisible(self.ToggleGroupCheck, self.IsHavePermission)
	UIUtil.SetIsVisible(self.TextNoPrivilege, not self.IsHavePermission)
	if self.IsHavePermission then
		-- LSTR string:保存更改
		self.BtnSave:SetText(LSTR(910043))
		self.BtnSave:SetIsEnabled(false)
	else
		-- LSTR string:确定
		self.BtnSave:SetText(LSTR(910182))
		self.BtnSave:SetIsEnabled(true)
		if bOpen then
			self.ToggleBtnStart:SetCheckedState(_G.UE.EToggleButtonState.Locked)
			-- LSTR string:公开招募
			self.TextNoPrivilege:SetText(LSTR(910057))
		else
			self.ToggleBtnStop:SetCheckedState(_G.UE.EToggleButtonState.Locked)
			-- LSTR string:停止公开招募
			self.TextNoPrivilege:SetText(LSTR(910048))
		end
	end

	-- LSTR string:取  消
	self.BtnCancel:SetText(LSTR(910081))
	-- LSTR string:保存更改
	self.BtnSave:SetText(LSTR(910043))
end

function ArmyInfoRecruitWinView:OnHide()

end

function ArmyInfoRecruitWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickedSave)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.Hide)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupCheck, self.OnToggleGroupCheckChanged)
	--UIUtil.AddOnTextCommittedEvent(self, self.MulitiLineInputBox.FMultiLineInputText, self.OnSloginTextComitted)
end

function ArmyInfoRecruitWinView:OnRegisterGameEvent()

end

function ArmyInfoRecruitWinView:OnRegisterBinder()

end

function ArmyInfoRecruitWinView:OnToggleGroupCheckChanged(ToggleGroup, ToggleButton, Index, State)
	if UIUtil.IsToggleButtonChecked(State) then
		self:CheckIsEnabled()
	end
end

function ArmyInfoRecruitWinView:OnSloginTextComitted(Text)
	bNormRecruitSlogan = false
	self:CheckIsEnabled(Text)
end

function ArmyInfoRecruitWinView:CheckIsEnabled(Text)
	local RecruitSloganText = Text or self.MulitiLineInputBox:GetText()
	local Params = self.Params
	if nil == Params then
		return
	end
	if not self.IsHavePermission then
		return
	end
	local Index = self.ToggleGroupCheck:GetCheckedIndex()
	local Text = self.MulitiLineInputBox:GetText()
	local bOpen = Index == GroupRecruitStatus.GROUP_RECRUIT_STATUS_Open
	self.MulitiLineInputBox:SetIsEnabled(bOpen)
	---查询文本是否合法（敏感词）
	ArmyMgr:CheckSensitiveText(RecruitSloganText, function( IsLegal )
		if IsLegal then
			bNormRecruitSlogan = true
		else
			bNormRecruitSlogan = false
			-- LSTR string:招募标语不可使用！
			MsgTipsUtil.ShowTips(LSTR(910138))
		end
		if (Index ~= RecruitStatus or Text ~= RecruitSlogan) and bNormRecruitSlogan then
			self.BtnSave:SetIsEnabled(true)
		else
			self.BtnSave:SetIsEnabled(false)
		end
	end)
	-- if (Index ~= RecruitStatus or Text ~= RecruitSlogan) and bNormRecruitSlogan then
	-- 	self.BtnSave:SetIsEnabled(true)
	-- else
	-- 	self.BtnSave:SetIsEnabled(false)
	-- end
end

function ArmyInfoRecruitWinView:OnClickedSave()
	if not self.IsHavePermission then
		self:Hide()
		return
	end
	if not bNormRecruitSlogan then
		-- LSTR string:招募标语不可使用！
		MsgTipsUtil.ShowTips(LSTR(910138))
		return
	end
	local Text = self.MulitiLineInputBox:GetText()
	-- if Text == "" then
	-- LSTR string:提示
	-- 	MsgBoxUtil.ShowMsgBoxOneOpRight(self, LSTR(910144), LSTR(910137), nil, LSTR(910182))
	-- 	return
	-- end
	local Length = UTF8Util.Len(Text)
	local Index = self.ToggleGroupCheck:GetCheckedIndex()
	local bOpen = Index == GroupRecruitStatus.GROUP_RECRUIT_STATUS_Open
	if bOpen then
		if Length < Slogin_Min_Limit or Length > Slogin_Max_Limit then
			-- LSTR string:招募标语长度限制%d-%d个字符
			local Message = string.format(LSTR(910139), Slogin_Min_Limit, Slogin_Max_Limit)
			MsgTipsUtil.ShowTips(Message)
			return
		end
	else
		---关闭不做最小判断
		if Length > Slogin_Max_Limit then
			-- LSTR string:招募标语长度限制%d个字符
			local Message = string.format(LSTR(910140), Slogin_Max_Limit)
			MsgTipsUtil.ShowTips(Message)
			return
		end
	end
	if self.Callback then
		self.Callback(Text, self.ToggleGroupCheck:GetCheckedIndex())
		self.Callback = nil
	end
	self:Hide()
end

return ArmyInfoRecruitWinView