---
--- Author: xingcaicao
--- DateTime: 2025-03-24 14:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ChatVM = require("Game/Chat/ChatVM")
local ChatSetting = require("Game/Chat/ChatSetting")

local LSTR = _G.LSTR

---@class ChatSettingChannelSortPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewList UTableView
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatSettingChannelSortPanelView = LuaClass(UIView, true)

function ChatSettingChannelSortPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewList = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatSettingChannelSortPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatSettingChannelSortPanelView:OnInit()
	self.TextTitle:SetText(LSTR(50025)) -- "频道排序与显隐"

	self.TableAdapterList = UIAdapterTableView.CreateAdapter(self, self.TableViewList)

	self.Binders = {
		{ "SettingSortItemVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterList) },
	}
end

function ChatSettingChannelSortPanelView:OnDestroy()

end

function ChatSettingChannelSortPanelView:OnShow()
	ChatVM:TryInitSettingSortItemVMList()
end

function ChatSettingChannelSortPanelView:OnHide()
	ChatVM:SaveSettingSortInfo()
end

function ChatSettingChannelSortPanelView:OnRegisterUIEvent()

end

function ChatSettingChannelSortPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ChatScroolSettingSortItemIntoView, self.OnEventScroolSettingSortItemIntoView)
end

function ChatSettingChannelSortPanelView:OnRegisterBinder()
	self:RegisterBinders(ChatVM, self.Binders)
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function ChatSettingChannelSortPanelView:OnEventScroolSettingSortItemIntoView(Idx)
	self.TableAdapterList:ScrollToIndex(Idx)
end

return ChatSettingChannelSortPanelView