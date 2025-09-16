---
--- Author: Administrator
--- DateTime: 2023-05-31 10:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local TutorialGuideShowPanelVM = require("Game/Tutorial/VM/TutorialGuideShowPanelVM")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local GuideCfg = require("TableCfg/GuideCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIViewID = require("Define/UIViewID")

---@class TutorialGuideShowPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnArrowLeft UFButton
---@field BtnArrowRight UFButton
---@field BtnClose CommonCloseBtnView
---@field GuideShow UFCanvasPanel
---@field IconArrowLeftDisabled UFImage
---@field IconArrowLeftNormal UFImage
---@field IconArrowRightDisabled UFImage
---@field IconArrowRightNormal UFImage
---@field PanelArrowLeft UFCanvasPanel
---@field PanelBtnArrowRight UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field RichTextContent URichTextBox
---@field ShowBanner TutorialGuideShowBannerItemView
---@field TableViewDrop UTableView
---@field TextHint UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialGuideShowPanelView = LuaClass(UIView, true)

function TutorialGuideShowPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnArrowLeft = nil
	--self.BtnArrowRight = nil
	--self.BtnClose = nil
	--self.GuideShow = nil
	--self.IconArrowLeftDisabled = nil
	--self.IconArrowLeftNormal = nil
	--self.IconArrowRightDisabled = nil
	--self.IconArrowRightNormal = nil
	--self.PanelArrowLeft = nil
	--self.PanelBtnArrowRight = nil
	--self.PopUpBG = nil
	--self.RichTextContent = nil
	--self.ShowBanner = nil
	--self.TableViewDrop = nil
	--self.TextHint = nil
	--self.TextTips = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialGuideShowPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.PopUpBG)
	self:AddSubView(self.ShowBanner)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGuideShowPanelView:OnInit()

	self.TutorialGuideShowPanelVM = TutorialGuideShowPanelVM.New()

	self.Index = 1
	self.ID = nil
	self.IsRead = false
	self.TableViewDropAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewDrop, nil, true, false)
	self.Binders = {}

end

function TutorialGuideShowPanelView:OnDestroy()
end


function TutorialGuideShowPanelView:OnShow()
	if not self.Params then
		return
	end

	self.Index = 1
	self.ID = self.Params.ID
	self.TutorialGuideShowPanelVM:UpdateData(self.ID, self.Index)

	local Cfg = GuideCfg:FindCfgByGuideID(self.ID)
	local bMultiContent = false
	if Cfg ~= nil then
		self.IsRead = tonumber(Cfg.IsRead) == 1
		bMultiContent = #Cfg.WindowContent > 1
	end
	UIUtil.SetIsVisible(self.PanelArrowLeft,  bMultiContent)
	UIUtil.SetIsVisible(self.PanelBtnArrowRight, bMultiContent)
	UIUtil.SetIsVisible(self.TableViewDrop, bMultiContent)
	
	self.TableViewDropAdapter:SetSelectedIndex(1)
	-- UIUtil.SetColorAndOpacity(self.ShowBanner.ImgLine, 1, 1, 1, 0.3)
	UIUtil.SetColorAndOpacity(self.ShowBanner.ImgFrame2, 1, 1, 1, 0.3)

	-- 副本教学中屏蔽部分UI,点击空白处关闭
	if self.Params.PWorldTeaching then
		self.PopUpBG:SetHideOnClick(true)
		UIUtil.SetIsVisible(self.TextTips, true)

		UIUtil.SetIsVisible(self.BtnClose, false)
		UIUtil.SetIsVisible(self.TextHint, false)
		UIUtil.SetIsVisible(self.PanelArrowLeft, false)
		UIUtil.SetIsVisible(self.PanelBtnArrowRight, false)
	else
		UIUtil.SetIsVisible(self.BtnClose, false)
		self.PopUpBG:SetHideOnClick(true)
		self.PopUpBG:SetCallback(self, self.BgClickCallBack)
		UIUtil.SetIsVisible(self.TextTips, true)
	end

	self.TextTips:SetText(LSTR(890004))
	self.TextHint:SetText(LSTR(890006))
