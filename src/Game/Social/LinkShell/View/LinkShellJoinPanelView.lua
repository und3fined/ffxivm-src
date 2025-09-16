---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local LinkShellMgr = require("Game/Social/LinkShell/LinkShellMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local LSTR = _G.LSTR

---@class LinkShellJoinPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnScreen CommScreenerBtnView
---@field CommEmpty CommBackpackEmptyView
---@field PanelSearch UFCanvasPanel
---@field SearchInput CommSearchBarView
---@field SingleBoxCannotJoin CommSingleBoxView
---@field TableViewJoinList UTableView
---@field AnimIn UWidgetAnimation
---@field AnimUpdateList UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellJoinPanelView = LuaClass(UIView, true)

function LinkShellJoinPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnScreen = nil
	--self.CommEmpty = nil
	--self.PanelSearch = nil
	--self.SearchInput = nil
	--self.SingleBoxCannotJoin = nil
	--self.TableViewJoinList = nil
	--self.AnimIn = nil
	--self.AnimUpdateList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellJoinPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnScreen)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.SearchInput)
	self:AddSubView(self.SingleBoxCannotJoin)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellJoinPanelView:OnInit()
	self.TableAdapterJoinList = UIAdapterTableView.CreateAdapter(self, self.TableViewJoinList)

	self.SearchInput:SetCallback(self, nil, self.OnSearchTextCommitted, self.OnCancelSearchInput)

	self.Binders = {
		{ "IsScreening", 			UIBinderSetIsChecked.New(self, self.BtnScreen, false) },
		{ "IsShowCannotJoin",   	UIBinderSetIsChecked.New(self, self.SingleBoxCannotJoin, false) },
		{ "ShowingSearchItemVMList",UIBinderUpdateBindableList.New(self, self.TableAdapterJoinList) },
		{ "IsEmptySearchList", 		UIBinderSetIsVisible.New(self, self.CommEmpty) },
	}
end

function LinkShellJoinPanelView:OnDestroy()

end

function LinkShellJoinPanelView:OnShow()
	self:InitConstText()
	self:SendSearchLinkShellReq()
end

function LinkShellJoinPanelView:OnHide()
	self.SearchInput:SetText("")
	LinkShellVM:ClearFindData()
    LinkShellVM.IsShowCannotJoin = false 
end

function LinkShellJoinPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBoxCannotJoin, self.OnStateChangedCannotJoin)
	UIUtil.AddOnStateChangedEvent(self, self.BtnScreen, self.OnClickedBtnScreen)
end

function LinkShellJoinPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.HideUI, self.OnGameEventHideUI)
	self:RegisterGameEvent(EventID.LinkShellPlayJoinUpdateListAnim, self.OnGameEventPlayUpdateListAnim)
end

function LinkShellJoinPanelView:OnRegisterBinder()
	self:RegisterBinders(LinkShellVM, self.Binders)
end

function LinkShellJoinPanelView:InitConstText()
	if self.IsInitConstText then
		return
	end

	self.IsInitConstText = true

	self.SingleBoxCannotJoin:SetText(LSTR(40077)) -- "显示不可加入通讯贝"
	self.SearchInput:SetHintText(LSTR(40078)) -- "搜索通讯贝"
	self.CommEmpty:SetTipsContent(LSTR(40079)) -- "没有符合条件的通讯贝，请重新操作"
end

function LinkShellJoinPanelView:ResetState()
	self.SearchInput:SetText("")
	LinkShellVM:ClearFindData()

	self:SendSearchLinkShellReq()
end

function LinkShellJoinPanelView:SendSearchLinkShellReq(Text)
	--清除老数据
	LinkShellVM.SearchItemVMList:Clear()

	--请求推荐
	if string.isnilorempty(Text) then
		LinkShellMgr:SendSearchRecommendLinkShell()
		return
	end

	LinkShellVM.FindKeyword = Text
	LinkShellVM.IsShowCannotJoin = true
	LinkShellMgr:SendSearchLinkShellByName(Text)
end
function LinkShellJoinPanelView:OnSearchTextCommitted( Text )
	LinkShellVM:ResetFindScreenData()
	self:SendSearchLinkShellReq(Text)
end

function LinkShellJoinPanelView:OnCancelSearchInput()
	self:ResetState()
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function LinkShellJoinPanelView:OnGameEventHideUI(ViewID)
	if ViewID == UIViewID.LinkShellScreenerWin and LinkShellVM.IsScreening then
		self.SearchInput:SetText("")
	end
end

function LinkShellJoinPanelView:OnGameEventPlayUpdateListAnim()
    self:PlayAnimation(self.AnimUpdateList)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function LinkShellJoinPanelView:OnStateChangedCannotJoin(_, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	LinkShellVM:UpdateShowingSearchItemList(IsChecked)
end

function LinkShellJoinPanelView:OnClickedBtnScreen(_, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if IsChecked then
		LinkShellVM.IsScreening = true 
		UIViewMgr:ShowView(UIViewID.LinkShellScreenerWin) 

	else
		self:ResetState()
	end
end

return LinkShellJoinPanelView