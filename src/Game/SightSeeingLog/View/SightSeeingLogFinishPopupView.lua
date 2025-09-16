---
--- Author: Administrator
--- DateTime: 2024-03-19 11:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local ProtoRes = require("Protocol/ProtoRes")
local DiscoverNoteVM = require("Game/SightSeeingLog/DiscoverNoteVM")
local DiscoverNoteMgr = require("Game/SightSeeingLog/DiscoverNoteMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBinderSetMaterialTextureFromAssetPath = require("Binder/UIBinderSetMaterialTextureFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetMaterialVectorParameterValue = require("Binder/UIBinderSetMaterialVectorParameterValue")
local UIBinderSetMaterialScalarParameterValue = require("Binder/UIBinderSetMaterialScalarParameterValue")
local DiscoverNoteDefine = require("Game/SightSeeingLog/DiscoverNoteDefine")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")
local NoteUnlockType = DiscoverNoteDefine.NoteUnlockType
local TipsShowType = ProtoRes.sysnotice_show_type
local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR

local DiscoveryTipsID = 308100 -- 初步探索
local PerfectDiscoverTipsID = 308101 -- 完美探索

local TipsShowType2InfoTextTipType = {
	[TipsShowType.SYSNOTICE_SHOWTYPE_INFOTEXT] = 1,
	[TipsShowType.SYSNOTICE_SHOWTYPE_INFOTEXTSMALL] = 2,
	[TipsShowType.SYSNOTICE_SHOWTYPE_INFOTEXTBIG] = 3,
}

---@class SightSeeingLogFinishPopupView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field BtnCloseWin CommBtnLView
---@field BtnGo CommBtnLView
---@field CommBtnGo CommBtnLView
---@field HorizontalTips UFHorizontalBox
---@field ImgPhoto UFImage
---@field ImgPhotoDark UFImage
---@field ImgPhotoFrameNormal UFImage
---@field InfoTips InfoTextTipsView
---@field PanelBtn UFCanvasPanel
---@field PanelFinish UFCanvasPanel
---@field PanelRecord UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field TextDescribe UFTextBlock
---@field TextName UFTextBlock
---@field TextPlace UFTextBlock
---@field TextRecord UFTextBlock
---@field textTips UFTextBlock
---@field AnimIn1 UWidgetAnimation
---@field AnimIn2 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SightSeeingLogFinishPopupView = LuaClass(UIView, true)

function SightSeeingLogFinishPopupView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnCloseWin = nil
	--self.BtnGo = nil
	--self.CommBtnGo = nil
	--self.HorizontalTips = nil
	--self.ImgPhoto = nil
	--self.ImgPhotoDark = nil
	--self.ImgPhotoFrameNormal = nil
	--self.InfoTips = nil
	--self.PanelBtn = nil
	--self.PanelFinish = nil
	--self.PanelRecord = nil
	--self.PopUpBG = nil
	--self.TextDescribe = nil
	--self.TextName = nil
	--self.TextPlace = nil
	--self.TextRecord = nil
	--self.textTips = nil
	--self.AnimIn1 = nil
	--self.AnimIn2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SightSeeingLogFinishPopupView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCloseWin)
	self:AddSubView(self.BtnGo)
	self:AddSubView(self.CommBtnGo)
	self:AddSubView(self.InfoTips)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SightSeeingLogFinishPopupView:InitConstStringInfo()
	self.textTips:SetText(LSTR(330011))
end

function SightSeeingLogFinishPopupView:InitSubViewConstStringInfo()
	self.CommBtnGo:SetButtonText(LSTR(330014))
	self.BtnCloseWin:SetButtonText(LSTR(330012))
	self.BtnGo:SetButtonText(LSTR(330013))
end

function SightSeeingLogFinishPopupView:OnInit()
	self.Binders = {
		{"ImgPath", UIBinderSetMaterialTextureFromAssetPath.New(self, self.ImgPhoto, "MainTexture")},
		{"Color", UIBinderSetMaterialVectorParameterValue.New(self, self.ImgPhoto, "Color")},
		{"Int", UIBinderSetMaterialScalarParameterValue.New(self, self.ImgPhoto, "Int")},
		{"Tint", UIBinderSetMaterialScalarParameterValue.New(self, self.ImgPhoto, "Tint")},
		{"Opacity", UIBinderSetMaterialScalarParameterValue.New(self, self.ImgPhoto, "Opacity")},
		{"RegionName", UIBinderSetText.New(self, self.TextName)},
		{"MapName", UIBinderSetText.New(self, self.TextPlace)},
		{"NoteContent", UIBinderSetText.New(self, self.TextDescribe)},
		{"NoteName", UIBinderSetText.New(self, self.TextRecord)},
	}
	self:InitConstStringInfo()
