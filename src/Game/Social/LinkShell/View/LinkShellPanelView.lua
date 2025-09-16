---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local LinkShellMgr = require("Game/Social/LinkShell/LinkShellMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local LSTR = _G.LSTR

---@class LinkShellPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommEmpty CommBackpackEmptyView
---@field PanelDetail LinkShellDetailPanelView
---@field PanelEmpty UFCanvasPanel
---@field TableViewList UTableView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellPanelView = LuaClass(UIView, true)

function LinkShellPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommEmpty = nil
	--self.PanelDetail = nil
	--self.PanelEmpty = nil
	--self.TableViewList = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.PanelDetail)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellPanelView:OnInit()
	self.TableAdapterList = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSelectItemChanged, true)

	self.Binders = {
		{ "IsShowJoinedEmptyTips", UIBinderValueChangedCallback.New(self, nil, self.OnIsShowJoinedEmptyTipsChanged) },
		{ "LinkShellItemVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterList) },
	}
end

function LinkShellPanelView:OnDestroy()

end

function LinkShellPanelView:OnShow()
	self:InitConstText()

	self.CurIdx = nil 
	UIUtil.SetIsVisible(self.PanelDetail, false)
end

function LinkShellPanelView:OnHide()
    self.DefaultSelLinkShellID = nil 

	LinkShellVM:ClearTempData()
end

function LinkShellPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommEmpty.Btn, self.OnClickedButtonCommEmptyBtn)
end

function LinkShellPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.LinkShellCreateSuc, self.OnEventCreateLSSuc)
    self:RegisterGameEvent(EventID.LinkShellListUpdate, self.OnEventLSListRefresh)
end

function LinkShellPanelView:OnRegisterBinder()
	self:RegisterBinders(LinkShellVM, self.Binders)
end

function LinkShellPanelView:InitConstText()
	if self.IsInitConstText then
		return
	end

	self.IsInitConstText = true

	local CommEmpty = self.CommEmpty 
	CommEmpty:SetTipsContent(LSTR(40108)) -- "创建或加入通讯贝和朋友一起聊天吧！"
	CommEmpty:SetBtnText(LSTR(40115)) -- "创建"
end

--- 跳转到指定通讯贝
---@param LinkShellID number @通讯贝ID 
function LinkShellPanelView:GoToLinkShell(LinkShellID)
    self.DefaultSelLinkShellID = LinkShellID
end

function LinkShellPanelView:OnIsShowJoinedEmptyTipsChanged(IsShow)
	UIUtil.SetIsVisible(self.PanelEmpty, IsShow)

	-- 只处理隐藏，是为了解决为后台通讯贝列表数据未回包之前把PanelDetail显示出来的问题
	if IsShow then
		UIUtil.SetIsVisible(self.PanelDetail, false)
	end
end

function LinkShellPanelView:OnSelectItemChanged(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	local LastLinkShellID = LinkShellVM.CurLinkShellID
	local LastIdentify = LinkShellVM.CurLinkShellIdentify

	local LinkShellID = ItemData.ID
	local Identify = ItemData.Identify
	LinkShellVM.CurLinkShellID = LinkShellID
	LinkShellVM.CurLinkShellIdentify = Identify

	if ItemData.IsEmpty then
		if self.CurIdx and self.CurIdx ~= Index then
			self.TableAdapterList:SetSelectedIndex(self.CurIdx)
		end

		self:ShowCreateWin()
		return
	end

	self.CurIdx = Index

	if LastLinkShellID == LinkShellID and LastIdentify == Identify then
		return
	end

	UIUtil.SetIsVisible(self.PanelDetail, true)
	self.PanelDetail:SetViewModel(ItemData)

	-- 播放动效
	self:PlayAnimation(self.AnimPanelChange)
end

function LinkShellPanelView:ShowCreateWin()
	--"通讯贝数量达到上限"
	if LinkShellMgr:CheckLinkshellNumLimit(40040) then
		UIViewMgr:ShowView(UIViewID.LinkShellCreateWin)
	end
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function LinkShellPanelView:OnClickedButtonCommEmptyBtn()
	self:ShowCreateWin()
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function LinkShellPanelView:OnEventCreateLSSuc()
    UIViewMgr:HideView(UIViewID.LinkShellCreateWin)
end

function LinkShellPanelView:OnEventLSListRefresh( ItemData )
	if LinkShellVM.IsShowJoinedEmptyTips then
		return
	end

	local LinkShellID = self.DefaultSelLinkShellID
	if LinkShellID then
        if self.TableAdapterList:SetSelectedByPredicate(function(Item) return Item.ID == LinkShellID end) then
			self.DefaultSelLinkShellID = nil
			return
		end

		self.DefaultSelLinkShellID = nil
	end

	if type(ItemData) == "table" then
		self.TableAdapterList:SetSelectedItem(ItemData)

	else
		self.TableAdapterList:SetSelectedIndex(1)
	end
end

return LinkShellPanelView