---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local TipsUtil = require("Utils/TipsUtil")
local FriendVM = require("Game/Social/Friend/FriendVM")
local FriendMgr = require("Game/Social/Friend/FriendMgr")
local FriendDefine = require("Game/Social/Friend/FriendDefine")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local LSTR = _G.LSTR
local FVector2D = _G.UE.FVector2D
local DefaultGroupID = FriendDefine.DefaultGroupID
local TextCommitOnEnter = _G.UE.ETextCommit.OnEnter

local TitlePreStr = LSTR(30040) --"批量处理"

---@class FriendGroupManageWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameLView
---@field BtnBatchSwitch UFButton
---@field BtnDelete UFButton
---@field InputName CommInputBoxView
---@field PanelDelete UFCanvasPanel
---@field PanelEmptyFriend UFCanvasPanel
---@field PanelEmptyGroup UFCanvasPanel
---@field PanelFriends UFCanvasPanel
---@field PanelGroupInfo UFCanvasPanel
---@field PanelGroupOper UFCanvasPanel
---@field PanelMenu UFCanvasPanel
---@field SingleBoxAll CommSingleBoxView
---@field TableViewFriendList UTableView
---@field TableViewGroupList UTableView
---@field TextAllSelect UFTextBlock
---@field TextBatchTitle UFTextBlock
---@field TextDelete UFTextBlock
---@field TextEmptyFriend UFTextBlock
---@field TextEmptyGroup UFTextBlock
---@field TextRenameTips UFTextBlock
---@field AnimChangeMenu UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FriendGroupManageWinView = LuaClass(UIView, true)

function FriendGroupManageWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnBatchSwitch = nil
	--self.BtnDelete = nil
	--self.InputName = nil
	--self.PanelDelete = nil
	--self.PanelEmptyFriend = nil
	--self.PanelEmptyGroup = nil
	--self.PanelFriends = nil
	--self.PanelGroupInfo = nil
	--self.PanelGroupOper = nil
	--self.PanelMenu = nil
	--self.SingleBoxAll = nil
	--self.TableViewFriendList = nil
	--self.TableViewGroupList = nil
	--self.TextAllSelect = nil
	--self.TextBatchTitle = nil
	--self.TextDelete = nil
	--self.TextEmptyFriend = nil
	--self.TextEmptyGroup = nil
	--self.TextRenameTips = nil
	--self.AnimChangeMenu = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FriendGroupManageWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.InputName)
	self:AddSubView(self.SingleBoxAll)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FriendGroupManageWinView:OnInit()
	self.TableAdapterGroupList = UIAdapterTableView.CreateAdapter(self, self.TableViewGroupList, self.OnSelectChangedGroupItem)
	self.TableAdapterFriendList = UIAdapterTableView.CreateAdapter(self, self.TableViewFriendList)

	self.InputName:SetCallback(self, nil, self.OnInputTextCommitted)

	self.Binders = {
		{ "IsCheckedSingleBoxAll", 		UIBinderSetIsChecked.New(self, self.SingleBoxAll, false) },
        { "BtnBatchSwitchEnabled", 		UIBinderSetIsEnabled.New(self, self.BtnBatchSwitch)},
        { "IsDeleteGrouping", 			UIBinderSetIsEnabled.New(self, self.PanelMenu, true)},
		{ "GroupManageVMList", 		 	UIBinderUpdateBindableList.New(self, self.TableAdapterGroupList) },
		{ "GroupManageFriendVMList", 	UIBinderUpdateBindableList.New(self, self.TableAdapterFriendList) },
		{ "CreateGroupCount", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCreateGroupCount) },
	}
end

function FriendGroupManageWinView:OnDestroy()

end

function FriendGroupManageWinView:OnShow()
	self:InitConstText()

	self.CurGroupData = nil

	--- 重置分组管理信息
	FriendVM:ResetGroupManageInfo()

	if FriendVM.GroupManageVMList:Length() > 1 then
		self.TableAdapterGroupList:SetSelectedIndex(1)
	end
end

function FriendGroupManageWinView:OnHide()
	self.TableAdapterGroupList:CancelSelected()

	self:CloseJumpWayTipsWin(true)
	FriendVM:ClearGroupManageData()
end

