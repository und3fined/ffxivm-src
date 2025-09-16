---
--- Author: richyczhou
--- DateTime: 2024-06-25 10:00
--- Description:
---

local CommonUtil = require("Utils/CommonUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local LoginMapleVM = require("Game/LoginNew/VM/LoginMapleVM")
local LoginNewVM = require("Game/LoginNew/VM/LoginNewVM")
local LoginMgr = require("Game/Login/LoginMgr")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIUtil = require("Utils/UIUtil")
local UIView = require("UI/UIView")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID

local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_ERROR
local FLOG_ERROR = _G.FLOG_ERROR
local ObjectPoolMgr = _G.ObjectPoolMgr
local LSTR = _G.LSTR

---@class LoginNewSeverPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field LoginRoleBackPage LoginCreateBackPageView
---@field PanelEmpty UFCanvasPanel
---@field TableViewFriendsSever UTableView
---@field TableViewPreviewMenu UTableView
---@field TableViewPreviewMenuALL UTableView
---@field TableViewSever UTableView
---@field TableViewSeverAll UTableView
---@field TableViewState UTableView
---@field TextEmpty UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewSeverPanelView = LuaClass(UIView, true)

function LoginNewSeverPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.LoginRoleBackPage = nil
	--self.PanelEmpty = nil
	--self.TableViewFriendsSever = nil
	--self.TableViewPreviewMenu = nil
	--self.TableViewPreviewMenuALL = nil
	--self.TableViewSever = nil
	--self.TableViewSeverAll = nil
	--self.TableViewState = nil
	--self.TextEmpty = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewSeverPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.LoginRoleBackPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewSeverPanelView:OnInit()
	--FLOG_INFO("LoginNewSeverPanelView:OnInit")
	DataReportUtil.ReportLoginFlowData(_G.UE.EDataReportLoginPhase.SelectServer)
	_G.UE.UGPMMgr.Get():PostLoginStepEvent(_G.UE.EDataReportLoginPhase.SelectServer, 0, 0, "success", "", false, false)

	---@type LoginMapleVM
	self.LoginMapleVM = ObjectPoolMgr:AllocObject(LoginMapleVM)
	--self.LoginMapleVM = LoginMapleVM.New()

	self.StateTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewState)
	self.TypeTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPreviewMenu, self.OnTypeTabItemSelectChanged, true)
	self.RecommendMyTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSever)
	self.GroupTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPreviewMenuALL, self.OnGroupItemSelectChanged, true)
	self.NodeTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSeverAll)
	self.FriendTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewFriendsSever)

	self.Binders = {
		{ "ServerStateList", UIBinderUpdateBindableList.New(self, self.StateTableViewAdapter) },
		{ "TabList", UIBinderUpdateBindableList.New(self, self.TypeTableViewAdapter) },
		{ "RecommendOrMyList", UIBinderUpdateBindableList.New(self, self.RecommendMyTableViewAdapter) },
		{ "ServerGroupList", UIBinderUpdateBindableList.New(self, self.GroupTableViewAdapter) },
		{ "ServerList", UIBinderUpdateBindableList.New(self, self.NodeTableViewAdapter) },
		-- 好友服务器列表
		{ "FriendServerList", UIBinderUpdateBindableList.New(self, self.FriendTableViewAdapter) },

		{ "RecommendOrMineType", UIBinderSetIsVisible.New(self, self.TableViewSever) },
		{ "FriendType", UIBinderSetIsVisible.New(self, self.TableViewFriendsSever) },
		{ "AllListType", UIBinderSetIsVisible.New(self, self.TableViewPreviewMenuALL) },
		{ "AllListType", UIBinderSetIsVisible.New(self, self.TableViewSeverAll) },
	}
end

function LoginNewSeverPanelView:OnDestroy()

end

