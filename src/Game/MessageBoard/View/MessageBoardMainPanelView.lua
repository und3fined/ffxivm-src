---
--- Author: jamiyang
--- DateTime: 2023-08-10 09:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local EventMgr = _G.EventMgr
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local BoardMgr = _G.BoardMgr
local LSTR = _G.LSTR
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local BoardVM = require("Game/MessageBoard/VM/BoardVM")
local MessageBoardPanelVM = require("Game/MessageBoard/VM/MessageBoardPanelVM")

---@class MessageBoardMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInput UFButton
---@field BtnMask UFButton
---@field CloseBtn CommonCloseBtnView
---@field TableViewMsgList UTableView
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY

---@field Params table @通过外部参数传入
---@field Params.BoardTypeID integer @留言板类型
---@field Params.SelectObjectID integer @图鉴物品ID

local MessageBoardMainPanelView = LuaClass(UIView, true)

function MessageBoardMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInput = nil
	--self.BtnMask = nil
	--self.CloseBtn = nil
	--self.TableViewMsgList = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MessageBoardMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MessageBoardMainPanelView:OnInit()
	self.ViewModel = MessageBoardPanelVM.New()

	--留言板列表
	self.BoardTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewMsgList, self.OnBoardTableViewSelectChange, false)
	self.BoardTableView:SetScrollbarIsVisible(true)

	--self.BtnInput:SetCallback(self, nil, self.OnBoardInput)
	self.IsInputAnonymous = false
end

function MessageBoardMainPanelView:OnDestroy()
end

function MessageBoardMainPanelView:OnShow()
	BoardVM.BoardList = nil
	BoardVM.CurBoardTypeID = self.Params.BoardTypeID
	BoardVM.CurObjectID = self.Params.SelectObjectID
	EventMgr:SendEvent(EventID.BoardObjectChange, self.Params.SelectObjectID)
end

function MessageBoardMainPanelView:OnHide()
	BoardVM.BoardList = nil
	self.ViewModel:UnInitData()
	self.MaskCloseFunc = self.Params.MaskCloseFunc
	self.HostVM = self.Params.HostVM
	--BoardVM:ClearNew()
end

function MessageBoardMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnInput, self.OnBoardInput)
	UIUtil.AddOnClickedEvent(self, self.BtnMask, self.OnBtnMaskClick)
end

function MessageBoardMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BoardObjectChange, self.OnBoardDataChange)
	self:RegisterGameEvent(EventID.BoardRefreshList, self.OnBoardListChange)
end

function MessageBoardMainPanelView:OnRegisterBinder()
	local Binders = {
		--{ "BoardListSlotVM", UIBinderUpdateBindableList.New(self, self.BoardTableView) },
		{ "ExistListSlotVM", UIBinderUpdateBindableList.New(self, self.BoardTableView) },
	}
	self:RegisterBinders(self.ViewModel, Binders)

	--local Binders1 = {
		--{ "BoardList", UIBinderValueChangedCallback.New(self, nil, self.OnBoardListChange) },
	--}
	--self:RegisterBinders(BoardVM, Binders1)
end


-- 监听EventID.BoardObjectChange事件的回调
function MessageBoardMainPanelView:OnBoardDataChange(Params)
	BoardVM.BoardList = nil
	BoardVM.CurObjectID = Params
	local QueryParams = { TypeID = self.Params.BoardTypeID, ObjectID = Params}
	BoardMgr:SendMsgBoardQuery(QueryParams)
end

-- BoardList数据更新的回调
function MessageBoardMainPanelView:OnBoardListChange(Param)
	self.ViewModel:UpdateBoardList(Param)
end

-- 列表选中项更改的回调
function MessageBoardMainPanelView:OnBoardTableViewSelectChange(Index, ItemData, ItemView)
	-- body
end

-- 点击输入框的回调
function MessageBoardMainPanelView:OnBoardInput()
	--- 打开输入框弹框，让玩家输入留言后之后，发送请求
	local Callback1 = function(InputText)
		if InputText == nil or #InputText < 1 then return end
		-- 获取查询参数
		local MajorServerID = MajorUtil.GetMajorWorldID()
		local CreateParams = {ServerID = MajorServerID, TypeID = self.Params.BoardTypeID, ObjectID = BoardVM.CurObjectID,
		                      Content = InputText, IsAnoymour = self.IsInputAnonymous}
		BoardMgr:SendMsgBoardCreate(CreateParams)
	end
	local Callback2 = function(IsChecked)
		self.IsInputAnonymous = IsChecked
	end
    local Params = {
            HintText = LSTR("点击输入留言"),
            MaxTextLength = 40,
            SureCallback = Callback1,
			GetAnonymousCallback = Callback2
    }
    UIViewMgr:ShowView(UIViewID.MessageBoardPublishWin, Params)
end

function MessageBoardMainPanelView:OnBtnMaskClick()
	if self.MaskCloseFunc then
		self:MaskCloseFunc(self.HostVM)
	end
end

return MessageBoardMainPanelView