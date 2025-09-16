---
--- Author: Administrator
--- DateTime: 2025-02-24 10:33
--- Description:
---

local CommSidebarFrameBaseView = require("Game/Common/Frame/CommSidebarFrameBaseView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

local CommEasyToUseSidebarVM = require("Game/Common/Frame/CommEasytoUseVM/CommEasyToUseSidebarVM")
local UIBinderSetViewParams = require("Binder/UIBinderSetViewParams")
---@class CommEasytoUseSidebarFrameView : CommSidebarFrameBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnClose CommonCloseBtnView
---@field CommSideBarTabs_UIBP CommSideBarTabsView
---@field CommonTitle CommonTitleView
---@field FHorizontalTitle UFHorizontalBox
---@field ImgBkg UFImage
---@field ImgPattern UFImage
---@field ImgTabBkg UFImage
---@field ImgTitleBg UFImage
---@field NamedSlotChild UNamedSlot
---@field PanelTop UFCanvasPanel
---@field Sidebar UFCanvasPanel
---@field AnimChatToNarrow UWidgetAnimation
---@field AnimChatToWide UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field IsBtnCloseShow bool
---@field IsBtnBackShow bool
---@field TabBkgSize float
---@field SizeType CommonSideBarTabSize
---@field CustomSideBarSize float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommEasytoUseSidebarFrameView = LuaClass(CommSidebarFrameBaseView, true)

function CommEasytoUseSidebarFrameView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnClose = nil
	--self.CommSideBarTabs_UIBP = nil
	--self.CommonTitle = nil
	--self.FHorizontalTitle = nil
	--self.ImgBkg = nil
	--self.ImgPattern = nil
	--self.ImgTabBkg = nil
	--self.ImgTitleBg = nil
	--self.NamedSlotChild = nil
	--self.PanelTop = nil
	--self.Sidebar = nil
	--self.AnimChatToNarrow = nil
	--self.AnimChatToWide = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.TitleShow = nil
	--self.TitleContentText = nil
	--self.TitleColorAndOpacity = nil
	--self.TitleFontMaterial = nil
	--self.TitleFontSize = nil
	--self.TitleMinFontSize = nil
	--self.TitleReductionStep = nil
	--self.TitleTextAdaptation = nil
	--self.TitleTextOverflow = nil
	--self.TitleEnableShowDetailTips = nil
	--self.TitleMaxNeedWidth = nil
	--self.SubTitleShow = nil
	--self.SubTitleContentText = nil
	--self.SubTitleColorAndOpacity = nil
	--self.SubTitleFontSize = nil
	--self.SubTitleMinFontSize = nil
	--self.SubTitleReductionStep = nil
	--self.SubTitleTextAdaptation = nil
	--self.SubTitleTextOverflow = nil
	--self.SubTitleEnableShowDetailTips = nil
	--self.SubMaxNeedWidth = nil
	--self.HpInfoShow = nil
	--self.HelpInfoID = nil
	--self.IsHorizontalTitleShow = nil
	--self.IsBtnCloseShow = nil
	--self.IsBtnBackShow = nil
	--self.TabBkgSize = nil
	--self.SizeType = nil
	--self.CustomSideBarSize = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommEasytoUseSidebarFrameView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommSideBarTabs_UIBP)
	self:AddSubView(self.CommonTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommEasytoUseSidebarFrameView:OnInit()
	self.ViewModel = CommEasyToUseSidebarVM.New()

	self.Binders = {
		{ "SideBarSelectVM", UIBinderSetViewParams.New(self, self.CommSideBarTabs_UIBP)}, --右侧类型选择VM
	}
end

function CommEasytoUseSidebarFrameView:OnShow()
	self.Super.OnShow(self)
	if self.AnimIn then
		local DelayTime = self.AnimIn:GetEndTime() or 0
		self:RegisterTimer(function()
			self:PlayAnimation(self.AnimIn, DelayTime, 1, 0, 1.0, false)
		end, DelayTime, 0, 1)
	end
end

function CommEasytoUseSidebarFrameView:SetTabSideBarData(Data, Type)
	if self.ViewModel then
		self.ViewModel:SetSelectTabData(Data)
		local TypeIsVaild = false
		for i, v in ipairs(Data) do
			if v.Type == Type then
				self:SetTabSelectByTypeIndex(i, Type)
				TypeIsVaild = true
				break
			end
		end

		if not TypeIsVaild and next(Data) then
			self:SetTabSelectByTypeIndex(1, Data[1].Type)
			FLOG_INFO(string.format("SetTabSideBarData Cur Type Page Show Fail Type Is %d", Type or 0))
		end
		
	else
		FLOG_ERROR("SetTabSideBarData CommEasyToUseSidebarVM Is Not Init")
	end
end

function CommEasytoUseSidebarFrameView:SetTabSideBarSelectCallBack(CallBack)
	if self.ViewModel then
		self.ViewModel:SetTabSideBarSelectCallBack(CallBack)
	else
		FLOG_ERROR("SetTabSideBarData CommEasyToUseSidebarVM Is Not Init")
	end
end

function CommEasytoUseSidebarFrameView:SetHelpInfoCallback(UIViewID)
	if not UIViewID then
		self.CommonTitle.CommInforBtn.Callback = nil
		return
	end
	local Callback = function()
		UIViewMgr:ShowView(UIViewID)
	end
	self.CommonTitle:SetCommInforBtnIsVisible(true)
	self.CommonTitle.CommInforBtn.Callback = Callback
end

function CommEasytoUseSidebarFrameView:SetTabSelectByTypeIndex(Index, Type)
	self.ViewModel:SetCurSelectType(Type)
	self.ViewModel:SetCurSelectIndex(Index)
	self.CommSideBarTabs_UIBP:SetTabSelectByIndex(Index)
end

function CommEasytoUseSidebarFrameView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function CommEasytoUseSidebarFrameView:SetSidebarSize(SizeX)
	UIUtil.CanvasSlotSetSize(self.Sidebar, _G.UE.FVector2D(SizeX, 0))
end

return CommEasytoUseSidebarFrameView