function LoginNewSeverPanelView:OnShow()
	FLOG_INFO("LoginNewSeverPanelView:OnShow")

	self.LoginMapleVM:InitMapleData()
	self.LoginMapleVM:InitMyServerData()
	self.LoginMapleVM:InitFriendServerData()

	local CurWorldID = LoginNewVM.WorldID
	for Idx, ServerListItem in ipairs(self.LoginMapleVM.RecommendListData) do
		if ServerListItem.WorldID == CurWorldID then
			self.LoginMapleVM.RecommendIndex = Idx
			--FLOG_INFO("LoginNewSeverPanelView:OnShow RecommendIndex:%d", Idx)
			break
		end
	end

	for GroupIndex, Group in ipairs(self.LoginMapleVM.ServerGroup) do
		local IsFind = false
		---@type ServerTreeItem
		local ServerTree = self.LoginMapleVM.ServerTree[Group.GroupID] or {}
		for _, Server in ipairs(ServerTree.ServerList) do
			if Server.WorldID == CurWorldID then
				IsFind = true
				self.LoginMapleVM.GroupIndex = GroupIndex
				self.LoginMapleVM.ServerIndex = Server.Index
				break
			end
		end

		if IsFind then
			break
		end
	end

	self.LoginRoleBackPage.TextTitle:SetText(LSTR(LoginStrID.SelectServer))
	-- 服务状态示例
	self.LoginMapleVM:UpdateServerState()
	-- 服务类型列表
	self.LoginMapleVM:UpdateTab()

	-- 点击默认选反区服，如果有我的服务器数据则打开我的服务器列表，否则打开推荐服务器列表
	-- 点击好友同玩列表，打开好友服务器列表
	local Params = self.Params
	local Index = Params and Params.Index
	if not Index then
		if self.LoginMapleVM.MyServerListData and #self.LoginMapleVM.MyServerListData > 0 then
			Index = 2
		else
			Index = 1
		end
	end
	self.TypeTableViewAdapter:SetSelectedIndex(Index)
end

function LoginNewSeverPanelView:OnHide()

end

function LoginNewSeverPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.LoginRoleBackPage.BtnBack, self.OnClickBackBtn)
end

function LoginNewSeverPanelView:OnRegisterGameEvent()

end

function LoginNewSeverPanelView:OnRegisterBinder()
	self:RegisterBinders(self.LoginMapleVM, self.Binders)
end

function LoginNewSeverPanelView:OnClickBackBtn()
	_G.EventMgr:SendEvent(_G.EventID.LoginShowMainPanel)
	self:Hide()
end

---OnItemSelectChanged
---@param Index number
---@param ItemData any
---@param ItemView UIView
function LoginNewSeverPanelView:OnTypeTabItemSelectChanged(Index, ItemData, ItemView)
	FLOG_INFO("LoginNewSeverPanelView:OnTypeTabItemSelectChanged Index:%d", Index)
	self.LoginMapleVM.TabIndex = Index

	local IsShowRecommendList = false
	local IsShowMyList = false
	local IsShowFriendList = false
	local IsShowAllServerList = false
	if CommonUtil.IsInternationalChina() then
		self.LoginMapleVM.RecommendOrMineType = LoginNewDefine.MapleTabTypeCN.Recommend == Index or LoginNewDefine.MapleTabTypeCN.Mine == Index
		self.LoginMapleVM.FriendType = LoginNewDefine.MapleTabTypeCN.Friend == Index
		self.LoginMapleVM.AllListType = LoginNewDefine.MapleTabTypeCN.All == Index

		if LoginNewDefine.MapleTabTypeCN.Recommend == Index then
			IsShowRecommendList = true
			self.LoginRoleBackPage.TextSubtile:SetText(LSTR(LoginStrID.SvrRecommend))
		elseif LoginNewDefine.MapleTabTypeCN.Mine == Index then
			-- 我的服务器列表
			IsShowMyList = true
			self.LoginRoleBackPage.TextSubtile:SetText(LSTR(LoginStrID.SvrMine))
		elseif LoginNewDefine.MapleTabTypeCN.Friend == Index then
			-- 好友服务器列表
			IsShowFriendList = true
			self.LoginRoleBackPage.TextSubtile:SetText(LSTR(LoginStrID.SvrFriend))
		elseif LoginNewDefine.MapleTabTypeCN.All == Index then
			IsShowAllServerList = true
			self.LoginRoleBackPage.TextSubtile:SetText(LSTR(LoginStrID.SvrAllList))
		end
	else
		self.LoginMapleVM.RecommendOrMineType = LoginNewDefine.MapleTabTypeOversea.Recommend == Index
		self.LoginMapleVM.AllListType = LoginNewDefine.MapleTabTypeOversea.All == Index

		if LoginNewDefine.MapleTabTypeOversea.Recommend == Index then
			IsShowRecommendList = true
			self.LoginRoleBackPage.TextSubtile:SetText(LSTR(LoginStrID.SvrRecommend))
		elseif LoginNewDefine.MapleTabTypeOversea.All == Index then
			IsShowAllServerList = true
			self.LoginRoleBackPage.TextSubtile:SetText(LSTR(LoginStrID.SvrAllList))
		end
	end

	if IsShowRecommendList then
		self:UpdateRecommendList()
	end

	if IsShowMyList then
		self:UpdateMyServerList()
	end

	if IsShowFriendList then
		self:UpdateFriendServerList()
	end

	if IsShowAllServerList then
		self.LoginMapleVM:UpdateServerGroup()
		self.GroupTableViewAdapter:SetSelectedIndex(self.LoginMapleVM.GroupIndex)
		self.GroupTableViewAdapter:ScrollToIndex(self.LoginMapleVM.GroupIndex)
		self:UpdateServerList(self.LoginMapleVM.GroupIndex)
	end
