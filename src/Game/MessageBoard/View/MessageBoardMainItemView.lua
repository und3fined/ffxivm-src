---
--- Author: jamiyang
--- DateTime: 2023-08-10 09:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetButtonBrush = require("Binder/UIBinderSetButtonBrush")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local BoardVM = require("Game/MessageBoard/VM/BoardVM")
local BoardMgr = _G.BoardMgr
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

---@class MessageBoardMainItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDelete UFButton
---@field BtnPick UFButton
---@field BtnReport UFButton
---@field ImgBar UFImage
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field TextMsg UFTextBlock
---@field TextOther UFTextBlock
---@field TextPickValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MessageBoardMainItemView = LuaClass(UIView, true)

function MessageBoardMainItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDelete = nil
	--self.BtnPick = nil
	--self.BtnReport = nil
	--self.ImgBar = nil
	--self.PlayerHeadSlot = nil
	--self.TextMsg = nil
	--self.TextOther = nil
	--self.TextPickValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MessageBoardMainItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerHeadSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MessageBoardMainItemView:OnInit()

end

function MessageBoardMainItemView:OnDestroy()

end

function MessageBoardMainItemView:OnShow()

end

function MessageBoardMainItemView:OnHide()

end

function MessageBoardMainItemView:OnRegisterUIEvent()

end

function MessageBoardMainItemView:OnRegisterGameEvent()
	--UIUtil.AddOnClickedEvent(self, self.ToggleBtnItem, self.OnClickButtonItem)
	UIUtil.AddOnClickedEvent(self, self.BtnPick, self.OnClickPickButton)
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnClickDeleteButton)
	UIUtil.AddOnClickedEvent(self, self.BtnReport, self.OnClickReportButton)
end

function MessageBoardMainItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	--local ViewModel = Params.ViewModel
	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel
	self.PlayerHeadSlot:UpdateIcon(ViewModel.PlayerID)
	local Binders = {
		{ "PlayerInf", UIBinderSetText.New(self, self.TextOther) },
		{ "BoardContent", UIBinderSetText.New(self, self.TextMsg)},
		{ "LikeNum", UIBinderSetText.New(self, self.TextPickValue)},
		--{ "IsSelfCreate", UIBinderSetIsVisible.New(self, self.ImgBar)},
		{ "IsCanDelete", UIBinderSetIsVisible.New(self, self.BtnDelete, false, true)},
		{ "IsCanReport", UIBinderSetIsVisible.New(self, self.BtnReport, false, true)},
		--点赞图标状态绑定
		{ "LikeIcon", UIBinderSetButtonBrush.New(self, self.BtnPick, nil) },
		{ "PlayerInf", UIBinderValueChangedCallback.New(self, nil, self.OnPlayerChange) },
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function MessageBoardMainItemView:OnPlayerChange()
	self.PlayerHeadSlot:UpdateIcon(self.ViewModel.PlayerID)
end

function MessageBoardMainItemView:OnClickPickButton()
	-- if self.ViewModel.IsSelfCreate then return end
	local PickParams = {TypeID = BoardVM.CurBoardTypeID, ObjectID = BoardVM.CurObjectID, PlayerID = self.ViewModel.PlayerID}
	if self.ViewModel.IsSelfLike then
		BoardMgr:SendMsgBoardUnLike(PickParams)
	else
		BoardMgr:SendMsgBoardLike(PickParams)
	end
end

function MessageBoardMainItemView:OnClickDeleteButton()
	-- if not self.ViewModel.IsSelfCreate then return end
	local Title = nil
	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, Title, _G.LSTR("确定删除留言？"), self.OnTipsSureDelete)
end

function MessageBoardMainItemView:OnTipsSureDelete()
	local DelParams = {TypeID = BoardVM.CurBoardTypeID, ObjectID = BoardVM.CurObjectID, PlayerID = self.ViewModel.PlayerID}
	BoardMgr:SendMsgBoardDel(DelParams)
end

function MessageBoardMainItemView:OnClickReportButton()
	--local ReportParams = {TypeID = BoardVM.CurBoardTypeID, ObjectID = BoardVM.CurObjectID, PlayerID = self.ViewModel.PlayerID}
	--BoardMgr:SendMsgBoardReport(ReportParams)
	-- 接入举报界面
	local Params = { ReporteeRoleID = ((self.ViewModel or {}).RoleVM or {}).RoleID }
	_G.ReportMgr:OpenViewBySpeech(Params)
end

return MessageBoardMainItemView