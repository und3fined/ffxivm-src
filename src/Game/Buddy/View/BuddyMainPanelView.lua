---
--- Author: Administrator
--- DateTime: 2023-11-13 15:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local BuddyMainVM = require("Game/Buddy/VM/BuddyMainVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MajorUtil = require ("Utils/MajorUtil")

local UIViewMgr
local UIViewID
local BuddyMgr

---@class BuddyMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AbilityPage BuddyAbilityPageView
---@field BtnMask UFButton
---@field BtnShow UFButton
---@field CloseBtn CommonCloseBtnView
---@field StatusPage BuddyStatusPageView
---@field TableViewPage UTableView
---@field TextTitle UFTextBlock
---@field AnimChangePage UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddyMainPanelView = LuaClass(UIView, true)

function BuddyMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AbilityPage = nil
	--self.BtnMask = nil
	--self.BtnShow = nil
	--self.CloseBtn = nil
	--self.StatusPage = nil
	--self.TableViewPage = nil
	--self.TextTitle = nil
	--self.AnimChangePage = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddyMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AbilityPage)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.StatusPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddyMainPanelView:OnInit()
	UIViewMgr = _G.UIViewMgr
	UIViewID = _G.UIViewID
	BuddyMgr = _G.BuddyMgr

	self.TableViewMenuAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPage)
	self.TableViewMenuAdapter:SetOnClickedCallback(self.OnMenuItemClicked)

	self.Binders = {
		{ "AbilityPageVisible", UIBinderSetIsVisible.New(self, self.AbilityPage) },
		{ "StatusPageVisible", UIBinderSetIsVisible.New(self, self.StatusPage) },
		{ "CurrentPageVMList", UIBinderUpdateBindableList.New(self, self.TableViewMenuAdapter) },
	}

	self.AbilityPage:SetParams({Data = BuddyMainVM.AbilityPageVM})
	self.StatusPage:SetParams({Data = BuddyMainVM.StatusPageVM})
end

function BuddyMainPanelView:OnDestroy()

end

function BuddyMainPanelView:OnShow()
	UIViewMgr:HideView(UIViewID.Main2ndPanel)
	BuddyMainVM:InitPageMenu()
	BuddyMainVM:ShowStatusPage()

	BuddyMgr:SendBuddyQueryMessage()
	BuddyMgr:ReqUsedColor()
	BuddyMgr:ReqUsedArmor()
end

function BuddyMainPanelView:OnHide()

end

function BuddyMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnShow, self.OnBtnShow) --外观
end

function BuddyMainPanelView:OnRegisterGameEvent()

end

function BuddyMainPanelView:OnRegisterBinder()
	self:RegisterBinders(BuddyMainVM, self.Binders)
	self.TextTitle:SetText(_G.LSTR(1000044))
end

function BuddyMainPanelView:OnMenuItemClicked(Index, ItemData, ItemView)
	if ItemData.Index == BuddyMainVM.MenuType.Status then
		BuddyMainVM:ShowStatusPage()
	elseif ItemData.Index == BuddyMainVM.MenuType.Ability then
		BuddyMainVM:ShowAbilityPage()
		BuddyMgr:RecordRedDotClicked()
	end
	self:PlayAnimation(self.AnimChangePage)
end

function BuddyMainPanelView:OnBtnShow()
	if MajorUtil.IsMajorDead() then
		_G.MsgTipsUtil.ShowTipsByID(308012)
	else
		UIViewMgr:ShowView(UIViewID.BuddySurfacePanel, {ID = BuddyMgr.BuddyID})
		self:Hide()
	end
end

return BuddyMainPanelView