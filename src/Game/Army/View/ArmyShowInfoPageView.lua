---
--- Author: daniel
--- DateTime: 2023-03-07 16:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ArmyDefine = require("Game/Army/ArmyDefine")
local PersonInfoMgr = require("Game/PersonInfo/PersonInfoMgr")
local UIViewMgr = require("UI/UIViewMgr")
local CommonUtil = require("Utils/CommonUtil")
local FLinearColor = _G.UE.FLinearColor


local LSTR = _G.LSTR
---@class ArmyShowInfoPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ArmyBadgeItem ArmyBadgeItemView
---@field BtnLeaderInfo UFButton
---@field BtnReport UFButton
---@field ImgBadge UFImage
---@field ImgFlagBG UFImage
---@field ImgLine01 UFImage
---@field ImgLine02 UFImage
---@field PanelArmyName UFCanvasPanel
---@field PanelLeader UFCanvasPanel
---@field AnimIn UWidgetAnimation
---@field AnimUpdate UWidgetAnimation
---@field Styles ArmyShowInfoStyle
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyShowInfoPageView = LuaClass(UIView, true)

local GrandCompanyTypeStyle = 
{
	[ArmyDefine.GrandCompanyType.HeiWo] = 2,
	[ArmyDefine.GrandCompanyType.ShuangShe] = 1,
	[ArmyDefine.GrandCompanyType.HengHui] = 2,
}

local ArmyFlagTextColors = ArmyDefine.ArmyFlagTextColors

local NewStyles = 
{
	[1] = ArmyFlagTextColors.Dark,
	[2] = ArmyFlagTextColors.Nomal,
}

local RecursionDepth1 = 0

function ArmyShowInfoPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ArmyBadgeItem = nil
	--self.BtnLeaderInfo = nil
	--self.BtnReport = nil
	--self.ImgBadge = nil
	--self.ImgFlagBG = nil
	--self.ImgLine01 = nil
	--self.ImgLine02 = nil
	--self.PanelArmyName = nil
	--self.PanelLeader = nil
	--self.AnimIn = nil
	--self.AnimUpdate = nil
	--self.Styles = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyShowInfoPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ArmyBadgeItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyShowInfoPageView:OnInit()
	self.Binders = {
		{ "CaptainName", UIBinderValueChangedCallback.New(self, nil, self.SetTextCaptainName)},
        --{ "ArmyID", UIBinderSetText.New(self, self.TextArmyID_3)},
		--{ "Slogan", UIBinderSetText.New(self, self.TextSlogan)},
		{ "ArmyName", UIBinderValueChangedCallback.New(self, nil, self.SetTextArmyName)},
		{ "ArmyShortName", UIBinderValueChangedCallback.New(self, nil, self.SetTextArmyName02)},
		{ "UnionIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgMainArmyIcon)},
		{ "UnionBGIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgFlagBG)},
		{ "BadgeData", UIBinderValueChangedCallback.New(self, nil, self.OnBadgeDataChange)},
		{ "ArmyID", UIBinderValueChangedCallback.New(self, nil, self.OnArmyChange)},
		{ "LeaderID", UIBinderValueChangedCallback.New(self, nil, self.OnArmyLeaderChange)},
		{ "bShowArmyLeader", UIBinderSetIsVisible.New(self, self.PanelArmyName, true)},
		{ "bShowArmyLeader", UIBinderSetIsVisible.New(self, self.PanelLeader)},
		{ "bShowArmyLeader", UIBinderValueChangedCallback.New(self, nil, self.SetMidPanel)},
		{ "GrandCompanyType", UIBinderValueChangedCallback.New(self, nil, self.OnGrandCompanyTypeChange) },
		{ "IsRoleQueryFinish", UIBinderValueChangedCallback.New(self, nil, self.OnIsRoleQueryFinishChange) }
	}
end

function ArmyShowInfoPageView:SetTextArmyName(ArmyName)
	if self.ArmyNameView and self.ArmyNameView.TextArmyName then
		self.ArmyNameView.TextArmyName:SetText(ArmyName)
	end
end

function ArmyShowInfoPageView:SetTextArmyName02(ArmyShortName)
	if self.ArmyNameView and self.ArmyNameView.TextArmyName02 then
		self.ArmyNameView.TextArmyName02:SetText(ArmyShortName)
	end
end

function ArmyShowInfoPageView:SetTextCaptainName(CaptainName)
	if self.LeaderView and self.LeaderView.TextCaptainName then
		self.LeaderView.TextCaptainName:SetText(CaptainName)
	end
end

function ArmyShowInfoPageView:SetMidPanel(bShowArmyLeader)
	---屏蔽部队名显示
	if bShowArmyLeader then
		--self:RemoveArmyNameView()
		self:AddLeaderView()
	else
		self:RemoveLeaderView()
		--self:AddArmyNameViewView()
	end
end

function ArmyShowInfoPageView:OnDestroy()
end

function ArmyShowInfoPageView:OnShow()
	-- LSTR string:编号
	--self.TextNumber:SetText(LSTR(910322))
	local VM = self.ViewModel
	if VM then
		if VM and VM:GetIsRoleQueryFinish() then
			self:SetPlayerHeadSlotData()
		end
		if VM.bShowArmyLeader then
			self:AddLeaderView()
		else
			--self:AddArmyNameViewView()
		end
	end
end

function ArmyShowInfoPageView:OnArmyLeaderChange(LeaderID)
	self:SetPlayerHeadSlotData() ---用缓存数据设置一次头像框
end

function ArmyShowInfoPageView:OnGrandCompanyTypeChange(GrandCompanyType)
	if GrandCompanyType ~= nil then
		self:SetStyle(GrandCompanyTypeStyle[GrandCompanyType])
	end
end

function ArmyShowInfoPageView:SetStyle(GrandCompanyTypeStyle)
	if GrandCompanyTypeStyle then
		if NewStyles[GrandCompanyTypeStyle] == nil then
			return
		end
		--local IDColor = FLinearColor.FromHex(NewStyles[GrandCompanyTypeStyle].IDColor)
		local ContentColor = FLinearColor.FromHex(NewStyles[GrandCompanyTypeStyle].ContentColor)
		local LineColor = FLinearColor.FromHex(NewStyles[GrandCompanyTypeStyle].LineColor)
		local LeaderNameColor = FLinearColor.FromHex(NewStyles[GrandCompanyTypeStyle].LeaderNameColor)
		if self.LeaderView then
			self.LeaderView.TextCaptainName:SetColorAndOpacity(LeaderNameColor)
			local LeaderTextColor = FLinearColor.FromHex(NewStyles[GrandCompanyTypeStyle].LeaderTextColor)
			self.LeaderView.TextCaptain:SetColorAndOpacity(LeaderTextColor)
		end
		if self.ArmyNameView then
			self.ArmyNameView.TextArmyName:SetColorAndOpacity(LeaderNameColor)
			self.ArmyNameView.TextArmyName02:SetColorAndOpacity(ContentColor)
		end
	    --	self.TextArmyID_3:SetColorAndOpacity(IDColor)
		--self.TextSlogan:SetColorAndOpacity(ContentColor)
		self.ImgLine01:SetColorAndOpacity(LineColor)
		self.ImgLine02:SetColorAndOpacity(LineColor)
	end
end

function ArmyShowInfoPageView:OnBadgeDataChange(Value)
	self.ArmyBadgeItem:SetBadgeData(Value, true)
end

function ArmyShowInfoPageView:OnArmyChange()
	self:PlayAnimation(self.AnimUpdate)
end

function ArmyShowInfoPageView:OnHide()
	self:RemoveArmyNameView()
	self:RemoveLeaderView()
end

function ArmyShowInfoPageView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.BtnCopy, self.OnClickedCopyID)
	UIUtil.AddOnClickedEvent(self, self.BtnLeaderInfo, self.OnClickedLeaderInfo)
	UIUtil.AddOnClickedEvent(self, self.BtnReport, self.OnClickedReport)
end

function ArmyShowInfoPageView:OnRegisterGameEvent()

end

function ArmyShowInfoPageView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil or Params.Data == nil then
		if self.ViewModel then
			self:RegisterBinders(self.ViewModel, self.Binders)
		end
		return
	end

	self:RefreshVM(Params.Data)
end

function ArmyShowInfoPageView:RefreshVM(VM)
	if VM == nil then
		return
	end
	self.ViewModel = VM

	-- if self:GetIsShowView() then
	-- 	self:RegisterBinders(VM, self.Binders)
	-- end
end

--- 复制部队ID
function ArmyShowInfoPageView:OnClickedCopyID()
	_G.CommonUtil.ClipboardCopy(self.ViewModel.ArmyID)
    -- LSTR string:拷贝成功
    _G.MsgTipsUtil.ShowTips(LSTR(910142))
end

--- 查看部队长信息
function ArmyShowInfoPageView:OnClickedLeaderInfo()
	if self.ViewModel == nil then
		return
	end
	PersonInfoMgr:ShowPersonalSimpleInfoView(self.ViewModel:GetLeaderID())
end

function ArmyShowInfoPageView:SetViewModel(VM)
	self.ViewModel = VM
end

function ArmyShowInfoPageView:OnIsRoleQueryFinishChange(IsRoleQueryFinish)
	if IsRoleQueryFinish then
		self:SetPlayerHeadSlotData()
	end
end

function ArmyShowInfoPageView:SetPlayerHeadSlotData()
	if self.LeaderView then
		local VM = self.ViewModel
		if VM then
			local CurLeaderID = VM:GetLeaderID()
			local PlayerHeadSlot = self.LeaderView.CommPlayerHeadSlot_UIBP
			if PlayerHeadSlot and CommonUtil.IsObjectValid(PlayerHeadSlot) and CurLeaderID then
				PlayerHeadSlot:SetInfo(CurLeaderID)
			end
		end
	end
end

function ArmyShowInfoPageView:AddArmyNameViewView()
	if self.ArmyNameView == nil then
		self.ArmyNameView = UIViewMgr:CreateViewByName("Army/ArmyShowInfoArmyNamePage_UIBP", nil, self, true)
		if self.ArmyNameView then
			self.PanelArmyName:AddChildToCanvas(self.ArmyNameView)
			local Anchor = _G.UE.FAnchors()
			Anchor.Minimum = _G.UE.FVector2D(0, 0)
			Anchor.Maximum = _G.UE.FVector2D(1, 1)
			UIUtil.CanvasSlotSetAnchors(self.ArmyNameView, Anchor)
			UIUtil.CanvasSlotSetSize(self.ArmyNameView, _G.UE.FVector2D(0, 0))
			---更新数据，防止数据变化时，LeaderView未加载导致数据没更新到
			if self.ArmyNameView then
				if self.ViewModel == nil then
					return
				end
				if self.ArmyNameView.TextArmyName then
					local ArmyName = self.ViewModel:GetArmyName()
					if ArmyName then
						self.ArmyNameView.TextArmyName:SetText(ArmyName)
					end
				end
				if self.ArmyNameView.TextArmyName02 then
					local ArmyShortName = self.ViewModel:GetArmyShortName()
					if ArmyShortName then
						self.ArmyNameView.TextArmyName02:SetText(ArmyShortName)
					end
				end
			end
		end
	end
end

function ArmyShowInfoPageView:AddLeaderView()
	if self.LeaderView == nil then
		self.LeaderView = UIViewMgr:CreateViewByName("Army/ArmyShowInfoLeaderPage_UIBP", nil, self, true)
		if self.LeaderView then
			self.PanelLeader:AddChildToCanvas(self.LeaderView)
			local Anchor = _G.UE.FAnchors()
			Anchor.Minimum = _G.UE.FVector2D(0, 0)
			Anchor.Maximum = _G.UE.FVector2D(1, 1)
			UIUtil.CanvasSlotSetAnchors(self.LeaderView, Anchor)
			UIUtil.CanvasSlotSetSize(self.LeaderView, _G.UE.FVector2D(0, 0))
			---更新数据，防止数据变化时，LeaderView未加载导致数据没更新到
			if self.LeaderView then
				if self.ViewModel == nil then
					return
				end
				if self.LeaderView.TextCaptainName then
					local CaptainName = self.ViewModel:GetCaptainName()
					if CaptainName then
						self.LeaderView.TextCaptainName:SetText(CaptainName)
					end
				end
				local IsRoleQueryFinish = self.ViewModel:GetIsRoleQueryFinish()
				if IsRoleQueryFinish then
					self:SetPlayerHeadSlotData()
				end
			end
		end
	end
end

function ArmyShowInfoPageView:RemoveArmyNameView()
	if self.ArmyNameView then
		self.PanelArmyName:RemoveChild(self.ArmyNameView)
		UIViewMgr:RecycleView(self.ArmyNameView)
		self.ArmyNameView = nil
	end
end

function ArmyShowInfoPageView:RemoveLeaderView()
	if self.LeaderView then
		self.PanelLeader:RemoveChild(self.LeaderView)
		UIViewMgr:RecycleView(self.LeaderView)
		self.LeaderView = nil
	end
end

function ArmyShowInfoPageView:OnClickedReport()
	---按钮未启用，此界面可能在部队列表显示，也可能在部队内显示，后续启用再处理简称和招募标语
	local Params = {
        ReporteeRoleID = self.LeaderID,
        GroupID = self.ArmyID,
        GroupName = self.Name,
    }
	--- Params.ReportContentList  = { "Abbreviation" = "部队简称文本", "RecruitmentSlogan" = "招募标语文本"}
	_G.ReportMgr:OpenViewByArmyList(Params)
end

return ArmyShowInfoPageView