function FriendGroupManageWinView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBoxAll, self.OnToggleStateChangedAll)

	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnClickButtonDelete)
	UIUtil.AddOnClickedEvent(self, self.BtnBatchSwitch, self.OnClickButtonBatchSwitch)
end

function FriendGroupManageWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.FriendGroupInfoUpdate, self.OnGameEventGroupInfoUpdate)
	self:RegisterGameEvent(EventID.FriendTransGroup, self.OnGameEventTransGroup)
	self:RegisterGameEvent(EventID.FriendBatchSwitchGroupUpdate, self.OnGameEventBatchSwitchGroupUpdate)
end

function FriendGroupManageWinView:OnRegisterBinder()
	self:RegisterBinders(FriendVM, self.Binders)
end

function FriendGroupManageWinView:InitConstText()
	if self.IsInitConstText then
		return
	end

	self.IsInitConstText = true

	self.Bg:SetTitleText(LSTR(30045)) -- "管理分组"
	self.TextRenameTips:SetText(LSTR(30047)) -- "分组命名"
	self.InputName:SetHintText(LSTR(30048)) -- "请输入分组名称"
	self.TextDelete:SetText(LSTR(30049)) -- "删除分组"
	self.TextEmptyFriend:SetText(LSTR(30050)) -- "分组下暂无好友"
	self.TextAllSelect:SetText(LSTR(10006)) -- "全选"
	self.TextEmptyGroup:SetText(LSTR(30051)) -- "暂无好友分组"
end

function FriendGroupManageWinView:UpdateFriendListInfo()
	-- 好友列表
	local FriendsCount = FriendVM.GroupManageFriendVMList:Length()
	local IsEmpty = FriendsCount <= 0

	UIUtil.SetIsVisible(self.PanelFriends, not IsEmpty)
	UIUtil.SetIsVisible(self.PanelEmptyFriend, IsEmpty)
end

function FriendGroupManageWinView:UpdateBatchTitle()
	local CurNum = #(FriendVM.CurBatchSwitchRoleIDs or {})
	local MaxNum = FriendVM.GroupManageFriendVMList:Length()
	local Title = string.format("%s %s/%s", TitlePreStr, CurNum, MaxNum)
	self.TextBatchTitle:SetText(Title)
end

