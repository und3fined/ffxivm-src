---
--- Author: Administrator
--- DateTime: 2025-03-06 17:30
--- Description:
---



local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local InviteSignSideWinVM = require("Game/Common/InviteSignSideWin/InviteSignSideWinVM")
local InviteSignSideDefine = require("Game/Common/InviteSignSideWin/InviteSignSideDefine")
local InviteItemType = InviteSignSideDefine.InviteItemType
local InviteMenu = InviteSignSideDefine.InviteMenu
local MenuValues = InviteSignSideDefine.MenuValues

---@class ArmyInvitePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field BtnRefresh UFButton
---@field CommBackpackEmpty CommBackpackEmptyView
---@field CommSearchBar CommSearchBarView
---@field CommSidebarTabFrame CommSidebarTabFrameView
---@field PanelBtns UFCanvasPanel
---@field PanelEmpty UFCanvasPanel
---@field PanelMember UFCanvasPanel
---@field TableViewChannelPublic UTableView
---@field TableViewInvitePlayers UTableView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyInvitePanelView = LuaClass(UIView, true)

function ArmyInvitePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnRefresh = nil
	--self.CommBackpackEmpty = nil
	--self.CommSearchBar = nil
	--self.CommSidebarTabFrame = nil
	--self.PanelBtns = nil
	--self.PanelEmpty = nil
	--self.PanelMember = nil
	--self.TableViewChannelPublic = nil
	--self.TableViewInvitePlayers = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyInvitePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpackEmpty)
	self:AddSubView(self.CommSearchBar)
	self:AddSubView(self.CommSidebarTabFrame)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyInvitePanelView:OnInit()
	self.CommSearchBar:SetCallback(self, nil, self.OnSearchTextCommitted, self.OnClickCancelSearchBar)
	if self.InviteSignSideWinVM == nil then
		self.InviteSignSideWinVM = InviteSignSideWinVM.New()
	end
	self.InviteSignSideWinVM:OnInit()
	self.PlayersAdapterTable = UIAdapterTableView.CreateAdapter(self, self.TableViewInvitePlayers)
	self.MenuAdapterTable = UIAdapterTableView.CreateAdapter(self, self.TableViewChannelPublic, self.OnTabItemSelect, true)
	self.Binders = {
		{ "IsEmptyMember", 	UIBinderSetIsVisible.New(self, 	self.PanelEmpty) },
		{ "IsEmptyMember", 	UIBinderSetIsVisible.New(self, 	self.PanelMember, true) },
		{ "MenuItemVMList", 		UIBinderUpdateBindableList.New(self, self.MenuAdapterTable) },		--- 页签列表 
		{ "ViewingPlayerItemVMList", UIBinderUpdateBindableList.New(self, self.PlayersAdapterTable)},		--- 成员列表 
	}
end

function ArmyInvitePanelView:OnDestroy()

end
--- Params = 
---{
---		PanleTitleText, --- 标题文本
---		MenusData, --- 页签数据
---		ItemType, --- Item类型
---}
function ArmyInvitePanelView:OnShow()
	local Params = self.Params
	if Params then
		---LSTR 暂无可邀请玩家
		self:SetEmptyText(LSTR(910413))
		---LSTR 邀请署名
		local PanleTitleText = Params.PanleTitleText or LSTR(910336)
		self.CommSidebarTabFrame.CommonTitle:SetTextTitleName(PanleTitleText)

		UIUtil.SetIsVisible(self.PanelBtns, true)
		if self.InviteSignSideWinVM then
			---列表数据处理
			local MenusData = Params.MenusData or {MenuValues[InviteMenu.Friend]}
			self.InviteSignSideWinVM:SetTabVMByTabValues(MenusData)
			local ItemType = Params.ItemType or InviteItemType.ArmySignInvite
			self.InviteSignSideWinVM:SetItemType(ItemType)
			---设置默认选中第一个
			self.MenuAdapterTable:SetSelectedIndex(1)
		end
	end
end

function ArmyInvitePanelView:OnTabItemSelect(Index, ItemData, ItemView, IsByClick )
	if ItemData then
		self.InviteSignSideWinVM:RefreshInviteMemberDataByMenuID(ItemData.MenuID)
	end
end

function ArmyInvitePanelView:OnHide()
	self.InviteSignSideWinVM:ClearFilterData()
end

function ArmyInvitePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRefresh, self.OnClickedButtonRefresh)
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnClickedBtnClose)
end

function ArmyInvitePanelView:OnRegisterGameEvent()

end

function ArmyInvitePanelView:OnRegisterBinder()
	self:RegisterBinders(self.InviteSignSideWinVM, self.Binders)
end

---设置空文本
function ArmyInvitePanelView:SetEmptyText(Text)
	self.CommBackpackEmpty:SetTipsContent(Text)
end

function ArmyInvitePanelView:OnClickedButtonRefresh()
	local Index = self.MenuAdapterTable:GetSelectedIndex()
	self.InviteSignSideWinVM:RefreshInviteMemberDataByMenuIndex(Index)
end

function ArmyInvitePanelView:OnSearchTextCommitted(SearchText)
	self:HandleSearchText(SearchText)
end

function ArmyInvitePanelView:OnSearchTextChanged(SearchText)
	self:HandleSearchText(SearchText)
end

function ArmyInvitePanelView:HandleSearchText(SearchText)
	local ProcessedText = ((SearchText or ""):gsub("^%s*(.-)%s*$", "%1"))
	self.InviteSignSideWinVM:FilterParentItemByKeyword(ProcessedText)
end

--- 关闭搜索框
function ArmyInvitePanelView:OnClickCancelSearchBar()
	---LSTR 暂无可邀请玩家
	self.CommSearchBar:SetText("")
	self:SetEmptyText(LSTR(910413))

	self.InviteSignSideWinVM:ClearFilterData()

	UIUtil.SetIsVisible(self.PanelBtns, true)
end

function ArmyInvitePanelView:OnClickedBtnClose()
	self:Hide()
end

return ArmyInvitePanelView