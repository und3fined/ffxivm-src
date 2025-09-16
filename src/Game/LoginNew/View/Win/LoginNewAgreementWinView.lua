---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:59
--- Description:
---

local UIView = require("UI/UIView")
local OverseaAgreementVM = require("Game/LoginNew/VM/OverseaAgreementVM")
local LoginDateUtils = require("Game/LoginNew/LoginDateUtils")
local LoginUtils = require("Game/LoginNew/LoginUtils")
local LuaClass = require("Core/LuaClass")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIUtil = require("Utils/UIUtil")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local AgreementCheckEnum = LoginNewDefine.AgreementCheckEnum
local LoginStrID = LoginNewDefine.LoginStrID

local LSTR = _G.LSTR

---@class LoginNewAgreementWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnStart CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field CommSingleBox CommSingleBoxView
---@field CommSingleBox2 CommSingleBoxView
---@field CommSingleBox3 CommSingleBoxView
---@field DropDownList1 CommDropDownListView
---@field DropDownList2 CommDropDownListView
---@field DropDownList3 CommDropDownListView
---@field DropDownList4 CommDropDownListView
---@field RichPrivacy URichTextBox
---@field RichUser URichTextBox
---@field TextFollowing UFTextBlock
---@field TextNote UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewAgreementWinView = LuaClass(UIView, true)

function LoginNewAgreementWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnStart = nil
	--self.Comm2FrameM_UIBP = nil
	--self.CommSingleBox = nil
	--self.CommSingleBox2 = nil
	--self.CommSingleBox3 = nil
	--self.DropDownList1 = nil
	--self.DropDownList2 = nil
	--self.DropDownList3 = nil
	--self.DropDownList4 = nil
	--self.RichPrivacy = nil
	--self.RichUser = nil
	--self.TextFollowing = nil
	--self.TextNote = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewAgreementWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnStart)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.CommSingleBox)
	self:AddSubView(self.CommSingleBox2)
	self:AddSubView(self.CommSingleBox3)
	self:AddSubView(self.DropDownList1)
	self:AddSubView(self.DropDownList2)
	self:AddSubView(self.DropDownList3)
	self:AddSubView(self.DropDownList4)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewAgreementWinView:OnInit()
	---@type OverseaAgreementVM
	self.OverseaAgreementVM = _G.ObjectPoolMgr:AllocObject(OverseaAgreementVM)

	local HyperLink1 = RichTextUtil.GetHyperlink(LSTR(LoginStrID.UserAgreement), 6, "#D5D5D5FF", nil, nil, nil, nil, nil)
	local NormalText1 = LSTR(LoginStrID.AgreeTo)
	local Text1 = string.format("%s %s", NormalText1, HyperLink1)
	self.RichUser:SetText(Text1)

	local HyperLink2 = RichTextUtil.GetHyperlink(LSTR(LoginStrID.PrivacyPolicy), 7, "#D5D5D5FF", nil, nil, nil, nil, nil)
	local NormalText2 = LSTR(LoginStrID.Acknowledge)
	local Text2 = string.format("%s %s", HyperLink2, NormalText2)
	self.RichPrivacy:SetText(Text2)

	self.Comm2FrameM_UIBP.FText_Title:SetText(LSTR(LoginStrID.Agreements))
	self.BtnStart.TextContent:SetText(LSTR(LoginStrID.ConfirmBtnStr))
	self.TextNote:SetText(LSTR(LoginStrID.AgeTips1))
	self.TextFollowing:SetText(LSTR(LoginStrID.IAgreeFollowing))

	------- TEST ---------
	local AchievementAwardTypeCfg = require("TableCfg/AchievementAwardTypeCfg")
	local AwardTypeAllCfg = AchievementAwardTypeCfg:FindAllCfg() or {}
	self.DropDownListData = {}
	table.sort(AwardTypeAllCfg, function(A, B) return A.Sort < B.Sort end )
	for i = 1, #AwardTypeAllCfg do
		table.insert(self.DropDownListData, { Type = AwardTypeAllCfg[i].ID , Name = AwardTypeAllCfg[i].AwardType } )
	end

	self.Binders = {
		--{ "AgreeAllAgreement", UIBinderSetIsDisabledState.New(self, self.BtnStart, true)},
		{ "AgreeAllAgreement", UIBinderSetIsVisible.New(self, self.BtnStart.ImgDisable, true)},
		{ "AgreeAllAgreement", UIBinderSetIsVisible.New(self, self.BtnStart.ImgNormal, true)},
		{ "AgreeAllAgreement", UIBinderSetIsChecked.New(self, self.CommSingleBox.ToggleButton)},
		{ "AgreeUserAgreement", UIBinderSetIsChecked.New(self, self.CommSingleBox2.ToggleButton)},
		{ "AgreePrivacyPolicy", UIBinderSetIsChecked.New(self, self.CommSingleBox3.ToggleButton)},
	}
end

function LoginNewAgreementWinView:OnDestroy()

end

function LoginNewAgreementWinView:OnShow()
	self.DropDownList1:UpdateItems(self.DropDownListData, 1)

	--- Date
	local Years = LoginDateUtils:GetYears()
	local Months = LoginDateUtils:GetMonths()
	local Days = LoginDateUtils:GetDays(self.OverseaAgreementVM.Month, self.OverseaAgreementVM.Year)
	self.DropDownList4:UpdateItems(Years, 1)
	self.DropDownList3:UpdateItems(Months, 1)
	self.DropDownList2:UpdateItems(Days, 1)