function FriendGroupManageWinView:OnSelectChangedGroupItem(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	local GroupID = ItemData.ID 
	if nil == GroupID then
		local Data = self.CurGroupData
		if Data then
			local Idx = self.TableAdapterGroupList:GetItemDataIndex(Data)
			if Idx then
				self.TableAdapterGroupList:SetSelectedIndex(Idx)
				self.TableAdapterGroupList:ScrollToIndex(Idx)
			end
		end

		if not FriendVM.IsCreateGrouping then
			FriendVM.IsCreateGrouping = true 

			local Name = FriendVM:GetNewGroupDefaultName()
			FriendMgr:SendFriendsCreateGroupMsg(Name)
		end

		return
	else
		if self.CurGroupData == ItemData then
			return
		end

		self.CurGroupData = ItemData
		FriendVM:UpdateGroupManageFriendVMList(GroupID)
	end

	self:CloseJumpWayTipsWin()

	-- 清理小组调整数据
    FriendVM:ClearGroupSwitchData()

	-- 更新好友列表信息
	self:UpdateFriendListInfo()

	-- 批处理标题
	self:UpdateBatchTitle()

	-- 分组操作
	local IsDefaultGroup = GroupID == DefaultGroupID
	UIUtil.SetIsVisible(self.PanelDelete, not IsDefaultGroup)
	UIUtil.SetIsVisible(self.TextRenameTips, not IsDefaultGroup)

	self.InputName:SetIsHideNumber(IsDefaultGroup)
	self.InputName:SetIsReadOnly(IsDefaultGroup)
	self.InputName:SetText(ItemData.Name or "")

	-- 播放动效
	self:PlayAnimation(self.AnimChangeMenu)
end

function FriendGroupManageWinView:OnValueChangedCreateGroupCount(NewValue)
	local IsCreateGroup = NewValue > 0 
	UIUtil.SetIsVisible(self.PanelGroupInfo, IsCreateGroup)
	UIUtil.SetIsVisible(self.PanelEmptyGroup, not IsCreateGroup)
end

function FriendGroupManageWinView:CloseJumpWayTipsWin(bForceHide)
	local ID = UIViewID.CommJumpWayTipsView
	if bForceHide or UIViewMgr:IsViewVisible(ID) then
		UIViewMgr:HideView(ID)
	end
end

---@param InputText string @回调的文本
function FriendGroupManageWinView:OnInputTextCommitted(InputText, CommitMethod)
	if CommitMethod ~= TextCommitOnEnter then
		return
	end

	local Group = self.CurGroupData
	if Group and Group.ID then
		local Name = string.isnilorempty(InputText) and FriendVM:GetNewGroupDefaultName() or InputText
		FriendMgr:SendFriendsEditGroupMsg(Group.ID, Name)
	end
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function FriendGroupManageWinView:OnGameEventGroupInfoUpdate( )
	local VMList = FriendVM.GroupManageVMList
	local Group = self.CurGroupData
	if nil == Group then
		if VMList:Length() > 1 then
			self.TableAdapterGroupList:SetSelectedIndex(1)
			self.TableAdapterGroupList:ScrollToIndex(1)
		end

		return
	end

	-- 检测当前选择的分组是否被删除了
	local ID = Group.ID
	if ID and nil ~= VMList:Find(function(Item) return Item.ID == ID end) then
		return
	end

	if VMList:Length() < 2 then
		self.CurGroupData = nil
		self.TableAdapterGroupList:CancelSelected()
	else
		self.TableAdapterGroupList:SetSelectedIndex(1)
		self.TableAdapterGroupList:ScrollToIndex(1)
	end
end

function FriendGroupManageWinView:OnGameEventTransGroup(OldGroupIDs, NewGroupIDs)
	if nil == OldGroupIDs and nil == NewGroupIDs then
		return
	end

	local CurGroupID = (self.CurGroupData or {}).ID
	if nil == CurGroupID then
		return
	end

	if table.contain(OldGroupIDs, CurGroupID) or table.contain(NewGroupIDs, CurGroupID) then
		FriendVM:UpdateGroupManageFriendVMList(CurGroupID)

		-- 更新好友列表信息
		self:UpdateFriendListInfo()
	end

	self:UpdateBatchTitle()
end

function FriendGroupManageWinView:OnGameEventBatchSwitchGroupUpdate()
	-- 批处理标题
	self:UpdateBatchTitle()
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function FriendGroupManageWinView:OnToggleStateChangedAll(ToggleButton, State)
	FriendVM:SetAllSwitch(UIUtil.IsToggleButtonChecked(State))
end

function FriendGroupManageWinView:OnClickButtonDelete()
	local Group = self.CurGroupData
	if nil == Group then
		return
	end

	if FriendVM.IsDeleteGrouping then
		return
	end

	local Text1 = Group.Name
	local Text2 = string.format('<span color="#d1ba8e">%s</>', FriendDefine.DefaultGroupName) 

	-- "确定删除分组%s吗？组内好友将自动移至%s"
	local Content = string.format(LSTR(30041), Text1, Text2) 

    MsgBoxUtil.ShowMsgBoxTwoOp(
        self, 
        LSTR(30042), --"删除分组"
		Content,
        function() 
			FriendVM.IsDeleteGrouping = true 
			FriendMgr:SendFriendsRemoveGroupMsg(Group.ID)
        end,
        nil, LSTR(30043), LSTR(30044)) --"取消删除"、"确认删除"
end

function FriendGroupManageWinView:OnClickButtonBatchSwitch()
	local CurGroupID = (self.CurGroupData or {}).ID
	local Data = FriendVM:GetSwitchGroupJumpList(CurGroupID, self.OnClickedBatchSwitchGroupItem, self) 
	TipsUtil.ShowJumpToTips({ Data = Data }, self.BtnBatchSwitch, FVector2D(0, 10))
end

function FriendGroupManageWinView:OnClickedBatchSwitchGroupItem(ItemData)
	if nil == ItemData then
		return
	end

	local RoleIDs = FriendVM.CurBatchSwitchRoleIDs
	if nil == RoleIDs then
		return
	end

	local TargetGroupID = ItemData.Data.ID
	FriendMgr:SendFriendsMoveGroupMsg(RoleIDs, TargetGroupID)

	self:CloseJumpWayTipsWin()
end

return FriendGroupManageWinView