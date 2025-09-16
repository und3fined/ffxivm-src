---
--- Author: v_vvxinchen
--- DateTime: 2024-07-24 11:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class CraftingLogSearchHistoryItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDelete UFButton
---@field BtnRefresh UFButton
---@field PanelSearchHistory UFCanvasPanel
---@field TableViewHistory UTableView
---@field TextSearchHistory UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CraftingLogSearchHistoryItemView = LuaClass(UIView, true)

function CraftingLogSearchHistoryItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDelete = nil
	--self.BtnRefresh = nil
	--self.PanelSearchHistory = nil
	--self.TableViewHistory = nil
	--self.TextSearchHistory = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CraftingLogSearchHistoryItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CraftingLogSearchHistoryItemView:OnInit()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewHistory, nil, true)
	self.TableViewAdapter:SetOnClickedCallback(self.OnSearchHistoryBtnClick)
	self.Binders = {
		{"TableViewHistoryAdapter", UIBinderUpdateBindableList.New(self, self.TableViewAdapter)},
		{"bBtnDeleteShow", UIBinderSetIsVisible.New(self, self.PanelSearchHistory)},
	}
end

function CraftingLogSearchHistoryItemView:OnDestroy()

end

function CraftingLogSearchHistoryItemView:OnShow()
	self.TextSearchHistory:SetText(_G.LSTR(80052)) --历史搜索
	self:RefreshSearchHistory()
end

function CraftingLogSearchHistoryItemView:OnHide()

end

function CraftingLogSearchHistoryItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnDeleteHistoryBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnRefresh, self.RefreshSearchHistory)
end

function CraftingLogSearchHistoryItemView:OnRegisterGameEvent()

end

function CraftingLogSearchHistoryItemView:OnRegisterBinder()
	self:RegisterBinders(_G.CraftingLogVM, self.Binders)
end

---@type 点击单个历史记录
function CraftingLogSearchHistoryItemView:OnSearchHistoryBtnClick(Index, ItemData, ItemView)
	local SearchText = ItemView.TextHistoryContent:GetText()
	if string.isnilorempty(SearchText) then
		return
	end
	EventMgr:SendEvent(EventID.CraftingLogFastSearch, SearchText)
	_G.CraftingLogVM.bSearchHistoryShow = false
end

---@type 清空搜索历史
function CraftingLogSearchHistoryItemView:OnDeleteHistoryBtnClicked()
	_G.CraftingLogVM:ClearSearchHistory()
	self:RefreshSearchHistory()
end

---@type 刷新搜索历史
function CraftingLogSearchHistoryItemView:RefreshSearchHistory()
	_G.CraftingLogVM:UpdateSearchHistoryListTab(_G.CraftingLogMgr:GetSearchHistory())
end

return CraftingLogSearchHistoryItemView