end

---OnItemSelectChanged
---@param Index number
---@param ItemData any
---@param ItemView UIView
function LoginNewSeverPanelView:OnGroupItemSelectChanged(Index, ItemData, ItemView)
	--FLOG_INFO("LoginNewSeverPanelView:OnGroupItemSelectChanged Index:%d", Index)
	self:UpdateServerList(Index)
end

function LoginNewSeverPanelView:UpdateRecommendList()
	FLOG_INFO("[LoginNewSeverPanelView:UpdateRecommendList] RecommendIndex:%d", self.LoginMapleVM.RecommendIndex)
	UIUtil.SetIsVisible(self.PanelEmpty, false)
	self.LoginMapleVM:UpdateRecommendList()
	if self.LoginMapleVM.RecommendIndex > 0 then
		self.RecommendMyTableViewAdapter:SetSelectedIndex(self.LoginMapleVM.RecommendIndex)
		self.RecommendMyTableViewAdapter:ScrollToIndex(self.LoginMapleVM.RecommendIndex)
	end
end

function LoginNewSeverPanelView:UpdateMyServerList()
	FLOG_INFO("LoginNewSeverPanelView:UpdateMyServerList")
	self.LoginMapleVM:UpdateMyServerList()

	if self.LoginMapleVM.MyServerListData and next(self.LoginMapleVM.MyServerListData) ~= nil then
		UIUtil.SetIsVisible(self.PanelEmpty, false)
	else
		UIUtil.SetIsVisible(self.PanelEmpty, true)
		self.TextEmpty:SetText(LSTR(LoginStrID.EmptyMyServer))
	end
end

function LoginNewSeverPanelView:UpdateFriendServerList()
	FLOG_INFO("LoginNewSeverPanelView:UpdateFriendServerList")
	self.LoginMapleVM:UpdateFriendServerList()

	if self.LoginMapleVM.FriendServerListData and next(self.LoginMapleVM.FriendServerListData) ~= nil then
		UIUtil.SetIsVisible(self.PanelEmpty, false)
	else
		UIUtil.SetIsVisible(self.PanelEmpty, true)
		self.TextEmpty:SetText(LSTR(LoginStrID.EmptyFriends))
	end
end

function LoginNewSeverPanelView:UpdateServerList(Index)
	UIUtil.SetIsVisible(self.PanelEmpty, false)

	local Group = self.LoginMapleVM.ServerGroup[Index]
	if Group then
		self.LoginMapleVM:UpdateServerList(Group.GroupID)
		if self.LoginMapleVM.GroupIndex == Index then
			local ServerIndex = self.LoginMapleVM.ServerIndex
			--FLOG_INFO("[LoginNewSeverPanelView:UpdateServerList] Index:%d", ServerIndex)
			self.NodeTableViewAdapter:SetSelectedIndex(ServerIndex)
			self.NodeTableViewAdapter:ScrollToIndex(ServerIndex)
		else
			self.NodeTableViewAdapter:ClearSelectedItem()
			self.NodeTableViewAdapter:ScrollToIndex(1)
		end
	else
		FLOG_WARNING("[LoginNewSeverPanelView:UpdateServerList] Can't found ServerGroup by %d", Index)
	end
end

return LoginNewSeverPanelView