---
--- Author: xingcaicao
--- DateTime: 2024-12-19 20:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText  = require("Binder/UIBinderSetText")
local ChatSetting = require("Game/Chat/ChatSetting")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local ChatVM = require("Game/Chat/ChatVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIDefine = require("Define/UIDefine")

local CheckBoxStyle = UIDefine.SearchBtnColorType.Dark

---@class ChatSettingGroupItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CheckBox CommSingleBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatSettingGroupItemView = LuaClass(UIView, true)

function ChatSettingGroupItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CheckBox = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatSettingGroupItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CheckBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatSettingGroupItemView:OnInit()
	self.Binders = {
		{"Name", UIBinderSetText.New(self, self.CheckBox)},
	}

	self.BindersChatVM = {
		{ "IsSettingGroupChecked", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedIsSettingGroupChecked) }
	}
end

function ChatSettingGroupItemView:OnDestroy()

end

function ChatSettingGroupItemView:OnShow()

end

function ChatSettingGroupItemView:OnHide()

end

function ChatSettingGroupItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CheckBox, self.OnToggleStateChanged)
end

function ChatSettingGroupItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ChatSettingComprehensiveChannelBlockGroupClear, self.OnEventBlockGroupClear)
end

function ChatSettingGroupItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self:RegisterBinders(ChatVM, self.BindersChatVM)

	self.GroupID = ViewModel.ChannelID

	-- 选择状态
	local IsChecked = ChatSetting.IsDisplayInComprehensiveChannelByGroupID(self.GroupID)
	self.CheckBox:SetChecked(IsChecked, false)
end

function ChatSettingGroupItemView:OnToggleStateChanged(ToggleButton, State)
	local GroupID = self.GroupID
	if nil == GroupID then 
		return
	end

	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	EventMgr:SendEvent(EventID.ChatSettingComprehensiveChannelBlockGroup, GroupID, IsChecked)
end

function ChatSettingGroupItemView:OnEventBlockGroupClear() 
	self.CheckBox:SetChecked(true, false)
end

function ChatSettingGroupItemView:OnValueChangedIsSettingGroupChecked(NewValue) 
	local IsGrey = not NewValue
	local CheckBox = self.CheckBox
	CheckBox:SetColorType(CheckBoxStyle, IsGrey)
	CheckBox:SetIsEnabled(not IsGrey)
end

return ChatSettingGroupItemView