---
--- Author: xingcaicao
--- DateTime: 2024-06-29 15:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local FriendVM = require("Game/Social/Friend/FriendVM")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local TipsUtil = require("Utils/TipsUtil")
local FriendMgr = require("Game/Social/Friend/FriendMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CommPlayerDefine = require("Game/Common/Player/CommPlayerDefine")

local StateType = CommPlayerDefine.StateType
local StateIcon = CommPlayerDefine.StateIcon
local FVector2D = _G.UE.FVector2D

---@class FriendGroupManageFriendItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSwitchGroup UFButton
---@field HorizontalServer UFHorizontalBox
---@field ImgOnlineStatus UFImage
---@field ImgStateIcon UFImage
---@field ProfSlot CommPlayerSimpleJobSlotView
---@field Server USizeBox
---@field SingleBox CommSingleBoxView
---@field StateIconPanel USizeBox
---@field TextPlayerName URichTextBox
---@field TextServer UFTextBlock
---@field TextState UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FriendGroupManageFriendItemView = LuaClass(UIView, true)

function FriendGroupManageFriendItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSwitchGroup = nil
	--self.HorizontalServer = nil
	--self.ImgOnlineStatus = nil
	--self.ImgStateIcon = nil
	--self.ProfSlot = nil
	--self.Server = nil
	--self.SingleBox = nil
	--self.StateIconPanel = nil
	--self.TextPlayerName = nil
	--self.TextServer = nil
	--self.TextState = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FriendGroupManageFriendItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ProfSlot)
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FriendGroupManageFriendItemView:OnInit()
	self.Binders = {
		{ "Name", 				UIBinderSetText.New(self, self.TextPlayerName) },

		{ "State", 				UIBinderSetText.New(self, self.TextState) },
		{ "StateType", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedSateType) },

		{ "OnlineStatusIcon",	UIBinderSetBrushFromAssetPath.New(self, self.ImgOnlineStatus) },
	}
end

function FriendGroupManageFriendItemView:OnDestroy()

end

function FriendGroupManageFriendItemView:OnShow()
	self:UpdateSingleBoxState()
end

function FriendGroupManageFriendItemView:OnHide()

end

function FriendGroupManageFriendItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnToggleStateChanged)

	UIUtil.AddOnClickedEvent(self, self.BtnSwitchGroup, self.OnClickButtonSwitchGroup)
end

function FriendGroupManageFriendItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.FriendBatchSwitchGroupUpdate, self.OnGameEventBatchSwitchGroupUpdate)
end

function FriendGroupManageFriendItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local EntryVM = Params.Data
	self.ViewModel = EntryVM 

	self:RegisterBinders(EntryVM, self.Binders)
end

function FriendGroupManageFriendItemView:UpdateSingleBoxState( )
	local EntryVM = self.ViewModel
	if EntryVM then
		local b = FriendVM:IsInBatchSwitch(EntryVM.RoleID)
		self.SingleBox:SetChecked(b, false)
	end
end

function FriendGroupManageFriendItemView:CloseJumpWayTipsWin()
	local ID = UIViewID.CommJumpWayTipsView
	if UIViewMgr:IsViewVisible(ID) then
		UIViewMgr:HideView(ID)
	end
end

function FriendGroupManageFriendItemView:OnClickedSwitchGroupItem(ItemData)
	if nil == ItemData then
		return
	end

	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	local CurGroupID = self.ViewModel.GroupID
	local TargetGroupID = ItemData.Data.ID
	if CurGroupID == TargetGroupID then
		return
	end

	FriendMgr:SendFriendsMoveGroupMsg({ViewModel.RoleID}, TargetGroupID)

	self:CloseJumpWayTipsWin()
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function FriendGroupManageFriendItemView:OnGameEventBatchSwitchGroupUpdate( )
	self:UpdateSingleBoxState()
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function FriendGroupManageFriendItemView:OnToggleStateChanged(ToggleButton, State)
	local EntryVM = self.ViewModel
	if nil == EntryVM then
		return
	end

	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if IsChecked then
		FriendVM:AddBatchSwitch(EntryVM.RoleID)
	else
		FriendVM:RemoveBatchSwitch(EntryVM.RoleID)
	end
end

function FriendGroupManageFriendItemView:OnClickButtonSwitchGroup()
	local TargetNode = self.BtnSwitchGroup
	if nil == TargetNode then
		return
	end

	self:CloseJumpWayTipsWin()

	local CurGroupID = (self.ViewModel or {}).GroupID
	local Data = FriendVM:GetSwitchGroupJumpList(CurGroupID, self.OnClickedSwitchGroupItem, self) 
	local Size = UIUtil.GetLocalSize(TargetNode)
	TipsUtil.ShowJumpToTips({ Data = Data }, TargetNode, FVector2D(-(Size.X), 10), FVector2D(1, 0))
end

function FriendGroupManageFriendItemView:OnValueChangedSateType(NewValue)
	NewValue = NewValue or StateType.None

	local Icon = StateIcon[NewValue]
	if string.isnilorempty(Icon) then
		UIUtil.SetIsVisible(self.StateIconPanel, false)
	else
		UIUtil.ImageSetBrushFromAssetPath(self.ImgStateIcon, Icon)
		UIUtil.SetIsVisible(self.StateIconPanel, true)
	end
end

-- TableView回调
function FriendGroupManageFriendItemView:OnItemUpdate()
	self:UpdateSingleBoxState()
end

return FriendGroupManageFriendItemView