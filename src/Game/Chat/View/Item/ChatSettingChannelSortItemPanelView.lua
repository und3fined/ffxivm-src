---
--- Author: xingcaicao
--- DateTime: 2025-03-27 20:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChatVM = require("Game/Chat/ChatVM")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local LSTR = _G.LSTR

---@class ChatSettingChannelSortItemPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckBoxHide CommSingleBoxView
---@field CheckHidePanel UFCanvasPanel
---@field FBtnMoveDown UFButton
---@field FBtnMoveUp UFButton
---@field FBtnPinToBottom UFButton
---@field FBtnPinToTop UFButton
---@field FTextChannelName UFTextBlock
---@field FTextHide UFTextBlock
---@field FTextMoveDown UFTextBlock
---@field FTextMoveUp UFTextBlock
---@field ImgMoveDown UFImage
---@field ImgMoveUp UFImage
---@field ImgPinToBottom UFImage
---@field ImgPinToTop UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatSettingChannelSortItemPanelView = LuaClass(UIView, true)

function ChatSettingChannelSortItemPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckBoxHide = nil
	--self.CheckHidePanel = nil
	--self.FBtnMoveDown = nil
	--self.FBtnMoveUp = nil
	--self.FBtnPinToBottom = nil
	--self.FBtnPinToTop = nil
	--self.FTextChannelName = nil
	--self.FTextHide = nil
	--self.FTextMoveDown = nil
	--self.FTextMoveUp = nil
	--self.ImgMoveDown = nil
	--self.ImgMoveUp = nil
	--self.ImgPinToBottom = nil
	--self.ImgPinToTop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatSettingChannelSortItemPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CheckBoxHide)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatSettingChannelSortItemPanelView:OnInit()
	self.FTextHide:SetText(LSTR(50026)) -- "隐藏"
	self.FTextMoveUp:SetText(LSTR(50027)) -- "上移"
	self.FTextMoveDown:SetText(LSTR(50028)) -- "下移"

	self.Binders = {
		{ "Name", 	UIBinderSetText.New(self, self.FTextChannelName) },
		{ "CannotHide", UIBinderSetIsVisible.New(self, self.CheckHidePanel, true) },
		{ "IsHide", UIBinderSetIsChecked.New(self,self.CheckBoxHide)},

		{"NameColor", UIBinderSetColorAndOpacityHex.New(self, self.FTextChannelName)},
		{"MoveUpTextColor", UIBinderSetColorAndOpacityHex.New(self, self.FTextMoveUp)},
		{"MoveDownTextColor", UIBinderSetColorAndOpacityHex.New(self, self.FTextMoveDown)},

        {"TopImgPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgPinToTop)},
		{"BottomImgPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgPinToBottom)},
		{"MoveUpImgPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgMoveUp)},
		{"MoveDownImgPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgMoveDown)}
	}
end

function ChatSettingChannelSortItemPanelView:OnDestroy()

end

function ChatSettingChannelSortItemPanelView:OnShow()

end

function ChatSettingChannelSortItemPanelView:OnHide()

end

function ChatSettingChannelSortItemPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CheckBoxHide, self.OnToggleStateChanged)

	UIUtil.AddOnClickedEvent(self, self.FBtnPinToTop, self.OnClickButtonPinToTop)
	UIUtil.AddOnClickedEvent(self, self.FBtnPinToBottom, self.OnClickButtonPinToBottom)
	UIUtil.AddOnClickedEvent(self, self.FBtnMoveUp, self.OnClickButtonMoveUp)
	UIUtil.AddOnClickedEvent(self, self.FBtnMoveDown, self.OnClickButtonMoveDown)
end

function ChatSettingChannelSortItemPanelView:OnRegisterGameEvent()

end

function ChatSettingChannelSortItemPanelView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local ViewModel = Params.Data
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function ChatSettingChannelSortItemPanelView:OnToggleStateChanged(ToggleButton, State)
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end	

	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	ViewModel:SetIsHide(IsChecked)
end

---置顶
function ChatSettingChannelSortItemPanelView:OnClickButtonPinToTop()
	local CurItem = self.ViewModel
	if nil == CurItem or self.SettingIsMoving then
		return
	end	

	if CurItem.IsTop then
		MsgTipsUtil.ShowTips(LSTR(50175)) -- "无法移动"
		return
	end	

	if CurItem.IsHide then
		MsgTipsUtil.ShowTips(LSTR(50176)) -- "隐藏频道无法调整顺序"
		return
	end

	local ItemVMList = ChatVM.SettingSortItemVMList 
	if nil == ItemVMList then
		return
	end

	local Channel = CurItem.Channel
	local _, Idx = ItemVMList:Find(function(e) return e.Channel == Channel end)	
	if nil == Idx or Idx <= 1 then
		return
	end

	self.SettingIsMoving = true 

	for i = 1, Idx - 1 do
        local Item = ItemVMList:Get(i)
		if Item then
			Item:SetPos(i + 1)
		end
	end

	CurItem:SetPos(1)

	ChatVM:SortSettingSortItemVMList()
	self.SettingIsMoving = nil 

	EventMgr:SendEvent(EventID.ChatScroolSettingSortItemIntoView, 1)
end

---置底
function ChatSettingChannelSortItemPanelView:OnClickButtonPinToBottom()
	local CurItem = self.ViewModel
	if nil == CurItem or self.SettingIsMoving then
		return
	end	

	if CurItem.IsBottom then
		MsgTipsUtil.ShowTips(LSTR(50175)) -- "无法移动"
		return
	end	

	if CurItem.IsHide then
		MsgTipsUtil.ShowTips(LSTR(50176)) -- "隐藏频道无法调整顺序"
		return
	end

	local ItemVMList = ChatVM.SettingSortItemVMList 
	if nil == ItemVMList then
		return
	end

	local Length = ItemVMList:Length()

	local Channel = CurItem.Channel
	local _, Idx = ItemVMList:Find(function(e) return e.Channel == Channel end)	
	if nil == Idx or Idx >= Length then
		return
	end

	self.SettingIsMoving = true 

	for i = 1, Length do
        local Item = ItemVMList:Get(i)
		if Item then
			Item:SetPos(i - 1)
		end
	end

	CurItem:SetPos(Length)

	ChatVM:SortSettingSortItemVMList()
	self.SettingIsMoving = nil 

	EventMgr:SendEvent(EventID.ChatScroolSettingSortItemIntoView, Length)
end

---上移
function ChatSettingChannelSortItemPanelView:OnClickButtonMoveUp()
	local CurItem = self.ViewModel
	if nil == CurItem or self.SettingIsMoving then
		return
	end	

	if CurItem.IsTop then
		MsgTipsUtil.ShowTips(LSTR(50175)) -- "无法移动"
		return
	end	

	if CurItem.IsHide then
		MsgTipsUtil.ShowTips(LSTR(50176)) -- "隐藏频道无法调整顺序"
		return
	end

	local ItemVMList = ChatVM.SettingSortItemVMList 
	if nil == ItemVMList then
		return
	end

	local Channel = CurItem.Channel
	local _, Idx = ItemVMList:Find(function(e) return e.Channel == Channel end)	
	if nil == Idx or Idx <= 1 then
		return
	end

	local PrevItem = ItemVMList:Get(Idx - 1)
	if nil == PrevItem then
		return
	end

	self.SettingIsMoving = true 

	PrevItem:SetPos(Idx)
	CurItem:SetPos(Idx - 1)

	ChatVM:SortSettingSortItemVMList()
	self.SettingIsMoving = nil 

	EventMgr:SendEvent(EventID.ChatScroolSettingSortItemIntoView, Idx - 1)
end

---下移	
function ChatSettingChannelSortItemPanelView:OnClickButtonMoveDown()
	local CurItem = self.ViewModel
	if nil == CurItem or self.SettingIsMoving then
		return
	end	

	if CurItem.IsBottom then
		MsgTipsUtil.ShowTips(LSTR(50175)) -- "无法移动"
		return
	end	

	if CurItem.IsHide then
		MsgTipsUtil.ShowTips(LSTR(50176)) -- "隐藏频道无法调整顺序"
		return
	end

	local ItemVMList = ChatVM.SettingSortItemVMList 
	if nil == ItemVMList then
		return
	end

	local Length = ItemVMList:Length()
	local Channel = CurItem.Channel
	local _, Idx = ItemVMList:Find(function(e) return e.Channel == Channel end)	
	if nil == Idx or Idx >= Length then
		return
	end

	local NextItem = ItemVMList:Get(Idx + 1)
	if nil == NextItem then
		return
	end

	self.SettingIsMoving = true 

	NextItem:SetPos(Idx)
	CurItem:SetPos(Idx + 1)

	ChatVM:SortSettingSortItemVMList()
	self.SettingIsMoving = nil 

	EventMgr:SendEvent(EventID.ChatScroolSettingSortItemIntoView, Idx + 1)
end

return ChatSettingChannelSortItemPanelView