---
--- Author: xingcaicao
--- DateTime: 2025-04-08 11:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local LinkShellMgr = require("Game/Social/LinkShell/LinkShellMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local LSTR = _G.LSTR

---@class LinkShellInvitedPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommEmpty CommBackpackEmptyView
---@field PanelEmpty UFCanvasPanel
---@field PanelInviteDetail LinkShellInviteDetailPanelView
---@field TableViewList UTableView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellInvitedPanelView = LuaClass(UIView, true)

function LinkShellInvitedPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommEmpty = nil
	--self.PanelEmpty = nil
	--self.PanelInviteDetail = nil
	--self.TableViewList = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellInvitedPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.PanelInviteDetail)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellInvitedPanelView:OnInit()
	self.TableAdapterList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSelectItemChanged)

	self.Binders = {
		{ "IsShowInvitedEmptyTips", UIBinderValueChangedCallback.New(self, nil, self.OnIsShowInvitedEmptyTipsChanged) },
		{ "LinkShellInvitedItemVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterList) },
	}
end

function LinkShellInvitedPanelView:OnDestroy()

end

function LinkShellInvitedPanelView:OnShow()
	self:InitConstText()

	UIUtil.SetIsVisible(self.PanelInviteDetail, false)
end

function LinkShellInvitedPanelView:OnHide()
	LinkShellVM:ClearTempData()
end

function LinkShellInvitedPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommEmpty.Btn, self.OnClickedButtonCommEmptyBtn)
end

function LinkShellInvitedPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.LinkShellInvitedListUpdate, self.OnEventLSInvitedListRefresh)
end

function LinkShellInvitedPanelView:OnRegisterBinder()
	self:RegisterBinders(LinkShellVM, self.Binders)
end

function LinkShellInvitedPanelView:InitConstText()
	if self.IsInitConstText then
		return
	end

	self.IsInitConstText = true

	local CommEmpty = self.CommEmpty 
	CommEmpty:SetTipsContent(LSTR(40113)) -- "还没有收到通讯贝邀请哦，创建或加入通讯贝和朋友一起聊天吧！"
	CommEmpty:SetBtnText(LSTR(40114)) -- "加入"
end

function LinkShellInvitedPanelView:OnIsShowInvitedEmptyTipsChanged(IsShow)
	UIUtil.SetIsVisible(self.PanelEmpty, IsShow)

	-- 只处理隐藏，是为了解决为后台通讯贝列表数据未回包之前把PanelInviteDetail显示出来的问题
	if IsShow then
		UIUtil.SetIsVisible(self.PanelInviteDetail, false)
	end
end

function LinkShellInvitedPanelView:OnSelectItemChanged(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	LinkShellVM.CurLinkShellID = ItemData.ID
	UIUtil.SetIsVisible(self.PanelInviteDetail, true)
	self.PanelInviteDetail:SetViewModel(ItemData)

	-- 播放动效
	self:PlayAnimation(self.AnimPanelChange)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function LinkShellInvitedPanelView:OnClickedButtonCommEmptyBtn()
	local ParentView = self.ParentView
	if nil == ParentView then
		return
	end

	-- "通讯贝已达到加入上限"
    if LinkShellMgr:CheckLinkshellNumLimit(40116) then
		ParentView:SwitchToJoinLinkShellTab()
	end
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function LinkShellInvitedPanelView:OnEventLSInvitedListRefresh( )
	if LinkShellVM.IsShowInvitedEmptyTips then
		return
	end

	self.TableAdapterList:SetSelectedIndex(1)
end
return LinkShellInvitedPanelView