end

function TutorialGuideShowPanelView:OnHide()
	--_G.TutorialGuideMgr:SetGuideTutorialDoing(false)

	-- 副本教学中使用,关闭时发送UI交互
	if self.Params.PWorldTeaching then
		_G.TeachingMgr.SendInteractiveByGuideID(self.ID)
	end

	if self.ID == 59 then ---巡回乐团结束需要通知打开应援按钮界面
		_G.EventMgr:SendEvent(_G.EventID.TutorialGuideTouringBandFinish)
	end
end

function TutorialGuideShowPanelView:OnRegisterUIEvent()
	--self.BtnClose:SetCallback(self, self.OnClickButtonBack)
	UIUtil.AddOnClickedEvent(self, self.CloseGuide, self.OnClickButtonBack)
	UIUtil.AddOnClickedEvent(self, self.BtnArrowLeft, self.OnClickedPrePage)
	UIUtil.AddOnClickedEvent(self, self.BtnArrowRight, self.OnClickedNextPage)
end

function TutorialGuideShowPanelView:OnRegisterGameEvent()
end

function TutorialGuideShowPanelView:OnRegisterBinder()
	local Binders = {
		{"IsLeft", UIBinderSetIsVisible.New(self, self.IconArrowLeftNormal)},
		{"IsLeft", UIBinderSetIsVisible.New(self, self.IconArrowLeftDisabled, true)},
		{"IsRight", UIBinderSetIsVisible.New(self, self.IconArrowRightNormal)},
		{"IsRight", UIBinderSetIsVisible.New(self,self.IconArrowRightDisabled, true)},
		{"RichTextContent", UIBinderSetText.New(self, self.RichTextContent)},
		{"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"GuideShowPic", UIBinderSetBrushFromAssetPath.New(self, self.ShowBanner.ImgBanner)},
		{"DropListSelectIndex", UIBinderSetSelectedIndex.New(self, self.TableViewDropAdapter)},
		{"DropList", UIBinderUpdateBindableList.New(self, self.TableViewDropAdapter)},
		{"SpecShowPic", UIBinderSetBrushFromAssetPath.New(self, self.ShowBanner.Img2,true)},
		{"SpecShowPicShow", UIBinderSetIsVisible.New(self, self.ShowBanner.Img2, false, true)},
		{"TipsText", UIBinderSetText.New(self, self.TextTips)},
	}

	self:RegisterBinders(self.TutorialGuideShowPanelVM, Binders)
end

function TutorialGuideShowPanelView:OnClickedPrePage()
	if self.Index <= 1 then
		return 
	end
	self.Index = self.Index - 1
	self.TutorialGuideShowPanelVM:UpdateContent(self.ID, self.Index)
end

function TutorialGuideShowPanelView:OnClickedNextPage()
	local Len = self.TableViewDropAdapter:GetNum()
	if self.Index >= Len then
		return
	end
	self.Index = self.Index + 1
	self.TutorialGuideShowPanelVM:UpdateContent(self.ID, self.Index)
end

function TutorialGuideShowPanelView:OnClickButtonBack()
	local OpenModuleCfg = _G.ModuleOpenMgr:GetCfgByModuleID(ProtoCommon.ModuleID.ModuleIDNewbie)
	local Len = #_G.TutorialGuideMgr:GetGuideTutorial()
	if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDNewbie) and OpenModuleCfg then
		_G.EventMgr:SendEvent(_G.EventID.ModuleOpenNewBieGuideEvent, OpenModuleCfg.ID, true)
	end

	_G.TutorialGuideMgr:OnTutorialGuideCountDownEnd()

	self:Hide()
end

function TutorialGuideShowPanelView:BgClickCallBack()
	local Len = self.TableViewDropAdapter:GetNum()
	if not self.IsRead then
		self:OnClickButtonBack()
		return
	end

	if self.IsRead and self.Index >= Len then
		self:OnClickButtonBack()
		return
	end
end


return TutorialGuideShowPanelView
