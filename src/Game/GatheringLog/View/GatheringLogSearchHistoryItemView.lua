--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-07-24 14:27:31
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-07-24 19:00:14
FilePath: \Client\Source\Script\Game\GatheringLog\View\GatheringLogSearchHistoryItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: v_vvxinchen
--- DateTime: 2024-07-23 19:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class GatheringLogSearchHistoryItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDelete UFButton
---@field BtnRefresh UFButton
---@field PanelSearchHistory UFCanvasPanel
---@field TableViewHistory UTableView
---@field TextSearchHistory UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringLogSearchHistoryItemView = LuaClass(UIView, true)

function GatheringLogSearchHistoryItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDelete = nil
	--self.BtnRefresh = nil
	--self.PanelSearchHistory = nil
	--self.TableViewHistory = nil
	--self.TextSearchHistory = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringLogSearchHistoryItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringLogSearchHistoryItemView:OnInit()
	self.TableViewHistoryAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewHistory, nil, true)
	self.TableViewHistoryAdapter:SetOnClickedCallback(self.OnSearchHistoryBtnClick)
	self.Binders = {
		{"SearchRecordVMList", UIBinderUpdateBindableList.New(self, self.TableViewHistoryAdapter)},
        {"bBtnDeleteShow", UIBinderSetIsVisible.New(self, self.PanelSearchHistory)},
    }
end

function GatheringLogSearchHistoryItemView:OnDestroy()

end

function GatheringLogSearchHistoryItemView:OnShow()
	self.TextSearchHistory:SetText(_G.LSTR(70047)) --历史搜索
	self:RefreshSearchHistory()
end

function GatheringLogSearchHistoryItemView:OnHide()

end

function GatheringLogSearchHistoryItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnDeleteHistoryBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnRefresh, self.RefreshSearchHistory)
end

function GatheringLogSearchHistoryItemView:OnRegisterGameEvent()

end

function GatheringLogSearchHistoryItemView:OnRegisterBinder()
	self:RegisterBinders(_G.GatheringLogVM, self.Binders)
end

---@type 点击单个历史记录
function GatheringLogSearchHistoryItemView:OnSearchHistoryBtnClick(Index, ItemData, ItemView)
	local SearchText = ItemView.TextHistoryContent:GetText()
	if string.isnilorempty(SearchText) then
		return
	end
	EventMgr:SendEvent(EventID.GatheringLogSearch, SearchText)
	_G.GatheringLogVM.bSearchHistoryShow = false
end

---@type 清空搜索历史
function GatheringLogSearchHistoryItemView:OnDeleteHistoryBtnClicked()
	_G.GatheringLogVM:ClearSearchHistory()
	self:RefreshSearchHistory()
end

---@type 刷新搜索历史
function GatheringLogSearchHistoryItemView:RefreshSearchHistory()
	_G.GatheringLogVM:UpdateSearchRecordList(_G.GatheringLogMgr.SearchRecordList)
end

return GatheringLogSearchHistoryItemView