end

function LoginNewAgreementWinView:OnHide()

end

function LoginNewAgreementWinView:OnRegisterUIEvent()
	UIUtil.AddOnHyperlinkClickedEvent(self, self.RichUser, self.OnClickUserAgreement, nil)
	UIUtil.AddOnHyperlinkClickedEvent(self, self.RichPrivacy, self.OnClickPrivacyAgreement, nil)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList1, self.OnRegionListSelectionChanged)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList2, self.OnDayListSelectionChanged)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList3, self.OnMonthListSelectionChanged)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList4, self.OnYearListSelectionChanged)

	self.CommSingleBox:SetStateChangedCallback(self, self.OnStateChangedCallback, AgreementCheckEnum.All)
	self.CommSingleBox2:SetStateChangedCallback(self, self.OnStateChangedCallback, AgreementCheckEnum.UserAgreement)
	self.CommSingleBox3:SetStateChangedCallback(self, self.OnStateChangedCallback, AgreementCheckEnum.PrivacyPolicy)

	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnClickBtnStart)
end

function LoginNewAgreementWinView:OnRegisterGameEvent()

end

function LoginNewAgreementWinView:OnRegisterBinder()
	self:RegisterBinders(self.OverseaAgreementVM, self.Binders)
end

function LoginNewAgreementWinView:OnClickUserAgreement(_, LinkID)
	LoginUtils:OpenAgreementUrl(LinkID);
end

function LoginNewAgreementWinView:OnClickPrivacyAgreement(_, LinkID)
	LoginUtils:OpenAgreementUrl(LinkID);
end

function LoginNewAgreementWinView:OnRegionListSelectionChanged(Index, ItemData, ItemView, IsByClick)
	if Index ~= nil and self.DropDownListData[Index] ~= nil then

	end
end

function LoginNewAgreementWinView:OnDayListSelectionChanged(Index, ItemData, ItemView, IsByClick)
	if Index ~= nil and type(ItemData.Name) == "number" then
		self.OverseaAgreementVM.Day = ItemData.Name
	end
end

function LoginNewAgreementWinView:OnMonthListSelectionChanged(Index, ItemData, ItemView, IsByClick)
	if Index ~= nil and type(ItemData.Name) == "number" then
		self.OverseaAgreementVM.Month = ItemData.Name
		self:UpdateDays()
	end
end

function LoginNewAgreementWinView:OnYearListSelectionChanged(Index, ItemData, ItemView, IsByClick)
	if Index ~= nil and type(ItemData.Name) == "number" then
		self.OverseaAgreementVM.Year = ItemData.Name
		self:UpdateDays()
	end
end

function LoginNewAgreementWinView:OnStateChangedCallback(IsChecked, Type)
	if AgreementCheckEnum.All == Type then
		self.OverseaAgreementVM.AgreeAllAgreement = IsChecked
		self.OverseaAgreementVM.AgreeUserAgreement = IsChecked
		self.OverseaAgreementVM.AgreePrivacyPolicy = IsChecked
	elseif AgreementCheckEnum.UserAgreement == Type then
		self.OverseaAgreementVM.AgreeUserAgreement = IsChecked
		if IsChecked then
			if self.OverseaAgreementVM.AgreeUserAgreement == true and self.OverseaAgreementVM.AgreePrivacyPolicy == true then
				self.OverseaAgreementVM.AgreeAllAgreement = true
			end
		else
			if self.OverseaAgreementVM.AgreeUserAgreement == false or self.OverseaAgreementVM.AgreePrivacyPolicy == false then
				self.OverseaAgreementVM.AgreeAllAgreement = false
			end
		end
	elseif AgreementCheckEnum.PrivacyPolicy == Type then
		self.OverseaAgreementVM.AgreePrivacyPolicy = IsChecked
		if IsChecked then
			if self.OverseaAgreementVM.AgreeUserAgreement == true and self.OverseaAgreementVM.AgreePrivacyPolicy == true then
				self.OverseaAgreementVM.AgreeAllAgreement = true
			end
		else
			if self.OverseaAgreementVM.AgreeUserAgreement == false or self.OverseaAgreementVM.AgreePrivacyPolicy == false then
				self.OverseaAgreementVM.AgreeAllAgreement = false
			end
		end
	end
end

function LoginNewAgreementWinView:OnClickBtnStart()
	--MsgTipsUtil.ShowTips(LSTR(LoginStrID.DateUnfilled))

	if self.OverseaAgreementVM.AgreeAllAgreement then
		self:Hide()
	else
		MsgTipsUtil.ShowTips(LSTR(LoginStrID.ConfirmAgreement))
	end
end

function LoginNewAgreementWinView:UpdateDays()
	local AgreementVM = self.OverseaAgreementVM
	local DayLen = LoginDateUtils:GetDaysInMonth(AgreementVM.Month, AgreementVM.Year)
	--print("[LoginNewAgreementWinView:UpdateDays] ", DayLen, AgreementVM.Year, AgreementVM.Month, AgreementVM.Day)

	if DayLen < AgreementVM.Day then
		AgreementVM.Day = 1
	end
	local Days = LoginDateUtils:GetDays(AgreementVM.Month, AgreementVM.Year, DayLen)
	self.DropDownList2:UpdateItems(Days, AgreementVM.Day)
end

return LoginNewAgreementWinView