end

function SightSeeingLogFinishPopupView:OnDestroy()

end

function SightSeeingLogFinishPopupView:OnShow()
	self:InitSubViewConstStringInfo()
	local DiscoverNoteCompleteVM = DiscoverNoteVM.DiscoverNoteCompleteVM
	if not DiscoverNoteCompleteVM then
		return
	end
	self:ShowMainPanel(DiscoverNoteCompleteVM.CompleteState)
end

function SightSeeingLogFinishPopupView:OnHide()

end

function SightSeeingLogFinishPopupView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnBtnCloseClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCloseWin, self.OnBtnCloseClick)
	UIUtil.AddOnClickedEvent(self, self.CommBtnGo, self.OnCommBtnGoClick)
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnCommBtnGoClick)
end

function SightSeeingLogFinishPopupView:OnRegisterGameEvent()

end

function SightSeeingLogFinishPopupView:OnRegisterBinder()
	local DiscoverNoteCompleteVM = DiscoverNoteVM.DiscoverNoteCompleteVM
	if not DiscoverNoteCompleteVM then
		return
	end

	self:RegisterBinders(DiscoverNoteCompleteVM, self.Binders)
end

function SightSeeingLogFinishPopupView:OnBtnCloseClick()
	if self:IsAnimationPlaying(self.AnimIn) then
		return
	end

	self:Hide()
end

function SightSeeingLogFinishPopupView:OnCommBtnGoClick()
	if self:IsAnimationPlaying(self.AnimIn) then
		return
	end
	self:Hide()
	local DiscoverNoteCompleteVM = DiscoverNoteVM.DiscoverNoteCompleteVM
	if not DiscoverNoteCompleteVM then
		return
	end
	DiscoverNoteMgr:OpenDiscoverNoteMainPanel(DiscoverNoteCompleteVM.ItemID or 0)
end

function SightSeeingLogFinishPopupView:ShowMainPanel(UnlockType)
	if not UnlockType or UnlockType == NoteUnlockType.Locked then
		return
	end

	--UIUtil.SetIsVisible(self.InfoTips, false)
	if UnlockType == NoteUnlockType.PerfectUnlock then
		self:SetTitle(PerfectDiscoverTipsID)
		--MsgTipsUtil.ShowTipsByID(PerfectDiscoverTipsID)
		self:PlayAnimation(self.AnimIn2)
	else
		self:SetTitle(DiscoveryTipsID)
		--MsgTipsUtil.ShowTipsByID()
		UIUtil.SetIsVisible(self.HorizontalTips, UnlockType == NoteUnlockType.UnlockFail)
		self:PlayAnimation(self.AnimIn1)
	end
end

function SightSeeingLogFinishPopupView:SetTitle(TipsID)
	local Cfg = SysnoticeCfg:FindCfgByKey(TipsID)
	if nil == Cfg or nil == next(Cfg) then
		if nil == TipsID then
			FLOG_ERROR(string.format("SightSeeingLogFinishPopupView:SetMainPanelTitle can't find tips, ID is nil"))
			return
		else
			FLOG_ERROR(string.format("SightSeeingLogFinishPopupView:SetMainPanelTitle can't find tips, ID=%d", TipsID))
			return
		end
	end
	local ShowTypes = Cfg.ShowType
	if not ShowTypes then
		return
	end
	local ShowType = ShowTypes[1]
	if not ShowType then
		return
	end
	local Params = {
		Type = TipsShowType2InfoTextTipType[ShowType]
	}

	local TargetContent = ""
	local Contents = Cfg.Content or {}
	TargetContent = Contents[1] or ""
	TargetContent = MsgTipsUtil.ParseLabel(TargetContent)
	TargetContent = CommonUtil.GetTextFromStringWithSpecialCharacter(TargetContent)
	Params.Content = TargetContent
	self.InfoTips:SetParams(Params)
end

return SightSeeingLogFinishPopupView