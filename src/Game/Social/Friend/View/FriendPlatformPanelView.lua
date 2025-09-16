---
--- Author: xingcaicao
--- DateTime: 2025-04-17 18:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SocialDefine = require("Game/Social/SocialDefine")
local FriendVM = require("Game/Social/Friend/FriendVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local FriendDefine = require("Game/Social/Friend/FriendDefine")

local TabType = SocialDefine.TabType
local FLOG_WARNING = _G.FLOG_WARNING

local LSTR = _G.LSTR
local ListState = FriendDefine.ListState

---@class FriendPlatformPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommEmpty CommBackpackEmptyView
---@field PanelSearch UFCanvasPanel
---@field SearchInput CommSearchBarView
---@field TableViewList UTableView
---@field AnimIn UWidgetAnimation
---@field AnimUpdateList UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FriendPlatformPanelView = LuaClass(UIView, true)

function FriendPlatformPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommEmpty = nil
	--self.PanelSearch = nil
	--self.SearchInput = nil
	--self.TableViewList = nil
	--self.AnimIn = nil
	--self.AnimUpdateList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FriendPlatformPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.SearchInput)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FriendPlatformPanelView:OnInit()
    self.TableAdapterList = UIAdapterTableView.CreateAdapter(self, self.TableViewList)

	self.SearchInput:SetCallback(self, nil, self.OnSearchTextCommitted, self.OnClickCancelSearchInput)

	self.Binders = {
		{ "ShowingPlatformFriendItemVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterList) },
		{ "PlatformFriendListState", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedFriendListState) },
	}

	UIUtil.SetIsVisible(self.PanelSearch, false)
end

function FriendPlatformPanelView:OnDestroy()

end

function FriendPlatformPanelView:OnShow()
	self.SearchInput:SetText("")

	-- 更新角色信息
	FriendVM:UpdatePlatformFriendRoleInfos()
end

function FriendPlatformPanelView:OnHide()
	FriendVM:ClearPlatformFriendFilterData()
end

function FriendPlatformPanelView:OnRegisterUIEvent()

end

function FriendPlatformPanelView:OnRegisterGameEvent()

end

function FriendPlatformPanelView:OnRegisterBinder()
	self:RegisterBinders(FriendVM, self.Binders)
end

function FriendPlatformPanelView:SelectTab( Key )
	local SearchHintKey = nil
	if Key == TabType.WeChatFriend then
		SearchHintKey = 30069 -- "搜索微信好友"

	elseif Key == TabType.QQFriend then
		SearchHintKey = 30070 -- "搜索QQ好友"

	else
		FLOG_WARNING("[FriendPlatformPanelView] SelectTab, the Key is invalid. " .. tostring(Key))
		return
	end

	self.SearchInput:SetHintText(LSTR(SearchHintKey))

end

---@param SearchText string @回调的文本
function FriendPlatformPanelView:OnSearchTextCommitted(SearchText)
	if not string.isnilorempty(SearchText) then
		FriendVM:FilterPlatformFriendByKeyword(SearchText)
	end
end

function FriendPlatformPanelView:OnClickCancelSearchInput()
	self.SearchInput:SetText("")
	FriendVM:ClearPlatformFriendFilterData()
end

function FriendPlatformPanelView:OnValueChangedFriendListState(NewValue)
	if NewValue == ListState.Normal then
		UIUtil.SetIsVisible(self.CommEmpty, false)
		return
	end

	local CommEmpty = self.CommEmpty 
	UIUtil.SetIsVisible(CommEmpty, true)

	local Tips = "" 
	if NewValue == ListState.NoFriend then
		Tips = LSTR(30074) -- "暂时还没有好友哦！"

	elseif NewValue == ListState.SearchEmpty then
		Tips = LSTR(30073) -- "未找到该好友"
	end

	CommEmpty:SetTipsContent(Tips)
end

return FriendPlatformPanelView