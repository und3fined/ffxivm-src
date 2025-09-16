---
--- Author: usakizhang
--- DateTime: 2025-03-06 16:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local OpsConcertRecallWinVM = require("Game/Ops/VM/OpsConcert/OpsConcertRecallWinVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local LSTR = _G.LSTR
---@class OpsConcertRecallWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRefresh UFButton
---@field CommEmpty CommBackpackEmptyView
---@field CommSearchBar CommSearchBarView
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field PanelBtns UFCanvasPanel
---@field TableViewInvitePlayers UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsConcertRecallWinView = LuaClass(UIView, true)

function OpsConcertRecallWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRefresh = nil
	--self.CommEmpty = nil
	--self.CommSearchBar = nil
	--self.CommSidebarFrameS_UIBP = nil
	--self.PanelBtns = nil
	--self.TableViewInvitePlayers = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsConcertRecallWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.CommSearchBar)
	self:AddSubView(self.CommSidebarFrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsConcertRecallWinView:OnInit()
	self.ViewModel = OpsConcertRecallWinVM.New()
	self.BindPlayerListAdapter = UIAdapterTableView.CreateAdapter(self,self.TableViewInvitePlayers)

	self.Binders = {
		{"BindPlayerVMList", UIBinderUpdateBindableList.New(self, self.BindPlayerListAdapter)},
		{"ListIsEmpty", UIBinderSetIsVisible.New(self, self.CommEmpty)},
		{"ListIsNotEmpty", UIBinderSetIsVisible.New(self, self.PanelBtns)}
	}
end

function OpsConcertRecallWinView:OnDestroy()

end

function OpsConcertRecallWinView:OnShow()
	---设置文本
	self.CommSidebarFrameS_UIBP.CommonTitle:SetTextTitleName(LSTR(1600019))
	self.CommEmpty:SetTipsContent(LSTR(1600027))
	self.CommSidebarFrameS_UIBP.CommonTitle:SetSubTitleIsVisible(false)
	self.CommSidebarFrameS_UIBP.CommonTitle:SetCommInforBtnIsVisible(false)
	self.CommSearchBar.TextInput:SetHintText(LSTR(1600020))
	self.CommSearchBar:SetCallback(self, self.SearchTextChangeCallback, self.SearchTextChangeCallback, self.SearchCancelCallback)
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	ViewModel:Update(self.Params)
end

function OpsConcertRecallWinView:SearchTextChangeCallback(Text)
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	ViewModel:BindPlayerVMListWithText(Text)
end

function OpsConcertRecallWinView:SearchCancelCallback()
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	ViewModel:ShowAllPlayer()
end

function OpsConcertRecallWinView:OnHide()

end

function OpsConcertRecallWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnRefresh, self.OnClickBtnRefresh)
end

function OpsConcertRecallWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.OnActivityUpdateInfo)
end

function OpsConcertRecallWinView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsConcertRecallWinView:OnActivityUpdateInfo(MsgBody)
	if MsgBody == nil or MsgBody.NodeOperate == nil or MsgBody.NodeOperate.Result == nil then
		return
	end
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	--- 检查是否是拉回流活动的节点更新
	local ActivityDetail = MsgBody.NodeOperate.ActivityDetail
	if ViewModel.ActivityID ~= ActivityDetail.Head.ActivityID then
		return
	end
	local OpType = MsgBody.NodeOperate.OpType
	if OpType == ProtoCS.Game.Activity.NodeOpType.NodeOpTypePullBindRole then
		self:OnRecieveBindRoleInfo(MsgBody)
	end
end

function OpsConcertRecallWinView:OnRecieveBindRoleInfo(MsgBody)
	local Result = MsgBody.NodeOperate.Result or {}
	local ParamsType = Result.Data or "BindAccount"
	local RoleData = Result[ParamsType] and Result[ParamsType].BindRole or {}
	self.ViewModel:UpdateBindPlayerVMList(RoleData)
end

function OpsConcertRecallWinView:OnClickBtnRefresh()
	--清空搜索框
	self.CommSearchBar:SetText("")
	--刷新列表
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	--- 发送拉取绑定玩家列表的请求
	_G.OpsActivityMgr:SendActivityNodeOperate(self.ViewModel.GetInviteListNodeID, ProtoCS.Game.Activity.NodeOpType.NodeOpTypePullBindRole, {})
end
return OpsConcertRecallWinView