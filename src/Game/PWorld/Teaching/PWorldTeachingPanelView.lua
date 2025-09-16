---
--- Author: ashyuan
--- DateTime: 2024-04-18 14:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TeachingVM = require("Game/Pworld/Teaching/TeachingVM")
local TeachingType = require("Game/Pworld/Teaching/TeachingType")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local TeachingDefine = require("Game/Pworld/Teaching/TeachingDefine")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIAdventureAdapterTableView = require("Game/Adventure/UIAdventureAdapterTableView")

local TeachingMgr = _G.TeachingMgr

---@class PWorldTeachingPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackBtn CommBackBtnView
---@field BackpackEmpty CommBackpackEmptyView
---@field BtnQuit CommBtnLView
---@field BtnSwitch UFButton
---@field BtnSwitchProfession CommBtnLView
---@field CommTab CommMenuView
---@field CommonBkg CommonBkg01View
---@field IconProfession UFImage
---@field IconProfession2 UFImage
---@field ImgMaskBg UFImage
---@field PanelEmpty UFCanvasPanel
---@field PanelSwitch UFHorizontalBox
---@field TableViewCatalog UTableView
---@field TextLv UFTextBlock
---@field TextProfession UFTextBlock
---@field TextTitle UFTextBlock
---@field TextType UFTextBlock
---@field AnimChangeTab UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldTeachingPanelView = LuaClass(UIView, true)

function PWorldTeachingPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackBtn = nil
	--self.BackpackEmpty = nil
	--self.BtnQuit = nil
	--self.BtnSwitch = nil
	--self.BtnSwitchProfession = nil
	--self.CommTab = nil
	--self.CommonBkg = nil
	--self.IconProfession = nil
	--self.IconProfession2 = nil
	--self.ImgMaskBg = nil
	--self.PanelEmpty = nil
	--self.PanelSwitch = nil
	--self.TableViewCatalog = nil
	--self.TextLv = nil
	--self.TextProfession = nil
	--self.TextTitle = nil
	--self.TextType = nil
	--self.AnimChangeTab = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.SelectIndex = 0
end

function PWorldTeachingPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	self:AddSubView(self.BackpackEmpty)
	self:AddSubView(self.BtnQuit)
	self:AddSubView(self.BtnSwitchProfession)
	self:AddSubView(self.CommTab)
	self:AddSubView(self.CommonBkg)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldTeachingPanelView:OnInit()
	self.TableViewCatalogAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCatalog, nil, false)
	self.Binders = {
		{ "JobType", UIBinderSetText.New(self, self.TextType) },
		{ "ShowBtnQuit", UIBinderSetVisibility.New(self, self.BtnQuit) },
		{ "ProfID", UIBinderSetProfName.New(self, self.TextProfession) },
		{ "ProfID", UIBinderSetProfIcon.New(self, self.IconProfession2) },
		{ "Level", UIBinderSetTextFormat.New(self, self.TextLv, "%d") },
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.IconProfession) },
		{ "TableViewCatalogVMList", UIBinderUpdateBindableList.New(self, self.TableViewCatalogAdapter)},
	}
end

function PWorldTeachingPanelView:OnDestroy()

end

function PWorldTeachingPanelView:OnShow()
	-- 设置默认文本
	self.TextTitle:SetText(LSTR(890010))--设置机制特训Title
	self.BtnQuit:SetText(LSTR(890013))--设置退出训练按钮
	self.BtnSwitchProfession:SetText(LSTR(80015))--设置切换职业按钮
	self.BackpackEmpty:SetTipsContent(LSTR(890028))--设置无法参与特训，需要切换为战斗职业

	if TeachingMgr.IsTeachScene then
		UIUtil.SetIsVisible(self.CommonBkg, false)
		UIUtil.SetIsVisible(self.ImgMaskBg, true)
		UIUtil.SetIsVisible(self.PanelSwitch, false)

		--副本内这两个Tips不能显示在主界面上方,临时处理下先隐藏掉
		_G.UIViewMgr:HideView(UIViewID.TutorialGestureTips1Item)
		_G.UIViewMgr:HideView(UIViewID.CommTextTipsBigStrongItem)
	else
		UIUtil.SetIsVisible(self.CommonBkg, true)
		UIUtil.SetIsVisible(self.ImgMaskBg, false)
		UIUtil.SetIsVisible(self.PanelSwitch, true)
	end

	local IsCrafterProf = TeachingMgr:IsCrafterProf()
	if IsCrafterProf then
		self:ShowPanelEmpty(true)
	else
		self:ShowPanelEmpty(false)
		self:ShowContentPanel()
	end
	self:PlayAnimation(self.AnimIn)
