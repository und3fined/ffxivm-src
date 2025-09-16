---
--- Author: richyczhou
--- DateTime: 2024-10-25 18:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local SaveKey = require("Define/SaveKey")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID
local LSTR = _G.LSTR

local FLOG_INFO = _G.FLOG_INFO
local USaveMgr = _G.UE.USaveMgr

---@class LoginNewNoticeWinWBPView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BannerPanel UFCanvasPanel
---@field BtnArrowL UButton
---@field BtnArrowR UButton
---@field BtnClose UButton
---@field BtnClose1 UButton
---@field BtnConfirm UButton
---@field BtnOut UButton
---@field BtnUpdate UButton
---@field ButtonMask UButton
---@field ButtonPanel UFHorizontalBox
---@field CommSingleBox CommSingleBoxView
---@field Drop1 UFCanvasPanel
---@field Drop2 UFCanvasPanel
---@field Drop3 UFCanvasPanel
---@field Drop4 UFCanvasPanel
---@field Drop5 UFCanvasPanel
---@field Drop6 UFCanvasPanel
---@field FHorizontalBox UFHorizontalBox
---@field ImageMask UImage
---@field ImgBanner UFImage
---@field ImgDisable UFImage
---@field ImgDisable2 UFImage
---@field ImgDisable2_1 UFImage
---@field ImgNorma2 UFImage
---@field ImgNormal UFImage
---@field ImgNormal1 UFImage
---@field ImgNormal2 UFImage
---@field ImgNormal2_1 UFImage
---@field ImgNormal3 UFImage
---@field ImgNormal4 UFImage
---@field ImgNormal5 UFImage
---@field ImgNormal6 UFImage
---@field ImgRecommend UFImage
---@field ImgRecommend2 UFImage
---@field ImgRecommend2_1 UFImage
---@field ImgSelect1 UFImage
---@field ImgSelect2 UFImage
---@field ImgSelect3 UFImage
---@field ImgSelect4 UFImage
---@field ImgSelect5 UFImage
---@field ImgSelect6 UFImage
---@field LoginNewBanner UFCanvasPanel
---@field NoticePanel UFCanvasPanel
---@field PanelTextTitle UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PopUpBG UFCanvasPanel
---@field RichText URichTextBox
---@field TableViewDrop UTableView
---@field TextContent UFTextBlock
---@field TextContent2 UFTextBlock
---@field TextContent2_1 UFTextBlock
---@field TextNot UFTextBlock
---@field TextNoticePanel UFCanvasPanel
---@field TextPrepare2 UFTextBlock
---@field TextTitle UFTextBlock
---@field TextTitle2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewNoticeWinWBPView = LuaClass(UIView, true)

function LoginNewNoticeWinWBPView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BannerPanel = nil
	--self.BtnArrowL = nil
	--self.BtnArrowR = nil
	--self.BtnClose = nil
	--self.BtnClose1 = nil
	--self.BtnConfirm = nil
	--self.BtnOut = nil
	--self.BtnUpdate = nil
	--self.ButtonMask = nil
	--self.ButtonPanel = nil
	--self.CommSingleBox = nil
	--self.Drop1 = nil
	--self.Drop2 = nil
	--self.Drop3 = nil
	--self.Drop4 = nil
	--self.Drop5 = nil
	--self.Drop6 = nil
	--self.FHorizontalBox = nil
	--self.ImageMask = nil
	--self.ImgBanner = nil
	--self.ImgDisable = nil
	--self.ImgDisable2 = nil
	--self.ImgDisable2_1 = nil
	--self.ImgNorma2 = nil
	--self.ImgNormal = nil
	--self.ImgNormal1 = nil
	--self.ImgNormal2 = nil
	--self.ImgNormal2_1 = nil
	--self.ImgNormal3 = nil
	--self.ImgNormal4 = nil
	--self.ImgNormal5 = nil
	--self.ImgNormal6 = nil
	--self.ImgRecommend = nil
	--self.ImgRecommend2 = nil
	--self.ImgRecommend2_1 = nil
	--self.ImgSelect1 = nil
	--self.ImgSelect2 = nil
	--self.ImgSelect3 = nil
	--self.ImgSelect4 = nil
	--self.ImgSelect5 = nil
	--self.ImgSelect6 = nil
	--self.LoginNewBanner = nil
	--self.NoticePanel = nil
	--self.PanelTextTitle = nil
	--self.PanelTips = nil
	--self.PopUpBG = nil
	--self.RichText = nil
	--self.TableViewDrop = nil
	--self.TextContent = nil
	--self.TextContent2 = nil
	--self.TextContent2_1 = nil
	--self.TextNot = nil
	--self.TextNoticePanel = nil
	--self.TextPrepare2 = nil
	--self.TextTitle = nil
	--self.TextTitle2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewNoticeWinWBPView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewNoticeWinWBPView:OnInit()
	self.TextNot:SetText(LSTR(LoginStrID.NoShowAgain))
	self.TextContent2_1:SetText(LSTR(LoginStrID.ConfirmBtnStr))

	self.Binders = {
		--{ "AgreeAllAgreement", UIBinderSetIsDisabledState.New(self, self.BtnStart, true)},
		{ "NoShowAgain", UIBinderSetIsChecked.New(self, self.CommSingleBox.ToggleButton)},
	}
end

function LoginNewNoticeWinWBPView:OnDestroy()

end

function LoginNewNoticeWinWBPView:OnShow()
	local bNoShowNoticeAgain = USaveMgr.GetInt(SaveKey.NoShowNoticeAgain, 0, false) == 1
	FLOG_INFO("[LoginNewNoticeWinWBPView:OnShow] bNoShowNoticeAgain:%s", tostring(bNoShowNoticeAgain))
	self.CommSingleBox:SetChecked(bNoShowNoticeAgain)

	self.BtnClose1:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
	self.ButtonPanel:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
	self:ShowNoticeFromLogin()
end

function LoginNewNoticeWinWBPView:OnHide()

end

function LoginNewNoticeWinWBPView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm, self.OnClickBtnConfirm)
	UIUtil.AddOnClickedEvent(self, self.ButtonMask, self.OnClickBtnMask)

	self.CommSingleBox:SetStateChangedCallback(self, self.OnStateChangedCallback)
end

function LoginNewNoticeWinWBPView:OnRegisterGameEvent()

end

function LoginNewNoticeWinWBPView:OnRegisterBinder()

end

function LoginNewNoticeWinWBPView:OnClickBtnConfirm()
	FLOG_INFO("[LoginNewNoticeWinWBPView:OnClickBtnConfirm] ")
	--self:Hide()
	UIViewMgr:HideView(UIViewID.LoginNotice)
end

function LoginNewNoticeWinWBPView:OnClickBtnMask()
	FLOG_INFO("[LoginNewNoticeWinWBPView:OnClickBtnMask] ")
	UIViewMgr:HideView(UIViewID.LoginNotice)
end

function LoginNewNoticeWinWBPView:OnStateChangedCallback(IsChecked, Type)
	FLOG_INFO("[LoginNewNoticeWinWBPView:OnStateChangedCallback] IsChecked:%s", tostring(IsChecked))
	USaveMgr.SetInt(SaveKey.NoShowNoticeAgain, IsChecked and 1 or 0, false)
end

return LoginNewNoticeWinWBPView