---
--- Author: mingyyzhang
--- DateTime: 2025-07-01 14:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local HouseInfoInviteFriendsWinVM = require("Game/House/VM/HouseInfoInviteFriendsWinVM")
local HouseLocalDef = require("Game/House/HouseLocalDef")

---@class HouseInfoInviteFriendsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRefresh UFButton
---@field CommBackpackEmpty CommBackpackEmptyView
---@field CommEasytoUseSidebarFrame_UIBP CommEasytoUseSidebarFrameView
---@field CommSearchBar CommSearchBarView
---@field CommSideTab CommSideBarTabsView
---@field CommSidebarTabFrame CommSidebarTabFrameView
---@field PanelBtns UFCanvasPanel
---@field PanelEmpty UFCanvasPanel
---@field TableViewInvitePlayers UTableView
---@field AnimEmptyIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInfoInviteFriendsWinView = LuaClass(UIView, true)

function HouseInfoInviteFriendsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRefresh = nil
	--self.CommBackpackEmpty = nil
	--self.CommEasytoUseSidebarFrame_UIBP = nil
	--self.CommSearchBar = nil
	--self.CommSideTab = nil
	--self.CommSidebarTabFrame = nil
	--self.PanelBtns = nil
	--self.PanelEmpty = nil
	--self.TableViewInvitePlayers = nil
	--self.AnimEmptyIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInfoInviteFriendsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpackEmpty)
	self:AddSubView(self.CommEasytoUseSidebarFrame_UIBP)
	self:AddSubView(self.CommSearchBar)
	self:AddSubView(self.CommSideTab)
	self:AddSubView(self.CommSidebarTabFrame)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInfoInviteFriendsWinView:OnInit()
	self.CommSearchBar:SetCallback(self, nil, self.OnSearchTextCommitted, self.OnClickCancelSearchBar)
	if self.HouseInfoInviteFriendsWinVM == nil then
		self.HouseInfoInviteFriendsWinVM = HouseInfoInviteFriendsWinVM.New()
	end

	self.PlayersAdapterTable = UIAdapterTableView.CreateAdapter(self, self.TableViewInvitePlayers)
	self:SetEmptyText(LSTR(910413))
	self.Binders = {
		{ "IsEmptyMember", 	UIBinderSetIsVisible.New(self, 	self.PanelEmpty) },
		{ "IsEmptyMember", 	UIBinderSetIsVisible.New(self, 	self.TableViewInvitePlayers, true) },
		{ "ExpandItem", 	UIBinderSetIsVisible.New(self, 	self.CommEasytoUseSidebarFrame_UIBP.CommonTitle.CommInforBtn) },
		{ "ExpandItem", 	UIBinderSetIsVisible.New(self, 	self.CommEasytoUseSidebarFrame_UIBP.CommonTitle.TextSubtitle) },
		--{ "MenuItemVMList", 		UIBinderUpdateBindableList.New(self, self.MenuAdapterTable) },		--- 页签列表 
		{ "ViewingPlayerItemVMList", UIBinderUpdateBindableList.New(self, self.PlayersAdapterTable)},	--- 成员列表
	} 
end

function HouseInfoInviteFriendsWinView:OnDestroy()

end

function HouseInfoInviteFriendsWinView:OnShow()
	--UIUtil.SetIsVisible(self.CommEasytoUseSidebarFrame_UIBP.CommonTitle.CommInforBtn, false)
	--UIUtil.SetIsVisible(self.CommEasytoUseSidebarFrame_UIBP.CommonTitle.TextSubtitle, false)

	self.HouseInfoInviteFriendsWinVM:Reset()
	self.HouseInfoInviteFriendsWinVM:SetTabVMByTabValues(HouseLocalDef.RoommatesInviteWinViewStr.MenuList)
	self.CommEasytoUseSidebarFrame_UIBP:SetTabSideBarData(HouseLocalDef.RoommatesInviteWinViewStr.MenuList, 1)
	self.CommEasytoUseSidebarFrame_UIBP:SetTabSideBarSelectCallBack(self.OnTabItemSelect)
	self.CommEasytoUseSidebarFrame_UIBP.CommonTitle:SetTextTitleName(HouseLocalDef.RoommatesInviteWinViewStr.PanelTittle)
	self.CommEasytoUseSidebarFrame_UIBP:SetTabSelectByTypeIndex(1, 1)
	self.HouseInfoInviteFriendsWinVM:RefreshInviteMemberDataByButton(1)
end

function HouseInfoInviteFriendsWinView:OnHide()

end

function HouseInfoInviteFriendsWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRefresh, self.OnClickedButtonRefresh)
	UIUtil.AddOnClickedEvent(self, self.CommEasytoUseSidebarFrame_UIBP.BtnClose.Btn_Close, self.OnClickedBtnClose)
end

function HouseInfoInviteFriendsWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.HousePullRoleBasic, self.OnPullRoleBasic)
end

function HouseInfoInviteFriendsWinView:OnRegisterBinder()
	self:RegisterBinders(self.HouseInfoInviteFriendsWinVM, self.Binders)
end

function HouseInfoInviteFriendsWinView:OnTabItemSelect(Index, ItemData, ItemView)
	if self and ItemData then
		self.HouseInfoInviteFriendsWinVM:RefreshInviteMemberDataByButton()
	end
end

function HouseInfoInviteFriendsWinView:OnClickedButtonRefresh()
	--local Index = self.MenuAdapterTable:GetSelectedIndex()
	--后续拓展Menu使用
	local Index = 1
	self:OnClickCancelSearchBar()
	self.HouseInfoInviteFriendsWinVM:RefreshInviteMemberDataByButton(Index)
end

function HouseInfoInviteFriendsWinView:OnSearchTextCommitted(SearchText)
	self:HandleSearchText(SearchText)
end

function HouseInfoInviteFriendsWinView:OnSearchTextChanged(SearchText)
	self:HandleSearchText(SearchText)
end

function HouseInfoInviteFriendsWinView:HandleSearchText(SearchText)
	local ProcessedText = ((SearchText or ""):gsub("^%s*(.-)%s*$", "%1"))
	self.HouseInfoInviteFriendsWinVM:FilterParentItemByKeyword(ProcessedText)
end

--- 清空搜索框
function HouseInfoInviteFriendsWinView:OnClickCancelSearchBar()
	---LSTR 暂无可邀请玩家
	self.CommSearchBar:SetText("")
	self:SetEmptyText(LSTR(910413))

	self.HouseInfoInviteFriendsWinVM:ClearFilterData()

	UIUtil.SetIsVisible(self.PanelBtns, true)
end

---设置空文本
function HouseInfoInviteFriendsWinView:SetEmptyText(Text)
	self.CommBackpackEmpty:SetTipsContent(Text)
end

function HouseInfoInviteFriendsWinView:OnClickedBtnClose()
	self:OnHide()
end

function HouseInfoInviteFriendsWinView:OnPullRoleBasic(MsgBody)
	self.HouseInfoInviteFriendsWinVM:FreshInvite(MsgBody)
end

return HouseInfoInviteFriendsWinView