end

function PWorldTeachingPanelView:OnHide()

end

function PWorldTeachingPanelView:OnSelectionChangedCommMenu(Index)
	TeachingVM:UpdateCatalogItems(Index)
	self.SelectIndex = Index
	self:PlayAnimation(self.AnimChangeTab)
end

function PWorldTeachingPanelView:OnRegisterUIEvent()
	self.BackBtn:AddBackClick(self, self.OnClickButtonExit)
	UIUtil.AddOnClickedEvent(self, self.BtnQuit, self.OnClickedBack)
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OnBtnSwitchClick)
    UIUtil.AddOnClickedEvent(self, self.BtnSwitchProfession, self.OnBtnSwitchClick)
	UIUtil.AddOnSelectionChangedEvent(self, self.CommTab, self.OnSelectionChangedCommMenu)
end

function PWorldTeachingPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnEventMajorProfSwitch)
end

function PWorldTeachingPanelView:OnRegisterBinder()
	self:RegisterBinders(TeachingVM, self.Binders)
end

--- 返回
function PWorldTeachingPanelView:OnClickedBack()
	TeachingMgr:LeaveTeaching()
end

function PWorldTeachingPanelView:OnClickButtonExit()
	UIViewMgr:HideView(self.ViewID)
end

function PWorldTeachingPanelView:OnBtnSwitchClick()
	UIViewMgr:ShowView(_G.UIViewID.ProfessionToggleJobTab)
end

function PWorldTeachingPanelView:OnEventMajorProfSwitch()
	local IsCrafterProf = TeachingMgr:IsCrafterProf()
	if IsCrafterProf then
		self:ShowPanelEmpty(true)
	else
		self:ShowPanelEmpty(false)
		self:ShowContentPanel()
	end
end

function PWorldTeachingPanelView:ShowPanelEmpty(IsShow)
	if IsShow then
		UIUtil.SetIsVisible(self.TableViewCatalog, false)
		UIUtil.SetIsVisible(self.IconProfession, false)
		UIUtil.SetIsVisible(self.PanelSwitch, true)
		UIUtil.SetIsVisible(self.PanelEmpty, true)
		UIUtil.SetIsVisible(self.TextType, false)
		UIUtil.SetIsVisible(self.CommTab, false)
		TeachingVM:UpdateMajorInfo()
	else
		UIUtil.SetIsVisible(self.TableViewCatalog, true)
		UIUtil.SetIsVisible(self.IconProfession, true)
		UIUtil.SetIsVisible(self.PanelEmpty, false)
		UIUtil.SetIsVisible(self.TextType, true)
		UIUtil.SetIsVisible(self.CommTab, true)

		if not TeachingMgr.IsTeachScene then
			UIUtil.SetIsVisible(self.PanelSwitch, true)
		end
	end
end

function PWorldTeachingPanelView:ShowContentPanel()
	self.CommTab:UpdateItems(TeachingDefine.MainTabs)
	local SelectedLevel = TeachingMgr:GetShowLevel()
	if self.SelectIndex and self.SelectIndex == SelectedLevel then
		self:OnSelectionChangedCommMenu(SelectedLevel)
	else
		self.CommTab:SetSelectedIndex(SelectedLevel)
	end
end

return PWorldTeachingPanelView